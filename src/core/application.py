"""
Clipboard Guardian

Application Bootstrap
"""

from __future__ import annotations

from src.core.service_manager import ServiceManager

from src.managers.event_bus import EventBus

from src.platform.clipboard.xclip_backend import XClipBackend

from src.services.clipboard_service import ClipboardMonitorService
from src.services.history_service import ClipboardHistory
from src.services.notification_service import NotificationService
from src.services.tray_service import TrayService


class GuardianApplication:

    def __init__(self):

        self.event_bus = EventBus()

        self.service_manager = ServiceManager()

        self.backend = XClipBackend()

        self.history = ClipboardHistory()

        clipboard = ClipboardMonitorService(
            backend=self.backend,
            history=self.history,
            event_bus=self.event_bus,
        )

        notifications = NotificationService(
            event_bus=self.event_bus,
        )

        tray = TrayService(
            event_bus=self.event_bus,
        )

        self.service_manager.register(clipboard)
        self.service_manager.register(notifications)
        self.service_manager.register(tray)

    def start(self):

        self.service_manager.initialize()

        self.service_manager.start()

    def stop(self):

        self.service_manager.stop()
