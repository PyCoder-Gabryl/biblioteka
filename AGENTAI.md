# 🤖 AGENTAI.md — Wytyczne dla AI

> **WAŻNE:** Sprawdź ten plik na początku każdej sesji pracy z projektem!

---

## 📑 Spis treści

1. [Projekt](#1-projekt)
2. [Środowisko](#2-środowisko)
3. [Zasady budowania kodu Python](#3-zasady-budowania-kodu-python)
4. [Nagłówki plików Python](#4-nagłówki-plików-python)
5. [Pliki MakeLib](#5-pliki-makelib)
6. [Git - zasady commitow](#6-git---zasady-commitow)
7. [Przed pisaniem kodu](#7-przed-pisaniem-kodu)
8. [Po napisaniu kodu](#8-po-napisaniu-kodu)

---

## 1. Projekt

- **Nazwa:** Bibliotka (desktopowy katalog biblioteczny)
- **Python:** 3.14
- **GUI:** PySide6
- **Baza:** DuckDB
- **Struktura:** `src/biblioteka/`
- **Wersja:** `src/biblioteka/__about__.py`
- **WAŻNE:** Sekcja `dependencies` w `pyproject.toml` musi być **OSTATNIĄ** sekcją przed `[project.urls]`

---

## 2. Środowisko

- `hatch` - zarządzanie środowiskiem
- `ruff check .` - linting
- `ruff format .` - formatowanie
- `mypy .` - sprawdzanie typów
- `pytest .` - testy

---

## 3. Zasady budowania kodu Python

### Klasy

- Używaj `@dataclass` do tworzenia klas
- Jeśli możliwe, stosuj `__slots__`
- **Jeden plik = jedna klasa**

### Nazewnictwo

| Element    | Język     | Przykład                            |
|------------|-----------|-------------------------------------|
| Klasy      | angielski | `BookScanner`, `DatabaseManager`    |
| Metody     | angielski | `scan_barcode()`, `get_book_info()` |
| Zmienne    | angielski | `book_title`, `scan_result`         |
| Komentarze | polski    | `# Pobiera dane z API`              |

### Struktura kodu

- Rozbijaj duże metody na mniejsze (~20 linii max.)
- Każda metoda robi jedną rzecz
- Nazwy metod opisują co robią
- Każdy plik musi mieć zdefiniowany `__all__`

### Typy

- **ZAWSZE stosuj adnotacje typów** (Python 3.14 to obsługuje native)
- Używaj adnotacji w kodzie (`def foo(x: int) -> str:`)
- Unikaj type comments (`# type: int`)
- Dla złożonych typów używaj `typing` lub `types`

### Liczby magiczne

- NIE używaj liczb magicznych w kodzie
- Zmienne liczbowe zapisuj w klasach konfiguracyjnych (stłe) lub dataclasach
- Jeśli potrzeba, używaj klas z `enum` do definiowania stałych wartości
- Klasy konfiguracyjne służą do konfiguracji zachowań klas

### Logowanie

- Używaj `structlog`
- Konsola: `rich` (kolorowe, czytelne)
- Plik: `logs/*.json` (strukturalne)

---

## 4. Nagłówki plików Python

### Każdy plik .py musi mieć nagłówek:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==========================================================================================
#   PROJEKT:            biblioteka
#   MODUŁ:              ścieżka/do/pliku.py
#
#   WERSJA:             x.x [MM-DD]
#   Data utworzenia:    RRRR miesiąc DD, HH:MM
#
#   COPYRIGHT:          RRRR PyGamiQ <pygamiq@gmail.com>
#   LICENCJA:           MIT
#
#   AUTOR:              PyGamiQ
#   GITHUB:             https://github.com/PyGamiQ/bibliotka
#   IDE:                PyCharm Python 3.14.4 <macOS ARM>
# ==========================================================================================
#   OPIS:
#       - Krótki opis co robi moduł
#
#   CHANGELOG:
#       - x.x (DD mmm RRRR) - opis zmian
# ==========================================================================================
```

### Wersjonowanie plików:

| Wersja  | Kiedy                                       |
|---------|---------------------------------------------|
| `x.x.x` | Mało istotne zmiany (poprawki, drobne fixy) |
| `x.x`   | Istotne zmiany (nowe funkcje, refaktor)     |
| `1.0`   | Program działa kompletnie                   |

---

## 5. Pliki MakeLib

### Nagłówek każdego pliku .mk:

```makefile
# =============================================================================
# nazwa.mk - Krótki opis
# Ścieżka: MakeLib/nazwa.mk
# =============================================================================
# Automatycznie importowany przez Makefile.
# Zadanie: Co robi ten moduł.
# Wymagania: Zależności.
# =============================================================================
```

### Targety z opisem dla `make help`:

```makefile
target-name: ## 🎯 Opis widoczny w make help
	@polecenie
```

---

## 6. Git - zasady commitow

### Gdy użytkownik powie "wykonaj git" lub "zrób gita":

1. Zrób `git add` odpowiednich plików
2. Commit z **tematem i dokładnym opisem** (co, dlaczego, szczegóły)
3. Wykonaj `git push`

### Gdy tworzysz nowy plik:

1. Po utworzeniu pliku **automatycznie** wykonaj git + push
2. Commit z dokładnym opisem co zawiera nowy plik

### Format commitów:

```
<emoji> <typ>(<zakres>): krótki opis

Szczegółowy opis:
- co zostało dodane/zmienione
- dlaczego
- lista zmian jeśli więcej niż jedna
```

**Emoji i typy:**

- ✨ `feat` - nowa funkcjonalność
- 🐛 `fix` - naprawa błędu
- 📚 `docs` - dokumentacja
- 🔧 `chore` - konfiguracja, maintenance
- ♻️ `refactor` - refaktoryzacja
- 🎨 `style` - formatowanie, styl kodu

---

## 7. Przed pisaniem kodu

**ZAWSZE przed implementacją:**

1. **Omów teorię** — wyjaśnij podejście, architekturę
2. **Zadaj pytania uzupełniające** — upewnij się, że rozumiesz wymagania
3. **Pokaż słabe strony** — co może pójść nie tak, ograniczenia
4. **Zaproponuj alternatywy** — inne rozwiązania, ulepszenia

Dopiero po akceptacji użytkownika → pisz kod.

---

## 8. Po napisaniu kodu

1. `ruff check . && ruff format .` - linting i formatowanie
2. `mypy .` - sprawdzanie typów
3. `pytest .` - testy
4. Pokaż wyniki
