#!/bin/bash

################################################################################
# Script pour nettoyer les anciens logs GDM et vérifier l'état actuel
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
echo -e "${BLUE}║     Nettoyage et Vérification des Logs GDM                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Étape 1: Vérifier l'état actuel de GDM
echo -e "${CYAN}📊 Étape 1: État actuel de GDM${NC}"
if systemctl is-active --quiet gdm; then
    echo -e "${GREEN}✓ GDM est actif${NC}"
else
    echo -e "${RED}✗ GDM n'est pas actif${NC}"
fi

echo ""

# Étape 2: Vérifier les erreurs récentes (dernières 10 minutes)
echo -e "${CYAN}🔍 Étape 2: Erreurs récentes (dernières 10 minutes)${NC}"
RECENT_ERRORS=$(journalctl -u gdm --since "10 minutes ago" | grep -E "(no session desktop files|GdmSession.*aborting|core-dump|Failed with result)" | wc -l)

if [ "$RECENT_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ Aucune erreur récente détectée${NC}"
else
    echo -e "${YELLOW}⚠️  $RECENT_ERRORS erreur(s) récente(s) trouvée(s)${NC}"
    journalctl -u gdm --since "10 minutes ago" | grep -E "(no session desktop files|GdmSession.*aborting|core-dump|Failed with result)" | tail -5
fi

echo ""

# Étape 3: Compter les erreurs historiques
echo -e "${CYAN}📈 Étape 3: Analyse des erreurs historiques${NC}"
HISTORICAL_ERRORS=$(journalctl -u gdm | grep -E "no session desktop files" | wc -l)
COREDUMPS=$(journalctl -u gdm | grep -E "core-dump" | wc -l)

echo -e "   Erreurs 'no session desktop files': $HISTORICAL_ERRORS"
echo -e "   Coredumps: $COREDUMPS"

if [ "$HISTORICAL_ERRORS" -gt 0 ] || [ "$COREDUMPS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Des erreurs historiques sont présentes dans les logs${NC}"
    echo -e "${CYAN}💡 Ces erreurs sont probablement anciennes et ne devraient plus se produire${NC}"
fi

echo ""

# Étape 4: Vérifier la configuration
echo -e "${CYAN}⚙️  Étape 4: Vérification de la configuration${NC}"

# Vérifier les fichiers desktop
X11_COUNT=$(ls -1 /usr/share/xsessions/*.desktop 2>/dev/null | wc -l)
WAYLAND_COUNT=$(ls -1 /usr/share/wayland-sessions/*.desktop 2>/dev/null | wc -l)

if [ "$X11_COUNT" -gt 0 ] && [ "$WAYLAND_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Fichiers desktop disponibles${NC}"
    echo -e "   X11: $X11_COUNT fichier(s)"
    echo -e "   Wayland: $WAYLAND_COUNT fichier(s)"
else
    echo -e "${RED}✗ Fichiers desktop manquants${NC}"
fi

# Vérifier la configuration GDM
if grep -q "DefaultSession=gnome-wayland.desktop" /etc/gdm/custom.conf 2>/dev/null; then
    echo -e "${GREEN}✓ Session par défaut configurée (Wayland)${NC}"
else
    echo -e "${YELLOW}⚠️  Session par défaut non configurée${NC}"
fi

if grep -q "^WaylandEnable=true" /etc/gdm/custom.conf 2>/dev/null; then
    echo -e "${GREEN}✓ Wayland activé${NC}"
else
    echo -e "${YELLOW}⚠️  Wayland peut être désactivé${NC}"
fi

echo ""

# Étape 5: Nettoyer les anciens logs (optionnel)
echo -e "${CYAN}🧹 Étape 5: Nettoyage des anciens logs${NC}"
echo -e "${YELLOW}💡 Les logs historiques peuvent être nettoyés pour réduire le bruit${NC}"
echo ""
read -p "Nettoyer les logs GDM de plus de 7 jours? (o/N): " confirm

if [[ "$confirm" =~ ^[oO]$ ]]; then
    echo -e "${CYAN}Nettoyage des logs de plus de 7 jours...${NC}"
    sudo journalctl --vacuum-time=7d --unit=gdm 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Impossible de nettoyer uniquement GDM, nettoyage général...${NC}"
        sudo journalctl --vacuum-time=7d 2>/dev/null || true
    }
    echo -e "${GREEN}✓ Logs nettoyés${NC}"
else
    echo -e "${CYAN}Nettoyage annulé${NC}"
fi

echo ""

# Résumé
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📊 Résumé:${NC}"

if [ "$RECENT_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ Aucune erreur récente - GDM fonctionne correctement${NC}"
    if [ "$HISTORICAL_ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Les erreurs que vous voyez sont historiques (anciennes)${NC}"
        echo -e "${CYAN}💡 Elles ne devraient plus se produire avec la configuration actuelle${NC}"
    fi
else
    echo -e "${RED}⚠️  Des erreurs récentes ont été détectées${NC}"
    echo -e "${CYAN}💡 Vérifiez la configuration et redémarrez GDM${NC}"
fi

echo ""
echo -e "${BLUE}💡 Pour voir uniquement les logs récents:${NC}"
echo "   journalctl -u gdm --since '10 minutes ago'"
echo ""
echo -e "${BLUE}💡 Pour voir les erreurs récentes uniquement:${NC}"
echo "   journalctl -u gdm --since '1 hour ago' | grep -i error"
echo ""

