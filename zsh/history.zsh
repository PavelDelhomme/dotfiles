# =============================================================================
# CONFIGURATION HISTORIQUE ZSH - Par Terminal
# =============================================================================
# Description: Configuration de l'historique ZSH avec fichier unique par terminal
# Author: Paul Delhomme
# Version: 2.0 - Historique par terminal
# =============================================================================

# Créer le répertoire pour les historiques si nécessaire
HISTORY_DIR="$HOME/.zsh_history_dir"
mkdir -p "$HISTORY_DIR"

# Identifier le terminal de manière unique
# Utiliser TTY si disponible, sinon PID du shell
if [ -t 0 ] && [ -n "$TTY" ]; then
    # TTY disponible (terminal interactif)
    TERMINAL_ID=$(basename "$TTY" 2>/dev/null || echo "unknown")
elif [ -n "$$" ]; then
    # Utiliser le PID du shell comme identifiant
    TERMINAL_ID="pid_$$"
else
    # Fallback: timestamp
    TERMINAL_ID="term_$(date +%s)"
fi

# Fichier d'historique unique pour ce terminal
HISTFILE="$HISTORY_DIR/zsh_history_${TERMINAL_ID}"

# Taille de l'historique
HISTSIZE=10000
SAVEHIST=10000

# Options d'historique
# IMPORTANT: On désactive SHARE_HISTORY pour avoir un historique par terminal
setopt APPEND_HISTORY          # Ajoute à l'historique au lieu de le remplacer
setopt INC_APPEND_HISTORY      # Ajoute immédiatement à l'historique (pas de SHARE_HISTORY)
setopt HIST_IGNORE_DUPS        # Ignore les doublons consécutifs
setopt HIST_IGNORE_ALL_DUPS    # Supprime les doublons dans l'historique
setopt HIST_FIND_NO_DUPS       # Ne montre pas les doublons lors de la recherche
setopt HIST_IGNORE_SPACE       # Ignore les commandes commençant par un espace
setopt HIST_VERIFY             # Vérifie avant d'exécuter (avec !!)
setopt HIST_EXPIRE_DUPS_FIRST  # Expire d'abord les doublons
setopt HIST_SAVE_NO_DUPS       # Ne sauvegarde pas les doublons
setopt HIST_REDUCE_BLANKS      # Réduit les espaces multiples

# Fonction pour afficher l'historique de ce terminal
history() {
    if [ $# -eq 0 ]; then
        # Afficher l'historique de ce terminal
        fc -l 1
    else
        # Passer les arguments à fc
        fc "$@"
    fi
}

# Alias pour l'historique
alias h='history'
alias hg='history | grep'  # Recherche dans l'historique de ce terminal

# Fonction pour voir l'historique global (tous les terminaux)
history_global() {
    echo "📜 Historique global (tous les terminaux):"
    echo "═══════════════════════════════════════════════════════════════"
    if [ -d "$HISTORY_DIR" ]; then
        for hist_file in "$HISTORY_DIR"/zsh_history_*; do
            if [ -f "$hist_file" ]; then
                local term_name=$(basename "$hist_file" | sed 's/zsh_history_//')
                echo ""
                echo "🖥️  Terminal: $term_name"
                echo "─────────────────────────────────────────────────────────────"
                tail -20 "$hist_file" | nl
            fi
        done
    else
        echo "❌ Aucun historique trouvé"
    fi
}

# Fonction pour fusionner tous les historiques
history_merge() {
    echo "🔄 Fusion de tous les historiques..."
    local merged_file="$HISTORY_DIR/zsh_history_merged"
    
    if [ -d "$HISTORY_DIR" ]; then
        # Fusionner tous les historiques, trier par timestamp, supprimer doublons
        cat "$HISTORY_DIR"/zsh_history_* 2>/dev/null | \
            sort -u | \
            sort -t ';' -k 2 -n > "$merged_file" 2>/dev/null || true
        
        if [ -f "$merged_file" ]; then
            echo "✅ Historique fusionné dans: $merged_file"
            echo "💡 Pour charger: fc -R $merged_file"
        else
            echo "❌ Erreur lors de la fusion"
        fi
    else
        echo "❌ Aucun historique à fusionner"
    fi
}

# Fonction pour nettoyer les anciens historiques
history_clean() {
    echo "🧹 Nettoyage des historiques..."
    local days="${1:-30}"
    
    if [ -d "$HISTORY_DIR" ]; then
        find "$HISTORY_DIR" -name "zsh_history_*" -type f -mtime +$days -delete
        echo "✅ Historiques de plus de $days jours supprimés"
    else
        echo "❌ Aucun historique à nettoyer"
    fi
}

# Alias pour les fonctions d'historique
alias hg='history_global'
alias hm='history_merge'
alias hc='history_clean'

# Message informatif (optionnel, peut être désactivé)
# echo "💡 Historique ZSH configuré pour ce terminal: $TERMINAL_ID"
# echo "   Fichier: $HISTFILE"
# echo "   Commandes: 'history' (ce terminal), 'history_global' (tous), 'history_merge' (fusionner)"
