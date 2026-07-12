#!/usr/bin/env bash

set -euo pipefail


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "===================================="
echo " Adding Settings Window Support "
echo "===================================="


########################################
# Backup
########################################

echo
echo "Creating backups..."

cp "$ROOT_DIR/src/tray/tray_process.py" \
"$ROOT_DIR/src/tray/tray_process.py.backup_settings"

cp "$ROOT_DIR/src/services/tray_service.py" \
"$ROOT_DIR/src/services/tray_service.py.backup_settings"


########################################
# Create settings window
########################################

echo
echo "Creating settings window..."


cat > "$ROOT_DIR/src/gui/windows/settings_window.py" <<'PY'
from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk

from src.managers.config_manager import ConfigManager


class SettingsWindow(Gtk.Window):

    def __init__(self):

        super().__init__(
            title="Clipboard Guardian Settings"
        )

        self.set_default_size(
            350,
            300
        )


        self.config = ConfigManager()
        self.config.load()


        box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12
        )

        box.set_margin_top(20)
        box.set_margin_bottom(20)
        box.set_margin_start(20)
        box.set_margin_end(20)


        self.monitor_check = Gtk.CheckButton(
            label="Enable Monitoring"
        )

        self.notify_check = Gtk.CheckButton(
            label="Enable Notifications"
        )

        self.toast_check = Gtk.CheckButton(
            label="Enable Toast Popup"
        )

        self.hidden_check = Gtk.CheckButton(
            label="Start Hidden"
        )


        self.monitor_check.set_active(
            self.config.get_default(
                "monitoring",
                True
            )
        )

        self.notify_check.set_active(
            self.config.get_default(
                "notifications",
                True
            )
        )

        self.toast_check.set_active(
            self.config.get_default(
                "toast",
                True
            )
        )

        self.hidden_check.set_active(
            self.config.get_default(
                "start_hidden",
                False
            )
        )


        save = Gtk.Button(
            label="Save Settings"
        )

        save.connect(
            "clicked",
            self.save_settings
        )


        box.append(self.monitor_check)
        box.append(self.notify_check)
        box.append(self.toast_check)
        box.append(self.hidden_check)
        box.append(save)


        self.set_child(box)



    def save_settings(self, *_):

        self.config.set_default(
            "monitoring",
            self.monitor_check.get_active()
        )

        self.config.set_default(
            "notifications",
            self.notify_check.get_active()
        )

        self.config.set_default(
            "toast",
            self.toast_check.get_active()
        )

        self.config.set_default(
            "start_hidden",
            self.hidden_check.get_active()
        )


        self.config.save()

        self.close()
PY


########################################
# Add IPC command handler
########################################

echo
echo "Updating TrayService..."


python3 <<PY

from pathlib import Path

p = Path("$ROOT_DIR/src/services/tray_service.py")

s = p.read_text()


old = '''
    def handle_command(self, command: str):

'''


new = '''
    def handle_command(self, command: str):

        if command == "open_settings":

            from src.gui.windows.settings_window import SettingsWindow

            window = SettingsWindow()

            window.present()

            return False

'''


if old not in s:
    raise SystemExit("TrayService handler not found")


s=s.replace(old,new)


p.write_text(s)

print("TrayService updated")

PY



########################################
# Update tray process
########################################

echo
echo "Updating tray menu..."


python3 <<PY

from pathlib import Path

p = Path("$ROOT_DIR/src/tray/tray_process.py")

s=p.read_text()


target='''        self.menu.append(self.show_hide_item)

        self.monitor_item =
'''


insert='''        self.menu.append(self.show_hide_item)


        settings_item = Gtk.MenuItem(
            label="Settings..."
        )

        settings_item.connect(
            "activate",
            lambda *_: send_command("open_settings")
        )

        self.menu.append(settings_item)


        self.monitor_item =
'''


if target not in s:
    raise SystemExit("Tray menu location not found")


s=s.replace(target,insert)


p.write_text(s)

print("Tray updated")

PY



########################################
# Cleanup
########################################

echo
echo "Cleaning cache..."

find "$ROOT_DIR/src" \
-type d \
-name "__pycache__" \
-exec rm -rf {} +


find "$ROOT_DIR/src" \
-type f \
-name "*.pyc" \
-delete



########################################
# Syntax check
########################################

echo
echo "Syntax check..."

python3 -m compileall "$ROOT_DIR/src" -q


echo
echo "===================================="
echo " Settings window added "
echo "===================================="
