#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Sync Tray Menu With Config "
echo "===================================="


FILE="src/tray/tray_process.py"


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_sync_config"



python3 - <<'PY'

from pathlib import Path

p = Path("src/tray/tray_process.py")

s = p.read_text()


# Add ConfigManager import

old = """
from gi.repository import Gtk
"""


new = """
from gi.repository import Gtk

from src.managers.config_manager import ConfigManager
"""


if "from src.managers.config_manager import ConfigManager" not in s:

    if old not in s:
        raise SystemExit("GTK import block not found")

    s=s.replace(old,new)



# Replace initial states

old = """
        self.window_visible = False
        self.monitoring = True
        self.notify_me = True
        self.toast = True
"""


new = """
        self.window_visible = False

        self.config = ConfigManager()
        self.config.load()

        self.monitoring = self.config.get_default(
            "monitoring",
            True
        )

        self.notify_me = self.config.get_default(
            "notifications",
            True
        )

        self.toast = self.config.get_default(
            "toast",
            True
        )
"""


if old not in s:
    raise SystemExit("State block not found")


s=s.replace(old,new)



# Replace menu labels

s=s.replace(
'''
self.monitor_item = Gtk.MenuItem(label="Monitoring: ON")
''',
'''
self.monitor_item = Gtk.MenuItem(
    label=f"Monitoring: {'ON' if self.monitoring else 'OFF'}"
)
'''
)


s=s.replace(
'''
self.notify_item = Gtk.MenuItem(label="Notify Me: ON")
''',
'''
self.notify_item = Gtk.MenuItem(
    label=f"Notify Me: {'ON' if self.notify_me else 'OFF'}"
)
'''
)


s=s.replace(
'''
self.toast_item = Gtk.MenuItem(label="Toast: ON")
''',
'''
self.toast_item = Gtk.MenuItem(
    label=f"Toast: {'ON' if self.toast else 'OFF'}"
)
'''
)


p.write_text(s)

print("Tray menu synced with config")

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
echo " Tray Config Sync Complete "
echo "===================================="
