#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Add Systemd User Service"
echo "===================================="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$ROOT_DIR/packaging/systemd"


echo
echo "Creating service file..."


cat > "$ROOT_DIR/packaging/systemd/clipboard-guardian.service" <<'EOF'
[Unit]
Description=Clipboard Guardian
After=graphical-session.target


[Service]
Type=simple

ExecStart=/usr/bin/clipboard-guardian --hidden

Restart=on-failure
RestartSec=3

Environment=GSK_RENDERER=cairo


[Install]
WantedBy=default.target
EOF


echo
echo "Creating backup..."

cp "$ROOT_DIR/packaging/debian/postinst" \
"$ROOT_DIR/packaging/debian/postinst.backup_systemd" 2>/dev/null || true

cp "$ROOT_DIR/packaging/debian/prerm" \
"$ROOT_DIR/packaging/debian/prerm.backup_systemd" 2>/dev/null || true


echo
echo "Updating postinst..."


cat >> "$ROOT_DIR/packaging/debian/postinst" <<'EOF'


# Enable Clipboard Guardian user service template
mkdir -p /usr/lib/systemd/user

cp /usr/share/clipboard-guardian/clipboard-guardian.service \
/usr/lib/systemd/user/clipboard-guardian.service \
2>/dev/null || true

systemctl --user daemon-reload 2>/dev/null || true

systemctl --user enable clipboard-guardian.service 2>/dev/null || true
EOF


echo
echo "Updating build script..."


python3 - "$ROOT_DIR/scripts/build_deb.sh" <<'PY'

from pathlib import Path
import sys

p = Path(sys.argv[1])

text = p.read_text()


needle = '''"$BUILD_DIR/usr/share/applications" \\
"$BUILD_DIR/etc/xdg/autostart" \\
"$BUILD_DIR/usr/share/icons/hicolor/128x128/apps"
'''


replace = '''"$BUILD_DIR/usr/share/applications" \\
"$BUILD_DIR/etc/xdg/autostart" \\
"$BUILD_DIR/usr/lib/systemd/user" \\
"$BUILD_DIR/usr/share/icons/hicolor/128x128/apps"
'''


if "usr/lib/systemd/user" not in text:
    text=text.replace(
        needle,
        replace
    )


insert='''

################################
# Systemd User Service
################################

cp "$ROOT_DIR/packaging/systemd/clipboard-guardian.service" \\
"$BUILD_DIR/usr/share/clipboard-guardian/clipboard-guardian.service"

cp "$ROOT_DIR/packaging/systemd/clipboard-guardian.service" \\
"$BUILD_DIR/usr/lib/systemd/user/clipboard-guardian.service"

'''


if "# Systemd User Service" not in text:
    text=text.replace(
        "################################\n# Debian control",
        insert+"################################\n# Debian control"
    )


p.write_text(text)

PY


echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Syntax check..."

bash -n "$ROOT_DIR/scripts/build_deb.sh"


echo
echo "===================================="
echo " Systemd service added"
echo "===================================="
