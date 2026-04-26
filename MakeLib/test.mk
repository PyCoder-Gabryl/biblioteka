# =============================================================================
# test.mk - Testowanie aplikacji
# Ścieżka: MakeLib/test.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Uruchamianie testów pytest, coverage, linting.
# Wymagania: .venv, pytest, ruff.
# =============================================================================

VENV_PYTHON := .venv/bin/python
TESTS_DIR := tests

.PHONY: test test-cov test-watch test-fast lint lint-fix typecheck

test: ## 🧪 Uruchamia wszystkie testy
	@echo "🧪 Uruchamiam testy..."
	@$(VENV_PYTHON) -m pytest $(TESTS_DIR) -v

test-cov: ## 📊 Testy z raportem coverage
	@echo "📊 Testy + coverage..."
	@$(VENV_PYTHON) -m pytest $(TESTS_DIR) -v --cov=src/bibliotka --cov-report=term-missing --cov-report=html
	@echo "📁 Raport HTML: htmlcov/index.html"

test-watch: ## 👀 Testy w trybie watch (pytest-watch)
	@echo "👀 Tryb watch - testy uruchomią się po każdej zmianie..."
	@$(VENV_PYTHON) -m pytest_watch $(TESTS_DIR)

test-fast: ## ⚡ Szybkie testy (bez slow markers)
	@echo "⚡ Szybkie testy..."
	@$(VENV_PYTHON) -m pytest $(TESTS_DIR) -v -m "not slow"

lint: ## 🔍 Sprawdza kod (ruff)
	@echo "🔍 Linting..."
	@$(VENV_PYTHON) -m ruff check src/bibliotka $(TESTS_DIR)
	@$(VENV_PYTHON) -m ruff format --check src/bibliotka $(TESTS_DIR)
	@echo "✅ Kod OK!"

lint-fix: ## 🔧 Naprawia problemy w kodzie (ruff)
	@echo "🔧 Auto-fix..."
	@$(VENV_PYTHON) -m ruff check --fix src/bibliotka $(TESTS_DIR)
	@$(VENV_PYTHON) -m ruff format src/bibliotka $(TESTS_DIR)
	@echo "✅ Naprawiono!"

typecheck: ## 🏷️  Sprawdza typy (mypy)
	@echo "🏷️  Type checking..."
	@$(VENV_PYTHON) -m mypy src/bibliotka
