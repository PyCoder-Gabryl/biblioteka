#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              biblioteka/src/biblioteka/main.py
#
#   WERSJA:             0.2 [04-27]
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

from biblioteka import __about__
from biblioteka.logging.logger import get_logger

log = get_logger(__name__)


def main() -> None:
	"""Uruchamia aplikację biblioteki."""
	log.info(
		"start aplikacji",
		app=__about__.__app_name__,
		version=__about__.__version__,
		started_at=datetime.now().isoformat(),
	)


if __name__ == '__main__':
	main()
