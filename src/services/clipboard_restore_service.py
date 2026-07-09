"""
Clipboard Restore Service
"""

from __future__ import annotations

from src.platform.clipboard.backend import ClipboardBackend
from src.models.clipboard_item import ClipboardItem


class ClipboardRestoreService:

    name = "ClipboardRestoreService"

    def __init__(self, backend: ClipboardBackend):

        self.backend = backend

    def restore(self, item: ClipboardItem):

        self.backend.write_text(item.text)
