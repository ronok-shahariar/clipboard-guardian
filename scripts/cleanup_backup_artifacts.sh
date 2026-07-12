#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Cleanup Backup Artifacts"
echo "===================================="


echo
echo "Updating .gitignore..."

python3 - <<'PY'

from pathlib import Path

p = Path(".gitignore")

text = p.read_text()

entry = """
# Temporary patch backups
*.backup*
"""

if "*.backup*" not in text:
    text += entry

p.write_text(text)

PY


echo
echo "Removing tracked/untracked temporary backups..."

find src \
    -name "*.backup*" \
    -type f \
    -delete


echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Verification..."

echo "--- Backup files ---"
find . -name "*.backup*" -o -name "*backup*" || true


echo
echo "--- Git status ---"
git status


echo
echo "===================================="
echo " Cleanup completed"
echo "===================================="
