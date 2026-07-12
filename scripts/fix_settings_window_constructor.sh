#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix Settings Window Constructor"
echo "===================================="


FILE="src/gui/windows/settings_window.py"


if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE not found"
    exit 1
fi


echo "Creating backup..."

cp "$FILE" "$FILE.backup_constructor_fix"


echo "Updating constructor..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/gui/windows/settings_window.py")

s = p.read_text()


old = '''    def __init__(self):

        super().__init__(
            title="Clipboard Guardian Settings"
        )
'''


new = '''    def __init__(self, application=None):

        super().__init__(
            title="Clipboard Guardian Settings"
        )

        self.application = application
'''


if old not in s:
    raise SystemExit(
        "Constructor pattern not found. File may already be updated."
    )


s = s.replace(old, new)


p.write_text(s)

print("SettingsWindow constructor updated")

PY


echo
echo "Cleaning python cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete


echo
echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " Settings constructor fixed "
echo "===================================="
