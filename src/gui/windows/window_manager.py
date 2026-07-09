"""
Clipboard Guardian

Window Manager
"""

from __future__ import annotations


class WindowManager:

    def __init__(self):

        self.windows = {}

    def register(
        self,
        name,
        window,
    ):

        self.windows[name] = window

    def get(
        self,
        name,
    ):

        return self.windows.get(name)

    def close_all(self):

        for window in self.windows.values():

            try:
                window.close()
            except Exception:
                pass
