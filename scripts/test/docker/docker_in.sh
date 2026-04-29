#!/usr/bin/env bash
# Lancé par : make docker-in (variables d'environnement passées par Make)
# Bac à sable : choix distro (optionnel), image construite si absente, puis shell.
#
# Images hors Arch : tag dotfiles-in-<distro>:latest (nettoyage manuel si besoin :
#   docker images --format '{{.Repository}}:{{.Tag}}' | grep '^dotfiles-in-' | xargs -r docker rmi)
# CentOS : pas de fish dans l'image — choisir zsh ou bash pour cette distro.
set -e
ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
cd "$ROOT_DIR" || exit 1

DOTFILES_IMAGE="${DOTFILES_IMAGE:-dotfiles-test-image:latest}"
DOTFILES_CONTAINER="${DOTFILES_CONTAINER:-dotfiles-test-container}"
DOCKER_DOTFILES_DIR="${DOCKER_DOTFILES_DIR:-/root/dotfiles}"
DOCKER_INSTALLMAN_ASSUME="${DOCKER_INSTALLMAN_ASSUME:-1}"

if ! command -v docker >/dev/null 2>&1; then
	printf '%s\n' "⚠️  Docker n'est pas installé." >&2
	exit 1
fi

# --- Distribution (base OS du conteneur) ---
DISTRO="${DOCKER_DISTRO:-}"
DISTRO=$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

if [[ -z "$DISTRO" && -t 0 ]]; then
	echo ""
	echo -e "\033[0;36mQuelle distribution (base du conteneur) ?\033[0m"
	echo "  1) Arch (défaut — image Makefile / make docker-build)"
	echo "  2) Ubuntu"
	echo "  3) Debian"
	echo "  4) Alpine"
	echo "  5) Fedora"
	echo "  6) CentOS"
	echo "  7) openSUSE"
	echo "  8) Gentoo  ⚠️  build très long (sources)"
	echo ""
	printf "\033[1;33mChoix [1-8, ou nom: arch|ubuntu|…, Entrée = Arch] : \033[0m"
	read -r _d_choice || true
	_d_choice=$(echo "${_d_choice:-1}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
	case "$_d_choice" in
		2|ubuntu) DISTRO=ubuntu ;;
		3|debian) DISTRO=debian ;;
		4|alpine) DISTRO=alpine ;;
		5|fedora) DISTRO=fedora ;;
		6|centos) DISTRO=centos ;;
		7|opensuse|opensuse-tumbleweed|suse) DISTRO=opensuse ;;
		8|gentoo) DISTRO=gentoo ;;
		1|arch|'') DISTRO=arch ;;
		*) DISTRO=arch ;;
	esac
fi
[[ -z "$DISTRO" ]] && DISTRO=arch

IMG=""
DOCKERFILE=""
case "$DISTRO" in
	arch)
		IMG="$DOTFILES_IMAGE"
		;;
	ubuntu)
		IMG="dotfiles-in-ubuntu:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.ubuntu"
		;;
	debian)
		IMG="dotfiles-in-debian:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.debian"
		;;
	alpine)
		IMG="dotfiles-in-alpine:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.alpine"
		;;
	fedora)
		IMG="dotfiles-in-fedora:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.fedora"
		;;
	centos)
		IMG="dotfiles-in-centos:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.centos"
		;;
	opensuse)
		IMG="dotfiles-in-opensuse:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.opensuse"
		;;
	gentoo)
		IMG="dotfiles-in-gentoo:latest"
		DOCKERFILE="scripts/test/docker/Dockerfile.gentoo"
		if [[ -t 0 ]]; then
			echo -e "\033[1;33m⚠️  Gentoo : build très longue (souvent 30–60 min+).\033[0m"
			printf "Continuer ? (o/N) : "
			read -r _g2 || true
			case "${_g2:-}" in o|O) ;; *) echo "Annulé."; exit 0 ;; esac
		fi
		;;
	*)
		printf '%s\n' "Distribution inconnue: $DISTRO (utilisez arch, ubuntu, debian, …)" >&2
		exit 1
		;;
esac

image_present() {
	docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$1$"
}

if [[ "$DISTRO" == "arch" ]]; then
	if ! image_present "$IMG"; then
		echo -e "\033[0;34m📦 Image absente ($IMG), construction (make docker-build)…\033[0m"
		"${MAKE:-make}" -C "$ROOT_DIR" docker-build
	fi
else
	if ! image_present "$IMG"; then
		echo -e "\033[0;34m📦 Construction $IMG ($DOCKERFILE)…\033[0m"
		DOCKER_BUILDKIT=0 docker build -f "$DOCKERFILE" -t "$IMG" "$ROOT_DIR"
	fi
fi

# --- Shell ---
SH="${DOCKER_SHELL:-}"
if [[ -z "$SH" && -t 0 ]]; then
	echo ""
	echo -e "\033[0;36mQuel shell ouvrir dans le conteneur ?\033[0m"
	echo "  1) zsh   2) bash   3) fish   4) sh (POSIX)"
	printf "\033[1;33mChoix [1-4, ou nom, Entrée = zsh] : \033[0m"
	read -r _ds_choice || true
	_ds_choice=$(echo "${_ds_choice:-}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
	case "$_ds_choice" in
		2|bash) SH=bash ;;
		3|fish) SH=fish ;;
		4|sh) SH=sh ;;
		1|zsh|'') SH=zsh ;;
		*) SH=zsh ;;
	esac
fi
[[ -z "$SH" ]] && SH=zsh

_ASSUME_ARGS=()
[[ "$DOCKER_INSTALLMAN_ASSUME" == "1" ]] && _ASSUME_ARGS+=(-e INSTALLMAN_ASSUME_YES=1)

echo -e "\033[0;32m🐧 Distro: $DISTRO  →  image: $IMG\033[0m"
echo -e "\033[0;32m🐚 Shell: $SH\033[0m"

_run() {
	docker run -it --rm \
		--name "$DOTFILES_CONTAINER" \
		-v "$ROOT_DIR:/root/dotfiles:ro" \
		-v dotfiles-test-config:/root/.config \
		-v dotfiles-test-ssh:/root/.ssh \
		-e HOME=/root \
		-e DOTFILES_DIR="$DOCKER_DOTFILES_DIR" \
		"${_ASSUME_ARGS[@]}" \
		-e TERM="${TERM:-xterm-256color}" \
		"$IMG" \
		"$@"
}

case "$SH" in
	bash)
		_run /bin/bash -c 'source /root/dotfiles/shared/config.sh 2>/dev/null; [ -f /root/dotfiles/bash/bashrc_custom ] && source /root/dotfiles/bash/bashrc_custom; exec /bin/bash'
		;;
	fish)
		_run /bin/bash -c 'source /root/dotfiles/shared/config.sh 2>/dev/null; [ -f /root/dotfiles/fish/config_custom.fish ] && source /root/dotfiles/fish/config_custom.fish; exec fish'
		;;
	sh)
		_run /bin/sh
		;;
	zsh|*)
		_run /bin/zsh
		;;
esac
