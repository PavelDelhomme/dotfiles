#!/bin/bash

################################################################################
# Désinstallation paquets de base
# Supprime xclip, curl, wget, make, cmake, gcc, git, base-devel, zsh, btop
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation paquets de base"

log_warn "⚠️  ATTENTION : Cette opération va supprimer les paquets de base"
log_warn "⚠️  Paquets concernés :"
echo "  - xclip, curl, wget"
echo "  - make, cmake, gcc"
echo "  - git, base-devel"
echo "  - zsh, btop"
echo ""
log_warn "⚠️  Certains de ces paquets sont essentiels au système !"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

# Détecter le gestionnaire de paquets
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    UNINSTALL_CMD="sudo pacman -Rns --noconfirm"
    BASE_PACKAGES=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "base-devel" "zsh" "btop")
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    UNINSTALL_CMD="sudo apt remove -y"
    BASE_PACKAGES=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "build-essential" "zsh" "btop")
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UNINSTALL_CMD="sudo dnf remove -y"
    BASE_PACKAGES=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "gcc-c++" "zsh" "btop")
else
    log_error "Gestionnaire de paquets non supporté"
    exit 1
fi

log_info "Détection: $PKG_MANAGER"
log_info "Suppression paquets de base..."

for pkg in "${BASE_PACKAGES[@]}"; do
    if command -v "$pkg" &> /dev/null || pacman -Q "$pkg" &> /dev/null 2>&1 || dpkg -l | grep -q "^ii.*$pkg" 2>/dev/null; then
        log_info "Suppression de $pkg..."
        $UNINSTALL_CMD "$pkg" 2>/dev/null && log_info "✓ $pkg supprimé" || log_warn "Impossible de supprimer $pkg"
    else
        log_skip "$pkg non installé"
    fi
done

log_info "✅ Désinstallation paquets de base terminée"
log_warn "⚠️  Note: Certains paquets ont pu être conservés s'ils sont nécessaires au système"

