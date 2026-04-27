#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              src/biblioteka/ui/main_window.py
#
#   WERSJA:             0.1 [04-27]
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
# ==========================================================================================

from PySide6.QtWidgets import QMainWindow, QTabWidget, QWidget
from PySide6.QtCore import Qt


class MainWindow(QMainWindow):
	"""Główne okno aplikacji biblioteki."""

	def __init__(self) -> None:
		"""Inicjalizacja głównego okna."""
		super().__init__()

		self.setWindowTitle('bibliotka')
		self.setMinimumSize(1200, 800)

		self._setup_ui()
		self._center_on_screen()

	def _setup_ui(self) -> None:
		"""Tworzy interfejs użytkownika."""
		tabs = QTabWidget()
		tabs.setTabPosition(QTabWidget.TabPosition.North)

		tabs.addTab(self._create_tab('Dodaj'), 'Dodaj')
		tabs.addTab(self._create_tab('Szukaj'), 'Szukaj')
		tabs.addTab(self._create_tab('Przeglądaj'), 'Przeglądaj')
		tabs.addTab(self._create_tab('Statystyki'), 'Statystyki')
		tabs.addTab(self._create_tab('Logi'), 'Logi')
		tabs.addTab(self._create_tab('Ustawienia'), 'Ustawienia')

		self.setCentralWidget(tabs)

	def _create_tab(self, name: str) -> QWidget:
		"""Tworzy pustą zakładkę placeholder."""
		tab = QWidget()
		return tab

	def _center_on_screen(self) -> None:
		"""Centruje okno na ekranie."""
		screen = self.screen()
		geo = screen.geometry()
		x = (geo.width() - self.width()) // 2
		y = (geo.height() - self.height()) // 2
		self.move(x, y)


__all__ = ['MainWindow']