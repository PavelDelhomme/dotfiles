#!/bin/zsh
# =============================================================================
# Ollama — module installman
# =============================================================================
# Paquets / script officiel selon la distro. Redémarrages systemd : demande.
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[[ -f "$INSTALLMAN_DIR/utils/logger.sh" ]] && source "$INSTALLMAN_DIR/utils/logger.sh"
[[ -f "$INSTALLMAN_DIR/utils/distro_detect.sh" ]] && source "$INSTALLMAN_DIR/utils/distro_detect.sh"
[[ -f "$INSTALLMAN_DIR/utils/installman_confirm.sh" ]] && source "$INSTALLMAN_DIR/utils/installman_confirm.sh"

install_ollama() {
    log_step "Ollama (LLM local)…"

    if command -v ollama &>/dev/null; then
        log_info "Ollama est déjà présent : $(ollama --version 2>/dev/null || echo ok)"
        if installman_confirm "Réinstaller / réexécuter le flux d'installation ?"; then
            :
        else
            return 0
        fi
    fi

    local d
    d=$(detect_distro 2>/dev/null || echo unknown)

    case "$d" in
        arch|manjaro)
            if ! installman_confirm "Installer ollama via pacman (sudo) ?"; then
                log_info "Annulé."
                return 1
            fi
            sudo pacman -S --needed --noconfirm ollama || return 1
            ;;
        debian|ubuntu)
            if ! installman_confirm "Télécharger et exécuter le script officiel ollama.com (curl|sh) ?"; then
                return 1
            fi
            curl -fsSL https://ollama.com/install.sh | sh || return 1
            ;;
        fedora)
            if ! installman_confirm "Installer ollama via dnf (sudo) ?"; then
                return 1
            fi
            sudo dnf install -y ollama 2>/dev/null || curl -fsSL https://ollama.com/install.sh | sh || return 1
            ;;
        *)
            if ! installman_confirm "Distro non détectée : utiliser le script officiel curl|sh ?"; then
                return 1
            fi
            curl -fsSL https://ollama.com/install.sh | sh || return 1
            ;;
    esac

    if installman_confirm "Activer le service systemd ollama (sudo systemctl enable --now ollama) ?"; then
        sudo systemctl enable --now ollama.service 2>/dev/null || log_info "(service ollama non disponible ou déjà actif — ignorer si installation userland)"
    fi

    log_info "✓ Terminé. Test : ollama run llama3.2:1b"
    return 0
}
