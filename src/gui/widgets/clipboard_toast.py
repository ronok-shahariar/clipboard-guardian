from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib


class ClipboardToast(Gtk.Window):

    def __init__(self, app, text):

        super().__init__(
            application=app
        )

        self.set_title("Clipboard Guardian")

        self.set_default_size(
            380,
            120,
        )

        self.set_modal(False)

        self.set_resizable(False)

        self.set_decorated(False)

        self.set_resizable(False)

        self.set_default_size(
            420,
            140,
        )

        self.add_css_class("clipboard-toast")


        box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=15,
        )


        box.set_margin_top(20)
        box.set_margin_bottom(20)
        box.set_margin_start(22)
        box.set_margin_end(22)


        indicator = Gtk.Label(
            label="●"
        )

        indicator.add_css_class(
            "success-dot"
        )


        content = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=5,
        )


        title = Gtk.Label(
            label="Clipboard Copied"
        )

        title.add_css_class(
            "toast-title"
        )


        preview = Gtk.Label(
            label=text[:90]
        )

        preview.set_wrap(True)

        preview.add_css_class(
            "toast-text"
        )


        content.append(title)
        content.append(preview)


        box.append(indicator)
        box.append(content)


        self.set_child(box)


        self.present()

        self.move_to_corner()

        print("[DEBUG] Toast positioned")


        GLib.timeout_add(
            3500,
            self.close
        )






    def move_to_corner(self):

        try:

            display = self.get_display()

            print(
                "[DEBUG] Display:",
                type(display).__name__
            )

            surface = self.get_surface()

            if surface:

                print(
                    "[DEBUG] Surface available"
                )

            # GTK4 Wayland does not allow manual window movement.
            # Use compositor placement instead.

            self.set_default_size(
                380,
                120,
            )

            print(
                "[DEBUG] Wayland compatible toast"
            )

        except Exception as e:

            print(
                "[DEBUG] Toast placement error:",
                e
            )



    def close_toast(self):

        self.hide()

        return False

