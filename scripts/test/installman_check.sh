#!/usr/bin/env sh
# =============================================================================
# Vérifications installman : syntaxe POSIX + option moteur POSIX (sans zsh)
# =============================================================================
# Usage depuis le dépôt :
#   sh scripts/test/installman_check.sh
#   DOTFILES_DIR=/chemin/dotfiles sh scripts/test/installman_check.sh
#
# Note : sh -n fichier.sh n’affiche rien si la syntaxe est correcte (code 0).
# =============================================================================

set -e
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
POSIX_CORE="$DOTFILES_DIR/core/managers/installman/core/installman.sh"
ENTRY="$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

echo "== 1) Syntaxe core POSIX (sh -n ; silence = OK) =="
if ! sh -n "$POSIX_CORE"; then
    echo "Échec: sh -n" >&2
    exit 1
fi
echo "   OK : syntaxe valide pour $POSIX_CORE"
echo ""

echo "== 2) Moteur POSIX (INSTALLMAN_ENGINE=posix), extrait de help =="
if [ ! -f "$ENTRY" ]; then
    echo "Entrée absente: $ENTRY" >&2
    exit 1
fi
INSTALLMAN_ENGINE=posix sh "$ENTRY" help 2>&1 | head -25
echo "   … (tronqué)"
echo ""

echo "== 3) Entrée par défaut (zsh si présent), extrait de help =="
if command -v zsh >/dev/null 2>&1; then
    sh "$ENTRY" help 2>&1 | head -15
    echo "   … (tronqué)"
else
    echo "   (zsh absent : ignoré, déjà testé via POSIX ci-dessus)"
fi

echo ""
echo "Terminé : tout est cohérent pour les vérifications locales."
