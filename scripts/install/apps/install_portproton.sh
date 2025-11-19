#!/bin/bash

################################################################################
# Installation et configuration PortProton
# Pour jouer aux jeux Windows sur Linux
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

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

ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"

# Créer le fichier aliases.zsh s'il n'existe pas
if [ ! -f "$ALIASES_FILE" ]; then
    mkdir -p "$(dirname "$ALIASES_FILE")"
    touch "$ALIASES_FILE"
    echo "# ~/dotfiles/zsh/aliases.zsh" > "$ALIASES_FILE"
fi

# Utiliser add_alias si disponible
if type add_alias &> /dev/null; then
    log_info "Création alias via add_alias..."
    add_alias "portproton" "flatpak run ru.linux_gaming.PortProton" "PortProton - Jeux Windows sur Linux"
    add_alias "pp" "flatpak run ru.linux_gaming.PortProton" "PortProton (raccourci)"
    log_info "✓ Alias créés via add_alias"
else
    log_warn "add_alias non disponible, ajout manuel..."
    if ! grep -q "^alias portproton=" "$ALIASES_FILE"; then
        echo "" >> "$ALIASES_FILE"
        echo "# PortProton helpers" >> "$ALIASES_FILE"
        echo "alias portproton='flatpak run ru.linux_gaming.PortProton'" >> "$ALIASES_FILE"
        echo "alias pp='flatpak run ru.linux_gaming.PortProton'" >> "$ALIASES_FILE"
        log_info "✓ Alias ajoutés dans $ALIASES_FILE"
    else
        log_info "✓ Alias déjà présents"
    fi
fi

# Ajouter les fonctions helper
if ! grep -q "portproton-install-game()" "$ALIASES_FILE"; then
    cat >> "$ALIASES_FILE" <<'PORTFUNCTIONS'

# PortProton helper functions
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
PORTFUNCTIONS
    log_info "✓ Fonctions helper ajoutées"
fi

log_info "✓ Alias et fonctions créés (recharger avec: source ~/.zshrc)"

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
