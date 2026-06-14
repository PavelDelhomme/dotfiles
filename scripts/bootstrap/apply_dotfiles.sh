#!/usr/bin/env bash
################################################################################
# Re-apply dotfiles configuration on an existing machine.
#
# This is intentionally idempotent: it can be used after first bootstrap and later
# to converge the shell/prompt setup again.
################################################################################

set -u

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPT_DIR="$DOTFILES_DIR/scripts"
PROFILE="shell"
APPLY=0
INSTALL_MISSING=0
ASSUME_YES=0

if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    # shellcheck source=/dev/null
    . "$SCRIPT_DIR/lib/common.sh"
else
    log_info() { printf '[OK] %s\n' "$*"; }
    log_warn() { printf '[WARN] %s\n' "$*" >&2; }
    log_error() { printf '[ERR] %s\n' "$*" >&2; }
    log_section() { printf '\n== %s ==\n' "$*"; }
fi

usage() {
    cat <<'EOF'
Usage:
  apply_dotfiles.sh [shell|root|base] [--dry-run|--apply] [--install-missing] [--yes]

Profiles:
  shell   Reconfigure shell entrypoints and current Powerlevel10k design.
  root    Configure root prompt and sudo-compatible manager commands.
  base    Alias for shell for now; future-safe entry for broader bootstrap.

Examples:
  configman apply shell --dry-run
  configman apply shell --apply
  configman apply shell --apply --install-missing
  configman apply root --dry-run
  configman apply root --apply
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        shell|root|base) PROFILE="$1" ;;
        --apply) APPLY=1 ;;
        --dry-run) APPLY=0 ;;
        --install-missing) INSTALL_MISSING=1 ;;
        --yes|-y) ASSUME_YES=1 ;;
        --help|-h|help) usage; exit 0 ;;
        *) log_error "Argument inconnu: $1"; usage; exit 1 ;;
    esac
    shift
done

run_or_print() {
    if [ "$APPLY" -eq 1 ]; then
        log_info "+ $*"
        "$@"
    else
        printf '[dry-run] %s\n' "$*"
    fi
}

backup_path() {
    _path="$1"
    [ -e "$_path" ] || [ -L "$_path" ] || return 0
    _backup_dir="$HOME/.dotfiles_reapply_backup_$(date +%Y%m%d_%H%M%S)"
    run_or_print mkdir -p "$_backup_dir"
    run_or_print cp -a "$_path" "$_backup_dir/"
    log_info "Backup prévu: $_backup_dir/$(basename "$_path")"
}

ensure_symlink() {
    _src="$1"
    _dst="$2"
    _label="$3"
    _src_cmp="$_src"
    _dst_cmp=""

    if command -v readlink >/dev/null 2>&1; then
        _src_cmp=$(readlink -f "$_src" 2>/dev/null || printf '%s' "$_src")
    fi

    if [ ! -e "$_src" ]; then
        log_warn "$_label source introuvable: $_src"
        return 1
    fi

    if [ -L "$_dst" ]; then
        _dst_cmp=$(readlink "$_dst")
        if command -v readlink >/dev/null 2>&1; then
            _dst_cmp=$(readlink -f "$_dst" 2>/dev/null || printf '%s' "$_dst_cmp")
        fi
    fi

    if [ -L "$_dst" ] && [ "$_dst_cmp" = "$_src_cmp" ]; then
        log_info "$_label déjà configuré: $_dst -> $_src"
        return 0
    fi

    if [ -e "$_dst" ] || [ -L "$_dst" ]; then
        backup_path "$_dst"
        run_or_print rm -f "$_dst"
    fi
    run_or_print ln -sfn "$_src" "$_dst"
}

detect_prompt_engine() {
    if [ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]; then
        printf 'powerlevel10k-system\n'
    elif [ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        printf 'powerlevel10k-oh-my-zsh\n'
    elif [ -f /usr/share/zsh/manjaro-zsh-prompt ]; then
        printf 'manjaro-zsh-prompt\n'
    else
        printf 'missing\n'
    fi
}

font_status() {
    if ! command -v fc-match >/dev/null 2>&1; then
        printf 'unknown'
        return
    fi
    if fc-match 'MesloLGS NF' 2>/dev/null | grep -qi 'Meslo'; then
        printf 'ok'
    else
        printf 'missing'
    fi
}

install_missing_shell_bits() {
    if [ "$INSTALL_MISSING" -ne 1 ]; then
        return 0
    fi

    if ! command -v zsh >/dev/null 2>&1; then
        log_warn "zsh absent; lancer scripts/config/setup_zsh_complete.sh pour installation complète"
    fi

    if [ "$(detect_prompt_engine)" = "missing" ]; then
        if [ -f "$SCRIPT_DIR/config/setup_p10k.sh" ]; then
            run_or_print bash "$SCRIPT_DIR/config/setup_p10k.sh"
        else
            log_warn "setup_p10k.sh introuvable"
        fi
    fi

    if [ "$(font_status)" = "missing" ] && [ -f "$SCRIPT_DIR/config/install_nerd_fonts.sh" ]; then
        run_or_print bash "$SCRIPT_DIR/config/install_nerd_fonts.sh"
    fi
}

apply_shell_profile() {
    log_section "Ré-application shell/prompt dotfiles"

    log_info "DOTFILES_DIR=$DOTFILES_DIR"
    log_info "Prompt engine détecté: $(detect_prompt_engine)"
    log_info "Police MesloLGS NF: $(font_status)"

    if [ "$(detect_prompt_engine)" = "missing" ]; then
        log_warn "Moteur Powerlevel10k absent. Utilise --install-missing pour tenter l'installation."
    fi
    if [ "$(font_status)" = "missing" ]; then
        log_warn "Police Nerd Font non détectée. Les icônes peuvent s'afficher mal."
    fi

    install_missing_shell_bits

    ensure_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc" ".zshrc"
    ensure_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"

    if command -v zsh >/dev/null 2>&1; then
        run_or_print zsh -n "$DOTFILES_DIR/zsh/zshrc_custom"
        run_or_print zsh -n "$DOTFILES_DIR/.p10k.zsh"
    else
        log_warn "zsh absent: vérification syntaxe zsh ignorée"
    fi

    log_info "Ré-application terminée. Recharge ensuite avec: exec zsh"
}

apply_root_profile() {
    log_section "Ré-application root/sudo dotfiles"

    _mode="--dry-run"
    [ "$APPLY" -eq 1 ] && _mode="--apply"
    _yes=""
    [ "$ASSUME_YES" -eq 1 ] && _yes="--yes"

    if [ -f "$SCRIPT_DIR/config/setup_root_prompt.sh" ]; then
        bash "$SCRIPT_DIR/config/setup_root_prompt.sh" "$_mode" $_yes
    else
        log_warn "setup_root_prompt.sh introuvable"
    fi

    if [ -f "$SCRIPT_DIR/bootstrap/install_manager_shims.sh" ]; then
        bash "$SCRIPT_DIR/bootstrap/install_manager_shims.sh" "$_mode" $_yes --manager diskman
    else
        log_warn "install_manager_shims.sh introuvable"
    fi

    log_info "Root prêt après apply: sudo diskman overview"
}

if [ "$APPLY" -eq 1 ] && [ "$ASSUME_YES" -ne 1 ]; then
    printf 'Appliquer le profil %s sur ce compte (%s) ? [y/N] ' "$PROFILE" "$HOME"
    read -r answer
    case "$answer" in
        y|Y|yes|YES|o|O|oui|OUI) ;;
        *) log_error "Annulé"; exit 1 ;;
    esac
fi

case "$PROFILE" in
    shell|base) apply_shell_profile ;;
    root) apply_root_profile ;;
    *) log_error "Profil non supporté: $PROFILE"; exit 1 ;;
esac
