"""
Clipboard Guardian

Base Service Class
"""

from __future__ import annotations

from abc import ABC
from abc import abstractmethod


class Service(ABC):
    """
    Base class for all Guardian services.
    """

    def __init__(
        self,
        name: str,
        logger=None,
        config=None,
        event_bus=None,
    ):

        self.name = name

        self.logger = logger

        self.config = config

        self.event_bus = event_bus

        self.running = False

        self.initialized = False

    # -------------------------------------------------

    @abstractmethod
    def initialize(self) -> None:
        """
        Allocate resources.
        """
        pass

    # -------------------------------------------------

    @abstractmethod
    def start(self) -> None:
        """
        Start the service.
        """
        pass

    # -------------------------------------------------

    @abstractmethod
    def stop(self) -> None:
        """
        Stop the service.
        """
        pass
