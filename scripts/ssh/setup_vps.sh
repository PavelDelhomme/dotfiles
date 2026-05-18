#!/usr/bin/env bash
# Configure le VPS (alias pavel-server) : clé locale + entrée ~/.ssh/config + copie clé sur le serveur.
# Secrets uniquement dans ~/dotfiles/.env (gitignored).
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ENV_FILE="$DOTFILES_DIR/.env"
EXAMPLE="$DOTFILES_DIR/.env.example"
SETUP_SH="$DOTFILES_DIR/zsh/functions/configman/modules/ssh/ssh_auto_setup.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf '%b[→]%b %s\n' "$YELLOW" "$NC" "$*"; }
ok()   { printf '%b[✓]%b %s\n' "$GREEN" "$NC" "$*"; }
err()  { printf '%b[✗]%b %s\n' "$RED" "$NC" "$*" >&2; }

if [ ! -f "$SETUP_SH" ]; then
    err "Script introuvable : $SETUP_SH"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$EXAMPLE" ]; then
        info "Création de .env depuis .env.example"
        cp "$EXAMPLE" "$ENV_FILE"
        chmod 600 "$ENV_FILE"
    else
        err "Créez $ENV_FILE avec SSH_HOST, SSH_USER, SSH_PASSWORD, etc."
        exit 1
    fi
fi

# shellcheck source=/dev/null
set -a
source "$ENV_FILE" 2>/dev/null || true
set +a

if [ -z "${SSH_PASSWORD:-}" ]; then
    err "SSH_PASSWORD est vide dans $ENV_FILE"
    printf '  Éditez le fichier : nano %s\n' "$ENV_FILE"
    printf '  Puis relancez : %s\n' "$DOTFILES_DIR/scripts/ssh/setup_vps.sh"
    exit 1
fi

if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    err "Aucune clé dans ~/.ssh — lancez d'abord : sshman keys (générer id_ed25519)"
    exit 1
fi

if ! command -v sshpass >/dev/null 2>&1; then
    if [ -f "$DOTFILES_DIR/scripts/install/system/packages_ssh.sh" ]; then
        info "Installation de sshpass…"
        bash "$DOTFILES_DIR/scripts/install/system/packages_ssh.sh" || exit 1
    else
        err "sshpass manquant : installman sshpass  ou  sudo pacman -S sshpass"
        exit 1
    fi
fi

export DOTFILES_SSH_AUTO_NONINTERACTIVE=1
export DOTFILES_SSH_AUTO_REPLACE=1

info "Configuration SSH automatique (alias ${SSH_HOST_NAME:-pavel-server})…"
bash "$SETUP_SH" "${SSH_HOST_NAME:-pavel-server}" "${SSH_HOST:-}" "${SSH_USER:-pavel}" "${SSH_PORT:-22}"

ok "Terminé. Connexion : ssh ${SSH_HOST_NAME:-pavel-server}  (alias shell : vps)"
