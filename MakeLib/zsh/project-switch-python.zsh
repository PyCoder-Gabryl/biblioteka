#!/bin/zsh
setopt NULL_GLOB

echo ""
echo "🐍 Python w tym katalogu"
echo "=========================="

PY=$(which python 2>/dev/null)
if [ -n "$PY" ]; then
  VER=$($PY --version 2>&1 | /usr/bin/grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | /usr/bin/head -1)
  echo "   python: $VER"
fi

echo ""
echo "📦 Dostępne wersje:"

ALL=()

i=1
for v in ~/.pyenv/versions/*; do
  [ -d "$v" ] || continue
  ver=$(/usr/bin/basename "$v" | sed 's/python-//')
  ALL+=("$ver")
  echo "   $i) $ver"
  i=$((i+1))
done

for v in $(brew list --versions python 2>/dev/null | /usr/bin/tr ' ' '\n'); do
  [[ "$v" == python@* ]] && continue
  [[ "$v" == [0-9]*.* ]] || continue
  ALL+=("$v")
  echo "   $i) $v"
  i=$((i+1))
done

for cmd in python3.14 python3.13 python3.12 python3; do
  p=$(command -v $cmd 2>/dev/null) || continue
  ver=$($p --version 2>&1 | /usr/bin/grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | /usr/bin/head -1)
  [[ "$ver" == 3.* ]] || continue
  skip=0
  for e in "${ALL[@]}"; do [[ "$e" == "$ver" ]] && skip=1; done
  [ $skip -eq 0 ] || continue
  ALL+=("$ver")
  echo "   $i) $ver"
  i=$((i+1))
done

echo ""
/usr/bin/printf "Wybierz numer (lub n): "
read -r sel

[ -z "$sel" ] && echo "Anulowano." && exit 0
[[ "$sel" == [nN] ]] && echo "Anulowano." && exit 0

# Convert number to array index (zsh arrays are 0-indexed internally)
if [[ "$sel" == <-> ]]; then
  n=$sel
  if [ $n -ge 1 ] && [ $n -le ${#ALL[@]} ]; then
    WYBRANA="${ALL[$n]}"
  else
    echo "Zły numer." && exit 1
  fi
else
  WYBRANA="$sel"
fi

[ -z "$WYBRANA" ] && echo "Błąd." && exit 1

echo ""
echo "➡ Wybrano: $WYBRANA"

[ -d .venv ] && /bin/rm -rf .venv

UV="/opt/homebrew/bin/uv"
[ -f "$UV" ] || UV="/usr/local/bin/uv"

$UV venv --python "$WYBRANA" .venv 2>/dev/null || $UV venv .venv 2>/dev/null

echo "$WYBRANA" > .python-version

NOWY=$(".venv/bin/python" --version 2>&1 | /usr/bin/grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | /usr/bin/head -1)

DIR=$(pwd)

{
echo "# Python venv dla $DIR"
echo "export PATH=\"$DIR/.venv/bin:\$PATH\""
} > .python-path.zsh

if ! /usr/bin/grep -q ".python-path.zsh" ~/.zshrc 2>/dev/null; then
  echo "" >> ~/.zshrc
  echo "source $DIR/.python-path.zsh" >> ~/.zshrc
fi

source .python-path.zsh

echo ""
echo "✅ Gotowe! $NOWY"
echo ""
echo "Aktywowano automatycznie."
echo "Sprawdź: python --version"