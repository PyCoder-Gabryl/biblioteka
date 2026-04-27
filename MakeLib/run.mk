# =============================================================================
# run.mk - Uruchamianie aplikacji
# Ścieżka: MakeLib/run.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Uruchamianie głównego skryptu w różnych trybach.
# Wymagania: .venv, Python.
# =============================================================================

UV := uv
MAIN_MODULE := biblioteka.main

.PHONY: run run-dev run-debug

run: ## ▶️  Uruchamia aplikację
	@echo "▶️  Uruchamiam bibliotka..."
	@$(UV) run python -m $(MAIN_MODULE)

run-dev: ## 🔧 Uruchamia w trybie developerskim (verbose)
	@echo "🔧 Tryb DEV..."
	@$(UV) run python -m $(MAIN_MODULE) -v

run-debug: ## 🐛 Uruchamia z debuggerem (pdb)
	@echo "🐛 Tryb DEBUG (pdb)..."
	@$(UV) run pdb -m $(MAIN_MODULE)
