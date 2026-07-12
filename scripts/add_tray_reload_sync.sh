#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Add Tray Reload Sync"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backups..."

cp src/services/tray_service.py \
src/services/tray_service.py.backup_reload_sync

cp src/tray/tray_process.py \
src/tray/tray_process.py.backup_reload_sync



python3 - <<'PY'

from pathlib import Path


# -----------------------------
# TrayService
# -----------------------------

p = Path("src/services/tray_service.py")

s = p.read_text()


# add reload socket

old = '''        self.socket_path = os.path.join(
            tempfile.gettempdir(),
            f"clipboard_guardian_tray_{os.getuid()}.sock",
        )
'''


new = '''        self.socket_path = os.path.join(
            tempfile.gettempdir(),
            f"clipboard_guardian_tray_{os.getuid()}.sock",
        )

        self.reload_socket_path = os.path.join(
            tempfile.gettempdir(),
            f"clipboard_guardian_reload_{os.getuid()}.sock",
        )
'''


s=s.replace(old,new)



# add env

old = '''        env["CLIPBOARD_GUARDIAN_TRAY_SOCKET"] = self.socket_path

        self.process = subprocess.Popen(
'''


new = '''        env["CLIPBOARD_GUARDIAN_TRAY_SOCKET"] = self.socket_path

        env["CLIPBOARD_GUARDIAN_RELOAD_SOCKET"] = (
            self.reload_socket_path
        )

        self.process = subprocess.Popen(
'''


s=s.replace(old,new)



# add sender before handle_command

marker = '''    def handle_command(self, command: str):
'''


insert = '''
    def send_reload_command(self):

        try:

            with socket.socket(
                socket.AF_UNIX,
                socket.SOCK_STREAM,
            ) as client:

                client.connect(
                    self.reload_socket_path
                )

                client.sendall(
                    b"reload_config"
                )

        except Exception:

            pass


'''


s=s.replace(marker,insert+marker)



# add command

old = '''        elif command == "open_settings":

            from src.gui.windows.settings_window import SettingsWindow
'''


new = '''        elif command == "reload_tray":

            self.send_reload_command()


        elif command == "open_settings":

            from src.gui.windows.settings_window import SettingsWindow
'''


s=s.replace(old,new)


p.write_text(s)



# -----------------------------
# tray_process
# -----------------------------

p=Path("src/tray/tray_process.py")

s=p.read_text()


# add imports

s=s.replace(
"import socket\n",
"import socket\nimport threading\n"
)


# add reload socket variable

s=s.replace(
'SOCKET_PATH = os.environ.get("CLIPBOARD_GUARDIAN_TRAY_SOCKET")',
'''SOCKET_PATH = os.environ.get(
    "CLIPBOARD_GUARDIAN_TRAY_SOCKET"
)

RELOAD_SOCKET_PATH = os.environ.get(
    "CLIPBOARD_GUARDIAN_RELOAD_SOCKET"
)'''
)



# add reload method before quit

marker='''    def quit_app(self, *_args):
'''


insert='''
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


'''


s=s.replace(marker,insert+marker)



# replace main

old='''def main():
    ClipboardGuardianTray()
    Gtk.main()
'''


new='''def main():

    tray = ClipboardGuardianTray()


    def listener():

        if not RELOAD_SOCKET_PATH:
            return


        if os.path.exists(RELOAD_SOCKET_PATH):
            os.remove(RELOAD_SOCKET_PATH)


        server = socket.socket(
            socket.AF_UNIX,
            socket.SOCK_STREAM,
        )

        server.bind(
            RELOAD_SOCKET_PATH
        )

        server.listen(5)


        while True:

            conn, _ = server.accept()

            with conn:

                cmd = conn.recv(
                    1024
                ).decode()


                if cmd == "reload_config":

                    GLib.idle_add(
                        tray.reload_config
                    )


    threading.Thread(
        target=listener,
        daemon=True,
    ).start()


    Gtk.main()
'''


s=s.replace(old,new)


p.write_text(s)


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
echo " Tray reload sync added "
echo "===================================="
