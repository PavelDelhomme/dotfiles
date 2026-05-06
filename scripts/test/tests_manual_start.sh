#!/usr/bin/env bash
# Menu d’accompagnement pour docs/TESTS.md — ne remplace pas la lecture du fichier.
# Usage : make tests-start   ou   bash scripts/test/tests_manual_start.sh
set -e
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR" || exit 1

export MAKE="${MAKE:-make}"

banner() {
	printf '\n\033[0;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
	printf '\033[1m%s\033[0m\n' "$1"
	printf '\033[0;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n\n'
}

while true; do
	banner "Tests manuels — voir docs/TESTS.md (parcours lettre par lettre)"
	echo "Répertoire dotfiles : $ROOT_DIR"
	echo ""
	echo "  1) Prérequis hôte (docker, cc, chemins) — équivalent étapes A.1–A.3"
	echo "  2) make docker-build (image Arch / dotfiles-test)"
	echo "  3) make docker-in  → menus : distribution puis shell (Bloc C du guide)"
	echo "  4) Afficher exemples docker-in sans menu (copier-coller)"
	echo "  5) make test-dotcli (compilation + smoke dotcli)"
	echo "  6) make test-help"
	echo "  7) make test-dotfiles-good"
	echo "  8) make test (Docker complet — long)"
	echo "  9) Ouvrir docs/TESTS.md dans \$PAGER (less)"
	echo "  0) Quitter"
	echo ""
	printf "\033[1;33mChoix [0-9] : \033[0m"
	read -r _c || exit 0
	_c=$(echo "${_c:-}" | tr -d '[:space:]')
	case "$_c" in
		1)
			echo "--- Docker ---"
			command -v docker >/dev/null 2>&1 && docker version 2>/dev/null | head -20 || echo "❌ docker absent ou daemon injoignable"
			echo "--- Compilateur C (dotcli) ---"
			(command -v cc && cc --version | head -1) || (command -v gcc && gcc --version | head -1) || echo "❌ pas de cc/gcc"
			echo "--- Répertoire ---"
			echo "PWD=$ROOT_DIR"
			test -f "$ROOT_DIR/Makefile" && echo "✅ Makefile présent" || echo "❌ Makefile manquant"
			;;
		2)
			"$MAKE" -C "$ROOT_DIR" docker-build
			;;
		3)
			"$MAKE" -C "$ROOT_DIR" docker-in
			;;
		4)
			echo "# Exemples (hôte) — pas de menu interactif :"
			echo "  $MAKE docker-in DOCKER_DISTRO=debian DOCKER_SHELL=bash"
			echo "  $MAKE docker-in DOCKER_DISTRO=ubuntu DOCKER_SHELL=fish"
			echo "  $MAKE docker-in DOCKER_DISTRO=arch DOCKER_SHELL=zsh"
			echo "  INSTALLMAN sans auto-yes : $MAKE docker-in DOCKER_INSTALLMAN_ASSUME=0"
			echo ""
			echo "Variables : voir TODOS.md (section Docker) et scripts/test/docker/docker_in.sh"
			;;
		5)
			"$MAKE" -C "$ROOT_DIR" test-dotcli
			;;
		6)
			"$MAKE" -C "$ROOT_DIR" test-help
			;;
		7)
			"$MAKE" -C "$ROOT_DIR" test-dotfiles-good
			;;
		8)
			echo "⚠️  Peut prendre longtemps. Ctrl+C pour annuler avant lancement."
			printf "Lancer make test ? (o/N) "
			read -r _ok || true
			case "${_ok:-}" in o|O) "$MAKE" -C "$ROOT_DIR" test ;; *) echo "Annulé." ;; esac
			;;
		9)
			if command -v less >/dev/null 2>&1; then
				less -R "$ROOT_DIR/docs/TESTS.md"
			else
				${PAGER:-cat} "$ROOT_DIR/docs/TESTS.md"
			fi
			;;
		0|"")
			echo "À bientôt — coche les étapes dans docs/TESTS.md."
			exit 0
			;;
		*)
			echo "Choix invalide."
			;;
	esac
done
