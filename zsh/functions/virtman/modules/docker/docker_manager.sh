#!/bin/bash

################################################################################
# Docker Manager - Gestion des conteneurs Docker
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman docker'
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

log_section "Gestionnaire Docker"

# Vérifier que Docker est installé
if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker n'est pas installé!"
    echo "Installez avec: installman docker"
    return 1 2>/dev/null || exit 1
fi

echo ""
echo "Options disponibles:"
echo "1. Lister les conteneurs"
echo "2. Créer et démarrer un conteneur"
echo "3. Démarrer un conteneur existant"
echo "4. Arrêter un conteneur"
echo "5. Supprimer un conteneur"
echo "6. Exécuter une commande dans un conteneur"
echo "7. Voir les logs d'un conteneur"
echo "8. Gérer les images Docker"
echo "9. Gérer les volumes"
echo "10. Gérer les réseaux"
echo "0. Retour"
echo ""
printf "Choix [0-10]: "
read -r choice

case "$choice" in
    1)
        log_info "Liste des conteneurs..."
        echo ""
        echo "Conteneurs en cours d'exécution:"
        docker ps
        echo ""
        echo "Tous les conteneurs:"
        docker ps -a
        ;;
    2)
        log_info "Création et démarrage d'un conteneur..."
        printf "Image Docker (ex: ubuntu:latest): "
        read -r image_name
        
        printf "Nom du conteneur: "
        read -r container_name
        
        printf "Commande à exécuter (optionnel, laissez vide pour shell): "
        read -r cmd
        
        printf "Mode interactif? (o/n) [o]: "
        read -r interactive
        interactive="${interactive:-o}"
        
        log_info "Création du conteneur..."
        if [[ "$interactive" =~ ^[oO]$ ]]; then
            if [ -n "$cmd" ]; then
                docker run -it --name "$container_name" "$image_name" $cmd
            else
                docker run -it --name "$container_name" "$image_name"
            fi
        else
            if [ -n "$cmd" ]; then
                docker run -d --name "$container_name" "$image_name" $cmd
            else
                docker run -d --name "$container_name" "$image_name" tail -f /dev/null
            fi
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur créé et démarré"
        fi
        ;;
    3)
        log_info "Démarrage d'un conteneur..."
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        docker start "$container_name"
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur démarré"
        fi
        ;;
    4)
        log_info "Arrêt d'un conteneur..."
        docker ps --format "table {{.Names}}\t{{.Status}}"
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        docker stop "$container_name"
        if [ $? -eq 0 ]; then
            log_info "✓ Conteneur arrêté"
        fi
        ;;
    5)
        log_info "Suppression d'un conteneur..."
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        printf "Confirmer la suppression? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            docker rm "$container_name"
            if [ $? -eq 0 ]; then
                log_info "✓ Conteneur supprimé"
            fi
        fi
        ;;
    6)
        log_info "Exécution d'une commande dans un conteneur..."
        docker ps --format "table {{.Names}}\t{{.Status}}"
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        printf "Commande à exécuter: "
        read -r cmd
        
        docker exec -it "$container_name" $cmd
        ;;
    7)
        log_info "Logs d'un conteneur..."
        docker ps -a --format "table {{.Names}}\t{{.Status}}"
        echo ""
        printf "Nom du conteneur: "
        read -r container_name
        
        docker logs "$container_name" | less
        ;;
    8)
        log_info "Gestion des images Docker..."
        echo ""
        echo "1. Lister les images"
        echo "2. Télécharger une image"
        echo "3. Supprimer une image"
        echo "4. Construire une image depuis Dockerfile"
        printf "Choix [1-4]: "
        read -r img_choice
        
        case "$img_choice" in
            1)
                docker images
                ;;
            2)
                printf "Nom de l'image (ex: ubuntu:latest): "
                read -r image_name
                docker pull "$image_name"
                ;;
            3)
                docker images
                echo ""
                printf "ID ou nom de l'image: "
                read -r image_id
                docker rmi "$image_id"
                ;;
            4)
                printf "Répertoire du Dockerfile: "
                read -r dockerfile_dir
                printf "Nom de l'image à construire: "
                read -r image_name
                docker build -t "$image_name" "$dockerfile_dir"
                ;;
        esac
        ;;
    9)
        log_info "Gestion des volumes Docker..."
        echo ""
        echo "1. Lister les volumes"
        echo "2. Créer un volume"
        echo "3. Supprimer un volume"
        printf "Choix [1-3]: "
        read -r vol_choice
        
        case "$vol_choice" in
            1)
                docker volume ls
                ;;
            2)
                printf "Nom du volume: "
                read -r volume_name
                docker volume create "$volume_name"
                ;;
            3)
                docker volume ls
                echo ""
                printf "Nom du volume: "
                read -r volume_name
                docker volume rm "$volume_name"
                ;;
        esac
        ;;
    10)
        log_info "Gestion des réseaux Docker..."
        echo ""
        echo "1. Lister les réseaux"
        echo "2. Créer un réseau"
        echo "3. Supprimer un réseau"
        printf "Choix [1-3]: "
        read -r net_choice
        
        case "$net_choice" in
            1)
                docker network ls
                ;;
            2)
                printf "Nom du réseau: "
                read -r network_name
                printf "Type (bridge/host/none) [bridge]: "
                read -r network_type
                network_type="${network_type:-bridge}"
                docker network create "$network_name"
                ;;
            3)
                docker network ls
                echo ""
                printf "Nom du réseau: "
                read -r network_name
                docker network rm "$network_name"
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

