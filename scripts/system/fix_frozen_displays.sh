#!/bin/bash

################################################################################
# Script pour corriger les écrans gelés (freeze)
# Réinitialise la configuration multi-écrans
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
echo -e "${BLUE}║     Correction Écrans Gelés (Freeze)                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction pour réinitialiser un écran
reset_display() {
    local display=$1
    local mode=$2
    
    echo -e "${CYAN}🔄 Réinitialisation de $display...${NC}"
    
    # Désactiver puis réactiver l'écran
    xrandr --output "$display" --off 2>/dev/null || true
    sleep 0.5
    xrandr --output "$display" --mode "$mode" --auto 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Impossible de réinitialiser $display avec le mode $mode${NC}"
        echo -e "${CYAN}   Tentative avec auto-détection...${NC}"
        xrandr --output "$display" --auto 2>/dev/null || {
            echo -e "${RED}✗ Échec pour $display${NC}"
            return 1
        }
    }
    
    sleep 0.5
    echo -e "${GREEN}✓ $display réinitialisé${NC}"
}

# Étape 1: Vérifier l'état actuel
echo -e "${CYAN}📺 Étape 1: État actuel des écrans${NC}"
xrandr --listactivemonitors
echo ""

# Étape 2: Détecter les écrans et leurs modes
echo -e "${CYAN}📺 Étape 2: Détection des écrans et modes${NC}"

DP1_MODE=$(xrandr | grep -A1 "DP-1 connected" | grep -oE "[0-9]+x[0-9]+" | head -1 || echo "2560x1440")
HDMI1_MODE=$(xrandr | grep -A1 "HDMI-1 connected" | grep -oE "[0-9]+x[0-9]+" | head -1 || echo "1920x1080")
HDMI2_MODE=$(xrandr | grep -A1 "HDMI-2 connected" | grep -oE "[0-9]+x[0-9]+" | head -1 || echo "1600x900")

echo -e "   DP-1: ${GREEN}$DP1_MODE${NC}"
echo -e "   HDMI-1: ${GREEN}$HDMI1_MODE${NC}"
echo -e "   HDMI-2: ${GREEN}$HDMI2_MODE${NC}"
echo ""

# Étape 3: Vérifier les drivers NVIDIA
echo -e "${CYAN}🔍 Étape 3: Vérification des drivers NVIDIA${NC}"
if command -v nvidia-smi >/dev/null 2>&1; then
    if nvidia-smi >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Drivers NVIDIA fonctionnels${NC}"
        nvidia-smi --query-gpu=name,driver_version --format=csv,noheader | head -1
    else
        echo -e "${YELLOW}⚠️  nvidia-smi ne répond pas correctement${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  nvidia-smi non disponible${NC}"
fi
echo ""

# Étape 4: Réinitialiser les écrans un par un
echo -e "${CYAN}🔄 Étape 4: Réinitialisation des écrans${NC}"
echo -e "${YELLOW}⚠️  Cela peut causer un bref clignotement des écrans${NC}"
echo ""
read -p "Continuer? (o/N): " confirm
if [[ ! "$confirm" =~ ^[oO]$ ]]; then
    echo -e "${YELLOW}Annulé${NC}"
    exit 0
fi

# Réinitialiser DP-1 (écran principal)
if xrandr | grep -q "DP-1 connected"; then
    reset_display "DP-1" "$DP1_MODE"
    # Redéfinir comme principal
    xrandr --output DP-1 --primary 2>/dev/null || true
fi

# Réinitialiser HDMI-1
if xrandr | grep -q "HDMI-1 connected"; then
    reset_display "HDMI-1" "$HDMI1_MODE"
    # Repositionner à gauche de DP-1
    xrandr --output HDMI-1 --left-of DP-1 2>/dev/null || true
fi

# Réinitialiser HDMI-2
if xrandr | grep -q "HDMI-2 connected"; then
    reset_display "HDMI-2" "$HDMI2_MODE"
    # Repositionner à droite de DP-1
    xrandr --output HDMI-2 --right-of DP-1 2>/dev/null || true
fi

echo ""
echo -e "${CYAN}📺 Étape 5: État final des écrans${NC}"
xrandr --listactivemonitors
echo ""

# Étape 6: Vérifier les processus qui pourraient causer des problèmes
echo -e "${CYAN}🔍 Étape 6: Vérification des processus${NC}"
if pgrep -x "compton" >/dev/null 2>&1 || pgrep -x "picom" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Compositeur détecté (compton/picom)${NC}"
    echo -e "${CYAN}💡 Si les écrans sont toujours gelés, essayez de redémarrer le compositeur:${NC}"
    echo "   pkill picom && picom &"
    echo "   ou"
    echo "   pkill compton && compton &"
fi

echo ""
echo -e "${GREEN}✅ Réinitialisation terminée!${NC}"
echo ""
echo -e "${BLUE}💡 Si les écrans sont toujours gelés:${NC}"
echo "   1. Redémarrez le compositeur (picom/compton)"
echo "   2. Redémarrez la session GNOME: Alt+F2 puis 'r'"
echo "   3. Vérifiez les logs: journalctl -u gdm -n 50"
echo ""

