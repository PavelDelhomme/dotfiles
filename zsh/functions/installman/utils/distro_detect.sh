#!/bin/zsh
# =============================================================================
# DISTRO DETECT — délégation vers core/lib/distro.sh (source unique)
# =============================================================================

detect_distro() {
    local _dd_df="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_dd_df/core/lib/distro.sh" ]; then
        # shellcheck source=../../../../core/lib/distro.sh
        . "$_dd_df/core/lib/distro.sh"
        dotfiles_detect_distro
        return 0
    fi
    [ -f /etc/arch-release ] && { echo arch; return 0; }
    [ -f /etc/debian_version ] && { echo debian; return 0; }
    echo unknown
}

detect_distro_pretty() {
    local _dd_df="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_dd_df/core/lib/distro.sh" ]; then
        . "$_dd_df/core/lib/distro.sh"
        dotfiles_detect_distro_pretty
        return 0
    fi
    detect_distro
}
