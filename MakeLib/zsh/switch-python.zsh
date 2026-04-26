#!/bin/zsh
# Wrapper - uruchamia switch i aktywuje nową wersję

echo "Wybierz wersję z listy, a ja ustawię i aktywuję..."

/bin/zsh MakeLib/zsh/project-switch-python.zsh << EOF

if [ -f .python-path.zsh ]; then
  echo ""
  echo "Aby użyć nowej wersji, uruchom w terminalu:"
  echo "   source .python-path.zsh"
  echo ""
  echo "Lub po prostu wpisz:"
  echo "   source .venv/bin/activate"
fi
exec /bin/zsh