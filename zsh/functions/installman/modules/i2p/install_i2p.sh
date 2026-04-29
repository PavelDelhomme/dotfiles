#!/bin/zsh
# =============================================================================
# INSTALLATION I2P (i2pd — Purple I2P) - Module installman
# =============================================================================
# Description: Routeur léger I2P (i2pd), multi-distributions
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"
[ -f "$INSTALLMAN_UTILS_DIR/check_installed.sh" ] && source "$INSTALLMAN_UTILS_DIR/check_installed.sh"
[ -f "$INSTALLMAN_UTILS_DIR/installman_confirm.sh" ] && source "$INSTALLMAN_UTILS_DIR/installman_confirm.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# DESC: Active le service i2pd si systemd est disponible
_install_i2p_enable_service() {
    if command -v systemctl &>/dev/null; then
        if [[ -f /usr/lib/systemd/system/i2pd.service ]] || [[ -f /lib/systemd/system/i2pd.service ]]; then
            log_step "Activation du service i2pd (systemd)..."
            sudo systemctl enable --now i2pd 2>/dev/null || log_warn "Impossible d'activer i2pd automatiquement (sudo / unité absente)."
        fi
    fi
}

# DESC: Installe i2pd (réseau I2P, implémentation C++ « Purple I2P »)
# USAGE: install_i2p
install_i2p() {
    log_step "Installation d'I2P (i2pd)..."

    if [[ "$(check_i2p_installed 2>/dev/null)" == installed ]]; then
        log_info "i2pd semble déjà installé."
        read "reinstall?Réinstaller ou mettre à jour ? (o/N): "
        if [[ ! "$reinstall" =~ ^[oOyY]$ ]]; then
            log_info "Installation ignorée."
            return 0
        fi
    fi

    local distro
    distro=$(detect_distro)
    local install_success=false

    case "$distro" in
        arch|manjaro)
            log_step "Installation via pacman (Arch / Manjaro)..."
            if sudo pacman -S --needed --noconfirm i2pd 2>/dev/null; then
                install_success=true
            elif command -v yay &>/dev/null && yay -S --needed --noconfirm i2pd; then
                install_success=true
            elif command -v pamac &>/dev/null && sudo pamac install --no-confirm i2pd; then
                install_success=true
            fi
            ;;
        debian|ubuntu)
            log_step "Installation via apt (Debian / Ubuntu)..."
            if sudo apt-get update && sudo apt-get install -y i2pd 2>/dev/null; then
                install_success=true
            elif sudo apt-get install -y i2p 2>/dev/null; then
                log_info "Paquet « i2p » (Java) installé à la place d'i2pd."
                install_success=true
            fi
            ;;
        fedora)
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y i2pd && install_success=true
            ;;
        alpine)
            log_step "Installation via apk (Alpine)..."
            sudo apk add --no-cache i2pd && install_success=true
            ;;
        gentoo)
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q net-vpn/i2pd && install_success=true
            ;;
        opensuse)
            log_step "Installation via zypper (openSUSE)..."
            sudo zypper install -y i2pd && install_success=true
            ;;
        centos)
            log_step "Installation via dnf/yum (CentOS / RHEL)..."
            if command -v dnf &>/dev/null; then
                sudo dnf install -y epel-release 2>/dev/null
                sudo dnf install -y i2pd 2>/dev/null && install_success=true
            elif command -v yum &>/dev/null; then
                sudo yum install -y epel-release && sudo yum install -y i2pd && install_success=true
            fi
            ;;
        *)
            log_warn "Distribution non reconnue : $distro — tentative générique."
            if install_package i2pd auto; then
                install_success=true
            elif install_package i2p auto; then
                install_success=true
            fi
            ;;
    esac

    if [[ "$install_success" == true ]]; then
        if command -v i2pd &>/dev/null; then
            log_info "i2pd : $(i2pd --version 2>/dev/null | head -n1 || echo version inconnue)"
            _install_i2p_enable_service
            log_info "HTTP proxy I2P typique : http://127.0.0.1:4444 — SOCKS : 127.0.0.1:4447 (selon i2pd.conf)."
            return 0
        fi
        if command -v i2prouter &>/dev/null || [[ -f /usr/share/i2p/i2prouter ]]; then
            log_info "Routeur Java I2P détecté ; lancez i2prouter ou le raccourci bureau I2P."
            return 0
        fi
        log_warn "Installation signalée comme réussie mais aucun binaire i2pd / i2prouter trouvé dans le PATH."
        return 1
    fi

    log_error "Échec de l'installation i2pd. Essayez le paquet « i2pd » ou « i2p » selon votre dépôt."
    return 1
}
