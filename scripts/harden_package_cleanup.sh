#!/bin/bash

set -e

echo "Hardening Debian cleanup..."

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

pkill -f "clipboard-guardian" || true


rm -f /tmp/clipboard_guardian*.sock || true

rm -f /tmp/clipboard_guardian_tray.lock || true

rm -rf /tmp/clipboard_guardian* || true


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


exit 0
EOF


chmod 755 packaging/debian/prerm


echo "Cleanup hardened"
