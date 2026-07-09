"""
Ubuntu X11 Clipboard Backend
"""

from __future__ import annotations

import subprocess

from .backend import ClipboardBackend


class XClipBackend(ClipboardBackend):

    def read_text(self) -> str:

        try:

            result = subprocess.run(
                [
                    "xclip",
                    "-selection",
                    "clipboard",
                    "-o",
                ],
                capture_output=True,
                text=True,
                timeout=2,
                check=True,
            )

            return result.stdout

        except Exception:
            return ""

    def write_text(self, text: str) -> bool:

        try:

            process = subprocess.Popen(
                [
                    "xclip",
                    "-selection",
                    "clipboard",
                    "-in",
                ],
                stdin=subprocess.PIPE,
                text=True,
            )

            process.communicate(text)

            return process.returncode == 0

        except Exception as e:

            print("Clipboard write failed:", e)

            return False
