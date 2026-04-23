# =============================================================================
# UTILS ADAPTER - Adapter Fish pour les utilitaires globaux
# =============================================================================
# Description: Charge les utilitaires POSIX et adapte pour Fish
# Author: Paul Delhomme
# Version: 2.0
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end

# Charger les utilitaires POSIX via bash (Fish ne peut pas sourcer .sh directement)
if test -f "$DOTFILES_DIR/core/utils/alias_utils.sh"
    bash -c "source '$DOTFILES_DIR/core/utils/alias_utils.sh'"
end

if test -f "$DOTFILES_DIR/core/utils/fix_ghostscript_alias.sh"
    bash -c "source '$DOTFILES_DIR/core/utils/fix_ghostscript_alias.sh'"
end

# Charger aussi depuis l'ancien emplacement pour compatibilité
if test -f "$DOTFILES_DIR/zsh/functions/utils/ensure_tool.sh"
    bash -c "source '$DOTFILES_DIR/zsh/functions/utils/ensure_tool.sh'"
end

if test -f "$DOTFILES_DIR/zsh/functions/utils/ensure_osint_tool.sh"
    bash -c "source '$DOTFILES_DIR/zsh/functions/utils/ensure_osint_tool.sh'"
end

