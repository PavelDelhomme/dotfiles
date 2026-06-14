#!/usr/bin/env bash
# Smoke test for local bootstrap/re-apply flow.
# It mounts the current checkout in a clean container and verifies that
# apply_dotfiles.sh can converge a fresh HOME without touching the host.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
IMAGE_NAME="${IMAGE_NAME:-dotfiles-test-bootstrap-apply}"
DOCKERFILE="${DOCKERFILE:-$DOTFILES_DIR/scripts/test/docker/Dockerfile.test}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker n'est pas installé" >&2
    exit 1
fi

echo "== Build image bootstrap/apply =="
DOCKER_BUILDKIT=0 docker build -f "$DOCKERFILE" -t "$IMAGE_NAME:latest" "$DOTFILES_DIR"

echo "== Run local apply smoke =="
docker run --rm \
    -v "$DOTFILES_DIR:/workspace/dotfiles:ro" \
    -e DOTFILES_DIR=/workspace/dotfiles \
    -e HOME=/tmp/dotfiles-home \
    -e TERM=xterm-256color \
    "$IMAGE_NAME:latest" \
    bash -lc '
        set -euo pipefail
        mkdir -p "$HOME"

        bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" shell --dry-run
        bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" shell --apply --yes
        ROOT_HOME=/tmp/dotfiles-root-home DOTFILES_MANAGER_SHIM_DIR=/tmp/dotfiles-shims \
            bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" root --apply --yes

        test -L "$HOME/.zshrc"
        test "$(readlink "$HOME/.zshrc")" = "$DOTFILES_DIR/zshrc"
        test -L "$HOME/.p10k.zsh"
        test "$(readlink "$HOME/.p10k.zsh")" = "$DOTFILES_DIR/.p10k.zsh"
        test -x /tmp/dotfiles-shims/diskman
        /tmp/dotfiles-shims/diskman help >/dev/null

        bash -n "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh"
        if command -v zsh >/dev/null 2>&1; then
            zsh -n "$DOTFILES_DIR/zsh/zshrc_custom"
            zsh -n "$DOTFILES_DIR/.p10k.zsh"
            bash "$DOTFILES_DIR/scripts/test/configman_apply_smoke.sh"
        fi

        echo "bootstrap/apply local smoke OK"
    '
