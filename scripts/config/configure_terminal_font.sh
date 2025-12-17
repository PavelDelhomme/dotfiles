#!/bin/bash

################################################################################
# Configuration automatique de la police Nerd Font dans le terminal
# Détecte le terminal utilisé et configure la police MesloLGS NF
# Usage: bash ~/dotfiles/scripts/config/configure_terminal_font.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Configuration de la police Nerd Font dans le terminal"

# Détecter le terminal
TERMINAL=""
if [ -n "$TERM_PROGRAM" ]; then
    TERMINAL="$TERM_PROGRAM"
fi

# Détecter via le processus parent
PARENT_CMD=$(ps -o comm= -p $(ps -o ppid= -p $$) 2>/dev/null || echo "")
case "$PARENT_CMD" in
    *kitty*) TERMINAL="kitty" ;;
    *alacritty*) TERMINAL="alacritty" ;;
    *konsole*) TERMINAL="konsole" ;;
    *gnome-terminal*) TERMINAL="gnome-terminal" ;;
    *kgx*) TERMINAL="gnome-console" ;;
    *xterm*) TERMINAL="xterm" ;;
    *st*) TERMINAL="st" ;;
    *urxvt*) TERMINAL="urxvt" ;;
    *tilix*) TERMINAL="tilix" ;;
esac

# Détecter via le nom de la fenêtre ou d'autres méthodes
if [ -z "$TERMINAL" ] || [ "$TERMINAL" = "unknown" ]; then
    if echo "$PARENT_CMD" | grep -qi "kgx"; then
        TERMINAL="gnome-console"
    fi
fi

# Vérifier si MesloLGS NF est installée
if ! fc-list | grep -qi "meslo.*nerd"; then
    log_warn "⚠️  MesloLGS Nerd Font non trouvée"
    log_info "Installation de la police..."
    bash "$SCRIPT_DIR/config/install_nerd_fonts.sh" || {
        log_error "Échec de l'installation de la police"
        exit 1
    }
fi

log_info "Terminal détecté: ${TERMINAL:-inconnu}"

################################################################################
# Configuration selon le terminal
################################################################################

case "$TERMINAL" in
    kitty)
        log_section "Configuration pour Kitty"
        KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"
        mkdir -p "$(dirname "$KITTY_CONFIG")"
        
        if [ -f "$KITTY_CONFIG" ]; then
            if grep -q "font_family.*MesloLGS" "$KITTY_CONFIG"; then
                log_info "✓ Police déjà configurée dans kitty.conf"
            else
                # Ajouter la configuration de police
                echo "" >> "$KITTY_CONFIG"
                echo "# Nerd Font pour Powerlevel10k" >> "$KITTY_CONFIG"
                echo "font_family MesloLGS NF" >> "$KITTY_CONFIG"
                log_info "✓ Police ajoutée dans kitty.conf"
            fi
        else
            # Créer le fichier de configuration
            cat > "$KITTY_CONFIG" <<EOF
# Configuration Kitty
font_family MesloLGS NF
font_size 12
EOF
            log_info "✓ Fichier kitty.conf créé avec la police"
        fi
        log_info "📝 Redémarrez Kitty pour appliquer les changements"
        ;;
        
    alacritty)
        log_section "Configuration pour Alacritty"
        ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
        mkdir -p "$(dirname "$ALACRITTY_CONFIG")"
        
        if [ -f "$ALACRITTY_CONFIG" ]; then
            if grep -q "family.*MesloLGS" "$ALACRITTY_CONFIG"; then
                log_info "✓ Police déjà configurée dans alacritty.toml"
            else
                # Ajouter la configuration de police
                if grep -q "^\[font\]" "$ALACRITTY_CONFIG"; then
                    sed -i '/^\[font\]/a family = "MesloLGS NF"' "$ALACRITTY_CONFIG"
                else
                    echo "" >> "$ALACRITTY_CONFIG"
                    echo "[font]" >> "$ALACRITTY_CONFIG"
                    echo 'family = "MesloLGS NF"' >> "$ALACRITTY_CONFIG"
                fi
                log_info "✓ Police ajoutée dans alacritty.toml"
            fi
        else
            # Créer le fichier de configuration
            cat > "$ALACRITTY_CONFIG" <<EOF
[font]
family = "MesloLGS NF"
size = 12
EOF
            log_info "✓ Fichier alacritty.toml créé avec la police"
        fi
        log_info "📝 Redémarrez Alacritty pour appliquer les changements"
        ;;
        
    konsole)
        log_section "Configuration pour Konsole"
        log_info "Pour configurer Konsole:"
        echo "  1. Ouvrez Konsole"
        echo "  2. Allez dans Paramètres > Modifier le profil actuel"
        echo "  3. Onglet 'Apparence'"
        echo "  4. Sélectionnez 'MesloLGS NF' dans la liste des polices"
        echo "  5. Cliquez sur OK"
        ;;
        
    gnome-terminal|gnome-console|tilix)
        log_section "Configuration pour $TERMINAL"
        if [ "$TERMINAL" = "gnome-console" ]; then
            # GNOME Console utilise dconf
            log_info "Configuration via dconf pour GNOME Console..."
            if command -v dconf >/dev/null 2>&1; then
                dconf write /org/gnome/Console/font "'MesloLGS NF 12'" 2>/dev/null && {
                    log_info "✓ Police configurée via dconf"
                } || {
                    log_warn "⚠️  Impossible de configurer via dconf, configuration manuelle requise"
                }
            else
                log_warn "⚠️  dconf non trouvé, configuration manuelle requise"
            fi
        fi
        log_info "Pour configurer manuellement $TERMINAL:"
        echo "  1. Ouvrez les préférences du terminal"
        echo "  2. Allez dans l'onglet 'Apparence' ou 'Polices'"
        echo "  3. Sélectionnez 'MesloLGS NF' dans la liste des polices"
        echo "  4. Cliquez sur OK"
        ;;
        
    *)
        log_section "Configuration manuelle"
        log_info "Terminal non reconnu ou configuration manuelle requise"
        echo ""
        echo "Pour configurer la police MesloLGS NF:"
        echo "  1. Ouvrez les paramètres de votre terminal"
        echo "  2. Allez dans l'onglet 'Apparence' ou 'Polices'"
        echo "  3. Sélectionnez 'MesloLGS NF' ou 'MesloLGS Nerd Font'"
        echo "  4. Redémarrez votre terminal"
        echo ""
        echo "Polices disponibles:"
        fc-list | grep -i "meslo.*nerd" | head -3
        ;;
esac

################################################################################
# Vérification
################################################################################
log_section "Vérification"

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "🔍 Pour vérifier que la police est chargée:"
echo "   fc-list | grep -i meslo"
echo ""
echo "💡 Si les icônes ne s'affichent toujours pas après redémarrage:"
echo "   1. Vérifiez que la police est bien sélectionnée dans le terminal"
echo "   2. Redémarrez complètement le terminal (fermez toutes les fenêtres)"
echo "   3. Vérifiez que votre terminal supporte les polices Nerd Fonts"
echo ""

