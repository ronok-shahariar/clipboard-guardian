from __future__ import annotations

import subprocess
import shutil
from pathlib import Path

from gi.repository import GLib

from src.events.clipboard_events import ClipboardChangedEvent
from src.core.paths import ICON_PATH


class NotificationService:
    name = "NotificationService"

    def __init__(self, event_bus=None):
        self.event_bus = event_bus
        self.application = None
        self.window = None
        self.overlay = None

    def set_overlay(self, overlay):
        self.overlay = overlay

    def set_application(self, app):
        self.application = app

    def set_window(self, window):
        self.window = window

    def initialize(self):
        pass

    def start(self):
        if self.event_bus:
            self.event_bus.subscribe(ClipboardChangedEvent, self.handle)

    def stop(self):
        pass

    def handle(self, event):
        text = event.item.text

        if self.window is not None:
            GLib.idle_add(self.window.add_clipboard_text, text)

        toast_enabled = True
        notify_enabled = True

        if self.event_bus is not None:
            toast_enabled = getattr(self.event_bus, "toast_enabled", True)
            notify_enabled = getattr(self.event_bus, "notify_enabled", True)

        preview = " ".join(text.strip().split())
        if len(preview) > 90:
            preview = preview[:90] + "..."

        if toast_enabled:
            subprocess.Popen(
                ["python3", "-m", "src.gui.toast_process"],
                stdin=subprocess.PIPE,
                text=True,
            ).communicate(text)

        if notify_enabled and shutil.which("notify-send"):
            subprocess.Popen([
                "notify-send",
                "-i",
                str(ICON_PATH),
                "Clipboard Guardian",
                "🔴🔴🔴 " + preview + " 🔴🔴🔴",
            ])
