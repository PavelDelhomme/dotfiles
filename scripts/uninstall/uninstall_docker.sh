#!/bin/bash

################################################################################
# Désinstallation Docker & Docker Compose
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation Docker"

log_warn "⚠️  Cette opération va supprimer Docker & Docker Compose"
log_warn "⚠️  Cela inclut :"
echo "  - Docker Engine"
echo "  - Docker Compose"
echo "  - Docker Desktop (si installé)"
echo "  - Conteneurs et images (optionnel)"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

# Détecter la distribution
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    log_error "Distribution non supportée"
    exit 1
fi

# Arrêter Docker
if systemctl is-active --quiet docker 2>/dev/null; then
    log_info "Arrêt de Docker..."
    sudo systemctl stop docker 2>/dev/null
    sudo systemctl disable docker 2>/dev/null
    log_info "✓ Docker arrêté"
fi

# Supprimer conteneurs/images (optionnel)
if command -v docker &> /dev/null; then
    CONTAINERS=$(docker ps -aq 2>/dev/null | wc -l)
    IMAGES=$(docker images -q 2>/dev/null | wc -l)
    
    if [ "$CONTAINERS" -gt 0 ] || [ "$IMAGES" -gt 0 ]; then
        log_warn "⚠️  Conteneurs/images Docker présents ($CONTAINERS conteneurs, $IMAGES images)"
        printf "Supprimer conteneurs et images? (o/n): "
        read -r remove_data
        if [[ "$remove_data" =~ ^[oO]$ ]]; then
            docker stop $(docker ps -aq) 2>/dev/null || true
            docker rm $(docker ps -aq) 2>/dev/null || true
            docker rmi $(docker images -q) 2>/dev/null || true
            docker volume prune -f 2>/dev/null || true
            docker system prune -af --volumes 2>/dev/null || true
            log_info "✓ Conteneurs et images supprimés"
        fi
    fi
fi

# Désinstallation selon la distribution
case "$DISTRO" in
    arch)
        log_info "Suppression Docker (Arch)..."
        sudo pacman -Rns --noconfirm docker docker-compose docker-desktop 2>/dev/null && \
        log_info "✓ Docker supprimé" || log_warn "Impossible de supprimer Docker"
        ;;
    debian)
        log_info "Suppression Docker (Debian/Ubuntu)..."
        sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-desktop 2>/dev/null && \
        log_info "✓ Docker supprimé" || log_warn "Impossible de supprimer Docker"
        
        # Supprimer le dépôt (optionnel)
        log_warn "⚠️  Supprimer aussi le dépôt Docker?"
        printf "Supprimer dépôt? (o/n): "
        read -r remove_repo
        if [[ "$remove_repo" =~ ^[oO]$ ]]; then
            sudo rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null
            sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null
            log_info "✓ Dépôt Docker supprimé"
        fi
        ;;
    fedora)
        log_info "Suppression Docker (Fedora)..."
        sudo dnf remove -y docker docker-compose docker-desktop 2>/dev/null && \
        log_info "✓ Docker supprimé" || log_warn "Impossible de supprimer Docker"
        ;;
esac

# Supprimer le groupe docker (optionnel)
if getent group docker > /dev/null 2>&1; then
    log_warn "⚠️  Supprimer le groupe 'docker'?"
    printf "Supprimer groupe? (o/n): "
    read -r remove_group
    if [[ "$remove_group" =~ ^[oO]$ ]]; then
        sudo groupdel docker 2>/dev/null && log_info "✓ Groupe docker supprimé" || log_warn "Impossible de supprimer groupe"
    fi
fi

# Supprimer les fichiers de configuration (optionnel)
log_warn "⚠️  Supprimer aussi la configuration Docker (~/.docker)?"
printf "Supprimer config? (o/n): "
read -r remove_config
if [[ "$remove_config" =~ ^[oO]$ ]]; then
    rm -rf "$HOME/.docker" 2>/dev/null && log_info "✓ Configuration supprimée" || true
fi

log_info "✅ Désinstallation Docker terminée"

