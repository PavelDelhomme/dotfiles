#!/bin/bash

################################################################################
# Installation modulaire de Cursor IDE
# Usage: ./install_cursor.sh [--skip-check] [--no-desktop] [--update-only]
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes réseau

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

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
        elif [ -x /opt/cursor.appimage ]; then
            CURSOR_VERSION=$(/opt/cursor.appimage --version 2>/dev/null || echo "version inconnue")
            log_info "Version actuelle: $CURSOR_VERSION"
        fi
        if [ "${NON_INTERACTIVE:-0}" != "1" ]; then
            read -p "Mettre à jour? (o/n): " update_choice
            if [[ "$update_choice" =~ ^[nN]$ ]]; then
                log_info "Installation annulée"
                exit 0
            fi
        fi
        UPDATE_ONLY=true
        # Nettoyer l'ancienne installation
        sudo rm -f /opt/cursor.appimage
        sudo rm -f /usr/local/bin/cursor
    fi
fi

################################################################################
# ÉTAPE 2: Vérification dernière version et téléchargement Cursor AppImage
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "2. Vérification version et téléchargement Cursor AppImage"
echo "═══════════════════════════════════"

# Vérifier la connexion internet d'abord
if ! curl -s --head --fail "https://cursor.com" > /dev/null 2>&1; then
    log_error "Impossible de se connecter à cursor.com"
    log_warn "Vérifiez votre connexion internet et votre résolution DNS"
    exit 1
fi

log_info "Vérification de la dernière version disponible sur cursor.com..."

# Télécharger la page cursor.com et chercher la version "Latest"
# On cherche dans le HTML le badge "Latest" ou les informations de version
CURSOR_VERSION=""
TEMP_HTML=$(mktemp)

# Télécharger la page cursor.com
if curl -s -L "https://cursor.com" -o "$TEMP_HTML" 2>/dev/null; then
    # Chercher le badge "Latest" ou une indication de version
    # On peut aussi chercher dans les meta tags ou les données structurées
    CURSOR_VERSION=$(grep -oP '(?<=Latest|latest|version|Version)[^<]*[0-9]+\.[0-9]+\.[0-9]+' "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    
    # Alternative: chercher dans le texte "Download for Linux" ou similaire
    if [ -z "$CURSOR_VERSION" ]; then
        CURSOR_VERSION=$(grep -iE "(version|v)[\s:]+[0-9]+\.[0-9]+\.[0-9]+" "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    fi
fi

rm -f "$TEMP_HTML"

if [ -n "$CURSOR_VERSION" ]; then
    log_info "Dernière version détectée: $CURSOR_VERSION"
else
    log_warn "Impossible de détecter la version, utilisation de la version par défaut"
fi

# URL de téléchargement pour Linux AppImage x64
CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"

log_info "Téléchargement depuis: $CURSOR_URL"

# Vérifier que downloader.cursor.sh est accessible
if ! curl -s --head --fail "https://downloader.cursor.sh" > /dev/null 2>&1; then
    log_error "Impossible de se connecter à downloader.cursor.sh"
    log_warn "Vérifiez votre connexion internet et votre résolution DNS"
    exit 1
fi

# Télécharger l'AppImage (URL principale + fallback pour Linux)
log_info "Téléchargement en cours..."
CURSOR_URL_ALT="https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/latest"
if ! sudo curl -L --progress-bar -o /opt/cursor.appimage "$CURSOR_URL" 2>/dev/null; then
    log_warn "Premier miroir échoué, tentative fallback..."
    if ! sudo curl -L --progress-bar -o /opt/cursor.appimage "$CURSOR_URL_ALT" 2>/dev/null; then
        log_error "Erreur lors du téléchargement de Cursor"
        log_warn "Vérifiez votre connexion internet et réessayez"
        exit 1
    fi
fi

sudo chmod +x /opt/cursor.appimage

log_info "✓ AppImage téléchargée: /opt/cursor.appimage"
if [ -n "$CURSOR_VERSION" ]; then
    log_info "✓ Version installée: $CURSOR_VERSION"
fi

if [ "$UPDATE_ONLY" = true ]; then
    log_info "✓ Cursor mis à jour avec succès"
    log_warn "Relancez Cursor pour utiliser la nouvelle version"
    exit 0
fi

################################################################################
# ÉTAPE 3: Vérification icône
################################################################################
if [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "3. Configuration icône"
    echo "═══════════════════════════════════"

    # Utiliser l'icône depuis le dossier dotfiles/images/icons/
    CURSOR_ICON_SOURCE="$DOTFILES_DIR/images/icons/cursor.png"
    CURSOR_ICON_TARGET="$HOME/.local/share/icons/cursor.png"
    
    mkdir -p "$(dirname "$CURSOR_ICON_TARGET")"
    
    if [ -f "$CURSOR_ICON_SOURCE" ]; then
        # Copier l'icône depuis dotfiles vers ~/.local/share/icons/
        cp "$CURSOR_ICON_SOURCE" "$CURSOR_ICON_TARGET"
        log_info "✓ Icône copiée depuis dotfiles: $CURSOR_ICON_SOURCE"
    else
        log_warn "Icône non trouvée dans $CURSOR_ICON_SOURCE"
        log_warn "Tentative de téléchargement depuis cursor.com..."
        
        # Fallback: télécharger l'icône si elle n'existe pas dans dotfiles
        if curl -L -s -o "$CURSOR_ICON_TARGET" "https://www.cursor.com/favicon.png" 2>/dev/null || \
           curl -L -s -o "$CURSOR_ICON_TARGET" "https://cursor.sh/favicon.ico" 2>/dev/null; then
            log_info "✓ Icône téléchargée depuis cursor.com"
        else
            log_warn "⚠ Téléchargement icône échoué, fichier .desktop utilisera l'icône par défaut"
        fi
    fi
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

    # Utiliser l'icône depuis dotfiles si disponible, sinon depuis ~/.local/share/icons/
    CURSOR_ICON=""
    if [ -f "$DOTFILES_DIR/images/icons/cursor.png" ]; then
        CURSOR_ICON="$DOTFILES_DIR/images/icons/cursor.png"
    elif [ -f "$HOME/.local/share/icons/cursor.png" ]; then
        CURSOR_ICON="$HOME/.local/share/icons/cursor.png"
    else
        # Pas d'icône trouvée, laisser vide pour utiliser l'icône par défaut
        CURSOR_ICON="cursor"
    fi

    cat > ~/.local/share/applications/cursor.desktop <<EOF
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.appimage --no-sandbox %U
Icon=$CURSOR_ICON
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
# Charger la bibliothèque commune si disponible
SCRIPT_DIR="$HOME/dotfiles/scripts"
if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    source "$SCRIPT_DIR/lib/common.sh"
fi

log_section "Mise à jour de Cursor"

# Vérifier la dernière version
log_info "Vérification de la dernière version..."

TEMP_HTML=$(mktemp)
CURSOR_VERSION=""

if curl -s -L "https://cursor.com" -o "$TEMP_HTML" 2>/dev/null; then
    CURSOR_VERSION=$(grep -oP '(?<=Latest|latest|version|Version)[^<]*[0-9]+\.[0-9]+\.[0-9]+' "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    if [ -z "$CURSOR_VERSION" ]; then
        CURSOR_VERSION=$(grep -iE "(version|v)[\s:]+[0-9]+\.[0-9]+\.[0-9]+" "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    fi
fi
rm -f "$TEMP_HTML"

if [ -n "$CURSOR_VERSION" ]; then
    log_info "Dernière version disponible: $CURSOR_VERSION"
fi

# Télécharger la dernière version
CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
log_info "Téléchargement depuis: $CURSOR_URL"

CURSOR_URL_ALT="https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/latest"
if sudo curl -L --progress-bar -o /opt/cursor.appimage "$CURSOR_URL" 2>/dev/null; then
    sudo chmod +x /opt/cursor.appimage
    log_info "✅ Cursor mis à jour!"
    echo "Relancez Cursor pour utiliser la nouvelle version"
elif sudo curl -L --progress-bar -o /opt/cursor.appimage "$CURSOR_URL_ALT" 2>/dev/null; then
    sudo chmod +x /opt/cursor.appimage
    log_info "✅ Cursor mis à jour (miroir de secours)!"
    echo "Relancez Cursor pour utiliser la nouvelle version"
else
    log_error "❌ Erreur lors de la mise à jour"
    exit 1
fi
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
