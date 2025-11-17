#!/bin/bash

################################################################################
# Installation paquets de base - Module
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_skip()  { echo -e "${BLUE}[→]${NC} $1"; }

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

log_info "Installation paquets de base..."

base_tools=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "base-devel" "zsh" "btop")
for tool in "${base_tools[@]}"; do
    if ! is_package_installed "$tool"; then
        log_info "Installation de $tool..."
        sudo pacman -S --noconfirm "$tool"
    else
        log_skip "$tool déjà installé"
    fi
done

log_info "✓ Paquets de base installés"

