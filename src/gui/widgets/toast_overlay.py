
from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib


class ToastOverlay(Gtk.Box):

    def __init__(self):

        super().__init__(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8,
        )


        self.add_css_class(
            "clipboard-toast"
        )

        self.set_hexpand(False)
        self.set_vexpand(False)


        self.set_halign(
            Gtk.Align.END
        )

        self.set_valign(
            Gtk.Align.START
        )


        self.set_margin_top(25)
        self.set_margin_end(25)


        self.set_size_request(
            340,
            110
        )


        self.indicator = Gtk.Label(
            label="●"
        )

        self.indicator.add_css_class(
            "success-dot"
        )


        self.title = Gtk.Label(
            label="Clipboard Copied"
        )

        self.title.add_css_class(
            "toast-title"
        )


        self.message = Gtk.Label()

        self.message.set_wrap(True)

        self.message.add_css_class(
            "toast-text"
        )


        self.append(
            self.indicator
        )

        self.append(
            self.title
        )

        self.append(
            self.message
        )


        self.set_visible(False)



    def show_message(self, text):

        preview = " ".join(
            text.strip().split()
        )


        if len(preview) > 90:
            preview = preview[:90] + "..."


        self.message.set_text(
            preview
        )


        self.set_visible(True)


        GLib.timeout_add(
            3000,
            self.hide_toast
        )


    def hide_toast(self):

        self.set_visible(False)

        return False
