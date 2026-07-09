from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib


class FloatingToast(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)

        self.set_title("Clipboard Guardian Toast")
        self.set_default_size(420, 120)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_modal(False)
        self.set_hide_on_close(True)

        self.add_css_class("clipboard-toast")

        box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=14,
        )
        box.set_margin_top(18)
        box.set_margin_bottom(18)
        box.set_margin_start(22)
        box.set_margin_end(22)

        self.indicator = Gtk.Label(label="●")
        self.indicator.add_css_class("success-dot")

        content = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=6,
        )

        self.title = Gtk.Label(label="Clipboard Copied")
        self.title.add_css_class("toast-title")
        self.title.set_halign(Gtk.Align.START)

        self.message = Gtk.Label()
        self.message.set_wrap(True)
        self.message.add_css_class("toast-text")
        self.message.set_halign(Gtk.Align.START)

        content.append(self.title)
        content.append(self.message)

        box.append(self.indicator)
        box.append(content)

        self.set_child(box)

    def show_message(self, text):
        preview = " ".join(text.strip().split())
        if len(preview) > 90:
            preview = preview[:90] + "..."

        self.message.set_text(preview)

        self.present()

        GLib.timeout_add(3000, self.hide_toast)

    def hide_toast(self):
        self.hide()
        return False
