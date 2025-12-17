#!/bin/bash

################################################################################
# Installation complète de l'environnement de développement
# Installe: Android SDK, OpenJDK 17, Flutter, emacs.d, dotnet, pub cache,
#           proton-pass, wine, portproton
################################################################################

set -e

# Mode non-interactif par défaut
export NON_INTERACTIVE=1

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation complète de l'environnement de développement"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

################################################################################
# 1. OPENJDK 17
################################################################################
log_section "1. Installation OpenJDK 17"

if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -n1)
    log_info "Java déjà installé: $JAVA_VERSION"
    if ! java -version 2>&1 | grep -q "17"; then
        log_info "Installation OpenJDK 17..."
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm jdk17-openjdk
        elif command -v apt >/dev/null 2>&1; then
            sudo apt install -y openjdk-17-jdk
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y java-17-openjdk-devel
        fi
    fi
else
    log_info "Installation OpenJDK 17..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm jdk17-openjdk
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -y openjdk-17-jdk
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y java-17-openjdk-devel
    fi
fi

# Configurer JAVA_HOME
if command -v pacman >/dev/null 2>&1; then
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
elif [ -d /usr/lib/jvm/java-17-openjdk ]; then
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
elif [ -d /usr/lib/jvm/java-17 ]; then
    export JAVA_HOME=/usr/lib/jvm/java-17
fi

log_info "✓ OpenJDK 17 installé (JAVA_HOME=$JAVA_HOME)"

################################################################################
# 2. ANDROID SDK
################################################################################
log_section "2. Installation Android SDK"

if [ -f "$SCRIPT_DIR/../installman/modules/android/install_android_tools.sh" ]; then
    bash "$SCRIPT_DIR/../installman/modules/android/install_android_tools.sh" || {
        log_warn "Installation Android SDK via installman échouée, tentative manuelle..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools android-tools
        fi
    }
else
    log_info "Installation Android SDK..."
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools android-tools
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm android-tools
    fi
fi

# Configurer ANDROID_HOME et PATH
ANDROID_SDK="/opt/android-sdk"
if [ -d "$ANDROID_SDK" ]; then
    export ANDROID_HOME="$ANDROID_SDK"
    export ANDROID_SDK_ROOT="$ANDROID_SDK"
    export PATH="$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin"
    log_info "✓ Android SDK configuré (ANDROID_HOME=$ANDROID_HOME)"
fi

################################################################################
# 3. FLUTTER dans /opt/flutter
################################################################################
log_section "3. Installation Flutter dans /opt/flutter"

if [ -f "$SCRIPT_DIR/dev/install_flutter.sh" ]; then
    bash "$SCRIPT_DIR/dev/install_flutter.sh"
else
    log_info "Installation Flutter..."
    FLUTTER_DIR="/opt/flutter"
    
    if [ ! -d "$FLUTTER_DIR" ]; then
        log_info "Téléchargement de Flutter..."
        cd /tmp
        FLUTTER_VERSION="3.24.5"
        wget -q --show-progress "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -O flutter.tar.xz
        
        log_info "Extraction de Flutter vers $FLUTTER_DIR..."
        sudo mkdir -p "$FLUTTER_DIR"
        sudo tar -xf flutter.tar.xz -C /opt/
        sudo chown -R $USER:$USER "$FLUTTER_DIR"
        rm flutter.tar.xz
        
        log_info "✓ Flutter installé dans $FLUTTER_DIR"
    else
        log_info "✓ Flutter déjà installé dans $FLUTTER_DIR"
    fi
    
    # Ajouter Flutter au PATH
    export PATH="$PATH:$FLUTTER_DIR/bin"
    
    # Configurer pub cache
    export PUB_CACHE="$HOME/.pub-cache"
    mkdir -p "$PUB_CACHE/bin"
    export PATH="$PATH:$PUB_CACHE/bin"
    log_info "✓ Pub cache configuré: $PUB_CACHE"
    
    # Exécuter flutter doctor
    if [ -f "$FLUTTER_DIR/bin/flutter" ]; then
        log_info "Exécution de flutter doctor..."
        "$FLUTTER_DIR/bin/flutter" doctor || true
    fi
fi

################################################################################
# 4. EMACS.D
################################################################################
log_section "4. Installation emacs.d"

EMACS_DIR="$HOME/.emacs.d"
if [ ! -d "$EMACS_DIR" ]; then
    log_info "Création de .emacs.d..."
    mkdir -p "$EMACS_DIR"
    
    # Créer un init.el basique
    cat > "$EMACS_DIR/init.el" <<'EOF'
;; Configuration Emacs de base
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Auto-install use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Thème
(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;; Interface
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Numéros de ligne
(global-display-line-numbers-mode t)

;; Sauvegarde automatique
(auto-save-mode t)
EOF
    
    log_info "✓ .emacs.d créé avec configuration de base"
else
    log_info "✓ .emacs.d existe déjà"
fi

################################################################################
# 5. DOTNET
################################################################################
log_section "5. Installation .NET"

if [ -f "$SCRIPT_DIR/dev/install_dotnet.sh" ]; then
    bash "$SCRIPT_DIR/dev/install_dotnet.sh"
else
    log_info "Installation .NET..."
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm dotnet-sdk-bin dotnet-runtime-bin || {
            sudo pacman -S --noconfirm dotnet-sdk dotnet-runtime
        }
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm dotnet-sdk dotnet-runtime
    fi
    
    # Configurer DOTNET_ROOT
    if command -v dotnet >/dev/null 2>&1; then
        export DOTNET_ROOT=$(dirname $(which dotnet))
        export PATH="$PATH:$HOME/.dotnet/tools"
        mkdir -p "$HOME/.dotnet/tools"
        log_info "✓ .NET installé"
    fi
fi

################################################################################
# 6. PROTON-PASS
################################################################################
log_section "6. Installation Proton Pass"

if [ -f "$SCRIPT_DIR/../config/fix_proton_pass_install.sh" ]; then
    bash "$SCRIPT_DIR/../config/fix_proton_pass_install.sh"
else
    log_info "Installation Proton Pass..."
    if command -v yay >/dev/null 2>&1; then
        # Nettoyer le cache
        rm -rf ~/.cache/yay/proton-pass
        yay -S --noconfirm proton-pass || {
            log_warn "Installation Proton Pass échouée, réessayez manuellement"
        }
    else
        log_warn "yay requis pour installer Proton Pass"
    fi
fi

################################################################################
# 7. WINE
################################################################################
log_section "7. Installation Wine"

if command -v wine >/dev/null 2>&1; then
    log_info "✓ Wine déjà installé"
else
    log_info "Installation Wine..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm wine-staging wine-mono wine-gecko
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -y wine-staging
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y wine
    fi
    
    # Initialiser Wine
    log_info "Initialisation de Wine..."
    winecfg 2>/dev/null || true
    log_info "✓ Wine installé"
fi

################################################################################
# 8. PORTPROTON
################################################################################
log_section "8. Installation PortProton"

if [ -f "$SCRIPT_DIR/apps/install_portproton.sh" ]; then
    bash "$SCRIPT_DIR/apps/install_portproton.sh"
else
    log_info "Installation PortProton..."
    if command -v flatpak >/dev/null 2>&1; then
        flatpak install -y flathub ru.linux_gaming.PortProton || {
            log_warn "Installation PortProton échouée"
        }
        
        # Configurer les permissions
        flatpak override --user ru.linux_gaming.PortProton --filesystem=~/Games 2>/dev/null || true
        flatpak override --user ru.linux_gaming.PortProton --filesystem=xdg-download 2>/dev/null || true
        
        log_info "✓ PortProton installé"
    else
        log_warn "flatpak requis pour installer PortProton"
    fi
fi

################################################################################
# 9. MISE À JOUR ENV.SH
################################################################################
log_section "9. Mise à jour env.sh"

ENV_FILE="$DOTFILES_DIR/zsh/env.sh"
if [ -f "$ENV_FILE" ]; then
    log_info "Mise à jour de env.sh avec les nouvelles variables..."
    
    # Ajouter JAVA_HOME si pas présent
    if ! grep -q "JAVA_HOME" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# Java" >> "$ENV_FILE"
        echo "export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk}" >> "$ENV_FILE"
        echo "export PATH=\"\$PATH:\$JAVA_HOME/bin\"" >> "$ENV_FILE"
    fi
    
    # Ajouter ANDROID_HOME si pas présent
    if ! grep -q "ANDROID_HOME" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# Android SDK" >> "$ENV_FILE"
        echo "export ANDROID_HOME=\${ANDROID_HOME:-/opt/android-sdk}" >> "$ENV_FILE"
        echo "export ANDROID_SDK_ROOT=\$ANDROID_HOME" >> "$ENV_FILE"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin\"" >> "$ENV_FILE"
    fi
    
    # Ajouter Flutter si pas présent
    if ! grep -q "/opt/flutter/bin" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# Flutter" >> "$ENV_FILE"
        echo "export PATH=\"\$PATH:/opt/flutter/bin\"" >> "$ENV_FILE"
        echo "export PUB_CACHE=\"\$HOME/.pub-cache\"" >> "$ENV_FILE"
        echo "export PATH=\"\$PATH:\$PUB_CACHE/bin\"" >> "$ENV_FILE"
    fi
    
    # Ajouter .NET si pas présent
    if ! grep -q "DOTNET_ROOT" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# .NET" >> "$ENV_FILE"
        echo "export PATH=\"\$PATH:\$HOME/.dotnet/tools\"" >> "$ENV_FILE"
    fi
    
    log_info "✓ env.sh mis à jour"
else
    log_warn "env.sh non trouvé, création..."
    mkdir -p "$(dirname "$ENV_FILE")"
    cat > "$ENV_FILE" <<EOF
# Variables d'environnement
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk}
export PATH="\$PATH:\$JAVA_HOME/bin"

export ANDROID_HOME=\${ANDROID_HOME:-/opt/android-sdk}
export ANDROID_SDK_ROOT=\$ANDROID_HOME
export PATH="\$PATH:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin"

export PATH="\$PATH:/opt/flutter/bin"
export PUB_CACHE="\$HOME/.pub-cache"
export PATH="\$PATH:\$PUB_CACHE/bin"

export PATH="\$PATH:\$HOME/.dotnet/tools"
EOF
    log_info "✓ env.sh créé"
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
echo "✅ Outils installés:"
echo "  ✓ OpenJDK 17"
echo "  ✓ Android SDK"
echo "  ✓ Flutter (dans /opt/flutter)"
echo "  ✓ emacs.d"
echo "  ✓ .NET"
echo "  ✓ Pub cache"
echo "  ✓ Proton Pass"
echo "  ✓ Wine"
echo "  ✓ PortProton"
echo ""
echo "📝 Pour appliquer les changements, rechargez votre shell:"
echo "  exec zsh"
echo ""
echo "🔍 Vérifications:"
echo "  java -version"
echo "  adb version"
echo "  flutter --version"
echo "  dotnet --version"
echo ""

