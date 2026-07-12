#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Fix Systemd GUI Environment"
echo "===================================="


cat > packaging/systemd/clipboard-guardian.service <<'EOF'
[Unit]
Description=Clipboard Guardian
After=graphical-session.target
Wants=graphical-session.target


[Service]
Type=simple

ExecStart=/usr/bin/clipboard-guardian --hidden

Restart=on-failure
RestartSec=3

Environment=GSK_RENDERER=cairo
Environment=DISPLAY=:0
Environment=XDG_CURRENT_DESKTOP=ubuntu:GNOME
Environment=WAYLAND_DISPLAY=wayland-0


[Install]
WantedBy=default.target
EOF


echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Checking service..."

systemd-analyze verify packaging/systemd/clipboard-guardian.service


echo
echo "===================================="
echo " Systemd GUI environment fixed"
echo "===================================="
