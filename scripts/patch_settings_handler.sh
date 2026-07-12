#!/usr/bin/env bash

set -euo pipefail


echo "Adding settings command handler..."


FILE="src/services/tray_service.py"


cp "$FILE" "$FILE.backup_settings_handler"


python3 - <<'PY'

from pathlib import Path

p = Path("src/services/tray_service.py")

s = p.read_text()


old = '''        elif command == "clear_history":
            if self.window and hasattr(self.window, "clear_history"):
                self.window.clear_history()

        elif command == "quit":
'''


new = '''        elif command == "clear_history":
            if self.window and hasattr(self.window, "clear_history"):
                self.window.clear_history()


        elif command == "open_settings":

            from src.gui.windows.settings_window import SettingsWindow

            if self.application:

                settings = SettingsWindow(
                    self.application,
                )

                settings.present()


        elif command == "quit":
'''


if old not in s:
    raise SystemExit("Handler insertion point not found")


s=s.replace(old,new)

p.write_text(s)

print("tray_service.py updated")

PY
