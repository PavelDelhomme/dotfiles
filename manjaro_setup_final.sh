#!/bin/bash

################################################################################
# Manjaro Complete Setup Script
# Paul Delhomme - Installation complète avec vérifications préalables
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_skip()  { echo -e "${BLUE}[→]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# FONCTION DE VÉRIFICATION D'INSTALLATION
################################################################################
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

is_flatpak_installed() {
    flatpak list | grep -q "$1" 2>/dev/null
}

is_snap_installed() {
    snap list | grep -q "$1" 2>/dev/null
}

################################################################################
# SECTION 1: SYSTEM UPDATE & NODEJS CONFLICTS
################################################################################
log_section "1. Mise à jour système & résolution conflits Node.js"

# Supprimer les versions conflictuelles de Node.js
log_info "Vérification des conflits Node.js..."
conflicting_packages=("nodejs-lts-jod" "nodejs-lts-iron" "nodejs-lts-gallium" "nodejs-lts-hydrogen")
for pkg in "\${conflicting_packages[@]}"; do
    if is_package_installed "$pkg"; then
        log_warn "Suppression de $pkg..."
        sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

log_info "Mise à jour du système..."
sudo pacman -Syu --noconfirm

# Installer Node.js standard si pas déjà installé
if ! is_package_installed "nodejs"; then
    log_info "Installation de Node.js et npm..."
    sudo pacman -S --noconfirm nodejs npm
else
    log_skip "Node.js déjà installé"
fi

################################################################################
# SECTION 2: YAY, SNAP, FLATPAK
################################################################################
log_section "2. Gestionnaires de paquets: yay, snap, flatpak"

# Installation de yay
if ! is_installed "yay"; then
    log_info "Installation de yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    log_info "✓ yay installé"
else
    log_skip "yay déjà installé"
fi

# Installation de snapd
if ! is_package_installed "snapd"; then
    log_info "Installation de snapd..."
    sudo pacman -S --noconfirm snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
    log_info "✓ snapd installé"
else
    log_skip "snapd déjà installé"
    sudo systemctl start snapd.socket 2>/dev/null || true
fi

# Installation de flatpak
if ! is_package_installed "flatpak"; then
    log_info "Installation de flatpak..."
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    log_info "✓ flatpak installé"
else
    log_skip "flatpak déjà installé"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
fi

################################################################################
# SECTION 3: OUTILS DE BASE
################################################################################
log_section "3. Outils de développement de base"

base_tools=("xclip" "curl" "wget" "make" "cmake" "gcc" "git" "base-devel" "zsh")
for tool in "\${base_tools[@]}"; do
    if ! is_package_installed "$tool"; then
        log_info "Installation de $tool..."
        sudo pacman -S --noconfirm "$tool"
    else
        log_skip "$tool déjà installé"
    fi
done

################################################################################
# SECTION 4: GITHUB SSH (si pas déjà configuré)
################################################################################
log_section "4. Configuration GitHub SSH"

if [ ! -f ~/.ssh/id_ed25519 ]; then
    log_info "Configuration Git et génération de clé SSH..."

    read -p "Nom Git (défaut: Paul Delhomme): " git_username
    git_username=\${git_username:-"Paul Delhomme"}
    read -p "Email Git (défaut: paul@delhomme.ovh): " git_email
    git_email=\${git_email:-"paul@delhomme.ovh"}

    git config --global user.name "\$git_username"
    git config --global user.email "\$git_email"

    ssh-keygen -t ed25519 -C "\$git_email" -f ~/.ssh/id_ed25519 -N ""
    eval "\$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

    mkdir -p ~/.ssh
    cat > ~/.ssh/config <<EOF
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
EOF
    chmod 600 ~/.ssh/config

    xclip -sel clip < ~/.ssh/id_ed25519.pub

    log_warn "═══════════════════════════════════"
    log_warn "CLÉ SSH COPIÉE DANS LE PRESSE-PAPIER"
    log_warn "═══════════════════════════════════"
    log_warn "→ Ouvre: https://github.com/settings/keys"
    log_warn "→ Clique 'New SSH key'"
    log_warn "→ Colle la clé (Ctrl+V)"
    log_warn "═══════════════════════════════════"
    read -p "Appuie sur Entrée quand c'est fait..."

    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && log_info "✓ SSH OK" || log_warn "Vérifiez la clé SSH"
else
    log_skip "Clé SSH déjà existante"
fi

################################################################################
# SECTION 5: APPLICATIONS PRINCIPALES
################################################################################
log_section "5. Installation des applications principales"

# Applications Pacman
apps_pacman=("brave-browser" "discord" "keepassxc" "docker" "docker-compose")
for app in "\${apps_pacman[@]}"; do
    if ! is_package_installed "$app"; then
        log_info "Installation de $app..."
        sudo pacman -S --noconfirm "$app"
    else
        log_skip "$app déjà installé"
    fi
done

# Applications Flatpak
apps_flatpak=(
    "ch.protonmail.protonmail-bridge:Proton Mail Bridge"
    "me.proton.Pass:Proton Pass"
    "ru.linux_gaming.PortProton:PortProton"
    "me.bluemail.BlueMail:BlueMail"
)

for app_info in "\${apps_flatpak[@]}"; do
    IFS=':' read -r app_id app_name <<< "$app_info"
    if ! is_flatpak_installed "$app_id"; then
        log_info "Installation de $app_name via Flatpak..."
        flatpak install -y flathub "$app_id" 2>/dev/null || log_warn "$app_name non disponible"
    else
        log_skip "$app_name déjà installé"
    fi
done

# Applications Snap
if ! is_snap_installed "session-desktop"; then
    log_info "Installation de Session Desktop via Snap..."
    sudo snap install session-desktop 2>/dev/null || log_warn "Session Desktop non disponible"
else
    log_skip "Session Desktop déjà installé"
fi

################################################################################
# SECTION 6: CURSOR IDE
################################################################################
log_section "6. Installation Cursor IDE"

if [ ! -f /opt/cursor.appimage ]; then
    log_info "Téléchargement de Cursor AppImage..."

    mkdir -p ~/.local/share/icons
    mkdir -p ~/.local/share/applications
    mkdir -p ~/.local/bin

    # Télécharger l'AppImage
    CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
    sudo curl -L -o /opt/cursor.appimage "\$CURSOR_URL"
    sudo chmod +x /opt/cursor.appimage

    # Télécharger l'icône
    curl -L -o ~/.local/share/icons/cursor.png "https://www.cursor.com/favicon.png" 2>/dev/null || \
        curl -L -o ~/.local/share/icons/cursor.png "https://cursor.sh/favicon.ico" 2>/dev/null || true

    # Créer .desktop
    cat > ~/.local/share/applications/cursor.desktop <<EOF
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.appimage --no-sandbox %U
Icon=\$HOME/.local/share/icons/cursor.png
Type=Application
Categories=Development;IDE;TextEditor;
Comment=AI-powered code editor
Terminal=false
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;
EOF

    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

    # Créer script de mise à jour
    cat > ~/.local/bin/update-cursor.sh <<'UPDATESCRIPT'
#!/bin/bash
echo "Mise à jour de Cursor AppImage..."
CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
sudo curl -L -o /opt/cursor.appimage "$CURSOR_URL"
sudo chmod +x /opt/cursor.appimage
echo "✓ Cursor mis à jour"
UPDATESCRIPT

    chmod +x ~/.local/bin/update-cursor.sh
    log_info "✓ Cursor installé (update-cursor.sh disponible)"
else
    log_skip "Cursor déjà installé"
fi

################################################################################
# SECTION 7: DOCKER CONFIGURATION
################################################################################
log_section "7. Configuration Docker"

if is_package_installed "docker"; then
    sudo systemctl start docker.service 2>/dev/null || true
    sudo systemctl enable docker.service 2>/dev/null || true

    # Ajouter l'utilisateur au groupe docker si pas déjà membre
    if ! groups | grep -q docker; then
        log_info "Ajout de l'utilisateur au groupe docker..."
        sudo usermod -aG docker \$USER
        log_warn "Redémarrage requis pour groupe docker"
    else
        log_skip "Utilisateur déjà dans le groupe docker"
    fi

    # Optimisation BuildKit
    mkdir -p ~/.docker
    if [ ! -f ~/.docker/config.json ]; then
        cat > ~/.docker/config.json <<'DOCKERCONF'
{
  "experimental": "enabled",
  "features": {
    "buildkit": true
  }
}
DOCKERCONF
        log_info "✓ Docker BuildKit activé"
    else
        log_skip "Configuration Docker déjà présente"
    fi

    log_warn "→ Login Docker Hub: docker login"
fi

################################################################################
# SECTION 8: FLUTTER & ANDROID
################################################################################
log_section "8. Flutter SDK & Android Studio"

# Flutter
if ! is_installed "flutter"; then
    log_info "Installation de Flutter via yay..."
    yay -S --noconfirm flutter
else
    log_skip "Flutter déjà installé"
fi

# Android Studio
if ! is_installed "android-studio"; then
    log_info "Installation d'Android Studio & SDK..."
    yay -S --noconfirm android-studio android-sdk android-sdk-platform-tools android-sdk-build-tools
else
    log_skip "Android Studio déjà installé"
fi

# Java
if ! is_package_installed "jdk11-openjdk"; then
    log_info "Installation de Java 11..."
    sudo pacman -S --noconfirm jdk11-openjdk
else
    log_skip "Java 11 déjà installé"
fi

# Permissions Flutter
sudo groupadd flutterusers 2>/dev/null || true
sudo gpasswd -a \$USER flutterusers 2>/dev/null || true
sudo chown -R :flutterusers /opt/flutter 2>/dev/null || true
sudo chmod -R g+w /opt/flutter/ 2>/dev/null || true

log_warn "═══════════════════════════════════"
log_warn "Variables PATH Flutter/Android"
log_warn "═══════════════════════════════════"
log_warn "Assurez-vous que ~/dotfiles/.env contient:"
log_warn "  export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'"
log_warn "  export ANDROID_SDK_ROOT='/opt/android-sdk'"
log_warn "  export PATH (voir setup.sh créé par dotfiles)"
log_warn "═══════════════════════════════════"

################################################################################
# SECTION 9: NVIDIA RTX 3060
################################################################################
log_section "9. NVIDIA RTX 3060 - Détection & Installation"

if lspci | grep -i nvidia >/dev/null 2>&1; then
    log_info "Carte NVIDIA détectée"

    if ! is_installed "nvidia-smi"; then
        log_info "Installation des pilotes NVIDIA..."
        sudo mhwd -a pci nonfree 0300
        sudo pacman -S --noconfirm nvidia-prime nvidia-settings

        # Configuration Xorg
        sudo mkdir -p /etc/X11/xorg.conf.d/
        sudo tee /etc/X11/xorg.conf.d/10-nvidia.conf >/dev/null <<'NVIDIACONF'
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
NVIDIACONF

        echo "nvidia-settings --load-config-only" >> ~/.xinitrc

        # GRUB fix
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset"/' /etc/default/grub
        sudo update-grub

        log_info "✓ Pilotes NVIDIA installés"
        log_warn "→ Branchez écran sur carte NVIDIA"
        log_warn "→ BIOS: Primary Display = PCI-E"
    else
        log_skip "Pilotes NVIDIA déjà installés"
    fi
else
    log_warn "Aucune carte NVIDIA détectée"
fi

################################################################################
# SECTION 10: VÉRIFICATIONS FINALES
################################################################################
log_section "10. Vérifications post-installation"

echo ""
log_info "[1] SSH GitHub..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && echo "  ✓ OK" || echo "  ✗ Échec"

log_info "[2] Docker..."
docker --version >/dev/null 2>&1 && echo "  ✓ \$(docker --version)" || echo "  ✗ Non trouvé"

log_info "[3] Flutter..."
flutter --version >/dev/null 2>&1 && echo "  ✓ OK" || echo "  ✗ Non trouvé"

log_info "[4] Android Studio..."
command -v android-studio >/dev/null 2>&1 && echo "  ✓ OK" || echo "  ✗ Non trouvé"

log_info "[5] NVIDIA..."
nvidia-smi >/dev/null 2>&1 && echo "  ✓ \$(nvidia-smi --query-gpu=name --format=csv,noheader)" || echo "  ⚠ Pas actif"

log_info "[6] Cursor..."
test -f /opt/cursor.appimage && echo "  ✓ Présent" || echo "  ✗ Manquant"

log_info "[7] Dotfiles..."
test -d ~/dotfiles && echo "  ✓ Présent" || echo "  ✗ Manquant"

################################################################################
# RÉSUMÉ FINAL
################################################################################
log_section "Installation terminée!"

echo ""
log_info "✓ Système à jour"
log_info "✓ Gestionnaires de paquets installés"
log_info "✓ Applications installées"
log_info "✓ Docker configuré"
log_info "✓ Flutter & Android Studio installés"
log_info "✓ NVIDIA configuré (si détecté)"
echo ""

log_warn "═══════════════════════════════════"
log_warn "ACTIONS APRÈS REBOOT"
log_warn "═══════════════════════════════════"
echo "  1. flutter doctor"
echo "  2. docker login"
echo "  3. Lancer Android Studio (config SDK)"
echo "  4. Lancer Cursor et se connecter"
echo "  5. nvidia-smi (si NVIDIA)"
echo "  6. Configurer BlueMail"
echo "  7. Se connecter à Proton Pass"
echo ""

read -p "Redémarrer maintenant? (o/n): " reboot_choice
if [[ "\$reboot_choice" =~ ^[oO]\$ ]]; then
    log_info "Redémarrage..."
    sudo reboot
else
    log_warn "N'oubliez pas de redémarrer: sudo reboot"
fi
