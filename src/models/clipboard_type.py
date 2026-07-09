"""
Clipboard Guardian

Clipboard Content Types
"""

from enum import Enum


class ClipboardType(Enum):

    TEXT = "text"

    COMMAND = "command"

    URL = "url"

    CODE = "code"

    FILE = "file"

    IMAGE = "image"

    UNKNOWN = "unknown"
