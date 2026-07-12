#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Clipboard Guardian Settings v2 "
echo " Phase 1 Patch"
echo "===================================="


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"


echo
echo "Creating backups..."

cp src/managers/config_manager.py \
src/managers/config_manager.py.backup_settings_v2

cp src/gui/windows/settings_window.py \
src/gui/windows/settings_window.py.backup_settings_v2


########################################
# ConfigManager patch
########################################

echo
echo "Updating ConfigManager..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/managers/config_manager.py")

s = p.read_text()


if '"config_version": 1' not in s:

    s = s.replace(
        'DEFAULT_CONFIG = {',
        'DEFAULT_CONFIG = {\\n    "config_version": 1,',
        1
    )


old = '''        try:
            self.data = json.loads(
                self.config_file.read_text()
            )

        except Exception:
            self.data = DEFAULT_CONFIG.copy()
            self.save()
'''

new = '''        try:
            self.data = json.loads(
                self.config_file.read_text()
            )

            self.migrate()

        except Exception:
            self.data = DEFAULT_CONFIG.copy()
            self.save()
'''


if old in s:
    s = s.replace(old, new)


marker = '''

    # ---------------------------------------------

    def get(self, key, default=None):
'''


migration = '''

    # ---------------------------------------------

    def migrate(self):

        if "config_version" not in self.data:

            self.data["config_version"] = 1


        if "defaults" not in self.data:

            self.data["defaults"] = (
                DEFAULT_CONFIG["defaults"].copy()
            )


        self.save()


'''


if "def migrate(self)" not in s:
    s = s.replace(marker, migration + marker)


p.write_text(s)

print("ConfigManager updated")

PY



########################################
# Settings Window patch
########################################

echo
echo "Updating Settings Window..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/gui/windows/settings_window.py")

s = p.read_text()


old = '''        self.application = application

        self.set_default_size(
'''


new = '''        self.application = application

        self.event_bus = None

        if self.application:

            self.event_bus = (
                self.application.guardian.event_bus
            )

        self.set_default_size(
'''


if old in s:
    s=s.replace(old,new)


# add reset button

old = '''        save = Gtk.Button(
            label="Save Settings"
        )

        save.connect(
            "clicked",
            self.save_settings
        )
'''


new = '''        save = Gtk.Button(
            label="Save Settings"
        )

        save.connect(
            "clicked",
            self.save_settings
        )


        reset = Gtk.Button(
            label="Reset Defaults"
        )

        reset.connect(
            "clicked",
            self.reset_defaults
        )
'''


if old in s:
    s=s.replace(old,new)


old = '''        box.append(self.hidden_check)
        box.append(save)
'''


new = '''        box.append(self.hidden_check)
        box.append(save)
        box.append(reset)
'''


if old in s:
    s=s.replace(old,new)


old = '''        self.config.save()

        self.close()


'''


new = '''        self.config.save()


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


if old in s:
    s=s.replace(old,new)


p.write_text(s)

print("SettingsWindow updated")

PY



########################################
# Cleanup
########################################

echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -type f -name "*.pyc" -delete



########################################
# Syntax check
########################################

echo
echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " Settings v2 Phase 1 completed "
echo "===================================="
