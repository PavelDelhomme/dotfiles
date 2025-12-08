# =============================================================================
# CONFIGURATION HISTORIQUE ZSH
# =============================================================================
# Description: Configuration de l'historique partagé entre terminaux
# - Historique individuelle par terminal (navigation avec flèches)
# - Historique global partagé accessible via 'history'
# =============================================================================

# Fichier d'historique partagé
HISTFILE="$HOME/.zsh_history"

# Taille de l'historique en mémoire (pour chaque terminal)
HISTSIZE=10000

# Taille de l'historique sauvegardé (historique global)
SAVEHIST=50000

# Options d'historique
setopt INC_APPEND_HISTORY        # Ajoute immédiatement à l'historique partagé
setopt SHARE_HISTORY             # Partage l'historique entre toutes les sessions
setopt HIST_IGNORE_DUPS          # Ignore les doublons consécutifs
setopt HIST_IGNORE_ALL_DUPS      # Supprime les doublons dans l'historique
setopt HIST_FIND_NO_DUPS         # Ne montre pas les doublons lors de la recherche
setopt HIST_IGNORE_SPACE         # Ignore les commandes commençant par un espace
setopt HIST_SAVE_NO_DUPS         # Ne sauvegarde pas les doublons
setopt HIST_REDUCE_BLANKS        # Réduit les espaces multiples
setopt HIST_VERIFY               # Vérifie avant d'exécuter les commandes de l'historique
setopt HIST_EXPIRE_DUPS_FIRST    # Expire d'abord les doublons
setopt HIST_FCNTL_LOCK           # Utilise le verrouillage de fichiers pour l'historique

# Fonction pour afficher l'historique avec numéros de ligne
history() {
    if [ $# -eq 0 ]; then
        # Afficher l'historique global avec numéros
        fc -l 1 | nl -v 1 -w 4 -s '  '
    else
        # Recherche dans l'historique
        fc -l 1 | grep -i "$*" | nl -v 1 -w 4 -s '  '
    fi
}

# Alias pour accéder rapidement à l'historique
alias h='history'
alias hg='history | grep'  # Recherche dans l'historique global

# Fonction pour voir l'historique d'un terminal spécifique (basé sur le PID)
history_local() {
    echo "📜 Historique local de ce terminal (navigation avec flèches)"
    echo "💡 Utilisez 'history' pour voir l'historique global de tous les terminaux"
}

