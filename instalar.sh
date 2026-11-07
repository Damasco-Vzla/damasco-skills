#!/usr/bin/env bash
# Instala las skills y el servidor MCP del DWH de Da+Cuotas en este ordenador.
#
#   curl -fsSL https://raw.githubusercontent.com/Damasco-Vzla/damasco-skills/main/instalar.sh | bash
#   curl -fsSL .../instalar.sh | bash -s -- --solo-mostrar    # no toca nada
#
# Detecta Claude Code, Codex y Cursor. Sin sudo y sin Docker. Antes de cambiar
# un fichero de configuración deja una copia .bak y nunca borra otros servidores.
# ChatGPT web y claude.ai son pantallas web: al final imprime los pasos.
set -euo pipefail

REPO="Damasco-Vzla/damasco-skills"
REF="${DAMASCO_SKILLS_REF:-main}"
URL_MCP="https://mambu-mirror.aplicacionesdamasco.com/mcp"
NOMBRE="dwh-dacuotas"
SOLO_MOSTRAR=0

for arg in "$@"; do
  case "$arg" in
    --solo-mostrar) SOLO_MOSTRAR=1 ;;
    -h|--help)
      sed -n '2,9p' "$0" 2>/dev/null || true
      exit 0 ;;
    *) echo "opción desconocida: $arg" >&2; exit 2 ;;
  esac
done

hacer() {
  # Ejecuta el comando o, con --solo-mostrar, sólo lo imprime.
  if [ "$SOLO_MOSTRAR" = 1 ]; then
    printf '  [mostrar] %s\n' "$*"
  else
    "$@"
  fi
}

# Origen de los ficheros: la copia local si el script se ejecuta desde el
# repositorio; si llega por tubería, se descarga el repositorio en un temporal.
AQUI=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -z "$AQUI" ] || [ ! -d "$AQUI/dacuotas/skills" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Descargando $REPO ($REF)..."
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$TMP"
  AQUI="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -1)"
fi
SKILLS="$AQUI/dacuotas/skills"
[ -d "$SKILLS" ] || { echo "no encuentro $SKILLS" >&2; exit 1; }

echo
echo "== Claude Code =="
if command -v claude >/dev/null 2>&1; then
  if claude plugin marketplace list 2>/dev/null | grep -q "damasco"; then
    hacer claude plugin marketplace update damasco
  else
    hacer claude plugin marketplace add "$REPO"
  fi
  if claude plugin list 2>/dev/null | grep -q "dacuotas@damasco"; then
    hacer claude plugin update dacuotas@damasco
  else
    hacer claude plugin install dacuotas@damasco
  fi
  if claude mcp list 2>/dev/null | grep -qE "^$NOMBRE:"; then
    echo "  Aviso: ya tienes $NOMBRE dado de alta a mano y el plugin trae el suyo."
    echo "  Para no tenerlo dos veces: claude mcp remove $NOMBRE -s user"
  fi
  echo "  En una sesión de Claude Code: /mcp, $NOMBRE, iniciar sesión."
else
  echo "  no hay 'claude' en el PATH; se omite"
fi

echo
echo "== Skills para Cursor, Codex y Grok Bot (~/.agents/skills) =="
DESTINO="$HOME/.agents/skills"
hacer mkdir -p "$DESTINO"
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  hacer rm -rf "$DESTINO/$s"
  hacer cp -R "$d" "$DESTINO/$s"
  echo "  $s"
done

echo
echo "== Cursor (~/.cursor/mcp.json) =="
if [ -d "$HOME/.cursor" ] || command -v cursor >/dev/null 2>&1; then
  CFG="$HOME/.cursor/mcp.json"
  if [ "$SOLO_MOSTRAR" = 1 ]; then
    echo "  [mostrar] añadir $NOMBRE a $CFG (con copia $CFG.bak)"
  elif command -v python3 >/dev/null 2>&1; then
    mkdir -p "$(dirname "$CFG")"
    python3 - "$CFG" "$NOMBRE" "$URL_MCP" <<'PY'
import json, os, shutil, sys
cfg, nombre, url = sys.argv[1:4]
datos = {}
if os.path.exists(cfg):
    with open(cfg, encoding="utf-8") as f:
        texto = f.read().strip()
    if texto:
        datos = json.loads(texto)
servidores = datos.setdefault("mcpServers", {})
if servidores.get(nombre, {}).get("url") == url:
    print(f"  {nombre} ya estaba en {cfg}")
    sys.exit(0)
if os.path.exists(cfg):
    shutil.copy(cfg, cfg + ".bak")
    print(f"  copia en {cfg}.bak")
servidores[nombre] = {"url": url}
with open(cfg, "w", encoding="utf-8") as f:
    json.dump(datos, f, indent=2, ensure_ascii=False)
    f.write("\n")
print(f"  escrito {cfg}")
PY
    echo "  En Cursor: Settings, MCP, pulsar $NOMBRE para iniciar sesión."
  else
    echo "  falta python3: añade a mano la entrada de instalacion/cursor.md"
  fi
else
  echo "  no hay Cursor; se omite"
fi

echo
echo "== Codex =="
if command -v codex >/dev/null 2>&1; then
  if codex mcp list 2>/dev/null | grep -q "$NOMBRE"; then
    echo "  $NOMBRE ya estaba en Codex"
  else
    hacer codex mcp add "$NOMBRE" --url "$URL_MCP"
  fi
  echo "  Para iniciar sesión: codex mcp login $NOMBRE"
else
  echo "  no hay 'codex' en el PATH; se omite"
fi

cat <<FIN

== A mano ==

ChatGPT web: modo desarrollador, chatgpt.com/plugins, «+», servidor MCP
  $URL_MCP con OAuth sin client id. Guía: instalacion/chatgpt.md

claude.ai: el conector lo añade el propietario de la organización (pide a TI
  el dato para claude.ai). Skills: zips de la última Release,
  https://github.com/$REPO/releases/latest. Guía: instalacion/claude.md

Sin usuario dado de alta por TI no se puede iniciar sesión.
FIN
