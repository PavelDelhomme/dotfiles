#!/bin/bash
################################################################################
# Bibliothèque commune pour tous les scripts
# Contient les fonctions de logging et variables communes
# Usage: 
#   Dans scripts/config/ ou scripts/install/ : source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
#   Dans scripts/ directement : source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
#   Depuis la racine : source "$DOTFILES_DIR/scripts/lib/common.sh"
################################################################################

# Variables de couleur
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export NC='\033[0m'  # No Color
export BOLD='\033[1m'

# Variables communes - Définir DOTFILES_DIR si pas déjà défini
if [ -z "$DOTFILES_DIR" ]; then
    # Essayer de trouver le répertoire dotfiles
    if [ -f "${BASH_SOURCE[0]}" ]; then
        SCRIPT_ABS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        if [ -f "$SCRIPT_ABS_PATH/bootstrap.sh" ] || [ -f "$SCRIPT_ABS_PATH/setup.sh" ]; then
            export DOTFILES_DIR="$SCRIPT_ABS_PATH"
        else
            export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
        fi
    else
        export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    fi
fi
export SCRIPT_DIR="${SCRIPT_DIR:-$DOTFILES_DIR/scripts}"

################################################################################
# FONCTIONS DE LOGGING
################################################################################

# Affiche un message d'information (vert)
log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Affiche un avertissement (jaune)
log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Affiche une erreur (rouge)
log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# Affiche une section (bleu avec bordure)
log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"
}

# Affiche un message de succès (vert avec émoji)
log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

# Affiche un message d'échec (rouge avec émoji)
log_failure() {
    echo -e "${RED}❌${NC} $1" >&2
}

# Affiche un message d'information (bleu)
log_skip() {
    echo -e "${BLUE}[→]${NC} $1"
}

################################################################################
# FONCTIONS UTILITAIRES COMMUNES
################################################################################

# Vérifie si une commande est installée
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Vérifie si un paquet est installé (Arch Linux uniquement)
is_package_installed() {
    if command -v pacman >/dev/null 2>&1; then
        pacman -Q "$1" >/dev/null 2>&1
    else
        return 1
    fi
}

# Détecte la distribution Linux
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/gentoo-release ] || [ -f /etc/portage/make.conf ]; then
        echo "gentoo"
    else
        echo "unknown"
    fi
}

# Exporter les fonctions pour utilisation dans les scripts enfants
export -f log_info
export -f log_warn
export -f log_error
export -f log_section
export -f log_success
export -f log_failure
export -f log_skip
export -f is_installed
export -f is_package_installed
export -f detect_distro

