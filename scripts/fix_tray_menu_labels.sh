#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix Tray Dynamic Menu Labels "
echo "===================================="


FILE="src/tray/tray_process.py"


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_dynamic_labels"


python3 - <<'PY'

from pathlib import Path

p = Path("src/tray/tray_process.py")

s = p.read_text()


replacements = {

'''        self.monitor_item = Gtk.MenuItem(label="Monitoring: ON")
''':
'''        self.monitor_item = Gtk.MenuItem(
            label=f"Monitoring: {'ON' if self.monitoring else 'OFF'}"
        )
''',

'''        self.notify_item = Gtk.MenuItem(label="Notify Me: ON")
''':
'''        self.notify_item = Gtk.MenuItem(
            label=f"Notify Me: {'ON' if self.notify_me else 'OFF'}"
        )
''',

'''        self.toast_item = Gtk.MenuItem(label="Toast: ON")
''':
'''        self.toast_item = Gtk.MenuItem(
            label=f"Toast: {'ON' if self.toast else 'OFF'}"
        )
''',

}


for old,new in replacements.items():

    if old not in s:
        raise SystemExit(
            f"Pattern not found:\n{old}"
        )

    s=s.replace(old,new)


p.write_text(s)

print("Dynamic labels added")

PY


echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " Tray Labels Fixed "
echo "===================================="
