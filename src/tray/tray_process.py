from __future__ import annotations

import os
import socket
import threading
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from gi.repository import GLib

from src.managers.config_manager import ConfigManager

APPINDICATOR_AVAILABLE = False
AppIndicator3 = None

try:
    gi.require_version("AyatanaAppIndicator3", "0.1")
    from gi.repository import AyatanaAppIndicator3 as AppIndicator3
    APPINDICATOR_AVAILABLE = True
except Exception:
    try:
        gi.require_version("AppIndicator3", "0.1")
        from gi.repository import AppIndicator3
        APPINDICATOR_AVAILABLE = True
    except Exception:
        APPINDICATOR_AVAILABLE = False


SOCKET_PATH = os.environ.get(
    "CLIPBOARD_GUARDIAN_TRAY_SOCKET"
)

RELOAD_SOCKET_PATH = os.environ.get(
    "CLIPBOARD_GUARDIAN_RELOAD_SOCKET"
)


def get_icon_path():
    """
    Resolve tray icon location.

    Development:
        use project assets.

    Production:
        fallback to installed icon theme.
    """

    project_root = os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            "../../"
        )
    )

    dev_icon = os.path.join(
        project_root,
        "assets",
        "icons",
        "clipboard-guardian-green.png",
    )

    if os.path.exists(dev_icon):
        return dev_icon

    return "clipboard-guardian"


def send_command(command: str):
    if not SOCKET_PATH:
        return

    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.connect(SOCKET_PATH)
            client.sendall(command.encode("utf-8"))
    except Exception:
        pass


class ClipboardGuardianTray:
    def __init__(self):
        if not APPINDICATOR_AVAILABLE:
            raise SystemExit(1)

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

        self.indicator = AppIndicator3.Indicator.new(
            "clipboard-guardian",
            get_icon_path(),
            AppIndicator3.IndicatorCategory.APPLICATION_STATUS,
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

        self.menu = Gtk.Menu()

        self.show_hide_item = Gtk.MenuItem(label="Show Window")
        self.show_hide_item.connect("activate", self.toggle_window)
        self.menu.append(self.show_hide_item)

        self.monitor_item = Gtk.MenuItem(
            label=f"Monitoring: {'ON' if self.monitoring else 'OFF'}"
        )
        self.monitor_item.connect("activate", self.toggle_monitoring)
        self.menu.append(self.monitor_item)

        self.notify_item = Gtk.MenuItem(
            label=f"Notify Me: {'ON' if self.notify_me else 'OFF'}"
        )
        self.notify_item.connect("activate", self.toggle_notify_me)
        self.menu.append(self.notify_item)

        self.toast_item = Gtk.MenuItem(
            label=f"Toast: {'ON' if self.toast else 'OFF'}"
        )
        self.toast_item.connect("activate", self.toggle_toast)
        self.menu.append(self.toast_item)

        settings_item = Gtk.MenuItem(label="Settings")
        settings_item.connect(
            "activate",
            lambda *_: send_command("open_settings")
        )
        self.menu.append(settings_item)

        refresh_item = Gtk.MenuItem(label="Refresh Window")
        refresh_item.connect("activate", lambda *_: send_command("refresh"))
        self.menu.append(refresh_item)

        clear_item = Gtk.MenuItem(label="Clear History")
        clear_item.connect("activate", lambda *_: send_command("clear_history"))
        self.menu.append(clear_item)

        self.menu.append(Gtk.SeparatorMenuItem())

        quit_item = Gtk.MenuItem(label="Quit")
        quit_item.connect("activate", self.quit_app)
        self.menu.append(quit_item)

        self.menu.show_all()
        self.indicator.set_menu(self.menu)

    def toggle_window(self, *_args):
        self.window_visible = not self.window_visible

        if self.window_visible:
            self.show_hide_item.set_label("Hide Window")
            send_command("show_window")
        else:
            self.show_hide_item.set_label("Show Window")
            send_command("hide_window")

    def toggle_monitoring(self, *_args):
        self.monitoring = not self.monitoring

        if self.monitoring:
            self.monitor_item.set_label("Monitoring: ON")
            send_command("monitoring_on")
        else:
            self.monitor_item.set_label("Monitoring: OFF")
            send_command("monitoring_off")

    def toggle_notify_me(self, *_args):
        self.notify_me = not self.notify_me

        if self.notify_me:
            self.notify_item.set_label("Notify Me: ON")
            send_command("notify_on")
        else:
            self.notify_item.set_label("Notify Me: OFF")
            send_command("notify_off")

    def toggle_toast(self, *_args):
        self.toast = not self.toast

        if self.toast:
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


    def quit_app(self, *_args):
        send_command("quit")
        Gtk.main_quit()


def main():

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


if __name__ == "__main__":
    main()
