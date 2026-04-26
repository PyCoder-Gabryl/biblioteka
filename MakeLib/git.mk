# =============================================================================
# git.mk - Inicjalizacja i zarządzanie Git
# Ścieżka: MakeLib/git.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Inicjalizacja repo, status, czyszczenie.
# =============================================================================

.PHONY: git-init git-status git-clean

git-init: ## 🔧 Inicjalizuje repozytorium Git
	@if [ -d .git ]; then \
		echo "✅ Git już zainicjalizowany"; \
	else \
		git init; \
		echo "✅ Repozytorium Git zainicjalizowane"; \
	fi

git-status: ## 📊 Pokazuje status repozytorium
	@git status

git-clean: ## 🧹 Lista plików do usunięcia (dry-run)
	@git clean -n -d
