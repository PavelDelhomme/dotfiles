#!/bin/bash
# Script pour tester l'installation complète des dotfiles dans Docker
# Environnement complètement isolé.
#
# Usage non interactif :
#   bash scripts/test/test_docker.sh --help
#   bash scripts/test/test_docker.sh --no-clean --managers all --shell zsh
#   bash test-docker.sh --clean --managers pathman,gitman --shell bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }

DOTFILES_PREFIX="dotfiles-test"
CONTAINER_NAME="${DOTFILES_PREFIX}-auto"
IMAGE_NAME="${DOTFILES_PREFIX}:auto"

# Racine du dépôt (script peut être appelé via wrapper racine)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
DOCKERFILE="${DOTFILES_DIR}/Dockerfile.test"

CLEAN_MODE=""          # yes | no | "" (demander si TTY)
MANAGERS_CHOICE=""     # all | none | liste CSV | "" (demander si TTY)
SELECTED_SHELL=""      # zsh | bash | fish | "" (demander si TTY)
ASSUME_YES=0

usage() {
	cat <<'EOF'
test-docker.sh — construire et lancer l'image de test isolée (dotfiles-test)

Usage:
  test-docker.sh [options]
  bash test-docker.sh --help

Options:
  -h, --help              Afficher cette aide et quitter (aucune interaction)
  --clean                 Supprimer conteneurs/images préfixe dotfiles-test avant build
  --no-clean              Garder les images existantes (défaut non-TTY / CI)
  -y, --yes               Mode non interactif : --no-clean + managers=all + shell=zsh
                          si les options correspondantes ne sont pas fournies
  --managers LIST         all | none | noms séparés par des virgules
                          (ex: pathman,gitman,shellman)
  --shell SHELL           zsh | bash | fish (défaut: zsh)

Exemples:
  bash test-docker.sh --help
  bash test-docker.sh --yes
  bash test-docker.sh --no-clean --managers all --shell zsh
  bash test-docker.sh --clean --managers shellman,helpman --shell bash

Notes:
  - Sans options et sur un TTY : menus interactifs (nettoyage seulement si image
    préfixe détectée, puis managers, puis shell).
  - Sans TTY (pipe/CI) : équivalent à --yes (pas de prompts).
  - Préfixe Docker isolé : dotfiles-test (ne touche pas vos autres images).
EOF
}

is_tty() {
	[[ -t 0 && -t 1 ]]
}

existing_dotfiles_images() {
	docker images --filter "reference=${DOTFILES_PREFIX}*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true
}

existing_dotfiles_containers() {
	docker ps -a --filter "name=${DOTFILES_PREFIX}" --format "{{.Names}}" 2>/dev/null || true
}

cleanup_dotfiles_docker() {
	log_step "Nettoyage UNIQUEMENT des conteneurs et images ${DOTFILES_PREFIX}..."
	local containers images
	containers=$(existing_dotfiles_containers)
	if [[ -n "$containers" ]]; then
		echo "$containers" | xargs -r docker stop 2>/dev/null || true
		echo "$containers" | xargs -r docker rm 2>/dev/null || true
		log_info "Conteneurs nettoyés"
	fi
	images=$(existing_dotfiles_images)
	if [[ -n "$images" ]]; then
		echo "$images" | xargs -r docker rmi 2>/dev/null || true
		log_info "Images nettoyées"
	fi
	docker rmi "${IMAGE_NAME}" 2>/dev/null || true
	log_info "Nettoyage terminé"
}

# --- parse args (avant tout prompt / message trompeur) ---
while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			usage
			exit 0
			;;
		--clean)
			CLEAN_MODE=yes
			shift
			;;
		--no-clean)
			CLEAN_MODE=no
			shift
			;;
		-y|--yes|--non-interactive)
			ASSUME_YES=1
			shift
			;;
		--managers)
			[[ $# -ge 2 ]] || { log_error "--managers nécessite une valeur"; exit 2; }
			MANAGERS_CHOICE="$2"
			shift 2
			;;
		--managers=*)
			MANAGERS_CHOICE="${1#*=}"
			shift
			;;
		--shell)
			[[ $# -ge 2 ]] || { log_error "--shell nécessite une valeur"; exit 2; }
			SELECTED_SHELL="$2"
			shift 2
			;;
		--shell=*)
			SELECTED_SHELL="${1#*=}"
			shift
			;;
		*)
			log_error "Option inconnue: $1"
			echo "Essayez: bash test-docker.sh --help" >&2
			exit 2
			;;
	esac
done

# Non-TTY ou --yes → defaults silencieux
if [[ "$ASSUME_YES" -eq 1 ]] || ! is_tty; then
	[[ -n "$CLEAN_MODE" ]] || CLEAN_MODE=no
	[[ -n "$MANAGERS_CHOICE" ]] || MANAGERS_CHOICE=all
	[[ -n "$SELECTED_SHELL" ]] || SELECTED_SHELL=zsh
fi

declare -A MANAGER_DESCS=(
	["aliaman"]="Gestionnaire alias"
	["configman"]="Gestionnaire configuration"
	["cyberman"]="Gestionnaire cybersécurité"
	["devman"]="Gestionnaire développement"
	["fileman"]="Gestionnaire fichiers"
	["gitman"]="Gestionnaire Git"
	["helpman"]="Gestionnaire aide/documentation"
	["installman"]="Gestionnaire installation"
	["manman"]="Manager of Managers"
	["miscman"]="Gestionnaire divers"
	["moduleman"]="Gestionnaire modules"
	["netman"]="Gestionnaire réseau"
	["pathman"]="Gestionnaire PATH"
	["searchman"]="Gestionnaire recherche"
	["shellman"]="Gestionnaire shell (session/user/system)"
	["dockerman"]="Gestionnaire Docker (ps/images/compose/cheat)"
	["sshman"]="Gestionnaire SSH"
	["testman"]="Gestionnaire tests applications"
	["testzshman"]="Gestionnaire tests ZSH/dotfiles"
	["virtman"]="Gestionnaire virtualisation"
)
MANAGER_NAMES=($(printf '%s\n' "${!MANAGER_DESCS[@]}" | sort))

# --- nettoyage ---
do_clean=0
if [[ "$CLEAN_MODE" == "yes" ]]; then
	do_clean=1
elif [[ "$CLEAN_MODE" == "no" ]]; then
	do_clean=0
else
	# Interactif : ne proposer le nettoyage que s'il y a réellement quelque chose
	imgs=$(existing_dotfiles_images)
	ctrs=$(existing_dotfiles_containers)
	if [[ -n "$imgs" || -n "$ctrs" ]]; then
		echo ""
		log_warn "Ressources Docker « ${DOTFILES_PREFIX} » déjà présentes"
		[[ -n "$ctrs" ]] && echo -e "  Conteneurs: ${CYAN}${ctrs}${NC}"
		[[ -n "$imgs" ]] && echo -e "  Images:     ${CYAN}${imgs}${NC}"
		echo -e "${YELLOW}Cela ne concerne QUE le préfixe ${DOTFILES_PREFIX} (pas vos autres images).${NC}"
		read -r -p "Nettoyer avant de reconstruire ? (o/N): " clean_choice
		clean_choice=${clean_choice:-n}
		if [[ "$clean_choice" =~ ^[oO]$ ]]; then
			do_clean=1
		else
			log_info "Nettoyage ignoré — réutilisation des images existantes si possible"
		fi
	else
		log_info "Aucune image/conteneur ${DOTFILES_PREFIX} détecté — pas de nettoyage"
	fi
fi

if [[ "$do_clean" -eq 1 ]]; then
	cleanup_dotfiles_docker
fi

# --- sélection managers ---
MANAGERS_CONFIG=$(mktemp)
trap 'rm -f "$MANAGERS_CONFIG"' EXIT

cat > "$MANAGERS_CONFIG" << 'EOF'
# Configuration des modules - Moduleman
# Format compatible Zsh et Fish
# Zsh: MODULE_<nom>=enabled|disabled
# Fish: set -g MODULE_<nom> enabled|disabled
EOF

if [[ -z "$MANAGERS_CHOICE" ]]; then
	echo ""
	echo -e "${CYAN}📦 SÉLECTION DES MANAGERS À ACTIVER${NC}"
	echo -e "${YELLOW}Quels managers voulez-vous activer dans Docker?${NC}"
	echo ""
	echo "Managers disponibles:"
	local_index=1
	declare -A MANAGER_MAP
	for manager_name in "${MANAGER_NAMES[@]}"; do
		MANAGER_MAP["$local_index"]="$manager_name"
		printf " %2d) %-15s - %s\n" "$local_index" "$manager_name" "${MANAGER_DESCS[$manager_name]}"
		((local_index++)) || true
	done
	echo ""
	echo -e "${YELLOW}Format: numéros (ex: 1 2 3) | 'all' | 'none' | noms (ex: pathman,gitman)${NC}"
	read -r -p "Votre choix [all]: " managers_input
	MANAGERS_CHOICE=${managers_input:-all}
fi

write_all_enabled() {
	local m
	for m in "${MANAGER_NAMES[@]}"; do
		echo "MODULE_${m}=enabled" >> "$MANAGERS_CONFIG"
	done
}

write_all_disabled() {
	local m
	for m in "${MANAGER_NAMES[@]}"; do
		echo "MODULE_${m}=disabled" >> "$MANAGERS_CONFIG"
	done
}

case "$MANAGERS_CHOICE" in
	all)
		write_all_enabled
		log_info "Tous les managers seront activés"
		;;
	none)
		write_all_disabled
		log_info "Aucun manager ne sera activé"
		;;
	*)
		# Numéros (interactif) ou noms CSV
		if [[ "$MANAGERS_CHOICE" =~ ^[0-9\ ]+$ ]]; then
			declare -A MANAGER_MAP=()
			local_index=1
			for manager_name in "${MANAGER_NAMES[@]}"; do
				MANAGER_MAP["$local_index"]="$manager_name"
				((local_index++)) || true
			done
			declare -A SELECTED=()
			for num in $MANAGERS_CHOICE; do
				if [[ -n "${MANAGER_MAP[$num]:-}" ]]; then
					SELECTED["${MANAGER_MAP[$num]}"]=1
					log_info "${MANAGER_MAP[$num]} sera activé"
				fi
			done
			for manager in "${MANAGER_NAMES[@]}"; do
				if [[ -n "${SELECTED[$manager]:-}" ]]; then
					echo "MODULE_${manager}=enabled" >> "$MANAGERS_CONFIG"
				else
					echo "MODULE_${manager}=disabled" >> "$MANAGERS_CONFIG"
				fi
			done
		else
			IFS=', ' read -r -a WANT <<< "$MANAGERS_CHOICE"
			declare -A SELECTED=()
			local any=0
			for name in "${WANT[@]}"; do
				[[ -z "$name" ]] && continue
				if [[ -z "${MANAGER_DESCS[$name]+x}" ]]; then
					log_warn "Manager inconnu ignoré: $name"
					continue
				fi
				SELECTED["$name"]=1
				any=1
				log_info "$name sera activé"
			done
			if [[ "$any" -eq 0 ]]; then
				log_error "Aucun manager valide dans: $MANAGERS_CHOICE"
				exit 2
			fi
			for manager in "${MANAGER_NAMES[@]}"; do
				if [[ -n "${SELECTED[$manager]:-}" ]]; then
					echo "MODULE_${manager}=enabled" >> "$MANAGERS_CONFIG"
				else
					echo "MODULE_${manager}=disabled" >> "$MANAGERS_CONFIG"
				fi
			done
		fi
		;;
esac

# --- shell ---
if [[ -z "$SELECTED_SHELL" ]]; then
	echo ""
	echo -e "${CYAN}🐚 SÉLECTION DU SHELL DE TEST${NC}"
	echo "  1) zsh (recommandé)"
	echo "  2) bash"
	echo "  3) fish"
	read -r -p "Votre choix [1]: " shell_choice
	shell_choice=${shell_choice:-1}
	case "$shell_choice" in
		1|zsh) SELECTED_SHELL=zsh ;;
		2|bash) SELECTED_SHELL=bash ;;
		3|fish) SELECTED_SHELL=fish ;;
		*) SELECTED_SHELL=zsh ;;
	esac
fi

case "$SELECTED_SHELL" in
	zsh|bash|fish) ;;
	*)
		log_error "Shell invalide: $SELECTED_SHELL (zsh|bash|fish)"
		exit 2
		;;
esac
log_info "Shell sélectionné: $SELECTED_SHELL"

if [[ ! -f "$DOCKERFILE" ]]; then
	log_error "Dockerfile.test introuvable: $DOCKERFILE"
	exit 1
fi

log_step "Construction de l'image Docker isolée..."
docker build --load \
	--build-arg MANAGERS_CONFIG="$(cat "$MANAGERS_CONFIG")" \
	--build-arg SELECTED_SHELL="$SELECTED_SHELL" \
	-f "$DOCKERFILE" \
	-t "$IMAGE_NAME" \
	"$DOTFILES_DIR" || {
	log_error "Échec de la construction de l'image"
	exit 1
}
log_info "Image isolée créée: $IMAGE_NAME"

log_step "Lancement du conteneur..."
docker run --rm \
	--name "$CONTAINER_NAME" \
	-v "${DOTFILES_DIR}:/root/dotfiles:ro" \
	"$IMAGE_NAME" || {
	log_error "Échec du lancement du conteneur"
	exit 1
}

log_info "Tests terminés !"
echo ""
echo -e "${CYAN}Pour tester manuellement:${NC} make docker-start"
echo ""
