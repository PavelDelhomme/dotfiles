#!/bin/zsh
# =============================================================================
# Confirmation installman (évite les actions destructrices sans accord)
# =============================================================================
# Si INSTALLMAN_ASSUME_YES=1, DOTFILES_NONINTERACTIVE=1 ou CI est défini :
#   toutes les confirmations sont acceptées (tests Docker / scripts).
# =============================================================================

# DESC: Demande confirmation (sauf mode non interactif)
# USAGE: installman_confirm "Message"
# RETURNS: 0 = oui, 1 = non
installman_confirm() {
    local msg="$1"
    if [[ -n "${INSTALLMAN_ASSUME_YES:-}" || -n "${DOTFILES_NONINTERACTIVE:-}" || -n "${CI:-}" ]]; then
        return 0
    fi
    local r
    printf '%s [o/N] ' "$msg"
    read -r r
    [[ "$r" == o || "$r" == O || "$r" == y || "$r" == Y ]]
}
