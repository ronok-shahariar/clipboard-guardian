#!/bin/bash

set -e

echo "Adding postrm to Debian builder..."

cpfile="scripts/build_deb.sh"

python3 - <<'PY'
from pathlib import Path

p = Path("scripts/build_deb.sh")

text = p.read_text()

old = '''cp "$ROOT_DIR/packaging/debian/prerm" "$BUILD_DIR/DEBIAN/prerm" 2>/dev/null || true
'''

new = '''cp "$ROOT_DIR/packaging/debian/prerm" "$BUILD_DIR/DEBIAN/prerm" 2>/dev/null || true

cp "$ROOT_DIR/packaging/debian/postrm" "$BUILD_DIR/DEBIAN/postrm" 2>/dev/null || true
'''

if "packaging/debian/postrm" not in text:
    text = text.replace(old, new)

p.write_text(text)

PY


echo "postrm added to builder"
