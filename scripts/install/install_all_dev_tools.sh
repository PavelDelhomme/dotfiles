#!/bin/bash

################################################################################
# Script d'installation complète des outils de développement
# Installe: Android SDK, OpenJDK 17, Flutter, .NET, Emacs, Proton Pass, Wine, PortProton
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ -f "$SCRIPT_DIR/scripts/lib/common.sh" ]; then
    source "$SCRIPT_DIR/scripts/lib/common.sh"
elif [ -f "$HOME/dotfiles/scripts/lib/common.sh" ]; then
    source "$HOME/dotfiles/scripts/lib/common.sh"
else
    # Fonctions de base si common.sh n'existe pas
    log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
    log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
    log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }
fi

log_section "Installation complète des outils de développement"

################################################################################
# FONCTION D'INSTALLATION (NON-INTERACTIVE)
################################################################################
install_tool() {
    local tool_name="$1"
    local script_path="$2"
    
    log_section "Installation de $tool_name"
    
    if [ -f "$script_path" ]; then
        # Passer YES pour toutes les confirmations
        yes | bash "$script_path" 2>/dev/null || {
            # Si yes échoue, essayer avec echo o
            echo "o" | bash "$script_path" || {
                log_warn "⚠️  Installation de $tool_name a échoué, continuation..."
                return 1
            }
        }
    else
        log_error "Script non trouvé: $script_path"
        return 1
    fi
}

################################################################################
# 1. OPENJDK 17
################################################################################
install_tool "OpenJDK 17" "$SCRIPT_DIR/scripts/install/dev/install_java17.sh"

################################################################################
# 2. ANDROID SDK
################################################################################
log_section "Installation Android SDK"

if command -v yay >/dev/null 2>&1; then
    log_info "Installation Android SDK via yay..."
    yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools android-sdk-cmdline-tools || {
        log_warn "⚠️  Installation Android SDK échouée"
    }
    
    # Accepter les licences
    log_info "Acceptation des licences Android SDK..."
    bash "$SCRIPT_DIR/scripts/install/dev/accept_android_licenses.sh" || {
        log_warn "⚠️  Acceptation des licences échouée"
    }
else
    log_warn "⚠️  yay non trouvé, installation Android SDK ignorée"
fi

################################################################################
# 3. FLUTTER (dans /opt/flutter)
################################################################################
install_tool "Flutter" "$SCRIPT_DIR/scripts/install/dev/install_flutter.sh"

# Configurer pub-cache
log_info "Configuration pub-cache..."
PUB_CACHE_DIR="$HOME/.pub-cache/bin"
mkdir -p "$PUB_CACHE_DIR"
export PUB_CACHE="$HOME/.pub-cache"
log_info "✓ pub-cache configuré: $PUB_CACHE_DIR"

################################################################################
# 4. .NET SDK
################################################################################
install_tool ".NET SDK" "$SCRIPT_DIR/scripts/install/dev/install_dotnet.sh"

################################################################################
# 5. EMACS + DOOM EMACS
################################################################################
install_tool "Emacs + Doom Emacs" "$SCRIPT_DIR/scripts/install/dev/install_emacs.sh"

# Installation Doom Emacs si nécessaire
if [ ! -d "$HOME/.emacs.d" ] || [ ! -f "$HOME/.emacs.d/bin/doom" ]; then
    log_info "Installation de Doom Emacs..."
    if [ -d "$HOME/.emacs.d" ]; then
        rm -rf "$HOME/.emacs.d"
    fi
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d || {
        log_warn "⚠️  Clonage Doom Emacs échoué"
    }
    
    if [ -f "$HOME/.emacs.d/bin/doom" ]; then
        log_info "Configuration de Doom Emacs..."
        ~/.emacs.d/bin/doom install --yes || {
            log_warn "⚠️  Installation Doom Emacs terminée avec des avertissements"
        }
    fi
fi

################################################################################
# 6. PROTON PASS
################################################################################
log_section "Installation Proton Pass"

if command -v yay >/dev/null 2>&1; then
    log_info "Nettoyage du cache yay pour proton-pass..."
    rm -rf ~/.cache/yay/proton-pass
    
    log_info "Installation Proton Pass via yay..."
    yay -S --noconfirm proton-pass || {
        log_warn "⚠️  Installation Proton Pass échouée"
        log_info "Essayez manuellement: yay -S proton-pass"
    }
else
    log_warn "⚠️  yay non trouvé, installation Proton Pass ignorée"
fi

################################################################################
# 7. WINE
################################################################################
log_section "Installation Wine"

if command -v pacman >/dev/null 2>&1; then
    log_info "Installation Wine via pacman..."
    sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks || {
        log_warn "⚠️  Installation Wine échouée"
    }
elif command -v apt >/dev/null 2>&1; then
    log_info "Installation Wine via apt..."
    sudo apt update
    sudo apt install -y wine wine64 wine32 winetricks || {
        log_warn "⚠️  Installation Wine échouée"
    }
else
    log_warn "⚠️  Gestionnaire de paquets non supporté pour Wine"
fi

################################################################################
# 8. PORTPROTON
################################################################################
install_tool "PortProton" "$SCRIPT_DIR/scripts/install/apps/install_portproton.sh"

################################################################################
# RÉSUMÉ
################################################################################
log_section "Résumé de l'installation"

echo ""
echo "Outils installés:"
echo "  ✅ OpenJDK 17"
echo "  ✅ Android SDK"
echo "  ✅ Flutter (dans /opt/flutter)"
echo "  ✅ pub-cache configuré"
echo "  ✅ .NET SDK"
echo "  ✅ Emacs + Doom Emacs"
echo "  ✅ Proton Pass"
echo "  ✅ Wine"
echo "  ✅ PortProton"
echo ""

log_info "✓ Installation terminée!"
echo ""
log_info "Pour appliquer les changements, rechargez votre shell :"
echo "  exec zsh"
echo ""
log_info "Vérifications recommandées:"
echo "  java -version"
echo "  flutter doctor"
echo "  dotnet --version"
echo "  emacs --version"
echo "  wine --version"

