"""
Clipboard Events
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from src.models.clipboard_item import ClipboardItem


@dataclass(slots=True)
class ClipboardChangedEvent:
    """
    Published whenever clipboard contents change.
    """

    item: ClipboardItem

    timestamp: datetime = field(default_factory=datetime.now)

    backend: str = "xclip"

    source: str = "clipboard"
