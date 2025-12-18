#!/bin/bash

################################################################################
# Script pour forcer l'écran principal (DP-1) comme écran par défaut
# Résout les problèmes de jeux qui démarrent sur le mauvais écran
################################################################################

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Configuration Écran Principal (DP-1)                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Détecter l'écran principal
PRIMARY_DISPLAY=$(xrandr --listactivemonitors 2>/dev/null | grep -E "^\s*0:" | awk '{print $4}' | sed 's/\+//' || echo "DP-1")

echo -e "${CYAN}📺 Écrans détectés:${NC}"
xrandr --listactivemonitors 2>/dev/null | while read line; do
    if echo "$line" | grep -q "^\s*0:"; then
        echo -e "${GREEN}  $line (PRINCIPAL)${NC}"
    else
        echo "  $line"
    fi
done

echo ""
echo -e "${CYAN}🔧 Configuration:${NC}"

# Vérifier si DP-1 est bien l'écran principal
if echo "$PRIMARY_DISPLAY" | grep -qi "DP-1"; then
    echo -e "${GREEN}✓ DP-1 est l'écran principal${NC}"
else
    echo -e "${YELLOW}⚠️  DP-1 n'est pas l'écran principal${NC}"
    echo -e "${YELLOW}💡 Pour définir DP-1 comme principal:${NC}"
    echo "   xrandr --output DP-1 --primary"
fi

echo ""
echo -e "${CYAN}📝 Variables d'environnement recommandées:${NC}"
echo ""
echo "export SDL_VIDEO_FULLSCREEN_DISPLAY=0  # Écran 0 (DP-1)"
echo "export SDL_VIDEODRIVER=x11"
echo "export DISPLAY=:0"
echo "export WINE_DISPLAY=:0"
echo ""

# Option: Définir DP-1 comme principal si ce n'est pas déjà le cas
if ! xrandr --listactivemonitors 2>/dev/null | grep -E "^\s*0:" | grep -qi "DP-1"; then
    echo -e "${YELLOW}⚠️  Voulez-vous définir DP-1 comme écran principal? (o/N)${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[oO]$ ]]; then
        xrandr --output DP-1 --primary && \
        echo -e "${GREEN}✓ DP-1 défini comme écran principal${NC}" || \
        echo -e "${RED}✗ Erreur lors de la définition${NC}"
    fi
fi

echo ""
echo -e "${BLUE}💡 Pour tester:${NC}"
echo "   bash ~/dotfiles/scripts/games/run_ultrakill.sh"
echo ""

