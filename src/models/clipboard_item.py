"""
Clipboard Guardian

Clipboard Item Model
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from src.platform.clipboard.hasher import Hasher


@dataclass(slots=True)
class ClipboardItem:
    """
    Represents a single clipboard capture.
    """

    text: str

    timestamp: datetime = field(default_factory=datetime.now)

    source: str = "clipboard"

    mime_type: str = "text/plain"

    favorite: bool = False

    pinned: bool = False

    sha256: str = field(init=False)

    def __post_init__(self):

        self.sha256 = Hasher.sha256_text(self.text)

    def preview(self, lines: int = 3) -> str:

        return "\n".join(self.text.strip().splitlines()[:lines])

    @property
    def length(self) -> int:

        return len(self.text)

    @property
    def is_empty(self) -> bool:

        return self.length == 0

    @property
    def first_line(self) -> str:

        if self.is_empty:
            return ""

        return self.text.splitlines()[0]

    def __str__(self):

        return self.first_line
