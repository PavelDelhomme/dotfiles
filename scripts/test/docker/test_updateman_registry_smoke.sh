#!/usr/bin/env bash
# Smoke updateman registre (cursor/docker/brave) — conteneur isole, sans toucher l'hote.
# Usage : DOTFILES_DIR=~/dotfiles bash scripts/test/docker/test_updateman_registry_smoke.sh [distro]
#         make test-updateman-registry-smoke
#         make test-updateman-registry-smoke DISTRO=debian

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISTRO="${1:-${DISTRO:-debian}}"
SCRIPT_DIR="$DOTFILES_DIR/scripts/test/docker"
DOCKERFILE=""

case "$DISTRO" in
    arch) DOCKERFILE="$SCRIPT_DIR/Dockerfile.test" ;;
    debian) DOCKERFILE="$SCRIPT_DIR/Dockerfile.debian" ;;
    alpine) DOCKERFILE="$SCRIPT_DIR/Dockerfile.alpine" ;;
    *)
        echo "Distro inconnue: $DISTRO" >&2
        exit 1
        ;;
esac

IMAGE="dotfiles-updateman-registry-${DISTRO}"
echo "==> Build $IMAGE ($DISTRO)"
docker build -q -f "$DOCKERFILE" -t "$IMAGE" "$DOTFILES_DIR" >/dev/null

DOCKER_RUN=(docker run --rm -v "$DOTFILES_DIR:/root/dotfiles:ro" -e DOTFILES_DIR=/root/dotfiles "$IMAGE")

echo "==> Smoke updateman registre ($DISTRO)"
if ! "${DOCKER_RUN[@]}" bash -c '
    set -e
    export HOME=/tmp/updateman-smoke-home
    mkdir -p "$HOME/Applications" "$HOME/.config/systemd/user"
    printf "2.0.0\n" >"$HOME/Applications/.cursor-version"

    # Binaires factices (pas de vraie install sur l hote)
    mkdir -p "$HOME/bin"
    printf "#!/bin/sh\necho Docker version 26.1.0, build smoke\n" >"$HOME/bin/docker"
    printf "#!/bin/sh\necho Brave Browser 1.65.120\n" >"$HOME/bin/brave"
    chmod +x "$HOME/bin/docker" "$HOME/bin/brave"
    export PATH="$HOME/bin:$PATH"

    cd /root/dotfiles
    . core/managers/updateman/core/updateman.sh

    _out="$(updateman cursor status </dev/null 2>&1)"
    printf "%s\n" "$_out"
    printf "%s" "$_out" | grep -q "Version locale"
    printf "%s" "$_out" | grep -q "Mise a jour"
    printf "%s" "$_out" | grep -q "2.0.0"

    _out="$(updateman docker status </dev/null 2>&1)"
    printf "%s\n" "$_out"
    printf "%s" "$_out" | grep -q "Installation"
    printf "%s" "$_out" | grep -q "26.1.0"

    _out="$(updateman brave status </dev/null 2>&1)"
    printf "%s\n" "$_out"
    printf "%s" "$_out" | grep -q "1.65.120"

    updateman status </dev/null | grep -qE "cursor|docker|brave"
    updateman docker check </dev/null >/dev/null

    echo "OK smoke updateman registry"
'; then
    echo "ECHEC smoke updateman registry ($DISTRO)" >&2
    exit 1
fi

echo "OK smoke updateman registry ($DISTRO)"
