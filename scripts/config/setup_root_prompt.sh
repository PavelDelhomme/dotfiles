#!/usr/bin/env bash
################################################################################
# Configure root prompt (zsh + Powerlevel10k) from dotfiles.
#
# Usage:
#   bash scripts/config/setup_root_prompt.sh --dry-run
#   bash scripts/config/setup_root_prompt.sh --apply
#   bash scripts/config/setup_root_prompt.sh --apply --yes
################################################################################

set -u

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
ROOT_HOME="${ROOT_HOME:-/root}"
APPLY=0
ASSUME_YES=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --dry-run) APPLY=0 ;;
        --yes|-y) ASSUME_YES=1 ;;
        --help|-h)
            sed -n '1,18p' "$0"
            exit 0
            ;;
        *)
            printf 'Argument inconnu: %s\n' "$1" >&2
            exit 1
            ;;
    esac
    shift
done

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN %s\n' "$*" >&2; }
die() { printf 'ERR  %s\n' "$*" >&2; exit 1; }

if [ ! -f "$DOTFILES_DIR/.p10k.zsh" ]; then
    die "Configuration utilisateur absente: $DOTFILES_DIR/.p10k.zsh"
fi
if [ ! -f "$DOTFILES_DIR/.p10k-root.zsh" ]; then
    die "Configuration root absente: $DOTFILES_DIR/.p10k-root.zsh"
fi

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
    command -v sudo >/dev/null 2>&1 || die "sudo absent"
fi

ROOT_ZSHRC="$ROOT_HOME/.zshrc"
ROOT_P10K="$ROOT_HOME/.p10k.zsh"
ROOT_DOTFILES="$ROOT_HOME/dotfiles"
BACKUP_DIR="$ROOT_HOME/.dotfiles_prompt_backup_$(date +%Y%m%d_%H%M%S)"

root_sh() {
    if [ -n "$SUDO" ]; then
        sudo sh -c "$1"
    else
        sh -c "$1"
    fi
}

run_or_print() {
    if [ "$APPLY" -eq 1 ]; then
        log "+ $*"
        "$@"
    else
        log "[dry-run] $*"
    fi
}

write_root_zshrc() {
    tmp=$(mktemp) || exit 1
    cat > "$tmp" <<EOF
# Managed by dotfiles: root prompt profile
# Source: $DOTFILES_DIR/scripts/config/setup_root_prompt.sh

export DOTFILES_DIR="$DOTFILES_DIR"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git sudo systemd docker)

if [ -f "\$ZSH/oh-my-zsh.sh" ]; then
  source "\$ZSH/oh-my-zsh.sh"
elif [ -f /usr/share/oh-my-zsh/oh-my-zsh.sh ]; then
  export ZSH=/usr/share/oh-my-zsh
  source /usr/share/oh-my-zsh/oh-my-zsh.sh
elif [ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [ -f /usr/share/zsh/manjaro-zsh-prompt ]; then
  source /usr/share/zsh/manjaro-zsh-prompt
elif [ -f "\$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
  source "\$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
fi

if [ -f "\$HOME/.p10k.zsh" ]; then
  source "\$HOME/.p10k.zsh"
fi

# Root gets the same manager functions without changing user files.
if [ -d "\$DOTFILES_DIR/shells/zsh/adapters" ]; then
  for adapter in "\$DOTFILES_DIR"/shells/zsh/adapters/*.zsh; do
    [ -f "\$adapter" ] || continue
    source "\$adapter" >/dev/null 2>&1 || true
  done
fi
EOF
    if [ "$APPLY" -eq 1 ]; then
        if [ -n "$SUDO" ]; then
            sudo install -m 0644 "$tmp" "$ROOT_ZSHRC"
        else
            install -m 0644 "$tmp" "$ROOT_ZSHRC"
        fi
    else
        log "[dry-run] installer $ROOT_ZSHRC depuis template genere"
    fi
    rm -f "$tmp"
}

log "Configuration prompt root"
log "DOTFILES_DIR=$DOTFILES_DIR"
log "ROOT_HOME=$ROOT_HOME"
log "Mode=$([ "$APPLY" -eq 1 ] && printf apply || printf dry-run)"
log ""

if [ ! -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ] && \
   [ ! -f /usr/share/zsh/manjaro-zsh-prompt ] && \
   [ ! -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    warn "Thème Powerlevel10k non trouvé dans /usr/share"
    warn "Installer d'abord: sudo pacman -S --needed zsh-theme-powerlevel10k"
fi
if command -v fc-match >/dev/null 2>&1; then
    if ! fc-match 'MesloLGS NF' 2>/dev/null | grep -qi 'Meslo'; then
        warn "Police MesloLGS NF non détectée par fontconfig"
        warn "Installer une Nerd Font compatible pour afficher les icônes du prompt"
    fi
else
    warn "fc-match absent: vérification des polices/icônes ignorée"
fi

if [ "$APPLY" -eq 1 ] && [ "$ASSUME_YES" -ne 1 ]; then
    printf 'Appliquer la configuration prompt root avec backup ? [y/N] '
    read -r answer
    case "$answer" in
        y|Y|yes|YES|oui|OUI) ;;
        *) die "Annule" ;;
    esac
fi

if [ "$APPLY" -eq 1 ]; then
    root_sh "mkdir -p '$BACKUP_DIR'"
    root_sh "[ ! -e '$ROOT_ZSHRC' ] || cp -a '$ROOT_ZSHRC' '$BACKUP_DIR/.zshrc'"
    root_sh "[ ! -e '$ROOT_P10K' ] || cp -a '$ROOT_P10K' '$BACKUP_DIR/.p10k.zsh'"
    root_sh "[ ! -e '$ROOT_DOTFILES' ] || [ -L '$ROOT_DOTFILES' ] || cp -a '$ROOT_DOTFILES' '$BACKUP_DIR/dotfiles'"
else
    log "[dry-run] backup éventuel vers $BACKUP_DIR"
fi

run_or_print root_sh "ln -sfn '$DOTFILES_DIR' '$ROOT_DOTFILES'"
run_or_print root_sh "ln -sfn '$DOTFILES_DIR/.p10k-root.zsh' '$ROOT_P10K'"
write_root_zshrc

log ""
log "Vérifications utiles:"
log "  sudo zsh -lc 'echo root-zsh-ok; test -f ~/.p10k.zsh && echo p10k-ok'"
log "  sudo zsh"
log ""
if [ "$APPLY" -eq 1 ]; then
    log "OK prompt root configuré. Backup: $BACKUP_DIR"
else
    log "Dry-run terminé. Relancer avec --apply pour appliquer."
fi
