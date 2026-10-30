#!/bin/bash
# =============================================================================
# Doctor machine + dotfiles (sourçable / CLI)
# Utilisé par bin/dotfiles doctor
# =============================================================================

_df_doc_root() {
    if [ -n "${DOTFILES_DIR:-}" ] && [ -d "$DOTFILES_DIR/.git" -o -f "$DOTFILES_DIR/bootstrap.sh" ]; then
        printf '%s\n' "$DOTFILES_DIR"
        return 0
    fi
    for cand in \
        "${HOME:-}/dotfiles" \
        /root/dotfiles \
        /opt/dotfiles
    do
        if [ -d "$cand/.git" ] || [ -f "$cand/bootstrap.sh" ]; then
            printf '%s\n' "$cand"
            return 0
        fi
    done
    # depuis ce fichier : scripts/lib → repo
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
    if [ -n "$here" ] && { [ -d "$here/.git" ] || [ -f "$here/bootstrap.sh" ]; }; then
        printf '%s\n' "$here"
        return 0
    fi
    return 1
}

df_doctor_context() {
    echo "Contexte"
    echo "  user=$(id -un) uid=$(id -u)  shell=${SHELL:-?}  cwd=$(pwd)"
    echo "  tty=$([ -t 0 ] && echo yes || echo no)  TERM=${TERM:-?}"
    echo "  session=${XDG_SESSION_TYPE:-?}  desktop=${XDG_CURRENT_DESKTOP:-?}"
    echo "  DOTFILES_DIR=${DOTFILES_DIR:-?(non défini)}"
    if command -v detect_distro >/dev/null 2>&1; then
        echo "  distro=$(detect_distro)"
    elif [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release 2>/dev/null
        echo "  distro=${ID:-?} ${VERSION_ID:-}"
    fi
    echo ""
}

df_doctor_repo() {
    local root="$1" bad=0
    echo "Dépôt dotfiles"
    if [ -z "$root" ]; then
        echo "  ✗ introuvable (attendu ~/dotfiles)"
        echo ""
        return 1
    fi
    echo "  ✓ $root"
    if [ -d "$root/.git" ]; then echo "  ✓ .git"; else echo "  ⚠ pas de .git"; bad=1; fi
    if [ -f "$root/bootstrap.sh" ]; then echo "  ✓ bootstrap.sh"; else echo "  ✗ bootstrap.sh"; bad=1; fi
    if [ -f "$root/scripts/install/system/base_profile.sh" ]; then echo "  ✓ base_profile.sh"; else echo "  ⚠ base_profile absent"; fi
    if [ -L "${HOME:-}/.zshrc" ] || [ -f "${HOME:-}/.zshrc" ]; then echo "  · ~/.zshrc présent"; else echo "  ⚠ ~/.zshrc absent"; fi
    [ -f "${HOME:-}/.config/fish/config.fish" ] && echo "  · fish config présent"
    echo ""
    return "$bad"
}

df_doctor_critical_bins() {
    # Minimum pour bootstrap / managers sans GUI
    local bins="git curl wget make bash"
    local b miss=0
    echo "Binaires critiques (fresh install / bootstrap)"
    for b in $bins; do
        if command -v "$b" >/dev/null 2>&1; then
            echo "  ✓ $b → $(command -v "$b")"
        else
            echo "  ✗ $b"
            miss=$((miss+1))
        fi
    done
    echo ""
    return "$miss"
}

df_doctor_managers_in_path() {
    local sample="netman installman updateman pathman helpman"
    local m found=0
    echo "Managers dans PATH (shims ou fonctions)"
    for m in $sample; do
        if command -v "$m" >/dev/null 2>&1; then
            echo "  ✓ $m → $(command -v "$m")"
            found=$((found+1))
        else
            # fonction shell ?
            if type "$m" >/dev/null 2>&1; then
                echo "  ~ $m (fonction shell — OK dans ce shell, pas sous sudo)"
                found=$((found+1))
            else
                echo "  ✗ $m"
            fi
        fi
    done
    if [ "$found" -eq 0 ]; then
        echo "  → Installe les shims:  dotfiles shims install"
        echo "    ou: bash \"\$DOTFILES_DIR/scripts/bootstrap/install_manager_shims.sh\" --apply --yes --all"
        echo "        DOTFILES_MANAGER_SHIM_DIR=\$HOME/.local/bin"
    fi
    echo ""
}

df_doctor_session() {
    local miss=0
    echo "Session graphique / display manager"
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "  (pas de systemd — skip)"
        echo ""
        return 0
    fi
    local dm=""
    for u in sddm.service gdm.service lightdm.service; do
        if systemctl is-enabled "$u" >/dev/null 2>&1; then
            echo "  enabled: $u"
            dm="$u"
        fi
    done
    [ -z "$dm" ] && echo "  ⚠ aucun display-manager enabled"
    local n_dm=0
    command -v pacman >/dev/null 2>&1 && n_dm=$(pacman -Qq sddm gdm lightdm 2>/dev/null | wc -l)
    n_dm=${n_dm//[[:space:]]/}
    if [ -n "$n_dm" ] && [ "$n_dm" -gt 1 ]; then
        echo "  ⚠ plusieurs DM installés ($n_dm) — greeter confus (GNOME vs KDE)"
        pacman -Q sddm gdm lightdm 2>/dev/null | sed 's/^/    /'
        miss=$((miss+1))
    fi
    if [ -d /usr/share/wayland-sessions ]; then
        echo "  sessions Wayland:"
        ls /usr/share/wayland-sessions/*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/^/    /'
    fi
    if [ -d /usr/share/xsessions ]; then
        echo "  sessions X11:"
        ls /usr/share/xsessions/*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/^/    /'
    fi
    echo "  Astuce:  dotfiles session doctor | dotfiles session prefer-kde | prefer-gnome"
    echo ""
    return "$miss"
}

df_doctor_pacman_health() {
    command -v pacman >/dev/null 2>&1 || return 0
    echo "Santé pacman (Arch)"
    if [ -e /var/lib/pacman/db.lck ]; then
        echo "  ✗ verrou /var/lib/pacman/db.lck — update en cours ou crashée"
    else
        echo "  ✓ pas de verrou db.lck"
    fi
    local dl=0
    if [ -d /var/cache/pacman/pkg ]; then
        dl=$(find /var/cache/pacman/pkg -maxdepth 1 -type d -name 'download-*' 2>/dev/null | wc -l)
        dl=${dl//[[:space:]]/}
    fi
    if [ "$dl" -gt 0 ]; then
        echo "  ⚠ $dl dossier(s) download-* orphelins → updateman arch fix-cache"
    else
        echo "  ✓ cache download-* propre"
    fi
    echo ""
}

# Rapport complet ; code retour = nb de problèmes majeurs (cap 1 pour scripts)
df_doctor_run() {
    local root miss=0
    root="$(_df_doc_root)" || root=""
    export DOTFILES_DIR="${DOTFILES_DIR:-$root}"

    if [ -f "${DOTFILES_DIR:-}/scripts/lib/common.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/common.sh" 2>/dev/null || true
    fi

    echo "════════════════════════════════════════════════════════"
    echo "  DOTFILES DOCTOR"
    echo "════════════════════════════════════════════════════════"
    echo ""
    df_doctor_context
    if ! df_doctor_critical_bins; then miss=$((miss+1)); fi
    if ! df_doctor_repo "$DOTFILES_DIR"; then miss=$((miss+1)); fi

    if [ -n "${DOTFILES_DIR:-}" ] && [ -f "$DOTFILES_DIR/scripts/lib/base_profile_lib.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/base_profile_lib.sh"
        BP_ROOT="$DOTFILES_DIR"
        BP_DIR="$DOTFILES_DIR/share/profiles/base"
        if ! bp_doctor; then miss=$((miss+1)); fi
        echo ""
    else
        echo "Profil de base: indisponible (clone le dépôt ou DOTFILES_DIR=…)"
        echo ""
    fi

    df_doctor_managers_in_path
    if ! df_doctor_session; then miss=$((miss+1)); fi
    df_doctor_pacman_health

    echo "Résumé"
    if [ "$miss" -eq 0 ]; then
        echo "  ✓ rien de bloquant détecté"
        return 0
    fi
    echo "  ⚠ problèmes signalés — corrige avec:"
    echo "    dotfiles base install"
    echo "    dotfiles shims install"
    echo "    dotfiles session prefer-kde   # ou prefer-gnome"
    echo "    updateman arch fix-cache"
    return 1
}
