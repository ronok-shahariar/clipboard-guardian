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

