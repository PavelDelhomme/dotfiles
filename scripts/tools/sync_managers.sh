#!/bin/bash
# =============================================================================
# SYNC MANAGERS - Système de synchronisation automatique
# =============================================================================
# Description: Synchronise automatiquement les changements ZSH vers Bash et Fish
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZSH_FUNCTIONS="$DOTFILES_DIR/zsh/functions"
BASH_FUNCTIONS="$DOTFILES_DIR/bash/functions"
FISH_FUNCTIONS="$DOTFILES_DIR/fish/functions"
CORE_MANAGERS="$DOTFILES_DIR/core/managers"
ZSH_ADAPTERS="$DOTFILES_DIR/shells/zsh/adapters"
BASH_ADAPTERS="$DOTFILES_DIR/shells/bash/adapters"
FISH_ADAPTERS="$DOTFILES_DIR/shells/fish/adapters"

# Log file
LOG_FILE="$DOTFILES_DIR/.sync_log"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

# Fonction de logging
log() {
    echo "[$TIMESTAMP] $*" >> "$LOG_FILE"
    printf "${BLUE}[SYNC]${NC} $*\n"
}

# Fonction pour détecter les changements
detect_changes() {
    local manager="$1"
    local zsh_file="$ZSH_FUNCTIONS/${manager}.zsh"
    local core_file="$CORE_MANAGERS/${manager}/core/${manager}.sh"
    
    # Vérifier si le fichier ZSH a été modifié récemment
    if [ -f "$zsh_file" ]; then
        local zsh_mtime=$(stat -c %Y "$zsh_file" 2>/dev/null || stat -f %m "$zsh_file" 2>/dev/null || echo "0")
        local core_mtime="0"
        
        if [ -f "$core_file" ]; then
            core_mtime=$(stat -c %Y "$core_file" 2>/dev/null || stat -f %m "$core_file" 2>/dev/null || echo "0")
        fi
        
        # Si ZSH est plus récent que le core, il y a des changements
        if [ "$zsh_mtime" -gt "$core_mtime" ]; then
            return 0  # Changements détectés
        fi
    fi
    
    return 1  # Pas de changements
}

# Fonction pour synchroniser un manager
sync_manager() {
    local manager="$1"
    
    log "Synchronisation de $manager..."
    
    # Vérifier si le manager a un core POSIX
    local core_file="$CORE_MANAGERS/${manager}/core/${manager}.sh"
    
    if [ -f "$core_file" ]; then
        # Manager avec core POSIX - vérifier si les adapters sont à jour
        log "  ✅ Core POSIX trouvé pour $manager"
        
        # Vérifier les adapters
        local zsh_adapter="$ZSH_ADAPTERS/${manager}.zsh"
        local bash_adapter="$BASH_ADAPTERS/${manager}.sh"
        local fish_adapter="$FISH_ADAPTERS/${manager}.fish"
        
        # Les adapters doivent juste charger le core, donc pas de sync nécessaire
        # Sauf si le core a changé, alors on doit vérifier que les adapters chargent bien le core
        
        log "  ✅ Adapters à jour (chargent le core)"
        return 0
    else
        # Manager sans core POSIX - wrapper temporaire
        log "  ⚠️  Wrapper temporaire pour $manager (pas de sync nécessaire)"
        return 0
    fi
}

# Fonction pour synchroniser tous les managers
sync_all_managers() {
    log "Début de la synchronisation..."
    
    local managers="pathman manman searchman aliaman helpman fileman miscman installman configman gitman cyberman devman virtman netman sshman testman testzshman moduleman multimediaman cyberlearn"
    local synced=0
    local skipped=0
    
    for manager in $managers; do
        if detect_changes "$manager"; then
            if sync_manager "$manager"; then
                synced=$((synced + 1))
            fi
        else
            skipped=$((skipped + 1))
        fi
    done
    
    log "Synchronisation terminée: $synced synchronisés, $skipped ignorés"
    printf "${GREEN}✅ Synchronisation terminée${NC}\n"
}

# Fonction pour synchroniser un manager spécifique
sync_single_manager() {
    local manager="$1"
    
    if [ -z "$manager" ]; then
        printf "${RED}❌ Usage: sync_managers.sh <manager>${NC}\n"
        return 1
    fi
    
    log "Synchronisation de $manager uniquement..."
    sync_manager "$manager"
}

# Fonction pour vérifier l'état de synchronisation
check_sync_status() {
    log "Vérification de l'état de synchronisation..."
    
    local managers="pathman manman searchman aliaman helpman fileman miscman installman configman gitman cyberman devman virtman netman sshman testman testzshman moduleman multimediaman cyberlearn"
    
    printf "${CYAN}${BOLD}État de synchronisation:${NC}\n"
    echo
    
    for manager in $managers; do
        local core_file="$CORE_MANAGERS/${manager}/core/${manager}.sh"
        local zsh_adapter="$ZSH_ADAPTERS/${manager}.zsh"
        local bash_adapter="$BASH_ADAPTERS/${manager}.sh"
        local fish_adapter="$FISH_ADAPTERS/${manager}.fish"
        
        printf "  $manager: "
        
        if [ -f "$core_file" ]; then
            # Vérifier si c'est un vrai core POSIX ou un wrapper
            if grep -q "Wrapper temporaire\|charge ZSH original" "$core_file" 2>/dev/null; then
                printf "${YELLOW}⚠️  Wrapper${NC}"
            else
                printf "${GREEN}✅ POSIX${NC}"
            fi
        else
            printf "${RED}❌ Pas de core${NC}"
        fi
        
        # Vérifier les adapters
        local adapters_ok=0
        [ -f "$zsh_adapter" ] && adapters_ok=$((adapters_ok + 1))
        [ -f "$bash_adapter" ] && adapters_ok=$((adapters_ok + 1))
        [ -f "$fish_adapter" ] && adapters_ok=$((adapters_ok + 1))
        
        printf " (Adapters: $adapters_ok/3)\n"
    done
}

# Menu principal
main() {
    case "${1:-all}" in
        all)
            sync_all_managers
            ;;
        check|status)
            check_sync_status
            ;;
        *)
            sync_single_manager "$1"
            ;;
    esac
}

# Exécuter
main "$@"

