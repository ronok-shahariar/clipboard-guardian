#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Upgrade Debian Package Metadata"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backups..."

cp packaging/debian/control \
packaging/debian/control.backup

cp packaging/debian/postinst \
packaging/debian/postinst.backup

cp packaging/debian/prerm \
packaging/debian/prerm.backup


echo
echo "Updating control file..."


cat > packaging/debian/control <<'EOF'
Package: clipboard-guardian
Version: 2.0.0
Section: utils
Priority: optional
Architecture: all

Depends:
 python3,
 python3-gi,
 python3-gi-cairo,
 gir1.2-gtk-4.0,
 gir1.2-gtk-3.0,
 gir1.2-ayatanaappindicator3-0.1,
 libayatana-appindicator3-1,
 libnotify-bin,
 xclip,
 wl-clipboard

Maintainer: Ronok

Description: Clipboard Guardian
 A lightweight clipboard monitoring application
 with tray controls, notifications and clipboard history.
EOF


echo
echo "Updating postinst..."


cat > packaging/debian/postinst <<'EOF'
#!/bin/bash

set -e


echo "Configuring Clipboard Guardian..."


gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


update-desktop-database \
>/dev/null 2>&1 || true


chmod 755 /usr/bin/clipboard-guardian || true


exit 0
EOF


echo
echo "Updating prerm..."


cat > packaging/debian/prerm <<'EOF'
#!/bin/bash

set -e


pkill -x clipboard-guardian || true


rm -f /tmp/clipboard_guardian_tray_*.sock || true


exit 0
EOF


chmod 755 packaging/debian/*


echo
echo "Syntax check..."

bash -n packaging/debian/postinst
bash -n packaging/debian/prerm


echo
echo "===================================="
echo " Debian metadata upgraded"
echo "===================================="
