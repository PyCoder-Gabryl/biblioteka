#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              src/biblioteka/config/settings.py
#
#   WERSJA:             0.1 [04-27]
#   Data utworzenia:    2026 kwiecień 27, 12:00
#
#   COPYRIGHT:          2026 PyGamiQ <pygamiq@gmail.com>
#   LICENCJA:           MIT
#
#   AUTOR:              PyGamiQ
#   GITHUB:             https://github.com/PyGamiQ/bibliotka
#   IDE:                PyCharm Python 3.14.4 <macOS ARM>
# ==========================================================================================
#   OPIS:
#       Walidacja i parsowanie konfiguracji aplikacji.
#       Używa Pydantic do walidacji i python-dotenv.
# ==========================================================================================

from pathlib import Path

import tomli
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class LoggingFileConfig(BaseModel):
    """Konfiguracja pliku logów."""

    path: str = "logs/app.log.json"
    backup_dir: str = "logs/backup"


class LoggingRotationConfig(BaseModel):
    """Konfiguracja rotacji logów."""

    max_backup_files: int = 100
    max_backup_days: int = 14


class LoggingConfig(BaseModel):
    """Konfiguracja logowania."""

    level: str = "INFO"
    file: LoggingFileConfig = Field(default_factory=LoggingFileConfig)
    rotation: LoggingRotationConfig = Field(default_factory=LoggingRotationConfig)


class DatabaseConfig(BaseModel):
    """Konfiguracja bazy danych."""

    path: str = "data/biblioteka.db"


class ApiBnConfig(BaseModel):
    """Konfiguracja API BN (Biblioteka Narodowa)."""

    base_url: str = "https://data.bn.org.pl/api"


class ApiFbcConfig(BaseModel):
    """Konfiguracja API FBC (Federacja Bibliotek Cyfrowych)."""

    base_url: str = "https://fbc.pionier.net.pl"


class ApiConfig(BaseModel):
    """Konfiguracja API."""

    bn: ApiBnConfig = Field(default_factory=ApiBnConfig)
    fbc: ApiFbcConfig = Field(default_factory=ApiFbcConfig)


class UiConfig(BaseModel):
	"""Konfiguracja UI."""

	window_width: int = 1200
	window_height: int = 800
	dark_mode: bool = False


class PanelConfig(BaseModel):
	"""Konfiguracja panelu logów."""

	max_height_ratio: float = 0.2
	bg_color: str = '#000000'
	text_color: str = '#FFFFFF'


class AssetsConfig(BaseModel):
	"""Konfiguracja assetów."""

	fonts_dir: str = 'assets/fonts'
	images_dir: str = 'assets/images'
	audio_dir: str = 'assets/audio'


class AppConfig(BaseModel):
    """Konfiguracja aplikacji."""

    name: str = "biblioteka"
    version: str = "0.0.1"


class Settings(BaseSettings):
	"""Główne ustawienia aplikacji."""

	model_config = SettingsConfigDict(
		env_file=".env",
		env_file_encoding="utf-8",
		extra="ignore",
	)

	app: AppConfig = Field(default_factory=AppConfig)
	logging: LoggingConfig = Field(default_factory=LoggingConfig)
	database: DatabaseConfig = Field(default_factory=DatabaseConfig)
	api: ApiConfig = Field(default_factory=ApiConfig)
	ui: UiConfig = Field(default_factory=UiConfig)
	panel: PanelConfig = Field(default_factory=PanelConfig)
	assets: AssetsConfig = Field(default_factory=AssetsConfig)


def get_project_root() -> Path:
    """Zwraca ścieżkę do korzenia projektu."""
    return Path(__file__).parent.parent.parent.parent


def load_settings() -> Settings:
    """Laduje i waliduje ustawienia z pliku TOML."""
    project_root = get_project_root()
    settings_file = project_root / "settings" / "biblioteka.toml"

    if not settings_file.exists():
        return Settings()

    with open(settings_file, "rb") as f:
        data = tomli.load(f)

    env_file = project_root / ".venv_config"
    if env_file.exists():
        with open(env_file) as f:
            env_level = f.read().strip().upper()
            if env_level in ("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"):
                data.setdefault("logging", {})["level"] = env_level

    return Settings(**data)


__all__ = ["Settings", "get_project_root", "load_settings"]
