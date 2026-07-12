#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Finalize Debian Lifecycle"
echo "===================================="


echo "Creating backups..."

cp packaging/debian/postinst \
packaging/debian/postinst.backup_final

cp packaging/debian/prerm \
packaging/debian/prerm.backup_final


cat > packaging/debian/postinst <<'EOF'
#!/bin/bash

set -e


echo "Configuring Clipboard Guardian..."


gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


update-desktop-database \
>/dev/null 2>&1 || true


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


systemctl --user enable clipboard-guardian.service \
>/dev/null 2>&1 || true


chmod 755 /usr/bin/clipboard-guardian || true


exit 0
EOF



cat > packaging/debian/prerm <<'EOF'
#!/bin/bash

set -e


echo "Stopping Clipboard Guardian..."


systemctl --user stop clipboard-guardian.service \
>/dev/null 2>&1 || true


systemctl --user disable clipboard-guardian.service \
>/dev/null 2>&1 || true


pkill -f "src.main" || true

pkill -f "src.tray.tray_process" || true


rm -f /tmp/clipboard_guardian*.sock || true

rm -f /tmp/clipboard_guardian_tray.lock || true


exit 0
EOF



chmod 755 packaging/debian/postinst
chmod 755 packaging/debian/prerm


echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "===================================="
echo " Debian lifecycle finalized"
echo "===================================="
