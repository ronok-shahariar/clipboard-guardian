"""
Application lifecycle states.
"""

from enum import Enum


class AppState(Enum):

    CREATED = "created"

    INITIALIZING = "initializing"

    READY = "ready"

    RUNNING = "running"

    STOPPING = "stopping"

    STOPPED = "stopped"
