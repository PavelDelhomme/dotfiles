#!/bin/bash
# =============================================================================
# Script de sécurisation des dossiers des managers
# =============================================================================
# Description: Sécurise les dossiers cachés créés par les managers
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

# =============================================================================
# DÉFINITION DES DOSSIERS À SÉCURISER
# =============================================================================

declare -a SECURE_DIRS=(
    "$HOME/.cyberman"
    "$HOME/.cyberlearn"
)

# =============================================================================
# FONCTION DE SÉCURISATION
# =============================================================================

secure_directory() {
    local dir="$1"
    local dir_name=$(basename "$dir")
    
    if [ ! -d "$dir" ]; then
        log_warn "Dossier $dir n'existe pas, création..."
        mkdir -p "$dir"
    fi
    
    # Vérifier le propriétaire
    local owner=$(stat -c '%U' "$dir" 2>/dev/null || stat -f '%Su' "$dir" 2>/dev/null)
    if [ "$owner" != "$USER" ]; then
        log_warn "Propriétaire incorrect pour $dir (actuel: $owner, attendu: $USER)"
        log_info "Correction du propriétaire..."
        chown -R "$USER:$USER" "$dir" 2>/dev/null || {
            log_error "Impossible de changer le propriétaire (besoin de sudo?)"
            return 1
        }
    fi
    
    # Appliquer les permissions
    log_info "Sécurisation de $dir..."
    
    # Dossier principal : 700 (rwx------)
    chmod 700 "$dir" 2>/dev/null || {
        log_error "Impossible de changer les permissions de $dir"
        return 1
    }
    
    # Sous-dossiers : 700
    find "$dir" -type d -exec chmod 700 {} \; 2>/dev/null || true
    
    # Fichiers : 600 (rw-------)
    find "$dir" -type f -exec chmod 600 {} \; 2>/dev/null || true
    
    log_info "✓ $dir sécurisé (700 pour dossiers, 600 pour fichiers)"
}

# =============================================================================
# VÉRIFICATION DES PERMISSIONS
# =============================================================================

check_permissions() {
    local dir="$1"
    local dir_name=$(basename "$dir")
    
    if [ ! -d "$dir" ]; then
        return 0  # N'existe pas, pas de problème
    fi
    
    local perms=$(stat -c '%a' "$dir" 2>/dev/null || stat -f '%A' "$dir" 2>/dev/null)
    
    # Vérifier que les permissions sont 700 ou plus restrictives
    if [ "$perms" != "700" ] && [ "$perms" != "750" ] && [ "$perms" != "755" ]; then
        # Extraire les permissions du groupe et autres
        local group_perm=$((perms % 100 / 10))
        local other_perm=$((perms % 10))
        
        if [ "$group_perm" -gt 0 ] || [ "$other_perm" -gt 0 ]; then
            log_warn "Permissions trop permissives pour $dir (actuel: $perms)"
            return 1
        fi
    fi
    
    return 0
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    log_section "Sécurisation des dossiers des managers"
    
    local needs_fix=0
    
    # Vérifier les permissions actuelles
    log_info "Vérification des permissions..."
    for dir in "${SECURE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            if ! check_permissions "$dir"; then
                needs_fix=1
            fi
        fi
    done
    
    if [ $needs_fix -eq 0 ]; then
        log_info "✓ Toutes les permissions sont correctes"
        return 0
    fi
    
    echo ""
    log_warn "Certains dossiers ont des permissions trop permissives"
    read -p "Corriger automatiquement? (o/N): " confirm
    
    if [[ ! "$confirm" =~ ^[oO]$ ]]; then
        log_info "Annulé"
        return 0
    fi
    
    # Sécuriser chaque dossier
    for dir in "${SECURE_DIRS[@]}"; do
        secure_directory "$dir"
    done
    
    log_section "Sécurisation terminée"
    log_info "✓ Tous les dossiers sont maintenant sécurisés"
}

# Exécuter si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

