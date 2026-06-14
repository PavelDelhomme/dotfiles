#!/usr/bin/env bash
# Smoke: configman apply shell --dry-run via zsh (comme sur machine réelle).

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR

if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh requis pour ce smoke" >&2
    exit 1
fi

out=$(zsh -fc '
  export DOTFILES_DIR="'"$DOTFILES_DIR"'"
  export HOME="${HOME:-/tmp/dotfiles-configman-apply-home}"
  mkdir -p "$HOME"
  source "'"$DOTFILES_DIR"'/zsh/functions/configman.zsh"
  configman apply shell --dry-run
')

printf '%s\n' "$out"

echo "$out" | grep -q 'Ré-application shell/prompt dotfiles' || {
    echo "configman apply: section attendue absente" >&2
    exit 1
}
echo "$out" | grep -q 'dry-run' || {
    echo "configman apply: mode dry-run non détecté" >&2
    exit 1
}

root_out=$(zsh -fc '
  export DOTFILES_DIR="'"$DOTFILES_DIR"'"
  export HOME="${HOME:-/tmp/dotfiles-configman-apply-home}"
  export ROOT_HOME="${ROOT_HOME:-/tmp/dotfiles-root-home}"
  export DOTFILES_MANAGER_SHIM_DIR="${DOTFILES_MANAGER_SHIM_DIR:-/tmp/dotfiles-shims}"
  mkdir -p "$HOME" "$ROOT_HOME" "$DOTFILES_MANAGER_SHIM_DIR"
  source "'"$DOTFILES_DIR"'/zsh/functions/configman.zsh"
  configman apply root --dry-run
')

printf '%s\n' "$root_out"

echo "$root_out" | grep -q 'Ré-application root/sudo dotfiles' || {
    echo "configman apply root: section attendue absente" >&2
    exit 1
}
echo "$root_out" | grep -q 'diskman' || {
    echo "configman apply root: shim diskman non détecté" >&2
    exit 1
}

echo "configman_apply_smoke: OK"
