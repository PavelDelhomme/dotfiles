#!/bin/bash
# =============================================================================
# Bibliothèque profil machine de base (déclaratif multi-distro)
# Source : scripts/install/system/base_profile.sh · packages_base.sh
# =============================================================================

# Ne pas set -e ici (sourcé)

_bp_dotfiles_root() {
    if [ -n "${DOTFILES_DIR:-}" ] && [ -d "$DOTFILES_DIR/share/profiles/base" ]; then
        printf '%s\n' "$DOTFILES_DIR"
        return 0
    fi
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    printf '%s\n' "$here"
}

BP_ROOT="${BP_ROOT:-$(_bp_dotfiles_root)}"
BP_DIR="${BP_DIR:-$BP_ROOT/share/profiles/base}"

bp_family() {
    case "$(detect_distro 2>/dev/null || echo unknown)" in
        arch|manjaro) echo arch ;;
        debian|ubuntu) echo debian ;;
        fedora) echo fedora ;;
        gentoo) echo gentoo ;;
        *) echo unknown ;;
    esac
}

bp_profile_name() {
    if [ "${DOTFILES_HEADLESS:-0}" = "1" ]; then
        echo headless
        return
    fi
    echo "${DOTFILES_BASE_PROFILE:-desktop}"
}

bp_pkg_for() {
    # $1 = key → paquet pour la famille courante
    local key="$1"
    local fam col line
    fam="$(bp_family)"
    case "$fam" in
        arch) col=2 ;;
        debian) col=3 ;;
        fedora) col=4 ;;
        gentoo) col=5 ;;
        *) col=3 ;;
    esac
    [ -f "$BP_DIR/pkgmap.conf" ] || { echo "$key"; return 0; }
    line=$(grep -E "^${key}\\|" "$BP_DIR/pkgmap.conf" 2>/dev/null | head -1)
    if [ -z "$line" ]; then
        echo "$key"
        return 0
    fi
    # shellcheck disable=SC2086
    printf '%s\n' "$line" | cut -d'|' -f"$col"
}

bp_read_keys_file() {
    # stdout: clés non vides, sans commentaires
    local f="$1"
    [ -f "$f" ] || return 0
    grep -vE '^\s*(#|$)' "$f" | sed 's/[[:space:]]//g'
}

bp_list_keys() {
    # Liste ordonnée des clés à traiter (universal + gui? + family.extra)
    local profile
    profile="$(bp_profile_name)"
    bp_read_keys_file "$BP_DIR/universal.bins"
    if [ "$profile" != "headless" ]; then
        bp_read_keys_file "$BP_DIR/gui.bins"
    fi
    case "$(bp_family)" in
        arch) bp_read_keys_file "$BP_DIR/arch.extra" ;;
        debian) bp_read_keys_file "$BP_DIR/debian.extra" ;;
        fedora) bp_read_keys_file "$BP_DIR/fedora.extra" ;;
        gentoo) bp_read_keys_file "$BP_DIR/gentoo.extra" ;;
    esac
}

bp_bin_ok() {
    command -v "$1" >/dev/null 2>&1
}

# Méta-clés sans binaire unique
bp_is_meta_key() {
    case "$1" in
        base-devel|zsh-theme-powerlevel10k|snapd|yay|paru|flatpak) return 0 ;;
        *) return 1 ;;
    esac
}

bp_meta_ok() {
    local key="$1"
    case "$key" in
        base-devel)
            bp_bin_ok gcc && bp_bin_ok make && return 0
            return 1
            ;;
        zsh-theme-powerlevel10k)
            [ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ] \
                || [ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ] \
                || [ -f /usr/share/zsh/manjaro-zsh-prompt ] \
                && return 0
            return 1
            ;;
        snapd)
            bp_bin_ok snap && return 0
            return 1
            ;;
        flatpak)
            bp_bin_ok flatpak && return 0
            return 1
            ;;
        yay|paru)
            bp_bin_ok "$key" && return 0
            return 1
            ;;
        *)
            bp_bin_ok "$key" && return 0
            return 1
            ;;
    esac
}

bp_key_ok() {
    local key="$1"
    if bp_is_meta_key "$key"; then
        bp_meta_ok "$key"
    else
        bp_bin_ok "$key"
    fi
}

bp_install_pkg() {
    local pkg="$1"
    local fam
    [ -n "$pkg" ] || return 1
    fam="$(bp_family)"
    case "$fam" in
        arch)
            sudo pacman -S --noconfirm --needed "$pkg"
            ;;
        debian)
            sudo apt-get update -qq
            sudo apt-get install -y "$pkg"
            ;;
        fedora)
            sudo dnf install -y "$pkg"
            ;;
        gentoo)
            if command -v emerge >/dev/null 2>&1; then
                sudo emerge --ask=n --quiet-build=y "$pkg"
            else
                log_warn "emerge introuvable"
                return 1
            fi
            ;;
        *)
            log_warn "Famille distro inconnue — installez manuellement: $pkg"
            return 1
            ;;
    esac
}

bp_need_key() {
    local key="$1"
    local pkg
    if bp_key_ok "$key"; then
        log_skip "$key déjà OK"
        return 0
    fi
    pkg="$(bp_pkg_for "$key")"
    if [ -z "$pkg" ]; then
        log_warn "$key : pas de paquet mappé pour $(bp_family) — skip"
        return 1
    fi
    log_info "Installation $pkg (clé $key)…"
    if bp_install_pkg "$pkg"; then
        if bp_key_ok "$key" || bp_is_meta_key "$key"; then
            log_info "✓ $key ($pkg)"
            return 0
        fi
        # Certains paquets (wl-clipboard) optionnels si Wayland absent
        log_warn "$pkg installé mais « $key » toujours absent (peut être OK)"
        return 0
    fi
    log_warn "Échec $pkg"
    return 1
}

bp_install_aur_helper() {
    local helper="${DOTFILES_AUR_HELPER:-yay}"
    local fam
    fam="$(bp_family)"
    [ "$fam" = "arch" ] || return 0
    case "$helper" in
        none) log_skip "AUR helper désactivé (DOTFILES_AUR_HELPER=none)"; return 0 ;;
        yay|paru|both) ;;
        *) helper=yay ;;
    esac
    _bp_install_one_aur() {
        local name="$1"
        if bp_bin_ok "$name"; then
            log_skip "$name déjà installé"
            return 0
        fi
        log_info "Installation AUR helper: $name…"
        sudo pacman -S --needed --noconfirm git base-devel || true
        local tmp="/tmp/${name}-$$"
        rm -rf "$tmp"
        if git clone "https://aur.archlinux.org/${name}.git" "$tmp" 2>/dev/null; then
            ( cd "$tmp" && makepkg -si --noconfirm ) && log_info "✓ $name" || log_warn "Échec makepkg $name"
            rm -rf "$tmp"
        else
            log_warn "Clone AUR $name échoué"
        fi
    }
    case "$helper" in
        yay) _bp_install_one_aur yay ;;
        paru) _bp_install_one_aur paru ;;
        both) _bp_install_one_aur yay; _bp_install_one_aur paru ;;
    esac
}

bp_install_flatpak_snap() {
    local fam
    fam="$(bp_family)"
    if [ "${DOTFILES_WANT_FLATPAK:-1}" = "1" ]; then
        if ! bp_bin_ok flatpak; then
            bp_need_key flatpak || true
        else
            log_skip "flatpak déjà présent"
        fi
        if bp_bin_ok flatpak; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        fi
    fi
    if [ "${DOTFILES_WANT_SNAP:-1}" = "1" ]; then
        if bp_bin_ok snap; then
            log_skip "snap déjà présent"
            sudo systemctl enable --now snapd.socket 2>/dev/null || true
        else
            case "$fam" in
                arch|debian|fedora)
                    bp_need_key snapd || true
                    if bp_bin_ok snap || [ -x /usr/bin/snap ]; then
                        sudo systemctl enable --now snapd.socket 2>/dev/null || true
                        sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
                        log_info "✓ snapd"
                    fi
                    ;;
                gentoo)
                    log_warn "snapd non mappé sous Gentoo — skip"
                    ;;
            esac
        fi
    fi
}

bp_maybe_set_default_shell() {
    [ "${DOTFILES_SET_DEFAULT_SHELL:-0}" = "1" ] || return 0
    local want="${DOTFILES_DEFAULT_SHELL:-zsh}"
    local path
    path="$(command -v "$want" 2>/dev/null || true)"
    if [ -z "$path" ]; then
        log_warn "Shell $want introuvable — chsh ignoré"
        return 1
    fi
    if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$path" ]; then
        log_skip "Shell par défaut déjà $path"
        return 0
    fi
    if command -v chsh >/dev/null 2>&1; then
        log_info "chsh -s $path…"
        chsh -s "$path" && log_info "✓ shell par défaut → $want (relogin)" || log_warn "chsh a échoué"
    else
        log_warn "chsh absent"
    fi
}

bp_plan() {
    local key pkg
    printf "Profil: %s  ·  Famille: %s  ·  Distro: %s\n" \
        "$(bp_profile_name)" "$(bp_family)" "$(detect_distro)"
    printf "AUR helper: %s  ·  flatpak=%s  ·  snap=%s  ·  chsh=%s\n\n" \
        "${DOTFILES_AUR_HELPER:-yay}" "${DOTFILES_WANT_FLATPAK:-1}" \
        "${DOTFILES_WANT_SNAP:-1}" "${DOTFILES_SET_DEFAULT_SHELL:-0}"
    printf "%-14s %-28s %s\n" "CLÉ" "PAQUET" "ÉTAT"
    printf "%-14s %-28s %s\n" "----" "------" "----"
    while IFS= read -r key; do
        [ -n "$key" ] || continue
        pkg="$(bp_pkg_for "$key")"
        if bp_key_ok "$key"; then
            printf "%-14s %-28s %s\n" "$key" "${pkg:--}" "OK"
        else
            printf "%-14s %-28s %s\n" "$key" "${pkg:-(aucun)}" "MANQUANT"
        fi
    done < <(bp_list_keys | awk 'NF && !seen[$0]++')
}

bp_doctor() {
    local key missing=0
    log_section "Doctor profil de base ($(bp_profile_name) / $(bp_family))"
    while IFS= read -r key; do
        [ -n "$key" ] || continue
        if bp_key_ok "$key"; then
            printf "  ${GREEN}✓${NC} %s\n" "$key"
        else
            printf "  ${RED}✗${NC} %s  →  %s\n" "$key" "$(bp_pkg_for "$key")"
            missing=$((missing + 1))
        fi
    done < <(bp_list_keys | awk 'NF && !seen[$0]++')

    echo ""
    if [ "${DOTFILES_WANT_FLATPAK:-1}" = "1" ]; then
        if bp_bin_ok flatpak; then printf "  ${GREEN}✓${NC} flatpak\n"; else printf "  ${RED}✗${NC} flatpak\n"; missing=$((missing+1)); fi
    fi
    if [ "${DOTFILES_WANT_SNAP:-1}" = "1" ]; then
        if bp_bin_ok snap; then printf "  ${GREEN}✓${NC} snap\n"; else printf "  ${YELLOW}⚠${NC} snap (optionnel selon distro)\n"; fi
    fi
    if [ "$(bp_family)" = "arch" ]; then
        case "${DOTFILES_AUR_HELPER:-yay}" in
            none) ;;
            paru) bp_bin_ok paru && printf "  ${GREEN}✓${NC} paru\n" || { printf "  ${RED}✗${NC} paru\n"; missing=$((missing+1)); } ;;
            both)
                bp_bin_ok yay && printf "  ${GREEN}✓${NC} yay\n" || { printf "  ${RED}✗${NC} yay\n"; missing=$((missing+1)); }
                bp_bin_ok paru && printf "  ${GREEN}✓${NC} paru\n" || { printf "  ${RED}✗${NC} paru\n"; missing=$((missing+1)); }
                ;;
            *) bp_bin_ok yay && printf "  ${GREEN}✓${NC} yay\n" || { printf "  ${RED}✗${NC} yay\n"; missing=$((missing+1)); } ;;
        esac
    fi

    echo ""
    if [ "$missing" -eq 0 ]; then
        log_info "✓ Profil de base complet ($missing manquant)"
        return 0
    fi
    log_warn "$missing élément(s) manquant(s) — lance: make base   ou   base_profile.sh install"
    return 1
}

bp_install_core() {
    local key
    log_section "Installation profil de base ($(bp_profile_name) / $(bp_family))"
    while IFS= read -r key; do
        [ -n "$key" ] || continue
        # gui optionnels : ne pas échouer fort
        case "$key" in
            wl-clipboard|xclip)
                bp_need_key "$key" || true
                ;;
            unrar|hwinfo|fastfetch|sshpass)
                bp_need_key "$key" || true
                ;;
            *)
                bp_need_key "$key" || true
                ;;
        esac
    done < <(bp_list_keys | awk 'NF && !seen[$0]++')
}

bp_install_all() {
    bp_install_core
    bp_install_aur_helper
    bp_install_flatpak_snap
    bp_maybe_set_default_shell
    echo ""
    bp_doctor || true
}
