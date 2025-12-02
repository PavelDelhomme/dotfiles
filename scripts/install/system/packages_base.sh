#!/bin/bash

################################################################################
# Installation paquets de base - Module
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_info "Installation paquets de base..."

base_tools=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "base-devel" "zsh" "btop" "zsh-theme-powerlevel10k")
for tool in "${base_tools[@]}"; do
    if ! is_package_installed "$tool"; then
        log_info "Installation de $tool..."
        sudo pacman -S --noconfirm "$tool"
    else
        log_skip "$tool déjà installé"
    fi
done

log_info "✓ Paquets de base installés"
