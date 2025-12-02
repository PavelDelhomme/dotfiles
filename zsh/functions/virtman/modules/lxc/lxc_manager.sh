#!/bin/bash

################################################################################
# LXC Manager - Gestion des conteneurs LXC
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman lxc'
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

log_section "Gestionnaire LXC"

# Vérifier que LXC est installé
if ! command -v lxc >/dev/null 2>&1 && ! command -v lxc-ls >/dev/null 2>&1; then
    log_error "LXC n'est pas installé!"
    echo "Installez avec: sudo pacman -S lxc (Arch) ou sudo apt install lxc (Debian)"
    return 1 2>/dev/null || exit 1
fi

# Détecter la version de LXC
if command -v lxc >/dev/null 2>&1; then
    LXC_CMD="lxc"
    LXC_VERSION="3+"
else
    LXC_CMD="lxc-"
    LXC_VERSION="2"
fi

echo ""
echo "Options disponibles:"
echo "1. Lister les conteneurs"
echo "2. Créer un conteneur"
echo "3. Démarrer un conteneur"
echo "4. Arrêter un conteneur"
echo "5. Exécuter une commande dans un conteneur"
echo "6. Accéder au shell d'un conteneur"
echo "7. Informations sur un conteneur"
echo "8. Supprimer un conteneur"
echo "0. Retour"
echo ""
printf "Choix [0-8]: "
read -r choice

case "$choice" in
    1)
        log_info "Liste des conteneurs LXC..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list
        else
            lxc-ls -f
        fi
        ;;
    2)
        log_info "Création d'un conteneur LXC..."
        printf "Nom du conteneur: "
        read -r container_name
        
        printf "Distribution (ubuntu, debian, archlinux, etc.): "
        read -r distro
        distro="${distro:-ubuntu}"
        
        printf "Version/Release (ex: focal, buster) [latest]: "
        read -r release
        release="${release:-latest}"
        
        if [ "$LXC_VERSION" = "3+" ]; then
            log_info "Création du conteneur..."
            lxc launch "$distro:$release" "$container_name"
        else
            log_info "Création du conteneur..."
            lxc-create -t download -n "$container_name" -- --dist "$distro" --release "$release" --arch amd64
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur créé"
        fi
        ;;
    3)
        log_info "Démarrage d'un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n,s | grep STOPPED || echo "Aucun conteneur arrêté"
        else
            lxc-ls --stopped
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc start "$container_name"
        else
            lxc-start -n "$container_name" -d
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur démarré"
        fi
        ;;
    4)
        log_info "Arrêt d'un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n,s | grep RUNNING || echo "Aucun conteneur en cours"
        else
            lxc-ls --running
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc stop "$container_name"
        else
            lxc-stop -n "$container_name"
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur arrêté"
        fi
        ;;
    5)
        log_info "Exécution d'une commande dans un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n | grep -v NAME
        else
            lxc-ls
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        printf "Commande à exécuter: "
        read -r cmd
        
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc exec "$container_name" -- $cmd
        else
            lxc-attach -n "$container_name" -- $cmd
        fi
        ;;
    6)
        log_info "Accès au shell d'un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n | grep -v NAME
        else
            lxc-ls
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        log_info "Connexion au shell..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc exec "$container_name" -- /bin/bash
        else
            lxc-attach -n "$container_name"
        fi
        ;;
    7)
        log_info "Informations sur un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n | grep -v NAME
        else
            lxc-ls
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc info "$container_name"
        else
            lxc-info -n "$container_name"
        fi
        ;;
    8)
        log_info "Suppression d'un conteneur..."
        if [ "$LXC_VERSION" = "3+" ]; then
            lxc list --format csv -c n | grep -v NAME
        else
            lxc-ls
        fi
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        printf "Confirmer la suppression? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            if [ "$LXC_VERSION" = "3+" ]; then
                lxc delete "$container_name"
            else
                lxc-stop -n "$container_name" 2>/dev/null
                lxc-destroy -n "$container_name"
            fi
            
            if [ $? -eq 0 ]; then
                log_info "✓ Conteneur supprimé"
            fi
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

