from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, Gdk


APP_CSS = """
.clipboard-toast {
    background: #111827;
    border: 1px solid #334155;
    border-radius: 18px;
    padding: 12px;
}

.success-dot {
    color: #22c55e;
    font-size: 22px;
}

.toast-title {
    color: #ffffff;
    font-weight: bold;
    font-size: 15px;
}

.toast-text {
    color: #cbd5e1;
    font-size: 12px;
}

.main-card {
    background: #ffffff;
    border: 1px solid #d1d5db;
    border-radius: 12px;
    padding: 8px;
    transition: 300ms ease-in-out;
}

.main-card.copy-flash {
    background: #dcfce7;
    border: 2px solid #22c55e;
}

.clipboard-text-view {
    background: #ffffff;
    transition: 300ms ease-in-out;
}

.clipboard-text-view.text-flash {
    background: #bbf7d0;
}
"""


def load_css():
    provider = Gtk.CssProvider()
    provider.load_from_data(APP_CSS.encode("utf-8"))

    display = Gdk.Display.get_default()

    if display is None:
        return

    Gtk.StyleContext.add_provider_for_display(
        display,
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )
