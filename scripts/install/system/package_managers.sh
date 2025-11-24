#!/bin/bash

################################################################################
# Installation gestionnaires de paquets - Module
# yay, snap, flatpak
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

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
    sudo pacman -S --needed --noconfirm git base-devel || log_warn "Erreur installation dépendances yay"
    
    YAY_TMP_DIR="/tmp/yay"
    # Nettoyer si existe déjà
    if [ -d "$YAY_TMP_DIR" ]; then
        log_info "Nettoyage du dossier temporaire..."
        rm -rf "$YAY_TMP_DIR"
    fi
    
    # Vérifier aussi dans le répertoire courant
    if [ -d "yay" ]; then
        log_warn "Répertoire 'yay' trouvé dans le répertoire courant, nettoyage..."
        rm -rf "yay"
    fi
    
    cd /tmp
    if git clone https://aur.archlinux.org/yay.git "$YAY_TMP_DIR" 2>/dev/null; then
        cd "$YAY_TMP_DIR"
        if makepkg -si --noconfirm 2>&1; then
            log_info "✓ yay installé"
        else
            log_warn "Erreur lors de la compilation de yay (peut être dû à des dépendances)"
            log_warn "Essayez: sudo pacman -Syu puis réessayez"
        fi
        cd /tmp
        rm -rf "$YAY_TMP_DIR"
    else
        log_warn "Erreur lors du clonage de yay (vérifiez votre connexion)"
    fi
    cd ~
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
