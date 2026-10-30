#!/bin/sh
# =============================================================================
# ADBMAN — connexion ADB USB / Wi-Fi sans spam de reconnexion
# =============================================================================
# USAGE: adbman [devices|usb|wifi|pair|connect|disconnect|doctor|stop-spam]
# =============================================================================

adbman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    ADB="${ADB_BIN:-adb}"
    CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
    CONF="$CONF_DIR/adbman.env"

    _am_need_adb() {
        if ! command -v "$ADB" >/dev/null 2>&1; then
            printf "${RED}adb introuvable. pacman -S android-tools${RESET}\n" >&2
            return 1
        fi
    }

    _am_load_conf() {
        [ -f "$CONF" ] || return 0
        # shellcheck source=/dev/null
        . "$CONF"
    }

    _am_usage() {
        cat <<EOF
${BOLD}adbman${RESET} — ADB USB / sans-fil (à la demande, sans ping agressif)

  adbman                  liste appareils
  adbman devices          idem (+ détails)
  adbman usb [serial]     préfère USB, coupe le doublon Wi-Fi du même device
  adbman wifi <ip[:port]> connect TCP (ex: 192.168.1.42:5555)
  adbman pair <ip:port>   pairing code (Android 11+)
  adbman connect <target> adb connect
  adbman disconnect [t]   déconnecte Wi-Fi (tous si vide)
  adbman doctor           état + timers keepalive suspects
  adbman stop-spam        coupe les timers keepalive Hubera/Samsung
  adbman shell [serial]   shell interactif (1er device si omis)
  adbman pick             affiche serials pour copier dans ANDROID_SERIAL

Config optionnelle: $CONF
  ADB_DEFAULT_WIFI=192.168.1.42:5555
  ADB_DEFAULT_SERIAL=R5CT7263YJL
EOF
    }

    _am_devices() {
        _am_need_adb || return 1
        printf "${CYAN}${BOLD}Appareils ADB${RESET}\n"
        "$ADB" devices -l
        echo ""
        "$ADB" devices -l | awk 'NR>1 && $2=="device" {
          serial=$1; product=""; model=""; trans=""
          for(i=3;i<=NF;i++){
            if($i ~ /^product:/) product=substr($i,9)
            if($i ~ /^model:/) model=substr($i,7)
            if($i ~ /^transport_id:/) trans=substr($i,14)
          }
          kind=(serial ~ /_adb-tls-connect|_adb-tls-pairing|:[0-9]+$/) ? "wifi" : "usb"
          printf "  %-44s  %-5s  %s %s\n", serial, kind, model, product
        }'
    }

    _am_stop_spam() {
        printf "${YELLOW}Arrêt timers keepalive ADB…${RESET}\n"
        systemctl --user stop hubera-samsung-adb-keepalive.timer hubera-samsung-adb-keepalive.service 2>/dev/null || true
        systemctl --user disable hubera-samsung-adb-keepalive.timer 2>/dev/null || true
        rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/timers.target.wants/hubera-samsung-adb-keepalive.timer" 2>/dev/null || true
        systemctl --user daemon-reload 2>/dev/null || true
        # Ne pas reconnecter en boucle : laisser les sessions Wi-Fi déjà pairées
        printf "${GREEN}✓ spam keepalive coupé${RESET}\n"
        printf "  Pour reconnecter à la demande: ${BOLD}adbman wifi <ip:port>${RESET} ou ${BOLD}adbman connect <mdns>${RESET}\n"
    }

    _am_doctor() {
        _am_need_adb || return 1
        _am_devices
        echo ""
        printf "${CYAN}Timers / services ADB${RESET}\n"
        systemctl --user list-timers --all 2>/dev/null | grep -iE 'adb|keepalive|hubera' || echo "  (aucun timer adb user)"
        systemctl --user list-units --all '*adb*' --no-pager 2>/dev/null | sed 's/^/  /' || true
        echo ""
        if systemctl --user is-enabled hubera-samsung-adb-keepalive.timer >/dev/null 2>&1; then
            printf "${RED}⚠ keepalive Samsung encore enabled → notifications « Débogage sans fil » en boucle${RESET}\n"
            printf "  → adbman stop-spam\n"
        else
            printf "${GREEN}✓ pas de keepalive agressif enabled${RESET}\n"
        fi
        echo ""
        printf "ANDROID_SERIAL=%s\n" "${ANDROID_SERIAL:-"(non défini)"}"
        [ -f "$CONF" ] && printf "config: %s\n" "$CONF" || printf "config: (absente)\n"
    }

    _am_usb() {
        _am_need_adb || return 1
        _am_load_conf
        serial="${1:-${ADB_DEFAULT_SERIAL:-}}"
        if [ -z "$serial" ]; then
            serial=$("$ADB" devices | awk 'NR>1 && $2=="device" && $1 !~ /:/ && $1 !~ /_adb-tls/ {print $1; exit}')
        fi
        if [ -z "$serial" ]; then
            printf "${RED}Aucun device USB. Branche le câble ou: adbman devices${RESET}\n" >&2
            return 1
        fi
        export ANDROID_SERIAL="$serial"
        printf "${GREEN}USB OK${RESET} ANDROID_SERIAL=%s\n" "$serial"
        # Couper doublons Wi-Fi du même téléphone si USB vivant
        model=$("$ADB" -s "$serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        "$ADB" devices | awk 'NR>1 && $2=="device" && ($1 ~ /:/ || $1 ~ /_adb-tls/) {print $1}' | while read -r w; do
            wmodel=$("$ADB" -s "$w" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
            if [ -n "$model" ] && [ "$wmodel" = "$model" ]; then
                printf "${YELLOW}Déconnecte doublon Wi-Fi %s (même modèle %s)${RESET}\n" "$w" "$model"
                "$ADB" disconnect "$w" >/dev/null 2>&1 || true
            fi
        done
        "$ADB" -s "$serial" get-state
    }

    _am_wifi() {
        _am_need_adb || return 1
        _am_load_conf
        target="${1:-${ADB_DEFAULT_WIFI:-}}"
        if [ -z "$target" ]; then
            printf "${RED}Usage: adbman wifi <ip[:port]>${RESET}\n" >&2
            return 1
        fi
        case "$target" in
            *:*) ;;
            *) target="${target}:5555" ;;
        esac
        printf "connect %s…\n" "$target"
        "$ADB" connect "$target"
        export ANDROID_SERIAL="$target"
        "$ADB" -s "$target" get-state 2>/dev/null || return 1
        printf "${GREEN}✓ Wi-Fi ADB${RESET} ANDROID_SERIAL=%s\n" "$target"
        printf "Astuce: une fois connecté, ${BOLD}ne lance pas de keepalive 45s${RESET} — ça spam le téléphone.\n"
    }

    _am_pair() {
        _am_need_adb || return 1
        target="$1"
        [ -n "$target" ] || { printf "Usage: adbman pair <ip:port>  # puis code affiché\n" >&2; return 1; }
        "$ADB" pair "$target"
    }

    cmd="${1:-devices}"
    [ "$#" -gt 0 ] && shift
    case "$cmd" in
        help|-h|--help) _am_usage ;;
        devices|ls|list|"") _am_devices ;;
        doctor|status) _am_doctor ;;
        stop-spam|nospam|quiet) _am_stop_spam ;;
        usb) _am_usb "$@" ;;
        wifi|tcp) _am_wifi "$@" ;;
        pair) _am_pair "$@" ;;
        connect)
            _am_need_adb || return 1
            [ -n "${1:-}" ] || { echo "Usage: adbman connect <target>" >&2; return 1; }
            "$ADB" connect "$1"
            ;;
        disconnect|disc)
            _am_need_adb || return 1
            if [ -n "${1:-}" ]; then "$ADB" disconnect "$1"; else "$ADB" disconnect; fi
            ;;
        shell)
            _am_need_adb || return 1
            _am_load_conf
            s="${1:-${ANDROID_SERIAL:-${ADB_DEFAULT_SERIAL:-}}}"
            if [ -n "$s" ]; then "$ADB" -s "$s" shell; else "$ADB" shell; fi
            ;;
        pick)
            _am_need_adb || return 1
            "$ADB" devices | awk 'NR>1 && $2=="device" {print $1}'
            ;;
        *)
            printf "${RED}Commande inconnue: %s${RESET}\n" "$cmd" >&2
            _am_usage
            return 1
            ;;
    esac
}

# Si exécuté directement (shim)
if [ "${0##*/}" = "adbman" ] || [ "${0##*/}" = "adbman.sh" ]; then
    adbman "$@"
fi
