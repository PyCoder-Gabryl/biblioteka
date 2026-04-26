# =============================================================================
# release.mk - Zarządzanie wersjami i wydaniami
# Ścieżka: MakeLib/release.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Bump wersji, tagi, changelog.
# Wymagania: git, python, pyproject.toml z wersją.
# =============================================================================

VERSION_FILE := src/bibliotka/__about__.py
CHANGELOG := CHANGELOG.md

.PHONY: version bump-patch bump-minor bump-major release changelog tag

version: ## 📌 Pokazuje aktualną wersję
	@grep -oP '(?<=__version__ = ")[^"]+' $(VERSION_FILE) || \
		grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2

bump-patch: ## 📦 Bump patch: 1.0.0 → 1.0.1
	@echo "📦 Bump patch..."
	@$(eval CURRENT := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@$(eval NEW := $(shell echo $(CURRENT) | awk -F. '{print $$1"."$$2"."$$3+1}'))
	@sed -i '' 's/__version__ = "$(CURRENT)"/__version__ = "$(NEW)"/' $(VERSION_FILE)
	@echo "✅ $(CURRENT) → $(NEW)"

bump-minor: ## 🚀 Bump minor: 1.0.0 → 1.1.0
	@echo "🚀 Bump minor..."
	@$(eval CURRENT := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@$(eval NEW := $(shell echo $(CURRENT) | awk -F. '{print $$1"."$$2+1".0"}'))
	@sed -i '' 's/__version__ = "$(CURRENT)"/__version__ = "$(NEW)"/' $(VERSION_FILE)
	@echo "✅ $(CURRENT) → $(NEW)"

bump-major: ## 💥 Bump major: 1.0.0 → 2.0.0
	@echo "💥 Bump major..."
	@$(eval CURRENT := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@$(eval NEW := $(shell echo $(CURRENT) | awk -F. '{print $$1+1".0.0"}'))
	@sed -i '' 's/__version__ = "$(CURRENT)"/__version__ = "$(NEW)"/' $(VERSION_FILE)
	@echo "✅ $(CURRENT) → $(NEW)"

tag: ## 🏷️  Tworzy git tag z aktualnej wersji
	@$(eval VER := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@echo "🏷️  Tworzę tag v$(VER)..."
	@git tag -a "v$(VER)" -m "Release v$(VER)"
	@echo "✅ Tag v$(VER) utworzony"

changelog: ## 📝 Generuje CHANGELOG z commitów
	@echo "📝 Generuję CHANGELOG..."
	@$(eval VER := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@$(eval DATE := $(shell date +%Y-%m-%d))
	@$(eval LAST_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo ""))
	@if [ -z "$(LAST_TAG)" ]; then \
		COMMITS=$$(git log --pretty=format:"- %s" --no-merges); \
	else \
		COMMITS=$$(git log $(LAST_TAG)..HEAD --pretty=format:"- %s" --no-merges); \
	fi; \
	if [ -f $(CHANGELOG) ]; then \
		echo "## [$(VER)] - $(DATE)\n\n$$COMMITS\n\n$$(cat $(CHANGELOG))" > $(CHANGELOG); \
	else \
		echo "# Changelog\n\n## [$(VER)] - $(DATE)\n\n$$COMMITS" > $(CHANGELOG); \
	fi
	@echo "✅ CHANGELOG zaktualizowany"

release: ## 🎉 Pełne wydanie: bump + changelog + commit + tag + push
	@echo "🎉 Przygotowuję release..."
	@read -p "Typ (patch/minor/major): " type; \
	$(MAKE) bump-$$type
	@$(MAKE) changelog
	@$(eval VER := $(shell grep -o '__version__ = "[^"]*"' $(VERSION_FILE) | cut -d'"' -f2))
	@git add $(VERSION_FILE) $(CHANGELOG)
	@git commit -m "🔖 release: v$(VER)"
	@$(MAKE) tag
	@echo ""
	@read -p "Push do GitHub? (y/n): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		git push && git push --tags; \
		echo "✅ Release v$(VER) opublikowany!"; \
	else \
		echo "⏸️  Lokalne zmiany gotowe. Push: git push && git push --tags"; \
	fi
