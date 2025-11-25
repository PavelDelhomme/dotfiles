#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour Docker
# =============================================================================

# DESC: Build une image Docker
# USAGE: docker_build [tag] [dockerfile_path]
# EXAMPLE: docker_build
docker_build() {
    local tag="${1:-latest}"
    local dockerfile="${2:-Dockerfile}"
    local context="${3:-.}"
    
    echo "🔨 Build Docker: $tag"
    docker build -t "$tag" -f "$dockerfile" "$context" || { echo "❌ Build échoué"; return 1; }
    echo "✅ Build réussi: $tag"
}

# DESC: Push une image Docker
# USAGE: docker_push <image:tag>
# EXAMPLE: docker_push
docker_push() {
    local image="$1"
    
    if [[ -z "$image" ]]; then
        echo "❌ Usage: docker_push <image:tag>"
        return 1
    fi
    
    echo "⬆️  Push Docker: $image"
    docker push "$image" || { echo "❌ Push échoué"; return 1; }
    echo "✅ Push réussi: $image"
}

# DESC: Build et push une image Docker
# USAGE: docker_build_push <image:tag> [dockerfile_path]
# EXAMPLE: docker_build_push
docker_build_push() {
    local image="$1"
    local dockerfile="${2:-Dockerfile}"
    
    if [[ -z "$image" ]]; then
        echo "❌ Usage: docker_build_push <image:tag> [dockerfile]"
        return 1
    fi
    
    docker_build "$image" "$dockerfile" && docker_push "$image"
}

# DESC: Nettoie Docker (images, conteneurs, volumes non utilisés)
# USAGE: docker_cleanup [--all]
# EXAMPLE: docker_cleanup
docker_cleanup() {
    local all="$1"
    
    echo "🧹 Cleanup Docker"
    
    # Conteneurs arrêtés
    docker container prune -f
    
    # Images dangling
    docker image prune -f
    
    # Volumes non utilisés
    docker volume prune -f
    
    # Networks non utilisés
    docker network prune -f
    
    # Si --all, nettoyer aussi les images non utilisées
    if [[ "$all" == "--all" ]]; then
        docker image prune -a -f
        echo "✅ Cleanup complet terminé"
    else
        echo "✅ Cleanup terminé (utilisez --all pour nettoyer aussi les images non utilisées)"
    fi
}

# DESC: Affiche les logs d'un conteneur
# USAGE: docker_logs <container_name> [--follow]
# EXAMPLE: docker_logs mycontainer
docker_logs() {
    local container="$1"
    local follow="$2"
    
    if [[ -z "$container" ]]; then
        echo "❌ Usage: docker_logs <container_name> [--follow]"
        return 1
    fi
    
    if [[ "$follow" == "--follow" ]] || [[ "$follow" == "-f" ]]; then
        docker logs -f "$container"
    else
        docker logs "$container"
    fi
}

# DESC: Execute une commande dans un conteneur
# USAGE: docker_exec <container_name> <command>
# EXAMPLE: docker_exec mycontainer
docker_exec() {
    local container="$1"
    shift
    
    if [[ -z "$container" ]] || [[ -z "$*" ]]; then
        echo "❌ Usage: docker_exec <container_name> <command>"
        return 1
    fi
    
    docker exec -it "$container" "$@"
}

# DESC: Affiche l'utilisation des ressources Docker
# USAGE: docker_stats [container_name]
# EXAMPLE: docker_stats
docker_stats() {
    local container="$1"
    
    if [[ -n "$container" ]]; then
        docker stats "$container"
    else
        docker stats --no-stream
    fi
}

# DESC: Redémarre un conteneur
# USAGE: docker_restart <container_name>
# EXAMPLE: docker_restart mycontainer
docker_restart() {
    local container="$1"
    
    if [[ -z "$container" ]]; then
        echo "❌ Usage: docker_restart <container_name>"
        return 1
    fi
    
    echo "🔄 Restart: $container"
    docker restart "$container" && echo "✅ Conteneur redémarré"
}

# DESC: Docker Compose up -d
# USAGE: docker_compose_up [compose_file]
# EXAMPLE: docker_compose_up
docker_compose_up() {
    local compose_file="${1:-docker-compose.yml}"
    
    echo "🚀 Docker Compose up: $compose_file"
    docker compose -f "$compose_file" up -d || { echo "❌ Échec"; return 1; }
    echo "✅ Services démarrés"
}

# DESC: Docker Compose down
# USAGE: docker_compose_down [compose_file]
# EXAMPLE: docker_compose_down
docker_compose_down() {
    local compose_file="${1:-docker-compose.yml}"
    
    echo "🛑 Docker Compose down: $compose_file"
    docker compose -f "$compose_file" down || { echo "❌ Échec"; return 1; }
    echo "✅ Services arrêtés"
}

# DESC: Docker Compose logs
# USAGE: docker_compose_logs [service_name] [--follow]
# EXAMPLE: docker_compose_logs
docker_compose_logs() {
    local service="$1"
    local follow="$2"
    local compose_file="${3:-docker-compose.yml}"
    
    if [[ "$service" == "--follow" ]] || [[ "$service" == "-f" ]]; then
        docker compose -f "$compose_file" logs -f
    elif [[ "$follow" == "--follow" ]] || [[ "$follow" == "-f" ]]; then
        docker compose -f "$compose_file" logs -f "$service"
    elif [[ -n "$service" ]]; then
        docker compose -f "$compose_file" logs "$service"
    else
        docker compose -f "$compose_file" logs
    fi
}

# DESC: Liste les images Docker
# USAGE: docker_images [filter]
# EXAMPLE: docker_images
docker_images() {
    local filter="$1"
    
    if [[ -n "$filter" ]]; then
        docker images | grep "$filter"
    else
        docker images
    fi
}

# DESC: Liste les conteneurs Docker
# USAGE: docker_ps [--all]
# EXAMPLE: docker_ps
docker_ps() {
    if [[ "$1" == "--all" ]] || [[ "$1" == "-a" ]]; then
        docker ps -a
    else
        docker ps
    fi
}

