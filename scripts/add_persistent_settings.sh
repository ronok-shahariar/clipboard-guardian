#!/usr/bin/env bash

set -euo pipefail


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "===================================="
echo " Adding Persistent Settings Support "
echo "===================================="


#######################################
# Backup
#######################################

echo
echo "Creating backups..."

cp "$ROOT_DIR/src/managers/config_manager.py" \
"$ROOT_DIR/src/managers/config_manager.py.backup"

cp "$ROOT_DIR/src/services/tray_service.py" \
"$ROOT_DIR/src/services/tray_service.py.backup"


#######################################
# Patch ConfigManager
#######################################

echo
echo "Updating ConfigManager..."


python3 <<PY

from pathlib import Path


p = Path("$ROOT_DIR/src/managers/config_manager.py")

s = p.read_text()


s = s.replace(
'''    "theme": "system",
}''',
'''    "theme": "system",

    "defaults": {
        "monitoring": True,
        "notifications": True,
        "toast": True,
        "start_hidden": False,
    },
}'''
)


old = '''        self.data = json.loads(self.config_file.read_text())
'''


new = '''        try:
            self.data = json.loads(
                self.config_file.read_text()
            )

        except Exception:
            self.data = DEFAULT_CONFIG.copy()
            self.save()
'''


if old in s:
    s = s.replace(old,new)


if "def get_default" not in s:

    s += '''

    # ---------------------------------------------

    def get_default(self, key, default=None):

        return self.data.get(
            "defaults",
            {}
        ).get(
            key,
            default
        )


    # ---------------------------------------------

    def set_default(self, key, value):

        if "defaults" not in self.data:
            self.data["defaults"] = {}

        self.data["defaults"][key] = value

'''


p.write_text(s)

print("ConfigManager updated")

PY



#######################################
# Patch TrayService
#######################################

echo
echo "Updating TrayService..."


python3 <<PY

from pathlib import Path


p = Path("$ROOT_DIR/src/services/tray_service.py")

s = p.read_text()


old = '''    def initialize(self):
        if self.event_bus is not None:
            self.event_bus.monitoring_enabled = True
            self.event_bus.notify_enabled = True
            self.event_bus.toast_enabled = True
'''


new = '''    def initialize(self):

        from src.managers.config_manager import ConfigManager

        config = ConfigManager()
        config.load()

        if self.event_bus is not None:

            self.event_bus.monitoring_enabled = (
                config.get_default(
                    "monitoring",
                    True
                )
            )

            self.event_bus.notify_enabled = (
                config.get_default(
                    "notifications",
                    True
                )
            )

            self.event_bus.toast_enabled = (
                config.get_default(
                    "toast",
                    True
                )
            )
'''


if old not in s:
    raise SystemExit(
        "TrayService initialize block not found"
    )


s = s.replace(old,new)


p.write_text(s)


print("TrayService updated")

PY



#######################################
# Cleanup
#######################################

echo
echo "Cleaning python cache..."

find "$ROOT_DIR/src" \
-type d \
-name "__pycache__" \
-exec rm -rf {} +


find "$ROOT_DIR/src" \
-type f \
-name "*.pyc" \
-delete



#######################################
# Validation
#######################################

echo
echo "Syntax check..."

python3 -m compileall "$ROOT_DIR/src" -q


echo
echo "===================================="
echo " Persistent settings added "
echo "===================================="
