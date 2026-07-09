from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk

from src.services.clipboard_restore_service import ClipboardRestoreService


class HistoryList(Gtk.ListBox):

    def __init__(self, history, backend):
        super().__init__()

        self.history = history
        self.restore = ClipboardRestoreService(backend)

        self.connect("row-activated", self._activated)

    def refresh(self):

        while child := self.get_first_child():
            self.remove(child)

        for item in self.history.items():

            row = Gtk.ListBoxRow()

            row.item = item

            row.set_child(
                Gtk.Label(
                    label=item.preview(2),
                    xalign=0,
                )
            )

            self.append(row)

    def _activated(self, box, row):

        self.restore.restore(row.item)

        print("Restored:", row.item.preview(1))
