#!/usr/bin/env bash

set -euo pipefail

echo "===================================="
echo " Finalize Clipboard Guardian v2.0.0"
echo "===================================="


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"


################################
# Ensure version
################################

echo "Checking version..."

echo "2.0.0" > VERSION



################################
# Add changelog
################################

echo "Creating CHANGELOG.md..."


cat > CHANGELOG.md <<'EOF'
# Clipboard Guardian 2.0.0

## Release Highlights

First production Debian release.

## Added

- Debian package installation support
- Automatic dependency handling
- Systemd user service integration
- Automatic startup after reboot
- Hidden startup mode
- Production-safe asset paths
- Tray indicator support
- Persistent application settings
- Live tray synchronization
- Clipboard notifications
- Clipboard history management

## Fixed

- GTK startup race condition after reboot
- Wayland/GNOME startup issues
- Missing tray process after login
- Duplicate tray process issue
- Debian package cleanup problems
- Unsafe package removal lifecycle
- Production icon/resource path issues

## Packaging

- Added .deb build system
- Added postinst configuration
- Added safe prerm cleanup
- Added postrm cleanup
- Added systemd user service packaging

EOF



################################
# Release build script
################################

echo "Creating release build script..."


cat > scripts/release_build.sh <<'EOF'
#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Clipboard Guardian Release Build"
echo "===================================="


ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"


echo "Checking syntax..."

python3 -m compileall src -q

bash -n scripts/build_deb.sh

bash -n packaging/debian/postinst
bash -n packaging/debian/prerm
bash -n packaging/debian/postrm


echo "Cleaning old builds..."

rm -rf build dist


echo "Building package..."

./scripts/build_deb.sh


echo
echo "Verifying package..."


dpkg-deb -I dist/clipboard-guardian_2.0.0_all.deb

echo

dpkg-deb -c dist/clipboard-guardian_2.0.0_all.deb \
| grep -E "systemd|applications|icons|assets"


echo
echo "===================================="
echo " Release build completed"
echo "===================================="

echo
echo "Artifact:"
echo "dist/clipboard-guardian_2.0.0_all.deb"

EOF


chmod +x scripts/release_build.sh



################################
# Final verification
################################

echo "Running release checks..."

python3 -m compileall src -q

bash -n scripts/release_build.sh


echo
echo "===================================="
echo " v2.0.0 finalization completed"
echo "===================================="
