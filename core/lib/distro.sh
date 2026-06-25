#!/bin/sh
# Detection distro POSIX — source unique pour installman/updateman/scripts.
# Usage : . core/lib/distro.sh && dotfiles_detect_distro

dotfiles_detect_distro() {
    _dd_id="unknown"
    _dd_like=""
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        _dd_id="${ID:-unknown}"
        _dd_like="${ID_LIKE:-}"
        _dd_id=$(printf '%s' "$_dd_id" | tr '[:upper:]' '[:lower:]')
        _dd_like=$(printf '%s' "$_dd_like" | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/alpine-release ]; then
        _dd_id="alpine"
    elif [ -f /etc/arch-release ]; then
        _dd_id="arch"
    elif [ -f /etc/debian_version ]; then
        _dd_id="debian"
    elif [ -f /etc/fedora-release ]; then
        _dd_id="fedora"
    elif [ -f /etc/centos-release ]; then
        _dd_id="centos"
    fi

    case "$_dd_id" in
        archlinux) _dd_id="arch" ;;
        manjaro|endeavouros|garuda) _dd_id="arch" ;;
        ubuntu|linuxmint|pop|pop-os|elementary|zorin) _dd_id="debian" ;;
        debian|kali|parrot|raspbian) _dd_id="debian" ;;
        fedora) _dd_id="fedora" ;;
        rhel|centos|rocky|almalinux|mariner|cbl-mariner|azurelinux|photon|ol|oraclelinux) _dd_id="rhel" ;;
        opensuse-leap|opensuse-tumbleweed|opensuse|sles|sled|sle-micro) _dd_id="opensuse" ;;
        gentoo) _dd_id="gentoo" ;;
        alpine) _dd_id="alpine" ;;
        flatcar|coreos|fedora-coreos) _dd_id="immutable" ;;
        unknown)
            case "$_dd_like" in
                *arch*) _dd_id="arch" ;;
                *debian*|*ubuntu*) _dd_id="debian" ;;
                *fedora*|*rhel*|*centos*) _dd_id="rhel" ;;
                *suse*) _dd_id="opensuse" ;;
            esac
            ;;
    esac
    printf '%s' "$_dd_id"
}

dotfiles_detect_distro_pretty() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        if [ -n "${PRETTY_NAME:-}" ]; then
            printf '%s' "$PRETTY_NAME"
            return 0
        fi
    fi
    dotfiles_detect_distro
}
