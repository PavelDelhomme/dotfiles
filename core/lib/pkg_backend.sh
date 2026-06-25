#!/bin/sh
# Backends paquets POSIX — refresh / pending / upgrade multi-distro.
# Requiert : core/lib/distro.sh

_pkg_df="${DOTFILES_DIR:-$HOME/dotfiles}"
[ -f "$_pkg_df/core/lib/distro.sh" ] && . "$_pkg_df/core/lib/distro.sh"

pkg_backend_list() {
    _pb_distro="$(dotfiles_detect_distro 2>/dev/null || echo unknown)"
    _pb_out=""
    _pb_add() {
        case " $_pb_out " in
            *" $1 "*) ;;
            *) _pb_out="${_pb_out}${_pb_out:+ }$1" ;;
        esac
    }

    case "$_pb_distro" in
        arch)
            command -v pacman >/dev/null 2>&1 && _pb_add pacman
            command -v yay >/dev/null 2>&1 && _pb_add yay
            command -v paru >/dev/null 2>&1 && _pb_add paru
            ;;
        debian)
            command -v apt-get >/dev/null 2>&1 && _pb_add apt
            ;;
        fedora|rhel)
            command -v dnf >/dev/null 2>&1 && _pb_add dnf
            command -v microdnf >/dev/null 2>&1 && _pb_add microdnf
            command -v tdnf >/dev/null 2>&1 && _pb_add tdnf
            command -v yum >/dev/null 2>&1 && _pb_add yum
            ;;
        alpine)
            command -v apk >/dev/null 2>&1 && _pb_add apk
            ;;
        opensuse)
            command -v zypper >/dev/null 2>&1 && _pb_add zypper
            ;;
        gentoo)
            command -v emerge >/dev/null 2>&1 && _pb_add emerge
            ;;
        immutable)
            command -v rpm-ostree >/dev/null 2>&1 && _pb_add rpm-ostree
            ;;
        unknown)
            command -v pacman >/dev/null 2>&1 && _pb_add pacman
            command -v apt-get >/dev/null 2>&1 && _pb_add apt
            command -v dnf >/dev/null 2>&1 && _pb_add dnf
            command -v apk >/dev/null 2>&1 && _pb_add apk
            command -v zypper >/dev/null 2>&1 && _pb_add zypper
            ;;
    esac

    command -v flatpak >/dev/null 2>&1 && _pb_add flatpak
    command -v snap >/dev/null 2>&1 && _pb_add snap

    printf '%s' "$_pb_out"
}

pkg_backend_refresh() {
    _pb="$1"
    case "$_pb" in
        pacman)
            if [ "$(id -u)" -eq 0 ]; then pacman -Sy --noconfirm; else sudo pacman -Sy --noconfirm; fi
            ;;
        yay|paru)
            "$_pb" -Sy --noconfirm 2>/dev/null || "$_pb" -Sy
            ;;
        apt)
            if [ "$(id -u)" -eq 0 ]; then apt-get update; else sudo apt-get update; fi
            ;;
        dnf|tdnf|microdnf)
            if [ "$(id -u)" -eq 0 ]; then "$_pb" makecache -y; else sudo "$_pb" makecache -y; fi
            ;;
        yum)
            if [ "$(id -u)" -eq 0 ]; then yum makecache -y; else sudo yum makecache -y; fi
            ;;
        apk)
            if [ "$(id -u)" -eq 0 ]; then apk update; else sudo apk update; fi
            ;;
        zypper)
            if [ "$(id -u)" -eq 0 ]; then zypper --non-interactive refresh; else sudo zypper --non-interactive refresh; fi
            ;;
        emerge)
            if [ "$(id -u)" -eq 0 ]; then emerge --sync; else sudo emerge --sync; fi
            ;;
        flatpak)
            flatpak update --appstream 2>/dev/null || flatpak update --appstream-data-only 2>/dev/null || true
            ;;
        snap)
            true
            ;;
        rpm-ostree)
            printf 'rpm-ostree: refresh via « rpm-ostree upgrade » (immutable OS)\n' >&2
            return 0
            ;;
        *)
            printf 'pkg_backend_refresh: backend inconnu: %s\n' "$_pb" >&2
            return 2
            ;;
    esac
}

pkg_backend_pending() {
    _pb="$1"
    _pb_out=""
    case "$_pb" in
        pacman)
            _pb_out=$(pacman -Qu 2>/dev/null || true)
            ;;
        yay)
            _pb_out=$(yay -Qua 2>/dev/null || true)
            ;;
        paru)
            _pb_out=$(paru -Qua 2>/dev/null || true)
            ;;
        apt)
            _pb_out=$(apt list --upgradable 2>/dev/null | sed '1d' || true)
            ;;
        dnf|tdnf|microdnf)
            _pb_out=$("$_pb" -q check-update 2>/dev/null || true)
            ;;
        yum)
            _pb_out=$(yum -q check-update 2>/dev/null || true)
            ;;
        apk)
            _pb_out=$(apk version -l '<' 2>/dev/null || true)
            ;;
        zypper)
            _pb_out=$(zypper -n list-updates 2>/dev/null || true)
            ;;
        emerge)
            _pb_out=$(emerge -puDN --with-bdeps=y @world 2>/dev/null | grep -E '^\[(ebuild|binary)' || true)
            ;;
        flatpak)
            _pb_out=$(flatpak remote-ls --updates 2>/dev/null || true)
            ;;
        snap)
            _pb_out=$(snap refresh --list 2>/dev/null | sed '1d' || true)
            ;;
        rpm-ostree)
            _pb_out=$(rpm-ostree status 2>/dev/null || true)
            ;;
        *)
            return 2
            ;;
    esac
  if [ -n "$_pb_out" ]; then
    printf '%s\n' "$_pb_out"
    return 0
  fi
  return 1
}

pkg_backend_upgrade() {
    _pb="$1"
    case "$_pb" in
        pacman)
            if [ "$(id -u)" -eq 0 ]; then
                printf 'Refus: lance pacman en utilisateur normal.\n' >&2
                return 1
            fi
            sudo pacman -Syu --noconfirm
            ;;
        yay)
            if [ "$(id -u)" -eq 0 ]; then
                printf 'Refus: ne lance pas yay en root.\n' >&2
                return 1
            fi
            yay -Syu --noconfirm
            ;;
        paru)
            if [ "$(id -u)" -eq 0 ]; then
                printf 'Refus: ne lance pas paru en root.\n' >&2
                return 1
            fi
            paru -Syu --noconfirm
            ;;
        apt)
            if [ "$(id -u)" -eq 0 ]; then
                apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
            else
                sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
            fi
            ;;
        dnf|tdnf|microdnf)
            if [ "$(id -u)" -eq 0 ]; then
                "$_pb" upgrade --refresh -y
            else
                sudo "$_pb" upgrade --refresh -y
            fi
            ;;
        yum)
            if [ "$(id -u)" -eq 0 ]; then yum update -y; else sudo yum update -y; fi
            ;;
        apk)
            if [ "$(id -u)" -eq 0 ]; then apk update && apk upgrade; else sudo apk update && sudo apk upgrade; fi
            ;;
        zypper)
            if [ "$(id -u)" -eq 0 ]; then zypper --non-interactive update; else sudo zypper --non-interactive update; fi
            ;;
        emerge)
            if [ "$(id -u)" -eq 0 ]; then emerge --sync && emerge -uDN --with-bdeps=y @world
            else sudo emerge --sync && sudo emerge -uDN --with-bdeps=y @world
            fi
            ;;
        flatpak)
            flatpak update -y
            ;;
        snap)
            if [ "$(id -u)" -eq 0 ]; then snap refresh; else sudo snap refresh; fi
            ;;
        rpm-ostree)
            rpm-ostree upgrade
            ;;
        *)
            return 2
            ;;
    esac
}

pkg_backend_refresh_all() {
    _rc=0
    for _b in $(pkg_backend_list); do
        printf '==> refresh %s\n' "$_b"
        pkg_backend_refresh "$_b" || _rc=1
    done
    return "$_rc"
}

pkg_backend_upgrade_all() {
    _rc=0
    _distro="$(dotfiles_detect_distro 2>/dev/null || echo unknown)"
    _list="$(pkg_backend_list)"
    _has() {
        case " $_list " in *" $1 "*) return 0 ;; *) return 1 ;; esac
    }
    _run() {
        printf '==> upgrade %s\n' "$1"
        pkg_backend_upgrade "$1" || _rc=1
    }

    case "$_distro" in
        arch)
            if _has yay; then _run yay
            elif _has paru; then _run paru
            elif _has pacman; then _run pacman
            fi
            ;;
        debian)
            _has apt && _run apt
            ;;
        fedora|rhel)
            if _has dnf; then _run dnf
            elif _has tdnf; then _run tdnf
            elif _has microdnf; then _run microdnf
            elif _has yum; then _run yum
            fi
            ;;
        alpine)
            _has apk && _run apk
            ;;
        opensuse)
            _has zypper && _run zypper
            ;;
        gentoo)
            _has emerge && _run emerge
            ;;
        immutable)
            _has rpm-ostree && _run rpm-ostree
            ;;
        *)
            for _b in pacman apt dnf apk zypper emerge; do
                _has "$_b" && _run "$_b"
            done
            ;;
    esac

    _has flatpak && _run flatpak
    _has snap && _run snap
    return "$_rc"
}
