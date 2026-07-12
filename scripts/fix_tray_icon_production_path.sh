#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Fix Tray Icon Production Path"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backup..."

cp src/tray/tray_process.py \
src/tray/tray_process.py.backup_icon_path


echo
echo "Updating tray process..."


python3 - <<'PY'

from pathlib import Path


p = Path("src/tray/tray_process.py")

s = p.read_text()


# add import

old = "from src.managers.config_manager import ConfigManager"

new = """from src.managers.config_manager import ConfigManager
from src.core.paths import ICON_PATH"""


if "from src.core.paths import ICON_PATH" not in s:
    s = s.replace(old, new)


start = s.index("def get_icon_path():")

end = s.index("\n\ndef send_command", start)


new_function = '''def get_icon_path():
    """
    Resolve tray icon location.

    Uses centralized production-safe path.
    """

    if ICON_PATH.exists():
        return str(ICON_PATH)

    return "clipboard-guardian"
'''


s = s[:start] + new_function + s[end:]


p.write_text(s)

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
echo " Tray icon path fixed"
echo "===================================="
