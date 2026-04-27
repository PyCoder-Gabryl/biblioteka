#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime

from PySide6.QtCore import Qt
from PySide6.QtGui import QFont
from PySide6.QtWidgets import (
	QLabel,
	QMainWindow,
	QSizePolicy,
	QTabWidget,
	QTextEdit,
	QVBoxLayout,
	QWidget,
)

from biblioteka import __about__
from biblioteka.config.settings import load_settings
from biblioteka.logging import get_logger

log = get_logger(__name__)

TAB_NAMES = ['Dodaj', 'Szukaj', 'Przeglądaj', 'Statystyki', 'Logi', 'Ustawienia', 'O aplikacji']
TAB_COLORS = ['#E74C3C', '#3498DB', '#2ECC71', '#9B59B6', '#F39C12', '#1ABC9C', '#E0E0E0']


class MainWindow(QMainWindow):
	def __init__(self) -> None:
		super().__init__()
		self._settings = load_settings()
		self._theme = self._settings.theme
		self._fonts = self._settings.fonts
		self._log_panel: QTextEdit = None  # type: ignore[assignment]
		self.setWindowTitle(self._build_title())
		self.setMinimumSize(self._settings.ui.window_width, self._settings.ui.window_height)
		self._setup_ui()
		self._center_on_screen()
		log.info('gui-ready', message='Aplikacja gotowa do działania')

	def _build_title(self) -> str:
		created = datetime.now().strftime('%Y-%m-%d')
		return f'{__about__.__app_name__} :: {__about__.__version__} : {created}'

	def _setup_ui(self) -> None:
		self.setStyleSheet(f'QMainWindow {{ background-color: {self._theme.bg_dark}; }} QWidget {{ color: {self._theme.text_primary}; }}')

		self._tabs = QTabWidget()
		self._tabs.setTabPosition(QTabWidget.TabPosition.North)
		self._tabs.currentChanged.connect(self._on_tab_changed)

		self._log_panel = self._create_log_panel()

		for name in TAB_NAMES:
			self._tabs.addTab(self._create_tab(name), name)

		self._style_tabs()
		self._load_logs()

		layout = QVBoxLayout()
		layout.setContentsMargins(0, 0, 0, 0)
		layout.setSpacing(0)
		layout.addWidget(self._tabs, 1)
		layout.addWidget(self._log_panel, 0)

		central = QWidget()
		central.setLayout(layout)
		self.setCentralWidget(central)

	def _create_tab(self, name: str) -> QWidget:
		tab = QWidget()
		if name == 'O aplikacji':
			self._create_about_tab(tab)
		else:
			label = QLabel(f'Zakładka: {name}')
			label.setAlignment(Qt.AlignmentFlag.AlignCenter)
			layout = QVBoxLayout(tab)
			layout.addWidget(label)
		return tab

	def _create_about_tab(self, tab: QWidget) -> None:
		layout = QVBoxLayout(tab)
		layout.setContentsMargins(50, 50, 50, 50)
		layout.setSpacing(30)

		title = QLabel(__about__.__app_name__.upper())
		title.setFont(QFont(self._fonts.tab_family, 36, QFont.Weight.Bold))
		title.setAlignment(Qt.AlignmentFlag.AlignHCenter)
		layout.addWidget(title)

		info = QLabel(f'Wersja: {__about__.__version__}<br>Utworzono: {__about__.__created__}<br>Autor: {__about__.__author__}')
		info.setFont(QFont(self._fonts.tab_family, 16))
		info.setAlignment(Qt.AlignmentFlag.AlignHCenter)
		layout.addWidget(info)

		link = QLabel(f'<a href="{__about__.__github__}">{__about__.__github__}</a>')
		link.setFont(QFont(self._fonts.tab_family, 14))
		link.setAlignment(Qt.AlignmentFlag.AlignHCenter)
		link.setOpenExternalLinks(True)
		layout.addWidget(link)
		layout.addStretch()

	def _style_tabs(self) -> None:
		font = QFont(self._fonts.tab_family)
		font.setPointSize(self._fonts.tab_size)
		font.setItalic(True)

		tab_bar = self._tabs.tabBar()
		tab_bar.setFont(font)
		tab_bar.setExpanding(True)
		tab_bar.setStyleSheet(f'QTabBar::tab {{ background-color: {self._theme.tabs_bg}; color: {self._theme.tabs_text}; padding: 8px 24px; min-width: 120px; }} QTabBar::tab:selected {{ background-color: {self._theme.tabs_active}; }}')

		for i, color in enumerate(TAB_COLORS):
			self._tabs.tabBar().setTabTextColor(i, color)

	def _create_log_panel(self) -> QTextEdit:
		panel = QTextEdit()
		panel.setReadOnly(True)
		panel.setFixedHeight(80)
		panel.setStyleSheet(f'QTextEdit {{ background-color: {self._settings.panel.bg_color}; color: {self._settings.panel.text_color}; border: none; padding: 10px; font-family: {self._fonts.tab_family}; font-size: 12px; }}')
		return panel

	def _load_logs(self) -> None:
		if not self._log_panel:
			return
		import json
		from biblioteka.config.settings import get_project_root
		project_root = get_project_root()
		log_file = project_root / self._settings.logging.file.path
		if log_file.exists():
			content = log_file.read_text(encoding='utf-8')
			lines = content.strip().split('\n')
			recent = lines[-50:] if len(lines) > 50 else lines
			self._log_panel.clear()
			for line in reversed(recent):
				if line:
					try:
						entry = json.loads(line)
						msg = entry.get('event', '')
						if msg:
							self._log_panel.append(msg)
					except Exception:
						pass

	def _on_tab_changed(self, index: int) -> None:
		tab_name = self._tabs.tabText(index)
		log.debug('zmiana-zakladki', tab=tab_name)

		if tab_name == 'Logi':
			self._log_panel.setFixedHeight(750)
		else:
			self._log_panel.setFixedHeight(80)

		self._load_logs()
		if self._log_panel:
			self._log_panel.append(f'przełączono na {tab_name}')

	def _center_on_screen(self) -> None:
		screen = self.screen()
		geo = screen.geometry()
		x = (geo.width() - self.width()) // 2
		y = (geo.height() - self.height()) // 2
		self.move(x, y)


__all__ = ['MainWindow']