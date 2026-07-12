#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix Tray Config Import Position "
echo "===================================="


FILE="src/services/tray_service.py"


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_import_position"



python3 - <<'PY'

from pathlib import Path

p = Path("src/services/tray_service.py")

s = p.read_text()


# Remove wrongly placed local import

s = s.replace(
'''
        from src.managers.config_manager import ConfigManager

        config = ConfigManager()
''',
'''
        config = ConfigManager()
'''
)


# Add top-level import

if "from src.managers.config_manager import ConfigManager" not in s.split("class TrayService")[0]:

    marker = "from gi.repository import GLib\n"

    if marker not in s:
        raise SystemExit("GLib import marker not found")

    s = s.replace(
        marker,
        marker + "\nfrom src.managers.config_manager import ConfigManager\n"
    )


p.write_text(s)

print("Import position fixed")

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
echo " Tray Config Import Fixed "
echo "===================================="
