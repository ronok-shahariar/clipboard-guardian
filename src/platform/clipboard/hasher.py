from __future__ import annotations

import hashlib


class Hasher:

    @staticmethod
    def sha256(text: str) -> str:

        return hashlib.sha256(text.encode("utf-8")).hexdigest()

    @staticmethod
    def sha256_text(text: str) -> str:

        return Hasher.sha256(text)
