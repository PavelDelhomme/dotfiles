#!/bin/bash

################################################################################
# Synchronisation automatique Git pour dotfiles
# Push/pull toutes les heures seulement s'il y a des modifications
# Usage: À exécuter via cron ou systemd timer
################################################################################

set -e

# Charger la bibliothèque commune (juste les couleurs, on redéfinit les fonctions de log)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    # Fallback si common.sh n'est pas disponible
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export NC='\033[0m'
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
LOG_FILE="$DOTFILES_DIR/logs/auto_sync.log"
LOCK_FILE="/tmp/dotfiles_auto_sync.lock"
SYNC_INTERVAL=3600  # 1 heure en secondes

# Fonctions de log personnalisées avec tee (pour écrire dans le fichier et afficher)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

# Vérifier le lock file pour éviter les exécutions simultanées
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        log_warn "Synchronisation déjà en cours (PID: $PID)"
        exit 0
    else
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Vérifier que le dossier dotfiles existe
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dossier dotfiles non trouvé: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Vérifier que c'est un repo git
if [ ! -d ".git" ]; then
    log_error "Ce n'est pas un dépôt Git!"
    exit 1
fi

log "════════════════════════════════════════════════"
log "Début synchronisation automatique dotfiles"
log "════════════════════════════════════════════════"

# 1. PULL - Récupérer les modifications distantes
log "Récupération des modifications distantes..."
BRANCH=$(git branch --show-current)
REMOTE="origin"

# Vérifier si le remote existe
if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    log_warn "Remote '$REMOTE' non configuré, synchronisation annulée"
    exit 0
fi

# Pull avec rebase pour éviter les merges inutiles
if git fetch "$REMOTE" "$BRANCH" 2>&1 | tee -a "$LOG_FILE"; then
    LOCAL=$(git rev-parse HEAD)
    REMOTE_REF=$(git rev-parse "$REMOTE/$BRANCH" 2>/dev/null || echo "")
    
    if [ -n "$REMOTE_REF" ] && [ "$LOCAL" != "$REMOTE_REF" ]; then
        log_info "Modifications distantes détectées, pull en cours..."
        if git pull --rebase "$REMOTE" "$BRANCH" 2>&1 | tee -a "$LOG_FILE"; then
            log_info "✓ Pull réussi"
        else
            log_error "✗ Erreur lors du pull (conflits possibles)"
            # En cas de conflit, on ne force pas, on laisse l'utilisateur gérer
        fi
    else
        log_info "✓ Déjà à jour avec le remote"
    fi
else
    log_warn "Impossible de fetch (pas de connexion?)"
fi

# 2. PUSH - Envoyer les modifications locales
log "Vérification des modifications locales..."

# Vérifier s'il y a des modifications non commitées
if [ -n "$(git status --porcelain)" ]; then
    log_info "Modifications détectées, commit automatique..."
    
    # Ajouter tous les fichiers modifiés
    git add -A
    
    # Commit avec timestamp
    COMMIT_MSG="Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
    if git commit -m "$COMMIT_MSG" 2>&1 | tee -a "$LOG_FILE"; then
        log_info "✓ Commit créé: $COMMIT_MSG"
        
        # Push vers le remote
        if git push "$REMOTE" "$BRANCH" 2>&1 | tee -a "$LOG_FILE"; then
            log_info "✓ Push réussi vers $REMOTE/$BRANCH"
        else
            log_error "✗ Erreur lors du push"
        fi
    else
        log_warn "Aucun changement à committer (peut-être déjà commité?)"
    fi
else
    log_info "✓ Aucune modification locale"
fi

log "════════════════════════════════════════════════"
log "Synchronisation terminée"
log "════════════════════════════════════════════════"
log ""

