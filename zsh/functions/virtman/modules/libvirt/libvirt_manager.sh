#!/bin/bash

################################################################################
# libvirt/virsh Manager - Gestion des VMs via libvirt
# Version améliorée avec gestion multi-terminaux et contrôle manuel
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman libvirt'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/lib/common.sh" ]; then
    source "$DOTFILES_DIR/scripts/lib/common.sh"
else
    log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
    log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
    log_error() { echo -e "${RED}[✗]${NC} $1"; }
    log_section() { echo -e "\n${CYAN}═══════════════════════════════════${NC}\n${CYAN}$1${NC}\n${CYAN}═══════════════════════════════════${NC}"; }
fi

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              GESTIONNAIRE LIBVIRT/VIRSH                        ║"
    echo "║              Gestion VMs en Ligne de Commande                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Fonction pour lister les VMs avec statut
list_vms() {
    echo ""
    echo -e "${CYAN}📋 VMs en cours d'exécution:${NC}"
    virsh list 2>/dev/null || {
        log_error "Impossible de lister les VMs. Vérifiez que libvirtd est démarré."
        return 1
    }
    echo ""
    echo -e "${CYAN}📋 Toutes les VMs:${NC}"
    virsh list --all 2>/dev/null
    echo ""
}

# Fonction pour ouvrir une console dans un nouveau terminal
open_vm_console_terminal() {
    local vm_name="$1"
    local terminal="${2:-$TERMINAL}"
    
    if [ -z "$vm_name" ]; then
        log_error "Nom de VM requis"
        return 1
    fi
    
    # Détecter le terminal disponible
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash -c "virsh console $vm_name; exec bash" 2>/dev/null &
    elif command -v konsole &>/dev/null; then
        konsole -e bash -c "virsh console $vm_name; exec bash" 2>/dev/null &
    elif command -v xterm &>/dev/null; then
        xterm -e bash -c "virsh console $vm_name; exec bash" 2>/dev/null &
    elif command -v alacritty &>/dev/null; then
        alacritty -e bash -c "virsh console $vm_name; exec bash" 2>/dev/null &
    elif command -v kitty &>/dev/null; then
        kitty bash -c "virsh console $vm_name; exec bash" 2>/dev/null &
    else
        log_warn "Terminal graphique non détecté, utilisation de la console actuelle"
        virsh console "$vm_name"
    fi
    
    log_info "Console de $vm_name ouverte dans un nouveau terminal"
    log_info "Utilisez Ctrl+] pour quitter la console"
}

# Fonction pour ouvrir virt-viewer dans un nouveau terminal
open_vm_viewer_terminal() {
    local vm_name="$1"
    
    if [ -z "$vm_name" ]; then
        log_error "Nom de VM requis"
        return 1
    fi
    
    if command -v virt-viewer &>/dev/null; then
        virt-viewer "$vm_name" &
        log_info "Virt-viewer ouvert pour $vm_name"
    else
        log_warn "virt-viewer non installé"
        log_info "Installez-le: sudo pacman -S virt-viewer"
    fi
}

# Menu principal
show_main_menu() {
    show_header
    
    # Afficher l'état actuel des VMs
    list_vms
    
    echo -e "${YELLOW}🖥️  OPTIONS DISPONIBLES:${NC}"
    echo ""
    echo "1.  📋 Lister les VMs (rafraîchir)"
    echo "2.  ▶️  Démarrer une VM (avec confirmation)"
    echo "3.  ⏹️  Arrêter une VM"
    echo "4.  🔄 Redémarrer une VM"
    echo "5.  ⏸️  Suspendre/Reprendre une VM"
    echo "6.  📊 Informations détaillées sur une VM"
    echo "7.  🖥️  Console VM (terminal actuel)"
    echo "8.  🖥️  Console VM (nouveau terminal)"
    echo "9.  🎨 Virt-viewer (interface graphique)"
    echo "10. 📸 Gérer les snapshots"
    echo "11. 📈 Monitoring et statistiques"
    echo "12. 🔧 Gérer les réseaux libvirt"
    echo "13. ➕ Créer une nouvelle VM"
    echo "14. 🗑️  Supprimer une VM"
    echo "15. 🔍 Rechercher une VM"
    echo "16. ⚙️  Configuration et maintenance"
    echo ""
    echo "0.  Retour au menu principal"
    echo ""
    printf "Choix: "
    read -r choice
    choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
    
    case "$choice" in
        1)
            list_vms
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        2)
            log_info "Démarrage d'une VM..."
            list_vms
            echo ""
            printf "Nom de la VM à démarrer: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            # Vérifier si la VM existe
            if ! virsh dominfo "$vm_name" &>/dev/null; then
                log_error "VM '$vm_name' introuvable"
                sleep 2
                return
            fi
            
            # Vérifier si déjà démarrée
            if virsh list --name | grep -q "^${vm_name}$"; then
                log_warn "La VM '$vm_name' est déjà démarrée"
                sleep 2
                return
            fi
            
            # Demander confirmation
            echo ""
            printf "${YELLOW}Voulez-vous démarrer la VM '$vm_name' maintenant? (O/n): ${NC}"
            read -r confirm
            confirm=${confirm:-O}
            
            if [[ "$confirm" =~ ^[oO]$ ]]; then
                log_info "Démarrage de $vm_name..."
                if virsh start "$vm_name"; then
                    log_info "✓ VM '$vm_name' démarrée avec succès"
                    sleep 2
                else
                    log_error "Échec du démarrage de '$vm_name'"
                    sleep 2
                fi
            else
                log_info "Démarrage annulé"
                sleep 1
            fi
            ;;
        3)
            log_info "Arrêt d'une VM..."
            virsh list
            echo ""
            printf "Nom de la VM à arrêter: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            printf "Arrêt gracieux (O) ou forcé (f)? [O]: "
            read -r shutdown_type
            shutdown_type=${shutdown_type:-O}
            
            if [[ "$shutdown_type" =~ ^[fF]$ ]]; then
                log_warn "Arrêt forcé de $vm_name..."
                virsh destroy "$vm_name"
            else
                log_info "Arrêt gracieux de $vm_name..."
                virsh shutdown "$vm_name"
            fi
            
            if [ $? -eq 0 ]; then
                log_info "✓ VM arrêtée"
                sleep 2
            fi
            ;;
        4)
            log_info "Redémarrage d'une VM..."
            virsh list
            echo ""
            printf "Nom de la VM à redémarrer: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            printf "${YELLOW}Redémarrer '$vm_name' maintenant? (O/n): ${NC}"
            read -r confirm
            confirm=${confirm:-O}
            
            if [[ "$confirm" =~ ^[oO]$ ]]; then
                virsh reboot "$vm_name"
                if [ $? -eq 0 ]; then
                    log_info "✓ VM redémarrée"
                    sleep 2
                fi
            else
                log_info "Redémarrage annulé"
                sleep 1
            fi
            ;;
        5)
            log_info "Suspendre/Reprendre une VM..."
            virsh list
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            echo ""
            echo "1. Suspendre (pause)"
            echo "2. Reprendre (resume)"
            printf "Choix [1-2]: "
            read -r suspend_choice
            
            case "$suspend_choice" in
                1)
                    virsh suspend "$vm_name"
                    log_info "✓ VM suspendue"
                    sleep 2
                    ;;
                2)
                    virsh resume "$vm_name"
                    log_info "✓ VM reprise"
                    sleep 2
                    ;;
                *)
                    log_error "Choix invalide"
                    sleep 1
                    ;;
            esac
            ;;
        6)
            log_info "Informations sur une VM..."
            virsh list --all
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            echo ""
            echo -e "${CYAN}📊 Informations de base:${NC}"
            virsh dominfo "$vm_name" 2>/dev/null || {
                log_error "VM '$vm_name' introuvable"
                sleep 2
                return
            }
            echo ""
            echo -e "${CYAN}📈 Statistiques:${NC}"
            virsh domstats "$vm_name" 2>/dev/null || true
            echo ""
            echo -e "${CYAN}🌐 Interfaces réseau:${NC}"
            virsh domiflist "$vm_name" 2>/dev/null || true
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        7)
            log_info "Accès console d'une VM (terminal actuel)..."
            virsh list
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            # Vérifier que la VM est démarrée
            if ! virsh list --name | grep -q "^${vm_name}$"; then
                log_warn "La VM '$vm_name' n'est pas démarrée"
                printf "Voulez-vous la démarrer maintenant? (O/n): "
                read -r start_confirm
                start_confirm=${start_confirm:-O}
                if [[ "$start_confirm" =~ ^[oO]$ ]]; then
                    virsh start "$vm_name"
                    sleep 3
                else
                    return
                fi
            fi
            
            log_info "Connexion à la console de $vm_name..."
            log_info "Utilisez Ctrl+] pour quitter"
            echo ""
            virsh console "$vm_name"
            ;;
        8)
            log_info "Ouvrir console dans un nouveau terminal..."
            virsh list
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            # Vérifier que la VM est démarrée
            if ! virsh list --name | grep -q "^${vm_name}$"; then
                log_warn "La VM '$vm_name' n'est pas démarrée"
                printf "Voulez-vous la démarrer maintenant? (O/n): "
                read -r start_confirm
                start_confirm=${start_confirm:-O}
                if [[ "$start_confirm" =~ ^[oO]$ ]]; then
                    virsh start "$vm_name"
                    sleep 3
                else
                    return
                fi
            fi
            
            open_vm_console_terminal "$vm_name"
            sleep 2
            ;;
        9)
            log_info "Ouvrir virt-viewer (interface graphique)..."
            virsh list
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            # Vérifier que la VM est démarrée
            if ! virsh list --name | grep -q "^${vm_name}$"; then
                log_warn "La VM '$vm_name' n'est pas démarrée"
                printf "Voulez-vous la démarrer maintenant? (O/n): "
                read -r start_confirm
                start_confirm=${start_confirm:-O}
                if [[ "$start_confirm" =~ ^[oO]$ ]]; then
                    virsh start "$vm_name"
                    sleep 3
                else
                    return
                fi
            fi
            
            open_vm_viewer_terminal "$vm_name"
            sleep 2
            ;;
        10)
            log_info "Gestion des snapshots..."
            virsh list --all
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            echo ""
            echo "1. Lister les snapshots"
            echo "2. Créer un snapshot"
            echo "3. Restaurer un snapshot"
            echo "4. Supprimer un snapshot"
            echo "5. Informations sur un snapshot"
            printf "Choix [1-5]: "
            read -r snapshot_choice
            
            case "$snapshot_choice" in
                1)
                    echo ""
                    virsh snapshot-list "$vm_name" 2>/dev/null || log_warn "Aucun snapshot trouvé"
                    ;;
                2)
                    printf "Nom du snapshot: "
                    read -r snapshot_name
                    printf "Description (optionnel): "
                    read -r snapshot_desc
                    snapshot_desc=${snapshot_desc:-"Snapshot créé le $(date)"}
                    
                    virsh snapshot-create-as "$vm_name" "$snapshot_name" --description "$snapshot_desc"
                    if [ $? -eq 0 ]; then
                        log_info "✓ Snapshot '$snapshot_name' créé"
                    fi
                    ;;
                3)
                    virsh snapshot-list "$vm_name" 2>/dev/null
                    echo ""
                    printf "Nom du snapshot à restaurer: "
                    read -r snapshot_name
                    
                    printf "${YELLOW}Restaurer le snapshot '$snapshot_name'? (O/n): ${NC}"
                    read -r confirm
                    confirm=${confirm:-O}
                    
                    if [[ "$confirm" =~ ^[oO]$ ]]; then
                        virsh snapshot-revert "$vm_name" "$snapshot_name"
                        if [ $? -eq 0 ]; then
                            log_info "✓ Snapshot restauré"
                        fi
                    fi
                    ;;
                4)
                    virsh snapshot-list "$vm_name" 2>/dev/null
                    echo ""
                    printf "Nom du snapshot à supprimer: "
                    read -r snapshot_name
                    
                    printf "${YELLOW}Supprimer le snapshot '$snapshot_name'? (O/n): ${NC}"
                    read -r confirm
                    confirm=${confirm:-O}
                    
                    if [[ "$confirm" =~ ^[oO]$ ]]; then
                        virsh snapshot-delete "$vm_name" "$snapshot_name"
                        if [ $? -eq 0 ]; then
                            log_info "✓ Snapshot supprimé"
                        fi
                    fi
                    ;;
                5)
                    virsh snapshot-list "$vm_name" 2>/dev/null
                    echo ""
                    printf "Nom du snapshot: "
                    read -r snapshot_name
                    
                    virsh snapshot-info "$vm_name" "$snapshot_name" 2>/dev/null || log_error "Snapshot introuvable"
                    ;;
            esac
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        11)
            log_info "Monitoring et statistiques..."
            virsh list
            echo ""
            printf "Nom de la VM: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            echo ""
            echo -e "${CYAN}📊 Statistiques en temps réel:${NC}"
            virsh domstats "$vm_name" 2>/dev/null || log_warn "Statistiques non disponibles"
            echo ""
            echo -e "${CYAN}💾 Utilisation disque:${NC}"
            virsh domblklist "$vm_name" 2>/dev/null || true
            echo ""
            echo -e "${CYAN}🌐 Interfaces réseau:${NC}"
            virsh domiflist "$vm_name" 2>/dev/null || true
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        12)
            log_info "Gestion des réseaux libvirt..."
            echo ""
            echo "1. Lister les réseaux"
            echo "2. Démarrer un réseau"
            echo "3. Arrêter un réseau"
            echo "4. Informations sur un réseau"
            echo "5. Activer auto-démarrage d'un réseau"
            printf "Choix [1-5]: "
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
                    if [ $? -eq 0 ]; then
                        log_info "✓ Réseau démarré"
                    fi
                    ;;
                3)
                    virsh net-list
                    echo ""
                    printf "Nom du réseau: "
                    read -r net_name
                    virsh net-destroy "$net_name"
                    if [ $? -eq 0 ]; then
                        log_info "✓ Réseau arrêté"
                    fi
                    ;;
                4)
                    virsh net-list
                    echo ""
                    printf "Nom du réseau: "
                    read -r net_name
                    virsh net-info "$net_name"
                    ;;
                5)
                    virsh net-list --all
                    echo ""
                    printf "Nom du réseau: "
                    read -r net_name
                    virsh net-autostart "$net_name"
                    if [ $? -eq 0 ]; then
                        log_info "✓ Auto-démarrage activé pour '$net_name'"
                    fi
                    ;;
            esac
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        13)
            log_info "Création d'une nouvelle VM..."
            echo ""
            log_warn "Pour créer une VM, vous pouvez utiliser:"
            echo ""
            echo "1. virt-manager (interface graphique):"
            echo "   virt-manager"
            echo ""
            echo "2. virt-install (ligne de commande):"
            echo "   virt-install --name ma-vm --ram 2048 \\"
            echo "     --disk path=/var/lib/libvirt/images/ma-vm.qcow2,size=20 \\"
            echo "     --cdrom /path/to/iso --graphics vnc"
            echo ""
            echo "3. Via virtman (à venir)"
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        14)
            log_info "Suppression d'une VM..."
            virsh list --all
            echo ""
            printf "Nom de la VM à supprimer: "
            read -r vm_name
            
            if [ -z "$vm_name" ]; then
                log_error "Nom de VM requis"
                sleep 2
                return
            fi
            
            printf "${RED}⚠️  Confirmer la suppression de '$vm_name'? (o/N): ${NC}"
            read -r confirm
            
            if [[ "$confirm" =~ ^[oO]$ ]]; then
                # Arrêter la VM si elle tourne
                if virsh list --name | grep -q "^${vm_name}$"; then
                    log_warn "Arrêt de la VM..."
                    virsh destroy "$vm_name" 2>/dev/null
                fi
                
                # Supprimer les snapshots
                printf "Supprimer aussi les snapshots? (o/N): "
                read -r del_snapshots
                if [[ "$del_snapshots" =~ ^[oO]$ ]]; then
                    for snapshot in $(virsh snapshot-list "$vm_name" --name 2>/dev/null); do
                        virsh snapshot-delete "$vm_name" "$snapshot" 2>/dev/null
                    done
                fi
                
                # Supprimer la VM
                virsh undefine "$vm_name"
                if [ $? -eq 0 ]; then
                    log_info "✓ VM supprimée"
                else
                    log_error "Échec de la suppression"
                fi
            else
                log_info "Suppression annulée"
            fi
            sleep 2
            ;;
        15)
            log_info "Rechercher une VM..."
            printf "Terme de recherche: "
            read -r search_term
            
            if [ -z "$search_term" ]; then
                log_error "Terme de recherche requis"
                sleep 2
                return
            fi
            
            echo ""
            echo -e "${CYAN}Résultats:${NC}"
            virsh list --all --name | grep -i "$search_term" || log_warn "Aucune VM trouvée"
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        16)
            log_info "Configuration et maintenance..."
            echo ""
            echo "1. Vérifier le statut de libvirtd"
            echo "2. Démarrer/Arrêter libvirtd"
            echo "3. Informations système libvirt"
            echo "4. Lister les pools de stockage"
            echo "5. Informations sur un pool"
            printf "Choix [1-5]: "
            read -r config_choice
            
            case "$config_choice" in
                1)
                    systemctl status libvirtd --no-pager
                    ;;
                2)
                    echo ""
                    echo "1. Démarrer libvirtd"
                    echo "2. Arrêter libvirtd"
                    echo "3. Redémarrer libvirtd"
                    printf "Choix [1-3]: "
                    read -r service_choice
                    
                    case "$service_choice" in
                        1) sudo systemctl start libvirtd && log_info "✓ libvirtd démarré" ;;
                        2) sudo systemctl stop libvirtd && log_info "✓ libvirtd arrêté" ;;
                        3) sudo systemctl restart libvirtd && log_info "✓ libvirtd redémarré" ;;
                    esac
                    ;;
                3)
                    virsh version
                    echo ""
                    virsh sysinfo 2>/dev/null || true
                    ;;
                4)
                    virsh pool-list --all
                    ;;
                5)
                    virsh pool-list --all
                    echo ""
                    printf "Nom du pool: "
                    read -r pool_name
                    virsh pool-info "$pool_name" 2>/dev/null || log_error "Pool introuvable"
                    ;;
            esac
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            ;;
        0)
            return 0
            ;;
        *)
            log_error "Choix invalide"
            sleep 1
            ;;
    esac
}

# Vérifier que libvirt est installé
if ! command -v virsh >/dev/null 2>&1; then
    log_error "libvirt n'est pas installé!"
    echo "Installez avec: installman network-tools"
    return 1 2>/dev/null || exit 1
fi

# Vérifier que libvirtd est démarré
if ! systemctl is-active --quiet libvirtd 2>/dev/null; then
    log_warn "libvirtd n'est pas démarré"
    printf "Voulez-vous le démarrer maintenant? (O/n): "
    read -r start_libvirtd
    start_libvirtd=${start_libvirtd:-O}
    if [[ "$start_libvirtd" =~ ^[oO]$ ]]; then
        sudo systemctl start libvirtd
        if [ $? -eq 0 ]; then
            log_info "✓ libvirtd démarré"
        else
            log_error "Impossible de démarrer libvirtd"
            return 1 2>/dev/null || exit 1
        fi
    fi
fi

# Menu principal en boucle
while true; do
    show_main_menu
done
