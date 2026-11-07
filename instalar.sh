#!/usr/bin/env bash
# Instala las skills y el servidor MCP del DWH de Da+Cuotas en este ordenador.
#
#   curl -fsSL https://raw.githubusercontent.com/Damasco-Vzla/damasco-skills/main/instalar.sh | bash
#   curl -fsSL .../instalar.sh | bash -s -- --solo-mostrar    # no toca nada
#
# Detecta Claude Code, Codex y Cursor. Sin sudo y sin Docker. Antes de cambiar
# un fichero de configuración deja una copia .bak única y nunca borra otros servidores.
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
      printf '%s\n' 'Uso: bash instalar.sh [--solo-mostrar]' 'Instala skills y configura clientes disponibles. --solo-mostrar no escribe ni descarga.'
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
  if [ "$SOLO_MOSTRAR" = 1 ]; then
    echo "[mostrar] Descargar $REPO ($REF), instalar skills en $HOME/.agents/skills"
    echo "[mostrar] Configurar los clientes disponibles con $URL_MCP; no se ha descargado ni modificado nada."
    exit 0
  fi
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Descargando $REPO ($REF)..."
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$TMP"
  AQUI="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -1)"
fi
SKILLS="$AQUI/dacuotas/skills"
[ -d "$SKILLS" ] || { echo "no encuentro $SKILLS" >&2; exit 1; }
# Rechazar fuentes incompletas o enlaces antes de cambiar ningún cliente.
shopt -s nullglob
FUENTES=("$SKILLS"/*/)
[ "${#FUENTES[@]}" -gt 0 ] || { echo "No hay skills para instalar" >&2; exit 1; }
if [ -L "$SKILLS" ] || [ -n "$(find "$SKILLS" -type l -print -quit)" ]; then
  echo "No se admiten enlaces simbólicos en las skills" >&2
  exit 1
fi
for fuente in "${FUENTES[@]}"; do
  nombre="$(basename "$fuente")"
  if [[ ! "$nombre" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ ! -f "$fuente/SKILL.md" ]; then
    echo "Skill inválida: $nombre" >&2
    exit 1
  fi
done

echo
echo "== Claude Code =="
if command -v claude >/dev/null 2>&1; then
  if claude plugin marketplace list 2>/dev/null | grep -q "damasco"; then
    hacer claude plugin marketplace update damasco || FALLO_CLAUDE=1
  else
    hacer claude plugin marketplace add "$REPO" || FALLO_CLAUDE=1
  fi
  if claude plugin list 2>/dev/null | grep -q "dacuotas@damasco"; then
    hacer claude plugin update dacuotas@damasco || FALLO_CLAUDE=1
  else
    hacer claude plugin install dacuotas@damasco || FALLO_CLAUDE=1
  fi
  if claude mcp list 2>/dev/null | grep -qE "^$NOMBRE:"; then
    echo "  Aviso: ya tienes $NOMBRE dado de alta a mano y el plugin trae el suyo."
    echo "  Para no tenerlo dos veces: claude mcp remove $NOMBRE -s user"
  fi
  if [ "${FALLO_CLAUDE:-0}" = 1 ]; then
    echo "  Algo falló en Claude Code; sigue instalacion/claude.md a mano."
  fi
  echo "  En una sesión de Claude Code: /mcp, $NOMBRE, iniciar sesión."
else
  echo "  no hay 'claude' en el PATH; se omite"
fi

echo
echo "== Skills para Cursor, Codex y Grok Bot (~/.agents/skills) =="
DESTINO="$HOME/.agents/skills"
hacer mkdir -p "$DESTINO"
# Preparar la copia antes de apartar una instalación existente. Nunca borrarla.
shopt -s nullglob
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  if [ ! -f "$d/SKILL.md" ] || [ -L "${d%/}" ]; then
    echo "Skill inválida: $s" >&2
    exit 1
  fi
  if [ "$SOLO_MOSTRAR" = 1 ]; then
    echo "  [mostrar] copiar $s; conservar instalación anterior en $DESTINO/.damasco-backups"
    continue
  fi
  STAGE="$(mktemp -d "$DESTINO/.damasco-stage.XXXXXX")"
  if ! cp -R "$d/." "$STAGE/"; then
    rm -rf "$STAGE"
    exit 1
  fi
  BACKUP=""
  if [ -e "$DESTINO/$s" ] || [ -L "$DESTINO/$s" ]; then
    mkdir -p "$DESTINO/.damasco-backups"
    BACKUP="$(mktemp -d "$DESTINO/.damasco-backups/$s.XXXXXX")/skill"
    if ! mv "$DESTINO/$s" "$BACKUP"; then
      rm -rf "$STAGE"
      exit 1
    fi
    echo "  copia anterior: $BACKUP"
  fi
  if ! mv "$STAGE" "$DESTINO/$s"; then
    [ -z "$BACKUP" ] || mv "$BACKUP" "$DESTINO/$s"
    rm -rf "$STAGE"
    exit 1
  fi
  echo "  $s"
done

echo
echo "== Cursor (~/.cursor/mcp.json) =="
if [ -d "$HOME/.cursor" ] || command -v cursor >/dev/null 2>&1; then
  CFG="$HOME/.cursor/mcp.json"
  if [ "$SOLO_MOSTRAR" = 1 ]; then
    echo "  [mostrar] añadir $NOMBRE a $CFG (con copia única $CFG.bak.*)"
  elif command -v python3 >/dev/null 2>&1; then
    mkdir -p "$(dirname "$CFG")"
    python3 - "$CFG" "$NOMBRE" "$URL_MCP" <<'PY'
import json, os, shutil, sys, tempfile
cfg, nombre, url = sys.argv[1:4]
datos = {}
if os.path.exists(cfg):
    with open(cfg, encoding="utf-8") as f:
        texto = f.read().strip()
    if texto:
        datos = json.loads(texto)
if not isinstance(datos, dict):
    sys.exit("Configuración Cursor inválida: se esperaba un objeto JSON; no se modificó")
servidores = datos.setdefault("mcpServers", {})
if not isinstance(servidores, dict):
    sys.exit("Configuración Cursor inválida: mcpServers debe ser un objeto; no se modificó")
existente = servidores.get(nombre)
if existente is not None and not isinstance(existente, dict):
    sys.exit("Entrada MCP existente inválida; no se modificó")
# No convertir silenciosamente un servidor local u otro transporte a HTTP.
# Conservar el fichero completo, sin respaldos ni escrituras innecesarias.
if isinstance(existente, dict) and (
    any(clave in existente for clave in ("command", "args"))
    or existente.get("type") not in (None, "http", "streamable-http", "streamable_http")
):
    print(f"  Aviso: {nombre} en {cfg} usa una configuración incompatible con HTTP.")
    print("  Se conserva sin modificar; revisa esa entrada a mano antes de configurar la URL MCP.")
    sys.exit(0)
if isinstance(existente, dict) and existente.get("url") == url:
    print(f"  {nombre} ya estaba en {cfg}")
    sys.exit(0)
if isinstance(existente, dict):
    print(f"  Aviso: {nombre} tiene una URL distinta o ausente.")
    print("  Se conserva sin modificar; revisa esa entrada a mano para evitar trasladar credenciales a otro destino.")
    sys.exit(0)
if os.path.exists(cfg):
    fd, copia = tempfile.mkstemp(prefix=os.path.basename(cfg) + ".bak.", dir=os.path.dirname(cfg))
    os.close(fd)
    shutil.copyfile(cfg, copia)
    print(f"  copia en {copia}")
servidores[nombre] = {"url": url}
fd, temporal = tempfile.mkstemp(prefix=".mcp.", dir=os.path.dirname(cfg))
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(datos, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(temporal, cfg)
finally:
    if os.path.exists(temporal):
        os.unlink(temporal)
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
  if codex mcp list 2>/dev/null | grep -qE "^$NOMBRE[[:space:]]"; then
    echo "  $NOMBRE ya estaba en Codex"
  else
    hacer codex mcp add "$NOMBRE" --url "$URL_MCP" \
      || echo "  no se pudo añadir en Codex; hazlo a mano (instalacion/chatgpt.md)"
  fi
  echo "  Codex abre el inicio de sesión al añadirlo; si no, codex mcp login $NOMBRE"
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
