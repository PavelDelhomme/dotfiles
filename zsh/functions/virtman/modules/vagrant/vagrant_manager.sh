#!/bin/bash

################################################################################
# Vagrant Manager - Gestion des VMs Vagrant
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman vagrant'
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

log_section "Gestionnaire Vagrant"

# Vérifier que Vagrant est installé
if ! command -v vagrant >/dev/null 2>&1; then
    log_error "Vagrant n'est pas installé!"
    echo "Installez avec: sudo pacman -S vagrant (Arch) ou sudo apt install vagrant (Debian)"
    return 1 2>/dev/null || exit 1
fi

echo ""
echo "Options disponibles:"
echo "1. Lister les VMs Vagrant"
echo "2. Initialiser un nouveau projet Vagrant"
echo "3. Démarrer une VM Vagrant"
echo "4. Arrêter une VM Vagrant"
echo "5. Suspendre/Reprendre une VM"
echo "6. Redémarrer une VM"
echo "7. Accéder au shell d'une VM (SSH)"
echo "8. Provisionner une VM"
echo "9. Détruire une VM"
echo "0. Retour"
echo ""
printf "Choix [0-9]: "
read -r choice

case "$choice" in
    1)
        log_info "Liste des VMs Vagrant..."
        vagrant global-status
        ;;
    2)
        log_info "Initialisation d'un nouveau projet Vagrant..."
        printf "Répertoire du projet: "
        read -r project_dir
        
        if [ ! -d "$project_dir" ]; then
            printf "Créer le répertoire? (o/n): "
            read -r create_dir
            if [[ "$create_dir" =~ ^[oO]$ ]]; then
                mkdir -p "$project_dir"
            else
                log_error "Répertoire introuvable"
                return 1 2>/dev/null || exit 1
            fi
        fi
        
        printf "Box Vagrant (ex: ubuntu/focal64) [hashicorp/bionic64]: "
        read -r box_name
        box_name="${box_name:-hashicorp/bionic64}"
        
        cd "$project_dir"
        vagrant init "$box_name"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Projet Vagrant initialisé"
            log_info "Éditez Vagrantfile puis: vagrant up"
        fi
        ;;
    3)
        log_info "Démarrage d'une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            vagrant up
            if [ $? -eq 0 ]; then
                log_info "✓ VM démarrée"
            fi
        else
            log_error "Vagrantfile introuvable dans $project_dir"
        fi
        ;;
    4)
        log_info "Arrêt d'une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            vagrant halt
            if [ $? -eq 0 ]; then
                log_info "✓ VM arrêtée"
            fi
        else
            log_error "Vagrantfile introuvable"
        fi
        ;;
    5)
        log_info "Suspendre/Reprendre une VM..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        echo ""
        echo "1. Suspendre"
        echo "2. Reprendre"
        printf "Choix [1-2]: "
        read -r suspend_choice
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            case "$suspend_choice" in
                1)
                    vagrant suspend
                    log_info "✓ VM suspendue"
                    ;;
                2)
                    vagrant resume
                    log_info "✓ VM reprise"
                    ;;
            esac
        else
            log_error "Vagrantfile introuvable"
        fi
        ;;
    6)
        log_info "Redémarrage d'une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            vagrant reload
            if [ $? -eq 0 ]; then
                log_info "✓ VM redémarrée"
            fi
        else
            log_error "Vagrantfile introuvable"
        fi
        ;;
    7)
        log_info "Accès SSH à une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            log_info "Connexion SSH..."
            vagrant ssh
        else
            log_error "Vagrantfile introuvable"
        fi
        ;;
    8)
        log_info "Provisionnement d'une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            cd "$project_dir"
            vagrant provision
            if [ $? -eq 0 ]; then
                log_info "✓ VM provisionnée"
            fi
        else
            log_error "Vagrantfile introuvable"
        fi
        ;;
    9)
        log_info "Destruction d'une VM Vagrant..."
        printf "Répertoire du projet Vagrant [$(pwd)]: "
        read -r project_dir
        project_dir="${project_dir:-$(pwd)}"
        
        if [ -f "$project_dir/Vagrantfile" ]; then
            printf "Confirmer la destruction? (o/n): "
            read -r confirm
            
            if [[ "$confirm" =~ ^[oO]$ ]]; then
                cd "$project_dir"
                vagrant destroy -f
                if [ $? -eq 0 ]; then
                    log_info "✓ VM détruite"
                fi
            fi
        else
            log_error "Vagrantfile introuvable"
        fi
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

