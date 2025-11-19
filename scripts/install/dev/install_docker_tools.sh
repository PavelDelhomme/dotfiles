#!/bin/bash

################################################################################
# Installation outils de build pour Makefile (Arch Linux)
# Installe: base-devel, make, gcc, pkg-config, cmake
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Installation outils de build (Arch Linux)"

################################################################################
# VÉRIFICATION SYSTÈME ARCH
################################################################################
if [ ! -f /etc/arch-release ]; then
    log_warn "Ce script est conçu pour Arch Linux"
    log_info "Système détecté: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    read -p "Continuer quand même? (o/n): " continue_choice
    if [[ ! "$continue_choice" =~ ^[oO]$ ]]; then
        log_info "Installation annulée"
        exit 0
    fi
fi

################################################################################
# INSTALLATION BASE-DEVEL
################################################################################
log_section "Installation base-devel"

if pacman -Q base-devel &> /dev/null; then
    log_info "base-devel déjà installé"
else
    log_info "Installation de base-devel..."
    sudo pacman -S --noconfirm base-devel
    log_info "✓ base-devel installé"
fi

################################################################################
# VÉRIFICATION DES OUTILS
################################################################################
log_section "Vérification des outils"

TOOLS_INSTALLED=()
TOOLS_MISSING=()

# Vérifier make
if command -v make &> /dev/null; then
    MAKE_VERSION=$(make --version | head -n1)
    log_info "✓ make: $MAKE_VERSION"
    TOOLS_INSTALLED+=("make")
else
    log_warn "✗ make non trouvé"
    TOOLS_MISSING+=("make")
fi

# Vérifier gcc
if command -v gcc &> /dev/null; then
    GCC_VERSION=$(gcc --version | head -n1)
    log_info "✓ gcc: $GCC_VERSION"
    TOOLS_INSTALLED+=("gcc")
else
    log_warn "✗ gcc non trouvé"
    TOOLS_MISSING+=("gcc")
fi

# Vérifier pkg-config
if command -v pkg-config &> /dev/null; then
    PKG_CONFIG_VERSION=$(pkg-config --version)
    log_info "✓ pkg-config: $PKG_CONFIG_VERSION"
    TOOLS_INSTALLED+=("pkg-config")
else
    log_warn "✗ pkg-config non trouvé"
    TOOLS_MISSING+=("pkg-config")
fi

# Vérifier cmake
if command -v cmake &> /dev/null; then
    CMAKE_VERSION=$(cmake --version | head -n1)
    log_info "✓ cmake: $CMAKE_VERSION"
    TOOLS_INSTALLED+=("cmake")
else
    log_warn "✗ cmake non trouvé"
    TOOLS_MISSING+=("cmake")
fi

################################################################################
# INSTALLATION DES OUTILS MANQUANTS
################################################################################
if [ ${#TOOLS_MISSING[@]} -gt 0 ]; then
    log_section "Installation des outils manquants"
    
    for tool in "${TOOLS_MISSING[@]}"; do
        case "$tool" in
            make|gcc|pkg-config)
                log_info "Ces outils font partie de base-devel, réinstallation..."
                sudo pacman -S --noconfirm base-devel
                ;;
            cmake)
                log_info "Installation de cmake..."
                sudo pacman -S --noconfirm cmake
                ;;
        esac
    done
fi

################################################################################
# VÉRIFICATION FINALE
################################################################################
log_section "Vérification finale"

ALL_OK=true

for tool in make gcc pkg-config cmake; do
    if command -v "$tool" &> /dev/null; then
        log_info "✓ $tool disponible"
    else
        log_error "✗ $tool toujours manquant"
        ALL_OK=false
    fi
done

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

if [ "$ALL_OK" = true ]; then
    log_info "✅ Tous les outils sont installés"
    echo ""
    log_info "Outils installés:"
    for tool in make gcc pkg-config cmake; do
        if command -v "$tool" &> /dev/null; then
            VERSION=$($tool --version 2>/dev/null | head -n1 || echo "Version inconnue")
            echo "  - $tool: $VERSION"
        fi
    done
else
    log_warn "⚠️ Certains outils sont manquants"
    log_info "Installez-les manuellement avec: sudo pacman -S <package>"
fi
echo ""
