#!/bin/bash
# Paquets SSH client + sshpass (copie de clé automatisée) — multi-distributions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" || exit 1

install_pkg() {
    local distro
    distro=$(detect_distro)
    case "$distro" in
        arch)
            sudo pacman -S --needed --noconfirm openssh sshpass
            ;;
        debian|ubuntu)
            sudo apt-get update -qq
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client sshpass
            ;;
        fedora)
            sudo dnf install -y openssh-clients sshpass
            ;;
        *)
            log_warn "Distribution non gérée pour packages_ssh — installez openssh et sshpass manuellement"
            return 1
            ;;
    esac
}

log_info "Vérification paquets SSH (openssh + sshpass)…"

if command -v ssh >/dev/null 2>&1 && command -v sshpass >/dev/null 2>&1; then
    log_skip "openssh et sshpass déjà présents"
    exit 0
fi

install_pkg
log_info "✓ Paquets SSH installés"
