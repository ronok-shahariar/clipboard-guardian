"""
Clipboard Guardian

Configuration Manager
"""

from __future__ import annotations

import json

from pathlib import Path


DEFAULT_CONFIG = {
    "history_limit": 20,
    "toast_duration": 5,
    "popup_enabled": True,
    "poll_interval": 300,
    "run_at_startup": True,
    "theme": "system",
}


class ConfigManager:

    def __init__(self):

        self.config_dir = Path.home() / ".config" / "clipboard-guardian"

        self.config_dir.mkdir(parents=True, exist_ok=True)

        self.config_file = self.config_dir / "config.json"

        self.data = {}

    # ---------------------------------------------

    def load(self):

        if not self.config_file.exists():

            self.data = DEFAULT_CONFIG.copy()

            self.save()

            return

        self.data = json.loads(self.config_file.read_text())

    # ---------------------------------------------

    def save(self):

        self.config_file.write_text(json.dumps(self.data, indent=4))

    # ---------------------------------------------

    def get(self, key, default=None):

        return self.data.get(key, default)

    # ---------------------------------------------

    def set(self, key, value):

        self.data[key] = value
