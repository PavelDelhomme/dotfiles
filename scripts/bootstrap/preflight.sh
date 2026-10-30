#!/bin/bash
# Preflight — détecter l'état existant avant install / reset / bootstrap.
# Usage:
#   bash scripts/bootstrap/preflight.sh --check
#   bash scripts/bootstrap/preflight.sh --plan install|reset|bootstrap [--gate]
#   bash scripts/bootstrap/preflight.sh --plan install --yes   # CI / non-TTY
#
# Codes sortie:
#   0 = OK (rien de bloquant, ou confirmation acceptée)
#   1 = annulé / erreur
#   2 = état déjà présent (mode --check-only-exit si DOTFILES_PREFLIGHT_STRICT=1)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*"; }
log_step()  { echo -e "${CYAN}[→]${NC} $*"; }

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PLAN=""
GATE=0
ASSUME_YES=0
CHECK_ONLY=0

usage() {
	cat <<'EOF'
preflight.sh — vérifier l'état machine avant install / reset / bootstrap

Usage:
  preflight.sh --check
  preflight.sh --plan install|reset|bootstrap [--gate] [--yes]

Options:
  --check              Rapport d'état uniquement (aucune action)
  --plan ACTION        Afficher ce que ferait install|reset|bootstrap
  --gate               Demander confirmation explicite (OUI) après le plan
  -y, --yes            Accepter sans prompt (CI / non-TTY)
  -h, --help           Cette aide

Variables:
  DOTFILES_DIR               Racine dépôt (défaut: ~/dotfiles)
  DOTFILES_SKIP_PREFLIGHT=1  Ignorer (exit 0) — utilisé par Makefile/bootstrap
  DOTFILES_PREFLIGHT_STRICT=1  Exit 2 si traces d'install déjà présentes (--check)

Exemples:
  bash scripts/bootstrap/preflight.sh --check
  bash scripts/bootstrap/preflight.sh --plan install --gate
  DOTFILES_SKIP_PREFLIGHT=1 make install
EOF
}

is_tty() { [[ -t 0 && -t 1 ]]; }

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help) usage; exit 0 ;;
		--check) CHECK_ONLY=1; shift ;;
		--plan)
			[[ $# -ge 2 ]] || { log_error "--plan nécessite install|reset|bootstrap"; exit 2; }
			PLAN="$2"; shift 2 ;;
		--plan=*) PLAN="${1#*=}"; shift ;;
		--gate) GATE=1; shift ;;
		-y|--yes) ASSUME_YES=1; shift ;;
		*) log_error "Option inconnue: $1"; usage; exit 2 ;;
	esac
done

if [[ "${DOTFILES_SKIP_PREFLIGHT:-0}" == "1" ]]; then
	log_info "Preflight ignoré (DOTFILES_SKIP_PREFLIGHT=1)"
	exit 0
fi

# --- collecte d'indices ---
declare -a FOUND=()
declare -a ACTIONS=()

note_found() { FOUND+=("$1"); }
note_action() { ACTIONS+=("$1"); }

check_state() {
	FOUND=()
	if [[ -d "$DOTFILES_DIR" ]]; then
		if [[ -d "$DOTFILES_DIR/.git" ]]; then
			note_found "Dépôt Git présent: $DOTFILES_DIR"
		else
			note_found "Dossier présent (sans .git): $DOTFILES_DIR"
		fi
	fi
	[[ -f "$DOTFILES_DIR/.env" ]] && note_found "Fichier .env présent"
	[[ -L "$HOME/.zshrc" || -f "$HOME/.zshrc" ]] && note_found "Shell rc: ~/.zshrc"
	[[ -L "$HOME/.bashrc" || -f "$HOME/.bashrc" ]] && note_found "Shell rc: ~/.bashrc"
	[[ -f "$HOME/.config/fish/config.fish" ]] && note_found "Fish config: ~/.config/fish/config.fish"
	if [[ -L "$HOME/.zshrc" ]]; then
		local target
		target=$(readlink -f "$HOME/.zshrc" 2>/dev/null || readlink "$HOME/.zshrc" 2>/dev/null || true)
		[[ "$target" == *dotfiles* ]] && note_found "Symlink ~/.zshrc → dotfiles ($target)"
	fi
	command -v pathman >/dev/null 2>&1 && note_found "Manager pathman disponible dans PATH"
	command -v manman >/dev/null 2>&1 && note_found "Manager manman disponible dans PATH"
	command -v shellman >/dev/null 2>&1 && note_found "Manager shellman disponible dans PATH"
	if systemctl --user is-enabled dotfiles-sync.timer >/dev/null 2>&1 \
		|| systemctl --user is-active dotfiles-sync.timer >/dev/null 2>&1; then
		note_found "Timer systemd user: dotfiles-sync"
	fi
	local imgs
	imgs=$(docker images --filter "reference=dotfiles-test*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
	[[ -n "$imgs" ]] && note_found "Images Docker de test: $imgs"
	if git config --global user.name >/dev/null 2>&1; then
		note_found "Git global user.name=$(git config --global user.name)"
	fi
}

print_report() {
	echo ""
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  Preflight — état machine (avant install / reset)${NC}"
	echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
	echo -e "  DOTFILES_DIR=${CYAN}$DOTFILES_DIR${NC}"
	echo ""
	if [[ ${#FOUND[@]} -eq 0 ]]; then
		log_info "Aucune trace d'installation dotfiles détectée — machine « propre » pour une install from scratch."
	else
		log_warn "Traces détectées (${#FOUND[@]}) :"
		local i
		for i in "${FOUND[@]}"; do
			echo -e "    • $i"
		done
		echo ""
		log_warn "Une install/reset sans lecture peut écraser ou mélanger ces éléments."
	fi
	echo ""
}

plan_install() {
	ACTIONS=(
		"Vérifier/installer git (+ ssh/sshpass selon distro)"
		"Configurer Git user.name / user.email (interactif ou .env)"
		"Proposer SSH GitHub (optionnel)"
		"Cloner ou réutiliser $DOTFILES_DIR"
		"Créer .env depuis .env.example si absent"
		"Proposer symlinks shell (zsh/bash/fish)"
		"Lancer scripts/setup.sh (menu interactif)"
	)
}

plan_reset() {
	ACTIONS=(
		"Rollback complet (timers, symlinks, configs gérées)"
		"Demander confirmation pour supprimer $DOTFILES_DIR"
		"Proposer réinstallation via bootstrap"
	)
}

plan_bootstrap() {
	plan_install
}

print_plan() {
	local title="$1"
	echo -e "${CYAN}Plan prévu — $title${NC}"
	local n=1 a
	for a in "${ACTIONS[@]}"; do
		printf "  %2d. %s\n" "$n" "$a"
		((n++)) || true
	done
	echo ""
	echo -e "${YELLOW}Rien n'est appliqué tant que vous ne confirmez pas.${NC}"
	echo -e "  Voir aussi: ${CYAN}make init help${NC} · ${CYAN}docs/guides/INSTALL.md${NC}"
	echo ""
}

confirm_gate() {
	if [[ "$ASSUME_YES" -eq 1 ]]; then
		log_info "Confirmation auto (--yes)"
		return 0
	fi
	if ! is_tty; then
		log_error "Pas de TTY : passez --yes ou DOTFILES_SKIP_PREFLIGHT=1 pour forcer."
		return 1
	fi
	echo -e "${YELLOW}Pour continuer, tapez exactement : OUI${NC}"
	local ans
	read -r -p "> " ans
	if [[ "$ans" != "OUI" ]]; then
		log_warn "Annulé."
		return 1
	fi
	return 0
}

# --- main ---
check_state
print_report

if [[ "$CHECK_ONLY" -eq 1 ]]; then
	if [[ "${DOTFILES_PREFLIGHT_STRICT:-0}" == "1" && ${#FOUND[@]} -gt 0 ]]; then
		exit 2
	fi
	exit 0
fi

case "${PLAN:-}" in
	"")
		# rapport seul si pas de plan
		exit 0
		;;
	install)
		plan_install
		print_plan "install (make install / bootstrap)"
		;;
	reset)
		plan_reset
		print_plan "reset (make reset)"
		;;
	bootstrap)
		plan_bootstrap
		print_plan "bootstrap (curl | bash)"
		;;
	*)
		log_error "Plan inconnu: $PLAN (install|reset|bootstrap)"
		exit 2
		;;
esac

if [[ "$GATE" -eq 1 ]]; then
	confirm_gate || exit 1
fi

exit 0
