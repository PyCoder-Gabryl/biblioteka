#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              biblioteka/src/biblioteka/main.py
#
#   WERSJA:             0.3 [04-27]
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

from datetime import datetime
from pathlib import Path

from biblioteka import __about__
from biblioteka.logging.logger import get_logger

log = get_logger(__name__)


def _check_previous_session() -> None:
	"""Sprawdza, czy poprzednia sesja zakończyła się poprawnie."""
	log_file = Path('logs/app.log.json')
	if not log_file.exists():
		return

	content = log_file.read_text(encoding='utf-8')
	if '"event": "end aplikacji"' not in content and '"event": "start aplikacji"' in content:
		log.warning('poprzednia-sesja-przerwana', reason='brak logu zakończenia')


def main() -> None:
	"""Uruchamia aplikację biblioteki."""
	_check_previous_session()

	log.info(
		'start aplikacji',
		app=__about__.__app_name__,
		version=__about__.__version__,
		started_at=datetime.now().isoformat(),
	)

	try:
		pass  # TODO: główna logika aplikacji
	finally:
		log.info(
			'end aplikacji',
			ended_at=datetime.now().isoformat(),
		)


if __name__ == '__main__':
	main()
