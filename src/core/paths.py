"""
Clipboard Guardian
Application Paths
"""

from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[2]

ASSETS_DIR = APP_ROOT / "assets"

ICON_PATH = (
    ASSETS_DIR /
    "icons" /
    "clipboard-guardian-green.png"
)
