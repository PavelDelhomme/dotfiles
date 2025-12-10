# =============================================================================
# PATHMAN ADAPTER - Wrapper Fish pour pathman
# =============================================================================
# Description: Adapter Fish pour charger pathman depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Note: Fish ne peut pas sourcer directement .sh, on utilise l'ancienne version
# pour l'instant jusqu'à ce qu'on crée une version Fish du code commun
# ou un wrapper qui convertit les fonctions

# Pour l'instant, on garde l'ancienne version Fish
if test -f "$HOME/dotfiles/fish/functions/pathman/core/pathman.fish"
    source "$HOME/dotfiles/fish/functions/pathman/core/pathman.fish"
else
    echo "❌ Erreur: pathman Fish non trouvé"
    return 1
end

# TODO: Créer une version Fish du code commun ou un wrapper de conversion

