#!/bin/bash

################################################################################
# Désinstallation Go (Golang)
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation Go (Golang)"

log_warn "⚠️  Cette opération va supprimer Go"
log_warn "⚠️  Cela inclut :"
echo "  - Go binaire"
echo "  - GOROOT/GOPATH (optionnel)"
echo "  - Packages Go installés (optionnel)"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

GO_ROOT="/usr/local/go"
GO_BIN="/usr/local/bin/go"
GOPATH_DIR="$HOME/go"

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    DISTRO="manual"
fi

# Désinstallation selon la distribution
case "$DISTRO" in
    arch)
        log_info "Suppression Go (Arch)..."
        if pacman -Q go &> /dev/null 2>&1; then
            sudo pacman -Rns --noconfirm go 2>/dev/null && log_info "✓ Go supprimé via pacman" || log_warn "Impossible de supprimer via pacman"
        elif [ -d "$GO_ROOT" ]; then
            log_info "Suppression installation manuelle..."
            sudo rm -rf "$GO_ROOT" && log_info "✓ Go supprimé" || log_warn "Impossible de supprimer"
            sudo rm -f "$GO_BIN" 2>/dev/null || true
        fi
        ;;
    debian|fedora)
        log_info "Suppression Go (via gestionnaire)..."
        if [ "$DISTRO" = "debian" ]; then
            sudo apt remove -y golang-go 2>/dev/null && log_info "✓ Go supprimé" || log_warn "Impossible de supprimer via apt"
        else
            sudo dnf remove -y golang 2>/dev/null && log_info "✓ Go supprimé" || log_warn "Impossible de supprimer via dnf"
        fi
        
        # Vérifier installation manuelle
        if [ -d "$GO_ROOT" ]; then
            log_info "Suppression installation manuelle..."
            sudo rm -rf "$GO_ROOT" && log_info "✓ Go supprimé" || log_warn "Impossible de supprimer"
            sudo rm -f "$GO_BIN" 2>/dev/null || true
        fi
        ;;
    manual|*)
        log_info "Suppression installation manuelle..."
        if [ -d "$GO_ROOT" ]; then
            sudo rm -rf "$GO_ROOT" && log_info "✓ Go supprimé" || log_warn "Impossible de supprimer"
            sudo rm -f "$GO_BIN" 2>/dev/null || true
        else
            log_warn "Go non trouvé dans $GO_ROOT"
        fi
        ;;
esac

# Supprimer GOPATH (optionnel)
if [ -d "$GOPATH_DIR" ]; then
    log_warn "⚠️  Supprimer aussi GOPATH ($GOPATH_DIR)?"
    printf "Supprimer GOPATH? (o/n): "
    read -r remove_gopath
    if [[ "$remove_gopath" =~ ^[oO]$ ]]; then
        rm -rf "$GOPATH_DIR" && log_info "✓ GOPATH supprimé" || log_warn "Impossible de supprimer GOPATH"
    fi
fi

# Retirer du PATH (optionnel)
log_warn "⚠️  Retirer Go du PATH dans env.sh?"
printf "Retirer du PATH? (o/n): "
read -r remove_path
if [[ "$remove_path" =~ ^[oO]$ ]]; then
    # Supprimer les lignes Go de env.sh
    sed -i '/export PATH.*go\/bin/d' "$HOME/dotfiles/zsh/env.sh" 2>/dev/null
    sed -i '/export GOPATH/d' "$HOME/dotfiles/zsh/env.sh" 2>/dev/null
    sed -i '/export GOROOT/d' "$HOME/dotfiles/zsh/env.sh" 2>/dev/null
    log_info "✓ Go retiré du PATH"
fi

log_info "✅ Désinstallation Go terminée"

