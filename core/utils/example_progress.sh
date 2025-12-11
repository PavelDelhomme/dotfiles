#!/bin/sh
# =============================================================================
# EXEMPLE - Utilisation de progress_bar.sh
# =============================================================================
# Description: Exemple d'utilisation de la barre de progression
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger le script de progression
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROGRESS_BAR="$DOTFILES_DIR/core/utils/progress_bar.sh"

if [ -f "$PROGRESS_BAR" ]; then
    . "$PROGRESS_BAR"
else
    echo "❌ Erreur: progress_bar.sh non trouvé: $PROGRESS_BAR"
    exit 1
fi

echo "🚀 Exemple d'utilisation de la barre de progression"
echo ""

# Initialiser avec 50 éléments
progress_init 50 "Traitement de fichiers"

successful=0
failed=0

# Simuler un traitement
i=1
while [ "$i" -le 50 ]; do
    sleep 0.1  # Simuler un délai
    
    # Simuler un résultat aléatoire (70% de réussite)
    # Utiliser $RANDOM si disponible (Bash/ZSH), sinon utiliser date
    if command -v shuf >/dev/null 2>&1; then
        random_val=$(shuf -i 0-9 -n 1)
    elif [ -n "$RANDOM" ]; then
        random_val=$((RANDOM % 10))
    else
        # Fallback: utiliser les microsecondes
        random_val=$(date +%N 2>/dev/null | sed 's/^0*//' || echo "0")
        random_val=$((random_val % 10))
    fi
    
    if [ "$random_val" -lt 7 ]; then
        successful=$((successful + 1))
    else
        failed=$((failed + 1))
    fi
    
    # Mettre à jour la progression
    progress_update "$i" "$successful" "$failed"
    
    i=$((i + 1))
done

# Terminer et afficher le résumé
progress_finish

echo ""
echo "✅ Exemple terminé !"

