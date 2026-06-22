#!/usr/bin/env bash
# Smoke G.1–G.26 : aide manager en non-TTY.
# Usage :
#   tests_smoke_manager.sh pathman           # exécuter
#   tests_smoke_manager.sh --copy pathman  # copier la commande → presse-papiers
#   make tests-smoke-manager MANAGER=pathman
#   make tests-copy-smoke MANAGER=pathman

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CLIP="${DOTFILES_DIR}/shared/functions/clipboard_copy.sh"

usage() {
    echo "Usage: tests_smoke_manager.sh [--copy] <manager>" >&2
    exit 1
}

mode=run
case "${1:-}" in
    --copy|-c) mode=copy; shift ;;
    --run|-r) mode=run; shift ;;
esac

mgr="${1:-}"
[ -n "$mgr" ] || usage

core="${DOTFILES_DIR}/core/managers/${mgr}/core/${mgr}.sh"
[ -f "$core" ] || { echo "tests_smoke_manager: manager introuvable : $core" >&2; exit 1; }

# Sous-shell sans « set -u » ni pipefail (cores : $ZSH_VERSION ; head → SIGPIPE 141).
_smoke_inner="set +o pipefail; cd \"${DOTFILES_DIR}\" && . \"${core}\" && ${mgr} help </dev/null 2>&1 | head -n 8"
cmd="bash -c $(printf '%q' "$_smoke_inner")"

if [ "$mode" = copy ]; then
    if [ -f "$CLIP" ]; then
        # shellcheck source=/dev/null
        . "$CLIP"
        dotfiles_clipboard_copy "$cmd" || true
    fi
    if command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$cmd" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$cmd" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        printf '%s' "$cmd" | xsel --clipboard --input
    else
        echo "$cmd"
        echo "tests_smoke_manager: installez wl-copy, xclip ou xsel pour copier" >&2
        exit 1
    fi
    printf '📋 Commande smoke %s copiée\n' "$mgr"
    exit 0
fi

# shellcheck disable=SC2090
bash -c "$_smoke_inner"
