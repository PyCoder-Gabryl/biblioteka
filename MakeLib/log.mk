# =============================================================================
# log.mk - Polecenia logowania
# Ścieżka: MakeLib/log.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Polecenia do przeglądania logów.
# Wymagania: lnav (opcjonalnie).
# =============================================================================

PROJECT_ROOT := .
LOG_FILE := $(PROJECT_ROOT)/logs/app.log.json

.PHONY: log-view log-tail log-clear

log-view: ## 📜 Otwiera logi w lnav (log viewer)
	@if command -v lnav >/dev/null 2>&1; then \
		lnav $(LOG_FILE); \
	else \
		echo "❌ lnav nie zainstalowany!"; \
		echo "💡 Zainstaluj: brew install lnav"; \
		exit 1; \
	fi

log-tail: ## 📜 Pokazuje ostatnie 20 linii logów
	@tail -20 $(LOG_FILE)

log-clear: ## 🗑️ Czyści pliki logów
	@rm -f $(LOG_FILE)
	@echo "✅ Logi wyczyszczone"