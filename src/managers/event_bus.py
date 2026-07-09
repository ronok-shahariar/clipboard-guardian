"""
Clipboard Guardian

Typed Publish / Subscribe Event Bus.
"""

from __future__ import annotations

from collections import defaultdict
from typing import Any
from typing import Callable
from typing import Type


class EventBus:

    def __init__(self):

        self._listeners = defaultdict(list)

    # --------------------------------------------------

    def subscribe(
        self,
        event_type: Type,
        callback: Callable[[Any], None],
    ) -> None:

        if callback not in self._listeners[event_type]:
            self._listeners[event_type].append(callback)

    # --------------------------------------------------

    def unsubscribe(
        self,
        event_type: Type,
        callback: Callable[[Any], None],
    ) -> None:

        if callback in self._listeners[event_type]:
            self._listeners[event_type].remove(callback)

    # --------------------------------------------------

    def publish(
        self,
        event: Any,
    ) -> None:

        event_type = type(event)

        listeners = list(self._listeners.get(event_type, []))

        for callback in listeners:
            callback(event)

    # --------------------------------------------------

    def listener_count(
        self,
        event_type: Type,
    ) -> int:

        return len(self._listeners.get(event_type, []))

    # --------------------------------------------------

    def clear(self) -> None:

        self._listeners.clear()
