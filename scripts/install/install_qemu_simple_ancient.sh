#!/bin/bash

################################################################################
# Installation QEMU/KVM/virt-manager pour Manjaro - Version Simple
################################################################################

set -e

echo "════════════════════════════════════════════════"
echo "Installation QEMU/KVM/virt-manager"
echo "════════════════════════════════════════════════"
echo ""

# Vérifier support virtualisation
echo "[1/6] Vérification support virtualisation..."
if grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null 2>&1; then
    echo "✓ Support virtualisation détecté"
else
    echo "✗ ERREUR: Pas de support virtualisation!"
    echo "Activez Intel VT-x ou AMD-V dans le BIOS"
    exit 1
fi

# Installer les paquets
echo ""
echo "[2/6] Installation des paquets QEMU/KVM..."
sudo pacman -S --noconfirm \
    qemu-desktop \
    libvirt \
    virt-manager \
    virt-viewer \
    dnsmasq \
    bridge-utils \
    openbsd-netcat \
    ebtables \
    iptables-nft

echo "✓ Paquets installés"

# Démarrer libvirtd
echo ""
echo "[3/6] Démarrage de libvirtd..."
sudo systemctl enable --now libvirtd
echo "✓ libvirtd démarré"

# Ajouter utilisateur au groupe
echo ""
echo "[4/6] Ajout au groupe libvirt..."
sudo usermod -aG libvirt $(whoami)
echo "✓ Utilisateur ajouté au groupe libvirt"

# Configurer réseau par défaut
echo ""
echo "[5/6] Configuration réseau..."
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default
echo "✓ Réseau configuré"

# Créer dossiers
echo ""
echo "[6/6] Création dossiers..."
mkdir -p ~/VMs
mkdir -p ~/ISOs
echo "✓ Dossiers créés: ~/VMs et ~/ISOs"

echo ""
echo "════════════════════════════════════════════════"
echo "✓ Installation terminée!"
echo "════════════════════════════════════════════════"
echo ""
echo "⚠ IMPORTANT:"
echo "  Déconnectez-vous et reconnectez-vous"
echo "  (ou redémarrez) pour que le groupe libvirt soit actif"
echo ""
echo "Ensuite, lancez:"
echo "  virt-manager"
echo ""
