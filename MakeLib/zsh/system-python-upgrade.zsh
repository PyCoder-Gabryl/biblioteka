#!/bin/sh
set -eu

printf '%s\n\n' "🐍 Python.org Latest Versions (3.x)"
printf '%s\n' "🔍 Pobieram listę wersji z https://www.python.org/ftp/python/ ..."

BASE_URL="https://www.python.org/ftp/python"
HTML=$(curl -4 -sS "${BASE_URL}/" || true)
if [ -z "$HTML" ]; then
  printf '%s\n' "❌ Nie udało się pobrać listy z python.org/ftp/python/."
  exit 1
fi

# Wyciągnij katalogi 3.X.Y/ i posortuj malejąco
VERSIONS=$(printf '%s\n' "$HTML" | grep -oE '3\.[0-9]+\.[0-9]+/' | sed 's#/##' | sort -Vr | uniq)
if [ -z "$VERSIONS" ]; then
  printf '%s\n' "❌ Nie znaleziono wersji 3.x na serwerze."
  exit 1
fi

# Z każdej gałęzi (3.X) wybierz pierwszą (najwyższy patch)
LATEST_LIST=$(printf '%s\n' "$VERSIONS" | awk -F. '
{
  branch = $1 "." $2
  if (!(branch in seen)) {
    print branch " " $0
    seen[branch]=1
  }
}
')

# Posortuj gałęzie malejąco i wybierz top5 (najnowsza + 4 poprzednie)
TOP_BRANCHES=$(printf '%s\n' "$LATEST_LIST" | awk '{print $1}' | sort -Vr | uniq | head -n 6)
if [ -z "$TOP_BRANCHES" ]; then
  printf '%s\n' "❌ Brak gałęzi do wyświetlenia."
  exit 1
fi

# --- NOWOŚĆ: filtrujemy wersje testowe i sprawdzamy obecność artefaktu źródłowego ---
# Funkcja: czy katalog wersji zawiera plik źródłowy (szybkie sprawdzenie listing katalogu)
has_source() {
  ver="$1"
  # krótkie pobranie listing katalogu; timeouty zapobiegają zawieszaniu
  LISTING=$(curl -4 -sS --connect-timeout 4 --max-time 6 "${BASE_URL}/${ver}/" || true)
  # sprawdź typowe nazwy plików źródłowych
  printf '%s\n' "$LISTING" | grep -qE "Python-${ver}([.-]).*\.(tgz|tar\.xz|zip)" && return 0
  printf '%s\n' "$LISTING" | grep -qE "Python-${ver//./-}([.-]).*\.(tgz|tar\.xz|zip)" && return 0
  return 1
}

# Zbuduj listę finalną: z TOP_BRANCHES wybierz tylko te, których najnowszy patch:
#  - nie zawiera liter (prerelease)
#  - i ma artefakt źródłowy w katalogu ftp
FINAL_LIST=""
for br in $(printf '%s\n' "$TOP_BRANCHES"); do
  latest=$(printf '%s\n' "$LATEST_LIST" | awk -v b="$br" '$1==b {print $2; exit}')
  [ -z "$latest" ] && continue
  # pomiń prereleasey zawierające litery (rc, a, b)
  case "$latest" in
    *[!0-9.]*)
      # zawiera znaki inne niż cyfry i kropki -> pomiń
      continue
    ;;
  esac
  if has_source "$latest"; then
    FINAL_LIST=$(printf '%s\n%s' "$FINAL_LIST" "$latest")
  fi
done

# Jeśli nic nie przeszło filtra (np. timeouty, brak artefaktów), fallback do oryginalnego TOP_BRANCHES
if [ -z "$(printf '%s\n' "$FINAL_LIST" | sed '/^\s*$/d')" ]; then
  FINAL_LIST=""
  # fallback: weź po prostu najwyższe patche z TOP_BRANCHES (tak jak wcześniej)
  for br in $(printf '%s\n' "$TOP_BRANCHES"); do
    latest=$(printf '%s\n' "$LATEST_LIST" | awk -v b="$br" '$1==b {print $2; exit}')
    [ -n "$latest" ] && FINAL_LIST=$(printf '%s\n%s' "$FINAL_LIST" "$latest")
  done
fi

# Zbierz lokalne binarki python (PATH + pyenv + typowe miejsca)
TMP=$(mktemp)
trap 'rm -f "$TMP" "$TMP.cands" "$TMP.vers"' EXIT

for cmd in python3 python; do
  p=$(command -v "$cmd" 2>/dev/null || true)
  [ -n "$p" ] && printf '%s\n' "$p" >> "$TMP"
done

if [ -d "$HOME/.pyenv/versions" ]; then
  for d in "$HOME/.pyenv/versions"/*; do
    [ -d "$d" ] || continue
    for f in "$d"/bin/python*; do
      [ -x "$f" ] && printf '%s\n' "$f" >> "$TMP"
    done
  done
fi

for d in /usr/local/bin /usr/bin /opt/homebrew/bin /opt/local/bin /usr/local/Cellar /opt/homebrew/Cellar; do
  if [ -d "$d" ]; then
    for f in "$d"/python*; do
      [ -x "$f" ] && printf '%s\n' "$f" >> "$TMP"
    done
  fi
done

# deduplikuj kandydatów
awk '!seen[$0]++' "$TMP" | sed '/^\s*$/d' > "$TMP.cands" || true

# Pobierz wersje z lokalnych binarek
: > "$TMP.vers"
FOUND=0
if [ -f "$TMP.cands" ]; then
  while IFS= read -r bin; do
    [ -x "$bin" ] || continue
    ver=$("$bin" --version 2>&1 | awk '{print $2}' || true)
    case "$ver" in
      3.*.*)
        branch=$(printf '%s\n' "$ver" | awk -F. '{print $1 "." $2}')
        printf '%s %s\n' "$branch" "$ver" >> "$TMP.vers"
        FOUND=1
      ;;
    esac
  done < "$TMP.cands"
fi

# dopisz systemowy python3 jeśli nie wykryto
sysver=$(command -v python3 >/dev/null 2>&1 && python3 --version 2>/dev/null | awk '{print $2}' || true)
case "$sysver" in
  3.*.*)
    b=$(printf '%s\n' "$sysver" | awk -F. '{print $1 "." $2}')
    printf '%s %s\n' "$b" "$sysver" >> "$TMP.vers"
    FOUND=1
  ;;
esac

# Wypisz wynik: dla każdej wersji z FINAL_LIST wybierz najwyższą zainstalowaną (jeśli jest)
printf '\n%s\n' "📦 Najnowsze wersje Pythona 3.x (najnowsza + 4 poprzednie):"
printf '%s\n' "-----------------------------------------------------------"

if [ -z "$(printf '%s\n' "$FINAL_LIST" | sed '/^\s*$/d')" ]; then
  printf '%s\n' "(brak oficjalnych wersji do wyświetlenia)"
else
  printf '%s\n' "$FINAL_LIST" | while IFS= read -r latest; do
    [ -z "$latest" ] && continue
    br=$(printf '%s\n' "$latest" | awk -F. '{print $1 "." $2}')
    inst=$( [ -s "$TMP.vers" ] && awk -v b="$br" '$1==b {print $2}' "$TMP.vers" | sort -Vr | head -n1 || true )
    if [ -z "$inst" ]; then inst="brak"; fi
    printf '%-12s (masz: %s)\n' "$latest" "$inst"
  done
fi

printf '%s\n' "-----------------------------------------------------------"

if [ "$FOUND" -eq 0 ]; then
  printf '%s\n\n' "⚠️  Nie znaleziono lokalnych binarek python. Uruchom: which -a python3 python  i  ls -1 ~/.pyenv/versions"
else
  printf '\n'
fi

exit 0

# Poprawna wersja !!!!
