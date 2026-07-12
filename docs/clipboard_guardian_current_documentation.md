# Clipboard Guardian - Project Documentation

## Current Milestone: Persistent Settings and Live Tray Synchronization

Clipboard Guardian now includes: - GTK4 main application - Clipboard
monitoring service - Notification service - Separate tray indicator
process - EventBus communication - ConfigManager persistent
configuration

## Persistent Settings

Configuration file:

\~/.config/clipboard-guardian/config.json

Default controls: - Monitoring - Notifications - Toast popup - Start
hidden

Settings changes are saved and loaded automatically.

## Live Tray Synchronization

Flow:

Settings Window -\> TrayService -\> Tray Process -\> Menu labels update

Changes apply without restarting the application.

## Development Verification

Run:

python3 -m compileall src -q

before commits.

## Current Milestone

Add persistent settings with live tray synchronization
