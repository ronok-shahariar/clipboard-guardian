#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Fix Debian Control Format"
echo "===================================="


cd "$(dirname "$0")/.."


echo
echo "Creating backup..."

cp packaging/debian/control \
packaging/debian/control.invalid_format.backup


echo
echo "Writing valid Debian control file..."


cat > packaging/debian/control <<'EOF'
Package: clipboard-guardian
Version: 2.0.0
Section: utils
Priority: optional
Architecture: all
Depends: python3, python3-gi, python3-gi-cairo, gir1.2-gtk-4.0, gir1.2-gtk-3.0, gir1.2-ayatanaappindicator3-0.1, libayatana-appindicator3-1, libnotify-bin, xclip, wl-clipboard
Maintainer: Ronok
Description: Clipboard Guardian
 A lightweight clipboard monitoring application with tray controls, notifications and clipboard history.
EOF


echo
echo "Removing old build..."

rm -rf build/clipboard-guardian


echo
echo "Checking control syntax..."

mkdir -p /tmp/debian-control-test/DEBIAN

cp packaging/debian/control \
/tmp/debian-control-test/DEBIAN/control


dpkg-deb --build \
/tmp/debian-control-test \
/tmp/control-test.deb >/dev/null


rm -rf /tmp/debian-control-test
rm -f /tmp/control-test.deb


echo
echo "===================================="
echo " Debian control fixed"
echo "===================================="
