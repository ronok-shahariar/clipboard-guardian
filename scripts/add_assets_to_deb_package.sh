#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Add Assets To Debian Package"
echo "===================================="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

BUILD_SCRIPT="$ROOT_DIR/scripts/build_deb.sh"


echo
echo "Creating backup..."

cp "$BUILD_SCRIPT" \
"$BUILD_SCRIPT.backup_assets"


echo
echo "Updating build script..."


python3 - "$BUILD_SCRIPT" <<'PY'

from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()


old = '''cp -a "$ROOT_DIR/src" \\
"$BUILD_DIR/usr/share/${APP_ID}/"
'''


new = '''cp -a "$ROOT_DIR/src" \\
"$BUILD_DIR/usr/share/${APP_ID}/"


################################
# Assets
################################

cp -a "$ROOT_DIR/assets" \\
"$BUILD_DIR/usr/share/${APP_ID}/"
'''


if "Assets" not in text:

    text = text.replace(
        old,
        new
    )

    path.write_text(text)

else:
    print("Assets section already exists")

PY


echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Syntax check..."

bash -n "$BUILD_SCRIPT"


echo
echo "===================================="
echo " Assets added to package builder"
echo "===================================="
