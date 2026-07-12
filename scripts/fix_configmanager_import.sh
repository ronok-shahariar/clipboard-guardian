#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix ConfigManager Import "
echo "===================================="


FILE="src/services/tray_service.py"


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_fix_import"



echo
echo "Adding missing import..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/services/tray_service.py")

s = p.read_text()


if "from src.managers.config_manager import ConfigManager" in s:
    print("Import already exists")

else:

    marker = "from gi.repository import GLib"

    if marker in s:

        s = s.replace(
            marker,
            marker + "\n\nfrom src.managers.config_manager import ConfigManager"
        )

    else:

        # fallback: add after imports
        lines = s.splitlines()

        index = 0

        for i,line in enumerate(lines):
            if line.startswith("import ") or line.startswith("from "):
                index = i + 1

        lines.insert(
            index,
            "from src.managers.config_manager import ConfigManager"
        )

        s="\n".join(lines)+"\n"


    p.write_text(s)

    print("Import added")

PY



echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete



echo
echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " ConfigManager import fixed "
echo "===================================="
