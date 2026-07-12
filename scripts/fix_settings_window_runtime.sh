#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Fix Settings Runtime Apply "
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backup..."

cp src/gui/windows/settings_window.py \
src/gui/windows/settings_window.py.backup_runtime_apply



python3 - <<'PY'

from pathlib import Path

p = Path("src/gui/windows/settings_window.py")

s = p.read_text()


old = '''        self.config.save()

        self.close()
'''


new = '''        self.config.save()


        # Apply immediately without restart

        if self.event_bus:

            self.event_bus.monitoring_enabled = (
                self.monitor_check.get_active()
            )

            self.event_bus.notify_enabled = (
                self.notify_check.get_active()
            )

            self.event_bus.toast_enabled = (
                self.toast_check.get_active()
            )


        self.close()



    def reset_defaults(self, *_):

        self.monitor_check.set_active(True)

        self.notify_check.set_active(True)

        self.toast_check.set_active(True)

        self.hidden_check.set_active(False)


        self.save_settings()
'''


if old not in s:
    raise SystemExit(
        "Save block not found"
    )


s = s.replace(old, new, 1)


p.write_text(s)

print("Settings runtime apply added")

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
echo " Settings runtime fix completed "
echo "===================================="
