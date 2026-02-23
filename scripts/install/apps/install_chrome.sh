#!/bin/bash
################################################################################
# Installation Google Chrome (navigateur officiel)
# Source: https://www.google.com/chrome/
# Support: Arch Linux (AUR), Debian/Ubuntu (.deb), Fedora (.rpm)
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    echo "Erreur: Impossible de charger scripts/lib/common.sh"
    exit 1
}

log_section "Installation Google Chrome"

# Détection distribution
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

case "$DISTRO" in
    arch)
        log_info "Arch Linux: installation via AUR (google-chrome)"
        if command -v yay &>/dev/null; then
            yay -S google-chrome --noconfirm
        elif command -v paru &>/dev/null; then
            paru -S google-chrome --noconfirm
        else
            log_error "Installez yay ou paru puis: yay -S google-chrome"
            log_info "Ou téléchargez le .deb et installez avec debtap"
            exit 1
        fi
        log_info "✓ Google Chrome installé"
        ;;
    debian)
        log_info "Téléchargement depuis https://dl.google.com/linux/direct/..."
        CHROME_DEB="/tmp/google-chrome-stable_current_amd64.deb"
        if ! curl -sL -o "$CHROME_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"; then
            log_error "Échec du téléchargement. Vérifiez https://www.google.com/chrome/"
            exit 1
        fi
        sudo apt-get update
        sudo apt-get install -y "$CHROME_DEB" || { sudo dpkg -i "$CHROME_DEB"; sudo apt-get install -f -y; }
        rm -f "$CHROME_DEB"
        log_info "✓ Google Chrome installé"
        ;;
    fedora)
        log_info "Téléchargement du .rpm depuis Google..."
        CHROME_RPM="/tmp/google-chrome-stable_current_x86_64.rpm"
        if ! curl -sL -o "$CHROME_RPM" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"; then
            log_error "Échec du téléchargement. Vérifiez https://www.google.com/chrome/"
            exit 1
        fi
        sudo dnf install -y "$CHROME_RPM" || sudo rpm -Uvh "$CHROME_RPM"
        rm -f "$CHROME_RPM"
        log_info "✓ Google Chrome installé"
        ;;
    *)
        log_error "Distribution non reconnue"
        log_info "Téléchargez manuellement: https://www.google.com/chrome/"
        log_info "  .deb (Debian/Ubuntu): https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        log_info "  .rpm (Fedora): https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
        exit 1
        ;;
esac

if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
    CHROME_CMD=$(command -v google-chrome 2>/dev/null || command -v google-chrome-stable 2>/dev/null)
    log_info "✅ Google Chrome installé: $($CHROME_CMD --version 2>/dev/null || echo 'OK')"
else
    log_info "✅ Installation terminée. Lancez Chrome depuis le menu applications."
fi

echo ""
log_info "Pour lancer: google-chrome ou google-chrome-stable"
echo ""
