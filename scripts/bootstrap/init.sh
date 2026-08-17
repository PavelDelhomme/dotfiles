#!/bin/bash
# Hub d'initialisation — point d'entrée clair pour machine vide ou dépôt déjà cloné.
#
# Usage:
#   make init help
#   make init-help
#   bash scripts/bootstrap/init.sh help
#   bash scripts/bootstrap/init.sh status
#   bash scripts/bootstrap/init.sh plan
#   bash scripts/bootstrap/init.sh install [--yes]
#   bash scripts/bootstrap/init.sh tests
#   bash scripts/bootstrap/init.sh menu

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
PREFLIGHT="$SCRIPT_DIR/preflight.sh"
BOOTSTRAP="$DOTFILES_DIR/bootstrap.sh"

log_info()  { echo -e "${GREEN}[✓]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*"; }

usage() {
	cat <<EOF
init — initialisation & procédure d'installation des dotfiles

Usage Make (recommandé):
  make init help          Aide d'initialisation (équivalent: make init-help)
  make init status        État machine (preflight --check)
  make init plan          Plan d'install sans rien appliquer
  make init install       Preflight + confirmation + bootstrap
  make init tests         Lancer / expliquer les tests (Docker, sans polluer l'hôte)
  make init               Menu court (status / plan / install / tests / aide)

  Note: « make init --help » est interprété par GNU Make (aide Make),
        pas par ce script. Utilisez: make init help | make init-help

Usage direct:
  bash scripts/bootstrap/init.sh help|status|plan|install|tests|menu [--yes]

Machine vide — accès à TOUTES les commandes SANS installer sur l'hôte:
  1. git clone https://github.com/PavelDelhomme/dotfiles.git ~/dotfiles
  2. cd ~/dotfiles && make init help
  3. make help                 # catalogue Make
  4. make tests | make docker-in   # bac à sable isolé
  5. make test-docker --  (via: bash test-docker.sh --yes)
  Les managers sur l'hôte nécessitent ensuite: make init install (ou make setup)

Depuis zéro (curl, sans clone préalable):
  bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
  → le bootstrap appelle le preflight dès que le dépôt est disponible.

Documentation:
  docs/guides/INSTALL.md
  docs/guides/DOCKER.md
  docs/TESTS.md
  docs/INDEX.md
EOF
}

cmd_status() {
	bash "$PREFLIGHT" --check
}

cmd_plan() {
	bash "$PREFLIGHT" --plan install
}

cmd_install() {
	local yes_flag=()
	[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && yes_flag=(--yes)
	bash "$PREFLIGHT" --plan install --gate "${yes_flag[@]}"
	log_info "Lancement bootstrap…"
	if [[ -f "$BOOTSTRAP" ]]; then
		# Évite double gate dans le même processus parent
		DOTFILES_SKIP_PREFLIGHT=1 bash "$BOOTSTRAP"
	else
		log_error "bootstrap.sh introuvable: $BOOTSTRAP"
		exit 1
	fi
}

cmd_tests() {
	echo ""
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  Tests — sans installer sur l'hôte${NC}"
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo ""
	echo "Prérequis: Docker + make (git déjà là si vous avez cloné)."
	echo ""
	echo -e "  ${CYAN}make tests${NC}              Menu interactif des tests"
	echo -e "  ${CYAN}make tests-start${NC}        Parcours manuel docs/TESTS.md"
	echo -e "  ${CYAN}make docker-in${NC}          Bac à sable distro×shell (isolé)"
	echo -e "  ${CYAN}bash test-docker.sh --help${NC}"
	echo -e "  ${CYAN}bash test-docker.sh --yes${NC}   Build+run non interactif"
	echo -e "  ${CYAN}make test${NC}               CI: managers + matrice sous-commandes"
	echo -e "  ${CYAN}make sandbox-guide${NC}      Affiche scripts/test/SANDBOX.md"
	echo ""
	if [[ -t 0 && -t 1 ]]; then
		read -r -p "Lancer maintenant « make tests » (menu) ? (o/N): " ans
		ans=${ans:-n}
		if [[ "$ans" =~ ^[oO]$ ]]; then
			cd "$DOTFILES_DIR" && make tests
		else
			log_info "OK — lancez quand vous voulez: cd ~/dotfiles && make tests"
		fi
	else
		log_info "Non-TTY: pas de menu. Exemple: bash test-docker.sh --yes"
	fi
}

cmd_menu() {
	echo ""
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  make init — menu${NC}"
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo "  1) status   — état machine"
	echo "  2) plan     — que ferait une install"
	echo "  3) install  — preflight + confirmation + bootstrap"
	echo "  4) tests    — chemin tests isolés"
	echo "  5) help     — aide complète"
	echo "  0) quitter"
	echo ""
	read -r -p "Choix: " c
	case "${c:-0}" in
		1) cmd_status ;;
		2) cmd_plan ;;
		3) cmd_install ;;
		4) cmd_tests ;;
		5) usage ;;
		0|q|Q) exit 0 ;;
		*) log_error "Choix invalide"; exit 2 ;;
	esac
}

main() {
	local cmd="${1:-menu}"
	shift || true
	case "$cmd" in
		-h|--help|help) usage ;;
		status|check) cmd_status ;;
		plan) cmd_plan ;;
		install) cmd_install "${1:-}" ;;
		tests|test) cmd_tests ;;
		menu|"") cmd_menu ;;
		*)
			log_error "Sous-commande inconnue: $cmd"
			usage
			exit 2
			;;
	esac
}

main "$@"
