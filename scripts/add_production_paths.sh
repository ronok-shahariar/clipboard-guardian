#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Add Production Path Manager"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating paths module..."


cat > src/core/paths.py <<'EOF'
"""
Clipboard Guardian
Application Paths
"""

from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[2]

ASSETS_DIR = APP_ROOT / "assets"

ICON_PATH = (
    ASSETS_DIR /
    "icons" /
    "clipboard-guardian-green.png"
)
EOF


echo
echo "Updating notification service..."


python3 - <<'PY'

from pathlib import Path


p=Path(
"src/services/notification_service.py"
)

s=p.read_text()


if "from src.core.paths import ICON_PATH" not in s:

    s=s.replace(
        "from src.events.clipboard_events import ClipboardChangedEvent",
        "from src.events.clipboard_events import ClipboardChangedEvent\nfrom src.core.paths import ICON_PATH"
    )


s=s.replace(
'str(Path("assets/icons/clipboard-guardian-green.png").resolve())',
'str(ICON_PATH)'
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
echo " Production paths added"
echo "===================================="
