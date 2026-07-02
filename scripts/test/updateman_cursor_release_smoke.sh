#!/usr/bin/env bash
# Smoke updateman cursor release — non destructif (API + check, pas de telechargement).
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOTFILES_DIR"

. "$DOTFILES_DIR/core/lib/tool_release.sh"
tool_release_cursor_fetch
[ -n "${TOOL_RELEASE_VERSION:-}" ] || { echo "FAIL: version vide"; exit 1; }
[ -n "${TOOL_RELEASE_URL:-}" ] || { echo "FAIL: URL vide"; exit 1; }
case "$TOOL_RELEASE_URL" in
    https://downloads.cursor.com/*|https://*.cursor.com/*|https://api2.cursor.sh/*) ;;
    *) echo "FAIL: URL inattendue: $TOOL_RELEASE_URL"; exit 1 ;;
esac
echo "OK tool_release cursor $TOOL_RELEASE_VERSION"

. "$DOTFILES_DIR/core/managers/updateman/core/updateman.sh"
updateman cursor check </dev/null >/dev/null
echo "OK updateman cursor check"

echo "OK smoke cursor release"
