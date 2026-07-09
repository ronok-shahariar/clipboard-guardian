# Clipboard Guardian

A small Linux GUI app that shows the current copied text before pasting.

## Backend

This version uses `xclip` because it worked correctly on this machine while `wl-copy` and `wl-paste` were unreliable.

## Install dependencies

```bash
sudo apt install python3 python3-tk xclip
# clipboard-guardian
