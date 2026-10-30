#!/bin/bash
################################################################################
# Profil machine de base — install / doctor / plan (multi-distro)
# Voir share/profiles/base/README.md
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
export DOTFILES_DIR

# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger common.sh"
    exit 1
}
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/base_profile_lib.sh" || {
    echo "Erreur: Impossible de charger base_profile_lib.sh"
    exit 1
}

BP_ROOT="$DOTFILES_DIR"
BP_DIR="$DOTFILES_DIR/share/profiles/base"

_usage() {
    cat <<'EOF'
base_profile — socle outils multi-distro (Arch / Debian / Fedora / Gentoo)

Usage :
  base_profile.sh install     installer universal (+ gui) + AUR/flatpak/snap
  base_profile.sh doctor      vérifier ce qui manque
  base_profile.sh plan        tableau clé → paquet → état
  base_profile.sh help

Variables :
  DOTFILES_BASE_PROFILE=desktop|headless
  DOTFILES_HEADLESS=1
  DOTFILES_AUR_HELPER=yay|paru|both|none
  DOTFILES_WANT_FLATPAK=1  DOTFILES_WANT_SNAP=1
  DOTFILES_SET_DEFAULT_SHELL=1  DOTFILES_DEFAULT_SHELL=zsh

Exemples :
  make base
  DOTFILES_HEADLESS=1 bash scripts/install/system/base_profile.sh install
  DOTFILES_AUR_HELPER=paru DOTFILES_SET_DEFAULT_SHELL=1 bash …/base_profile.sh install
EOF
}

cmd="${1:-help}"
case "$cmd" in
    install|i)
        bp_install_all
        ;;
    doctor|check|status)
        bp_doctor
        ;;
    plan|dry-run|preview)
        bp_plan
        ;;
    help|-h|--help)
        _usage
        ;;
    *)
        echo "Commande inconnue: $cmd" >&2
        _usage
        exit 1
        ;;
esac
