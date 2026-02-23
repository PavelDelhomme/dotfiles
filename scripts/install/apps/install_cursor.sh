#!/bin/bash

################################################################################
# Installation modulaire de Cursor IDE
# Version et URLs récupérées dynamiquement depuis https://cursor.com/download
# Formats: AppImage (Arch, Gentoo, etc.), .deb (Debian/Ubuntu), .rpm (Fedora/RHEL/openSUSE)
# Usage: ./install_cursor.sh [--skip-check] [--no-desktop] [--update-only]
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes réseau

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    log_info() { echo "[INFO] $*"; }
    log_warn() { echo "[WARN] $*"; }
    log_error() { echo "[ERROR] $*"; }
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
# Détection distribution et format (AppImage / .deb / .rpm)
################################################################################
detect_cursor_format() {
    local id="" id_like=""
    [ -f /etc/os-release ] && id=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
    [ -f /etc/os-release ] && id_like=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]' || true)
    # Arch, Manjaro, Gentoo, Alpine, etc. -> AppImage
    case "$id" in
        arch|archlinux|manjaro|gentoo|alpine) echo "appimage"; return ;;
    esac
    case "$id_like" in
        *arch*) echo "appimage"; return ;;
    esac
    # Debian / Ubuntu -> .deb
    case "$id" in
        debian|ubuntu) echo "deb"; return ;;
    esac
    case "$id_like" in
        *debian*) echo "deb"; return ;;
    esac
    # Fedora, RHEL, openSUSE, CentOS -> .rpm
    case "$id" in
        fedora|rhel|centos|ol|rocky|opensuse*|suse) echo "rpm"; return ;;
    esac
    case "$id_like" in
        *fedora*|*rhel*|*suse*) echo "rpm"; return ;;
    esac
    # Fallback: fichiers legacy
    [ -f /etc/arch-release ] && echo "appimage" && return
    [ -f /etc/debian_version ] && echo "deb" && return
    [ -f /etc/fedora-release ] && echo "rpm" && return
    echo "appimage"
}

# Architecture
CURSOR_ARCH="x64"
[ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ] && CURSOR_ARCH="arm64"

CURSOR_FORMAT=$(detect_cursor_format)
case "$CURSOR_FORMAT" in
    deb)   CURSOR_SUFFIX="linux-${CURSOR_ARCH}-deb" ;;
    rpm)   CURSOR_SUFFIX="linux-${CURSOR_ARCH}-rpm" ;;
    *)     CURSOR_SUFFIX="linux-${CURSOR_ARCH}" ;;  # appimage
esac

################################################################################
# ÉTAPE 1: Vérification installation existante
################################################################################
if [ "$SKIP_CHECK" = false ]; then
    echo "═══════════════════════════════════"
    echo "1. Vérification installation"
    echo "═══════════════════════════════════"

    if command -v cursor &>/dev/null || [ -f /opt/cursor.appimage ] && [ -x /opt/cursor.appimage ]; then
        log_warn "Cursor déjà installé"
        if [ -d /usr/share/cursor/resources/app ]; then
            log_info "Installation détectée: paquet (/usr/share/cursor)"
        elif [ -x /opt/cursor.appimage ]; then
            log_info "Installation détectée: AppImage (/opt/cursor.appimage)"
        fi
        if command -v cursor &>/dev/null; then
            CURSOR_VERSION_CURRENT=$(cursor --version 2>/dev/null || echo "version inconnue")
            log_info "Version actuelle: $CURSOR_VERSION_CURRENT"
        elif [ -x /opt/cursor.appimage ]; then
            CURSOR_VERSION_CURRENT=$(/opt/cursor.appimage --version 2>/dev/null || echo "version inconnue")
            log_info "Version actuelle: $CURSOR_VERSION_CURRENT"
        fi
        if [ "${NON_INTERACTIVE:-0}" != "1" ]; then
            read -p "Mettre à jour? (o/n): " update_choice
            if [[ "$update_choice" =~ ^[nN]$ ]]; then
                log_info "Installation annulée"
                exit 0
            fi
        fi
        UPDATE_ONLY=true
        # Nettoyer l'ancienne installation uniquement pour AppImage (on va réécrire /opt/cursor.appimage)
        if [ "$CURSOR_FORMAT" = "appimage" ]; then
            sudo rm -f /opt/cursor.appimage
            sudo rm -f /usr/local/bin/cursor
        fi
    fi
fi

################################################################################
# ÉTAPE 2: Récupération version + URL depuis https://cursor.com/download
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "2. Version et téléchargement (cursor.com/download)"
echo "═══════════════════════════════════"

if ! curl -s --head --fail "https://cursor.com" >/dev/null 2>&1; then
    log_error "Impossible de se connecter à cursor.com"
    log_warn "Vérifiez votre connexion internet et votre résolution DNS"
    exit 1
fi

log_info "Récupération de la dernière version depuis https://cursor.com/download ..."

CURSOR_VERSION=""
CURSOR_URL=""
TEMP_HTML=$(mktemp)
trap 'rm -f "$TEMP_HTML"' EXIT

if curl -s -L "https://cursor.com/download" -o "$TEMP_HTML" 2>/dev/null; then
    # Extraire la version depuis le lien qui correspond exactement à notre format (évite 2.4 si la page liste plusieurs versions)
    CURSOR_VERSION=$(grep -oE "https://api2\.cursor\.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/[0-9]+\.[0-9]+" "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+$')
    if [ -z "$CURSOR_VERSION" ]; then
        # Fallback: n'importe quel lien Linux
        CURSOR_VERSION=$(grep -oE "https://api2\.cursor\.sh/updates/download/golden/linux-[^/]+/cursor/[0-9]+\.[0-9]+" "$TEMP_HTML" 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+$')
    fi
    if [ -n "$CURSOR_VERSION" ]; then
        CURSOR_URL="https://api2.cursor.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/${CURSOR_VERSION}"
        log_info "Dernière version (cursor.com/download): $CURSOR_VERSION"
    fi
fi

if [ -z "$CURSOR_URL" ]; then
    CURSOR_URL="https://api2.cursor.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/latest"
    log_warn "Version non détectée depuis la page, utilisation de 'latest'"
fi

log_info "Format: $CURSOR_FORMAT | Arch: $CURSOR_ARCH"
log_info "Téléchargement depuis: $CURSOR_URL"

################################################################################
# Téléchargement et installation selon le format
################################################################################
install_cursor_appimage() {
    log_info "Téléchargement AppImage en cours..."
    if ! sudo curl -L --progress-bar -o /opt/cursor.appimage "$CURSOR_URL" 2>/dev/null; then
        log_warn "Tentative avec /latest..."
        if ! sudo curl -L --progress-bar -o /opt/cursor.appimage "https://api2.cursor.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/latest" 2>/dev/null; then
            log_error "Erreur lors du téléchargement de Cursor"
            return 1
        fi
    fi
    sudo chmod +x /opt/cursor.appimage
    # Pour que la commande "cursor" lance l'AppImage (prioritaire sur /usr/bin/cursor du paquet)
    sudo ln -sf /opt/cursor.appimage /usr/local/bin/cursor 2>/dev/null || true
    log_info "✓ AppImage installée: /opt/cursor.appimage"
    log_info "  Lien: /usr/local/bin/cursor → /opt/cursor.appimage (priorité sur le paquet si /usr/local/bin est dans le PATH)"
    return 0
}

install_cursor_deb() {
    local deb_file="/tmp/cursor_${CURSOR_VERSION:-latest}.deb"
    log_info "Téléchargement .deb en cours..."
    if ! curl -L --progress-bar -o "$deb_file" "$CURSOR_URL" 2>/dev/null; then
        curl -L --progress-bar -o "$deb_file" "https://api2.cursor.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/latest" 2>/dev/null || true
    fi
    if [ ! -f "$deb_file" ] || [ ! -s "$deb_file" ]; then
        log_error "Erreur lors du téléchargement du .deb"
        return 1
    fi
    log_info "Installation du paquet .deb..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y "$deb_file" 2>/dev/null || sudo dpkg -i "$deb_file" 2>/dev/null
    else
        sudo dpkg -i "$deb_file" 2>/dev/null
    fi
    rm -f "$deb_file"
    log_info "✓ Cursor (.deb) installé"
    return 0
}

install_cursor_rpm() {
    local rpm_file="/tmp/cursor_${CURSOR_VERSION:-latest}.rpm"
    log_info "Téléchargement .rpm en cours..."
    if ! curl -L --progress-bar -o "$rpm_file" "$CURSOR_URL" 2>/dev/null; then
        curl -L --progress-bar -o "$rpm_file" "https://api2.cursor.sh/updates/download/golden/${CURSOR_SUFFIX}/cursor/latest" 2>/dev/null || true
    fi
    if [ ! -f "$rpm_file" ] || [ ! -s "$rpm_file" ]; then
        log_error "Erreur lors du téléchargement du .rpm"
        return 1
    fi
    log_info "Installation du paquet .rpm..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y "$rpm_file" 2>/dev/null
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$rpm_file" 2>/dev/null
    else
        sudo rpm -Uhi "$rpm_file" 2>/dev/null
    fi
    rm -f "$rpm_file"
    log_info "✓ Cursor (.rpm) installé"
    return 0
}

# S'assurer que l'icône Cursor existe (pour le .desktop) et écrire le raccourci .desktop
ensure_cursor_icon_and_desktop() {
    local icon_target="$HOME/.local/share/icons/cursor.png"
    mkdir -p "$HOME/.local/share/icons" "$HOME/.local/share/applications"
    if [ -n "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/images/icons/cursor.png" ]; then
        cp "$DOTFILES_DIR/images/icons/cursor.png" "$icon_target" 2>/dev/null && log_info "✓ Icône Cursor depuis dotfiles" || true
    fi
    if [ ! -s "$icon_target" ]; then
        curl -L -s -o "$icon_target" "https://www.cursor.com/favicon.png" 2>/dev/null || \
        curl -L -s -o "$icon_target" "https://cursor.com/apple-touch-icon.png" 2>/dev/null || \
        curl -L -s -o "$icon_target" "https://cursor.sh/favicon.ico" 2>/dev/null || true
        [ -s "$icon_target" ] && log_info "✓ Icône Cursor téléchargée" || true
    fi
    local icon_path="$icon_target"
    [ -f "$icon_path" ] || icon_path="cursor"
    cat > "$HOME/.local/share/applications/cursor.desktop" <<DESKTOP
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.appimage --no-sandbox %U
Icon=$icon_path
Type=Application
Categories=Development;IDE;TextEditor;
Comment=AI-powered code editor
Terminal=false
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;
DESKTOP
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    log_info "✓ Raccourci cursor.desktop: ~/.local/share/applications/cursor.desktop (Exec=/opt/cursor.appimage, Icon=$icon_path)"
}

case "$CURSOR_FORMAT" in
    deb) install_cursor_deb   || exit 1 ;;
    rpm) install_cursor_rpm || exit 1 ;;
    *)   install_cursor_appimage || exit 1 ;;
esac

if [ "$UPDATE_ONLY" = true ]; then
    if [ "$CURSOR_FORMAT" = "appimage" ]; then
        ensure_cursor_icon_and_desktop
    fi
    log_info "✓ Cursor mis à jour avec succès"
    log_warn "Fermez Cursor puis relancez-le (icône ou commande 'cursor') pour utiliser la version ${CURSOR_VERSION:-latest}"
    exit 0
fi

################################################################################
# ÉTAPE 3–4: Icône et .desktop (uniquement pour AppImage)
################################################################################
if [ "$CURSOR_FORMAT" = "appimage" ] && [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "3. Configuration icône et raccourci"
    echo "═══════════════════════════════════"
    ensure_cursor_icon_and_desktop
fi

################################################################################
# ÉTAPE 5: Script update-cursor (réutilise ce script en --update-only)
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "5. Script de mise à jour (update-cursor)"
echo "═══════════════════════════════════"

mkdir -p ~/.local/bin
cat > ~/.local/bin/update-cursor <<'UPDATESCRIPT'
#!/usr/bin/env bash
# Mise à jour Cursor depuis https://cursor.com/download
# Généré par install_cursor.sh / installman cursor
export NON_INTERACTIVE=1
# Trouver les dotfiles (plusieurs emplacements possibles)
DOTFILES=""
for candidate in "${DOTFILES_DIR:-}" "$HOME/dotfiles" "$HOME/.dotfiles"; do
    [ -z "$candidate" ] && continue
    if [ -f "$candidate/scripts/install/apps/install_cursor.sh" ]; then
        DOTFILES="$candidate"
        break
    fi
done
if [ -n "$DOTFILES" ]; then
    export DOTFILES_DIR="$DOTFILES"
    exec bash "$DOTFILES_DIR/scripts/install/apps/install_cursor.sh" --update-only
fi
echo "Erreur: script install_cursor.sh introuvable." >&2
echo "  Vérifiez que vos dotfiles sont dans ~/dotfiles ou définissez DOTFILES_DIR." >&2
echo "  Ex: export DOTFILES_DIR=~/dotfiles && update-cursor" >&2
exit 1
UPDATESCRIPT
chmod +x ~/.local/bin/update-cursor
log_info "✓ update-cursor créé: ~/.local/bin/update-cursor"
log_info "  Pour l'utiliser: assurez-vous que ~/.local/bin est dans votre PATH (ex: dans .zshrc ou env.sh)"
log_info "  Sinon lancez directement: ~/.local/bin/update-cursor"

################################################################################
# ÉTAPE 6: Alias (AppImage: /opt/cursor.appimage ; deb/rpm: commande cursor)
################################################################################
if [ "$NO_DESKTOP" = false ]; then
    echo ""
    echo "═══════════════════════════════════"
    echo "6. Alias"
    echo "═══════════════════════════════════"
    CURSOR_EXEC="/opt/cursor.appimage"
    [ "$CURSOR_FORMAT" != "appimage" ] && CURSOR_EXEC="cursor"
    if type add_alias &>/dev/null; then
        add_alias "cursor" "$CURSOR_EXEC" "Cursor IDE - AI-powered code editor"
        log_info "✓ Alias créé via add_alias"
    elif [ -f "$HOME/dotfiles/zsh/aliases.zsh" ]; then
        if ! grep -q "^alias cursor=" "$HOME/dotfiles/zsh/aliases.zsh"; then
            echo "" >> "$HOME/dotfiles/zsh/aliases.zsh"
            echo "# Cursor IDE" >> "$HOME/dotfiles/zsh/aliases.zsh"
            echo "alias cursor='$CURSOR_EXEC'" >> "$HOME/dotfiles/zsh/aliases.zsh"
            log_info "✓ Alias ajouté dans zsh/aliases.zsh"
        fi
    fi
fi

################################################################################
# ÉTAPE 7: Vérification finale
################################################################################
echo ""
echo "═══════════════════════════════════"
echo "7. Vérification"
echo "═══════════════════════════════════"

if [ "$CURSOR_FORMAT" = "appimage" ]; then
    if [ -f /opt/cursor.appimage ] && [ -x /opt/cursor.appimage ]; then
        log_info "✓ Cursor AppImage installé: /opt/cursor.appimage"
        /opt/cursor.appimage --version 2>/dev/null && log_info "✓ Version: $(/opt/cursor.appimage --version 2>/dev/null | head -n1)"
    else
        log_error "✗ Vérification AppImage échouée"
        exit 1
    fi
else
    if command -v cursor &>/dev/null; then
        log_info "✓ Cursor installé: $(command -v cursor)"
        cursor --version 2>/dev/null && log_info "✓ Version: $(cursor --version 2>/dev/null | head -n1)"
    else
        log_warn "Commande 'cursor' non trouvée dans PATH (redémarrez le terminal ou exécutez hash -r)"
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
echo "Format utilisé: $CURSOR_FORMAT (détecté depuis la distribution)"
echo "Version récupérée depuis: https://cursor.com/download"
[ -n "$CURSOR_VERSION" ] && echo "Version installée: $CURSOR_VERSION"
echo ""
echo "Commandes:"
echo "  cursor          # Lancer Cursor"
echo "  update-cursor   # Mettre à jour (réutilise cursor.com/download)"
echo ""
echo "Options du script:"
echo "  --skip-check    Ne pas vérifier si déjà installé"
echo "  --no-desktop    Ne pas créer .desktop / alias"
echo "  --update-only   Mise à jour uniquement"
echo ""
