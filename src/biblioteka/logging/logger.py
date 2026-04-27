#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              src/biblioteka/logging/logger.py
#
#   WERSJA:             0.5 [04-27]
#   Data utworzenia:    2026 kwiecień 27, 00:00
#
#   COPYRIGHT:          2026 PyGamiQ <pygamiq@gmail.com>
#   LICENCJA:           MIT
#
#   AUTOR:              PyGamiQ
#   GITHUB:             https://github.com/PyGamiQ/bibliotka
#   IDE:                PyCharm Python 3.14.4 <macOS ARM>
# ==========================================================================================
#   OPIS:
#       Konfiguracja structlog z rotacją plików logów.
#       Konsola: rich, Plik: JSON zawsze.
# ==========================================================================================

import json
import logging
import shutil
import sys
from datetime import datetime, timedelta
from pathlib import Path

import structlog
from structlog import PrintLoggerFactory
from structlog.dev import ConsoleRenderer
from structlog.processors import StackInfoRenderer, TimeStamper, format_exc_info
from structlog.types import Processor

from dataclasses import dataclass

from biblioteka.config.settings import get_project_root, load_settings


@dataclass(slots=True)
class RotatingLogHandler:
	"""Handler rotujący pliki logów."""

	log_file: Path
	backup_dir: Path
	max_files: int = 100
	max_days: int = 14

	def rotate(self) -> None:
		"""Rotuje plik logów do katalogu backup."""
		if self.log_file.exists():
			timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
			backup_path = self.backup_dir / f'app_{timestamp}.json'
			shutil.move(str(self.log_file), str(backup_path))

	def clean_old(self) -> None:
		"""Czyści stare pliki logów."""
		if not self.backup_dir.exists():
			return

		files = sorted(self.backup_dir.glob('app_*.json'))
		if len(files) > self.max_files:
			for f in files[: -self.max_files]:
				f.unlink()

		cutoff = datetime.now() - timedelta(days=self.max_days)
		for f in self.backup_dir.glob('app_*.json'):
			mtime = datetime.fromtimestamp(f.stat().st_mtime)
			if mtime < cutoff:
				f.unlink()


_log_file: Path | None = None


def _write_json(processor: Processor, method: str, event_dict: dict) -> dict:
	"""Zapisuje log do pliku JSON.

	Args:
		processor: Procesor structlog.
		method: Metoda logowania (info, error, etc).
		event_dict: Słownik z danymi logowania.

	Returns:
		Niezmodyfikowany event_dict.
	"""
	global _log_file
	if _log_file:
		with open(_log_file, 'a', encoding='utf-8') as f:
			f.write(json.dumps(event_dict) + '\n')
	return event_dict


def configure_logging() -> None:
	"""Konfiguruje structlog z rotacją plików."""
	global _log_file

	project_root = get_project_root()
	settings = load_settings()

	log_path = project_root / settings.logging.file.path
	backup_dir = project_root / settings.logging.file.backup_dir

	log_path.parent.mkdir(parents=True, exist_ok=True)
	backup_dir.mkdir(exist_ok=True)

	handler = RotatingLogHandler(
		log_path,
		backup_dir,
		settings.logging.rotation.max_backup_files,
		settings.logging.rotation.max_backup_days,
	)
	handler.rotate()

	_log_file = log_path

	log_level = getattr(logging, settings.logging.level, logging.INFO)

	console_renderer = ConsoleRenderer(
		colors=True,
	)

	processors = [
		structlog.contextvars.merge_contextvars,
		structlog.processors.add_log_level,
		TimeStamper(fmt='iso', utc=True),
		StackInfoRenderer(),
		format_exc_info,
		_write_json,
		console_renderer,
	]

	structlog.configure(
		processors=processors,
		wrapper_class=structlog.make_filtering_bound_logger(log_level),
		context_class=dict,
		logger_factory=PrintLoggerFactory(file=sys.stderr),
		cache_logger_on_first_use=True,
	)


def get_logger(name: str | None = None) -> structlog.BoundLogger:
	"""Zwraca skonfigurowany logger.

	Args:
		name: Opcjonalna nazwa loggera (np. __name__ modułu).

	Returns:
		Skonfigurowany logger structlog.
	"""
	configure_logging()

	logger = structlog.get_logger()
	if name:
		logger = logger.bind(logger=name)

	return logger


__all__ = ['RotatingLogHandler', 'configure_logging', 'get_logger']