#!/bin/sh
################################################################################
# Configuration unifiée pour tous les shells (sh/bash/zsh compatible)
# Ce fichier contient la configuration commune à tous les shells
################################################################################

# Détection du répertoire dotfiles
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "$HOME" ]; then
        DOTFILES_DIR="$HOME/dotfiles"
    else
        DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    fi
fi

# Exporter pour les sous-shells
export DOTFILES_DIR

# ~/.local/bin et /usr/local/bin en tête de PATH (update-cursor, cursor = AppImage avant paquet)
[ -n "$HOME" ] && mkdir -p "$HOME/.local/bin"
_prepend_path() {
    _p="$1"
    case ":$PATH:" in *":$_p:"*) ;; *) export PATH="$_p:$PATH" ;; esac
}
[ -n "$HOME" ] && _prepend_path "$HOME/.local/bin"
_prepend_path "/usr/local/bin"

# Mettre à jour Cursor : créer ~/.local/bin/update-cursor s'il manque (pour installman / cursor)
if [ -n "$HOME" ] && [ ! -x "$HOME/.local/bin/update-cursor" ] && [ -f "$DOTFILES_DIR/scripts/install/apps/install_cursor.sh" ]; then
    cat > "$HOME/.local/bin/update-cursor" << 'UPDATECURSOR_EOF'
#!/usr/bin/env bash
# Mise à jour Cursor depuis https://cursor.com/download (généré par dotfiles)
export NON_INTERACTIVE=1
DOTFILES=""
for candidate in "${DOTFILES_DIR:-}" "$HOME/dotfiles" "$HOME/.dotfiles"; do
    [ -z "$candidate" ] && continue
    [ -f "$candidate/scripts/install/apps/install_cursor.sh" ] && DOTFILES="$candidate" && break
done
if [ -n "$DOTFILES" ]; then
    export DOTFILES_DIR="$DOTFILES"
    exec bash "$DOTFILES_DIR/scripts/install/apps/install_cursor.sh" --update-only
fi
echo "Erreur: script install_cursor.sh introuvable." >&2
echo "  DOTFILES_DIR=$DOTFILES_DIR" >&2
exit 1
UPDATECURSOR_EOF
    chmod +x "$HOME/.local/bin/update-cursor" 2>/dev/null || true
fi

# Charger les variables d'environnement communes
if [ -f "$DOTFILES_DIR/shared/env.sh" ]; then
    . "$DOTFILES_DIR/shared/env.sh"
fi

# Charger les alias communs (compatibles sh/bash/zsh)
if [ -f "$DOTFILES_DIR/shared/aliases.sh" ]; then
    . "$DOTFILES_DIR/shared/aliases.sh"
fi

# Charger les fonctions communes (compatibles sh/bash/zsh)
if [ -d "$DOTFILES_DIR/shared/functions" ]; then
    for func_file in "$DOTFILES_DIR/shared/functions"/*.sh; do
        [ -f "$func_file" ] && . "$func_file"
    done
fi

