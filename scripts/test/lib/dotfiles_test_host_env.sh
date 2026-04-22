#!/bin/sh
# shellcheck shell=sh
# =============================================================================
# Variables d'environnement pour les tests Docker (hôte)
# =============================================================================
# - dotfiles_test_load_user_env : source scripts/test/config/test.local.env
#   (ou DOTFILES_TEST_USER_ENV) pour définir TEST_SHELLS, TEST_MANAGERS, etc.
# - dotfiles_test_prepare_docker_mount : si TEST_DOTFILES_ISOLATE=1, copie le
#   dépôt vers un répertoire temporaire et exporte DOTFILES_DOCKER_MOUNT pour
#   le bind mount (le dépôt original n'est plus monté dans le conteneur).
# - dotfiles_test_isolate_cleanup : supprime la copie temporaire.
# =============================================================================

dotfiles_test_load_user_env() {
    _root="${DOTFILES_DIR:-$HOME/dotfiles}"
    _f="${DOTFILES_TEST_USER_ENV:-$_root/scripts/test/config/test.local.env}"
    if [ -f "$_f" ]; then
        printf '%s\n' "📎 Tests — configuration locale: $_f"
        set -a
        # shellcheck source=/dev/null
        . "$_f"
        set +a
    fi
}

dotfiles_test_prepare_docker_mount() {
    DOTFILES_DOCKER_MOUNT="${DOTFILES_DIR:-$HOME/dotfiles}"
    export DOTFILES_DOCKER_MOUNT
    if [ "${TEST_DOTFILES_ISOLATE:-0}" != "1" ]; then
        return 0
    fi
    _isol=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-isolate.XXXXXX") || return 1
    printf '%s\n' "🔒 TEST_DOTFILES_ISOLATE=1 — snapshot du dépôt → $_isol"
    printf '%s\n' "   (le conteneur ne monte plus directement votre arbre de travail)"
    if command -v rsync >/dev/null 2>&1; then
        if ! rsync -a "${DOTFILES_DIR}/" "${_isol}/" --exclude test_results; then
            rm -rf "$_isol"
            return 1
        fi
    else
        if ! (mkdir -p "$_isol" && (cd "${DOTFILES_DIR}" && tar cf - . 2>/dev/null) | (cd "$_isol" && tar xf -)); then
            rm -rf "$_isol"
            return 1
        fi
    fi
    DOTFILES_TEST_ISOLATE_DIR="$_isol"
    export DOTFILES_TEST_ISOLATE_DIR
    DOTFILES_DOCKER_MOUNT="$DOTFILES_TEST_ISOLATE_DIR"
    export DOTFILES_DOCKER_MOUNT
    return 0
}

dotfiles_test_isolate_cleanup() {
    if [ -n "${DOTFILES_TEST_ISOLATE_DIR:-}" ] && [ -d "$DOTFILES_TEST_ISOLATE_DIR" ]; then
        printf '%s\n' "🧹 Suppression du bac à sable: $DOTFILES_TEST_ISOLATE_DIR"
        rm -rf "$DOTFILES_TEST_ISOLATE_DIR"
        DOTFILES_TEST_ISOLATE_DIR=""
        export DOTFILES_TEST_ISOLATE_DIR
    fi
}
