"""
Abstract Clipboard Backend
"""

from __future__ import annotations

from abc import ABC
from abc import abstractmethod


class ClipboardBackend(ABC):

    @abstractmethod
    def read_text(self) -> str:
        raise NotImplementedError

    @abstractmethod
    def write_text(self, text: str) -> None:
        raise NotImplementedError
