#!/bin/bash
# =============================================================================
# VM Manager - Gestionnaire complet de VM en ligne de commande
# =============================================================================
# Description: Gestion complète des VM (création, démarrage, snapshots, rollback, tests)
# Auteur: Paul Delhomme
# Version: 2.0
# =============================================================================

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
}

# Variables
VM_DIR="${VM_DIR:-$HOME/VMs}"
ISO_DIR="${ISO_DIR:-$HOME/ISOs}"
DEFAULT_VM_NAME="${DEFAULT_VM_NAME:-test-dotfiles}"
DEFAULT_VM_MEMORY=2048
DEFAULT_VM_VCPUS=2
DEFAULT_VM_DISK_SIZE=20

################################################################################
# DESC: Vérifie que QEMU/KVM est installé et configuré
# USAGE: check_qemu_installed
# RETURNS: 0 si OK, 1 si erreur
################################################################################
check_qemu_installed() {
    if ! command -v virsh >/dev/null 2>&1; then
        log_error "QEMU/KVM non installé!"
        log_info "Installation via: bash $SCRIPT_DIR/install/tools/install_qemu_full.sh"
        return 1
    fi
    
    if ! systemctl is-active --quiet libvirtd 2>/dev/null; then
        log_warn "Service libvirtd non démarré, démarrage..."
        sudo systemctl start libvirtd
        sudo systemctl enable libvirtd
    fi
    
    return 0
}

################################################################################
# DESC: Liste toutes les VM disponibles
# USAGE: list_vms [--all]
# RETURNS: 0 si succès
################################################################################
list_vms() {
    local show_all="${1:-}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    log_section "Liste des VM"
    
    if [[ "$show_all" == "--all" ]]; then
        virsh list --all
    else
        virsh list
    fi
}

################################################################################
# DESC: Crée une VM de test complètement en ligne de commande
# USAGE: create_vm [name] [memory] [vcpus] [disk_size] [iso_path]
# RETURNS: 0 si succès
################################################################################
create_vm() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local memory="${2:-$DEFAULT_VM_MEMORY}"
    local vcpus="${3:-$DEFAULT_VM_VCPUS}"
    local disk_size="${4:-$DEFAULT_VM_DISK_SIZE}"
    local iso_path="${5:-}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    log_section "Création VM: $vm_name"
    
    # Vérifier si la VM existe déjà
    if virsh dominfo "$vm_name" &>/dev/null; then
        log_warn "VM '$vm_name' existe déjà"
        read -p "Supprimer et recréer? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            delete_vm "$vm_name"
        else
            return 1
        fi
    fi
    
    # Créer les dossiers
    mkdir -p "$VM_DIR"
    mkdir -p "$ISO_DIR"
    
    # Chemin du disque
    local disk_path="$VM_DIR/${vm_name}.qcow2"
    
    # Créer le disque QCOW2 (format pour snapshots)
    log_info "Création du disque virtuel ($disk_size Go)..."
    qemu-img create -f qcow2 "$disk_path" "${disk_size}G" || {
        log_error "Erreur lors de la création du disque"
        return 1
    }
    
    # Si ISO fournie, créer la VM avec installation
    if [[ -n "$iso_path" ]] && [[ -f "$iso_path" ]]; then
        log_info "Création de la VM avec ISO: $iso_path"
        
        # Créer la VM via virt-install
        virt-install \
            --name "$vm_name" \
            --memory "$memory" \
            --vcpus "$vcpus" \
            --disk path="$disk_path",format=qcow2,size="$disk_size" \
            --cdrom "$iso_path" \
            --network network=default \
            --graphics vnc,listen=0.0.0.0 \
            --noautoconsole \
            --os-variant detect=on \
            --wait -1 || {
            log_error "Erreur lors de la création de la VM"
            return 1
        }
        
        log_info "✅ VM créée avec succès"
        log_info "Connectez-vous via: virt-viewer $vm_name"
    else
        # Créer une VM sans ISO (disque vide)
        log_info "Création de la VM (sans ISO)..."
        
        virt-install \
            --name "$vm_name" \
            --memory "$memory" \
            --vcpus "$vcpus" \
            --disk path="$disk_path",format=qcow2,size="$disk_size" \
            --network network=default \
            --graphics vnc,listen=0.0.0.0 \
            --noautoconsole \
            --os-variant generic \
            --import || {
            log_error "Erreur lors de la création de la VM"
            return 1
        }
        
        log_info "✅ VM créée (disque vide)"
        log_warn "Ajoutez une ISO pour installer un OS"
    fi
    
    # Créer un snapshot initial "clean"
    log_info "Création snapshot initial 'clean'..."
    create_snapshot "$vm_name" "clean" "État initial propre"
    
    return 0
}

################################################################################
# DESC: Démarre une VM
# USAGE: start_vm <vm_name>
# RETURNS: 0 si succès
################################################################################
start_vm() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_info "Démarrage de la VM: $vm_name"
    virsh start "$vm_name" && log_info "✅ VM démarrée" || {
        log_error "Erreur lors du démarrage"
        return 1
    }
    
    # Attendre que la VM soit prête
    log_info "Attente que la VM soit prête..."
    sleep 3
    
    return 0
}

################################################################################
# DESC: Arrête une VM
# USAGE: stop_vm <vm_name> [--force]
# RETURNS: 0 si succès
################################################################################
stop_vm() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local force="${2:-}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    if [[ "$force" == "--force" ]]; then
        log_info "Arrêt forcé de la VM: $vm_name"
        virsh destroy "$vm_name" && log_info "✅ VM arrêtée (forcé)" || {
            log_error "Erreur lors de l'arrêt"
            return 1
        }
    else
        log_info "Arrêt de la VM: $vm_name"
        virsh shutdown "$vm_name" && log_info "✅ VM arrêtée" || {
            log_error "Erreur lors de l'arrêt"
            return 1
        }
    fi
    
    return 0
}

################################################################################
# DESC: Crée un snapshot d'une VM
# USAGE: create_snapshot <vm_name> <snapshot_name> [description]
# RETURNS: 0 si succès
################################################################################
create_snapshot() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local snapshot_name="$2"
    local description="${3:-Snapshot créé le $(date '+%Y-%m-%d %H:%M:%S')}"
    
    if [[ -z "$snapshot_name" ]]; then
        log_error "Usage: create_snapshot <vm_name> <snapshot_name> [description]"
        return 1
    fi
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_info "Création snapshot '$snapshot_name' pour VM: $vm_name"
    
    # Arrêter la VM si elle tourne (pour snapshot cohérent)
    if virsh dominfo "$vm_name" | grep -q "État:.*en cours d'exécution"; then
        log_info "Arrêt de la VM pour snapshot cohérent..."
        virsh shutdown "$vm_name"
        sleep 2
    fi
    
    virsh snapshot-create-as "$vm_name" "$snapshot_name" --description "$description" && {
        log_info "✅ Snapshot '$snapshot_name' créé"
        return 0
    } || {
        log_error "Erreur lors de la création du snapshot"
        return 1
    }
}

################################################################################
# DESC: Liste les snapshots d'une VM
# USAGE: list_snapshots <vm_name>
# RETURNS: 0 si succès
################################################################################
list_snapshots() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_section "Snapshots de la VM: $vm_name"
    virsh snapshot-list "$vm_name" --tree
}

################################################################################
# DESC: Restaure un snapshot (rollback)
# USAGE: restore_snapshot <vm_name> <snapshot_name>
# RETURNS: 0 si succès
################################################################################
restore_snapshot() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local snapshot_name="$2"
    
    if [[ -z "$snapshot_name" ]]; then
        log_error "Usage: restore_snapshot <vm_name> <snapshot_name>"
        return 1
    fi
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_warn "⚠️  Restauration du snapshot '$snapshot_name' pour VM: $vm_name"
    log_warn "⚠️  Toutes les modifications depuis ce snapshot seront perdues!"
    read -p "Confirmer? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Opération annulée"
        return 1
    fi
    
    # Arrêter la VM si elle tourne
    if virsh dominfo "$vm_name" | grep -q "État:.*en cours d'exécution"; then
        log_info "Arrêt de la VM..."
        virsh destroy "$vm_name"
        sleep 2
    fi
    
    log_info "Restauration du snapshot..."
    virsh snapshot-revert "$vm_name" "$snapshot_name" && {
        log_info "✅ Snapshot '$snapshot_name' restauré"
        return 0
    } || {
        log_error "Erreur lors de la restauration"
        return 1
    }
}

################################################################################
# DESC: Supprime un snapshot
# USAGE: delete_snapshot <vm_name> <snapshot_name>
# RETURNS: 0 si succès
################################################################################
delete_snapshot() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local snapshot_name="$2"
    
    if [[ -z "$snapshot_name" ]]; then
        log_error "Usage: delete_snapshot <vm_name> <snapshot_name>"
        return 1
    fi
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    log_warn "⚠️  Suppression du snapshot '$snapshot_name' pour VM: $vm_name"
    read -p "Confirmer? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Opération annulée"
        return 1
    fi
    
    virsh snapshot-delete "$vm_name" "$snapshot_name" && {
        log_info "✅ Snapshot '$snapshot_name' supprimé"
        return 0
    } || {
        log_error "Erreur lors de la suppression"
        return 1
    }
}

################################################################################
# DESC: Supprime une VM complètement
# USAGE: delete_vm <vm_name>
# RETURNS: 0 si succès
################################################################################
delete_vm() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_warn "⚠️  Suppression complète de la VM: $vm_name"
    log_warn "⚠️  Tous les snapshots et le disque seront supprimés!"
    read -p "Confirmer? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Opération annulée"
        return 1
    fi
    
    # Arrêter la VM si elle tourne
    if virsh dominfo "$vm_name" | grep -q "État:.*en cours d'exécution"; then
        log_info "Arrêt de la VM..."
        virsh destroy "$vm_name"
        sleep 2
    fi
    
    # Supprimer tous les snapshots
    log_info "Suppression des snapshots..."
    virsh snapshot-list "$vm_name" --name 2>/dev/null | while read -r snap; do
        [[ -n "$snap" ]] && virsh snapshot-delete "$vm_name" "$snap" --metadata 2>/dev/null || true
    done
    
    # Supprimer la VM
    log_info "Suppression de la VM..."
    virsh undefine "$vm_name" --remove-all-storage && {
        log_info "✅ VM '$vm_name' supprimée"
        return 0
    } || {
        log_error "Erreur lors de la suppression"
        return 1
    }
}

################################################################################
# DESC: Affiche les informations d'une VM
# USAGE: show_vm_info <vm_name>
# RETURNS: 0 si succès
################################################################################
show_vm_info() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        return 1
    fi
    
    log_section "Informations VM: $vm_name"
    virsh dominfo "$vm_name"
    echo ""
    log_info "Snapshots:"
    virsh snapshot-list "$vm_name" --tree 2>/dev/null || log_info "  (aucun snapshot)"
}

################################################################################
# DESC: Exécute une commande dans la VM via SSH (si SSH configuré)
# USAGE: exec_vm_command <vm_name> <command>
# RETURNS: 0 si succès
################################################################################
exec_vm_command() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    local command="$2"
    
    if [[ -z "$command" ]]; then
        log_error "Usage: exec_vm_command <vm_name> <command>"
        return 1
    fi
    
    # Obtenir l'IP de la VM
    local vm_ip=$(virsh domifaddr "$vm_name" 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
    
    if [[ -z "$vm_ip" ]]; then
        log_error "Impossible d'obtenir l'IP de la VM"
        log_info "Assurez-vous que la VM est démarrée et a une IP"
        return 1
    fi
    
    log_info "Exécution de la commande dans la VM ($vm_ip): $command"
    
    # Essayer SSH (nécessite que SSH soit configuré dans la VM)
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "user@$vm_ip" "$command" && {
        log_info "✅ Commande exécutée"
        return 0
    } || {
        log_warn "SSH non disponible, utilisez virt-viewer pour accéder à la VM"
        return 1
    }
}

################################################################################
# DESC: Teste les dotfiles dans une VM (workflow complet)
# USAGE: test_dotfiles_in_vm <vm_name>
# RETURNS: 0 si succès
################################################################################
test_dotfiles_in_vm() {
    local vm_name="${1:-$DEFAULT_VM_NAME}"
    
    if ! check_qemu_installed; then
        return 1
    fi
    
    if ! virsh dominfo "$vm_name" &>/dev/null; then
        log_error "VM '$vm_name' n'existe pas"
        log_info "Créez-la d'abord avec: create_vm $vm_name"
        return 1
    fi
    
    log_section "Test des dotfiles dans VM: $vm_name"
    
    # Vérifier que la VM est démarrée
    if ! virsh dominfo "$vm_name" | grep -q "État:.*en cours d'exécution"; then
        log_info "Démarrage de la VM..."
        start_vm "$vm_name" || return 1
        log_info "Attente que la VM soit prête (10 secondes)..."
        sleep 10
    fi
    
    # Créer un snapshot avant test
    log_info "Création snapshot 'before-test'..."
    create_snapshot "$vm_name" "before-test" "Avant test dotfiles"
    
    # Obtenir l'IP de la VM
    local vm_ip=$(virsh domifaddr "$vm_name" 2>/dev/null | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
    
    if [[ -n "$vm_ip" ]]; then
        log_info "IP de la VM: $vm_ip"
        log_info ""
        log_info "Pour tester les dotfiles dans la VM:"
        log_info "1. Connectez-vous à la VM: virt-viewer $vm_name"
        log_info "2. Dans la VM, exécutez:"
        log_info "   curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
        log_info ""
        log_info "Si le test échoue, restaurez le snapshot:"
        log_info "   make vm-rollback VM=$vm_name SNAPSHOT=before-test"
    else
        log_info "Connectez-vous à la VM: virt-viewer $vm_name"
        log_info "Dans la VM, exécutez:"
        log_info "   curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
    fi
    
    return 0
}

################################################################################
# DESC: Menu interactif de gestion des VM
# USAGE: vm_manager_menu
# RETURNS: 0
################################################################################
vm_manager_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  VM Manager - Gestionnaire VM                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo
        
        echo -e "${YELLOW}Gestion des VM:${RESET}"
        echo "  1) Lister les VM"
        echo "  2) Créer une VM"
        echo "  3) Démarrer une VM"
        echo "  4) Arrêter une VM"
        echo "  5) Afficher infos VM"
        echo "  6) Supprimer une VM"
        echo
        echo -e "${YELLOW}Snapshots:${RESET}"
        echo "  7) Créer un snapshot"
        echo "  8) Lister les snapshots"
        echo "  9) Restaurer un snapshot (rollback)"
        echo "  10) Supprimer un snapshot"
        echo
        echo -e "${YELLOW}Tests:${RESET}"
        echo "  11) Tester dotfiles dans VM"
        echo
        echo "  0) Quitter"
        echo
        
        read -p "Choix: " choice
        echo
        
        case "$choice" in
            1) list_vms --all ;;
            2)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                vm_name=${vm_name:-$DEFAULT_VM_NAME}
                read -p "Mémoire (Mo) [défaut: $DEFAULT_VM_MEMORY]: " memory
                memory=${memory:-$DEFAULT_VM_MEMORY}
                read -p "VCPUs [défaut: $DEFAULT_VM_VCPUS]: " vcpus
                vcpus=${vcpus:-$DEFAULT_VM_VCPUS}
                read -p "Taille disque (Go) [défaut: $DEFAULT_VM_DISK_SIZE]: " disk_size
                disk_size=${disk_size:-$DEFAULT_VM_DISK_SIZE}
                read -p "Chemin ISO (optionnel): " iso_path
                create_vm "$vm_name" "$memory" "$vcpus" "$disk_size" "$iso_path"
                ;;
            3)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                start_vm "${vm_name:-$DEFAULT_VM_NAME}"
                ;;
            4)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                read -p "Arrêt forcé? [y/N]: " force
                if [[ "$force" =~ ^[Yy]$ ]]; then
                    stop_vm "${vm_name:-$DEFAULT_VM_NAME}" --force
                else
                    stop_vm "${vm_name:-$DEFAULT_VM_NAME}"
                fi
                ;;
            5)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                show_vm_info "${vm_name:-$DEFAULT_VM_NAME}"
                ;;
            6)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                delete_vm "${vm_name:-$DEFAULT_VM_NAME}"
                ;;
            7)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                read -p "Nom du snapshot: " snap_name
                read -p "Description (optionnel): " snap_desc
                create_snapshot "${vm_name:-$DEFAULT_VM_NAME}" "$snap_name" "$snap_desc"
                ;;
            8)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                list_snapshots "${vm_name:-$DEFAULT_VM_NAME}"
                ;;
            9)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                read -p "Nom du snapshot à restaurer: " snap_name
                restore_snapshot "${vm_name:-$DEFAULT_VM_NAME}" "$snap_name"
                ;;
            10)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                read -p "Nom du snapshot à supprimer: " snap_name
                delete_snapshot "${vm_name:-$DEFAULT_VM_NAME}" "$snap_name"
                ;;
            11)
                read -p "Nom de la VM [défaut: $DEFAULT_VM_NAME]: " vm_name
                test_dotfiles_in_vm "${vm_name:-$DEFAULT_VM_NAME}"
                ;;
            0)
                return 0
                ;;
            *)
                log_error "Choix invalide"
                sleep 1
                ;;
        esac
        
        echo
        read -p "Appuyez sur Entrée pour continuer..."
    done
}

# Si le script est exécuté directement, lancer le menu
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    vm_manager_menu
fi

