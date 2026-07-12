#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Persist Tray Toggle Settings "
echo "===================================="


FILE="src/services/tray_service.py"


if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE not found"
    exit 1
fi


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_persist_toggle"



echo
echo "Patching TrayService..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/services/tray_service.py")

s = p.read_text()


# Add ConfigManager import

old = '''from gi.repository import GLib
'''


new = '''from gi.repository import GLib

from src.managers.config_manager import ConfigManager
'''


if "from src.managers.config_manager import ConfigManager" not in s:

    if old not in s:
        raise SystemExit("Import location not found")

    s = s.replace(old,new)



# Add config object

old = '''        self.event_bus = event_bus
        self.application = None
'''


new = '''        self.event_bus = event_bus

        self.config = ConfigManager()
        self.config.load()

        self.application = None
'''


if "self.config = ConfigManager()" not in s:

    if old not in s:
        raise SystemExit("Init location not found")

    s=s.replace(old,new)



# Replace toggle handlers

replacements = {

'''                self.event_bus.monitoring_enabled = True''':
'''                self.event_bus.monitoring_enabled = True
                self.config.set_default("monitoring", True)
                self.config.save()''',

'''                self.event_bus.monitoring_enabled = False''':
'''                self.event_bus.monitoring_enabled = False
                self.config.set_default("monitoring", False)
                self.config.save()''',

'''                self.event_bus.notify_enabled = True''':
'''                self.event_bus.notify_enabled = True
                self.config.set_default("notifications", True)
                self.config.save()''',

'''                self.event_bus.notify_enabled = False''':
'''                self.event_bus.notify_enabled = False
                self.config.set_default("notifications", False)
                self.config.save()''',

'''                self.event_bus.toast_enabled = True''':
'''                self.event_bus.toast_enabled = True
                self.config.set_default("toast", True)
                self.config.save()''',

'''                self.event_bus.toast_enabled = False''':
'''                self.event_bus.toast_enabled = False
                self.config.set_default("toast", False)
                self.config.save()''',

}


for old,new in replacements.items():

    if old in s:
        s=s.replace(old,new)
    else:
        print("Warning: pattern missing:", old)



p.write_text(s)

print("TrayService updated")

PY



echo
echo "Cleaning python cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete



echo
echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " Tray persistence added "
echo "===================================="
