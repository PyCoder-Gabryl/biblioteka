#!/bin/zsh
# MakeLib/zsh/python.zsh - Wrapper do zarządzania wersjami Pythona

setopt NO_NOMATCH

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP=$(mktemp)

"$SCRIPT_DIR/system-python-upgrade.zsh" > "$TMP" 2>&1
cat "$TMP"

echo ""
echo "=== Wybierz wersje do instalacji/aktualizacji ==="
echo ""

INPUT_FILE="$TMP" /bin/zsh "$SCRIPT_DIR/manage-python-versions.zsh" </dev/stdin

rm -f "$TMP"