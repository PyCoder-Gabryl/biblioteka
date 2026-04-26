# =============================================================================
# github.mk - Integracja z GitHub
# Ścieżka: MakeLib/github.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Tworzenie repo na GitHub, push, zarządzanie.
# Wymagania: gh (GitHub CLI), git.
# =============================================================================

# Nazwa projektu (z katalogu)
PROJECT_NAME ?= $(notdir $(CURDIR))
# Domyślnie prywatne repo
REPO_VISIBILITY ?= private

.PHONY: github-init github-create github-push github-status github-open

github-init: ## 🚀 Pełna inicjalizacja: git + GitHub + pierwszy push
	@echo "🚀 Inicjalizacja projektu na GitHub..."
	@echo ""
	@# 1. Sprawdź gh
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ Brak gh CLI! Zainstaluj: brew install gh"; \
		exit 1; \
	fi
	@# 2. Sprawdź logowanie
	@if ! gh auth status >/dev/null 2>&1; then \
		echo "❌ Niezalogowany! Uruchom: gh auth login"; \
		exit 1; \
	fi
	@# 3. Init git jeśli brak
	@if [ ! -d .git ]; then \
		echo "📁 Inicjalizacja git..."; \
		git init; \
	fi
	@# 4. Sprawdź czy repo już istnieje na GitHub
	@if gh repo view $(PROJECT_NAME) >/dev/null 2>&1; then \
		echo "⚠️  Repo '$(PROJECT_NAME)' już istnieje na GitHub"; \
		echo "   Ustawiam remote..."; \
		git remote remove origin 2>/dev/null || true; \
		gh repo view $(PROJECT_NAME) --json sshUrl -q .sshUrl | xargs git remote add origin; \
	else \
		echo "📦 Tworzę repo '$(PROJECT_NAME)' ($(REPO_VISIBILITY))..."; \
		gh repo create $(PROJECT_NAME) --$(REPO_VISIBILITY) --source=. --remote=origin; \
	fi
	@# 5. Pierwszy commit jeśli brak
	@if ! git rev-parse HEAD >/dev/null 2>&1; then \
		echo "📝 Pierwszy commit..."; \
		git add .; \
		git commit -m "🎉 Initial commit"; \
	fi
	@# 6. Push
	@echo "⬆️  Push do GitHub..."
	@git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || \
		(git branch -M main && git push -u origin main)
	@echo ""
	@echo "✅ Gotowe! Repo: https://github.com/$$(gh api user -q .login)/$(PROJECT_NAME)"

github-create: ## 📦 Tylko tworzy repo na GitHub (bez push)
	@echo "📦 Tworzę repo '$(PROJECT_NAME)'..."
	@gh repo create $(PROJECT_NAME) --$(REPO_VISIBILITY) --source=. --remote=origin
	@echo "✅ Repo utworzone!"

github-push: ## ⬆️  Commit wszystkich zmian i push
	@echo "⬆️  Push zmian..."
	@git add .
	@git status --short
	@read -p "Commit message: " msg; \
	git commit -m "$$msg" || echo "Brak zmian do commitowania"; \
	git push

github-status: ## 📊 Status repo (local + GitHub)
	@echo "📊 STATUS PROJEKTU: $(PROJECT_NAME)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📁 Local:"
	@git status --short || echo "   Brak repo git"
	@echo ""
	@echo "☁️  GitHub:"
	@gh repo view --json name,url,visibility,defaultBranchRef 2>/dev/null | \
		jq -r '"   Repo: \(.name)\n   URL: \(.url)\n   Visibility: \(.visibility)\n   Branch: \(.defaultBranchRef.name)"' \
		|| echo "   Brak repo na GitHub"

github-open: ## 🌐 Otwiera repo w przeglądarce
	@gh repo view --web

github-issues: ## 🐛 Otwiera issues w przeglądarce
	@gh issue list --web

github-prs: ## 🔀 Otwiera pull requests w przeglądarce
	@gh pr list --web

github-actions: ## ⚙️  Otwiera GitHub Actions w przeglądarce
	@open "$$(gh repo view --json url -q .url)/actions"

github-settings: ## 🔧 Otwiera ustawienia repo w przeglądarce
	@open "$$(gh repo view --json url -q .url)/settings"
