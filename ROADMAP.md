# 📚 Roadmapa: Desktopowy Katalog Biblioteczny (PySide6 + DuckDB)

## 🏗️ Faza 1: Fundamenty i Środowisko

- [ ] Konfiguracja projektu `hatch` (Python 3.14.4)
- [ ] Konfiguracja `structlog` (zapis do `logs/app.log.json`)
- [ ] Inicjalizacja bazy **DuckDB** (`src/core/database.py`)
    - [ ] Tworzenie tabel (books, authors, editions)
    - [ ] Logika unikalnych kluczy (ISBN / Hash metadanych)
- [ ] Integracja z **API Biblioteki Narodowej**:
    - [ ] **BN Data** (data.bn.org.pl) - bez autoryzacji
        - `/api/institutions/bibs.json` - rekordy BN
        - `/api/networks/bibs.json` - połączone katalogi
    - [ ] **PBN** (pbn.nauka.gov.pl) - publikacje naukowe (wymaga tokenu)
    - [ ] Wyszukiwanie po ISBN, autorze, tytule

## 🖥️ Faza 2: Interfejs Użytkownika (GUI)

- [ ] Szkielet aplikacji w **PySide6** (pasek boczny, nawigacja)
- [ ] Zakładka **Przeglądarka**:
    - [ ] Widok tabelaryczny z filtrowaniem dynamicznym
    - [ ] Karta szczegółów książki
- [ ] Zakładka **Logi**: Podgląd pliku JSON w czasie rzeczywistym
- [ ] Asynchroniczne pobieranie okładek (Worker Threads)

## 🔍 Faza 3: Skanowanie i Agregacja

- [ ] Moduł skanera **OpenCV + PyZbar**
    - [ ] Obsługa kamerki w MacBooku
    - [ ] Automatyczne wyzwalanie wyszukiwania po odczycie kodu
- [ ] Integracja z **Federacją Bibliotek Cyfrowych**:
    - [ ] **OpenSearch API** - `fbc.pionier.net.pl/opensearch/search`
    - [ ] Wyszukiwanie po identyfikatorze: `fbc.pionier.net.pl/id/{isbn}`
    - [ ] Wykrywanie duplikatów (dubletów)
    - [ ] Rozróżnianie statusu prawnego (Public Domain kontra Chronione)

## 📊 Faza 4: Funkcje Zaawansowane

- [ ] Zakładka **Statystyki**:
    - [ ] Wykresy (liczba książek, top autorzy, dekady wydań)
- [ ] Moduł **OCR (Tesseract)**:
    - [ ] Przetwarzanie zdjęć spisu treści do formatu Markdown
- [ ] Wbudowana przeglądarka PDF/Web dla darmowych pozycji (QWebEngineView)

## 📦 Faza 5: Finalizacja i Dystrybucja

- [ ] Obsługa duplikatów i dialogi wyboru wydań
- [ ] Ciemny motyw i ikony (UI/UX)
- [ ] Eksport bazy do formatów CSV/JSON
- [ ] Budowanie paczki instalacyjnej `.app` (macOS) i `.exe` (Windows)
