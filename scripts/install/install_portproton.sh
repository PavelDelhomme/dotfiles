#!/bin/bash

################################################################################
# Installation et configuration PortProton
# Pour jouer aux jeux Windows sur Linux
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Installation PortProton"

################################################################################
# ÉTAPE 1: Installation via Flatpak
################################################################################
echo "[1/4] Installation PortProton..."

if flatpak list | grep -q "PortProton"; then
    log_info "PortProton déjà installé"
else
    log_info "Installation via Flatpak..."
    flatpak install -y flathub ru.linux_gaming.PortProton
    log_info "✓ PortProton installé"
fi

################################################################################
# ÉTAPE 2: Configuration des dossiers
################################################################################
echo ""
echo "[2/4] Configuration des dossiers..."

# Créer dossiers pour jeux et préfixes Wine
mkdir -p ~/Games/PortProton
mkdir -p ~/Games/PortProton/prefix
mkdir -p ~/Games/PortProton/games

log_info "✓ Dossiers créés:"
log_info "  - ~/Games/PortProton/prefix (préfixes Wine)"
log_info "  - ~/Games/PortProton/games (jeux installés)"

################################################################################
# ÉTAPE 3: Permissions Flatpak
################################################################################
echo ""
echo "[3/4] Configuration permissions Flatpak..."

# Donner accès aux dossiers de jeux
flatpak override --user ru.linux_gaming.PortProton --filesystem=~/Games
flatpak override --user ru.linux_gaming.PortProton --filesystem=xdg-download

log_info "✓ Permissions configurées"

################################################################################
# ÉTAPE 4: Création alias et helper
################################################################################
echo ""
echo "[4/4] Création alias et scripts helper..."

# Créer fonction dans functions.zsh ou directement
cat >> ~/.zshrc <<'PORTALIAS'

# PortProton helpers
alias portproton='flatpak run ru.linux_gaming.PortProton'
alias pp='flatpak run ru.linux_gaming.PortProton'

portproton-install-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-install-game <installer.exe>"
        return 1
    fi
    flatpak run ru.linux_gaming.PortProton "$1"
}

portproton-run() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-run <game.exe>"
        return 1
    fi
    flatpak run ru.linux_gaming.PortProton "$1"
}
PORTALIAS

log_info "✓ Alias créés (recharger avec: source ~/.zshrc)"

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
echo "📦 PortProton installé et configuré"
echo ""
echo "🎮 Utilisation:"
echo ""
echo "  Lancer PortProton:"
echo "    portproton"
echo "    # ou"
echo "    flatpak run ru.linux_gaming.PortProton"
echo ""
echo "  Installer un jeu:"
echo "    portproton-install-game ~/Downloads/setup.exe"
echo ""
echo "  Lancer un jeu:"
echo "    portproton-run ~/Games/PortProton/games/MonJeu/game.exe"
echo ""
echo "  Dossiers importants:"
echo "    ~/Games/PortProton/prefix    # Préfixes Wine"
echo "    ~/Games/PortProton/games     # Jeux installés"
echo ""
echo "📚 Documentation:"
echo "  https://github.com/Castro-Fidel/PortWINE"
echo ""
echo "💡 Astuce: Pour Steam, Epic Games, etc., lance PortProton"
echo "   et utilise l'interface graphique intégrée"
echo ""
