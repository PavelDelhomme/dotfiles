#!/bin/bash
#!/bin/bash
# ~/dotfiles/auto_sync_dotfiles.sh - Synchronisation automatique avec GitHub

set -e

DOTFILES_DIR="$HOME/dotfiles"
LOG_FILE="$DOTFILES_DIR/auto_sync.log"

cd "$DOTFILES_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔄 Début de la synchronisation..." | tee -a "$LOG_FILE"

# Pull les changements distants
git pull origin main 2>&1 | tee -a "$LOG_FILE" || echo "⚠️ Aucun changement distant" | tee -a "$LOG_FILE"

# Vérifier s'il y a des changements locaux
if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Changements détectés, commit en cours..." | tee -a "$LOG_FILE"
    
    git add .
    git commit -m "Auto-sync $(date '+%Y-%m-%d %H:%M:%S')" 2>&1 | tee -a "$LOG_FILE"
    git push origin main 2>&1 | tee -a "$LOG_FILE"
    
    echo "✅ Synchronisation terminée avec succès" | tee -a "$LOG_FILE"
else
    echo "ℹ️  Aucun changement local à synchroniser" | tee -a "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Fin de la synchronisation" | tee -a "$LOG_FILE"
