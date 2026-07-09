"""
Clipboard Guardian

Service Manager
"""

from __future__ import annotations

from typing import Dict
from typing import List
from typing import Optional

from .service import Service


class ServiceManager:
    """
    Starts, stops and stores all services.
    """

    def __init__(self):

        self._services: List[Service] = []

        self._service_map: Dict[str, Service] = {}

    # ---------------------------------------------------------

    def register(
        self,
        service: Service,
    ):

        self._services.append(service)

        self._service_map[service.__class__.__name__] = service

    # ---------------------------------------------------------

    def get(
        self,
        service_name: str,
    ) -> Optional[Service]:

        return self._service_map.get(service_name)

    # ---------------------------------------------------------

    def has(
        self,
        service_name: str,
    ) -> bool:

        return service_name in self._service_map

    # ---------------------------------------------------------

    def initialize(self):

        for service in self._services:
            service.initialize()

    # ---------------------------------------------------------

    def start(self):

        for service in self._services:
            service.start()

    # ---------------------------------------------------------

    def stop(self):

        for service in reversed(self._services):
            service.stop()

    # ---------------------------------------------------------

    @property
    def services(self):

        return tuple(self._services)
