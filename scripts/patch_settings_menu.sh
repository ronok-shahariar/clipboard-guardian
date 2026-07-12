#!/usr/bin/env bash

set -euo pipefail

echo "Adding Settings menu item..."

FILE="src/tray/tray_process.py"

cp "$FILE" "$FILE.backup_settings_menu"


python3 - <<'PY'

from pathlib import Path

p = Path("src/tray/tray_process.py")

s = p.read_text()


old = '''        self.toast_item = Gtk.MenuItem(label="Toast: ON")
        self.toast_item.connect("activate", self.toggle_toast)
        self.menu.append(self.toast_item)

        refresh_item = Gtk.MenuItem(label="Refresh Window")
'''

new = '''        self.toast_item = Gtk.MenuItem(label="Toast: ON")
        self.toast_item.connect("activate", self.toggle_toast)
        self.menu.append(self.toast_item)

        settings_item = Gtk.MenuItem(label="Settings")
        settings_item.connect(
            "activate",
            lambda *_: send_command("open_settings")
        )
        self.menu.append(settings_item)

        refresh_item = Gtk.MenuItem(label="Refresh Window")
'''


if old not in s:
    raise SystemExit("Menu insertion point not found")


s = s.replace(old,new)

p.write_text(s)

print("tray_process.py updated")

PY
