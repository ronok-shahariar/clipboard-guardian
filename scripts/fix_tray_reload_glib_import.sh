#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix Tray Reload GLib Import"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backup..."

cp src/tray/tray_process.py \
src/tray/tray_process.py.backup_glib_import


python3 - <<'PY'

from pathlib import Path

p = Path("src/tray/tray_process.py")

s = p.read_text()


if "from gi.repository import GLib" not in s:

    s = s.replace(
        "from gi.repository import Gtk\n",
        "from gi.repository import Gtk\nfrom gi.repository import GLib\n",
        1
    )


p.write_text(s)

print("GLib import added")

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
echo " GLib import fixed "
echo "===================================="
