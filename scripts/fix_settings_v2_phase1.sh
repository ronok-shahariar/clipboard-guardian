#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Fix Settings v2 Phase 1 "
echo "===================================="

cd "$(dirname "$0")/.."


echo
echo "Updating ConfigManager..."


python3 - <<'PY'

from pathlib import Path

p = Path("src/managers/config_manager.py")

s = p.read_text()


if '"config_version": 1,' not in s:

    s = s.replace(
        'DEFAULT_CONFIG = {',
        'DEFAULT_CONFIG = {\n    "config_version": 1,',
        1
    )


old = """        try:
            self.data = json.loads(
                self.config_file.read_text()
            )

        except Exception:
            self.data = DEFAULT_CONFIG.copy()
            self.save()
"""


new = """        try:
            self.data = json.loads(
                self.config_file.read_text()
            )

            self.migrate()

        except Exception:
            self.data = DEFAULT_CONFIG.copy()
            self.save()
"""


if old in s:
    s = s.replace(old,new)


if "def migrate(self)" not in s:

    insert = """

    # ---------------------------------------------

    def migrate(self):

        if "config_version" not in self.data:

            self.data["config_version"] = 1


        if "defaults" not in self.data:

            self.data["defaults"] = (
                DEFAULT_CONFIG["defaults"].copy()
            )


        self.save()

"""

    marker = """
    # ---------------------------------------------

    def get(self, key, default=None):
"""

    s = s.replace(marker, insert + marker)


p.write_text(s)

print("ConfigManager fixed")

PY


echo
echo "Checking syntax..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete

python3 -m compileall src -q


echo
echo "===================================="
echo " Settings v2 repaired "
echo "===================================="
