#!/bin/sh
# =============================================================================
# VERSIONMAN — inventaire des versions (Java & n’importe quel outil)
# =============================================================================
# USAGE:
#   versionman
#   versionman java | jvm
#   versionman get <outil> [outil…]
#   versionman which <outil>
#   versionman scan [motif]
#   versionman all
#   versionman help
# =============================================================================

versionman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_manager_load_ui_libs 2>/dev/null || true
    fi

    _vm_header() {
        clear 2>/dev/null || true
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "VERSIONMAN" "Versions Java & logiciels (get / which / scan)"
        else
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║              VERSIONMAN — Versions & emplacements             ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
        fi
        printf "${RESET}\n"
    }

    _vm_wait() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée... "
            # shellcheck disable=SC2034
            read -r _vm_dummy || true
        fi
    }

    _vm_help() {
        cat <<EOF
${BOLD}versionman${RESET} — détecte versions & chemins des outils

  ${BOLD}versionman${RESET}                  menu interactif
  ${BOLD}versionman java${RESET}             toutes les JVM + défaut + Applet
  ${BOLD}versionman get <outil…>${RESET}     version(s) d’un ou plusieurs outils
  ${BOLD}versionman which <outil>${RESET}    chemins (command -v + /usr/lib/jvm…)
  ${BOLD}versionman scan [motif]${RESET}     scan rapide d’outils connus (filtre optionnel)
  ${BOLD}versionman all${RESET}              scan complet (connus + PATH utiles)
  ${BOLD}versionman help${RESET}

Exemples:
  versionman get java python node docker flutter cgoban cursor
  versionman java
  versionman which java
  versionman scan go

Astuce CGoban: il faut une JVM avec ${BOLD}java.applet.Applet${RESET} (11/8/17), pas Java 27.
EOF
    }

    # --- extraction numéro de version depuis une ligne ---
    _vm_extract_ver() {
        printf '%s' "$1" | grep -oE '[0-9]+(\.[0-9]+){1,3}' | head -n1
    }

    # --- sonde générique: lance bin avec flags version ---
    _vm_probe_bin() {
        _vm_bin="$1"
        [ -x "$_vm_bin" ] || [ -f "$_vm_bin" ] || return 1
        _vm_out=""
        for _vm_flag in --version -version -V version; do
            _vm_out=$("$_vm_bin" $_vm_flag 2>&1 | head -n3 | tr '\n' ' ' | sed 's/  */ /g')
            case "$_vm_out" in
                ''|*Unrecognized*|*unknown\ option*|*invalid\ option*|*Illegal*)
                    _vm_out=""
                    continue
                    ;;
            esac
            [ -n "$_vm_out" ] && break
        done
        [ -n "$_vm_out" ] || return 1
        printf '%s\n' "$_vm_out"
    }

    _vm_cmd_path() {
        command -v "$1" 2>/dev/null || true
    }

    # --- JAVA ---
    _vm_java_has_applet() {
        _vm_j="$1"
        case "$_vm_j" in
            */java-8-openjdk/*|*/java-11-openjdk/*|*/java-17-openjdk/*) return 0 ;;
            # Sur Arch, 21 peut encore exposer Applet ; 25/27 non.
            */java-25*|*/java-27*|*/java-2[6-9]*) return 1 ;;
            */java-21-openjdk/*) return 0 ;;
        esac
        return 1
    }

    _vm_java_report() {
        printf "${CYAN}${BOLD}Java / JVM${RESET}\n"
        if command -v archlinux-java >/dev/null 2>&1; then
            printf "  ${BOLD}archlinux-java status${RESET}:\n"
            archlinux-java status 2>/dev/null | sed 's/^/    /'
            echo ""
        fi
        _vm_def=$(readlink -f "$(command -v java 2>/dev/null)" 2>/dev/null || true)
        printf "  Défaut PATH: ${BOLD}%s${RESET}\n" "${_vm_def:-absent}"
        if [ -n "$_vm_def" ]; then
            _vm_line=$(_vm_probe_bin "$_vm_def" || true)
            printf "    → %s\n" "${_vm_line:-?}"
            if _vm_java_has_applet "$_vm_def"; then
                printf "    Applet: ${GREEN}oui${RESET}\n"
            else
                printf "    Applet: ${RED}non${RESET} (CGoban/KGS cassé avec cette JVM)\n"
            fi
        fi
        echo ""
        printf "  Installées sous /usr/lib/jvm :\n"
        _vm_found=0
        _vm_seen="|"
        for _vm_home in /usr/lib/jvm/java-*-openjdk; do
            [ -d "$_vm_home" ] || continue
            _vm_j="$_vm_home/bin/java"
            [ -x "$_vm_j" ] || continue
            _vm_realj=$(readlink -f "$_vm_j" 2>/dev/null || printf '%s' "$_vm_j")
            case "$_vm_seen" in
                *"|$_vm_realj|"*) continue ;;
            esac
            _vm_seen="${_vm_seen}${_vm_realj}|"
            _vm_found=1
            _vm_ver=$("$_vm_j" -version 2>&1 | head -n1)
            _vm_num=$(_vm_extract_ver "$_vm_ver")
            _vm_mark=""
            [ "$_vm_realj" = "$_vm_def" ] && _vm_mark=" ${GREEN}(défaut)${RESET}"
            if _vm_java_has_applet "$_vm_j"; then
                _vm_ap="${GREEN}Applet✓${RESET}"
            else
                _vm_ap="${RED}Applet✗${RESET}"
            fi
            printf "    %-28s  %-8s  %s%s\n" "$(basename "$_vm_home")" "${_vm_num:-?}" "$_vm_ap" "$_vm_mark"
            printf "      %s\n" "$_vm_j"
        done
        [ "$_vm_found" = "1" ] || printf "    (aucune)\n"
        echo ""
        printf "  ${YELLOW}CGoban${RESET}: wrapper → ~/.local/bin/cgoban (force Java 11)\n"
        if [ -x "$HOME/.local/bin/cgoban" ]; then
            printf "    présent: %s\n" "$HOME/.local/bin/cgoban"
        else
            printf "    ${RED}absent${RESET} — installman cgoban\n"
        fi
        if [ -f /opt/cgoban.version ]; then
            printf "    jar /opt: v%s\n" "$(tr -d ' \n\r' </opt/cgoban.version)"
        elif [ -f /opt/cgoban.jar ]; then
            printf "    jar /opt: présent\n"
        else
            printf "    jar /opt: absent\n"
        fi
    }

    # --- outils connus (nom -> résolution) ---
    _vm_known_list() {
        cat <<'EOF'
java
python
python3
node
npm
pnpm
yarn
docker
podman
git
rustc
cargo
go
gcc
g++
clang
cmake
make
ruby
php
perl
lua
dotnet
flutter
dart
kotlin
scala
mvn
gradle
adb
fastboot
cursor
code
brave
brave-browser
google-chrome
firefox
cgoban
flatpak
snap
pacman
yay
paru
nvim
vim
emacs
zsh
bash
fish
tmux
kubectl
helm
terraform
ansible
openssl
curl
wget
jq
ffmpeg
vlc
handbrake
ghb
EOF
    }

    _vm_resolve_special() {
        _vm_name="$1"
        case "$_vm_name" in
            java|jvm|jdk|jre)
                _vm_java_report
                return 0
                ;;
            cgoban)
                if [ -f /opt/cgoban.jar ]; then
                    _vm_v="unknown"
                    [ -f /opt/cgoban.version ] && _vm_v=$(tr -d ' \n\r' </opt/cgoban.version)
                    printf "${BOLD}%-14s${RESET}  %-18s  %s\n" "cgoban" "v$_vm_v" "/opt/cgoban.jar"
                    if [ -x "$HOME/.local/bin/cgoban" ]; then
                        printf "%-14s  %-18s  %s\n" "" "wrapper" "$HOME/.local/bin/cgoban"
                    fi
                else
                    printf "${BOLD}%-14s${RESET}  ${RED}not_installed${RESET}\n" "cgoban"
                fi
                return 0
                ;;
            cursor)
                for _vm_c in \
                    "$HOME/Applications"/Cursor*.AppImage \
                    "$HOME/Applications"/cursor*.AppImage \
                    /opt/cursor.appimage \
                    "$(command -v cursor 2>/dev/null)"; do
                    [ -e "$_vm_c" ] || continue
                    _vm_cv="?"
                    [ -f "$HOME/Applications/.cursor-version" ] && _vm_cv=$(tr -d ' \n\r' <"$HOME/Applications/.cursor-version")
                    printf "${BOLD}%-14s${RESET}  %-18s  %s\n" "cursor" "$_vm_cv" "$_vm_c"
                    return 0
                done
                printf "${BOLD}%-14s${RESET}  ${RED}not_installed${RESET}\n" "cursor"
                return 0
                ;;
            java8|java11|java17|java21|java25|java27)
                _vm_n=$(printf '%s' "$_vm_name" | sed 's/java//')
                _vm_j="/usr/lib/jvm/java-${_vm_n}-openjdk/bin/java"
                if [ -x "$_vm_j" ]; then
                    _vm_line=$(_vm_probe_bin "$_vm_j" || true)
                    printf "${BOLD}%-14s${RESET}  %-18s  %s\n" "$_vm_name" "$(_vm_extract_ver "$_vm_line")" "$_vm_j"
                else
                    printf "${BOLD}%-14s${RESET}  ${RED}not_installed${RESET}\n" "$_vm_name"
                fi
                return 0
                ;;
        esac
        return 1
    }

    _vm_get_one() {
        _vm_tool="$1"
        [ -n "$_vm_tool" ] || return 1
        # « get java » = ligne courte ; rapport complet via « versionman java »
        case "$_vm_tool" in
            java|jvm|jdk|jre)
                _vm_path=$(_vm_cmd_path java)
                if [ -z "$_vm_path" ]; then
                    printf "${BOLD}%-14s${RESET}  ${RED}not_installed${RESET}\n" "java"
                    return 1
                fi
                _vm_line=$(_vm_probe_bin "$_vm_path" || true)
                printf "${BOLD}%-14s${RESET}  %-18s  %s\n" "java" "$(_vm_extract_ver "$_vm_line")" "$(readlink -f "$_vm_path" 2>/dev/null || echo "$_vm_path")"
                return 0
                ;;
        esac
        if _vm_resolve_special "$_vm_tool"; then
            return 0
        fi
        _vm_path=$(_vm_cmd_path "$_vm_tool")
        if [ -z "$_vm_path" ]; then
            # alias / fonctions souvent pas visibles — chercher chemins courants
            for _vm_try in \
                "/usr/bin/$_vm_tool" \
                "/usr/local/bin/$_vm_tool" \
                "$HOME/.local/bin/$_vm_tool" \
                "/opt/$_vm_tool/bin/$_vm_tool"; do
                if [ -x "$_vm_try" ]; then
                    _vm_path="$_vm_try"
                    break
                fi
            done
        fi
        if [ -z "$_vm_path" ]; then
            printf "${BOLD}%-14s${RESET}  ${RED}not_installed${RESET}\n" "$_vm_tool"
            return 1
        fi
        _vm_real=$(readlink -f "$_vm_path" 2>/dev/null || printf '%s' "$_vm_path")
        _vm_line=$(_vm_probe_bin "$_vm_path" || true)
        _vm_num=$(_vm_extract_ver "$_vm_line")
        [ -n "$_vm_num" ] || _vm_num="?"
        printf "${BOLD}%-14s${RESET}  %-18s  %s\n" "$_vm_tool" "$_vm_num" "$_vm_real"
        if [ -n "$_vm_line" ] && [ "$_vm_line" != "$_vm_num" ]; then
            printf "               %s\n" "$(printf '%s' "$_vm_line" | cut -c1-100)"
        fi
    }

    _vm_which_one() {
        _vm_tool="$1"
        printf "${CYAN}${BOLD}%s${RESET}\n" "$_vm_tool"
        _vm_p=$(_vm_cmd_path "$_vm_tool")
        if [ -n "$_vm_p" ]; then
            printf "  PATH:   %s\n" "$_vm_p"
            printf "  réel:   %s\n" "$(readlink -f "$_vm_p" 2>/dev/null || echo "$_vm_p")"
            type "$_vm_tool" 2>/dev/null | sed 's/^/  type:   /' || true
        else
            printf "  PATH:   ${RED}absent${RESET}\n"
        fi
        case "$_vm_tool" in
            java|jvm)
                for _vm_home in /usr/lib/jvm/java-*-openjdk; do
                    [ -x "$_vm_home/bin/java" ] || continue
                    printf "  jvm:    %s\n" "$_vm_home/bin/java"
                done
                ;;
            cgoban)
                [ -f /opt/cgoban.jar ] && printf "  jar:    /opt/cgoban.jar\n"
                [ -x "$HOME/.local/bin/cgoban" ] && printf "  wrap:   %s\n" "$HOME/.local/bin/cgoban"
                ;;
        esac
    }

    _vm_scan() {
        _vm_filter="${1:-}"
        printf "%-14s %-18s %s\n" "OUTIL" "VERSION" "CHEMIN"
        printf "%s\n" "────────────────────────────────────────────────────────────"
        _vm_known_list | while IFS= read -r _vm_t || [ -n "$_vm_t" ]; do
            [ -n "$_vm_t" ] || continue
            if [ -n "$_vm_filter" ]; then
                case "$_vm_t" in
                    *"$_vm_filter"*) ;;
                    *) continue ;;
                esac
            fi
            case "$_vm_t" in
                java)
                    _vm_p=$(_vm_cmd_path java)
                    if [ -n "$_vm_p" ]; then
                        _vm_line=$(_vm_probe_bin "$_vm_p" || true)
                        printf "%-14s %-18s %s\n" "java" "$(_vm_extract_ver "$_vm_line")" "$(readlink -f "$_vm_p" 2>/dev/null || echo "$_vm_p")"
                    fi
                    ;;
                *)
                    # silencieux si absent
                    _vm_out=$(_vm_get_one "$_vm_t" 2>/dev/null) || true
                    case "$_vm_out" in
                        *not_installed*) ;;
                        '') ;;
                        *) printf '%s\n' "$_vm_out" | head -n1 ;;
                    esac
                    ;;
            esac
        done
    }

    _vm_menu() {
        while true; do
            _vm_header
            printf "  ${BOLD}1${RESET}) Java / JVM (détail + Applet)\n"
            printf "  ${BOLD}2${RESET}) Scan outils connus\n"
            printf "  ${BOLD}3${RESET}) Version d’un outil (saisie)\n"
            printf "  ${BOLD}4${RESET}) Which / chemins d’un outil\n"
            printf "  ${BOLD}5${RESET}) Scan filtré\n"
            printf "  ${BOLD}0${RESET}) Quitter\n\n"
            printf "Choix: "
            read -r _vm_c || return 0
            case "$_vm_c" in
                1) _vm_java_report; _vm_wait ;;
                2) _vm_scan; _vm_wait ;;
                3)
                    printf "Outil(s) (ex: python node docker): "
                    read -r _vm_args || true
                    # shellcheck disable=SC2086
                    for _vm_t in $_vm_args; do _vm_get_one "$_vm_t"; done
                    _vm_wait
                    ;;
                4)
                    printf "Outil: "
                    read -r _vm_t || true
                    [ -n "$_vm_t" ] && _vm_which_one "$_vm_t"
                    _vm_wait
                    ;;
                5)
                    printf "Motif (ex: java, py, go): "
                    read -r _vm_f || true
                    _vm_scan "$_vm_f"
                    _vm_wait
                    ;;
                0|q|quit|exit) return 0 ;;
                *) printf "${RED}Choix invalide${RESET}\n"; sleep 1 ;;
            esac
        done
    }

    # --- dispatch ---
    _vm_cmd="${1:-}"
    [ "$#" -gt 0 ] && shift
    case "$_vm_cmd" in
        ""|menu) _vm_menu ;;
        help|-h|--help|aide) _vm_help ;;
        java|jvm|jdk|jre) _vm_java_report ;;
        get|ver|version)
            if [ "$#" -eq 0 ]; then
                printf "Usage: versionman get <outil> [outil…]\n" >&2
                return 1
            fi
            for _vm_t in "$@"; do _vm_get_one "$_vm_t"; done
            ;;
        which|where|path)
            if [ "$#" -eq 0 ]; then
                printf "Usage: versionman which <outil>\n" >&2
                return 1
            fi
            for _vm_t in "$@"; do _vm_which_one "$_vm_t"; done
            ;;
        scan|list) _vm_scan "${1:-}" ;;
        all|full) _vm_scan ;;
        *)
            # Raccourci: versionman python  ≡  versionman get python
            _vm_get_one "$_vm_cmd"
            for _vm_t in "$@"; do _vm_get_one "$_vm_t"; done
            ;;
    esac
}

# Exécution directe (shim)
if [ "${0##*/}" = "versionman" ] || [ "${0##*/}" = "versionman.sh" ]; then
    versionman "$@"
fi
