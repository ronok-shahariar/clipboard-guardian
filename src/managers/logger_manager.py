"""
Clipboard Guardian

Logger Manager

Central logging system for the application.
"""

from __future__ import annotations

from pathlib import Path
from datetime import datetime


class LoggerManager:

    def __init__(self):

        self.log_dir = Path.home() / ".cache" / "clipboard-guardian"
        self.log_dir.mkdir(parents=True, exist_ok=True)

        self.log_file = self.log_dir / "guardian.log"

    # --------------------------------------------------

    def _write(self, level: str, message: str):

        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        line = f"[{timestamp}] [{level}] {message}"

        print(line)

        with self.log_file.open("a", encoding="utf-8") as f:
            f.write(line + "\n")

    # --------------------------------------------------

    def info(self, message: str):
        self._write("INFO", message)

    def debug(self, message: str):
        self._write("DEBUG", message)

    def warning(self, message: str):
        self._write("WARNING", message)

    def error(self, message: str):
        self._write("ERROR", message)
