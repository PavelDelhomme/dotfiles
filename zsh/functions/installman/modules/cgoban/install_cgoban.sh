#!/bin/zsh
# =============================================================================
# INSTALLATION CGOBAN — client Go KGS (/opt/cgoban.jar)
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
UPDATE_SCRIPT="${DOTFILES_DIR}/scripts/update/update-cgoban.sh"

# DESC: Installe CGoban (JAR officiel KGS) + raccourci + nettoie Téléchargements
# USAGE: install_cgoban
install_cgoban() {
    log_step "Installation de CGoban (KGS)…"

    # Obligatoire: JDK 11 (java.applet.Applet). Java 27 fait planter KGS.
    if [ ! -x /usr/lib/jvm/java-11-openjdk/bin/java ]; then
        log_info "Installation JDK 11 (requis pour CGoban / Applet)…"
        local distro
        distro=$(detect_distro 2>/dev/null || echo arch)
        case "$distro" in
            arch|manjaro)
                sudo pacman -S --needed --noconfirm jdk11-openjdk || {
                    log_error "Échec installation jdk11-openjdk"
                    return 1
                }
                ;;
            debian|ubuntu)
                sudo apt-get update && sudo apt-get install -y openjdk-11-jre || return 1
                ;;
            fedora)
                sudo dnf install -y java-11-openjdk || return 1
                ;;
            *)
                log_warn "Installe un JDK 11 manuellement puis relance installman cgoban"
                ;;
        esac
    fi

    if [ ! -x "$UPDATE_SCRIPT" ] && [ ! -f "$UPDATE_SCRIPT" ]; then
        log_error "Script introuvable: $UPDATE_SCRIPT"
        return 1
    fi
    chmod +x "$UPDATE_SCRIPT" 2>/dev/null || true

    bash "$UPDATE_SCRIPT" update || {
        log_error "Échec update-cgoban"
        return 1
    }

    # Activer timer updateman si présent
    if command -v updateman &>/dev/null; then
        updateman cgoban enable 2>/dev/null || true
    elif [ -f "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"
        updateman cgoban enable 2>/dev/null || true
    fi

    log_info "✓ CGoban prêt — alias: cgoban  |  updateman cgoban"
    return 0
}
