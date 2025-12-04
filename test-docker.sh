#!/bin/bash
# Script pour tester l'installation complète des dotfiles dans Docker
# Environnement complètement isolé

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }

# Préfixe unique pour isoler des autres conteneurs Docker
DOTFILES_PREFIX="dotfiles-test"
CONTAINER_NAME="${DOTFILES_PREFIX}-auto"
IMAGE_NAME="${DOTFILES_PREFIX}:auto"

# Demander si on veut nettoyer les images existantes
echo ""
echo -e "${YELLOW}⚠️  Image Docker existante détectée${NC}"
read -p "Voulez-vous nettoyer les images Docker existantes avant de reconstruire? (o/N): " clean_choice
clean_choice=${clean_choice:-n}

if [[ "$clean_choice" =~ ^[oO]$ ]]; then
    log_step "Nettoyage UNIQUEMENT des conteneurs et images dotfiles-test..."
    # Nettoyer uniquement les conteneurs avec notre préfixe
    CONTAINERS=$(docker ps -a --filter "name=${DOTFILES_PREFIX}" --format "{{.Names}}" 2>/dev/null || true)
    if [ -n "$CONTAINERS" ]; then
        echo "$CONTAINERS" | xargs -r docker stop 2>/dev/null || true
        echo "$CONTAINERS" | xargs -r docker rm 2>/dev/null || true
        log_info "✓ Conteneurs nettoyés"
    fi
    # Nettoyer uniquement les images avec notre préfixe
    IMAGES=$(docker images --filter "reference=${DOTFILES_PREFIX}*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
    if [ -n "$IMAGES" ]; then
        echo "$IMAGES" | xargs -r docker rmi 2>/dev/null || true
        log_info "✓ Images nettoyées"
    fi
    # Nettoyer aussi les images avec le tag exact
    docker rmi "${IMAGE_NAME}" 2>/dev/null || true
    log_info "✅ Nettoyage terminé"
else
    log_info "ℹ️  Nettoyage ignoré, utilisation des images existantes si disponibles"
fi

# Demander quels managers activer
echo ""
echo -e "${CYAN}📦 SÉLECTION DES MANAGERS À ACTIVER${NC}"
echo -e "${YELLOW}Quels managers voulez-vous activer dans Docker?${NC}"
echo ""
echo "Managers disponibles:"
echo "  1) pathman      - Gestionnaire PATH"
echo "  2) netman       - Gestionnaire réseau"
echo "  3) aliaman      - Gestionnaire alias"
echo "  4) miscman      - Gestionnaire divers"
echo "  5) searchman    - Gestionnaire recherche"
echo "  6) cyberman     - Gestionnaire cybersécurité"
echo "  7) devman       - Gestionnaire développement"
echo "  8) gitman       - Gestionnaire Git"
echo "  9) helpman      - Gestionnaire aide/documentation"
echo " 10) manman       - Manager of Managers"
echo " 11) configman    - Gestionnaire configuration"
echo " 12) installman   - Gestionnaire installation"
echo " 13) moduleman    - Gestionnaire modules"
echo " 14) fileman      - Gestionnaire fichiers"
echo " 15) virtman      - Gestionnaire virtualisation"
echo " 16) sshman       - Gestionnaire SSH"
echo ""
echo -e "${YELLOW}Format: numéros séparés par des espaces (ex: 1 2 3 6 7 9)${NC}"
echo -e "${YELLOW}Ou 'all' pour tout activer, 'none' pour rien activer${NC}"
read -p "Votre choix: " managers_choice
managers_choice=${managers_choice:-all}

# Créer un fichier temporaire avec la configuration des managers
MANAGERS_CONFIG=$(mktemp)
cat > "$MANAGERS_CONFIG" << 'EOF'
# Configuration des modules - Moduleman
# Format compatible Zsh et Fish
# Zsh: MODULE_<nom>=enabled|disabled
# Fish: set -g MODULE_<nom> enabled|disabled
EOF

# Liste des managers avec leurs numéros
declare -A MANAGER_MAP=(
    ["1"]="pathman"
    ["2"]="netman"
    ["3"]="aliaman"
    ["4"]="miscman"
    ["5"]="searchman"
    ["6"]="cyberman"
    ["7"]="devman"
    ["8"]="gitman"
    ["9"]="helpman"
    ["10"]="manman"
    ["11"]="configman"
    ["12"]="installman"
    ["13"]="moduleman"
    ["14"]="fileman"
    ["15"]="virtman"
    ["16"]="sshman"
)

# Traiter le choix
if [[ "$managers_choice" == "all" ]]; then
    # Activer tous les managers
    for manager in "${MANAGER_MAP[@]}"; do
        echo "MODULE_${manager}=enabled" >> "$MANAGERS_CONFIG"
    done
    log_info "✓ Tous les managers seront activés"
elif [[ "$managers_choice" == "none" ]]; then
    # Désactiver tous les managers
    for manager in "${MANAGER_MAP[@]}"; do
        echo "MODULE_${manager}=disabled" >> "$MANAGERS_CONFIG"
    done
    log_info "✓ Aucun manager ne sera activé"
else
    # Activer seulement les managers sélectionnés
    for num in $managers_choice; do
        if [[ -n "${MANAGER_MAP[$num]}" ]]; then
            echo "MODULE_${MANAGER_MAP[$num]}=enabled" >> "$MANAGERS_CONFIG"
            log_info "✓ ${MANAGER_MAP[$num]} sera activé"
        fi
    done
    # Désactiver les autres
    for num in "${!MANAGER_MAP[@]}"; do
        if [[ ! " $managers_choice " =~ " $num " ]]; then
            echo "MODULE_${MANAGER_MAP[$num]}=disabled" >> "$MANAGERS_CONFIG"
        fi
    done
fi

log_step "Construction de l'image Docker avec installation automatique (isolée)..."
# Utiliser --load pour charger l'image dans Docker (nécessaire avec BuildKit)
# Passer le fichier de configuration des managers comme build arg
docker build --load \
    --build-arg MANAGERS_CONFIG="$(cat "$MANAGERS_CONFIG")" \
    -f Dockerfile.test \
    -t "$IMAGE_NAME" . || {
    log_error "Échec de la construction de l'image"
    rm -f "$MANAGERS_CONFIG"
    exit 1
}
rm -f "$MANAGERS_CONFIG"
log_info "✅ Image isolée créée: $IMAGE_NAME (ne touche pas vos autres conteneurs)"

log_info "✅ Image construite avec succès"

log_step "Lancement du conteneur avec installation automatique..."
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$(pwd):/root/dotfiles:ro" \
    "$IMAGE_NAME" || {
    log_error "Échec du lancement du conteneur"
    exit 1
}

log_info "✅ Tests terminés !"

