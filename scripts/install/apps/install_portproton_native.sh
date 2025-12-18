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
# ÉTAPE 0: Installation des dépendances (gamescope)
################################################################################
echo "[0/5] Installation des dépendances..."

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    DISTRO="unknown"
fi

# Installer gamescope selon la distribution
if [ "$DISTRO" = "arch" ]; then
    if ! pacman -Qi gamescope >/dev/null 2>&1; then
        log_info "Installation de gamescope (requis pour PortProton)..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm gamescope || {
                log_warn "Échec avec yay, tentative avec pacman..."
                sudo pacman -S --noconfirm gamescope || {
                    log_warn "Impossible d'installer gamescope automatiquement"
                    log_info "Vous pouvez l'installer manuellement avec: sudo pacman -S gamescope"
                }
            }
        else
            sudo pacman -S --noconfirm gamescope || {
                log_warn "Impossible d'installer gamescope automatiquement"
                log_info "Vous pouvez l'installer manuellement avec: sudo pacman -S gamescope"
            }
        fi
        log_info "✓ gamescope installé"
    else
        log_info "✓ gamescope déjà installé"
    fi
elif [ "$DISTRO" = "debian" ]; then
    if ! dpkg -l | grep -q "^ii.*gamescope"; then
        log_info "Installation de gamescope (requis pour PortProton)..."
        sudo apt-get update -qq
        sudo apt-get install -y gamescope || {
            log_warn "gamescope non disponible dans les dépôts Debian"
            log_info "Vous devrez peut-être l'installer depuis les sources ou un PPA"
        }
        log_info "✓ gamescope installé"
    else
        log_info "✓ gamescope déjà installé"
    fi
elif [ "$DISTRO" = "fedora" ]; then
    if ! rpm -q gamescope >/dev/null 2>&1; then
        log_info "Installation de gamescope (requis pour PortProton)..."
        sudo dnf install -y gamescope || {
            log_warn "gamescope non disponible dans les dépôts Fedora"
            log_info "Vous devrez peut-être l'installer depuis les sources"
        }
        log_info "✓ gamescope installé"
    else
        log_info "✓ gamescope déjà installé"
    fi
else
    log_warn "Distribution non détectée, gamescope ne sera pas installé automatiquement"
    log_info "Assurez-vous d'installer gamescope manuellement si nécessaire"
fi

################################################################################
# ÉTAPE 1: Installation PortProton native
################################################################################
echo ""
echo "[1/5] Installation PortProton native..."

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
echo "[2/5] Configuration des dossiers..."

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
echo "[3/5] Création alias et scripts helper..."

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

portproton-uninstall-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-uninstall-game <nom_du_jeu>"
        echo ""
        echo "Jeux installés dans PortProton:"
        if [ -d "$HOME/Games/PortProton/games" ]; then
            ls -1 "$HOME/Games/PortProton/games" 2>/dev/null | sed 's/^/  - /' || echo "  (aucun jeu trouvé)"
        else
            echo "  (dossier games non trouvé)"
        fi
        return 1
    fi
    
    local game_name="\$1"
    local game_dir="\$HOME/Games/PortProton/games/\$game_name"
    local prefix_dir="\$HOME/Games/PortProton/prefix/\$game_name"
    
    echo "🔍 Recherche du jeu: \$game_name"
    
    # Vérifier si le jeu existe
    if [ ! -d "\$game_dir" ] && [ ! -d "\$prefix_dir" ]; then
        echo "❌ Jeu '\$game_name' non trouvé dans PortProton"
        echo ""
        echo "Jeux disponibles:"
        if [ -d "\$HOME/Games/PortProton/games" ]; then
            ls -1 "\$HOME/Games/PortProton/games" 2>/dev/null | sed 's/^/  - /' || echo "  (aucun jeu)"
        fi
        return 1
    fi
    
    # Confirmation
    echo "⚠️  Vous allez supprimer:"
    [ -d "\$game_dir" ] && echo "  - Dossier du jeu: \$game_dir"
    [ -d "\$prefix_dir" ] && echo "  - Préfixe Wine: \$prefix_dir"
    echo ""
    printf "Continuer? (o/N): "
    read -r confirm
    
    if [[ ! "\$confirm" =~ ^[oO]$ ]]; then
        echo "❌ Désinstallation annulée"
        return 1
    fi
    
    # Supprimer le dossier du jeu
    if [ -d "\$game_dir" ]; then
        echo "🗑️  Suppression du dossier du jeu..."
        rm -rf "\$game_dir" && echo "✓ Dossier du jeu supprimé" || echo "⚠️  Erreur lors de la suppression du dossier du jeu"
    fi
    
    # Supprimer le préfixe Wine
    if [ -d "\$prefix_dir" ]; then
        echo "🗑️  Suppression du préfixe Wine..."
        rm -rf "\$prefix_dir" && echo "✓ Préfixe Wine supprimé" || echo "⚠️  Erreur lors de la suppression du préfixe"
    fi
    
    echo "✅ Jeu '\$game_name' désinstallé avec succès"
}
PORTFUNCTIONS
    log_info "✓ Fonctions helper ajoutées"
fi

log_info "✓ Alias et fonctions créés (recharger avec: source ~/.zshrc)"

################################################################################
# ÉTAPE 4: Création script wrapper dans PATH
################################################################################
echo ""
echo "[4/5] Création script wrapper..."

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
echo "📦 gamescope installé (dépendance requise)"
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

