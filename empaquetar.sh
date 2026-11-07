#!/usr/bin/env bash
# Genera zips reproducibles y SHA256SUMS; valida antes de reemplazar dist.
set -euo pipefail
cd "$(dirname "$0")"
bash ./comprobar.sh
python3 scripts/empaquetar.py
