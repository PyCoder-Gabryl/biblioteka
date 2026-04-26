# =============================================================================
# python.mk - Zarządzanie wersjami Pythona
# Ścieżka: MakeLib/python.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Instalacja, upgrade i przełączanie wersji Pythona (pyenv).
# Wymagania: pyenv, zsh.
# =============================================================================

SHELL := /bin/zsh
export TERM ?= xterm-256color

.PHONY: upgrade-system-python python-check switch-project-python

upgrade-system-python: ## 🐍 Instalacja i aktualizacja wersji Pythona
	@/bin/zsh MakeLib/zsh/python.zsh

python-check: ## 🔍 Sprawdzanie wersji Pythona w systemie
	@/bin/sh MakeLib/zsh/system-python-upgrade.zsh

switch-project-python: ## 🔄 Przełączanie wersji Pythona dla projektu
	@/bin/zsh MakeLib/zsh/switch-python.zsh
