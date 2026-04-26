# =============================================================================
# upgrade_pip.mk - Aktualizacja Pip, Setuptools i Deps
# Ścieżka: MakeLib/upgrade_pip.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Upgrade pip, pipx, setuptools + sync deps projektu (.venv).
# Wymagania: .venv (z upgrade_python.mk), pyenv.
# =============================================================================

PYENV_VERSION_FILE := .python-version
VENV_DIR := .venv

.PHONY: upgrade-pip

upgrade-pip: ## 🔄 Aktualizuje pip, setuptools, wheel + deps projektu [Szybkie z uv]
	@echo "\n🚀 Rozpoczynamy upgrade Pip i deps..."
	@clear

	# 0. Aktywacja env (pyenv + venv)
	@if [ -f "$(PYENV_VERSION_FILE)" ]; then \
		source "$(PYENV_VERSION_FILE)"; \
		echo "✅ Pyenv: $$(pyenv version-name 2>/dev/null || echo 'default')"; \
	fi
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "❌ Brak .venv! Uruchom: make upgrade-python"; \
		exit 1; \
	fi
	source $(VENV_DIR)/bin/activate || { echo "❌ Błąd aktywacji venv"; exit 1; }

	# 1. Upgrade pip + core (uv jeśli dostępne, fallback pip)
	@if command -v uv >/dev/null 2>&1; then \
		echo "⚡ Używamy UV (szybkie) do upgrade..."; \
		uv pip install --upgrade pip setuptools wheel; \
	else \
		echo "📦 Standardowy pip upgrade..."; \
		python -m pip install --upgrade pip setuptools wheel; \
	fi

	# 2. Upgrade pipx (global tools: black, hatch itp.)
	@if command -v pipx >/dev/null 2>&1; then \
		echo "🔄 Upgrade pipx..."; \
		pipx upgrade-all || pipx ensurepath; \
	else \
		echo "📥 Instalujemy pipx..."; \
		python -m pip install --user pipx; \
		python -m pipx ensurepath; \
	fi

	# 3. Sync deps projektu (pyproject.toml lub requirements.txt)
	@echo "📦 Sync deps (upgrade packages)..."
	@if command -v uv >/dev/null 2>&1; then \
		uv sync --upgrade-package "*" --frozen; \
	else \
		python -m pip install --upgrade -e . || python -m pip install -e .; \
	fi

	# 4. Czyszczenie cache (opcjonalne, szybkie)
	@echo "🧹 Czyszczenie pip cache..."
	python -m pip cache purge || true

	# 5. Potwierdzenie
	deactivate
	echo "\n🎉 Pip upgrade zakończony!"
	echo "   Pip: $$(.venv/bin/pip --version | cut -d' ' -f2)"
	echo "   Python: $$(.venv/bin/python --version)"
	echo "💡 Aktywuj: source .venv/bin/activate && hatch env create"
	@echo "💡 Sprawdź deps: uv pip list | pip list"
