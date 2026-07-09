from __future__ import annotations

import gi

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib

from src.gui.widgets.toast_overlay import ToastOverlay


class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, app, *args, **kwargs):
        super().__init__(application=app)

        self.set_title("Clipboard Guardian")
        self.set_default_size(340, 210)
        self.set_size_request(300, 180)
        self.set_resizable(True)

        self.history = []
        self.index = 0
        self.monitoring = True

        self.toast = ToastOverlay()

        self.main_outer = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=6,
        )
        self.main_outer.set_margin_top(8)
        self.main_outer.set_margin_bottom(8)
        self.main_outer.set_margin_start(8)
        self.main_outer.set_margin_end(8)
        self.main_outer.add_css_class("main-card")

        self.text_buffer = Gtk.TextBuffer()

        self.text_view = Gtk.TextView.new_with_buffer(self.text_buffer)
        self.text_view.set_editable(False)
        self.text_view.set_cursor_visible(False)
        self.text_view.set_monospace(True)
        self.text_view.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        self.text_view.add_css_class("clipboard-text-view")

        scroller = Gtk.ScrolledWindow()
        scroller.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scroller.set_min_content_height(110)
        scroller.set_vexpand(True)
        self.text_view.set_vexpand(True)
        self.text_view.set_hexpand(True)
        scroller.set_child(self.text_view)

        self.main_outer.append(scroller)

        nav_row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=6,
        )

        self.prev_btn = Gtk.Button(label="◀")
        self.prev_btn.set_tooltip_text("Show older copied text")
        self.prev_btn.connect("clicked", self.show_older)

        self.counter_label = Gtk.Label(label="0/0")

        self.next_btn = Gtk.Button(label="▶")
        self.next_btn.set_tooltip_text("Show newer copied text")
        self.next_btn.connect("clicked", self.show_newer)

        self.status_btn = Gtk.Button(label="ON")
        self.status_btn.set_tooltip_text("Turn monitoring ON/OFF")
        self.status_btn.connect("clicked", self.toggle_monitoring)

        nav_row.append(self.prev_btn)
        nav_row.append(self.counter_label)
        nav_row.append(self.next_btn)
        nav_row.append(self.status_btn)

        self.main_outer.append(nav_row)

        button_row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=6,
        )

        refresh_btn = Gtk.Button(label="Refresh")
        refresh_btn.connect("clicked", self.refresh_window)

        copy_btn = Gtk.Button(label="Copy")
        copy_btn.set_tooltip_text("Copy visible text again")
        copy_btn.connect("clicked", self.copy_visible_text)

        clear_btn = Gtk.Button(label="Clear")
        clear_btn.connect("clicked", self.clear_history)

        hide_btn = Gtk.Button(label="Hide")
        hide_btn.connect("clicked", lambda *_: self.hide())

        button_row.append(refresh_btn)
        button_row.append(copy_btn)
        button_row.append(clear_btn)
        button_row.append(hide_btn)

        self.main_outer.append(button_row)

        overlay = Gtk.Overlay()
        overlay.set_child(self.main_outer)
        overlay.add_overlay(self.toast)

        self.set_child(overlay)

        self.connect("close-request", self.on_close_request)

        self.set_text("[Clipboard Guardian Ready]")
        self.update_counter()

    def add_clipboard_text(self, text: str):
        if not text:
            return

        if text in self.history:
            self.history.remove(text)

        self.history.insert(0, text)
        self.history = self.history[:20]
        self.index = 0

        self.show_current_item()
        self.flash_border()

    def add_item(self, item):
        self.add_clipboard_text(getattr(item, "text", str(item)))

    def add_history_item(self, item):
        self.add_item(item)

    def update_history(self, items):
        self.history = [
            getattr(item, "text", str(item))
            for item in items
        ]
        self.index = 0
        self.show_current_item()

    def show_current_item(self):
        if not self.history:
            self.set_text("[Empty or unavailable]")
            self.update_counter()
            return

        self.set_text(self.history[self.index])
        self.update_counter()

    def show_older(self, *_args):
        if self.index < len(self.history) - 1:
            self.index += 1
            self.show_current_item()

    def show_newer(self, *_args):
        if self.index > 0:
            self.index -= 1
            self.show_current_item()

    def update_counter(self):
        total = len(self.history)

        if total == 0:
            self.counter_label.set_text("0/0")
            self.prev_btn.set_sensitive(False)
            self.next_btn.set_sensitive(False)
            return

        self.counter_label.set_text(f"{self.index + 1}/{total}")
        self.prev_btn.set_sensitive(self.index < total - 1)
        self.next_btn.set_sensitive(self.index > 0)

    def set_text(self, text: str):
        self.text_buffer.set_text(text)
        self.text_view.queue_draw()
        self.queue_draw()

    def get_visible_text(self):
        start = self.text_buffer.get_start_iter()
        end = self.text_buffer.get_end_iter()
        return self.text_buffer.get_text(start, end, True)

    def copy_visible_text(self, *_args):
        text = self.get_visible_text()

        if not text.strip() or text.startswith("[Empty"):
            return

        clipboard = self.get_display().get_clipboard()
        clipboard.set(text)

    def clear_history(self, *_args):
        self.history = []
        self.index = 0
        self.set_text("[History cleared]")
        self.update_counter()

    def refresh_window(self, *_args):
        self.queue_draw()

    def toggle_monitoring(self, *_args):
        self.monitoring = not self.monitoring

        if self.monitoring:
            self.status_btn.set_label("ON")
        else:
            self.status_btn.set_label("OFF")

    def flash_border(self):
        self.main_outer.remove_css_class("copy-flash")
        self.text_view.remove_css_class("text-flash")

        self.main_outer.add_css_class("copy-flash")
        self.text_view.add_css_class("text-flash")

        GLib.timeout_add(1200, self.clear_flash_border)

    def clear_flash_border(self):
        self.main_outer.remove_css_class("copy-flash")
        self.text_view.remove_css_class("text-flash")
        return False


    def on_close_request(self, *_args):
        self.hide()
        return True
