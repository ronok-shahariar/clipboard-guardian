#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " Add Tray Singleton Protection"
echo "===================================="


FILE="src/tray/tray_process.py"


echo "Creating backup..."

cp "$FILE" "${FILE}.backup_singleton"


python3 - <<'PY'

from pathlib import Path

path = Path("src/tray/tray_process.py")

text = path.read_text()


marker = "RELOAD_SOCKET_PATH = os.environ.get("


insert = r'''

# -------------------------------------------------
# Tray Singleton Protection
# -------------------------------------------------

TRAY_LOCK_FILE = "/tmp/clipboard_guardian_tray.lock"


def acquire_tray_lock():

    import fcntl

    lock = open(
        TRAY_LOCK_FILE,
        "w"
    )

    try:
        fcntl.flock(
            lock,
            fcntl.LOCK_EX | fcntl.LOCK_NB
        )

        return lock

    except BlockingIOError:

        print(
            "Clipboard Guardian tray already running."
        )

        raise SystemExit(0)


'''


if "acquire_tray_lock" not in text:

    text = text.replace(
        marker,
        insert + "\n" + marker
    )


text = text.replace(
    "def main():\n\n    tray = ClipboardGuardianTray()",
    "def main():\n\n    tray_lock = acquire_tray_lock()\n\n    tray = ClipboardGuardianTray()"
)


path.write_text(text)

PY


echo "Cleaning cache..."

find src -type d -name "__pycache__" -exec rm -rf {} +
find src -name "*.pyc" -delete


echo "Syntax check..."

python3 -m compileall src -q


echo
echo "===================================="
echo " Tray singleton protection added"
echo "===================================="
