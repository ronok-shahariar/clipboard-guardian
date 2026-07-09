"""
Clipboard Guardian

Clipboard History Engine
"""

from __future__ import annotations

from typing import Optional

from src.models.clipboard_item import ClipboardItem


class ClipboardHistory:
    """
    Stores clipboard history and allows navigation.
    """

    def __init__(self, max_items: int = 100):

        self._items: list[ClipboardItem] = []

        self._cursor = 0

        self._max_items = max_items

    # ---------------------------------------------------------

    def add(self, item: ClipboardItem) -> None:
        """
        Add a new clipboard item.

        Duplicate hashes are moved to the top.
        """

        self._items = [x for x in self._items if x.sha256 != item.sha256]

        self._items.insert(0, item)

        if len(self._items) > self._max_items:
            self._items = self._items[: self._max_items]

        self._cursor = 0

    # ---------------------------------------------------------

    def current(self) -> Optional[ClipboardItem]:

        if not self._items:
            return None

        return self._items[self._cursor]

    # ---------------------------------------------------------

    def latest(self) -> Optional[ClipboardItem]:

        if not self._items:
            return None

        return self._items[0]

    # ---------------------------------------------------------

    def previous(self) -> Optional[ClipboardItem]:

        if not self._items:
            return None

        if self._cursor < len(self._items) - 1:
            self._cursor += 1

        return self.current()

    # ---------------------------------------------------------

    def next(self) -> Optional[ClipboardItem]:

        if not self._items:
            return None

        if self._cursor > 0:
            self._cursor -= 1

        return self.current()

    # ---------------------------------------------------------

    def clear(self):

        self._items.clear()

        self._cursor = 0

    # ---------------------------------------------------------

    def count(self) -> int:

        return len(self._items)

    # ---------------------------------------------------------

    def items(self):

        return list(self._items)
