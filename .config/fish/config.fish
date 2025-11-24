################################################################################
# Configuration Fish - Wrapper unifié
# Source la configuration partagée (via conversion)
################################################################################

# Variables d'environnement communes
if test -f "$HOME/dotfiles/shared/env.sh"
    # Fish ne peut pas source .sh directement, on doit convertir
    # Pour l'instant, charger directement les variables
    set -g DOTFILES_DIR "$HOME/dotfiles"
end

# Configuration spécifique Fish
if test -f "$HOME/dotfiles/fish/config_custom.fish"
    source "$HOME/dotfiles/fish/config_custom.fish"
end

