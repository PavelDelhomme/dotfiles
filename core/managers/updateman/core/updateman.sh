#!/bin/sh
# =============================================================================
# UPDATEMAN - Update Manager (POSIX)
# =============================================================================
# USAGE: updateman cursor [run|install|enable|status|logs|help]
# =============================================================================

updateman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    UPDATEMAN_BIN_DIR="${UPDATEMAN_BIN_DIR:-$HOME/.local/bin}"
    UPDATEMAN_SYSTEMD_DIR="${UPDATEMAN_SYSTEMD_DIR:-$HOME/.config/systemd/user}"
    UPDATEMAN_SCRIPT="$DOTFILES_DIR/scripts/update/update-cursor-appimage"
    UPDATEMAN_BIN="$UPDATEMAN_BIN_DIR/update-cursor-appimage"
    UPDATEMAN_SERVICE_SRC="$DOTFILES_DIR/systemd/user/cursor-update.service"
    UPDATEMAN_TIMER_SRC="$DOTFILES_DIR/systemd/user/cursor-update.timer"
    UPDATEMAN_SERVICE_DST="$UPDATEMAN_SYSTEMD_DIR/cursor-update.service"
    UPDATEMAN_TIMER_DST="$UPDATEMAN_SYSTEMD_DIR/cursor-update.timer"

    __updateman_help() {
        printf "${CYAN}${BOLD}UPDATEMAN${RESET} - mises a jour locales\n\n"
        printf "  ${BOLD}updateman cursor${RESET}              met Cursor a jour maintenant\n"
        printf "  ${BOLD}updateman cursor help${RESET}         detaille l'updater Cursor\n"
        printf "  ${BOLD}updateman cursor install${RESET}      installe le binaire + timer systemd user\n"
        printf "  ${BOLD}updateman cursor enable${RESET}       active le timer systemd user\n"
        printf "  ${BOLD}updateman cursor status${RESET}       affiche le statut du timer\n"
        printf "  ${BOLD}updateman cursor logs${RESET}         affiche les derniers logs\n"
        printf "  ${BOLD}updateman help${RESET}                affiche cette aide\n"
    }

    __updateman_cursor_help() {
        printf "${CYAN}${BOLD}UPDATEMAN Cursor${RESET}\n\n"
        printf "Commandes:\n"
        printf "  ${BOLD}updateman cursor${RESET}              telecharge et installe Cursor maintenant\n"
        printf "  ${BOLD}updateman cursor install${RESET}      copie l'updater dans ~/.local/bin et les unites systemd user\n"
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
    }

    __updateman_need_file() {
        if [ ! -f "$1" ]; then
            printf "${RED}Fichier introuvable:${RESET} %s\n" "$1" >&2
            return 1
        fi
        return 0
    }

    __updateman_install_cursor_files() {
        __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
        __updateman_need_file "$UPDATEMAN_SERVICE_SRC" || return 1
        __updateman_need_file "$UPDATEMAN_TIMER_SRC" || return 1

        mkdir -p "$UPDATEMAN_BIN_DIR" "$UPDATEMAN_SYSTEMD_DIR" || return 1
        cp "$UPDATEMAN_SCRIPT" "$UPDATEMAN_BIN" || return 1
        chmod 0755 "$UPDATEMAN_BIN" || return 1
        cp "$UPDATEMAN_SERVICE_SRC" "$UPDATEMAN_SERVICE_DST" || return 1
        cp "$UPDATEMAN_TIMER_SRC" "$UPDATEMAN_TIMER_DST" || return 1

        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload || return 1
        fi

        printf "${GREEN}OK:${RESET} updater installe dans %s\n" "$UPDATEMAN_BIN"
        printf "${GREEN}OK:${RESET} unites systemd installees dans %s\n" "$UPDATEMAN_SYSTEMD_DIR"
    }

    __updateman_enable_cursor_timer() {
        __updateman_install_cursor_files || return 1
        if ! command -v systemctl >/dev/null 2>&1; then
            printf "${YELLOW}systemctl absent:${RESET} timer installe mais non active.\n" >&2
            return 1
        fi
        systemctl --user enable --now cursor-update.timer
    }

    __updateman_cursor_status() {
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user status cursor-update.timer --no-pager
        else
            printf "${YELLOW}systemctl absent.${RESET}\n" >&2
            return 1
        fi
    }

    __updateman_cursor_logs() {
        if command -v journalctl >/dev/null 2>&1; then
            journalctl --user -u cursor-update.service -n 80 --no-pager
        else
            printf "${YELLOW}journalctl absent.${RESET}\n" >&2
            return 1
        fi
    }

    cmd="${1:-help}"
    case "$cmd" in
        help|-h|--help)
            __updateman_help
            ;;
        cursor)
            subcmd="${2:-run}"
            case "$subcmd" in
                help|-h|--help|aide)
                    __updateman_cursor_help
                    ;;
                run|update|now)
                    if [ -x "$UPDATEMAN_BIN" ]; then
                        "$UPDATEMAN_BIN"
                    else
                        __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
                        if ! command -v bash >/dev/null 2>&1; then
                            printf "${RED}bash introuvable:${RESET} l'updater Cursor necessite Bash.\n" >&2
                            return 1
                        fi
                        bash "$UPDATEMAN_SCRIPT"
                    fi
                    ;;
                install|setup)
                    __updateman_install_cursor_files
                    ;;
                enable|timer|auto)
                    __updateman_enable_cursor_timer
                    ;;
                status)
                    __updateman_cursor_status
                    ;;
                logs|log)
                    __updateman_cursor_logs
                    ;;
                *)
                    printf "${RED}Sous-commande inconnue:${RESET} %s\n\n" "$subcmd" >&2
                    __updateman_help
                    return 1
                    ;;
            esac
            ;;
        *)
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            __updateman_help
            return 1
            ;;
    esac
}
