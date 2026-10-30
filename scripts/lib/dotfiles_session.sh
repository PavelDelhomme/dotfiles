#!/bin/bash
# Session / display-manager doctor + remédiation (Arch + systemd)
# Sourcé par bin/dotfiles

df_session_doctor() {
    echo "════════════════════════════════════════════════════════"
    echo "  SESSION / DISPLAY MANAGER"
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "Desktop actuel: ${XDG_CURRENT_DESKTOP:-?}  type=${XDG_SESSION_TYPE:-?}"
    echo "dmrc: $(grep -E '^Session=' "$HOME/.dmrc" 2>/dev/null || echo '(absent)')"
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
        printf "  %-18s enabled=%-12s active=%s\n" "$u" "$en" "$ac"
    done
    echo ""
    dm_link=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || echo '?')
    echo "display-manager → $dm_link"
    echo ""

    if command -v pacman >/dev/null 2>&1; then
        echo "Paquets DM/DE:"
        pacman -Q sddm gdm lightdm plasma-desktop gnome-shell openbox 2>/dev/null | sed 's/^/  /' || true
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

    # Diagnostic boucle login connue (LightDM X11 + GNOME Shell assert)
    if systemctl is-enabled lightdm.service >/dev/null 2>&1; then
        echo ""
        echo "⚠ LightDM enabled : greeter X11. Plasma est surtout Wayland →"
        echo "  sessions GNOME X11 peuvent planter (assert gnome-shell) → retour login."
        echo "  → dotfiles session prefer-kde   # SDDM + Plasma"
        echo "  Urgence graphique: choisir « Openbox (urgence) » au greeter."
    fi
    if systemctl is-enabled sddm.service >/dev/null 2>&1; then
        echo ""
        echo "Au greeter SDDM tu peux choisir: Plasma / GNOME / Openbox (urgence)."
        echo "GDM reste installé mais disabled (dotfiles session prefer-gnome pour basculer)."
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
    # GDM souvent masked après incident multi-DM
    if [ "$want" = "gdm" ]; then
        _run systemctl unmask gdm.service 2>/dev/null || true
    fi
    echo "Activation de ${want}.service (disable des autres)…"
    for u in sddm gdm lightdm; do
        if [ "$u" = "$want" ]; then
            _run systemctl enable "$u.service" 2>/dev/null || true
        else
            _run systemctl disable "$u.service" 2>/dev/null || true
        fi
    done
    # Session par défaut utilisateur
    if [ -n "${HOME:-}" ] && [ "$(id -u)" -ne 0 ]; then
        printf '%s\n' '[Desktop]' 'Session=plasma' >"$HOME/.dmrc" 2>/dev/null || true
        if [ "$want" = "gdm" ] || [ "${1:-}" = "gnome-force" ]; then
            printf '%s\n' '[Desktop]' 'Session=gnome' >"$HOME/.dmrc" 2>/dev/null || true
        fi
    fi
    echo "OK. Appliqué au prochain boot (ne coupe pas la session courante)."
    echo "  sudo systemctl isolate ${want}.service   # bascule immédiate (ferme le bureau)"
    echo "  # ou reboot"
}

df_session_prefer_kde() {
    echo "Cible: Plasma (KDE) + SDDM — GNOME reste sélectionnable au greeter"
    if command -v pacman >/dev/null 2>&1; then
        if ! pacman -Q plasma-desktop >/dev/null 2>&1; then
            echo "plasma-desktop absent — installe: sudo pacman -S plasma-desktop sddm"
        fi
        # Session urgence
        if ! pacman -Q openbox >/dev/null 2>&1; then
            echo "Install openbox (session urgence minimale)…"
            sudo pacman -S --needed --noconfirm openbox || true
        fi
        if [ ! -f /usr/share/xsessions/openbox-emergency.desktop ]; then
            sudo tee /usr/share/xsessions/openbox-emergency.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Openbox (urgence)
Comment=Session graphique minimale pour dépannage
Exec=openbox-session
TryExec=openbox
Type=Application
DesktopNames=Openbox
EOF
        fi
        if pacman -Q sddm >/dev/null 2>&1; then
            # garder GDM installé mais disabled (parallèle au besoin)
            sudo systemctl unmask gdm.service 2>/dev/null || true
            df_session_enable_dm sddm
            printf '%s\n' '[Desktop]' 'Session=plasma' >"${HOME:-/tmp}/.dmrc"
            if [ -d /var/lib/AccountsService/users ]; then
                sudo tee /var/lib/AccountsService/users/"${USER:-pactivisme}" >/dev/null <<EOF
[User]
Session=plasma
XSession=plasma
SystemAccount=false
EOF
            fi
        elif pacman -Q lightdm >/dev/null 2>&1; then
            echo "SDDM absent, fallback LightDM (risque boucle si GNOME X11 cassé)"
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
    echo "Cible: GNOME + GDM (Plasma reste installé, bascule au greeter après prefer-kde)"
    if command -v pacman >/dev/null 2>&1; then
        if ! pacman -Q gnome-shell >/dev/null 2>&1; then
            echo "gnome-shell absent — installe: sudo pacman -S gnome gdm"
        fi
        if pacman -Q gdm >/dev/null 2>&1; then
            df_session_enable_dm gdm
            printf '%s\n' '[Desktop]' 'Session=gnome' >"${HOME:-/tmp}/.dmrc"
        else
            echo "GDM absent. sudo pacman -S gdm && dotfiles session prefer-gnome"
            return 1
        fi
    else
        df_session_enable_dm gdm
    fi
}

df_session_ensure_emergency() {
    echo "Session urgence Openbox…"
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm openbox || true
    fi
    sudo tee /usr/share/xsessions/openbox-emergency.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Openbox (urgence)
Comment=Session graphique minimale pour dépannage
Exec=openbox-session
TryExec=openbox
Type=Application
DesktopNames=Openbox
EOF
    echo "✓ Choisis « Openbox (urgence) » sur l'écran de login si Plasma/GNOME cassés."
}
