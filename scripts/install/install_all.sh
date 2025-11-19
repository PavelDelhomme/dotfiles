#!/bin/bash

################################################################################
# Installation complète de tous les outils
# Git, Cursor, PortProton, QEMU/KVM
# Usage: bash scripts/install/install_all.sh [--skip-git] [--skip-cursor] [--skip-portproton] [--skip-qemu]
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$DOTFILES_DIR/scripts/install"

# Options
SKIP_GIT=false
SKIP_CURSOR=false
SKIP_PORTPROTON=false
SKIP_QEMU=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-git) SKIP_GIT=true; shift ;;
        --skip-cursor) SKIP_CURSOR=true; shift ;;
        --skip-portproton) SKIP_PORTPROTON=true; shift ;;
        --skip-qemu) SKIP_QEMU=true; shift ;;
        *) log_error "Option inconnue: $1"; exit 1 ;;
    esac
done

log_section "Installation complète - Tous les outils"

################################################################################
# 1. INSTALLATION GIT
################################################################################
if [ "$SKIP_GIT" = false ]; then
    log_section "Installation Git"
    
    if command -v git >/dev/null 2>&1; then
        log_info "Git déjà installé: $(git --version)"
    else
        log_info "Installation de Git..."
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm git
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        else
            log_error "Gestionnaire de paquets non supporté"
            exit 1
        fi
        log_info "✓ Git installé"
    fi
    
    # Configuration Git si pas déjà configuré
    if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
        log_info "Configuration Git globale..."
        git config --global user.name "Pactivisme"
        git config --global user.email "dev@delhomme.ovh"
        git config --global init.defaultBranch main
        git config --global core.editor vim
        git config --global color.ui auto
        log_info "✓ Git configuré"
    else
        log_info "Git déjà configuré: $(git config --global user.name)"
    fi
else
    log_warn "Installation Git ignorée (--skip-git)"
fi

################################################################################
# 2. INSTALLATION CURSOR
################################################################################
if [ "$SKIP_CURSOR" = false ]; then
    log_section "Installation Cursor"
    
    if [ -f "$SCRIPT_DIR/apps/install_cursor.sh" ]; then
        bash "$SCRIPT_DIR/apps/install_cursor.sh" --skip-check
        log_info "✓ Cursor installé"
    else
        log_error "Script install_cursor.sh non trouvé"
    fi
else
    log_warn "Installation Cursor ignorée (--skip-cursor)"
fi

################################################################################
# 3. INSTALLATION PORTPROTON
################################################################################
if [ "$SKIP_PORTPROTON" = false ]; then
    log_section "Installation PortProton"
    
    if [ -f "$SCRIPT_DIR/apps/install_portproton.sh" ]; then
        bash "$SCRIPT_DIR/apps/install_portproton.sh"
        log_info "✓ PortProton installé"
    else
        log_error "Script install_portproton.sh non trouvé"
    fi
else
    log_warn "Installation PortProton ignorée (--skip-portproton)"
fi

################################################################################
# 4. INSTALLATION QEMU/KVM
################################################################################
if [ "$SKIP_QEMU" = false ]; then
    log_section "Installation QEMU/KVM"
    
    if [ -f "$SCRIPT_DIR/install_qemu_simple.sh" ]; then
        bash "$SCRIPT_DIR/install_qemu_simple.sh"
        log_info "✓ QEMU/KVM installé"
        log_warn "⚠ IMPORTANT: Déconnectez-vous et reconnectez-vous pour que le groupe libvirt soit actif"
    else
        log_error "Script install_qemu_simple.sh non trouvé"
    fi
else
    log_warn "Installation QEMU ignorée (--skip-qemu)"
fi

################################################################################
# 5. INSTALLATION SYNCHRONISATION AUTOMATIQUE
################################################################################
log_section "Installation synchronisation automatique Git"

if [ -f "$DOTFILES_DIR/scripts/sync/install_auto_sync.sh" ]; then
    read -p "Installer la synchronisation automatique Git (toutes les heures)? (o/n) [défaut: o]: " install_sync
    install_sync=${install_sync:-o}
    
    if [[ "$install_sync" =~ ^[oO]$ ]]; then
        bash "$DOTFILES_DIR/scripts/sync/install_auto_sync.sh"
        log_info "✓ Synchronisation automatique installée"
    else
        log_warn "Synchronisation automatique ignorée"
    fi
else
    log_warn "Script install_auto_sync.sh non trouvé"
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
log_info "Résumé des installations:"
[ "$SKIP_GIT" = false ] && log_info "  ✓ Git"
[ "$SKIP_CURSOR" = false ] && log_info "  ✓ Cursor"
[ "$SKIP_PORTPROTON" = false ] && log_info "  ✓ PortProton"
[ "$SKIP_QEMU" = false ] && log_info "  ✓ QEMU/KVM"
echo ""
log_warn "Prochaines étapes:"
echo "  1. Si QEMU installé: déconnectez-vous et reconnectez-vous"
echo "  2. Rechargez votre shell: exec zsh"
echo "  3. Vérifiez les installations:"
echo "     - cursor (ou /opt/cursor.appimage)"
echo "     - portproton"
echo "     - virt-manager"
echo ""
