#!/bin/bash
# =============================================================================
# INSTALLMAN - Délégation vers l’entrée unique (même logique que shells/bash/adapters)
# =============================================================================
# Ancien chemin conservé pour compatibilité : source ce fichier → installman()
# appelle core/managers/installman/installman_entry.sh
# =============================================================================

if [ -z "${DOTFILES_DIR:-}" ]; then
    if [ -d "$HOME/dotfiles" ]; then
        DOTFILES_DIR="$HOME/dotfiles"
    else
        echo "❌ Répertoire dotfiles introuvable (définir DOTFILES_DIR)" >&2
        return 1 2>/dev/null || exit 1
    fi
fi

INSTALLMAN_ENTRY="$DOTFILES_DIR/core/managers/installman/installman_entry.sh"

installman() {
    if [ -f "$INSTALLMAN_ENTRY" ]; then
        sh "$INSTALLMAN_ENTRY" "$@"
    else
        echo "❌ installman entry non trouvé: $INSTALLMAN_ENTRY" >&2
        return 1
    fi
}

export -f installman 2>/dev/null || true
