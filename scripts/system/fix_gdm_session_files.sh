#!/bin/bash

################################################################################
# Script pour corriger l'erreur GDM "no session desktop files installed"
# Résout les problèmes de crash GDM et écrans gelés
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Correction GDM - Session Desktop Files                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Étape 1: Vérifier les fichiers de session
echo -e "${CYAN}📁 Étape 1: Vérification des fichiers de session${NC}"

XSESSIONS_DIR="/usr/share/xsessions"
WAYLAND_SESSIONS_DIR="/usr/share/wayland-sessions"

echo -e "${CYAN}X11 Sessions (${XSESSIONS_DIR}):${NC}"
if [ -d "$XSESSIONS_DIR" ]; then
    count=$(ls -1 "$XSESSIONS_DIR"/*.desktop 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✓ $count fichier(s) trouvé(s)${NC}"
        ls -1 "$XSESSIONS_DIR"/*.desktop 2>/dev/null | while read file; do
            echo -e "   - $(basename "$file")"
        done
    else
        echo -e "${RED}✗ Aucun fichier .desktop trouvé${NC}"
    fi
else
    echo -e "${RED}✗ Dossier $XSESSIONS_DIR n'existe pas${NC}"
fi

echo ""
echo -e "${CYAN}Wayland Sessions (${WAYLAND_SESSIONS_DIR}):${NC}"
if [ -d "$WAYLAND_SESSIONS_DIR" ]; then
    count=$(ls -1 "$WAYLAND_SESSIONS_DIR"/*.desktop 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✓ $count fichier(s) trouvé(s)${NC}"
        ls -1 "$WAYLAND_SESSIONS_DIR"/*.desktop 2>/dev/null | while read file; do
            echo -e "   - $(basename "$file")"
        done
    else
        echo -e "${RED}✗ Aucun fichier .desktop trouvé${NC}"
    fi
else
    echo -e "${RED}✗ Dossier $WAYLAND_SESSIONS_DIR n'existe pas${NC}"
fi

echo ""

# Étape 2: Vérifier les paquets installés
echo -e "${CYAN}📦 Étape 2: Vérification des paquets${NC}"

check_package() {
    local pkg=$1
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
        local version=$(pacman -Qi "$pkg" | grep "^Version" | awk '{print $3}')
        echo -e "${GREEN}✓ $pkg installé (version: $version)${NC}"
        return 0
    else
        echo -e "${RED}✗ $pkg non installé${NC}"
        return 1
    fi
}

MISSING_PACKAGES=()

if ! check_package "gnome-session"; then
    MISSING_PACKAGES+=("gnome-session")
fi

if ! check_package "gdm"; then
    MISSING_PACKAGES+=("gdm")
fi

if ! check_package "gnome-shell"; then
    MISSING_PACKAGES+=("gnome-shell")
fi

echo ""

# Étape 3: Réinstaller les paquets si nécessaire
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Paquets manquants détectés${NC}"
    echo -e "${CYAN}📦 Installation des paquets manquants...${NC}"
    echo ""
    read -p "Installer les paquets manquants? (o/N): " confirm
    if [[ "$confirm" =~ ^[oO]$ ]]; then
        sudo pacman -S --noconfirm "${MISSING_PACKAGES[@]}" || {
            echo -e "${RED}✗ Erreur lors de l'installation${NC}"
            exit 1
        }
        echo -e "${GREEN}✓ Paquets installés${NC}"
    else
        echo -e "${YELLOW}Installation annulée${NC}"
    fi
    echo ""
fi

# Étape 4: Vérifier et réinstaller les fichiers desktop
echo -e "${CYAN}🔧 Étape 3: Vérification des fichiers desktop GNOME${NC}"

# Vérifier si gnome.desktop existe
GNOME_X11_DESKTOP="$XSESSIONS_DIR/gnome.desktop"
GNOME_WAYLAND_DESKTOP="$WAYLAND_SESSIONS_DIR/gnome.desktop"

if [ ! -f "$GNOME_X11_DESKTOP" ] && [ ! -f "$GNOME_WAYLAND_DESKTOP" ]; then
    echo -e "${YELLOW}⚠️  Fichiers desktop GNOME manquants${NC}"
    echo -e "${CYAN}📦 Réinstallation de gnome-session pour restaurer les fichiers...${NC}"
    echo ""
    read -p "Réinstaller gnome-session? (o/N): " confirm
    if [[ "$confirm" =~ ^[oO]$ ]]; then
        sudo pacman -S --noconfirm --overwrite="*" gnome-session || {
            echo -e "${RED}✗ Erreur lors de la réinstallation${NC}"
            exit 1
        }
        echo -e "${GREEN}✓ gnome-session réinstallé${NC}"
    fi
    echo ""
fi

# Étape 5: Vérifier les permissions
echo -e "${CYAN}🔐 Étape 4: Vérification des permissions${NC}"

if [ -d "$XSESSIONS_DIR" ]; then
    perms=$(stat -c "%a" "$XSESSIONS_DIR" 2>/dev/null || echo "unknown")
    echo -e "   $XSESSIONS_DIR: $perms"
    if [ "$perms" != "755" ] && [ "$perms" != "unknown" ]; then
        echo -e "${YELLOW}⚠️  Permissions incorrectes, correction...${NC}"
        sudo chmod 755 "$XSESSIONS_DIR" 2>/dev/null || true
    fi
fi

if [ -d "$WAYLAND_SESSIONS_DIR" ]; then
    perms=$(stat -c "%a" "$WAYLAND_SESSIONS_DIR" 2>/dev/null || echo "unknown")
    echo -e "   $WAYLAND_SESSIONS_DIR: $perms"
    if [ "$perms" != "755" ] && [ "$perms" != "unknown" ]; then
        echo -e "${YELLOW}⚠️  Permissions incorrectes, correction...${NC}"
        sudo chmod 755 "$WAYLAND_SESSIONS_DIR" 2>/dev/null || true
    fi
fi

echo ""

# Étape 6: Vérifier la configuration GDM
echo -e "${CYAN}⚙️  Étape 5: Vérification de la configuration GDM${NC}"

GDM_CUSTOM_CONF="/etc/gdm/custom.conf"
if [ -f "$GDM_CUSTOM_CONF" ]; then
    echo -e "${GREEN}✓ Fichier de configuration GDM trouvé${NC}"
    # Vérifier si Wayland est désactivé (peut causer des problèmes)
    if grep -q "^WaylandEnable=false" "$GDM_CUSTOM_CONF" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Wayland est désactivé dans GDM${NC}"
        echo -e "${CYAN}💡 Cela peut causer des problèmes. Voulez-vous le réactiver?${NC}"
        read -p "Réactiver Wayland? (o/N): " confirm
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            sudo sed -i 's/^WaylandEnable=false/#WaylandEnable=false/' "$GDM_CUSTOM_CONF" 2>/dev/null || true
            echo -e "${GREEN}✓ Wayland réactivé${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  Fichier de configuration GDM non trouvé${NC}"
fi

echo ""

# Étape 7: Nettoyer les coredumps
echo -e "${CYAN}🧹 Étape 6: Nettoyage des coredumps${NC}"
COREDUMP_COUNT=$(journalctl --list-coredumps 2>/dev/null | wc -l)
if [ "$COREDUMP_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $COREDUMP_COUNT coredump(s) trouvé(s)${NC}"
    echo -e "${CYAN}💡 Les coredumps peuvent être nettoyés avec:${NC}"
    echo "   sudo journalctl --vacuum-time=1d"
    echo ""
    read -p "Nettoyer les coredumps? (o/N): " confirm
    if [[ "$confirm" =~ ^[oO]$ ]]; then
        sudo journalctl --vacuum-time=1d 2>/dev/null || true
        echo -e "${GREEN}✓ Coredumps nettoyés${NC}"
    fi
else
    echo -e "${GREEN}✓ Aucun coredump récent${NC}"
fi

echo ""

# Résumé final
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📊 Résumé:${NC}"

# Vérifier à nouveau les fichiers
X11_COUNT=$(ls -1 "$XSESSIONS_DIR"/*.desktop 2>/dev/null | wc -l)
WAYLAND_COUNT=$(ls -1 "$WAYLAND_SESSIONS_DIR"/*.desktop 2>/dev/null | wc -l)

if [ "$X11_COUNT" -gt 0 ] || [ "$WAYLAND_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Fichiers de session disponibles${NC}"
    echo -e "   X11: $X11_COUNT fichier(s)"
    echo -e "   Wayland: $WAYLAND_COUNT fichier(s)"
else
    echo -e "${RED}✗ Aucun fichier de session trouvé${NC}"
    echo -e "${YELLOW}⚠️  Réinstallation complète de GNOME recommandée${NC}"
fi

echo ""
echo -e "${GREEN}✅ Correction terminée!${NC}"
echo ""
echo -e "${BLUE}💡 Prochaines étapes:${NC}"
echo "   1. Redémarrez GDM:"
echo "      sudo systemctl restart gdm"
echo ""
echo "   2. Ou redémarrez le système:"
echo "      sudo reboot"
echo ""
echo "   3. Vérifiez les logs après redémarrage:"
echo "      journalctl -u gdm -n 50"
echo ""

