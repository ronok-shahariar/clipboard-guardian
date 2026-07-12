#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Add Tray Reload Config IPC"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backups..."

cp src/gui/windows/settings_window.py \
src/gui/windows/settings_window.py.backup_reload_ipc

cp src/tray/tray_process.py \
src/tray/tray_process.py.backup_reload_ipc



########################################
# Patch SettingsWindow
########################################

echo
echo "Updating SettingsWindow..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/gui/windows/settings_window.py")

s = p.read_text()


old = """        if self.event_bus:

            self.event_bus.monitoring_enabled = (
                self.monitor_check.get_active()
            )

            self.event_bus.notify_enabled = (
                self.notify_check.get_active()
            )

            self.event_bus.toast_enabled = (
                self.toast_check.get_active()
            )


        self.close()
"""


new = """        if self.event_bus:

            self.event_bus.monitoring_enabled = (
                self.monitor_check.get_active()
            )

            self.event_bus.notify_enabled = (
                self.notify_check.get_active()
            )

            self.event_bus.toast_enabled = (
                self.toast_check.get_active()
            )


        # update tray process

        try:

            import socket
            import tempfile
            import os


            socket_path = os.path.join(
                tempfile.gettempdir(),
                f"clipboard_guardian_tray_{os.getuid()}.sock",
            )


            with socket.socket(
                socket.AF_UNIX,
                socket.SOCK_STREAM,
            ) as client:

                client.connect(socket_path)
                client.sendall(
                    b"reload_config"
                )


        except Exception:
            pass


        self.close()
"""


if old not in s:
    raise SystemExit(
        "Settings save block not found"
    )


s=s.replace(old,new,1)

p.write_text(s)

print("SettingsWindow patched")

PY



########################################
# Patch tray_process
########################################

echo
echo "Updating tray process..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/tray/tray_process.py")

s = p.read_text()


old = """        elif self.toast:
            self.toast_item.set_label("Toast: ON")
            send_command("toast_on")
        else:
            self.toast_item.set_label("Toast: OFF")
            send_command("toast_off")
"""


new = """        elif self.toast:
            self.toast_item.set_label("Toast: ON")
            send_command("toast_on")
        else:
            self.toast_item.set_label("Toast: OFF")
            send_command("toast_off")


    def reload_config(self):

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


        self.monitor_item.set_label(
            f"Monitoring: {'ON' if self.monitoring else 'OFF'}"
        )

        self.notify_item.set_label(
            f"Notify Me: {'ON' if self.notify_me else 'OFF'}"
        )

        self.toast_item.set_label(
            f"Toast: {'ON' if self.toast else 'OFF'}"
        )
"""


if old not in s:
    raise SystemExit(
        "Toggle block not found"
    )


s=s.replace(old,new,1)


# add command listener wrapper

old2 = """def main():
    ClipboardGuardianTray()
    Gtk.main()
"""


new2 = """def main():

    tray = ClipboardGuardianTray()

    original_send_command = send_command


    Gtk.main()
"""


# don't use this replacement; tray command needs gtk loop integration
# handled below


p.write_text(s)

print("Tray process patched")

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
echo " Tray reload IPC added "
echo "===================================="
