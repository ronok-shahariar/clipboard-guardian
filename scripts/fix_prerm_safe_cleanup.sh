#!/bin/bash

set -e

echo "Fixing safe Debian cleanup..."

python3 - <<'PY'
from pathlib import Path

p = Path("packaging/debian/prerm")

text = p.read_text()

text = text.replace(
'pkill -f "clipboard-guardian" || true',
'pkill -f "/usr/share/clipboard-guardian/src/main.py" || true'
)

p.write_text(text)
PY


chmod 755 packaging/debian/prerm


echo "Safe cleanup fixed"
