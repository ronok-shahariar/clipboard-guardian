#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Cleanup Tray Config Manager Usage "
echo "===================================="


FILE="src/services/tray_service.py"


echo
echo "Creating backup..."

cp "$FILE" "$FILE.backup_cleanup_config"



python3 - <<'PY'

from pathlib import Path

p = Path("src/services/tray_service.py")

s = p.read_text()


old = """
    def initialize(self):

        config = ConfigManager()
        config.load()

        if self.event_bus is not None:

            self.event_bus.monitoring_enabled = (
                config.get_default(
                    \"monitoring\",
                    True
                )
            )

            self.event_bus.notify_enabled = (
                config.get_default(
                    \"notifications\",
                    True
                )
            )

            self.event_bus.toast_enabled = (
                config.get_default(
                    \"toast\",
                    True
                )
            )
"""


new = """
    def initialize(self):

        if self.event_bus is not None:

            self.event_bus.monitoring_enabled = (
                self.config.get_default(
                    \"monitoring\",
                    True
                )
            )

            self.event_bus.notify_enabled = (
                self.config.get_default(
                    \"notifications\",
                    True
                )
            )

            self.event_bus.toast_enabled = (
                self.config.get_default(
                    \"toast\",
                    True
                )
            )
"""


if old not in s:
    raise SystemExit(
        "initialize config block not found"
    )


s = s.replace(old,new)


p.write_text(s)

print("TrayService cleaned")

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
echo " Tray Config Cleanup Complete "
echo "===================================="
