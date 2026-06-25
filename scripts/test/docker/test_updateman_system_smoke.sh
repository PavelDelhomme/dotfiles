#!/usr/bin/env bash
# Smoke updateman system — non destructif (status/pending/refresh sans upgrade).
# Usage : DOTFILES_DIR=~/dotfiles bash scripts/test/docker/test_updateman_system_smoke.sh [distro]
#         make test-updateman-system-smoke
#         make test-updateman-system-smoke DISTRO=ubuntu

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DISTRO="${1:-${DISTRO:-arch}}"
SCRIPT_DIR="$DOTFILES_DIR/scripts/test/docker"
DOCKERFILE=""

case "$DISTRO" in
    arch) DOCKERFILE="$SCRIPT_DIR/Dockerfile.test" ;;
    ubuntu) DOCKERFILE="$SCRIPT_DIR/Dockerfile.ubuntu" ;;
    debian) DOCKERFILE="$SCRIPT_DIR/Dockerfile.debian" ;;
    alpine) DOCKERFILE="$SCRIPT_DIR/Dockerfile.alpine" ;;
    fedora) DOCKERFILE="$SCRIPT_DIR/Dockerfile.fedora" ;;
    centos) DOCKERFILE="$SCRIPT_DIR/Dockerfile.centos" ;;
    opensuse) DOCKERFILE="$SCRIPT_DIR/Dockerfile.opensuse" ;;
    *)
        echo "Distro inconnue: $DISTRO" >&2
        exit 1
        ;;
esac

IMAGE="dotfiles-updateman-smoke-${DISTRO}"
echo "==> Build $IMAGE ($DISTRO)"
docker build -q -f "$DOCKERFILE" -t "$IMAGE" "$DOTFILES_DIR" >/dev/null

DOCKER_RUN=(docker run --rm -v "$DOTFILES_DIR:/root/dotfiles:ro" -e DOTFILES_DIR=/root/dotfiles "$IMAGE")

run_smoke_bashlike() {
    local shell="$1"
    echo "==> Smoke updateman system ($DISTRO / $shell)"
    if ! "${DOCKER_RUN[@]}" "$shell" -c '
        set -e
        cd /root/dotfiles
        . core/managers/updateman/core/updateman.sh
        updateman system status </dev/null
        updateman system pending </dev/null | head -n 20
        updateman help </dev/null | grep -q "updateman system"
        echo "help OK"
    '; then
        echo "FAIL smoke ($DISTRO / $shell)" >&2
        return 1
    fi
}

run_smoke_fish() {
    echo "==> Smoke updateman system ($DISTRO / fish)"
    if ! "${DOCKER_RUN[@]}" fish -c '
        cd /root/dotfiles; or exit 1
        source shells/fish/adapters/updateman.fish; or exit 1
        updateman system status; or exit 1
        updateman system pending | head -n 20
        updateman help | grep -q "updateman system"; or exit 1
        echo help OK
    '; then
        echo "FAIL smoke ($DISTRO / fish)" >&2
        return 1
    fi
}

failed=0
for sh in bash zsh; do
    if "${DOCKER_RUN[@]}" /bin/bash -c "command -v $sh" >/dev/null 2>&1; then
        run_smoke_bashlike "$sh" || failed=1
    fi
done
if "${DOCKER_RUN[@]}" /bin/bash -c 'command -v fish' >/dev/null 2>&1; then
    run_smoke_fish || failed=1
fi

if [ "$failed" -ne 0 ]; then
    echo "ECHEC smoke updateman system ($DISTRO)" >&2
    exit 1
fi

echo "OK smoke updateman system ($DISTRO)"
