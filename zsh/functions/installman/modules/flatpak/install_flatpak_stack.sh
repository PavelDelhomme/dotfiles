#!/bin/zsh
# =============================================================================
# Flatpak + Flathub — module installman
# =============================================================================
# Installe le client flatpak selon la distro, ajoute le dépôt Flathub.
# Préfère l'installation utilisateur (--user) si pas de confirmation sudo.
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$INSTALLMAN_DIR/utils/logger.sh" ]] && source "$INSTALLMAN_DIR/utils/logger.sh"
[[ -f "$INSTALLMAN_DIR/utils/distro_detect.sh" ]] && source "$INSTALLMAN_DIR/utils/distro_detect.sh"
[[ -f "$INSTALLMAN_DIR/utils/installman_confirm.sh" ]] && source "$INSTALLMAN_DIR/utils/installman_confirm.sh"

FLATHUB_REPO="https://dl.flathub.org/repo/flathub.flatpakrepo"

install_flatpak_stack() {
    log_step "Flatpak + dépôt Flathub…"

    if ! command -v flatpak &>/dev/null; then
        local d
        d=$(detect_distro 2>/dev/null || echo unknown)
        case "$d" in
            arch|manjaro)
                installman_confirm "Installer flatpak via pacman (sudo) ?" || return 1
                sudo pacman -S --needed --noconfirm flatpak || return 1
                ;;
            debian|ubuntu)
                installman_confirm "Installer flatpak via apt (sudo) ?" || return 1
                sudo apt-get update && sudo apt-get install -y flatpak || return 1
                ;;
            fedora)
                installman_confirm "Installer flatpak via dnf (sudo) ?" || return 1
                sudo dnf install -y flatpak || return 1
                ;;
            *)
                log_error "Installez flatpak manuellement pour votre distro, puis relancez installman flatpak-stack."
                return 1
                ;;
        esac
    else
        log_info "flatpak déjà installé."
    fi

    if flatpak remotes 2>/dev/null | grep -qi flathub; then
        log_info "Dépôt flathub déjà configuré."
        return 0
    fi

    local use_user=0
    if installman_confirm "Ajouter Flathub en installation --user (sans toucher /usr) ? (N = tentative système)"; then
        use_user=1
    fi

    if [[ "$use_user" == 1 ]]; then
        flatpak remote-add --if-not-exists flathub "$FLATHUB_REPO" --user || return 1
    else
        installman_confirm "Ajouter Flathub au niveau système (sudo) ?" || return 1
        sudo flatpak remote-add --if-not-exists flathub "$FLATHUB_REPO" || return 1
    fi

    if installman_confirm "Lancer flatpak update (téléchargement méta) ?"; then
        flatpak update --noninteractive 2>/dev/null || flatpak update
    fi

    log_info "✓ Exemple : flatpak install flathub org.mozilla.firefox"
    return 0
}
