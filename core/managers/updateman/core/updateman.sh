#!/bin/sh
# =============================================================================
# UPDATEMAN - Update Manager (POSIX)
# =============================================================================
# USAGE: updateman [status|all|cursor|help]
# =============================================================================

updateman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    UPDATEMAN_LEGACY_BIN="$HOME/.local/bin/update-cursor-appimage"
    UPDATEMAN_SYSTEMD_DIR="${UPDATEMAN_SYSTEMD_DIR:-$HOME/.config/systemd/user}"
    UPDATEMAN_LIB="$DOTFILES_DIR/core/managers/updateman/lib/updatable_tools.sh"
    UPDATEMAN_SCRIPT="$DOTFILES_DIR/scripts/update/update-cursor-appimage"
    UPDATEMAN_SERVICE_SRC="$DOTFILES_DIR/systemd/user/cursor-update.service"
    UPDATEMAN_TIMER_SRC="$DOTFILES_DIR/systemd/user/cursor-update.timer"
    UPDATEMAN_SERVICE_DST="$UPDATEMAN_SYSTEMD_DIR/cursor-update.service"
    UPDATEMAN_TIMER_DST="$UPDATEMAN_SYSTEMD_DIR/cursor-update.timer"

    if [ -f "$UPDATEMAN_LIB" ]; then
        # shellcheck source=../lib/updatable_tools.sh
        . "$UPDATEMAN_LIB"
        updatable_tools_load_installman_utils
    fi
    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=../../../scripts/lib/manager_ui.sh
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_load_manager_ui
    elif [ -f "$DOTFILES_DIR/scripts/lib/tui_core.sh" ]; then
        # shellcheck source=../../../scripts/lib/tui_core.sh
        . "$DOTFILES_DIR/scripts/lib/tui_core.sh"
    fi

    __updateman_help() {
        printf "${CYAN}${BOLD}UPDATEMAN${RESET} - mises a jour locales\n\n"
        printf "  ${BOLD}updateman status${RESET}              vue d'ensemble (versions + timers)\n"
        printf "  ${BOLD}updateman all${RESET}                 met a jour les outils du registre, un par un\n"
        printf "  ${BOLD}updateman cursor${RESET}              met Cursor a jour maintenant\n"
        printf "  ${BOLD}updateman cursor help${RESET}         detaille l'updater Cursor\n"
        printf "  ${BOLD}updateman cursor install${RESET}      installe les unites systemd user\n"
        printf "  ${BOLD}updateman cursor enable${RESET}       active le timer systemd user\n"
        printf "  ${BOLD}updateman cursor status${RESET}       statut du timer Cursor\n"
        printf "  ${BOLD}updateman cursor logs${RESET}         logs du service Cursor\n"
        printf "  ${BOLD}updateman help${RESET}                affiche cette aide\n"
        printf "\n${YELLOW}Note:${RESET} les scripts internes (ex. update-cursor-appimage) ne sont pas des commandes publiques.\n"
        printf "      Installation initiale : ${BOLD}installman <outil>${RESET} ; mises a jour : ${BOLD}updateman${RESET}.\n"
    }

    __updateman_tools() {
        if command -v updatable_tool_names >/dev/null 2>&1; then
            updatable_tool_names
            return 0
        fi
        printf '%s\n' cursor
    }

    __updateman_cursor_help() {
        printf "${CYAN}${BOLD}UPDATEMAN Cursor${RESET}\n\n"
        printf "Commandes:\n"
        printf "  ${BOLD}updateman cursor${RESET}              telecharge et installe Cursor maintenant\n"
        printf "  ${BOLD}updateman cursor install${RESET}      installe les unites systemd user\n"
        printf "  ${BOLD}updateman cursor enable${RESET}       installe puis active le timer quotidien\n"
        printf "  ${BOLD}updateman cursor status${RESET}       statut du timer systemd user\n"
        printf "  ${BOLD}updateman cursor logs${RESET}         derniers logs du service\n\n"
        printf "Variables utiles:\n"
        printf "  APP_PATH=/chemin/Cursor.AppImage       force le chemin final\n"
        printf "  APP_DIR=/chemin                       force le dossier final si APP_PATH est absent\n"
        printf "  CURRENT_APPIMAGE=/chemin/app.AppImage  force l'ancien chemin a sauvegarder/rediriger\n"
        printf "  DOWNLOAD_URL=https://...               remplace l'URL officielle\n"
        printf "  BACKUP_KEEP=5                          nombre de backups a garder\n\n"
        printf "Detection automatique: .desktop Cursor, processus Cursor en cours, commande cursor, /opt, puis ~/Applications.\n"
        printf "Apres ${BOLD}installman cursor${RESET}, le timer est active automatiquement si possible.\n"
    }

    __updateman_cursor_path() {
        cursor_candidate=""
        if [ -n "${APP_PATH:-}" ] && [ -e "$APP_PATH" ]; then
            printf '%s\n' "$APP_PATH"
            return 0
        fi
        if [ -e "$HOME/Applications/Cursor.AppImage" ]; then
            printf '%s\n' "$HOME/Applications/Cursor.AppImage"
            return 0
        fi
        for cursor_candidate in "$HOME"/Applications/Cursor*.AppImage "$HOME"/Applications/cursor*.AppImage; do
            [ -e "$cursor_candidate" ] || continue
            printf '%s\n' "$cursor_candidate"
            return 0
        done
        if [ -x "$HOME/.local/bin/cursor" ]; then
            sed -n 's/^exec "\([^"]*\)".*/\1/p' "$HOME/.local/bin/cursor" 2>/dev/null | sed -n '1p'
            return 0
        fi
        if command -v cursor >/dev/null 2>&1; then
            cursor_candidate="$(command -v cursor)"
            case "$cursor_candidate" in
                /tmp/.mount_*|/tmp/*) ;;
                *) printf '%s\n' "$cursor_candidate"; return 0 ;;
            esac
        fi
        return 1
    }

    __updateman_tool_versions() {
        _uv_tool="$1"
        _uv_current="n/a"
        _uv_latest="n/a"
        _uv_update="?"
        if command -v get_current_version >/dev/null 2>&1; then
            _uv_current="$(get_current_version "$_uv_tool" 2>/dev/null || echo "n/a")"
            _uv_latest="$(get_latest_version "$_uv_tool" 2>/dev/null || echo "n/a")"
            if command -v is_update_available >/dev/null 2>&1 && is_update_available "$_uv_tool" 2>/dev/null; then
                _uv_update="oui"
            elif [ "$_uv_current" = "not_installed" ] || [ "$_uv_current" = "n/a" ]; then
                _uv_update="-"
            else
                _uv_update="non"
            fi
        fi
        printf '%s|%s|%s' "$_uv_current" "$_uv_latest" "$_uv_update"
    }

    __updateman_tool_location() {
        case "$1" in
            cursor) __updateman_cursor_path 2>/dev/null || printf '%s' "-" ;;
            *) printf '%s' "-" ;;
        esac
    }

    __updateman_status_all() {
        _loc_max=48
        if command -v tui_is_compact >/dev/null 2>&1 && tui_is_compact; then
            _loc_max=22
        fi
        printf "${CYAN}${BOLD}UPDATEMAN status${RESET}\n\n"
        if command -v tui_is_compact >/dev/null 2>&1 && tui_is_compact; then
            printf '%-10s %-8s %-10s %-8s %-6s %s\n' \
                "outil" "etat" "version" "maj?" "timer" "emplacement"
        else
            printf '%-12s %-10s %-14s %-14s %-8s %-10s %s\n' \
                "outil" "installe" "version" "disponible" "maj?" "timer" "emplacement"
        fi
        for _us_tool in $(__updateman_tools); do
            if updatable_tool_check_installed "$_us_tool" 2>/dev/null; then
                _us_inst="present"
            else
                _us_inst="absent"
            fi
            _us_timer="$(updatable_tool_timer_state "$_us_tool" 2>/dev/null || printf '%s' "-")"
            _us_loc="$(__updateman_tool_location "$_us_tool")"
            if command -v tui_truncate >/dev/null 2>&1; then
                _us_loc="$(tui_truncate "$_us_loc" "$_loc_max")"
            fi
            _us_vers="$(__updateman_tool_versions "$_us_tool")"
            _us_cur="${_us_vers%%|*}"
            _us_rest="${_us_vers#*|}"
            _us_lat="${_us_rest%%|*}"
            _us_upd="${_us_rest#*|}"
            if command -v tui_is_compact >/dev/null 2>&1 && tui_is_compact; then
                printf '%-10s %-8s %-10s %-8s %-6s %s\n' \
                    "$_us_tool" "$_us_inst" "$_us_cur" "$_us_upd" "$_us_timer" "$_us_loc"
            else
                printf '%-12s %-10s %-14s %-14s %-8s %-10s %s\n' \
                    "$_us_tool" "$_us_inst" "$_us_cur" "$_us_lat" "$_us_upd" "$_us_timer" "$_us_loc"
            fi
        done
        printf '\n%s\n' "Registre: core/managers/updateman/config/updatable-tools.list"
    }

    __updateman_need_file() {
        if [ ! -f "$1" ]; then
            printf "${RED}Fichier introuvable:${RESET} %s\n" "$1" >&2
            return 1
        fi
        return 0
    }

    __updateman_run_cursor() {
        __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
        if ! command -v bash >/dev/null 2>&1; then
            printf "${RED}bash introuvable:${RESET} l'updater Cursor necessite Bash.\n" >&2
            return 1
        fi
        bash "$UPDATEMAN_SCRIPT"
    }

    __updateman_run_tool() {
        case "$1" in
            cursor) __updateman_run_cursor ;;
            *)
                printf "${RED}outil non gere:${RESET} %s\n" "$1" >&2
                return 1
                ;;
        esac
    }

    __updateman_update_all() {
        rc=0
        for tool in $(__updateman_tools); do
            if ! updatable_tool_check_installed "$tool" 2>/dev/null; then
                printf "${YELLOW}==> %s ignore (non installe)${RESET}\n" "$tool"
                continue
            fi
            printf "${CYAN}${BOLD}==> updateman %s${RESET}\n" "$tool"
            __updateman_run_tool "$tool" || rc=1
        done
        return "$rc"
    }

    __updateman_install_cursor_files() {
        __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
        __updateman_need_file "$UPDATEMAN_SERVICE_SRC" || return 1
        __updateman_need_file "$UPDATEMAN_TIMER_SRC" || return 1

        mkdir -p "$UPDATEMAN_SYSTEMD_DIR" || return 1
        cp "$UPDATEMAN_SERVICE_SRC" "$UPDATEMAN_SERVICE_DST" || return 1
        cp "$UPDATEMAN_TIMER_SRC" "$UPDATEMAN_TIMER_DST" || return 1
        rm -f "$UPDATEMAN_LEGACY_BIN" 2>/dev/null || true

        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload || return 1
        fi

        printf "${GREEN}OK:${RESET} unites systemd installees dans %s\n" "$UPDATEMAN_SYSTEMD_DIR"
        printf "${GREEN}OK:${RESET} pas de commande publique update-cursor-appimage (utiliser updateman cursor)\n"
    }

    __updateman_enable_cursor_timer() {
        __updateman_install_cursor_files || return 1
        if ! command -v systemctl >/dev/null 2>&1; then
            printf "${YELLOW}systemctl absent:${RESET} timer installe mais non active.\n" >&2
            return 1
        fi
        systemctl --user enable --now cursor-update.timer
    }

    __updateman_install_tool_files() {
        case "$1" in
            cursor) __updateman_install_cursor_files ;;
            *)
                printf "${YELLOW}aucune unite systemd a installer pour:${RESET} %s\n" "$1"
                return 0
                ;;
        esac
    }

    __updateman_setup_tool_service() {
        case "$1" in
            cursor) __updateman_enable_cursor_timer ;;
            *)
                printf "${YELLOW}aucun timer configure pour:${RESET} %s\n" "$1" >&2
                return 0
                ;;
        esac
    }

    __updateman_tool_timer_unit() {
        _ttu_line="$(updatable_tool_find "$1" 2>/dev/null)"
        [ -n "$_ttu_line" ] || return 1
        updatable_tool_field "$_ttu_line" 3
    }

    __updateman_tool_timer_status() {
        _tts_timer="$(__updateman_tool_timer_unit "$1")"
        [ -n "$_tts_timer" ] && [ "$_tts_timer" != "-" ] || {
            printf "${YELLOW}pas de timer pour %s${RESET}\n" "$1" >&2
            return 1
        }
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user status "$_tts_timer" --no-pager
        else
            printf "${YELLOW}systemctl absent.${RESET}\n" >&2
            return 1
        fi
    }

    __updateman_tool_timer_logs() {
        _ttl_timer="$(__updateman_tool_timer_unit "$1")"
        [ -n "$_ttl_timer" ] && [ "$_ttl_timer" != "-" ] || return 1
        _ttl_svc="${_ttl_timer%.timer}.service"
        if command -v journalctl >/dev/null 2>&1; then
            journalctl --user -u "$_ttl_svc" -n 80 --no-pager
        else
            printf "${YELLOW}journalctl absent.${RESET}\n" >&2
            return 1
        fi
    }

    __updateman_dispatch_tool() {
        _dt_tool="$1"
        _dt_sub="${2:-run}"
        case "$_dt_sub" in
            help|-h|--help|aide)
                if [ "$_dt_tool" = "cursor" ]; then
                    __updateman_cursor_help
                else
                    printf "${CYAN}updateman %s${RESET} — outil du registre\n" "$_dt_tool"
                fi
                ;;
            run|update|now) __updateman_run_tool "$_dt_tool" ;;
            install|setup) __updateman_install_tool_files "$_dt_tool" ;;
            enable|timer|auto) __updateman_setup_tool_service "$_dt_tool" ;;
            status) __updateman_tool_timer_status "$_dt_tool" ;;
            logs|log) __updateman_tool_timer_logs "$_dt_tool" ;;
            *)
                printf "${RED}Sous-commande inconnue:${RESET} %s\n\n" "$_dt_sub" >&2
                __updateman_help
                return 1
                ;;
        esac
    }

    cmd="${1:-help}"
    case "$cmd" in
        help|-h|--help)
            __updateman_help
            ;;
        status|list|overview)
            __updateman_status_all
            ;;
        all|upgrade-all|update-all)
            __updateman_update_all
            ;;
        cursor)
            __updateman_dispatch_tool cursor "${2:-run}"
            ;;
        *)
            if updatable_tool_is_registered "$cmd" 2>/dev/null; then
                __updateman_dispatch_tool "$cmd" "${2:-run}"
                return $?
            fi
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            __updateman_help
            return 1
            ;;
    esac
}
