# =============================================================================
# CONFIGURATION HISTORIQUE BASH
# =============================================================================
# Description: Configuration de l'historique partagé entre terminaux
# - Historique individuelle par terminal (navigation avec flèches)
# - Historique global partagé accessible via 'history'
# =============================================================================

# Fichier d'historique partagé
HISTFILE="$HOME/.bash_history"

# Taille de l'historique en mémoire (pour chaque terminal)
HISTSIZE=10000

# Taille de l'historique sauvegardé (historique global)
HISTFILESIZE=50000

# Options d'historique
HISTCONTROL=ignoreboth          # Ignore les doublons et les commandes avec espace
HISTIGNORE="ls:ll:la:cd:pwd:clear:history"  # Ignore les commandes courantes

# Format de l'historique avec timestamp
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# Sauvegarder l'historique après chaque commande (partage immédiat)
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Fonction pour afficher l'historique avec numéros de ligne
history() {
    if [ $# -eq 0 ]; then
        # Afficher l'historique global avec numéros
        builtin history | nl -v 1 -w 4 -s '  '
    else
        # Recherche dans l'historique
        builtin history | grep -i "$*" | nl -v 1 -w 4 -s '  '
    fi
}

# Alias pour accéder rapidement à l'historique
alias h='history'
alias hg='history | grep'  # Recherche dans l'historique global

# Fonction pour voir l'historique d'un terminal spécifique
history_local() {
    echo "📜 Historique local de ce terminal (navigation avec flèches)"
    echo "💡 Utilisez 'history' pour voir l'historique global de tous les terminaux"
}

# Synchroniser l'historique au démarrage
history -a  # Ajouter l'historique actuel au fichier
history -c  # Effacer l'historique en mémoire
history -r  # Recharger l'historique depuis le fichier

