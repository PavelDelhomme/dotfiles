#!/bin/zsh
# =============================================================================
# Pyenv — Python côte à côte (module installman)
# =============================================================================
# Installe pyenv dans PYENV_ROOT (défaut ~/.pyenv). N’écrase pas le python
# système : la version « globale » pyenv est optionnelle et confirmée.
# Versions supplémentaires : variable PYENV_VERSIONS="3.11.9 3.12.3" (optionnel).
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

[[ -f "$INSTALLMAN_DIR/utils/logger.sh" ]] && source "$INSTALLMAN_DIR/utils/logger.sh"
[[ -f "$INSTALLMAN_DIR/utils/distro_detect.sh" ]] && source "$INSTALLMAN_DIR/utils/distro_detect.sh"
[[ -f "$INSTALLMAN_DIR/utils/installman_confirm.sh" ]] && source "$INSTALLMAN_DIR/utils/installman_confirm.sh"

install_pyenv() {
    log_step "Pyenv (Python isolés sous $PYENV_ROOT)…"

    if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
        log_info "pyenv déjà présent : $($PYENV_ROOT/bin/pyenv --version)"
        if installman_confirm "Mettre à jour pyenv (git pull dans $PYENV_ROOT) ?"; then
            (cd "$PYENV_ROOT" && git pull --ff-only) 2>/dev/null || true
        fi
    else
        installman_confirm "Cloner pyenv dans $PYENV_ROOT ?" || return 1
        mkdir -p "$(dirname "$PYENV_ROOT")"
        if [[ -d "$PYENV_ROOT" ]]; then
            log_error "Répertoire existant : $PYENV_ROOT"
            return 1
        fi
        git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT" || return 1
    fi

    local d
    d=$(detect_distro 2>/dev/null || echo unknown)
    log_info "Dépendances de compilation Python : installez build-essential / base-devel / etc. selon la doc pyenv si 'pyenv install' échoue."
    log_info "Distro détectée : $d — https://github.com/pyenv/pyenv/wiki#suggested-build-environment"

    if [[ -n "${PYENV_VERSIONS:-}" ]]; then
        local ver
        for ver in ${=PYENV_VERSIONS}; do
            installman_confirm "Compiler et installer Python $ver avec pyenv (long) ?" || continue
            "$PYENV_ROOT/bin/pyenv" install -s "$ver" || log_error "Échec pyenv install $ver"
        done
    fi

    if [[ -n "${PYENV_GLOBAL_VERSION:-}" ]]; then
        if installman_confirm "Définir pyenv global $PYENV_GLOBAL_VERSION (affecte les shells où pyenv est dans le PATH) ?"; then
            "$PYENV_ROOT/bin/pyenv" global "$PYENV_GLOBAL_VERSION" || return 1
        fi
    else
        log_info "Astuce : PYENV_GLOBAL_VERSION=3.12.3 installman pyenv pour fixer une version par défaut pyenv."
    fi

    log_info "Ajoutez à votre shell : export PYENV_ROOT=\"$PYENV_ROOT\" ; export PATH=\"\$PYENV_ROOT/bin:\$PATH\" ; eval \"\$(pyenv init -)\""
    log_info "✓ pyenv prêt."
    return 0
}
