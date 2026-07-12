#!/usr/bin/env bash

set -e

echo "===================================="
echo " Add Systemd Boot Delay"
echo "===================================="

SERVICE="packaging/systemd/clipboard-guardian.service"

cp "$SERVICE" "$SERVICE.backup_boot_delay"

python3 - <<'PY'
from pathlib import Path

p = Path("packaging/systemd/clipboard-guardian.service")

text = p.read_text()

if "ExecStartPre=/bin/sleep 5" not in text:
    text = text.replace(
        "Type=simple",
        "Type=simple\n\nExecStartPre=/bin/sleep 5"
    )

p.write_text(text)
PY

echo "Boot delay added"
