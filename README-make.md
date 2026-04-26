# 📋 Dokumentacja poleceń Make

System automatyzacji projektu **Bibliotka** oparty na modułach Make.

## Szybki start

```bash
make help    # Lista wszystkich poleceń
make menu    # Interaktywne menu (fzf)
```

---

## 📂 Moduły

### Makefile (główny)

| Polecenie   | Opis                                      |
|-------------|-------------------------------------------|
| `make menu` | 🎯 Interaktywne menu wyboru poleceń (fzf) |
| `make help` | 📋 Wyświetla pomoc pogrupowaną sekcjami   |

---

### git.mk — Zarządzanie Git

| Polecenie         | Opis                                   |
|-------------------|----------------------------------------|
| `make git-init`   | 🔧 Inicjalizuje repozytorium Git       |
| `make git-status` | 📊 Pokazuje status repozytorium        |
| `make git-clean`  | 🧹 Lista plików do usunięcia (dry-run) |

---

### github.mk — Integracja z GitHub

| Polecenie              | Opis                                                 |
|------------------------|------------------------------------------------------|
| `make github-init`     | 🚀 Pełna inicjalizacja: git + GitHub + pierwszy push |
| `make github-create`   | 📦 Tylko tworzy repo na GitHub (bez push)            |
| `make github-push`     | ⬆️ Commit wszystkich zmian i push                    |
| `make github-status`   | 📊 Status repo (local + GitHub)                      |
| `make github-open`     | 🌐 Otwiera repo w przeglądarce                       |
| `make github-issues`   | 🐛 Otwiera issues w przeglądarce                     |
| `make github-prs`      | 🔀 Otwiera pull requests w przeglądarce              |
| `make github-actions`  | ⚙️ Otwiera GitHub Actions w przeglądarce             |
| `make github-settings` | 🔧 Otwiera ustawienia repo w przeglądarce            |

**Opcje:**

```bash
make github-init REPO_VISIBILITY=public   # Publiczne repo (domyślnie: private)
make github-init PROJECT_NAME=inna-nazwa  # Inna nazwa repo
```

**Wymagania:** `gh` (GitHub CLI) zainstalowane i zalogowane (`gh auth login`)

---

### python.mk — Zarządzanie Pythonem

| Polecenie                    | Opis                                        |
|------------------------------|---------------------------------------------|
| `make upgrade-system-python` | 🐍 Instalacja i aktualizacja wersji Pythona |
| `make python-check`          | 🔍 Sprawdzanie wersji Pythona w systemie    |
| `make switch-project-python` | 🔄 Przełączanie wersji Pythona dla projektu |

**Wymagania:** `pyenv`

---

### run.mk — Uruchamianie aplikacji

| Polecenie        | Opis                                          |
|------------------|-----------------------------------------------|
| `make run`       | ▶️ Uruchamia aplikację                        |
| `make run-dev`   | 🔧 Uruchamia w trybie developerskim (verbose) |
| `make run-debug` | 🐛 Uruchamia z debuggerem (pdb)               |

**Wymagania:** `.venv` (uruchom `make upgrade-pip` jeśli brak)

---

### test.mk — Testowanie i jakość kodu

| Polecenie         | Opis                                             |
|-------------------|--------------------------------------------------|
| `make test`       | 🧪 Uruchamia wszystkie testy                     |
| `make test-cov`   | 📊 Testy z raportem coverage (HTML w `htmlcov/`) |
| `make test-watch` | 👀 Testy w trybie watch (auto-restart)           |
| `make test-fast`  | ⚡ Szybkie testy (bez `@pytest.mark.slow`)        |
| `make lint`       | 🔍 Sprawdza kod (ruff)                           |
| `make lint-fix`   | 🔧 Naprawia problemy w kodzie (ruff)             |
| `make typecheck`  | 🏷️ Sprawdza typy (mypy)                         |

**Wymagania:** `pytest`, `pytest-cov`, `pytest-watch`, `ruff`, `mypy`

---

### release.mk - Zarządzanie wersjami

| Polecenie         | Opis                                                     |
|-------------------|----------------------------------------------------------|
| `make version`    | 📌 Pokazuje aktualną wersję                              |
| `make bump-patch` | 📦 Bump patch: 1.0.0 → 1.0.1 (bugfixy)                   |
| `make bump-minor` | 🚀 Bump minor: 1.0.0 → 1.1.0 (nowe funkcje)              |
| `make bump-major` | 💥 Bump major: 1.0.0 → 2.0.0 (breaking changes)          |
| `make tag`        | 🏷️ Tworzy git tag z aktualnej wersji                    |
| `make changelog`  | 📝 Generuje CHANGELOG.md z commitów                      |
| `make release`    | 🎉 Pełne wydanie: bump + changelog + commit + tag + push |

**Workflow wydania:**

```bash
make release         # Interaktywnie pyta o typ (patch/minor/major)
# lub ręcznie:
make bump-minor      # Podbij wersję
make changelog       # Wygeneruj CHANGELOG
make tag             # Utwórz tag
git push --tags      # Wyślij
```

---

### tree.mk - Struktura projektu

| Polecenie   | Opis                                                |
|-------------|-----------------------------------------------------|
| `make tree` | 📂 Pokazuje strukturę projektu (bez cache i śmieci) |

**Wymagania:** `tree`

---

### upgrade_pip.mk - Aktualizacja zależności

| Polecenie          | Opis                                                  |
|--------------------|-------------------------------------------------------|
| `make upgrade-pip` | 🔄 Aktualizuje pip, setuptools, wheel + deps projektu |

Używa `uv` jeśli dostępne (szybsze), fallback na `pip`.

---

## 🗂️ Struktura MakeLib

```
MakeLib/
├── git.mk          # Zarządzanie Git
├── github.mk       # Integracja z GitHub
├── python.mk       # Zarządzanie Pythonem
├── release.mk      # Wersjonowanie i wydania
├── run.mk          # Uruchamianie aplikacji
├── test.mk         # Testy i jakość kodu
├── tree.mk         # Wizualizacja struktury
├── upgrade_pip.mk  # Aktualizacja zależności
└── zsh/            # Skrypty pomocnicze
```

---

## 💡 Wskazówki

1. **Pierwszy raz?** Uruchom `make menu` i wybierz polecenie strzałkami
2. **Nowy projekt?** `make github-init` zrobi wszystko za Ciebie
3. **Przed commitem:** `make lint` sprawdzi kod
4. **Release:** `make release` przeprowadzi przez cały proces
