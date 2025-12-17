#!/bin/bash

################################################################################
# Script de correction de la police du terminal
# Force la configuration de MesloLGS Nerd Font dans GNOME Console
# Usage: bash ~/dotfiles/scripts/config/fix_terminal_font.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Correction de la police du terminal"

# Vérifier que la police est installée
if ! fc-list | grep -qi "meslo.*nerd"; then
    log_warn "⚠️  MesloLGS Nerd Font non trouvée"
    log_info "Installation de la police..."
    bash "$SCRIPT_DIR/config/install_nerd_fonts.sh" || {
        log_error "Échec de l'installation de la police"
        exit 1
    }
fi

# Configurer la police pour GNOME Console
log_info "Configuration de la police pour GNOME Console..."

# Essayer différentes variantes de la police
FONT_VARIANTS=(
    "MesloLGS Nerd Font Mono 12"
    "MesloLGS NF 12"
    "MesloLGS Nerd Font 12"
    "MesloLGSDZ Nerd Font Mono 12"
)

FONT_SET=false
for font_variant in "${FONT_VARIANTS[@]}"; do
    if fc-list | grep -qi "$(echo "$font_variant" | cut -d' ' -f1)"; then
        log_info "Configuration avec: $font_variant"
        dconf write /org/gnome/Console/font "'$font_variant'" 2>/dev/null && {
            log_info "✓ Police configurée: $font_variant"
            FONT_SET=true
            break
        } || {
            log_warn "⚠️  Échec avec: $font_variant"
        }
    fi
done

if [ "$FONT_SET" = false ]; then
    # Utiliser la première variante disponible
    log_info "Configuration avec variante par défaut..."
    dconf write /org/gnome/Console/font "'MesloLGS Nerd Font Mono 12'" 2>/dev/null || {
        log_error "Impossible de configurer la police via dconf"
        log_info "Configuration manuelle requise"
    }
fi

# Vérifier la configuration
CURRENT_FONT=$(dconf read /org/gnome/Console/font 2>/dev/null || echo "")
if [ -n "$CURRENT_FONT" ]; then
    log_info "✓ Police actuellement configurée: $CURRENT_FONT"
else
    log_warn "⚠️  Police non détectée dans dconf"
fi

log_section "Instructions pour appliquer les changements"

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "🔄 Pour voir les icônes, vous devez redémarrer le terminal:"
echo ""
echo "Option 1 (rapide): Redémarrer la session GNOME"
echo "  - Appuyez sur Alt+F2"
echo "  - Tapez 'r' et appuyez sur Entrée"
echo "  - OU déconnectez-vous et reconnectez-vous"
echo ""
echo "Option 2: Fermer et rouvrir le terminal"
echo "  - Fermez TOUTES les fenêtres du terminal"
echo "  - Rouvrez un nouveau terminal"
echo ""
echo "Option 3: Redémarrer l'ordinateur"
echo "  - C'est la solution la plus sûre"
echo ""
echo "💡 Après redémarrage, les icônes devraient s'afficher!"
echo ""

