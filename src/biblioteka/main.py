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

from biblioteka import __about__
from biblioteka.logging.logger import get_logger

log = get_logger(__name__)


def main() -> None:
	"""Uruchamia aplikację biblioteki."""
	log.info(
		'start aplikacji',
		version=__about__.__version__,
	)


if __name__ == '__main__':
	main()
