#!/usr/bin/env bash

set -e

echo "===================================="
echo " Fix Safe Debian prerm"
echo "===================================="

cp packaging/debian/prerm \
packaging/debian/prerm.backup_final


cat > packaging/debian/prerm <<'EOF'
#!/bin/bash

set -e

echo "Stopping Clipboard Guardian..."


systemctl --user stop clipboard-guardian.service \
>/dev/null 2>&1 || true


systemctl --user disable clipboard-guardian.service \
>/dev/null 2>&1 || true


# Kill only application processes, never apt/dpkg
pkill -u "$USER" -f "/usr/share/clipboard-guardian/src/tray/tray_process" \
>/dev/null 2>&1 || true


pkill -u "$USER" -f "/usr/share/clipboard-guardian/src/main.py" \
>/dev/null 2>&1 || true


rm -f /tmp/clipboard_guardian*.sock || true
rm -f /tmp/clipboard_guardian_tray.lock || true
rm -rf /tmp/clipboard_guardian* || true


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


exit 0
EOF


chmod 755 packaging/debian/prerm


echo "Safe prerm fixed"
