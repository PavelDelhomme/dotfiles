#!/bin/bash

################################################################################
# libvirt/virsh Manager - Gestion des VMs via libvirt
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman libvirt'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/lib/common.sh" ]; then
    source "$DOTFILES_DIR/scripts/lib/common.sh"
else
    log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
    log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
    log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }
fi

log_section "Gestionnaire libvirt/virsh"

# Vérifier que libvirt est installé
if ! command -v virsh >/dev/null 2>&1; then
    log_error "libvirt n'est pas installé!"
    echo "Installez avec: configman qemu-packages"
    return 1 2>/dev/null || exit 1
fi

echo ""
echo "Options disponibles:"
echo "1. Lister les VMs (domaines)"
echo "2. Démarrer une VM"
echo "3. Arrêter une VM"
echo "4. Redémarrer une VM"
echo "5. Suspendre/Reprendre une VM"
echo "6. Informations sur une VM"
echo "7. Accéder à la console d'une VM"
echo "8. Créer une nouvelle VM"
echo "9. Supprimer une VM"
echo "10. Gérer les réseaux libvirt"
echo "0. Retour"
echo ""
printf "Choix [0-10]: "
read -r choice

case "$choice" in
    1)
        log_info "Liste des VMs libvirt..."
        echo ""
        echo "VMs en cours d'exécution:"
        virsh list
        echo ""
        echo "Toutes les VMs:"
        virsh list --all
        ;;
    2)
        log_info "Démarrage d'une VM..."
        virsh list --all
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        virsh start "$vm_name"
        if [ $? -eq 0 ]; then
            log_info "✓ VM démarrée"
        fi
        ;;
    3)
        log_info "Arrêt d'une VM..."
        virsh list
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        printf "Arrêt gracieux (o) ou forcé (f)? [o]: "
        read -r shutdown_type
        
        if [[ "$shutdown_type" =~ ^[fF]$ ]]; then
            virsh destroy "$vm_name"
        else
            virsh shutdown "$vm_name"
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ VM arrêtée"
        fi
        ;;
    4)
        log_info "Redémarrage d'une VM..."
        virsh list
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        virsh reboot "$vm_name"
        if [ $? -eq 0 ]; then
            log_info "✓ VM redémarrée"
        fi
        ;;
    5)
        log_info "Suspendre/Reprendre une VM..."
        virsh list
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        echo ""
        echo "1. Suspendre"
        echo "2. Reprendre"
        printf "Choix [1-2]: "
        read -r suspend_choice
        
        case "$suspend_choice" in
            1)
                virsh suspend "$vm_name"
                log_info "✓ VM suspendue"
                ;;
            2)
                virsh resume "$vm_name"
                log_info "✓ VM reprise"
                ;;
        esac
        ;;
    6)
        log_info "Informations sur une VM..."
        virsh list --all
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        echo ""
        virsh dominfo "$vm_name"
        echo ""
        virsh domstats "$vm_name" 2>/dev/null || true
        ;;
    7)
        log_info "Accès console d'une VM..."
        virsh list
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        log_info "Connexion à la console..."
        log_info "Utilisez Ctrl+] pour quitter"
        virsh console "$vm_name"
        ;;
    8)
        log_info "Création d'une nouvelle VM..."
        log_warn "Utilisez virt-manager (GUI) ou virt-install pour créer une VM"
        echo ""
        echo "Exemple avec virt-install:"
        echo "  virt-install --name ma-vm --ram 2048 --disk path=/var/lib/libvirt/images/ma-vm.qcow2,size=20 --cdrom /path/to/iso"
        ;;
    9)
        log_info "Suppression d'une VM..."
        virsh list --all
        echo ""
        printf "Nom de la VM: "
        read -r vm_name
        
        printf "Confirmer la suppression? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            virsh destroy "$vm_name" 2>/dev/null
            virsh undefine "$vm_name"
            log_info "✓ VM supprimée"
        fi
        ;;
    10)
        log_info "Gestion des réseaux libvirt..."
        echo ""
        echo "1. Lister les réseaux"
        echo "2. Démarrer un réseau"
        echo "3. Arrêter un réseau"
        echo "4. Informations sur un réseau"
        printf "Choix [1-4]: "
        read -r net_choice
        
        case "$net_choice" in
            1)
                virsh net-list --all
                ;;
            2)
                virsh net-list --inactive
                echo ""
                printf "Nom du réseau: "
                read -r net_name
                virsh net-start "$net_name"
                ;;
            3)
                virsh net-list
                echo ""
                printf "Nom du réseau: "
                read -r net_name
                virsh net-destroy "$net_name"
                ;;
            4)
                virsh net-list
                echo ""
                printf "Nom du réseau: "
                read -r net_name
                virsh net-info "$net_name"
                ;;
        esac
        ;;
    0)
        return 0
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Opération terminée!"

