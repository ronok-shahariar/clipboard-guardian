#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "===================================="
echo " Clipboard Guardian Fresh Reset"
echo "===================================="


echo
echo "Stopping running processes..."

pkill -f "clipboard-guardian" || true
pkill -f "clipboard-checker" || true
pkill -f "src.main" || true
pkill -f "src.tray.tray_process" || true


echo
echo "Removing installed package..."

if dpkg -l | grep -q "^ii.*clipboard-guardian"
then
    sudo apt remove --purge -y clipboard-guardian
else
    echo "Package not installed"
fi


echo
echo "Removing leftover system files..."

sudo rm -rf /usr/share/clipboard-guardian

sudo rm -f \
/usr/bin/clipboard-guardian \
/usr/share/applications/clipboard-guardian.desktop \
/etc/xdg/autostart/clipboard-guardian.desktop


echo
echo "Removing user desktop entries..."

rm -f \
~/.local/share/applications/clipboard-guardian.desktop


echo
echo "Refreshing icon database..."

sudo gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


echo
echo "Cleaning project cache..."

find "$ROOT_DIR/src" \
-type d \
-name "__pycache__" \
-exec rm -rf {} +

find "$ROOT_DIR/src" \
-type f \
-name "*.pyc" \
-delete


echo
echo "Cleaning build artifacts..."

rm -rf \
"$ROOT_DIR/build" \
"$ROOT_DIR/dist"


echo
echo "Verification..."

echo "--- packages ---"
dpkg -l | grep -Ei "clipboard|guardian" || echo "OK"


echo
echo "--- processes ---"
ps aux | grep -Ei \
"clipboard|guardian|src.main|tray_process" \
| grep -v grep || echo "OK"


echo
echo "--- system files ---"

if [ -e /usr/share/clipboard-guardian ]
then
    echo "FOUND: /usr/share/clipboard-guardian"
else
    echo "OK"
fi


echo
echo "--- desktop files ---"

find \
~/.local/share/applications \
/usr/share/applications \
/etc/xdg/autostart \
-type f \
2>/dev/null \
| grep -Ei "clipboard|guardian" || echo "OK"


echo
echo "===================================="
echo " Fresh reset completed"
echo "===================================="
