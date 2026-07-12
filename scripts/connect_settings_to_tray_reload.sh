#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Connect Settings To Tray Reload"
echo "===================================="


echo
echo "Creating backup..."

cp src/gui/windows/settings_window.py \
src/gui/windows/settings_window.py.backup_tray_reload


python3 - <<'PY'

from pathlib import Path

p = Path(
    "src/gui/windows/settings_window.py"
)

s = p.read_text()


old = '''            self.event_bus.toast_enabled = (
                self.toast_check.get_active()
            )


        self.close()
'''


new = '''            self.event_bus.toast_enabled = (
                self.toast_check.get_active()
            )


        # Refresh tray indicator immediately

        if self.application:

            tray = (
                self.application
                .guardian
                .service_manager
                .get("TrayService")
            )

            if tray:

                tray.handle_command(
                    "reload_tray"
                )


        self.close()
'''


if old not in s:
    raise SystemExit(
        "Save block not found"
    )


s = s.replace(
    old,
    new
)


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
echo " Settings tray reload connected "
echo "===================================="
