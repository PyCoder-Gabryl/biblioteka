# =============================================================================
# run.mk - Uruchamianie aplikacji
# Ścieżka: MakeLib/run.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Uruchamianie głównego skryptu w różnych trybach.
# Wymagania: .venv, Python.
# =============================================================================

VENV_PYTHON := .venv/bin/python
MAIN_MODULE := bibliotka.main

.PHONY: run run-dev run-debug

run: ## ▶️  Uruchamia aplikację
	@if [ ! -f "$(VENV_PYTHON)" ]; then \
		echo "❌ Brak .venv! Uruchom: make upgrade-pip"; \
		exit 1; \
	fi
	@echo "▶️  Uruchamiam bibliotka..."
	@$(VENV_PYTHON) -m $(MAIN_MODULE)

run-dev: ## 🔧 Uruchamia w trybie developerskim (verbose)
	@if [ ! -f "$(VENV_PYTHON)" ]; then \
		echo "❌ Brak .venv! Uruchom: make upgrade-pip"; \
		exit 1; \
	fi
	@echo "🔧 Tryb DEV..."
	@BIBLIOTKA_DEBUG=1 $(VENV_PYTHON) -m $(MAIN_MODULE) -v

run-debug: ## 🐛 Uruchamia z debuggerem (pdb)
	@if [ ! -f "$(VENV_PYTHON)" ]; then \
		echo "❌ Brak .venv! Uruchom: make upgrade-pip"; \
		exit 1; \
	fi
	@echo "🐛 Tryb DEBUG (pdb)..."
	@$(VENV_PYTHON) -m pdb -m $(MAIN_MODULE)
