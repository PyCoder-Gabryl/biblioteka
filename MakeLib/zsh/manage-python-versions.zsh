#!/bin/zsh
# MakeLib/zsh/manage-python-versions.zsh
setopt NO_NOMATCH

AVAILABLE_VERSIONS=()
typeset -A INSTALLED_BY_BRANCH

is_version() {
  print -- "$1" | grep -Eq '^[0-9]+\.[0-9]+(\.[0-9]+)?$' 
}

process_line() {
  local rawline="$1"
  local line="${rawline##+([[:space:]])}"
  line="${line%%+([[:space:]])}"
  [ -z "$line" ] && return 0

  local first=$(print -- "$line" | awk '{print $1}')

  if is_version "$first"; then
    AVAILABLE_VERSIONS+=("$first")
  fi

  if [[ "$line" =~ "\(masz:[[:space:]]*([0-9]+\.[0-9]+(\.[0-9]+)?)" ]]; then
    local ver="${match[1]}"
    local branch=$(print -- "$ver" | awk -F. '{print $1"."$2}')
    INSTALLED_BY_BRANCH[$branch]="$ver"
  fi
}

if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
  while IFS= read -r rawline; do
    process_line "$rawline"
  done < "$INPUT_FILE"
elif [ -n "$1" ] && [ -f "$1" ]; then
  while IFS= read -r rawline; do
    process_line "$rawline"
  done < "$1"
else
  while IFS= read -r rawline; do
    process_line "$rawline"
  done
fi

if [ ${#AVAILABLE_VERSIONS[@]} -eq 0 ]; then
  printf '  Brak dostępnych wersji do przetworzenia.\n\n'
  exit 0
fi

UPGRADE_VERSIONS=()
INSTALL_VERSIONS=()

for v in "${AVAILABLE_VERSIONS[@]}"; do
  branch=$(print -- "$v" | awk -F. '{print $1"."$2}')
  inst="${INSTALLED_BY_BRANCH[$branch]:-brak}"
  if [ "$inst" = "brak" ]; then
    INSTALL_VERSIONS+=("$v")
  elif [ "$v" != "$inst" ]; then
    UPGRADE_VERSIONS+=("$v")
  fi
done

echo ""
echo "=== DO ZAINSTALOWANIA ==="
if [ ${#INSTALL_VERSIONS[@]} -eq 0 ]; then
  printf "  Brak wersji do zainstalowania.\n"
else
  printf "  Dostępne do instalacji:\n"
  i=1
  for v in "${INSTALL_VERSIONS[@]}"; do
    printf "    %2d) %s\n" "$i" "$v"
    i=$((i+1))
  done
  printf "\n  Wpisz numery (np. 1 lub 1 2), 'all' lub 'n' aby pominąć: "
  if [ -t 0 ] && [ -c /dev/tty ]; then
    read -r selection </dev/tty
  else
    read -r selection
  fi

  to_install=()
  if [ -n "$selection" ] && [ "$selection" != "n" ] && [ "$selection" != "N" ]; then
    if [ "$selection" = "all" ]; then
      to_install=("${INSTALL_VERSIONS[@]}")
    else
      for idx in $selection; do
        if print -- "$idx" | grep -Eq '^[0-9]+$'; then
          n=$((idx))
          if [ $n -ge 1 ] && [ $n -le ${#INSTALL_VERSIONS[@]} ]; then
            to_install+=("${INSTALL_VERSIONS[$((n-1))]}")
          fi
        fi
      done
    fi
  fi

  if [ ${#to_install[@]} -gt 0 ]; then
    printf "  Wybrane do instalacji: %s\n" "${to_install[@]}"
  else
    printf "  Pominięto.\n"
  fi
fi

echo ""
echo "=== DO AKTUALIZACJI ==="
if [ ${#UPGRADE_VERSIONS[@]} -eq 0 ]; then
  printf "  Brak wersji do aktualizacji.\n"
else
  printf "  Dostępne aktualizacje:\n"
  i=1
  for v in "${UPGRADE_VERSIONS[@]}"; do
    branch=$(print -- "$v" | awk -F. '{print $1"."$2}')
    inst="${INSTALLED_BY_BRANCH[$branch]}"
    printf "    %2d) %s -> %s\n" "$i" "$v" "$inst"
    i=$((i+1))
  done
  printf "\n  Wpisz numery (np. 1 lub 1 2), 'all' lub 'n' aby pominąć: "
  if [ -t 0 ] && [ -c /dev/tty ]; then
    read -r selection </dev/tty
  else
    read -r selection
  fi

  to_upgrade=()
  if [ -n "$selection" ] && [ "$selection" != "n" ] && [ "$selection" != "N" ]; then
    if [ "$selection" = "all" ]; then
      to_upgrade=("${UPGRADE_VERSIONS[@]}")
    else
      for idx in $selection; do
        if print -- "$idx" | grep -Eq '^[0-9]+$'; then
          n=$((idx))
          if [ $n -ge 1 ] && [ $n -le ${#UPGRADE_VERSIONS[@]} ]; then
            to_upgrade+=("${UPGRADE_VERSIONS[$((n-1))]}")
          fi
        fi
      done
    fi
  fi

  if [ ${#to_upgrade[@]} -gt 0 ]; then
    printf "  Wybrane do aktualizacji: %s\n" "${to_upgrade[@]}"
  else
    printf "  Pominięto.\n"
  fi
fi

total=$(( ${#to_upgrade[@]} + ${#to_install[@]} ))
if [ $total -eq 0 ]; then
  printf '\nNic do zrobienia.\n'
  exit 0
fi

USE_PYENV=0
USE_BREW=0
if command -v pyenv >/dev/null 2>&1; then
  USE_PYENV=1
elif command -v brew >/dev/null 2>&1; then
  USE_BREW=1
fi

install_with_pyenv() {
  v="$1"
  printf '-> pyenv install -s %s\n' "$v"
  pyenv install -s "$v"
}

install_with_brew() {
  v="$1"
  majmin=$(print -- "$v" | awk -F. '{print $1"."$2}')
  printf '-> brew install python@%s\n' "$majmin"
  brew install "python@${majmin}" || {
    printf '  brew install failed.\n'
  }
}

echo ""
echo "=== WYKONYWANIE ==="

for v in "${to_upgrade[@]}"; do
  inst="${INSTALLED_BY_BRANCH[${v%.*}]}"
  printf 'Aktualizuję %s (masz: %s) ...\n' "$v" "$inst"
  if [ $USE_PYENV -eq 1 ]; then
    install_with_pyenv "$v"
  elif [ $USE_BREW -eq 1 ]; then
    install_with_brew "$v"
  else
    printf '  Brak pyenv lub brew. Uruchom ręcznie: pyenv install %s\n' "$v"
  fi
  printf 'Zakończono.\n'
done

for v in "${to_install[@]}"; do
  printf 'Instaluję %s ...\n' "$v"
  if [ $USE_PYENV -eq 1 ]; then
    install_with_pyenv "$v"
  elif [ $USE_BREW -eq 1 ]; then
    install_with_brew "$v"
  else
    printf '  Brak pyenv lub brew. Uruchom ręcznie: pyenv install %s\n' "$v"
  fi
  printf 'Zakończono.\n'
done

printf '\nWszystkie operacje zakończone.\n'
exit 0