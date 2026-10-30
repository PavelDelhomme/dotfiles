#!/bin/bash
# Mincheck — fresh OS sans dépôt (ou dépôt partiel)
# Peut être curl|bash après upload, ou lancé via bin/dotfiles mincheck
set -u
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -x "$DOTFILES_DIR/bin/dotfiles" ]; then
    exec "$DOTFILES_DIR/bin/dotfiles" mincheck
fi
# fallback autonome
miss=0
echo "Mincheck (standalone)"
for b in git curl wget make bash; do
    if command -v "$b" >/dev/null 2>&1; then
        echo "  ✓ $b"
    else
        echo "  ✗ $b"
        miss=$((miss+1))
    fi
done
[ "$miss" -eq 0 ] && exit 0 || exit 1
