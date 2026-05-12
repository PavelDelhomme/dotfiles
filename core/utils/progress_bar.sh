#!/bin/sh
# =============================================================================
# PROGRESS_BAR - Barre de progression réutilisable (POSIX)
# =============================================================================
# Description: Script de barre de progression réutilisable pour tous les shells
# Author: Paul Delhomme
# Version: 1.0 - POSIX Compliant
# =============================================================================
# Usage: source progress_bar.sh puis utiliser les fonctions
# Compatible: ZSH, Bash, Fish (via sh), POSIX sh
# =============================================================================

# Variables globales pour la progression
PROGRESS_START_TIME=0
PROGRESS_TOTAL=0
PROGRESS_COMPLETED=0
PROGRESS_SUCCESSFUL=0
PROGRESS_FAILED=0
PROGRESS_DESCRIPTION="Traitement"

# =============================================================================
# Initialiser la progression
# =============================================================================
# Usage: progress_init TOTAL [DESCRIPTION]
# Args:
#   TOTAL: Nombre total d'éléments à traiter
#   DESCRIPTION: Description du traitement (optionnel)
# =============================================================================
progress_init() {
    PROGRESS_TOTAL=${1:-0}
    PROGRESS_DESCRIPTION=${2:-"Traitement"}
    PROGRESS_START_TIME=$(date +%s 2>/dev/null || echo 0)
    PROGRESS_COMPLETED=0
    PROGRESS_SUCCESSFUL=0
    PROGRESS_FAILED=0
}

# =============================================================================
# Mettre à jour la progression
# =============================================================================
# Usage: progress_update COMPLETED [SUCCESSFUL] [FAILED]
# Args:
#   COMPLETED: Nombre d'éléments complétés
#   SUCCESSFUL: Nombre d'éléments réussis (optionnel, calculé si omis)
#   FAILED: Nombre d'éléments échoués (optionnel, calculé si omis)
# =============================================================================
progress_update() {
    PROGRESS_COMPLETED=${1:-0}
    PROGRESS_SUCCESSFUL=${2:-$PROGRESS_COMPLETED}
    PROGRESS_FAILED=${3:-0}
    
    # Calculer le pourcentage
    if [ "$PROGRESS_TOTAL" -eq 0 ]; then
        PERCENTAGE=0
    else
        # Utiliser awk pour le calcul (compatible POSIX)
        PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($PROGRESS_COMPLETED / $PROGRESS_TOTAL) * 100}" 2>/dev/null || echo "0")
    fi
    
    # Calculer le temps écoulé
    CURRENT_TIME=$(date +%s 2>/dev/null || echo 0)
    if [ "$PROGRESS_START_TIME" -gt 0 ]; then
        ELAPSED=$((CURRENT_TIME - PROGRESS_START_TIME))
    else
        ELAPSED=0
    fi
    
    # Formater le temps écoulé (HH:MM:SS)
    ELAPSED_HOURS=$((ELAPSED / 3600))
    ELAPSED_MINUTES=$((ELAPSED % 3600 / 60))
    ELAPSED_SECONDS=$((ELAPSED % 60))
    ELAPSED_STR=$(printf '%02d:%02d:%02d' "$ELAPSED_HOURS" "$ELAPSED_MINUTES" "$ELAPSED_SECONDS")
    
    # Calculer le temps estimé restant
    if [ "$PROGRESS_COMPLETED" -gt 0 ] && [ "$PROGRESS_TOTAL" -gt 0 ]; then
        AVG_TIME=$(awk "BEGIN {printf \"%.2f\", $ELAPSED / $PROGRESS_COMPLETED}" 2>/dev/null || echo "0")
        REMAINING=$(awk "BEGIN {printf \"%.0f\", $AVG_TIME * ($PROGRESS_TOTAL - $PROGRESS_COMPLETED)}" 2>/dev/null || echo "0")
        ETA_HOURS=$((REMAINING / 3600))
        ETA_MINUTES=$((REMAINING % 3600 / 60))
        ETA_SECONDS=$((REMAINING % 60))
        ETA_STR=$(printf '%02d:%02d:%02d' "$ETA_HOURS" "$ETA_MINUTES" "$ETA_SECONDS")
        TIME_INFO="⏱️  ${ELAPSED_STR} écoulé | ~${ETA_STR} restant"
    else
        TIME_INFO="⏱️  Calcul en cours..."
    fi
    
    # Créer la barre de progression
    BAR_LENGTH=40
    if [ "$PROGRESS_TOTAL" -gt 0 ]; then
        FILLED=$(awk "BEGIN {printf \"%.0f\", ($PROGRESS_COMPLETED / $PROGRESS_TOTAL) * $BAR_LENGTH}" 2>/dev/null || echo "0")
        if [ "$FILLED" -gt "$BAR_LENGTH" ]; then
            FILLED=$BAR_LENGTH
        fi
    else
        FILLED=0
    fi
    
    # Construire la barre
    BAR=""
    i=1
    while [ "$i" -le "$BAR_LENGTH" ]; do
        if [ "$i" -le "$FILLED" ]; then
            BAR="${BAR}█"
        else
            BAR="${BAR}░"
        fi
        i=$((i + 1))
    done
    
    # Statistiques
    STATS="✅ $PROGRESS_SUCCESSFUL | ❌ $PROGRESS_FAILED"

    # Mode d'affichage :
    #   - TTY interactif (stdout est un terminal) ET DOTFILES_PROGRESS_PLAIN != 1
    #     → on utilise \r pour écraser la ligne précédente (UX moderne).
    #   - Sinon (pipe, log file, redirection, CI, DOTFILES_PROGRESS_PLAIN=1)
    #     → on émet une ligne propre par mise à jour, sans \r, pour rester
    #     lisible dans `tee`, `less`, les logs et les terminaux d’IDE qui ne
    #     savent pas réinterpréter \r correctement.
    if [ -t 1 ] && [ "${DOTFILES_PROGRESS_PLAIN:-0}" != "1" ]; then
        printf "\r[%d/%d] %s%% |%s| %s | %s" "$PROGRESS_COMPLETED" "$PROGRESS_TOTAL" "$PERCENTAGE" "$BAR" "$STATS" "$TIME_INFO"
    else
        printf "[%d/%d] %s%% %s | %s\n" "$PROGRESS_COMPLETED" "$PROGRESS_TOTAL" "$PERCENTAGE" "$STATS" "$TIME_INFO"
    fi
}

# =============================================================================
# Incrémenter la progression
# =============================================================================
# Usage: progress_increment [SUCCESSFUL] [COUNT]
# Args:
#   SUCCESSFUL: true/false ou 1/0 pour indiquer si réussi (défaut: true)
#   COUNT: Nombre d'éléments à incrémenter (défaut: 1)
# =============================================================================
progress_increment() {
    local successful=${1:-1}
    local count=${2:-1}
    
    PROGRESS_COMPLETED=$((PROGRESS_COMPLETED + count))
    
    if [ "$successful" = "true" ] || [ "$successful" = "1" ] || [ "$successful" = "yes" ]; then
        PROGRESS_SUCCESSFUL=$((PROGRESS_SUCCESSFUL + count))
    else
        PROGRESS_FAILED=$((PROGRESS_FAILED + count))
    fi
    
    progress_update "$PROGRESS_COMPLETED" "$PROGRESS_SUCCESSFUL" "$PROGRESS_FAILED"
}

# =============================================================================
# Terminer la progression (affiche une nouvelle ligne)
# =============================================================================
# Usage: progress_finish [SHOW_SUMMARY]
# Args:
#   SHOW_SUMMARY: true/false pour afficher le résumé (défaut: true)
# =============================================================================
progress_finish() {
    local show_summary=${1:-true}
    
    # Afficher la progression finale
    progress_update "$PROGRESS_COMPLETED" "$PROGRESS_SUCCESSFUL" "$PROGRESS_FAILED"
    # En mode TTY, progress_update n'a pas terminé par \n → on en ajoute une.
    # En mode plain (non-TTY), chaque update finit déjà par \n → on évite le
    # saut de ligne en trop pour ne pas polluer les logs.
    if [ -t 1 ] && [ "${DOTFILES_PROGRESS_PLAIN:-0}" != "1" ]; then
        echo ""
    fi
    
    # Afficher le résumé final si demandé
    if [ "$show_summary" = "true" ] || [ "$show_summary" = "1" ] || [ "$show_summary" = "yes" ]; then
        CURRENT_TIME=$(date +%s 2>/dev/null || echo 0)
        if [ "$PROGRESS_START_TIME" -gt 0 ]; then
            TOTAL_TIME=$((CURRENT_TIME - PROGRESS_START_TIME))
        else
            TOTAL_TIME=0
        fi
        
        TOTAL_TIME_HOURS=$((TOTAL_TIME / 3600))
        TOTAL_TIME_MINUTES=$((TOTAL_TIME % 3600 / 60))
        TOTAL_TIME_SECONDS=$((TOTAL_TIME % 60))
        TOTAL_TIME_STR=$(printf '%02d:%02d:%02d' "$TOTAL_TIME_HOURS" "$TOTAL_TIME_MINUTES" "$TOTAL_TIME_SECONDS")
        
        echo "═══════════════════════════════════════════════════════════════"
        echo "📊 RÉSUMÉ - $PROGRESS_DESCRIPTION"
        echo "═══════════════════════════════════════════════════════════════"
        echo "⏱️  Temps total: ${TOTAL_TIME_STR}"
        
        if [ "$PROGRESS_TOTAL" -gt 0 ]; then
            SUCCESS_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($PROGRESS_SUCCESSFUL / $PROGRESS_TOTAL) * 100}" 2>/dev/null || echo "0")
            FAILED_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($PROGRESS_FAILED / $PROGRESS_TOTAL) * 100}" 2>/dev/null || echo "0")
            echo "✅ Réussis: $PROGRESS_SUCCESSFUL ($SUCCESS_PERCENT%)"
            echo "❌ Échoués: $PROGRESS_FAILED ($FAILED_PERCENT%)"
        else
            echo "✅ Réussis: $PROGRESS_SUCCESSFUL"
            echo "❌ Échoués: $PROGRESS_FAILED"
        fi
        echo "═══════════════════════════════════════════════════════════════"
    fi
}

# =============================================================================
# Réinitialiser la progression
# =============================================================================
# Usage: progress_reset
# =============================================================================
progress_reset() {
    PROGRESS_START_TIME=0
    PROGRESS_TOTAL=0
    PROGRESS_COMPLETED=0
    PROGRESS_SUCCESSFUL=0
    PROGRESS_FAILED=0
    PROGRESS_DESCRIPTION="Traitement"
}

