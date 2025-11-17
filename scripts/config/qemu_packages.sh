#!/bin/bash

################################################################################
# Installation paquets QEMU/KVM - Unitaire
# Installe uniquement les paquets nécessaires
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes de dépendances

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "Installation paquets QEMU/KVM"

# Vérifier support virtualisation
if ! grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null 2>&1; then
    log_error "Pas de support virtualisation matérielle!"
    log_error "Activez Intel VT-x ou AMD-V dans le BIOS"
    exit 1
fi
log_info "✓ Support virtualisation détecté"

# Résoudre conflit iptables si nécessaire
if pacman -Q iptables >/dev/null 2>&1 && ! pacman -Q iptables-nft >/dev/null 2>&1; then
    log_info "Résolution conflit iptables..."
    sudo pacman -Rdd --noconfirm iptables 2>/dev/null || true
    sudo pacman -S --noconfirm iptables-nft
    log_info "✓ Conflit résolu"
fi

# Installer les paquets
log_info "Installation des paquets..."

if ! sudo pacman -S --needed --noconfirm \
    qemu-desktop \
    libvirt \
    virt-manager \
    virt-viewer \
    dnsmasq \
    bridge-utils \
    openbsd-netcat \
    ebtables 2>&1; then
    log_error "Erreur lors de l'installation des paquets QEMU"
    log_warn "Cela peut être dû à des problèmes de dépendances système"
    log_warn "Essayez de mettre à jour votre système d'abord:"
    log_warn "  sudo pacman -Syu"
    log_warn "Puis réessayez l'installation"
    exit 1
fi

log_info "✓ Paquets installés"

log_section "Installation terminée!"
log_warn "Configurez ensuite:"
log_warn "  - Réseau: bash ~/dotfiles/scripts/config/qemu_network.sh"
log_warn "  - Libvirt: bash ~/dotfiles/scripts/config/qemu_libvirt.sh"

