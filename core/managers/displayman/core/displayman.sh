#!/bin/sh
# =============================================================================
# DISPLAYMAN - Display / Monitor Manager (core POSIX)
# =============================================================================
# Description : pilote la luminosité, le contraste, le preset couleur et le
#               reset usine des écrans externes via DDC/CI (ddcutil), expose un
#               diagnostic Full/Limited range HDMI, restaure le layout multi-écrans
#               (hotplug DisplayPort / Philips) et guide l'OSD physique quand le
#               firmware refuse l'écriture.
# Auteur      : Paul Delhomme
# Convention  : aide / CLI alignée Bloc G de docs/TESTS.md (no-args / help / -h /
#               aide / help --interactive / --help, arg inconnu -> stderr + rc1).
# =============================================================================

# --- Détection shell (informative) -------------------------------------------
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire d'écran / luminosité / preset couleur (DDC/CI + OSD).
# USAGE: displayman [command] [args]
# EXAMPLE: displayman
# EXAMPLE: displayman detect
# EXAMPLE: displayman brightness 1 80
displayman() {
    # Couleurs ANSI (désactivées si stdout non-TTY ou NO_COLOR)
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m'); GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m'); BLUE=$(printf '\033[0;34m')
        CYAN=$(printf '\033[0;36m'); MAGENTA=$(printf '\033[0;35m')
        BOLD=$(printf '\033[1m');    RESET=$(printf '\033[0m')
    else
        RED= ; GREEN= ; YELLOW= ; BLUE= ; CYAN= ; MAGENTA= ; BOLD= ; RESET=
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    DISPLAYMAN_TIMEOUT="${DISPLAYMAN_DDC_TIMEOUT:-15}"

    # Profil layout connu (Xiaomi | Philips 245E1 | HP 2011) — surchargeable.
    # Géométrie cible : HDMI-A-1 (1920) | DP-1 (2560, primary) | HDMI-A-2 (1600)
    DM_LEFT="${DISPLAYMAN_LEFT:-HDMI-A-1}"
    DM_LEFT_MODE="${DISPLAYMAN_LEFT_MODE:-1920x1080@75}"
    DM_PRIMARY="${DISPLAYMAN_PRIMARY:-DP-1}"
    DM_PRIMARY_MODE="${DISPLAYMAN_PRIMARY_MODE:-2560x1440@75}"
    DM_RIGHT="${DISPLAYMAN_RIGHT:-HDMI-A-2}"
    DM_RIGHT_MODE="${DISPLAYMAN_RIGHT_MODE:-1600x900@60}"
    DM_LEFT_W="${DISPLAYMAN_LEFT_W:-1920}"
    DM_PRIMARY_W="${DISPLAYMAN_PRIMARY_W:-2560}"

    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_manager_load_ui_libs
    elif [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read _dummy
        fi
    }

    # --- Helpers DDC ---------------------------------------------------------
    _displayman_has_ddcutil() {
        command -v ddcutil >/dev/null 2>&1
    }

    _displayman_require_ddcutil() {
        if ! _displayman_has_ddcutil; then
            printf '%sdisplayman: ddcutil introuvable.%s\n' "$RED" "$RESET" >&2
            printf '  Installer (Arch) : sudo pacman -S ddcutil\n' >&2
            printf '  Installer (Debian/Ubuntu) : sudo apt install ddcutil\n' >&2
            return 1
        fi
        return 0
    }

    _displayman_ddcutil() {
        # Wrapper avec timeout et --noverify (firmware Xiaomi : verify échoue
        # mais l'écriture est appliquée — voir docs/ERRORS.md).
        timeout "$DISPLAYMAN_TIMEOUT" ddcutil --noverify "$@"
    }

    _displayman_has_kscreen() {
        command -v kscreen-doctor >/dev/null 2>&1
    }

    _displayman_require_kscreen() {
        if ! _displayman_has_kscreen; then
            printf '%sdisplayman: kscreen-doctor introuvable (Plasma / KDE requis).%s\n' \
                "$RED" "$RESET" >&2
            return 1
        fi
        return 0
    }

    # Parse "NAME MODE WxH+X+Y [primary]" depuis xrandr --query (fallback).
    _displayman_xrandr_line() {
        # $1 = connector name
        xrandr --query 2>/dev/null | awk -v n="$1" '
            $1 == n && $2 == "connected" {
                primary = ($3 == "primary") ? "primary" : ""
                geom = (primary != "") ? $4 : $3
                # geom = 2560x1440+1920+0
                split(geom, a, /[x+]/)
                printf "%s %sx%s +%s+%s %s\n", n, a[1], a[2], a[3], a[4], primary
                exit
            }
            $1 == n && $2 == "disconnected" {
                printf "%s disconnected\n", n
                exit
            }
        '
    }

    _displayman_drm_status() {
        # $1 = connector short name e.g. DP-1
        name="$1"
        for f in /sys/class/drm/card*-"$name"/status; do
            if [ -r "$f" ]; then
                cat "$f"
                return 0
            fi
        done
        printf 'unknown\n'
        return 1
    }

    _displayman_kscreen_mode_of() {
        # $1 = output name → prints current mode name (e.g. 2560x1440@75) or empty
        out="$1"
        if command -v python3 >/dev/null 2>&1; then
            kscreen-doctor -j 2>/dev/null | python3 -c '
import json,sys
want=sys.argv[1]
try:
    d=json.load(sys.stdin)
except Exception:
    sys.exit(0)
for o in d.get("outputs",[]):
    if o.get("name")!=want: continue
    if not o.get("connected"):
        print("disconnected"); sys.exit(0)
    if not o.get("enabled"):
        print("disabled"); sys.exit(0)
    mid=str(o.get("currentModeId",""))
    for m in o.get("modes",[]):
        if str(m.get("id"))==mid:
            print(m.get("name","")); sys.exit(0)
    print("?")
' "$out" 2>/dev/null
            return 0
        fi
        # Fallback texte : chercher le mode marqué *
        kscreen-doctor -o 2>/dev/null | awk -v n="$out" '
            $1=="Output:" && $3==n { hit=1; next }
            hit && /Modes:/ {
                for (i=1; i<=NF; i++) {
                    if ($i ~ /\*$/) {
                        gsub(/^[0-9]+:/, "", $i)
                        gsub(/\*.*/, "", $i)
                        print $i
                        exit
                    }
                }
                exit
            }
            hit && $1=="Output:" { exit }
        '
    }

    _displayman_layout_target_args() {
        # Args atomiques kscreen-doctor pour le profil cible.
        left_x=0
        prim_x=$DM_LEFT_W
        right_x=$((DM_LEFT_W + DM_PRIMARY_W))
        printf '%s\n' \
            "output.${DM_LEFT}.enable" \
            "output.${DM_LEFT}.mode.${DM_LEFT_MODE}" \
            "output.${DM_LEFT}.position.${left_x},0" \
            "output.${DM_LEFT}.priority.2" \
            "output.${DM_PRIMARY}.enable" \
            "output.${DM_PRIMARY}.mode.${DM_PRIMARY_MODE}" \
            "output.${DM_PRIMARY}.position.${prim_x},0" \
            "output.${DM_PRIMARY}.priority.1" \
            "output.${DM_RIGHT}.enable" \
            "output.${DM_RIGHT}.mode.${DM_RIGHT_MODE}" \
            "output.${DM_RIGHT}.position.${right_x},0" \
            "output.${DM_RIGHT}.priority.3"
    }

    # --- Sous-commandes ------------------------------------------------------
    displayman_cmd_detect() {
        _displayman_require_ddcutil || return 1
        printf "%sÉcrans détectés via DDC/CI :%s\n" "$CYAN" "$RESET"
        timeout "$DISPLAYMAN_TIMEOUT" ddcutil detect --brief 2>&1 \
            | awk 'NF { print "  " $0 } !NF { print "" }'
        if command -v kscreen-doctor >/dev/null 2>&1; then
            printf "\n%sSorties KDE (kscreen-doctor) :%s\n" "$CYAN" "$RESET"
            kscreen-doctor -o 2>&1 | awk '/^Output:|^outputs:/,0' | head -40 \
                | awk 'NF { print "  " $0 } !NF { print "" }'
        fi
    }

    displayman_cmd_info() {
        n="${1:-1}"
        _displayman_require_ddcutil || return 1
        printf "%sInfo écran #%s :%s\n" "$CYAN" "$n" "$RESET"
        timeout "$DISPLAYMAN_TIMEOUT" ddcutil --display "$n" detect 2>&1 \
            | awk 'NF { print "  " $0 }'
    }

    displayman_cmd_dump() {
        n="${1:-1}"
        _displayman_require_ddcutil || return 1
        printf "%sDump VCP utiles écran #%s :%s\n" "$CYAN" "$n" "$RESET"
        _displayman_ddcutil --display "$n" --terse \
            getvcp 10 12 14 16 18 1A 6C 6E 70 D6 2>&1 \
            | awk '
                BEGIN {
                    map["10"]="Brightness          "
                    map["12"]="Contrast            "
                    map["14"]="Color preset (lect.)"
                    map["16"]="Gain ROUGE          "
                    map["18"]="Gain VERT           "
                    map["1A"]="Gain BLEU           "
                    map["6C"]="Black level ROUGE   "
                    map["6E"]="Black level VERT    "
                    map["70"]="Black level BLEU    "
                    map["D6"]="Power mode          "
                }
                /^VCP / {
                    code=$2; rest=""
                    for (i=3; i<=NF; i++) rest=rest" "$i
                    lab=map[code]; if (lab=="") lab="(autre)             "
                    printf "  [VCP %s] %s ->%s\n", code, lab, rest
                    next
                }
                { print "  " $0 }
            '
    }

    _displayman_get_val() {
        # $1 = display, $2 = VCP code → echo "current max" (ou rien)
        _displayman_ddcutil --display "$1" --terse getvcp "$2" 2>/dev/null \
            | awk '/^VCP / { print $4, $5 }'
    }

    displayman_cmd_brightness() {
        n="${1:-1}"; val="${2-}"
        _displayman_require_ddcutil || return 1
        if [ -z "$val" ]; then
            cur=$(_displayman_get_val "$n" 10)
            printf "  Écran #%s — brightness actuelle : %s\n" "$n" "${cur:-?}"
            return 0
        fi
        case "$val" in
            ''|*[!0-9]*) printf '%sdisplayman: valeur invalide "%s" (0..100).%s\n' "$RED" "$val" "$RESET" >&2; return 1 ;;
        esac
        if [ "$val" -lt 0 ] || [ "$val" -gt 100 ]; then
            printf '%sdisplayman: valeur hors plage (0..100).%s\n' "$RED" "$RESET" >&2; return 1
        fi
        _displayman_ddcutil --display "$n" setvcp 10 "$val" 2>&1 \
            | sed 's/^/  /'
        sleep 1
        printf "  → "
        _displayman_get_val "$n" 10 | awk '{ printf "vérification : current=%s max=%s\n", $1, $2 }'
    }

    displayman_cmd_contrast() {
        n="${1:-1}"; val="${2-}"
        _displayman_require_ddcutil || return 1
        if [ -z "$val" ]; then
            cur=$(_displayman_get_val "$n" 12)
            printf "  Écran #%s — contraste actuel : %s\n" "$n" "${cur:-?}"
            return 0
        fi
        case "$val" in
            ''|*[!0-9]*) printf '%sdisplayman: valeur invalide "%s" (0..100).%s\n' "$RED" "$val" "$RESET" >&2; return 1 ;;
        esac
        if [ "$val" -lt 0 ] || [ "$val" -gt 100 ]; then
            printf '%sdisplayman: valeur hors plage (0..100).%s\n' "$RED" "$RESET" >&2; return 1
        fi
        _displayman_ddcutil --display "$n" setvcp 12 "$val" 2>&1 \
            | sed 's/^/  /'
        sleep 1
        printf "  → "
        _displayman_get_val "$n" 12 | awk '{ printf "vérification : current=%s max=%s\n", $1, $2 }'
    }

    displayman_cmd_preset() {
        n="${1:-1}"; name="${2-}"
        _displayman_require_ddcutil || return 1
        if [ -z "$name" ]; then
            printf "  Écran #%s — preset couleur actuel (VCP 14) :\n" "$n"
            _displayman_ddcutil --display "$n" --terse getvcp 14 2>&1 | sed 's/^/    /'
            printf "  Valeurs courantes : 01=sRGB · 05=6500K · 06=7500K · 08=9300K · 0b=User1\n"
            printf "  Usage : displayman preset %s <hex>     ex. displayman preset %s 01\n" "$n" "$n"
            printf "  %sNote%s : sur Mi Monitor, le firmware refuse souvent le set DDC ; bascule via OSD physique (displayman osd-guide).\n" "$YELLOW" "$RESET"
            return 0
        fi
        hex=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed 's/^0x//')
        case "$hex" in
            srgb)  hex=01 ;;
            6500k|65) hex=05 ;;
            7500k|75) hex=06 ;;
            9300k|93) hex=08 ;;
            user|user1) hex=0b ;;
        esac
        case "$hex" in
            [0-9a-f]|[0-9a-f][0-9a-f]) ;;
            *) printf '%sdisplayman: preset invalide "%s".%s\n' "$RED" "$name" "$RESET" >&2; return 1 ;;
        esac
        printf "  Tentative bascule preset → 0x%s ...\n" "$hex"
        _displayman_ddcutil --display "$n" setvcp 14 "0x$hex" 2>&1 | sed 's/^/    /'
        sleep 2
        cur_line=$(_displayman_ddcutil --display "$n" --terse getvcp 14 2>&1 | head -1)
        printf "  → relecture : %s\n" "$cur_line"
        case "$cur_line" in
            *"x$hex"*) printf "  %s✓%s preset appliqué côté firmware.\n" "$GREEN" "$RESET" ;;
            *) printf "  %s⚠%s relecture différente — firmware probablement bloqué. Utiliser l'OSD physique :\n" "$YELLOW" "$RESET"
               printf "    displayman osd-guide\n" ;;
        esac
    }

    displayman_cmd_reset() {
        n="${1:-1}"; flag="${2-}"
        _displayman_require_ddcutil || return 1
        if [ "$flag" != "--yes" ] && [ "$flag" != "-y" ]; then
            if [ -t 0 ] && [ -t 1 ]; then
                printf "%sReset usine couleur (VCP 04+08) sur écran #%s. Continuer ? [o/N] %s" "$YELLOW" "$n" "$RESET"
                read ans
                case "$ans" in
                    o|O|y|Y|oui|yes) : ;;
                    *) printf "  Annulé.\n"; return 1 ;;
                esac
            else
                printf '%sdisplayman: reset nécessite TTY ou --yes.%s\n' "$RED" "$RESET" >&2
                return 1
            fi
        fi
        printf "  Restore color defaults (VCP 08) ...\n"
        _displayman_ddcutil --display "$n" setvcp 08 01 2>&1 | sed 's/^/    /'
        printf "  Restore factory defaults (VCP 04) ...\n"
        _displayman_ddcutil --display "$n" setvcp 04 01 2>&1 | sed 's/^/    /'
        printf "  %s✓%s reset envoyé (effet visible immédiatement si firmware coopératif).\n" "$GREEN" "$RESET"
    }

    displayman_cmd_range() {
        printf "%sFull RGB Range (0-255) vs Limited (16-235) — diagnostic :%s\n\n" "$CYAN" "$RESET"
        if command -v lspci >/dev/null 2>&1; then
            gpu=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | head -1)
            [ -n "$gpu" ] && printf "  GPU : %s\n" "$gpu"
        fi
        if [ -r /sys/module/nvidia_drm/parameters/modeset ]; then
            ms=$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null)
            printf "  nvidia-drm modeset : %s\n" "$ms"
        fi
        sess="${XDG_SESSION_TYPE:-?}  desktop=${XDG_CURRENT_DESKTOP:-?}"
        printf "  Session : %s\n\n" "$sess"
        cat <<EOF
  Symptômes typiques d'un HDMI Limited Range alors qu'il faudrait Full :
    - image lavée, noirs gris, blancs ternes même à brightness 100
    - couleurs "molles", dégradés écrasés en haut/bas
    - le réglage côté DDC ne change rien à l'aspect lavé

  Pilotes NVIDIA propriétaires (Wayland inclus) — fix côté serveur X11 honoré
  par le pilote, créer /etc/X11/xorg.conf.d/20-nvidia-fullrange.conf :

      Section "Device"
          Identifier "Card0"
          Driver     "nvidia"
          Option     "ColorRange"  "Full"
      EndSection

  Puis : redémarrer la session graphique (sortie + reconnexion).
  Voir docs/guides/SCREEN_DISPLAY.md § "Étape C — Full Range NVIDIA"
  pour la procédure complète et le rollback.

  GPU Intel / AMD : la propriété DRM "Broadcast RGB" est exposée et peut
  être forcée via 'kscreen-doctor output.<N>.colorimetry rgb_full' (Plasma 6).
EOF
    }

    displayman_cmd_osd_guide() {
        cat <<EOF
${CYAN}${BOLD}Guide OSD physique — Mi Monitor / Xiaomi (joystick au dos)${RESET}

Localiser d'abord le joystick : en bas à droite, au DOS de la dalle.
Appuyer au centre pour ouvrir le menu. Deux variantes selon le modèle :

${BOLD}— Variante A : OSD international (27" et certains 24")${RESET}
  1. ${BOLD}Picture → Picture Mode${RESET} : choisir ${GREEN}Standard${RESET} ou ${GREEN}sRGB${RESET}
     (éviter User / ECO / Reading / Game).
  2. ${BOLD}Picture → Advanced → HDMI Black Level${RESET} : mettre ${GREEN}Normal${RESET}
     (= Full RGB 0-255).
  3. Désactiver DCR / Dynamic Contrast / Low Blue Light / Eye Saver.
  4. ${BOLD}Settings → Reset → Factory Reset${RESET} en dernier recours.

${BOLD}— Variante B : OSD français minimaliste (23.8" / A22 / 1C récent)${RESET}
  Menus rencontrés : Luminosité · Contraste · Température de couleur ·
  Modes intelligents · Entrée · Paramètres.
  1. ${BOLD}Température de couleur${RESET} ← équivalent OSD du VCP 14 du DDC.
     Si ${YELLOW}Personnalisé / Utilisateur${RESET} est actif → bascule sur
     ${GREEN}Standard${RESET} (≈ 6500K calibré usine).
  2. ${BOLD}Modes intelligents${RESET} : bascule sur ${GREEN}Standard${RESET}
     (éviter ECO / Cinéma / Jeu / Lecture / Faible lumière bleue).
  3. ${BOLD}Paramètres${RESET} :
       - ${BOLD}Format couleur HDMI / Plage de couleurs${RESET} (si présent)
         → ${GREEN}RGB / Plein / Complet${RESET} (et pas YCbCr / Limité).
         Absent sur Mi Monitor 23.8" → l'Étape C côté NVIDIA est indispensable
         (voir ${BOLD}displayman range${RESET}).
       - Désactiver ${BOLD}MEMC / DCR / Contraste dynamique / Mode de jeu${RESET}.
       - ${BOLD}Réinitialiser / Réglages d'usine${RESET} si rien d'autre n'aide.

Une fois fait, ${BOLD}displayman dump 1${RESET} doit montrer VCP 14 ≠ 0x0b
(p.ex. 0x05 si tu passes en Standard, ou 0x01 si tu passes en sRGB).
EOF
    }

    displayman_cmd_layout() {
        printf "%sLayout multi-écrans (profil cible : %s | %s | %s)%s\n" \
            "$CYAN" "$DM_LEFT" "$DM_PRIMARY" "$DM_RIGHT" "$RESET"
        printf "  Cible : %s @0+0 · %s %s @%s+0 (primary) · %s @%s+0\n\n" \
            "$DM_LEFT_MODE" "$DM_PRIMARY" "$DM_PRIMARY_MODE" "$DM_LEFT_W" \
            "$DM_RIGHT_MODE" "$((DM_LEFT_W + DM_PRIMARY_W))"

        if _displayman_has_kscreen; then
            printf "%sÉtat KDE (kscreen-doctor) :%s\n" "$CYAN" "$RESET"
            if command -v python3 >/dev/null 2>&1; then
                kscreen-doctor -j 2>/dev/null | python3 -c '
import json,sys
d=json.load(sys.stdin)
rows=[]
for o in d.get("outputs",[]):
    name=o.get("name","?")
    if not o.get("connected"):
        rows.append((name,"disconnected","—","—","—"))
        continue
    mid=str(o.get("currentModeId",""))
    mode="?"
    for m in o.get("modes",[]):
        if str(m.get("id"))==mid:
            mode=m.get("name","?"); break
    pos=o.get("pos") or {}
    size=o.get("size") or {}
    en="on" if o.get("enabled") else "off"
    prio=o.get("priority","?")
    geom="%sx%s+%s+%s" % (size.get("width","?"), size.get("height","?"),
                           pos.get("x","?"), pos.get("y","?"))
    rows.append((name, en, mode, geom, "prio %s" % prio))
# ordre gauche → primary → droite si possible
order={sys.argv[2]:0, sys.argv[1]:1, sys.argv[3]:2}
rows.sort(key=lambda r: order.get(r[0], 9))
for name,en,mode,geom,prio in rows:
    mark=" ★" if name==sys.argv[1] else ""
    print("  %-10s  %-12s  %-16s  %-22s  %s%s" % (name,en,mode,geom,prio,mark))
' "$DM_PRIMARY" "$DM_LEFT" "$DM_RIGHT" 2>/dev/null \
                    || kscreen-doctor -o 2>&1 | sed 's/^/  /' | head -60
            else
                kscreen-doctor -o 2>&1 | sed 's/^/  /' | head -60
            fi
        elif command -v xrandr >/dev/null 2>&1; then
            printf "%sÉtat xrandr :%s\n" "$CYAN" "$RESET"
            for n in "$DM_LEFT" "$DM_PRIMARY" "$DM_RIGHT"; do
                printf "  %s\n" "$(_displayman_xrandr_line "$n")"
            done
        else
            printf '%sAucun backend (kscreen-doctor / xrandr).%s\n' "$RED" "$RESET" >&2
            return 1
        fi

        printf "\n%sDRM connector status :%s\n" "$CYAN" "$RESET"
        for n in "$DM_LEFT" "$DM_PRIMARY" "$DM_RIGHT"; do
            printf "  %-10s  %s\n" "$n" "$(_displayman_drm_status "$n")"
        done
    }

    displayman_cmd_doctor() {
        printf "%sdisplayman doctor — hotplug / layout Philips DP%s\n\n" "$CYAN" "$RESET"
        issues=0

        drm_p="$(_displayman_drm_status "$DM_PRIMARY")"
        printf "  DRM %s : %s\n" "$DM_PRIMARY" "$drm_p"
        if [ "$drm_p" != "connected" ]; then
            printf "  %s✗%s Philips/%s déconnecté côté noyau — écran éteint ou câble DP HS.\n" \
                "$RED" "$RESET" "$DM_PRIMARY"
            printf "    → rallumer l'écran, attendre 2–3 s, puis : displayman fix\n"
            issues=$((issues + 1))
        fi

        if ! _displayman_has_kscreen; then
            printf "  %s✗%s kscreen-doctor absent — fix layout indisponible sous cette session.\n" \
                "$RED" "$RESET"
            issues=$((issues + 1))
            printf "\n  Problèmes détectés : %s\n" "$issues"
            return 1
        fi

        mode_p="$(_displayman_kscreen_mode_of "$DM_PRIMARY")"
        printf "  Mode %s : %s (attendu %s)\n" "$DM_PRIMARY" "${mode_p:-?}" "$DM_PRIMARY_MODE"
        case "$mode_p" in
            "$DM_PRIMARY_MODE"|2560x1440@75|2560x1440@74.*)
                printf "  %s✓%s Résolution native Philips OK\n" "$GREEN" "$RESET"
                ;;
            disconnected|disabled|"")
                printf "  %s✗%s Sortie absente / désactivée côté KWin\n" "$RED" "$RESET"
                issues=$((issues + 1))
                ;;
            *)
                printf "  %s✗%s Mode incorrect (souvent après power-off bouton Philips + NVIDIA DP)\n" \
                    "$RED" "$RESET"
                printf "    → displayman fix   (soft-replug DP + restaure layout)\n"
                issues=$((issues + 1))
                ;;
        esac

        mode_l="$(_displayman_kscreen_mode_of "$DM_LEFT")"
        mode_r="$(_displayman_kscreen_mode_of "$DM_RIGHT")"
        printf "  Mode %s : %s\n" "$DM_LEFT" "${mode_l:-?}"
        printf "  Mode %s : %s  %s(petit HP — ne doit PAS être le primary)%s\n" \
            "$DM_RIGHT" "${mode_r:-?}" "$YELLOW" "$RESET"

        if command -v python3 >/dev/null 2>&1; then
            bad_prio=$(kscreen-doctor -j 2>/dev/null | python3 -c '
import json,sys
d=json.load(sys.stdin)
want=sys.argv[1]
hp=sys.argv[2]
pri=None; hp_pri=None
for o in d.get("outputs",[]):
    if o.get("name")==want: pri=o.get("priority")
    if o.get("name")==hp: hp_pri=o.get("priority")
if pri is None:
    print("missing"); sys.exit(0)
if hp_pri is not None and int(hp_pri) < int(pri):
    print("hp_first")
elif int(pri)!=1:
    print("not_primary")
else:
    print("ok")
' "$DM_PRIMARY" "$DM_RIGHT" 2>/dev/null || printf 'unknown\n')
            case "$bad_prio" in
                ok) printf "  %s✓%s Priorité KWin : %s = primary (1)\n" "$GREEN" "$RESET" "$DM_PRIMARY" ;;
                hp_first)
                    printf "  %s✗%s Le petit HP a une priorité plus haute → fenêtres déportées dessus\n" \
                        "$RED" "$RESET"
                    issues=$((issues + 1))
                    ;;
                not_primary|missing)
                    printf "  %s✗%s %s n'est pas priority 1\n" "$RED" "$RESET" "$DM_PRIMARY"
                    issues=$((issues + 1))
                    ;;
            esac
        fi

        printf "\n%sPourquoi ça casse%s\n" "$BOLD" "$RESET"
        cat <<'EOF'
  1. Bouton power du Philips = coupe le lien DisplayPort (hot-unplug).
  2. KWin bascule le primary / déplace les fenêtres vers le HP (HDMI-A-2).
  3. Au rallumage, NVIDIA + DP renégocie souvent un mauvais mode EDID
     jusqu'à un vrai unplug/replug câble — d'où la perte du 2560x1440.

  Contournements :
    • displayman fix          → soft-replug logiciel + layout cible
    • Éviter le bouton power : laisser l'écran allumé, ou DPMS session
      (veille OS) plutôt que coupure physique DP.
    • Les fenêtres déjà déplacées sur le HP ne reviennent pas toutes seules
      après fix (KWin ne les rapatrie pas) — à re-glisser une fois.
EOF

        printf "\n"
        if [ "$issues" -eq 0 ]; then
            printf "%s✓ Layout sain (%s problème).%s\n" "$GREEN" "$issues" "$RESET"
            return 0
        fi
        printf "%s✗ %s problème(s) — lance : displayman fix%s\n" "$YELLOW" "$issues" "$RESET"
        return 1
    }

    displayman_cmd_fix() {
        force_replug=0
        for a in "$@"; do
            case "$a" in
                --replug|-r|replug) force_replug=1 ;;
                --help|-h)
                    cat <<EOF
Usage : displayman fix [--replug]

  Restaure le layout cible (Xiaomi | Philips DP-1 primary | HP) via
  kscreen-doctor. Si le mode Philips est faux / absent, ou avec --replug,
  fait un soft-replug (disable → enable) qui imite le débranchement DP.

Variables : DISPLAYMAN_PRIMARY, DISPLAYMAN_PRIMARY_MODE, DISPLAYMAN_LEFT,
            DISPLAYMAN_LEFT_MODE, DISPLAYMAN_RIGHT, DISPLAYMAN_RIGHT_MODE,
            DISPLAYMAN_LEFT_W, DISPLAYMAN_PRIMARY_W
EOF
                    return 0
                    ;;
            esac
        done

        _displayman_require_kscreen || return 1

        drm_p="$(_displayman_drm_status "$DM_PRIMARY")"
        if [ "$drm_p" != "connected" ]; then
            printf '%sdisplayman fix: %s pas connected (DRM=%s).%s\n' \
                "$RED" "$DM_PRIMARY" "$drm_p" "$RESET" >&2
            printf '  Rallume le Philips, attends 2–3 s, relance displayman fix.\n' >&2
            return 1
        fi

        mode_p="$(_displayman_kscreen_mode_of "$DM_PRIMARY")"
        need_replug=$force_replug
        case "$mode_p" in
            "$DM_PRIMARY_MODE"|2560x1440@75|2560x1440@74.*) ;;
            *) need_replug=1 ;;
        esac

        if [ "$need_replug" -eq 1 ]; then
            printf "%s↻ Soft-replug %s (disable → pause → enable+layout)...%s\n" \
                "$YELLOW" "$DM_PRIMARY" "$RESET"
            printf "  (équivalent logiciel du débranchement DisplayPort)\n"
            kscreen-doctor "output.${DM_PRIMARY}.disable" 2>&1 | sed 's/^/  /' || true
            sleep 2
        else
            printf "%s↻ Restauration layout (mode Philips déjà OK)...%s\n" \
                "$CYAN" "$RESET"
        fi

        # shellcheck disable=SC2046
        set -- $(_displayman_layout_target_args)
        printf "  kscreen-doctor"
        for a in "$@"; do printf " %s" "$a"; done
        printf "\n"

        if ! kscreen-doctor "$@" 2>&1 | sed 's/^/  /'; then
            printf '%sÉchec kscreen-doctor — nouvel essai après soft-replug forcé...%s\n' \
                "$YELLOW" "$RESET" >&2
            kscreen-doctor "output.${DM_PRIMARY}.disable" 2>/dev/null || true
            sleep 2
            if ! kscreen-doctor "$@" 2>&1 | sed 's/^/  /'; then
                printf '%sdisplayman fix: échec. Débranche/rebranche le câble DP une fois,%s\n' \
                    "$RED" "$RESET" >&2
                printf '  puis relance displayman fix.\n' >&2
                return 1
            fi
        fi

        sleep 1
        printf "\n%sÉtat après fix :%s\n" "$GREEN" "$RESET"
        displayman_cmd_layout
        printf "\n%s✓ Layout appliqué.%s Si des fenêtres restent sur le petit HP, glisse-les\n" \
            "$GREEN" "$RESET"
        printf "  sur le Philips (KWin ne les rapatrie pas automatiquement).\n"
    }

    # --- En-tête + menu interactif -------------------------------------------
    show_header() {
        if [ -t 1 ]; then clear; fi
        printf "%s%s" "$CYAN" "$BOLD"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "DISPLAYMAN - DISPLAY MANAGER"
        else
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                DISPLAYMAN - DISPLAY MANAGER                     ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
        fi
        printf "%s" "$RESET"
    }

    show_main_menu() {
        show_header
        printf "%s🖥  ÉCRAN / LUMINOSITÉ%s\n" "$YELLOW" "$RESET"
        manager_ui_section_line "${BLUE}" "${RESET}\n\n"
        printf "%s1.%s Détecter écrans (ddcutil + KDE)\n" "$BOLD" "$RESET"
        printf "%s2.%s Dump VCP écran 1 (diagnostic complet)\n" "$BOLD" "$RESET"
        printf "%s3.%s Régler brightness\n" "$BOLD" "$RESET"
        printf "%s4.%s Régler contraste\n" "$BOLD" "$RESET"
        printf "%s5.%s Preset couleur (sRGB / 6500K / …)\n" "$BOLD" "$RESET"
        printf "%s6.%s Reset usine couleur\n" "$BOLD" "$RESET"
        printf "%s7.%s Diagnostic Full/Limited range HDMI\n" "$BOLD" "$RESET"
        printf "%s8.%s Guide OSD physique (joystick)\n" "$BOLD" "$RESET"
        printf "%s9.%s Layout multi-écrans (état)\n" "$BOLD" "$RESET"
        printf "%sa.%s Doctor hotplug Philips DP\n" "$BOLD" "$RESET"
        printf "%sb.%s Fix layout (soft-replug DP si besoin)\n" "$BOLD" "$RESET"
        printf "%sh.%s Aide\n" "$BOLD" "$RESET"
        printf "%s0.%s Quitter\n\n" "$BOLD" "$RESET"
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Détecter écrans|1
Dump VCP écran 1|2
Régler brightness|3
Régler contraste|4
Preset couleur|5
Reset usine couleur|6
Diagnostic Full/Limited range HDMI|7
Guide OSD physique|8
Layout multi-écrans|9
Doctor hotplug Philips DP|a
Fix layout (soft-replug)|b
Aide|h
Quitter|0
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "DISPLAYMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix: "
            read choice
        fi
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        case "$choice" in
            1|detect)      displayman_cmd_detect; pause_if_tty ;;
            2|dump)        displayman_cmd_dump 1; pause_if_tty ;;
            3|brightness)
                printf "Numéro d'écran (défaut 1): "; read d; d="${d:-1}"
                printf "Valeur 0..100: "; read v
                displayman_cmd_brightness "$d" "$v"; pause_if_tty ;;
            4|contrast)
                printf "Numéro d'écran (défaut 1): "; read d; d="${d:-1}"
                printf "Valeur 0..100: "; read v
                displayman_cmd_contrast "$d" "$v"; pause_if_tty ;;
            5|preset)
                printf "Numéro d'écran (défaut 1): "; read d; d="${d:-1}"
                printf "Preset (srgb|6500k|7500k|9300k|user|<hex>): "; read v
                displayman_cmd_preset "$d" "$v"; pause_if_tty ;;
            6|reset)
                printf "Numéro d'écran (défaut 1): "; read d; d="${d:-1}"
                displayman_cmd_reset "$d"; pause_if_tty ;;
            7|range|rg)    displayman_cmd_range; pause_if_tty ;;
            8|osd|osd-guide|guide) displayman_cmd_osd_guide; pause_if_tty ;;
            9|layout|l)    displayman_cmd_layout; pause_if_tty ;;
            a|doctor|doc)  displayman_cmd_doctor; pause_if_tty ;;
            b|fix|f|restore) displayman_cmd_fix; pause_if_tty ;;
            h|help|aide)   show_help ;;
            0|q|quit|exit)
                printf "%sAu revoir!%s\n" "$GREEN" "$RESET"
                return 1
                ;;
            *) printf "%s❌ Choix invalide: %s%s\n" "$RED" "$choice" "$RESET"; sleep 1 ;;
        esac
        return 0
    }

    displayman_print_quick_help() {
        cat <<'EOF'
DISPLAYMAN — écrans / luminosité / DDC / layout

Interface :
  displayman                          cette aide (stdout)
  displayman help | -h | aide         idem
  displayman help --interactive       cette aide + pause (TTY requis)
  displayman --help                   cette aide + pause + menu interactif

Commandes DDC :
  displayman detect                   lister les écrans détectés (ddcutil)
  displayman info [n]                 détail écran n (défaut 1)
  displayman dump [n]                 dump VCP utiles (brightness, contraste,
                                       preset, gains RGB, black level, power)
  displayman brightness [n] [0..100]  lit ou règle la luminosité (VCP 10)
  displayman contrast   [n] [0..100]  lit ou règle le contraste   (VCP 12)
  displayman preset     [n] [name]    preset couleur — srgb|6500k|7500k|9300k|
                                       user|<hex> (VCP 14)
  displayman reset      [n] [--yes]   reset usine couleur + factory (VCP 08+04)
  displayman range                    diagnostic Full vs Limited range HDMI
  displayman osd-guide                guide pas-à-pas OSD physique (Xiaomi…)

Layout / hotplug (Plasma + Philips DP-1) :
  displayman layout | status          état des sorties vs profil cible
  displayman doctor                   diagnostique perte résolution / primary
  displayman fix [--replug]           restaure layout ; soft-replug DP si besoin

Variables :
  DISPLAYMAN_DDC_TIMEOUT   timeout DDC en s (défaut 15)
  DISPLAYMAN_PRIMARY       connecteur primary (défaut DP-1)
  DISPLAYMAN_PRIMARY_MODE  mode Philips (défaut 2560x1440@75)
  DISPLAYMAN_LEFT / _RIGHT / _MODE / _W   profil multi-écrans
  NO_COLOR                 désactive les couleurs ANSI

Pré-requis : ddcutil ; kscreen-doctor (fix/layout/doctor).
Voir docs/guides/SCREEN_DISPLAY.md pour le diagnostic complet.
EOF
    }

    show_help() {
        show_header
        printf "%s%sAIDE - DISPLAYMAN%s\n\n" "$CYAN" "$BOLD" "$RESET"
        displayman_print_quick_help
        pause_if_tty
    }

    # --- Dispatch principal --------------------------------------------------
    if [ -z "${1-}" ]; then
        displayman_print_quick_help
        return 0
    fi
    if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "aide" ]; then
        case "${2-}" in
            --interactive|-i)
                if [ -t 0 ] && [ -t 1 ]; then
                    displayman_print_quick_help
                    pause_if_tty
                else
                    printf '%s\n' "displayman: help --interactive nécessite un TTY." >&2
                    displayman_print_quick_help
                fi
                return 0
                ;;
            *)
                displayman_print_quick_help
                return 0
                ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        displayman_print_quick_help
        return 0
    fi
    if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then
        if ! { [ -t 0 ] && [ -t 1 ]; }; then
            printf '%s\n' "displayman: menu nécessite un terminal (TTY)." >&2
            return 2
        fi
        while true; do
            show_main_menu || break
        done
        return 0
    fi

    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && \
        . "$_logdf/scripts/lib/managers_log_posix.sh" && \
        managers_cli_log displayman "$@"

    cmd=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    shift
    case "$cmd" in
        detect|list|ls)            displayman_cmd_detect "$@" ;;
        info|i)                    displayman_cmd_info "$@" ;;
        dump|d)                    displayman_cmd_dump "$@" ;;
        brightness|bright|b|lum)   displayman_cmd_brightness "$@" ;;
        contrast|contr|c)          displayman_cmd_contrast "$@" ;;
        preset|p|colorpreset)      displayman_cmd_preset "$@" ;;
        reset|r|factory)           displayman_cmd_reset "$@" ;;
        range|rg|fullrange|limited) displayman_cmd_range "$@" ;;
        osd|osd-guide|guide|osdguide) displayman_cmd_osd_guide "$@" ;;
        layout|status|state|st)    displayman_cmd_layout "$@" ;;
        doctor|doc|diag)           displayman_cmd_doctor "$@" ;;
        fix|restore|repair|apply)  displayman_cmd_fix "$@" ;;
        *)
            printf '%sdisplayman: commande inconnue: %s%s\n' "$RED" "$cmd" "$RESET" >&2
            printf 'Voir : displayman help\n' >&2
            return 1
            ;;
    esac
}
