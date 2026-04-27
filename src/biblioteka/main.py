#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              biblioteka/src/biblioteka/main.py
#
#   WERSJA:             0.4 [04-27]
#   Data utworzenia:    2026 kwiecień 26, 06:56
#
#   COPYRIGHT:          2026 PyGamiQ <pygamiq@gmail.com>
#   LICENCJA:           MIT
#
#   AUTOR:              PyGamiQ
#   GITHUB:             https://github.com/PyGamiQ/bibliotka
#   IDE:                PyCharm Python 3.14.4 <macOS ARM>
# ==========================================================================================
#   OPIS:
#       Główny moduł aplikacji biblioteki.
# ==========================================================================================

import sys
from datetime import datetime
from pathlib import Path

from PySide6.QtWidgets import QApplication

from biblioteka import __about__
from biblioteka.logging.logger import get_logger
from biblioteka.ui.main_window import MainWindow

log = get_logger(__name__)


def _check_previous_session() -> None:
	"""Sprawdza, czy poprzednia sesja zakończyła się poprawnie."""
	log_file = Path('logs/app.log.json')
	if not log_file.exists():
		return

	content = log_file.read_text(encoding='utf-8')
	if '"event": "end aplikacji"' not in content and '"event": "start aplikacji"' in content:
		log.warning('poprzednia-sesja-przerwana', reason='brak logu zakończenia')


def _setup_global_exception_handler() -> None:
	"""Ustawia globalny handler wyjątków."""

	def handle_exception(exc_type: type, exc_value: BaseException, exc_tb: object) -> None:
		if issubclass(exc_type, KeyboardInterrupt):
			log.warning('przerwane-przez-uzytkownika')
			return
		log.critical(
			'nieobsluzony-wyjątek',
			exc_type=exc_type.__name__,
			exc_value=str(exc_value),
		)

	import sys
	sys.excepthook = handle_exception


def main() -> None:
	"""Uruchamia aplikację biblioteki."""
	_setup_global_exception_handler()
	_check_previous_session()

	log.info(
		'start aplikacji',
		app=__about__.__app_name__,
		version=__about__.__version__,
		started_at=datetime.now().isoformat(),
	)

	app = QApplication(sys.argv)
	app.setApplicationName('bibliotka')

	window = MainWindow()
	window.show()

	try:
		sys.exit(app.exec())
	except SystemExit:
		pass  # noqa: PLR1722
	except Exception as e:
		log.error('blad-aplikacji', exc=str(e))
		raise
	finally:
		log.info(
			'end aplikacji',
			ended_at=datetime.now().isoformat(),
		)


if __name__ == '__main__':
	main()
