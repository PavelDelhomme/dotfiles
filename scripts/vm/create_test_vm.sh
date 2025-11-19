#!/bin/bash

################################################################################
# Création rapide d'une VM de test Linux minimaliste
# Interface graphique virt-manager + système léger pour tests
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# CONFIGURATION
################################################################################
VM_NAME="test-dotfiles"
VM_MEMORY=2048
VM_VCPUS=2
VM_DISK_SIZE=20
ISO_DIR="$HOME/ISOs"
VM_DIR="$HOME/VMs"

log_section "Création VM de test pour dotfiles"

################################################################################
# VÉRIFIER QEMU/KVM INSTALLÉ
################################################################################
if ! command -v virt-manager >/dev/null 2>&1; then
    log_error "QEMU/KVM/virt-manager non installé!"
    log_info "Installation..."

    DOTFILES_DIR="$HOME/dotfiles"
    if [ -f "$DOTFILES_DIR/scripts/install/tools/install_qemu_full.sh" ]; then
        bash "$DOTFILES_DIR/scripts/install/tools/install_qemu_full.sh"
    else
        sudo pacman -S --noconfirm qemu-desktop libvirt virt-manager virt-viewer
        sudo systemctl enable --now libvirtd
        sudo usermod -aG libvirt $(whoami)
        log_warn "Déconnectez-vous et reconnectez-vous pour appliquer le groupe libvirt"
    fi
fi

################################################################################
# CRER LES DOSSIERS ET APPLIQUER LES BONS DROITS A ISOs et VMs POUR QEMU/LIBVIRT
################################################################################
mkdir -p "$VM_DIR"
mkdir -p "$ISO_DIR"
sudo chown -R root:libvirt "$VM_DIR" "$ISO_DIR"
sudo chmod -R 770 "$VM_DIR" "$ISO_DIR"

################################################################################
# CHOIX DE LA DISTRIBUTION
################################################################################
log_section "Choix de la distribution"

echo ""
echo "Distributions recommandées pour test rapide:"
echo ""
echo "1. Arch Linux (minimaliste, rapide, rolling)"
echo "2. Manjaro XFCE (rapide, préconfigurée)"
echo "3. EndeavourOS (Arch user-friendly)"
echo "4. Alpine Linux (ultra-minimaliste)"
echo ""

read -p "Choix (1-4) [défaut: 2]: " distro_choice
distro_choice=${distro_choice:-2}

case $distro_choice in
    1)
        DISTRO_NAME="Arch Linux"
        ISO_URL="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
        ISO_FILE="archlinux-x86_64.iso"
        ;;
    2)
        DISTRO_NAME="Manjaro XFCE"
        ISO_URL="https://download.manjaro.org/xfce/23.1.4/manjaro-xfce-23.1.4-240406-linux66.iso"
        ISO_FILE="manjaro-xfce-latest.iso"
        ;;
    3)
        DISTRO_NAME="EndeavourOS"
        ISO_URL="https://github.com/endeavouros-team/ISO/releases/latest/download/endeavouros.iso"
        ISO_FILE="endeavouros.iso"
        ;;
    4)
        DISTRO_NAME="Alpine Linux"
        ISO_URL="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-extended-3.19.0-x86_64.iso"
        ISO_FILE="alpine-extended.iso"
        ;;
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

log_info "Distribution sélectionnée: $DISTRO_NAME"

################################################################################
# TÉLÉCHARGER L'ISO SI NÉCESSAIRE
################################################################################
log_section "Téléchargement de l'ISO"

mkdir -p "$ISO_DIR"
ISO_PATH="$ISO_DIR/$ISO_FILE"

if [ ! -f "$ISO_PATH" ]; then
    log_info "Téléchargement de $DISTRO_NAME..."
    log_warn "Ceci peut prendre plusieurs minutes..."

    curl -L -o "$ISO_PATH" "$ISO_URL" || wget -O "$ISO_PATH" "$ISO_URL"

    log_info "✓ ISO téléchargée: $ISO_PATH"
else
    log_info "✓ ISO déjà présente: $ISO_PATH"
fi

################################################################################
# LANCER VIRT-MANAGER
################################################################################
log_section "Lancement de virt-manager"

log_info "Ouverture de virt-manager..."
log_warn ""
log_warn "INSTRUCTIONS CRÉATION VM:"
log_warn "═══════════════════════════════════"
log_warn "1. Cliquez sur '+' (Créer nouvelle machine)"
log_warn "2. Sélectionnez 'Local install media'"
log_warn "3. Parcourir → Sélectionnez: $ISO_PATH"
log_warn "4. Recherchez '$DISTRO_NAME' (ou Generic)"
log_warn "5. Mémoire: $VM_MEMORY Mo, CPUs: $VM_VCPUS"
log_warn "6. Disque: $VM_DISK_SIZE Go"
log_warn "7. Nom: $VM_NAME"
log_warn "8. ✓ 'Personnaliser avant install' (IMPORTANT)"
log_warn "9. Dans 'Disque 1' → Format: QCOW2 (pour snapshots!)"
log_warn "10. Démarrer installation"
log_warn ""
log_warn "APRÈS INSTALLATION:"
log_warn "═══════════════════════════════════"
log_warn "1. Créer snapshot: vm-snapshot $VM_NAME 'clean-install'"
log_warn "2. Dans la VM, tester bootstrap:"
log_warn "   curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
log_warn "3. Si erreur → restaurer: vm-snapshot-restore $VM_NAME 'clean-install'"
log_warn ""

# Lancer virt-manager en arrière-plan
nohup virt-manager >/dev/null 2>&1 &

log_info "✓ virt-manager lancé"
log_info ""
log_info "Configuration recommandée VM:"
log_info "  Nom: $VM_NAME"
log_info "  RAM: $VM_MEMORY Mo"
log_info "  CPUs: $VM_VCPUS"
log_info "  Disque: $VM_DISK_SIZE Go (QCOW2)"
log_info "  ISO: $ISO_PATH"

################################################################################
# CRÉER SCRIPT HELPER
################################################################################

mkdir -p ~/.local/bin

cat > ~/.local/bin/test-dotfiles-vm << 'ENDHELPER'
#!/bin/bash
# Helper pour tester dotfiles dans VM

VM_NAME="test-dotfiles"

echo "🧪 Test dotfiles - VM $VM_NAME"
echo ""
echo "Commandes disponibles:"
echo "  1. Démarrer VM:           virsh start $VM_NAME"
echo "  2. Snapshot clean:        vm-snapshot $VM_NAME 'clean' 'Installation propre'"
echo "  3. Restaurer clean:       vm-snapshot-restore $VM_NAME 'clean'"
echo "  4. Liste snapshots:       vm-snapshot-list $VM_NAME"
echo "  5. Console VM:            virt-viewer $VM_NAME"
echo ""
echo "Test dans la VM:"
echo "  curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
echo ""

read -p "Action (1-5 ou q): " action

case $action in
    1) virsh start $VM_NAME ;;
    2) vm-snapshot $VM_NAME 'clean' 'Installation propre' ;;
    3) vm-snapshot-restore $VM_NAME 'clean' ;;
    4) vm-snapshot-list $VM_NAME ;;
    5) virt-viewer $VM_NAME ;;
    q) exit 0 ;;
    *) echo "Choix invalide" ;;
esac
ENDHELPER

chmod +x ~/.local/bin/test-dotfiles-vm

log_info "✓ Script helper créé: test-dotfiles-vm"
log_info ""
log_info "Lancez 'test-dotfiles-vm' pour gérer la VM rapidement"
