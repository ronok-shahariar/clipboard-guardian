"""
Clipboard Monitor Service
"""

from __future__ import annotations

import time

from src.core.service import Service
from src.models.clipboard_item import ClipboardItem
from src.events.clipboard_events import ClipboardChangedEvent
from src.platform.clipboard.hasher import Hasher


class ClipboardMonitorService(Service):

    def __init__(
        self,
        backend,
        history,
        logger=None,
        config=None,
        event_bus=None,
    ):

        super().__init__(
            name="ClipboardMonitorService",
            logger=logger,
            config=config,
            event_bus=event_bus,
        )

        self.backend = backend
        self.history = history

        self._last_hash = ""

    def initialize(self):

        self.initialized = True

    def start(self):

        import threading

        self.running = True

        self.thread = threading.Thread(
            target=self._monitor_loop,
            daemon=True,
        )

        self.thread.start()

    def stop(self):

        self.running = False

        if hasattr(self, "thread"):
            self.thread.join(timeout=1)

    def poll_once(self):

        if self.event_bus is not None and getattr(self.event_bus, "monitoring_enabled", True) is False:
            return None

        text = self.backend.read_text()

        if not text.strip():
            return None

        digest = Hasher.sha256(text)

        if digest == self._last_hash:
            return None

        self._last_hash = digest

        item = ClipboardItem(text=text)

        self.history.add(item)

        if self.event_bus:
            self.event_bus.publish(
                ClipboardChangedEvent(
                    item=item,
                    backend="xclip",
                    source="clipboard",
                )
            )

        return item

    def _monitor_loop(self):

        import time

        while self.running:

            try:
                self.poll_once()

            except Exception as e:
                print("Clipboard monitor error:", e)

            time.sleep(0.5)
