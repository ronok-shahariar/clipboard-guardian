#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Remove GNOME Autostart"
echo "===================================="


FILE="scripts/build_deb.sh"


echo "Creating backup..."

cp "$FILE" "${FILE}.backup_remove_autostart"


python3 - <<'PY'

from pathlib import Path

path = Path("scripts/build_deb.sh")

text = path.read_text()


start = text.find("################################\n# Autostart")

end = text.find("################################\n# Systemd User Service")


if start != -1 and end != -1:

    text = (
        text[:start]
        +
        "################################\n"
        "# GNOME Autostart removed\n"
        "################################\n\n\n"
        +
        text[end:]
    )


path.write_text(text)

PY


echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo "Syntax check..."

bash -n scripts/build_deb.sh


echo
echo "===================================="
echo " GNOME autostart removed"
echo "===================================="
