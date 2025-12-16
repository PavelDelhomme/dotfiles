#!/bin/zsh
# =============================================================================
# UTILS ADAPTER - Adapter ZSH pour les utilitaires globaux
# =============================================================================
# Description: Charge les utilitaires POSIX et adapte pour ZSH
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Charger les utilitaires POSIX
[ -f "$DOTFILES_DIR/core/utils/alias_utils.sh" ] && source "$DOTFILES_DIR/core/utils/alias_utils.sh"
[ -f "$DOTFILES_DIR/core/utils/fix_ghostscript_alias.sh" ] && source "$DOTFILES_DIR/core/utils/fix_ghostscript_alias.sh"

# Charger aussi depuis l'ancien emplacement pour compatibilité
[ -f "$DOTFILES_DIR/zsh/functions/utils/ensure_tool.sh" ] && source "$DOTFILES_DIR/zsh/functions/utils/ensure_tool.sh"
[ -f "$DOTFILES_DIR/zsh/functions/utils/ensure_osint_tool.sh" ] && source "$DOTFILES_DIR/zsh/functions/utils/ensure_osint_tool.sh"

