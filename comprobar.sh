#!/usr/bin/env bash
# Valida manifiestos, frontmatter YAML y contenido sensible.
set -euo pipefail
cd "$(dirname "$0")"
exec python3 scripts/validar.py
