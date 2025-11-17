#!/bin/bash

################################################################################
# Installation gestionnaires de paquets - Module
# yay, snap, flatpak
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

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

is_flatpak_installed() {
    flatpak list | grep -q "$1" 2>/dev/null
}

log_info "Installation gestionnaires de paquets..."

# yay
if ! is_installed "yay"; then
    log_info "Installation de yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    log_info "✓ yay installé"
else
    log_skip "yay déjà installé"
fi

# snapd
if ! is_package_installed "snapd"; then
    log_info "Installation de snapd..."
    sudo pacman -S --noconfirm snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
    log_info "✓ snapd installé"
else
    log_skip "snapd déjà installé"
    sudo systemctl start snapd.socket 2>/dev/null || true
fi

# flatpak
if ! is_package_installed "flatpak"; then
    log_info "Installation de flatpak..."
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    log_info "✓ flatpak installé"
else
    log_skip "flatpak déjà installé"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
fi

log_info "✓ Gestionnaires de paquets installés"

