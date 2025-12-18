#!/bin/bash

################################################################################
# Installation des dépendances pour le gaming avec PortProton
# Installe Vulkan, drivers vidéo, et autres dépendances nécessaires
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation dépendances gaming"

# Détecter la carte graphique
GPU_VENDOR=""
if lspci | grep -qi nvidia; then
    GPU_VENDOR="nvidia"
    log_info "Carte graphique NVIDIA détectée"
elif lspci | grep -qi intel; then
    GPU_VENDOR="intel"
    log_info "Carte graphique Intel détectée"
elif lspci | grep -qi amd; then
    GPU_VENDOR="amd"
    log_info "Carte graphique AMD détectée"
else
    log_warn "Carte graphique non détectée"
fi

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    DISTRO="unknown"
    log_error "Distribution non supportée"
    exit 1
fi

log_info "Distribution détectée: $DISTRO"

# Installer selon la distribution
case "$DISTRO" in
    arch)
        log_info "Installation des dépendances (Arch Linux)..."
        
        # Vulkan loader (toujours nécessaire)
        if ! pacman -Qi vulkan-icd-loader >/dev/null 2>&1; then
            log_info "Installation de vulkan-icd-loader..."
            sudo pacman -S --noconfirm vulkan-icd-loader
            log_info "✓ vulkan-icd-loader installé"
        else
            log_info "✓ vulkan-icd-loader déjà installé"
        fi
        
        # Drivers Vulkan selon la carte graphique
        if [ "$GPU_VENDOR" = "nvidia" ]; then
            if ! pacman -Qi vulkan-nvidia >/dev/null 2>&1; then
                log_info "Installation de vulkan-nvidia (NVIDIA)..."
                sudo pacman -S --noconfirm vulkan-nvidia
                log_info "✓ vulkan-nvidia installé"
            else
                log_info "✓ vulkan-nvidia déjà installé"
            fi
        elif [ "$GPU_VENDOR" = "intel" ]; then
            if ! pacman -Qi vulkan-intel >/dev/null 2>&1; then
                log_info "Installation de vulkan-intel (Intel)..."
                sudo pacman -S --noconfirm vulkan-intel
                log_info "✓ vulkan-intel installé"
            else
                log_info "✓ vulkan-intel déjà installé"
            fi
        elif [ "$GPU_VENDOR" = "amd" ]; then
            if ! pacman -Qi vulkan-radeon >/dev/null 2>&1; then
                log_info "Installation de vulkan-radeon (AMD)..."
                sudo pacman -S --noconfirm vulkan-radeon
                log_info "✓ vulkan-radeon installé"
            else
                log_info "✓ vulkan-radeon déjà installé"
            fi
        fi
        
        # Gamescope
        if ! pacman -Qi gamescope >/dev/null 2>&1; then
            log_info "Installation de gamescope..."
            sudo pacman -S --noconfirm gamescope
            log_info "✓ gamescope installé"
        else
            log_info "✓ gamescope déjà installé"
        fi
        
        # Lib32 pour compatibilité 32-bit
        if ! pacman -Qi lib32-vulkan-icd-loader >/dev/null 2>&1; then
            log_info "Installation de lib32-vulkan-icd-loader..."
            sudo pacman -S --noconfirm lib32-vulkan-icd-loader
            log_info "✓ lib32-vulkan-icd-loader installé"
        else
            log_info "✓ lib32-vulkan-icd-loader déjà installé"
        fi
        
        if [ "$GPU_VENDOR" = "nvidia" ]; then
            if ! pacman -Qi lib32-vulkan-nvidia >/dev/null 2>&1; then
                log_info "Installation de lib32-vulkan-nvidia..."
                sudo pacman -S --noconfirm lib32-vulkan-nvidia
                log_info "✓ lib32-vulkan-nvidia installé"
            else
                log_info "✓ lib32-vulkan-nvidia déjà installé"
            fi
        fi
        
        # PulseAudio/PipeWire (audio)
        if ! pacman -Qi pipewire pipewire-pulse >/dev/null 2>&1 && ! pacman -Qi pulseaudio >/dev/null 2>&1; then
            log_info "Installation de PipeWire (audio)..."
            sudo pacman -S --noconfirm pipewire pipewire-pulse pipewire-alsa pipewire-jack
            log_info "✓ PipeWire installé"
        else
            log_info "✓ Serveur audio déjà installé"
        fi
        ;;
    debian)
        log_info "Installation des dépendances (Debian/Ubuntu)..."
        sudo apt-get update -qq
        sudo apt-get install -y vulkan-tools libvulkan1
        
        if [ "$GPU_VENDOR" = "nvidia" ]; then
            sudo apt-get install -y libnvidia-glvkspirv libnvidia-glvkspirv:i386
        fi
        ;;
    fedora)
        log_info "Installation des dépendances (Fedora)..."
        sudo dnf install -y vulkan-loader vulkan-loader.i686
        
        if [ "$GPU_VENDOR" = "nvidia" ]; then
            sudo dnf install -y vulkan-loader-nvidia vulkan-loader-nvidia.i686
        fi
        ;;
esac

log_section "Installation terminée!"

echo ""
echo "✅ Dépendances gaming installées"
echo ""
echo "📝 Pour lancer ULTRAKILL maintenant:"
echo "   source ~/.zshrc"
echo "   ultrakill"
echo ""
echo "💡 Si vous avez encore des problèmes:"
echo "   - Redémarrez votre session (ou l'ordinateur)"
echo "   - Vérifiez que vos drivers NVIDIA sont à jour"
echo "   - Vérifiez que PulseAudio/PipeWire fonctionne: pulseaudio --check || pipewire --version"
echo ""

