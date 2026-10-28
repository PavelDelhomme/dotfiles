#!/bin/bash
# Session / display-manager doctor + remédiation (Arch + systemd)
# Sourcé par bin/dotfiles

df_session_doctor() {
    echo "════════════════════════════════════════════════════════"
    echo "  SESSION / DISPLAY MANAGER"
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "Desktop actuel: ${XDG_CURRENT_DESKTOP:-?}  type=${XDG_SESSION_TYPE:-?}"
    echo ""
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "systemd absent — skip"
        return 0
    fi

    echo "Display managers:"
    for u in sddm.service gdm.service lightdm.service; do
        en=$(systemctl is-enabled "$u" 2>/dev/null | head -1)
        ac=$(systemctl is-active "$u" 2>/dev/null | head -1)
        [ -n "$en" ] || en="absent"
        [ -n "$ac" ] || ac="inactive"
        # is-enabled renvoie exit 1 pour « disabled » — ne pas concaténer « absent »
        printf "  %-18s enabled=%-12s active=%s\n" "$u" "$en" "$ac"
    done
    echo ""

    if command -v pacman >/dev/null 2>&1; then
        echo "Paquets DM/DE:"
        pacman -Q sddm gdm lightdm plasma-desktop gnome-shell 2>/dev/null | sed 's/^/  /' || true
        echo ""
    fi

    echo "Sessions disponibles:"
    ls /usr/share/wayland-sessions/*.desktop /usr/share/xsessions/*.desktop 2>/dev/null \
        | xargs -n1 basename 2>/dev/null | sed 's/^/  /' || echo "  (aucune)"
    echo ""

    local n_en=0
    for u in sddm.service gdm.service lightdm.service; do
        systemctl is-enabled "$u" >/dev/null 2>&1 && n_en=$((n_en+1))
    done
    if [ "$n_en" -gt 1 ]; then
        echo "⚠ Plusieurs DM enabled ($n_en) — login imprévisible."
        echo "  → dotfiles session prefer-kde   ou   prefer-gnome"
    elif [ "$n_en" -eq 0 ]; then
        echo "⚠ Aucun DM enabled — pas d'écran de connexion au boot."
        echo "  → dotfiles session prefer-kde   ou   prefer-gnome"
    else
        echo "✓ Un seul DM enabled"
    fi
    echo ""
}

# Active un DM, désactive les autres. $1 = sddm|gdm|lightdm
df_session_enable_dm() {
    local want="$1"
    case "$want" in
        sddm|gdm|lightdm) ;;
        *) echo "DM inconnu: $want (sddm|gdm|lightdm)" >&2; return 1 ;;
    esac
    if [ "$(id -u)" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
        echo "root ou sudo requis" >&2
        return 1
    fi
    _run() {
        if [ "$(id -u)" -eq 0 ]; then "$@"
        else sudo "$@"
        fi
    }
    echo "Activation de ${want}.service (disable des autres)…"
    for u in sddm gdm lightdm; do
        if [ "$u" = "$want" ]; then
            _run systemctl enable "$u.service" 2>/dev/null || true
        else
            _run systemctl disable "$u.service" 2>/dev/null || true
        fi
    done
    echo "OK. Pour basculer maintenant (coupe la session graphique) :"
    echo "  sudo systemctl isolate ${want}.service"
    echo "  # ou reboot"
}

df_session_prefer_kde() {
    echo "Cible: Plasma (KDE) + SDDM (recommandé) ou LightDM si SDDM absent"
    if command -v pacman >/dev/null 2>&1; then
        if ! pacman -Q plasma-desktop >/dev/null 2>&1; then
            echo "plasma-desktop absent — installe: sudo pacman -S plasma-desktop sddm"
        fi
        if pacman -Q sddm >/dev/null 2>&1; then
            df_session_enable_dm sddm
        elif pacman -Q lightdm >/dev/null 2>&1; then
            echo "SDDM absent, fallback LightDM (choisis session Plasma au greeter)"
            df_session_enable_dm lightdm
        else
            echo "Aucun DM adapté. sudo pacman -S sddm && dotfiles session prefer-kde"
            return 1
        fi
    else
        df_session_enable_dm sddm
    fi
}

df_session_prefer_gnome() {
    echo "Cible: GNOME + GDM"
    if command -v pacman >/dev/null 2>&1; then
        if ! pacman -Q gnome-shell >/dev/null 2>&1; then
            echo "gnome-shell absent — installe: sudo pacman -S gnome gdm"
        fi
        if pacman -Q gdm >/dev/null 2>&1; then
            df_session_enable_dm gdm
        else
            echo "GDM absent. sudo pacman -S gdm && dotfiles session prefer-gnome"
            return 1
        fi
    else
        df_session_enable_dm gdm
    fi
}
