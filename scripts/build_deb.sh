#!/usr/bin/env bash
set -euo pipefail

APP_ID="clipboard-guardian"
APP_NAME="Clipboard Guardian"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

VERSION="$(cat "$ROOT_DIR/VERSION")"
ARCH="all"

BUILD_DIR="$ROOT_DIR/build/${APP_ID}"
DIST_DIR="$ROOT_DIR/dist"

DEB_FILE="${APP_ID}_${VERSION}_${ARCH}.deb"


echo "Building ${APP_NAME} ${VERSION}"


rm -rf "$BUILD_DIR"

mkdir -p \
"$BUILD_DIR/DEBIAN" \
"$BUILD_DIR/usr/bin" \
"$BUILD_DIR/usr/share/${APP_ID}" \
"$BUILD_DIR/usr/share/applications" \
"$BUILD_DIR/usr/lib/systemd/user" \
"$BUILD_DIR/usr/share/icons/hicolor/128x128/apps"



################################
# Application source
################################

cp -a "$ROOT_DIR/src" \
"$BUILD_DIR/usr/share/${APP_ID}/"


################################
# Assets
################################

cp -a "$ROOT_DIR/assets" \
"$BUILD_DIR/usr/share/${APP_ID}/"



################################
# Launcher
################################

cat > "$BUILD_DIR/usr/bin/${APP_ID}" <<EOF2
#!/usr/bin/env bash
set -e

cd /usr/share/${APP_ID}

export GSK_RENDERER=cairo

exec python3 -m src.main "\$@"
EOF2


chmod 755 "$BUILD_DIR/usr/bin/${APP_ID}"



################################
# Icon
################################

cp "$ROOT_DIR/assets/icons/clipboard-guardian-green.png" \
"$BUILD_DIR/usr/share/icons/hicolor/128x128/apps/${APP_ID}.png"



################################
# Desktop launcher
################################

cat > "$BUILD_DIR/usr/share/applications/${APP_ID}.desktop" <<EOF2
[Desktop Entry]
Type=Application
Name=${APP_NAME}
Comment=Clipboard history and notification utility
Exec=${APP_ID}
Icon=${APP_ID}
Terminal=false
Categories=Utility;
StartupNotify=false
EOF2



################################
# Systemd User Service
################################

cp "$ROOT_DIR/packaging/systemd/clipboard-guardian.service" \
"$BUILD_DIR/usr/share/clipboard-guardian/clipboard-guardian.service"

cp "$ROOT_DIR/packaging/systemd/clipboard-guardian.service" \
"$BUILD_DIR/usr/lib/systemd/user/clipboard-guardian.service"

################################
# Debian control
################################

################################
# Debian metadata
################################

cp "$ROOT_DIR/packaging/debian/control" "$BUILD_DIR/DEBIAN/control"

cp "$ROOT_DIR/packaging/debian/postinst" "$BUILD_DIR/DEBIAN/postinst" 2>/dev/null || true

cp "$ROOT_DIR/packaging/debian/prerm" "$BUILD_DIR/DEBIAN/prerm" 2>/dev/null || true

cp "$ROOT_DIR/packaging/debian/postrm" "$BUILD_DIR/DEBIAN/postrm" 2>/dev/null || true

chmod 755 "$BUILD_DIR/DEBIAN/"* 2>/dev/null || true



################################
# Cleanup
################################

find "$BUILD_DIR" -type d -name "__pycache__" -exec rm -rf {} +
find "$BUILD_DIR" -type f -name "*.pyc" -delete



################################
# Build
################################

mkdir -p "$DIST_DIR"

dpkg-deb --build \
"$BUILD_DIR" \
"$DIST_DIR/$DEB_FILE"


echo
echo "================================"
echo "Built:"
echo "$DIST_DIR/$DEB_FILE"
echo "================================"
