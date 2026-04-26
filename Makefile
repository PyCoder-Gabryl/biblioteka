# =============================================================================
# Makefile - Główny Zarządca Systemu
# =============================================================================
SHELL := /bin/zsh
export TERM := xterm-256color
.DEFAULT_GOAL := help

# Import modułów - ważne, aby pliki .mk były w katalogu MakeLIB
-include MakeLib/*.mk

.PHONY: help menu

menu: ## 🎯 Interaktywne menu wyboru poleceń (fzf)
	@clear
	@target=$$(grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sed 's/:.*## /\t/' | \
		fzf --height=40% --reverse --border --prompt="Wybierz polecenie: " \
		    --preview='echo "Uruchomi: make {1}"' \
		    --preview-window=down:1 | \
		cut -f1); \
	if [ -n "$$target" ]; then \
		echo "▶ Uruchamiam: make $$target"; \
		$(MAKE) $$target; \
	fi

help: ## 📋 Wyświetla pomoc pogrupowaną sekcjami
	@clear
	@echo "🤖 Bibliotka Domowa"
	@echo "============================================================"
	@for file in $(MAKEFILE_LIST); do \
		if grep -q "##" $$file; then \
			printf "\n\033[1;33m📂 MODUŁ: %-30s\033[0m\n" $$(basename $$file); \
			grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $$file | \
			awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'; \
		fi; \
	done
	@echo "\n============================================================"
