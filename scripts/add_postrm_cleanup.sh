#!/bin/bash

set -e

echo "Adding Debian postrm cleanup..."


cat > packaging/debian/postrm <<'EOF'
#!/bin/bash

set -e

echo "Cleaning Clipboard Guardian leftovers..."


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


rm -f /tmp/clipboard_guardian*.sock || true

rm -f /tmp/clipboard_guardian_tray.lock || true

rm -rf /tmp/clipboard_guardian* || true


rm -rf /usr/share/clipboard-guardian || true


update-desktop-database \
>/dev/null 2>&1 || true


gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


exit 0
EOF


chmod 755 packaging/debian/postrm


echo "postrm added"
