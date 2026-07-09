from __future__ import annotations

import sys

from src.gui.application import GuardianGtkApplication


def main():
    start_hidden = "--hidden" in sys.argv

    app = GuardianGtkApplication(
        start_hidden=start_hidden,
    )

    app.run([])


if __name__ == "__main__":
    main()
