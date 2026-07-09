from __future__ import annotations

import sys
import warnings
import gi

warnings.filterwarnings("ignore", category=DeprecationWarning)

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib, Gdk


class ModernToast(Gtk.Window):
    def __init__(self, text: str):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        self.set_title("Clipboard Guardian")
        self.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION)
        self.set_default_size(390, 96)
        self.set_size_request(390, 96)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_accept_focus(False)
        self.set_focus_on_map(False)

        css = b"""
        #toast_card {
            background: #0f172a;
            border: 1px solid #334155;
            border-radius: 22px;
        }

        #icon_circle {
            background: #22c55e;
            color: #ffffff;
            border-radius: 999px;
            font-weight: bold;
            font-size: 17px;
            min-width: 38px;
            min-height: 38px;
        }

        #toast_title {
            color: #ffffff;
            font-weight: bold;
            font-size: 15px;
        }

        #toast_app {
            color: #4ade80;
            font-size: 11px;
            font-weight: bold;
        }

        #toast_preview {
            color: #cbd5e1;
            font-family: Monospace;
            font-size: 12px;
        }
        """

        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        card = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        card.set_name("toast_card")
        card.set_border_width(12)
        self.add(card)

        icon = Gtk.Label(label="✓")
        icon.set_name("icon_circle")
        icon.set_size_request(38, 38)
        card.pack_start(icon, False, False, 0)

        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        card.pack_start(content, True, True, 0)

        title = Gtk.Label(label="Clipboard Copied")
        title.set_name("toast_title")
        title.set_xalign(0)
        content.pack_start(title, False, False, 0)

        app = Gtk.Label(label="Clipboard Guardian")
        app.set_name("toast_app")
        app.set_xalign(0)
        content.pack_start(app, False, False, 0)

        preview = Gtk.Label(label=self.make_preview(text))
        preview.set_name("toast_preview")
        preview.set_xalign(0)
        preview.set_line_wrap(False)
        preview.set_ellipsize(3)
        preview.set_max_width_chars(42)
        content.pack_start(preview, False, False, 0)

        self.position_top_right()
        self.show_all()
        self.position_top_right()

        GLib.timeout_add(2800, self.close_toast)

    def make_preview(self, text: str) -> str:
        text = " ".join(text.strip().split())
        if not text:
            return "[Empty text]"
        if len(text) > 70:
            return text[:70] + "..."
        return text

    def position_top_right(self):
        try:
            screen = Gdk.Screen.get_default()
            monitor = screen.get_primary_monitor()
            geometry = screen.get_monitor_workarea(monitor)

            width = 390
            x = geometry.x + geometry.width - width - 22
            y = geometry.y + 55

            self.move(x, y)
        except Exception:
            pass

    def close_toast(self):
        Gtk.main_quit()
        return False


def main():
    text = sys.stdin.read()
    ModernToast(text)
    Gtk.main()


if __name__ == "__main__":
    main()
