#!/usr/bin/env bash
# Smoke updateman registre + timers — conteneur isole uniquement (ne touche pas l'hote).
# Usage : make test-updateman-registry-smoke
#         make test-updateman-registry-smoke DISTRO=arch

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

# DOTFILES_DIR en lecture seule : les unites systemd vont dans HOME du conteneur.
DOCKER_RUN=(docker run --rm -v "$DOTFILES_DIR:/root/dotfiles:ro" -e DOTFILES_DIR=/root/dotfiles "$IMAGE")

echo "==> Smoke updateman registre + timers ($DISTRO)"
if ! "${DOCKER_RUN[@]}" bash -c '
    set -e
    export HOME=/tmp/updateman-smoke-home
    mkdir -p "$HOME/Applications" "$HOME/.config/systemd/user" "$HOME/bin"
    printf "3.9.16\n" >"$HOME/Applications/.cursor-version"
    printf "#!/bin/sh\necho Docker version 26.1.0, build smoke\n" >"$HOME/bin/docker"
    printf "#!/bin/sh\necho Brave Browser 1.65.120\n" >"$HOME/bin/brave"
    chmod +x "$HOME/bin/docker" "$HOME/bin/brave"
    export PATH="$HOME/bin:$PATH"

    cd /root/dotfiles
    . core/managers/updateman/core/updateman.sh

    for tool in cursor docker brave; do
        _out="$(updateman "$tool" status </dev/null 2>&1)"
        printf "%s\n" "$_out" | grep -q "Version locale" || { echo "FAIL status $tool"; exit 1; }
        printf "%s\n" "$_out" | grep -q "Mise a jour" || { echo "FAIL maj? $tool"; exit 1; }
    done

    updateman docker install </dev/null
    test -f "$HOME/.config/systemd/user/docker-update.timer"
    test -f "$HOME/.config/systemd/user/docker-update.service"

    updateman brave install </dev/null
    test -f "$HOME/.config/systemd/user/brave-update.timer"

    _out="$(updateman docker status </dev/null 2>&1)"
    printf "%s\n" "$_out" | grep -q "docker-update.timer"
    printf "%s\n" "$_out" | grep -qE "installees|Etat timer"

    updateman status </dev/null | grep -qE "cursor|docker|brave"
    updateman docker check </dev/null >/dev/null
    updateman brave check </dev/null >/dev/null

    echo "OK smoke updateman registry"
'; then
    echo "ECHEC smoke updateman registry ($DISTRO)" >&2
    exit 1
fi

echo "OK smoke updateman registry ($DISTRO)"
