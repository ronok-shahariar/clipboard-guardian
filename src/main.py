from __future__ import annotations

import sys

import sys

from src.gui.application import GuardianGtkApplication
from src.managers.config_manager import ConfigManager


def main():

    config = ConfigManager()
    config.load()


    # Command line has priority
    if "--hidden" in sys.argv:
        start_hidden = True

    else:
        start_hidden = config.get_start_hidden()


    app = GuardianGtkApplication(
        start_hidden=start_hidden,
    )

    app.run([])


if __name__ == "__main__":
    main()
