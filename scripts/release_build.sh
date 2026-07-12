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

