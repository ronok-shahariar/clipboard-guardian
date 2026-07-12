#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Final Production Package Fix"
echo "===================================="


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"


echo "Creating backups..."

mkdir -p .backups/final_package_fix

cp packaging/debian/prerm \
.backups/final_package_fix/prerm.backup 2>/dev/null || true

cp packaging/debian/postrm \
.backups/final_package_fix/postrm.backup 2>/dev/null || true



################################
# SAFE PRERM
################################

echo "Updating prerm..."


cat > packaging/debian/prerm <<'EOF'
#!/bin/bash

set -e

echo "Stopping Clipboard Guardian..."


systemctl --user stop clipboard-guardian.service \
>/dev/null 2>&1 || true


systemctl --user disable clipboard-guardian.service \
>/dev/null 2>&1 || true


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


exit 0
EOF



################################
# SAFE POSTRM
################################

echo "Updating postrm..."


cat > packaging/debian/postrm <<'EOF'
#!/bin/bash

set -e

echo "Cleaning Clipboard Guardian leftovers..."


rm -rf /usr/share/clipboard-guardian || true

rm -f /usr/bin/clipboard-guardian || true

rm -f /usr/lib/systemd/user/clipboard-guardian.service || true


rm -f /tmp/clipboard_guardian*.sock || true

rm -f /tmp/clipboard_guardian_tray.lock || true


systemctl --user daemon-reload \
>/dev/null 2>&1 || true


update-desktop-database \
>/dev/null 2>&1 || true


gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


exit 0
EOF



################################
# PERMISSIONS
################################

chmod 755 packaging/debian/prerm
chmod 755 packaging/debian/postrm



################################
# ADD POSTRM TO BUILDER
################################

echo "Updating build script..."


if ! grep -q "DEBIAN/postrm" scripts/build_deb.sh
then

cat >> /tmp/postrm_patch <<'EOF'


cp "$ROOT_DIR/packaging/debian/postrm" \
"$BUILD_DIR/DEBIAN/postrm" 2>/dev/null || true

EOF


sed -i '/# Cleanup/i\
\
################################\
# Debian postrm\
################################\
\
cp "$ROOT_DIR/packaging/debian/postrm" "$BUILD_DIR/DEBIAN/postrm" 2>/dev/null || true\
' scripts/build_deb.sh


fi



################################
# REMOVE CACHE
################################

echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete



################################
# CHECK
################################

echo "Syntax check..."

bash -n packaging/debian/prerm
bash -n packaging/debian/postrm
bash -n scripts/build_deb.sh


echo
echo "===================================="
echo " Production package fix completed"
echo "===================================="
