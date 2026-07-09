#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

echo "================================"
echo " Clipboard Guardian Dev Runner "
echo "================================"
echo

echo "Cleaning python cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete


echo "Starting Clipboard Guardian..."

export PYTHONPATH="$ROOT_DIR"

export GSK_RENDERER=cairo

python3 -m src.main "$@"
