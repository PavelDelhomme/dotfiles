# =============================================================================
# CONFIGURATION HISTORIQUE FISH
# =============================================================================
# Description: Configuration de l'historique partagé entre terminaux
# - Historique individuelle par terminal (navigation avec flèches)
# - Historique global partagé accessible via 'history'
# =============================================================================

# Fichier d'historique partagé (Fish utilise un format spécial)
set -gx fish_history_path "$HOME/.local/share/fish/fish_history"

# Taille de l'historique en mémoire (pour chaque terminal)
set -gx fish_history_size 10000

# Sauvegarder l'historique immédiatement après chaque commande
function save_history --on-event fish_preexec
    # L'historique est automatiquement sauvegardé par Fish
    # mais on force la synchronisation
    history --save
end

# Fonction personnalisée pour afficher l'historique avec numéros
function history --description "Affiche l'historique global avec numéros"
    if test (count $argv) -eq 0
        # Afficher l'historique global avec numéros
        builtin history | nl -v 1 -w 4 -s '  '
    else
        # Recherche dans l'historique
        builtin history | grep -i "$argv" | nl -v 1 -w 4 -s '  '
    end
end

# Alias pour accéder rapidement à l'historique
alias h='history'
alias hg='history | grep'  # Recherche dans l'historique global

# Fonction pour voir l'historique d'un terminal spécifique
function history_local
    echo "📜 Historique local de ce terminal (navigation avec flèches)"
    echo "💡 Utilisez 'history' pour voir l'historique global de tous les terminaux"
end

# Synchroniser l'historique au démarrage
history --merge  # Fusionner avec l'historique existant

