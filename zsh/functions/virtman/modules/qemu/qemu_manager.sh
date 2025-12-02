#!/bin/bash

################################################################################
# QEMU/KVM Manager - Gestion des machines virtuelles QEMU/KVM
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman qemu'
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

log_section "Gestionnaire QEMU/KVM"

# Vérifier que QEMU est installé
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    log_error "QEMU n'est pas installé!"
    echo "Installez avec: configman qemu-packages"
    return 1 2>/dev/null || exit 1
fi

echo ""
echo "Options disponibles:"
echo "1. Lister les VMs QEMU"
echo "2. Créer une nouvelle VM"
echo "3. Démarrer une VM"
echo "4. Arrêter une VM"
echo "5. Vérifier l'état d'une VM"
echo "6. Accéder à la console d'une VM"
echo "7. Gérer les disques (créer, supprimer)"
echo "8. Configuration réseau"
echo "0. Retour"
echo ""
printf "Choix [0-8]: "
read -r choice

case "$choice" in
    1)
        log_info "Liste des VMs QEMU..."
        # Chercher les processus QEMU en cours
        if pgrep -f qemu-system >/dev/null; then
            echo ""
            echo "VMs en cours d'exécution:"
            ps aux | grep qemu-system | grep -v grep | awk '{print $2, $11, $12, $13, $14, $15}'
        else
            log_info "Aucune VM QEMU en cours d'exécution"
        fi
        
        # Chercher les fichiers de disque
        if [ -d "$HOME/VMs" ] || [ -d "$HOME/vms" ] || [ -d "/var/lib/libvirt/images" ]; then
            echo ""
            echo "Disques trouvés:"
            find "$HOME/VMs" "$HOME/vms" "/var/lib/libvirt/images" -name "*.qcow2" -o -name "*.img" 2>/dev/null | head -10
        fi
        ;;
    2)
        log_info "Création d'une nouvelle VM QEMU..."
        printf "Nom de la VM: "
        read -r vm_name
        
        printf "Taille du disque (ex: 20G): "
        read -r disk_size
        disk_size="${disk_size:-20G}"
        
        printf "RAM allouée (ex: 2048M): "
        read -r ram_size
        ram_size="${ram_size:-2048M}"
        
        printf "Répertoire pour la VM [$HOME/VMs]: "
        read -r vm_dir
        vm_dir="${vm_dir:-$HOME/VMs}"
        mkdir -p "$vm_dir"
        
        disk_file="$vm_dir/${vm_name}.qcow2"
        
        log_info "Création du disque virtuel..."
        qemu-img create -f qcow2 "$disk_file" "$disk_size"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Disque créé: $disk_file"
            echo ""
            log_info "Pour démarrer la VM:"
            echo "  qemu-system-x86_64 -enable-kvm -m $ram_size -hda $disk_file -cdrom /path/to/iso"
        else
            log_error "✗ Erreur lors de la création du disque"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    3)
        log_info "Démarrage d'une VM QEMU..."
        printf "Fichier disque (.qcow2 ou .img): "
        read -r disk_file
        
        if [ ! -f "$disk_file" ]; then
            log_error "Fichier disque introuvable: $disk_file"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "RAM (ex: 2048M) [2048M]: "
        read -r ram_size
        ram_size="${ram_size:-2048M}"
        
        printf "ISO à monter (optionnel, laissez vide si non): "
        read -r iso_file
        
        log_info "Démarrage de la VM..."
        if [ -n "$iso_file" ] && [ -f "$iso_file" ]; then
            qemu-system-x86_64 -enable-kvm -m "$ram_size" -hda "$disk_file" -cdrom "$iso_file" &
        else
            qemu-system-x86_64 -enable-kvm -m "$ram_size" -hda "$disk_file" &
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ VM démarrée en arrière-plan"
        else
            log_error "✗ Erreur lors du démarrage"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    4)
        log_info "Arrêt d'une VM QEMU..."
        if ! pgrep -f qemu-system >/dev/null; then
            log_warn "Aucune VM en cours d'exécution"
            return 0 2>/dev/null || exit 0
        fi
        
        echo ""
        echo "VMs en cours d'exécution:"
        ps aux | grep qemu-system | grep -v grep | nl
        echo ""
        printf "Numéro de la VM à arrêter: "
        read -r vm_num
        
        vm_pid=$(ps aux | grep qemu-system | grep -v grep | sed -n "${vm_num}p" | awk '{print $2}')
        
        if [ -z "$vm_pid" ]; then
            log_error "VM introuvable"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Arrêter la VM (PID: $vm_pid)? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            kill "$vm_pid"
            log_info "✓ VM arrêtée"
        else
            log_info "Arrêt annulé"
        fi
        ;;
    5)
        log_info "État des VMs QEMU..."
        if pgrep -f qemu-system >/dev/null; then
            echo ""
            echo "VMs en cours d'exécution:"
            ps aux | grep qemu-system | grep -v grep
        else
            log_info "Aucune VM en cours d'exécution"
        fi
        ;;
    6)
        log_info "Accès console VM QEMU..."
        if ! pgrep -f qemu-system >/dev/null; then
            log_warn "Aucune VM en cours d'exécution"
            return 0 2>/dev/null || exit 0
        fi
        
        echo ""
        echo "VMs disponibles:"
        ps aux | grep qemu-system | grep -v grep | nl
        echo ""
        printf "Numéro de la VM: "
        read -r vm_num
        
        log_info "Utilisez Ctrl+Alt+G pour sortir de la console QEMU"
        log_info "Ou utilisez VNC si configuré"
        ;;
    7)
        log_info "Gestion des disques QEMU..."
        echo ""
        echo "1. Créer un nouveau disque"
        echo "2. Redimensionner un disque"
        echo "3. Convertir un disque"
        echo "4. Informations sur un disque"
        printf "Choix [1-4]: "
        read -r disk_choice
        
        case "$disk_choice" in
            1)
                printf "Nom du disque: "
                read -r disk_name
                printf "Taille (ex: 20G): "
                read -r disk_size
                printf "Format (qcow2/raw) [qcow2]: "
                read -r disk_format
                disk_format="${disk_format:-qcow2}"
                
                log_info "Création du disque..."
                qemu-img create -f "$disk_format" "$disk_name" "$disk_size"
                if [ $? -eq 0 ]; then
                    log_info "✓ Disque créé"
                fi
                ;;
            2)
                printf "Fichier disque: "
                read -r disk_file
                printf "Nouvelle taille (ex: +10G): "
                read -r new_size
                
                log_info "Redimensionnement..."
                qemu-img resize "$disk_file" "$new_size"
                if [ $? -eq 0 ]; then
                    log_info "✓ Disque redimensionné"
                fi
                ;;
            3)
                printf "Fichier source: "
                read -r src_file
                printf "Fichier destination: "
                read -r dst_file
                printf "Format destination (qcow2/raw) [qcow2]: "
                read -r dst_format
                dst_format="${dst_format:-qcow2}"
                
                log_info "Conversion..."
                qemu-img convert -f raw -O "$dst_format" "$src_file" "$dst_file"
                if [ $? -eq 0 ]; then
                    log_info "✓ Disque converti"
                fi
                ;;
            4)
                printf "Fichier disque: "
                read -r disk_file
                
                if [ -f "$disk_file" ]; then
                    echo ""
                    qemu-img info "$disk_file"
                else
                    log_error "Fichier introuvable"
                fi
                ;;
        esac
        ;;
    8)
        log_info "Configuration réseau QEMU..."
        log_info "Utilisez 'configman qemu-network' pour configurer le réseau NAT"
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

