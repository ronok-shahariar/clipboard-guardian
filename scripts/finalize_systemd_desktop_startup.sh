#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Finalize Systemd Desktop Startup"
echo "===================================="


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"


echo
echo "Creating backups..."

cp "$ROOT_DIR/scripts/build_deb.sh" \
"$ROOT_DIR/scripts/build_deb.sh.backup_systemd_final"

cp "$ROOT_DIR/packaging/debian/postinst" \
"$ROOT_DIR/packaging/debian/postinst.backup_final"

cp "$ROOT_DIR/packaging/debian/prerm" \
"$ROOT_DIR/packaging/debian/prerm.backup_final"



echo
echo "Updating build script..."


python3 - "$ROOT_DIR/scripts/build_deb.sh" <<'PY'

from pathlib import Path
import sys

p=Path(sys.argv[1])

text=p.read_text()


# Remove GNOME autostart directory creation

text=text.replace(
'"$BUILD_DIR/etc/xdg/autostart" \\\n',
''
)


# Remove autostart block

start=text.find(
'################################\n# Autostart'
)

end=text.find(
'################################\n# Systemd User Service'
)


if start != -1 and end != -1:
    text=text[:start]+text[end:]


p.write_text(text)

PY



echo
echo "Updating postinst..."


cat > "$ROOT_DIR/packaging/debian/postinst" <<'EOF'
#!/bin/bash

set -e


echo "Configuring Clipboard Guardian..."


gtk-update-icon-cache \
/usr/share/icons/hicolor \
>/dev/null 2>&1 || true


update-desktop-database \
>/dev/null 2>&1 || true


systemctl --global daemon-reload 2>/dev/null || true


chmod 755 /usr/bin/clipboard-guardian || true


exit 0
EOF



echo
echo "Updating prerm..."


cat > "$ROOT_DIR/packaging/debian/prerm" <<'EOF'
#!/bin/bash

set -e


systemctl --global disable clipboard-guardian.service 2>/dev/null || true

pkill -x clipboard-guardian || true

rm -f /tmp/clipboard_guardian_tray_*.sock || true


exit 0
EOF



echo
echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete



echo
echo "Syntax check..."

bash -n "$ROOT_DIR/scripts/build_deb.sh"


echo
echo "===================================="
echo " Systemd desktop startup finalized"
echo "===================================="
