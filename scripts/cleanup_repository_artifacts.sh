#!/usr/bin/env bash

set -euo pipefail


echo "===================================="
echo " Cleanup Repository Artifacts "
echo "===================================="


echo
echo "Creating backup archive folders..."

mkdir -p .backups/{managers,services,tray,windows,scripts,misc}


echo
echo "Moving backup files..."


mv src/managers/*.backup* \
.backups/managers/ 2>/dev/null || true


mv src/services/*.backup* \
.backups/services/ 2>/dev/null || true


mv src/tray/*.backup* \
.backups/tray/ 2>/dev/null || true


mv src/gui/windows/*.backup* \
.backups/windows/ 2>/dev/null || true


mv scripts/*.backup* \
.backups/scripts/ 2>/dev/null || true


mv clipboard_guardian_diagnostic.txt \
.backups/misc/ 2>/dev/null || true



echo
echo "Updating gitignore..."


cat >> .gitignore <<'EOF'

# Development backups
.backups/

# Python cache
__pycache__/
*.pyc
*.pyo

# Build output
build/
dist/

EOF


echo
echo "Cleaning python cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo
echo "Verification..."

echo "--- backup archive ---"
find .backups -type f | sort


echo
echo "--- remaining backup files ---"
find . -name "*.backup*" -o -name "*backup*" || true


echo
echo "===================================="
echo " Repository cleanup completed "
echo "===================================="
