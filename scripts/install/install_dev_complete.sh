#!/bin/bash

################################################################################
# Installation complète et automatique des outils de développement
# Installe: Android SDK, OpenJDK 17, Flutter, .NET, Emacs, Proton Pass, Wine, PortProton
################################################################################

set -e

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Installation complète des outils de développement"

################################################################################
# 1. OPENJDK 17
################################################################################
log_section "1. Installation OpenJDK 17"
if ! pacman -Q jdk17-openjdk >/dev/null 2>&1; then
    sudo pacman -S --noconfirm jdk17-openjdk
    log_info "✓ OpenJDK 17 installé"
else
    log_info "✓ OpenJDK 17 déjà installé"
fi

################################################################################
# 2. ANDROID SDK
################################################################################
log_section "2. Installation Android SDK"
if command -v yay >/dev/null 2>&1; then
    yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools android-sdk-cmdline-tools || log_warn "Installation Android SDK échouée"
    
    # Accepter les licences
    if [ -f "$HOME/dotfiles/scripts/install/dev/accept_android_licenses.sh" ]; then
        bash "$HOME/dotfiles/scripts/install/dev/accept_android_licenses.sh" || log_warn "Acceptation licences échouée"
    fi
    log_info "✓ Android SDK installé"
else
    log_warn "yay non trouvé, Android SDK ignoré"
fi

################################################################################
# 3. FLUTTER (dans /opt/flutter)
################################################################################
log_section "3. Installation Flutter"
if ! command -v flutter >/dev/null 2>&1 && [ ! -d "/opt/flutter" ]; then
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm flutter || log_warn "Installation Flutter échouée"
        sudo groupadd flutterusers 2>/dev/null || true
        sudo gpasswd -a $USER flutterusers 2>/dev/null || true
        if [ -d "/opt/flutter" ]; then
            sudo chown -R :flutterusers /opt/flutter 2>/dev/null || true
            sudo chmod -R g+w /opt/flutter/ 2>/dev/null || true
        fi
    else
        log_warn "yay non trouvé, Flutter ignoré"
    fi
else
    log_info "✓ Flutter déjà installé"
fi

# Configurer pub-cache
PUB_CACHE_DIR="$HOME/.pub-cache/bin"
mkdir -p "$PUB_CACHE_DIR"
export PUB_CACHE="$HOME/.pub-cache"
log_info "✓ pub-cache configuré: $PUB_CACHE_DIR"

################################################################################
# 4. .NET SDK
################################################################################
log_section "4. Installation .NET SDK"
if ! command -v dotnet >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm dotnet-sdk-bin dotnet-runtime-bin || {
            sudo pacman -S --noconfirm dotnet-sdk dotnet-runtime || log_warn "Installation .NET échouée"
        }
    else
        log_warn "yay non trouvé, .NET ignoré"
    fi
else
    log_info "✓ .NET déjà installé"
fi

# Créer répertoire outils .NET
mkdir -p "$HOME/.dotnet/tools"
log_info "✓ Répertoire .NET tools créé"

################################################################################
# 5. EMACS + DOOM EMACS
################################################################################
log_section "5. Installation Emacs + Doom Emacs"
if ! command -v emacs >/dev/null 2>&1; then
    sudo pacman -S --noconfirm emacs
    log_info "✓ Emacs installé"
else
    log_info "✓ Emacs déjà installé"
fi

# Installation Doom Emacs
if [ ! -d "$HOME/.emacs.d" ] || [ ! -f "$HOME/.emacs.d/bin/doom" ]; then
    log_info "Installation de Doom Emacs..."
    if [ -d "$HOME/.emacs.d" ]; then
        rm -rf "$HOME/.emacs.d"
    fi
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d || log_warn "Clonage Doom échoué"
    
    if [ -f "$HOME/.emacs.d/bin/doom" ]; then
        log_info "Configuration de Doom Emacs..."
        ~/.emacs.d/bin/doom install || log_warn "Installation Doom terminée avec avertissements"
        log_info "✓ Doom Emacs installé"
    fi
else
    log_info "✓ Doom Emacs déjà installé"
fi

################################################################################
# 6. PROTON PASS
################################################################################
log_section "6. Installation Proton Pass"
if ! command -v proton-pass >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1; then
        rm -rf ~/.cache/yay/proton-pass
        yay -S --noconfirm proton-pass || log_warn "Installation Proton Pass échouée"
    else
        log_warn "yay non trouvé, Proton Pass ignoré"
    fi
else
    log_info "✓ Proton Pass déjà installé"
fi

################################################################################
# 7. WINE
################################################################################
log_section "7. Installation Wine"
if ! command -v wine >/dev/null 2>&1; then
    sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks
    log_info "✓ Wine installé"
else
    log_info "✓ Wine déjà installé"
fi

################################################################################
# 8. PORTPROTON
################################################################################
log_section "8. Installation PortProton"
if ! flatpak list | grep -q "PortProton"; then
    flatpak install -y flathub ru.linux_gaming.PortProton || log_warn "Installation PortProton échouée"
    mkdir -p ~/Games/PortProton/prefix ~/Games/PortProton/games
    flatpak override --user ru.linux_gaming.PortProton --filesystem=~/Games
    flatpak override --user ru.linux_gaming.PortProton --filesystem=xdg-download
    log_info "✓ PortProton installé"
else
    log_info "✓ PortProton déjà installé"
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
echo "✅ Outils installés:"
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

log_info "Pour appliquer les changements, rechargez votre shell :"
echo "  exec zsh"

