# =============================================================================
# tree.mk - Wizualizacja struktury projektu
# Ścieżka: MakeLib/tree.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Wyświetlanie drzewa katalogów bez śmieci i cache.
# Wymagania: tree.
# =============================================================================

.PHONY: tree

tree: ## 📂 Pokazuje strukturę projektu (bez śmieci i cache)
	@clear
	@echo "📂 STRUKTURA PROJEKTU:"
	@tree -I "__pycache__|.venv|.git|.pytest_cache|*.egg-info|user_data*|GrShaderCache|ShaderCache" \
		  --dirsfirst \
		  -F
