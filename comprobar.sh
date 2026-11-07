#!/usr/bin/env bash
# Valida el repositorio antes de publicar:
#   1. Todos los JSON se leen.
#   2. Frontmatter de cada SKILL.md: sólo los campos del estándar Agent Skills,
#      name igual a la carpeta, description de menos de 1024 caracteres.
#   3. Nada sensible: correos, ARNs, cuentas, ids de instancia, claves.
#      Patrones adicionales privados en la variable PALABRAS_PROHIBIDAS (una
#      expresión regular por línea), que en CI viene de un secreto.
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import json, os, re, subprocess, sys

errores = []

# 1. JSON
for raiz, _, ficheros in os.walk("."):
    if "/.git" in raiz or raiz.startswith("./dist"):
        continue
    for f in ficheros:
        if f.endswith(".json"):
            ruta = os.path.join(raiz, f)
            try:
                json.load(open(ruta, encoding="utf-8"))
            except Exception as e:
                errores.append(f"{ruta}: JSON inválido: {e}")

# 2. Frontmatter
PERMITIDOS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
base = "dacuotas/skills"
for s in sorted(os.listdir(base)):
    ruta = os.path.join(base, s, "SKILL.md")
    if not os.path.isfile(ruta):
        continue
    texto = open(ruta, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", texto, re.S)
    if not m:
        errores.append(f"{ruta}: sin frontmatter")
        continue
    campos = {}
    for linea in m.group(1).splitlines():
        if linea and not linea.startswith((" ", "\t")):
            clave, _, valor = linea.partition(":")
            campos[clave.strip()] = valor.strip()
    sobran = set(campos) - PERMITIDOS
    if sobran:
        errores.append(f"{ruta}: campos no admitidos {sorted(sobran)}")
    if campos.get("name") != s:
        errores.append(f"{ruta}: name '{campos.get('name')}' distinto de la carpeta '{s}'")
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", campos.get("name", "")):
        errores.append(f"{ruta}: name no es minúsculas con guiones")
    desc = campos.get("description", "")
    if not desc or len(desc) >= 1024:
        errores.append(f"{ruta}: description vacía o de 1024 caracteres o más ({len(desc)})")

# 3. Contenido sensible, sobre los ficheros versionados o por versionar
PATRONES = [
    r"arn:aws",
    r"(?<![0-9])[0-9]{12}(?![0-9])",
    r"\bi-0[0-9a-f]{8,}\b",
    r"us-east-1_[A-Za-z0-9]+",
    r"(?i)cognito",
    r"(?i)@corporaciondamasco",
    r"damasco-prod-",
    r"\.secrets",
    r"AKIA[0-9A-Z]{16}",
    r"(?i)(password|secret|token)\s*[:=]\s*['\"][^'\"]{6,}",
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
]
extra = os.environ.get("PALABRAS_PROHIBIDAS", "")
PATRONES += [p.strip() for p in extra.splitlines() if p.strip()]

salida = subprocess.run(
    ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
    capture_output=True, text=True,
)
ficheros = salida.stdout.split() if salida.returncode == 0 else []
for ruta in ficheros:
    if ruta in ("comprobar.sh",) or ruta.endswith((".zip", ".png")):
        continue
    try:
        lineas = open(ruta, encoding="utf-8").read().splitlines()
    except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
        continue
    for n, linea in enumerate(lineas, 1):
        for p in PATRONES:
            if re.search(p, linea):
                # El patrón privado no se imprime para no publicarlo en el log.
                cual = p if p in PATRONES[:11] else "(patrón privado)"
                errores.append(f"{ruta}:{n}: contenido sensible {cual}")

if errores:
    print("\n".join(errores))
    sys.exit(1)
print(f"comprobar: ok ({len(ficheros)} ficheros, {len(PATRONES)} patrones)")
PY
