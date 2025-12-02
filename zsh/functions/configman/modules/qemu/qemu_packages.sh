#!/bin/bash

################################################################################
# Installation paquets QEMU/KVM - Unitaire
# Installe uniquement les paquets nécessaires
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les problèmes de dépendances

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    return 1 2>/dev/null || exit 1
}

log_section "Installation paquets QEMU/KVM"

# Vérifier support virtualisation
if ! grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null 2>&1; then
    log_error "Pas de support virtualisation matérielle!"
    log_error "Activez Intel VT-x ou AMD-V dans le BIOS"
    return 1 2>/dev/null || exit 1
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
    return 1 2>/dev/null || exit 1
fi

log_info "✓ Paquets installés"

log_section "Installation terminée!"
log_warn "Configurez ensuite:"
log_warn "  - Réseau: bash ~/dotfiles/scripts/config/qemu_network.sh"
log_warn "  - Libvirt: bash ~/dotfiles/scripts/config/qemu_libvirt.sh"

