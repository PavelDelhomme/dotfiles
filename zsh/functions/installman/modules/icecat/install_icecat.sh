#!/bin/zsh
# =============================================================================
# INSTALLATION GNU IceCat — Module installman (multi-distro)
# =============================================================================
# Arch/AUR : icecat / icecat-bin · Debian/Ubuntu : apt si dispo sinon Flatpak
# Fedora : dnf · Gentoo : emerge www-client/icecat · sinon Flatpak Flathub
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"
[ -f "$INSTALLMAN_UTILS_DIR/check_installed.sh" ] && source "$INSTALLMAN_UTILS_DIR/check_installed.sh"
[ -f "$INSTALLMAN_UTILS_DIR/installman_confirm.sh" ] && source "$INSTALLMAN_UTILS_DIR/installman_confirm.sh"

# DESC: Installe GNU IceCat (navigateur libre base Firefox ESR)
# USAGE: install_icecat
install_icecat() {
    log_step "Installation de GNU IceCat..."

    if [[ "$(check_icecat_installed 2>/dev/null)" == installed ]]; then
        log_info "IceCat semble déjà installé."
        if [[ -t 0 ]]; then
            read "reinstall?Réinstaller / mettre à jour ? (o/N): "
            [[ ! "$reinstall" =~ ^[oOyY]$ ]] && { log_info "Ignoré."; return 0; }
        else
            log_info "Déjà installé (non-TTY) — sortie."
            return 0
        fi
    fi

    local distro
    distro=$(detect_distro 2>/dev/null || echo unknown)
    local ok=false
    local method=""

    case "$distro" in
        arch|manjaro)
            log_step "Arch/Manjaro — pacman puis AUR (yay/paru)..."
            if sudo pacman -S --needed --noconfirm icecat 2>/dev/null; then
                ok=true; method="pacman/icecat"
            elif command -v yay &>/dev/null && yay -S --needed --noconfirm icecat-bin 2>/dev/null; then
                ok=true; method="AUR/icecat-bin"
            elif command -v yay &>/dev/null && yay -S --needed --noconfirm icecat 2>/dev/null; then
                ok=true; method="AUR/icecat"
            elif command -v paru &>/dev/null && paru -S --needed --noconfirm icecat-bin 2>/dev/null; then
                ok=true; method="paru/icecat-bin"
            fi
            ;;
        debian|ubuntu|kali)
            log_step "Debian/Ubuntu/Kali — apt puis Flatpak..."
            sudo apt-get update -qq 2>/dev/null || true
            if sudo apt-get install -y icecat 2>/dev/null; then
                ok=true; method="apt/icecat"
            elif sudo apt-get install -y iceweasel 2>/dev/null; then
                log_warn "iceweasel installé (ancien nom Debian) — IceCat natif indisponible."
                ok=true; method="apt/iceweasel"
            fi
            ;;
        fedora|rhel|centos)
            log_step "Fedora/RHEL — dnf..."
            if sudo dnf install -y icecat 2>/dev/null; then
                ok=true; method="dnf/icecat"
            fi
            ;;
        gentoo)
            log_step "Gentoo — emerge www-client/icecat..."
            if sudo emerge -q www-client/icecat 2>/dev/null; then
                ok=true; method="emerge/icecat"
            fi
            ;;
        opensuse)
            if sudo zypper install -y icecat 2>/dev/null; then
                ok=true; method="zypper/icecat"
            fi
            ;;
        alpine)
            log_warn "Alpine : paquet icecat rarement disponible — tentative Flatpak."
            ;;
        *)
            log_warn "Distro $distro — tentative générique puis Flatpak."
            if command -v install_package &>/dev/null && install_package icecat auto; then
                ok=true; method="install_package"
            fi
            ;;
    esac

    # Fallback Flatpak (universel)
    if [[ "$ok" != true ]] && command -v flatpak &>/dev/null; then
        log_step "Fallback Flatpak Flathub (org.gnu.icecat)..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        if flatpak install -y flathub org.gnu.icecat 2>/dev/null \
           || flatpak install -y flathub org.mozilla.firefox 2>/dev/null; then
            # Prefer genuine IceCat id if present
            if flatpak list --app 2>/dev/null | grep -qi icecat; then
                ok=true; method="flatpak/icecat"
            else
                log_warn "IceCat Flatpak introuvable ; Firefox Flatpak peut avoir été proposé — annule si non voulu."
            fi
        fi
    fi

    if [[ "$ok" == true ]]; then
        log_info "✓ IceCat installé via : $method"
        log_info "Lance : icecat   (ou flatpak run org.gnu.icecat)"
        return 0
    fi

    log_error "Échec IceCat. Sur Arch : yay -S icecat-bin · sinon Flatpak Flathub."
    return 1
}
