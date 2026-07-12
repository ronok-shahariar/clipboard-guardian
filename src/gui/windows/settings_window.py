from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk

from src.managers.config_manager import ConfigManager


class SettingsWindow(Gtk.Window):

    def __init__(self, application=None):

        super().__init__(
            title="Clipboard Guardian Settings"
        )

        self.application = application

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
