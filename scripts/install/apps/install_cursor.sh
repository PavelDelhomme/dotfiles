#!/bin/bash

################################################################################
# Installation modulaire de Cursor IDE
# Usage: ./install_cursor.sh [--skip-check] [--no-desktop] [--update-only]
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes réseau

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

SKIP_CHECK=false
NO_DESKTOP=false
UPDATE_ONLY=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-check) SKIP_CHECK=true; shift ;;
        --no-desktop) NO_DESKTOP=true; shift ;;
        --update-only) UPDATE_ONLY=true; shift ;;
        *) echo "Option inconnue: $1"; exit 1 ;;
    esac
done

################################################################################
# ÉTAPE 1: Vérification installation existante
################################################################################
if [ "$SKIP_CHECK" = false ]; then
    echo "═══════════════════════════════════"
    echo "1. Vérification installation"
    echo "═══════════════════════════════════"

    if command -v cursor &> /dev/null || [ -f /opt/cursor.appimage ]; then
        log_warn "Cursor déjà installé"
        if command -v cursor &> /dev/null; then
            CURSOR_VERSION=$(cursor --version 2>/dev/null || echo "version inconnue")
            log_info "Version actuelle: $CURSOR_VERSION"
        fi
        read -p "Mettre à jour? (o/n): " update_choice
        if [[ "$update_choice" =~ ^[nN]$ ]]; then
            log_info "Installation annulée"
            exit 0
        fi
        UPDATE_ONLY=true
        # Nettoyer l'ancienne installation
        sudo rm -f /opt/cursor.appimage
        sudo rm -f /usr/local/bin/cursor
    fi
fi

################################################################################
# ÉTAPE 2: Téléchargement Cursor AppImage
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "2. Téléchargement Cursor AppImage"
echo "═══════════════════════════════════"

CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"

log_info "Téléchargement depuis: $CURSOR_URL"

# Vérifier la connexion internet d'abord
if ! curl -s --head --fail "https://downloader.cursor.sh" > /dev/null 2>&1; then
    log_error "Impossible de se connecter à downloader.cursor.sh"
    log_warn "Vérifiez votre connexion internet et votre résolution DNS"
    log_warn "Vous pouvez essayer: ping downloader.cursor.sh"
    exit 1
fi

if ! sudo curl -L -o /opt/cursor.appimage "$CURSOR_URL" 2>/dev/null; then
    log_error "Erreur lors du téléchargement de Cursor"
    log_warn "Vérifiez votre connexion internet et réessayez"
    exit 1
fi

sudo chmod +x /opt/cursor.appimage

log_info "✓ AppImage téléchargée: /opt/cursor.appimage"

if [ "$UPDATE_ONLY" = true ]; then
    log_info "✓ Cursor mis à jour avec succès"
    log_warn "Relancez Cursor pour utiliser la nouvelle version"
    exit 0
fi

################################################################################
# ÉTAPE 3: Téléchargement icône
################################################################################
if [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "3. Téléchargement icône"
    echo "═══════════════════════════════════"

    mkdir -p ~/.local/share/icons

    curl -L -o ~/.local/share/icons/cursor.png "https://www.cursor.com/favicon.png" 2>/dev/null || \
        curl -L -o ~/.local/share/icons/cursor.png "https://cursor.sh/favicon.ico" 2>/dev/null || \
        log_warn "Téléchargement icône échoué (optionnel)"

    log_info "✓ Icône téléchargée"
fi

################################################################################
# ÉTAPE 4: Création fichier .desktop
################################################################################
if [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "4. Création raccourci .desktop"
    echo "═══════════════════════════════════"

    mkdir -p ~/.local/share/applications

    cat > ~/.local/share/applications/cursor.desktop <<EOF
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.appimage --no-sandbox %U
Icon=$HOME/.local/share/icons/cursor.png
Type=Application
Categories=Development;IDE;TextEditor;
Comment=AI-powered code editor
Terminal=false
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;
EOF

    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

    log_info "✓ Raccourci créé"
fi

################################################################################
# ÉTAPE 5: Création script de mise à jour
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "5. Création script de mise à jour"
echo "═══════════════════════════════════"

mkdir -p ~/.local/bin

cat > ~/.local/bin/update-cursor <<'UPDATESCRIPT'
#!/bin/bash
echo "🔄 Mise à jour de Cursor..."
CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
sudo curl -L -o /opt/cursor.appimage "$CURSOR_URL"
sudo chmod +x /opt/cursor.appimage
echo "✅ Cursor mis à jour!"
echo "Relancez Cursor pour utiliser la nouvelle version"
UPDATESCRIPT

chmod +x ~/.local/bin/update-cursor

log_info "✓ Script update-cursor créé"

################################################################################
# ÉTAPE 6: Création alias via add_alias si disponible
################################################################################
if [ "$UPDATE_ONLY" = false ] && [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "6. Création alias"
    echo "═══════════════════════════════════"
    
    if type add_alias &> /dev/null; then
        log_info "Création alias via add_alias..."
        add_alias "cursor" "/opt/cursor.appimage" "Cursor IDE - AI-powered code editor"
        log_info "✓ Alias créé via add_alias"
    else
        log_warn "add_alias non disponible, ajout manuel dans aliases.zsh..."
        ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"
        if [ -f "$ALIASES_FILE" ]; then
            if ! grep -q "^alias cursor=" "$ALIASES_FILE"; then
                echo "" >> "$ALIASES_FILE"
                echo "# Cursor IDE" >> "$ALIASES_FILE"
                echo "alias cursor='/opt/cursor.appimage'" >> "$ALIASES_FILE"
                log_info "✓ Alias ajouté dans $ALIASES_FILE"
            else
                log_info "✓ Alias déjà présent"
            fi
        fi
    fi
fi

################################################################################
# ÉTAPE 7: Vérification finale
################################################################################
if [ "$UPDATE_ONLY" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "7. Vérification"
    echo "═══════════════════════════════════"
    
    if [ -f /opt/cursor.appimage ] && [ -x /opt/cursor.appimage ]; then
        log_info "✓ Cursor AppImage installé et exécutable"
        if /opt/cursor.appimage --version &> /dev/null; then
            VERSION=$(/opt/cursor.appimage --version 2>/dev/null || echo "version inconnue")
            log_info "✓ Version: $VERSION"
        fi
    else
        log_error "✗ Erreur lors de la vérification"
        exit 1
    fi
fi

################################################################################
# RÉSUMÉ
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "✅ Installation terminée!"
echo "═══════════════════════════════════"
echo ""
echo "Cursor installé: /opt/cursor.appimage"
echo ""
echo "Commandes disponibles:"
echo "  cursor                  # Lancer Cursor (via .desktop ou alias)"
echo "  /opt/cursor.appimage    # Lancer directement"
echo "  update-cursor           # Mettre à jour Cursor"
echo ""
echo "Options disponibles pour ce script:"
echo "  --skip-check    Ne pas vérifier si déjà installé"
echo "  --no-desktop    Ne pas créer le raccourci .desktop"
echo "  --update-only   Mettre à jour uniquement (pas de .desktop)"
echo ""
