#!/bin/bash
################################################################################
# Installation paquets de base - multi-distro (délègue au profil déclaratif)
# Listes : share/profiles/base/
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/base_profile_lib.sh" || {
    echo "Erreur: base_profile_lib.sh manquant"
    exit 1
}

BP_ROOT="$DOTFILES_DIR"
BP_DIR="$DOTFILES_DIR/share/profiles/base"

log_section "Paquets de base (profil $(bp_profile_name) / $(bp_family))"
log_info "Distribution: $(detect_distro)"

# Core seulement (sans AUR/flatpak/snap — voir package_managers.sh / base_profile.sh)
bp_install_core

# SSH stack dédiée si présente
if [ -f "$SCRIPT_DIR/install/system/packages_ssh.sh" ]; then
    bash "$SCRIPT_DIR/install/system/packages_ssh.sh" || log_warn "Paquets SSH (sshpass) — voir installman sshpass"
fi

echo ""
log_info "Vérification dig:"
if command -v dig >/dev/null 2>&1; then
    log_info "✓ dig → $(command -v dig)"
else
    log_warn "dig toujours absent — installman network-tools ou base_profile.sh install"
fi

log_info "✓ Paquets de base traités (doctor: make base-doctor)"
