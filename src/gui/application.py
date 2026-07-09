"""
Guardian GTK Application
"""

from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk

from src.core.application import GuardianApplication
from src.gui.css import load_css
from src.gui.windows.main_window import MainWindow


class GuardianGtkApplication(Gtk.Application):

    def __init__(self, start_hidden: bool = False):

        super().__init__(
            application_id="com.clipboardguardian.app",
        )

        self.hold()
        self.start_hidden = start_hidden
        self.guardian = GuardianApplication()
        self.main_window = None

    def do_activate(self):

        load_css()

        self.guardian.start()

        for service in self.guardian.service_manager.services:
            if hasattr(service, "set_application"):
                service.set_application(self)

        if self.main_window is None:
            self.main_window = MainWindow(
                self,
                self.guardian.history,
                self.guardian.backend,
                self.guardian.event_bus,
            )

        for service in self.guardian.service_manager.services:

            if hasattr(service, "set_overlay"):
                service.set_overlay(
                    self.main_window.toast
                )

            if hasattr(service, "set_window"):
                service.set_window(
                    self.main_window
                )


        if self.start_hidden:
            self.main_window.hide()
        else:
            self.main_window.present()

    def do_shutdown(self):

        self.guardian.stop()

        Gtk.Application.do_shutdown(self)
