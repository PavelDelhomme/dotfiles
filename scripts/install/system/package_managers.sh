#!/bin/bash
################################################################################
# Gestionnaires de paquets — multi-distro
# Arch : AUR helper (yay/paru) + snap + flatpak
# Debian/Fedora : snap + flatpak
# Gentoo : flatpak si mappé
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

log_section "Gestionnaires de paquets ($(bp_family))"
bp_install_aur_helper
bp_install_flatpak_snap
log_info "✓ Gestionnaires de paquets traités"
