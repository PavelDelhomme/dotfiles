#!/bin/bash

################################################################################
# Installation PortProton version native (sans Flatpak)
# Pour jouer aux jeux Windows sur Linux
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation PortProton (version native)"

################################################################################
# ÉTAPE 1: Installation PortProton native
################################################################################
echo "[1/4] Installation PortProton native..."

PORTPROTON_DIR="$HOME/.local/share/PortProton"
PORTPROTON_BIN="$PORTPROTON_DIR/data_from_portwine/scripts/start.sh"

if [ -f "$PORTPROTON_BIN" ]; then
    log_info "PortProton déjà installé dans $PORTPROTON_DIR"
else
    log_info "Téléchargement de PortProton..."
    
    # Créer le répertoire
    mkdir -p "$PORTPROTON_DIR"
    cd "$PORTPROTON_DIR"
    
    # Télécharger PortProton depuis GitHub
    if command -v git >/dev/null 2>&1; then
        log_info "Clonage de PortProton depuis GitHub..."
        git clone https://github.com/Castro-Fidel/PortWINE.git . || {
            log_error "Échec du clonage"
            exit 1
        }
    else
        log_error "Git est requis pour installer PortProton"
        exit 1
    fi
    
    # Rendre les scripts exécutables
    chmod +x data_from_portwine/scripts/*.sh 2>/dev/null || true
    
    log_info "✓ PortProton installé dans $PORTPROTON_DIR"
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
# ÉTAPE 3: Création alias et helper
################################################################################
echo ""
echo "[3/4] Création alias et scripts helper..."

ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"

# Créer le fichier aliases.zsh s'il n'existe pas
if [ ! -f "$ALIASES_FILE" ]; then
    mkdir -p "$(dirname "$ALIASES_FILE")"
    touch "$ALIASES_FILE"
    echo "# ~/dotfiles/zsh/aliases.zsh" > "$ALIASES_FILE"
fi

# Retirer les anciens alias flatpak s'ils existent
sed -i '/^alias portproton=.*flatpak/d' "$ALIASES_FILE" 2>/dev/null || true
sed -i '/^alias pp=.*flatpak/d' "$ALIASES_FILE" 2>/dev/null || true

# Ajouter les nouveaux alias pour la version native
if ! grep -q "^alias portproton=" "$ALIASES_FILE" || grep -q "flatpak" <<< "$(grep '^alias portproton=' "$ALIASES_FILE")"; then
    # Retirer l'ancien alias s'il existe
    sed -i '/^alias portproton=/d' "$ALIASES_FILE" 2>/dev/null || true
    sed -i '/^alias pp=/d' "$ALIASES_FILE" 2>/dev/null || true
    
    echo "" >> "$ALIASES_FILE"
    echo "# PortProton (version native)" >> "$ALIASES_FILE"
    echo "alias portproton='bash $PORTPROTON_DIR/data_from_portwine/scripts/start.sh'" >> "$ALIASES_FILE"
    echo "alias pp='bash $PORTPROTON_DIR/data_from_portwine/scripts/start.sh'" >> "$ALIASES_FILE"
    log_info "✓ Alias ajoutés dans $ALIASES_FILE"
else
    log_info "✓ Alias déjà présents (version native)"
fi

# Retirer les anciennes fonctions flatpak et ajouter les nouvelles
sed -i '/portproton-install-game()/,/^}/d' "$ALIASES_FILE" 2>/dev/null || true
sed -i '/portproton-run()/,/^}/d' "$ALIASES_FILE" 2>/dev/null || true

# Ajouter les nouvelles fonctions helper
if ! grep -q "portproton-install-game()" "$ALIASES_FILE"; then
    cat >> "$ALIASES_FILE" <<PORTFUNCTIONS

# PortProton helper functions (version native)
portproton-install-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-install-game <installer.exe>"
        return 1
    fi
    bash "$PORTPROTON_DIR/data_from_portwine/scripts/start.sh" "$1"
}

portproton-run() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-run <game.exe>"
        return 1
    fi
    bash "$PORTPROTON_DIR/data_from_portwine/scripts/start.sh" "$1"
}
PORTFUNCTIONS
    log_info "✓ Fonctions helper ajoutées"
fi

log_info "✓ Alias et fonctions créés (recharger avec: source ~/.zshrc)"

################################################################################
# ÉTAPE 4: Création script wrapper dans PATH
################################################################################
echo ""
echo "[4/4] Création script wrapper..."

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Créer un wrapper script
cat > "$LOCAL_BIN/portproton" <<EOF
#!/bin/bash
# Wrapper pour PortProton (version native)
exec bash "$PORTPROTON_DIR/data_from_portwine/scripts/start.sh" "\$@"
EOF

chmod +x "$LOCAL_BIN/portproton"
log_info "✓ Script wrapper créé: $LOCAL_BIN/portproton"

# Ajouter ~/.local/bin au PATH si pas déjà présent
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    log_info "Ajout de $LOCAL_BIN au PATH dans env.sh..."
    ENV_FILE="$HOME/dotfiles/zsh/env.sh"
    if [ -f "$ENV_FILE" ]; then
        if ! grep -q "$LOCAL_BIN" "$ENV_FILE"; then
            echo "" >> "$ENV_FILE"
            echo "# Local bin (PortProton, etc.)" >> "$ENV_FILE"
            echo "export PATH=\"\$PATH:$LOCAL_BIN\"" >> "$ENV_FILE"
        fi
    fi
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
echo "📦 PortProton (version native) installé et configuré"
echo ""
echo "🎮 Utilisation:"
echo ""
echo "  Lancer PortProton:"
echo "    portproton"
echo "    # ou"
echo "    bash $PORTPROTON_DIR/data_from_portwine/scripts/start.sh"
echo ""
echo "  Installer un jeu:"
echo "    portproton-install-game ~/Downloads/setup.exe"
echo ""
echo "  Lancer un jeu:"
echo "    portproton-run ~/Games/PortProton/games/MonJeu/game.exe"
echo ""
echo "  Dossiers importants:"
echo "    $PORTPROTON_DIR          # Installation PortProton"
echo "    ~/Games/PortProton/prefix    # Préfixes Wine"
echo "    ~/Games/PortProton/games     # Jeux installés"
echo ""
echo "📚 Documentation:"
echo "  https://github.com/Castro-Fidel/PortWINE"
echo ""
echo "💡 Astuce: Pour Steam, Epic Games, etc., lance PortProton"
echo "   et utilise l'interface graphique intégrée"
echo ""

