#!/usr/bin/env bash

set -e

echo "===================================="
echo " Fix GTK Systemd Startup"
echo "===================================="

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Creating backups..."

cp "$ROOT/src/gui/css.py" \
"$ROOT/src/gui/css.py.backup_display_fix"

cp "$ROOT/src/gui/application.py" \
"$ROOT/src/gui/application.py.backup_display_fix"


python3 - <<'PY'
from pathlib import Path


css = Path("src/gui/css.py")

text = css.read_text()

old = """    display = Gdk.Display.get_default()

    Gtk.StyleContext.add_provider_for_display(
        display,
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )
"""

new = """    display = Gdk.Display.get_default()

    if display is None:
        return

    Gtk.StyleContext.add_provider_for_display(
        display,
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )
"""

if old in text:
    text=text.replace(old,new)

css.write_text(text)



app = Path("src/gui/application.py")

text=app.read_text()

text=text.replace(
"from gi.repository import Gtk",
"from gi.repository import Gtk, GLib"
)


text=text.replace(
"""    def do_activate(self):

        load_css()

        self.guardian.start()
""",
"""    def do_activate(self):

        GLib.idle_add(
            self.initialize_app
        )


    def initialize_app(self):

        load_css()

        self.guardian.start()
"""
)


text=text.replace(
"""        if self.start_hidden:
            self.main_window.hide()
        else:
            self.main_window.present()
""",
"""        if self.start_hidden:
            self.main_window.hide()
        else:
            self.main_window.present()

        return False
"""
)


app.write_text(text)

PY


find src -type d -name "__pycache__" -exec rm -rf {} +

python3 -m compileall src -q


echo
echo "===================================="
echo " GTK startup fix completed"
echo "===================================="
