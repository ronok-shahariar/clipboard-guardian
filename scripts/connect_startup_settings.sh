#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Connect Startup Settings Support "
echo "===================================="


MAIN="src/main.py"
CONFIG="src/managers/config_manager.py"
DESKTOP="scripts/build_deb.sh"


echo
echo "Creating backups..."

cp "$MAIN" "$MAIN.backup_startup_settings"
cp "$CONFIG" "$CONFIG.backup_startup_settings"
cp "$DESKTOP" "$DESKTOP.backup_startup_settings"



####################################
# Update ConfigManager
####################################

echo
echo "Updating ConfigManager..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/managers/config_manager.py")

s = p.read_text()


insert = '''

    def get_start_hidden(self):

        return self.get_default(
            "start_hidden",
            False
        )

'''


if "def get_start_hidden" not in s:

    marker = "\n    def set_default"

    if marker not in s:
        raise SystemExit(
            "set_default method not found"
        )

    s = s.replace(
        marker,
        insert + marker
    )


p.write_text(s)

print("ConfigManager updated")

PY



####################################
# Update main.py
####################################

echo
echo "Updating application startup..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/main.py")

s = p.read_text()


old = '''from src.gui.application import GuardianGtkApplication


def main():
    start_hidden = "--hidden" in sys.argv

    app = GuardianGtkApplication(
        start_hidden=start_hidden,
    )

    app.run([])


if __name__ == "__main__":
    main()
'''


new = '''import sys

from src.gui.application import GuardianGtkApplication
from src.managers.config_manager import ConfigManager


def main():

    config = ConfigManager()
    config.load()


    # Command line has priority
    if "--hidden" in sys.argv:
        start_hidden = True

    else:
        start_hidden = config.get_start_hidden()


    app = GuardianGtkApplication(
        start_hidden=start_hidden,
    )

    app.run([])


if __name__ == "__main__":
    main()
'''


if old not in s:
    raise SystemExit(
        "main.py pattern not found"
    )


s=s.replace(old,new)

p.write_text(s)

print("main.py updated")

PY



####################################
# Update autostart generation
####################################

echo
echo "Updating autostart desktop generation..."


python3 - <<'PY'

from pathlib import Path

p = Path("scripts/build_deb.sh")

s = p.read_text()


s=s.replace(
"Exec=${APP_ID} --hidden",
"Exec=${APP_ID}"
)


p.write_text(s)

print("Autostart updated")

PY



####################################
# Cleanup
####################################

echo
echo "Cleaning python cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete



####################################
# Syntax check
####################################

echo
echo "Syntax check..."

python3 -m compileall src -q



echo
echo "===================================="
echo " Startup settings connected "
echo "===================================="
