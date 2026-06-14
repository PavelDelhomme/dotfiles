#!/bin/sh
# =============================================================================
# Aide CLI managers — sortie robuste (quota disque / TTY étroit)
# Convention 2026-06 :
#   manager              aide détaillée (stdout)
#   manager help | -h    idem
#   manager --help       idem (documentation uniquement, pas de menu)
#   manager menu         menu interactif (TTY requis)
#   manager help --interactive  aide + pause (TTY)
# =============================================================================

dotfiles_mgr_safe_out() {
    if ! printf '%s\n' "$@" 2>/dev/null; then
        printf '%s\n' "$@" >&2 2>/dev/null || true
    fi
}

dotfiles_mgr_is_tty() {
    [ -t 0 ] && [ -t 1 ]
}

dotfiles_mgr_require_tty() {
    _mgr_name="$1"
    if dotfiles_mgr_is_tty; then
        return 0
    fi
    printf '%s: nécessite un terminal (TTY). Utilisez « %s help » pour la doc.\n' "$_mgr_name" "$_mgr_name" >&2
    return 2
}
