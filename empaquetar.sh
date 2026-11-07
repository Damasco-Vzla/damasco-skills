#!/usr/bin/env bash
# Genera dist/<skill>.zip por cada skill de dacuotas/skills, con la carpeta de
# la skill en la raíz del zip, para subirlos a claude.ai. Antes valida el
# frontmatter con comprobar.sh.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
cd "$AQUI"

bash ./comprobar.sh

rm -rf dist
mkdir -p dist
cd dacuotas/skills
for d in */; do
  s="${d%/}"
  # Sin agents/openai.yaml: es sólo para ChatGPT/Codex y claude.ai no lo usa.
  zip -qr "../../dist/$s.zip" "$s" -x "$s/agents/*" -x "*.DS_Store"
  echo "dist/$s.zip"
done
