#!/bin/bash

################################################################################
# Script de réinitialisation complète - Remet tout à zéro
# Usage: bash ~/dotfiles/scripts/uninstall/reset_all.sh
# 
# Ce script fait un rollback complet puis propose de réinstaller
################################################################################

set +e  # Ne pas arrêter sur erreurs

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "RÉINITIALISATION COMPLÈTE - Remise à zéro"

################################################################################
# CONFIRMATION
################################################################################
log_warn "⚠️  ATTENTION : Ce script va :"
echo "  1. Désinstaller TOUT (comme rollback_all.sh)"
echo "  2. Supprimer le dossier dotfiles"
echo "  3. Proposer de réinstaller depuis zéro"
echo ""
printf "Continuer avec la réinitialisation? (tapez 'OUI' en majuscules): "
read -r confirmation

if [ "$confirmation" != "OUI" ]; then
    log_info "Réinitialisation annulée"
    exit 0
fi

################################################################################
# 1. ROLLBACK COMPLET
################################################################################
log_section "1. Rollback complet"

if [ -f "$HOME/dotfiles/scripts/uninstall/rollback_all.sh" ]; then
    log_info "Exécution du rollback complet..."
    bash "$HOME/dotfiles/scripts/uninstall/rollback_all.sh"
else
    log_warn "Script rollback_all.sh non trouvé, nettoyage manuel..."
    
    # Nettoyage manuel de base
    log_info "Arrêt services systemd..."
    systemctl --user stop dotfiles-sync.timer 2>/dev/null
    systemctl --user disable dotfiles-sync.timer 2>/dev/null
    rm -f "$HOME/.config/systemd/user/dotfiles-sync.service" 2>/dev/null
    rm -f "$HOME/.config/systemd/user/dotfiles-sync.timer" 2>/dev/null
    
    log_info "Nettoyage configuration Git..."
    git config --global --unset user.name 2>/dev/null || true
    git config --global --unset user.email 2>/dev/null || true
    git config --global --unset credential.helper 2>/dev/null || true
    
    log_info "Suppression clés SSH..."
    rm -f "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
fi

################################################################################
# 2. SUPPRESSION DOTFILES
################################################################################
log_section "2. Suppression du dossier dotfiles"

if [ -d "$HOME/dotfiles" ]; then
    log_warn "⚠️  Suppression du répertoire $HOME/dotfiles..."
    printf "Confirmer la suppression? (tapez 'OUI' en majuscules): "
    read -r confirm_delete
    if [ "$confirm_delete" = "OUI" ]; then
        rm -rf "$HOME/dotfiles"
        log_info "✓ Répertoire dotfiles supprimé"
    else
        log_warn "Suppression annulée, le dossier dotfiles sera conservé"
    fi
else
    log_info "Répertoire dotfiles non trouvé"
fi

################################################################################
# 3. NETTOYAGE .zshrc
################################################################################
log_section "3. Nettoyage .zshrc"

if [ -f "$HOME/.zshrc" ]; then
    if grep -q "dotfiles\|zshrc_custom" "$HOME/.zshrc" 2>/dev/null; then
        log_warn "Références dotfiles trouvées dans .zshrc"
        printf "Nettoyer .zshrc? (o/n) [défaut: o]: "
        read -r clean_zshrc
        clean_zshrc=${clean_zshrc:-o}
        
        if [[ "$clean_zshrc" =~ ^[oO]$ ]]; then
            # Créer un backup
            BACKUP_FILE="$HOME/.zshrc.backup_$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.zshrc" "$BACKUP_FILE"
            log_info "✓ Backup créé: $BACKUP_FILE"
            
            # Supprimer les lignes dotfiles
            sed -i '/# Dotfiles/,+2d' "$HOME/.zshrc" 2>/dev/null || \
            sed -i '/dotfiles/d' "$HOME/.zshrc" 2>/dev/null || \
            sed -i '/zshrc_custom/d' "$HOME/.zshrc" 2>/dev/null || true
            
            log_info "✓ .zshrc nettoyé"
        fi
    else
        log_info "Aucune référence dotfiles dans .zshrc"
    fi
fi

################################################################################
# 4. SUPPRESSION SYMLINKS
################################################################################
log_section "4. Suppression des symlinks"

SYMLINKS_TO_REMOVE=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_ed25519.pub"
    "$HOME/.ssh/config"
)

for symlink in "${SYMLINKS_TO_REMOVE[@]}"; do
    if [ -L "$symlink" ]; then
        LINK_TARGET=$(readlink "$symlink")
        if [[ "$LINK_TARGET" == *"dotfiles"* ]]; then
            log_info "Suppression symlink: $(basename "$symlink")"
            rm -f "$symlink" 2>/dev/null || true
        fi
    fi
done

################################################################################
# 5. PROPOSITION RÉINSTALLATION
################################################################################
log_section "Réinitialisation terminée!"

log_info "✅ Réinitialisation complète effectuée"
echo ""
log_warn "⚠️  Actions effectuées :"
echo "  - Rollback complet exécuté"
echo "  - Dossier dotfiles supprimé (si confirmé)"
echo "  - Configuration Git nettoyée"
echo "  - Clés SSH supprimées"
echo "  - Services systemd arrêtés"
echo "  - Symlinks supprimés"
echo "  - .zshrc nettoyé (si confirmé)"
echo ""

printf "Voulez-vous réinstaller les dotfiles maintenant? (o/n) [défaut: o]: "
read -r reinstall
reinstall=${reinstall:-o}

if [[ "$reinstall" =~ ^[oO]$ ]]; then
    log_info "Réinstallation des dotfiles..."
    echo ""
    log_info "Exécutez cette commande pour réinstaller :"
    echo ""
    echo "  curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
    echo ""
    printf "Exécuter maintenant? (o/n) [défaut: n]: "
    read -r run_now
    run_now=${run_now:-n}
    
    if [[ "$run_now" =~ ^[oO]$ ]]; then
        curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
    else
        log_info "Réinstallation manuelle requise"
    fi
else
    log_info "Réinstallation ignorée"
    echo ""
    log_info "Pour réinstaller plus tard :"
    echo "  curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
fi

echo ""
log_info "✅ Réinitialisation terminée!"

