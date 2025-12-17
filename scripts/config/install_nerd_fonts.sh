#!/bin/bash

################################################################################
# Installation de Nerd Fonts pour le support des emojis et icônes dans le terminal
# Installe une police Nerd Font (MesloLGS NF recommandée pour Powerlevel10k)
# Usage: bash ~/dotfiles/scripts/config/install_nerd_fonts.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation de Nerd Fonts"

FONTS_DIR="$HOME/.local/share/fonts"
NERD_FONTS_DIR="$FONTS_DIR/NerdFonts"

# Créer le répertoire des polices si nécessaire
mkdir -p "$NERD_FONTS_DIR"

################################################################################
# ÉTAPE 1: Installation via AUR (Arch Linux)
################################################################################
log_section "1. Installation via AUR"

# Essayer d'installer via AUR d'abord
if command -v yay >/dev/null 2>&1; then
    log_info "Recherche de polices Nerd Fonts via AUR..."
    
    # Essayer plusieurs noms de paquets possibles
    if yay -Qi ttf-meslo-nerd >/dev/null 2>&1 || yay -Qi nerd-fonts-meslo >/dev/null 2>&1; then
        log_info "✓ Police Nerd Font déjà installée via AUR"
    else
        # Essayer d'installer
        if yay -S --noconfirm ttf-meslo-nerd 2>/dev/null || yay -S --noconfirm nerd-fonts-meslo 2>/dev/null; then
            log_info "✓ Police Nerd Font installée via AUR"
        else
            log_info "Aucun paquet AUR trouvé, installation manuelle..."
            install_nerd_fonts_manual
        fi
    fi
else
    log_info "Installation manuelle (yay non disponible)..."
    install_nerd_fonts_manual
fi

################################################################################
# ÉTAPE 2: Installation manuelle (fallback)
################################################################################
install_nerd_fonts_manual() {
    log_section "Installation manuelle de Nerd Fonts"
    
    log_info "Téléchargement de MesloLGS NF..."
    
    # Télécharger MesloLGS NF (recommandée pour Powerlevel10k)
    MESLO_VERSIONS=("Regular" "Bold" "Italic" "Bold Italic")
    
    for version in "${MESLO_VERSIONS[@]}"; do
        filename="MesloLGS NF ${version}.ttf"
        url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${version}.ttf"
        
        if [ ! -f "$NERD_FONTS_DIR/$filename" ]; then
            log_info "Téléchargement de $filename..."
            curl -L -o "$NERD_FONTS_DIR/$filename" "$url" || {
                log_warn "⚠️  Échec du téléchargement de $filename"
                continue
            }
            log_info "✓ $filename téléchargé"
        else
            log_info "✓ $filename déjà présent"
        fi
    done
    
    # Télécharger aussi d'autres polices populaires si souhaité
    log_info "Téléchargement de FiraCode Nerd Font..."
    FIRACODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz"
    if [ ! -d "$NERD_FONTS_DIR/FiraCode" ]; then
        TEMP_DIR=$(mktemp -d)
        curl -L -o "$TEMP_DIR/FiraCode.tar.xz" "$FIRACODE_URL" || {
            log_warn "⚠️  Échec du téléchargement de FiraCode"
        }
        if [ -f "$TEMP_DIR/FiraCode.tar.xz" ]; then
            tar -xf "$TEMP_DIR/FiraCode.tar.xz" -C "$NERD_FONTS_DIR" 2>/dev/null || true
            rm -rf "$TEMP_DIR"
            log_info "✓ FiraCode Nerd Font téléchargé"
        fi
    else
        log_info "✓ FiraCode Nerd Font déjà présent"
    fi
}

################################################################################
# ÉTAPE 3: Actualiser le cache des polices
################################################################################
log_section "3. Actualisation du cache des polices"

if command -v fc-cache >/dev/null 2>&1; then
    log_info "Actualisation du cache des polices..."
    fc-cache -fv "$NERD_FONTS_DIR" 2>/dev/null || true
    fc-cache -fv "$FONTS_DIR" 2>/dev/null || true
    log_info "✓ Cache des polices actualisé"
else
    log_warn "⚠️  fc-cache non trouvé, le cache ne sera pas actualisé"
fi

################################################################################
# ÉTAPE 4: Vérification et affichage des polices disponibles
################################################################################
log_section "4. Vérification des polices"

if command -v fc-list >/dev/null 2>&1; then
    log_info "Polices Nerd Fonts disponibles:"
    fc-list | grep -i "meslo\|nerd" | head -5 || log_warn "⚠️  Aucune police Nerd Font trouvée"
else
    log_warn "⚠️  fc-list non trouvé, impossible de vérifier"
fi

################################################################################
# ÉTAPE 5: Instructions de configuration
################################################################################
log_section "5. Configuration du terminal"

echo ""
echo "✅ Installation terminée!"
echo ""
echo "📝 Pour utiliser les polices Nerd Fonts dans votre terminal:"
echo ""
echo "1. Ouvrez les paramètres de votre terminal"
echo "2. Allez dans l'onglet 'Apparence' ou 'Polices'"
echo "3. Sélectionnez une police Nerd Font, par exemple:"
echo "   - MesloLGS NF (recommandée pour Powerlevel10k)"
echo "   - FiraCode Nerd Font"
echo "   - Hack Nerd Font"
echo "   - JetBrainsMono Nerd Font"
echo ""
echo "4. Redémarrez votre terminal"
echo ""
echo "🔍 Pour vérifier que la police est chargée:"
echo "   fc-list | grep -i meslo"
echo ""
echo "💡 Si les icônes ne s'affichent toujours pas:"
echo "   1. Vérifiez que la police est bien sélectionnée dans le terminal"
echo "   2. Redémarrez complètement le terminal (pas juste un nouveau shell)"
echo "   3. Vérifiez que votre terminal supporte les polices Nerd Fonts"
echo ""

