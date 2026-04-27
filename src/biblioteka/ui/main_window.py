#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              src/biblioteka/ui/main_window.py
#
#   WERSJA:             0.2 [04-27]
#   Data utworzenia:    2026 kwiecień 27, 03:00
#
#   COPYRIGHT:          2026 PyGamiQ <pygamiq@gmail.com>
#   LICENCJA:           MIT
#
#   AUTOR:              PyGamiQ
#   GITHUB:             https://github.com/PyGamiQ/bibliotka
#   IDE:                PyCharm Python 3.14.4 <macOS ARM>
# ==========================================================================================
#   OPIS:
#       Główne okno aplikacji z zakładkami.
#       - QTabWidget z zakładkami na górze (jak w Word)
#       - Zakładki: Dodaj, Szukaj, Przeglądaj, Statystyki, Logi, Ustawienia
#       - Panel logów na dole (czarny, białe logi)
# ==========================================================================================

from datetime import datetime
from pathlib import Path

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QTextCharFormat, QTextCursor
from PySide6.QtWidgets import (
	QApplication,
	QFrame,
	QLabel,
	QMainWindow,
	QTabWidget,
	QTextEdit,
	QVBoxLayout,
	QWidget,
)

from biblioteka import __about__
from biblioteka.config.settings import get_project_root, load_settings
from biblioteka.logging import get_logger

log = get_logger(__name__)


TAB_NAMES = ['Dodaj', 'Szukaj', 'Przeglądaj', 'Statystyki', 'Logi', 'Ustawienia']

TAB_COLORS = [
	'#E74C3C',  # Dodaj - czerwony
	'#3498DB',  # Szukaj - niebieski
	'#2ECC71',  # Przeglądaj - zielony
	'#9B59B6',  # Statystyki - fioletowy
	'#F39C12',  # Logi - pomarańczowy
	'#1ABC9C',  # Ustawienia - turkusowy
]


class MainWindow(QMainWindow):
	"""Główne okno aplikacji biblioteki."""

	def __init__(self) -> None:
		"""Inicjalizacja głównego okna."""
		super().__init__()

		settings = load_settings()
		self._settings = settings

		self.setWindowTitle(self._build_title())
		self.setMinimumSize(settings.ui.window_width, settings.ui.window_height)

		self._log_panel: QTextEdit = None  # type: ignore[assignment]

		self._setup_ui()
		self._center_on_screen()

		log.info('gui-ready', message='Aplikacja gotowa do działania')

	def _build_title(self) -> str:
		"""Buduje tytuł okna."""
		created = datetime.now().strftime('%Y-%m-%d')
		return f'bibliotka :: {__about__.__version__} : {created}'

	def _setup_ui(self) -> None:
		"""Tworzy interfejs użytkownika."""
		central = QWidget()
		layout = QVBoxLayout(central)
		layout.setContentsMargins(0, 0, 0, 0)
		layout.setSpacing(0)

		self._tabs = QTabWidget()
		self._tabs.setTabPosition(QTabWidget.TabPosition.North)
		self._tabs.currentChanged.connect(self._on_tab_changed)

		for i, name in enumerate(TAB_NAMES):
			self._tabs.addTab(self._create_tab(name), name)

		layout.addWidget(self._tabs)
		layout.addWidget(self._create_log_panel())

		self._style_tabs()
		self.setCentralWidget(central)

	def _create_tab(self, name: str) -> QWidget:
		"""Tworzy pustą zakładkę placeholder."""
		tab = QWidget()
		label = QLabel(f'Zakładka: {name}')
		label.setAlignment(Qt.AlignmentFlag.AlignCenter)
		layout = QVBoxLayout(tab)
		layout.addWidget(label)
		return tab

	def _style_tabs(self) -> None:
		"""Stylizuje zakładki."""
		font = QFont('JetBrains Mono')
		font.setPointSize(font.pointSize() * 2)

		for i in range(self._tabs.count()):
			tab = self._tabs.tabBar()
			tab.setFont(font)
			tab.setExpanding(True)
			tab.setDocumentMode(True)

			self._tabs.tabBar().setTabTextColor(i, TAB_COLORS[i])

		self._tabs.tabBar().setStyleSheet('''
			QTabBar::tab {
				min-width: 100px;
				padding: 10px 20px;
			}
		''')

	def _create_log_panel(self) -> QTextEdit:
		"""Tworzy panel logów na dole."""
		settings = self._settings.panel
		max_height = int(self._settings.ui.window_height * settings.max_height_ratio)

		panel = QTextEdit()
		panel.setMaximumHeight(max_height)
		panel.setReadOnly(True)

		panel.setStyleSheet('''
			QTextEdit {
				background-color: #000000;
				color: #FFFFFF;
				border: none;
				padding: 10px;
				font-family: 'JetBrains Mono';
				font-size: 12px;
			}
		''')

		return panel

	def _read_logs(self) -> None:
		"""Wczytuje logi do panelu."""
		if not self._log_panel:
			return

		project_root = get_project_root()
		log_file = project_root / self._settings.logging.file.path

		if not log_file.exists():
			return

		content = log_file.read_text(encoding='utf-8')
		lines = content.strip().split('\n')
		recent = lines[-20:] if len(lines) > 20 else lines

		for line in recent:
			if line:
				try:
					import json
					entry = json.loads(line)
					msg = entry.get('event', '')
					if msg:
						self._log_panel.moveCursor(QTextCursor.MoveOperation.End)
						self._log_panel.insertPlainText(f'{msg}\n')
				except Exception:
					pass

	def _append_log(self, message: str) -> None:
		"""Dodaje log do panelu."""
		if not self._log_panel or not message:
			return
		self._log_panel.moveCursor(QTextCursor.MoveOperation.End)
		self._log_panel.insertPlainText(f'{message}\n')
		self._log_panel.moveCursor(QTextCursor.MoveOperation.End)

	def _on_tab_changed(self, index: int) -> None:
		"""Obsługuje przełączenie zakładki."""
		tab_name = self._tabs.tabText(index)
		log.debug('zmiana-zakladki', tab=tab_name)
		self._append_log(f'→ {tab_name}')

	def _center_on_screen(self) -> None:
		"""Centruje okno na ekranie."""
		screen = self.screen()
		geo = screen.geometry()
		x = (geo.width() - self.width()) // 2
		y = (geo.height() - self.height()) // 2
		self.move(x, y)


__all__ = ['MainWindow']