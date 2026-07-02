#!/bin/sh
# =============================================================================
# UPDATEMAN - Update Manager (POSIX)
# =============================================================================
# USAGE: updateman [status|all|arch|cursor|help]
# =============================================================================

updateman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/core/lib/distro.sh" ]; then
        # shellcheck source=../../../lib/distro.sh
        . "$DOTFILES_DIR/core/lib/distro.sh"
    fi
    if [ -f "$DOTFILES_DIR/core/lib/pkg_backend.sh" ]; then
        # shellcheck source=../../../lib/pkg_backend.sh
        . "$DOTFILES_DIR/core/lib/pkg_backend.sh"
    fi
    if [ -f "$DOTFILES_DIR/core/lib/tool_release.sh" ]; then
        # shellcheck source=../../../lib/tool_release.sh
        . "$DOTFILES_DIR/core/lib/tool_release.sh"
    fi
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
        printf "  ${BOLD}updateman all${RESET}                 paquets systeme (detectes) + outils du registre\n"
        printf "  ${BOLD}updateman all --tools-only${RESET}    uniquement les outils du registre (Cursor, …)\n"
        printf "  ${BOLD}updateman system status${RESET}       distro, backends, maj en attente\n"
        printf "  ${BOLD}updateman system refresh${RESET}    met a jour les index (apt/dnf/apk/zypper/…)\n"
        printf "  ${BOLD}updateman system update${RESET}       applique les mises a jour systeme detectees\n"
        printf "  ${BOLD}updateman arch status${RESET}         diagnostic pacman/yay (Arch detaille)\n"
        printf "  ${BOLD}updateman arch update${RESET}         sudo pacman -Syu puis yay -Sua\n"
        printf "  ${BOLD}updateman arch keys librewolf${RESET} importe la cle PGP LibreWolf\n"
        printf "  ${BOLD}updateman arch fix-cache${RESET}      supprime les dossiers download-* orphelins (pacman -Sc)\n"
        printf "  ${BOLD}updateman cursor${RESET}              met Cursor a jour maintenant\n"
        printf "  ${BOLD}updateman cursor check${RESET}        version locale vs API officielle\n"
        printf "  ${BOLD}updateman cursor help${RESET}         detaille l'updater Cursor\n"
        printf "  ${BOLD}updateman cursor install${RESET}      installe les unites systemd user\n"
        printf "  ${BOLD}updateman cursor enable${RESET}       active le timer systemd user\n"
        printf "  ${BOLD}updateman cursor status${RESET}       installation, versions, maj, timer\n"
        printf "  ${BOLD}updateman cursor logs${RESET}         logs du service Cursor\n"
        printf "  ${BOLD}updateman help${RESET}                affiche cette aide\n"
        printf "\n${YELLOW}Note:${RESET} les scripts internes (ex. update-cursor-appimage) ne sont pas des commandes publiques.\n"
        printf "      Installation initiale : ${BOLD}installman <outil>${RESET} ; mises a jour : ${BOLD}updateman${RESET}.\n"
    }

    __updateman_system_help() {
        printf "${CYAN}${BOLD}UPDATEMAN system${RESET} — paquets multi-distro\n\n"
        printf "Commandes:\n"
        printf "  ${BOLD}updateman system status${RESET}   distro + backends detectes + pending\n"
        printf "  ${BOLD}updateman system pending${RESET}  liste des mises a jour par backend\n"
        printf "  ${BOLD}updateman system refresh${RESET}  refresh index (apt update, dnf makecache, apk update, …)\n"
        printf "  ${BOLD}updateman system update${RESET}   upgrade des backends detectes\n\n"
        printf "Backends: pacman yay paru | apt | dnf yum tdnf | apk | zypper | emerge | flatpak | snap\n"
        printf "Sur Arch, ${BOLD}updateman arch${RESET} reste disponible pour le diagnostic detaille.\n"
        printf "Immutable (Flatcar/CoreOS): ${BOLD}rpm-ostree${RESET} si present.\n"
    }

    __updateman_system_status() {
        printf "${CYAN}${BOLD}UPDATEMAN system status${RESET}\n\n"
        if command -v dotfiles_detect_distro_pretty >/dev/null 2>&1; then
            printf "Distro: %s (famille: %s)\n\n" \
                "$(dotfiles_detect_distro_pretty 2>/dev/null || echo '?')" \
                "$(dotfiles_detect_distro 2>/dev/null || echo unknown)"
        fi
        if ! command -v pkg_backend_list >/dev/null 2>&1; then
            printf "${RED}pkg_backend.sh introuvable.${RESET}\n" >&2
            return 1
        fi
        printf "${CYAN}${BOLD}Backends detectes${RESET}\n"
        printf '  %s\n\n' "$(pkg_backend_list)"
        __updateman_system_pending
    }

    __updateman_system_pending() {
        if ! command -v pkg_backend_list >/dev/null 2>&1; then
            return 1
        fi
        _usp_any=0
        for _usp in $(pkg_backend_list); do
            printf "${CYAN}${BOLD}=== %s ===${RESET}\n" "$_usp"
            if pkg_backend_pending "$_usp"; then
                _usp_any=1
            else
                printf "  (aucune mise a jour ou backend indisponible)\n"
            fi
            printf '\n'
        done
        if [ "$_usp_any" -eq 0 ]; then
            printf "${GREEN}Aucune mise a jour detectee sur les backends actifs.${RESET}\n"
        fi
    }

    __updateman_system_refresh() {
        if ! command -v pkg_backend_refresh_all >/dev/null 2>&1; then
            printf "${RED}pkg_backend indisponible.${RESET}\n" >&2
            return 1
        fi
        pkg_backend_refresh_all
    }

    __updateman_system_update() {
        if ! command -v pkg_backend_upgrade_all >/dev/null 2>&1; then
            printf "${RED}pkg_backend indisponible.${RESET}\n" >&2
            return 1
        fi
        pkg_backend_upgrade_all
    }

    __updateman_system() {
        _sys_sub="${1:-status}"
        case "$_sys_sub" in
            help|-h|--help|aide) __updateman_system_help ;;
            status|check) __updateman_system_status ;;
            pending|updates|list) __updateman_system_pending ;;
            refresh|sync|update-index) __updateman_system_refresh ;;
            update|upgrade|run) __updateman_system_update ;;
            *)
                printf "${RED}Sous-commande system inconnue:${RESET} %s\n\n" "$_sys_sub" >&2
                __updateman_system_help
                return 1
                ;;
        esac
    }

    __updateman_arch_help() {
        printf "${CYAN}${BOLD}UPDATEMAN Arch/AUR${RESET}\n\n"
        printf "Commandes:\n"
        printf "  ${BOLD}updateman arch status${RESET}         affiche les mises a jour et problemes probables\n"
        printf "  ${BOLD}updateman arch update${RESET}         lance sudo pacman -Syu puis yay -Sua\n"
        printf "  ${BOLD}updateman arch keys librewolf${RESET} importe la cle PGP LibreWolf/AUR\n"
        printf "  ${BOLD}updateman arch fix-cache${RESET}      supprime download-* orphelins (erreur pacman -Sc)\n"
        printf "  ${BOLD}updateman arch clean-hints${RESET}    affiche des commandes de nettoyage, sans les executer\n\n"
        printf "Regles:\n"
        printf "  - ne jamais lancer yay avec sudo ; yay gere sudo uniquement pour pacman\n"
        printf "  - si une signature AUR echoue, importer la cle mainteneur puis relancer\n"
        printf "  - garder /tmp et ~/.cache/yay raisonnables pour les builds AUR lourds\n"
    }

    __updateman_arch_pending() {
        printf "${CYAN}${BOLD}Mises a jour pacman${RESET}\n"
        if command -v pacman >/dev/null 2>&1; then
            pacman -Qu 2>/dev/null || true
        else
            printf "${YELLOW}pacman absent.${RESET}\n"
        fi
        printf "\n${CYAN}${BOLD}Mises a jour AUR (yay)${RESET}\n"
        if command -v yay >/dev/null 2>&1; then
            yay -Qua 2>/dev/null || true
        else
            printf "${YELLOW}yay absent.${RESET}\n"
        fi
    }

    __updateman_arch_status() {
        printf "${CYAN}${BOLD}UPDATEMAN Arch status${RESET}\n\n"
        if [ "$(id -u)" -eq 0 ]; then
            printf "${YELLOW}Attention:${RESET} ne lance pas yay en root/sudo.\n\n"
        fi

        printf "${CYAN}${BOLD}Espace disque${RESET}\n"
        df -h / /home /var /tmp 2>/dev/null || df -h 2>/dev/null || true
        printf "\n"

        printf "${CYAN}${BOLD}Verrou pacman${RESET}\n"
        if [ -e /var/lib/pacman/db.lck ]; then
            printf "${RED}Verrou present:${RESET} /var/lib/pacman/db.lck\n"
            printf "Verifier qu'aucun pacman/yay n'est actif avant suppression manuelle.\n"
        else
            printf "${GREEN}OK:${RESET} pas de verrou pacman.\n"
        fi
        printf "\n"

        __updateman_arch_pending
        printf "\n${CYAN}${BOLD}Caches${RESET}\n"
        du -sh /var/cache/pacman/pkg "$HOME/.cache/yay" /tmp 2>/dev/null || true
        _ua_dl_count=0
        if [ -d /var/cache/pacman/pkg ] && command -v find >/dev/null 2>&1; then
            _ua_dl_count=$(find /var/cache/pacman/pkg -maxdepth 1 -type d -name 'download-*' 2>/dev/null | wc -l)
            _ua_dl_count=${_ua_dl_count//[[:space:]]/}
        fi
        if [ "$_ua_dl_count" -gt 0 ]; then
            printf "${YELLOW}Attention:${RESET} %s dossier(s) download-* dans /var/cache/pacman/pkg\n" "$_ua_dl_count"
            printf "Cela casse souvent ${BOLD}sudo pacman -Sc${RESET} (Error reading fd 7).\n"
            printf "Corriger: ${BOLD}updateman arch fix-cache${RESET}\n"
        fi
        printf "\nAstuce: ${BOLD}updateman arch clean-hints${RESET} affiche les nettoyages prudents.\n"
    }

    __updateman_arch_fix_cache() {
        if [ -e /var/lib/pacman/db.lck ]; then
            printf "${RED}Verrou pacman actif:${RESET} attendez la fin de pacman/yay.\n" >&2
            return 1
        fi
        _afc_count=0
        if [ -d /var/cache/pacman/pkg ] && command -v find >/dev/null 2>&1; then
            _afc_count=$(find /var/cache/pacman/pkg -maxdepth 1 -type d -name 'download-*' 2>/dev/null | wc -l)
            _afc_count=${_afc_count//[[:space:]]/}
        fi
        if [ "$_afc_count" -eq 0 ]; then
            printf "${GREEN}OK:${RESET} aucun dossier download-* orphelin.\n"
            return 0
        fi
        printf "${CYAN}${BOLD}Suppression de %s dossier(s) download-* orphelin(s)${RESET}\n" "$_afc_count"
        printf "(restes de telechargements pacman/yay interrompus, proprietaire alpm)\n\n"
        if [ "$(id -u)" -eq 0 ]; then
            find /var/cache/pacman/pkg -maxdepth 1 -type d -name 'download-*' -exec rm -rf {} +
        else
            sudo find /var/cache/pacman/pkg -maxdepth 1 -type d -name 'download-*' -exec rm -rf {} +
        fi
        printf "${GREEN}OK:${RESET} cache pacman repare. Relancez ${BOLD}sudo pacman -Sc${RESET}.\n"
    }

    __updateman_arch_update() {
        if [ "$(id -u)" -eq 0 ]; then
            printf "${RED}Refus:${RESET} lance cette commande en utilisateur normal, pas avec sudo.\n" >&2
            return 1
        fi
        if ! command -v pacman >/dev/null 2>&1; then
            printf "${RED}pacman introuvable.${RESET}\n" >&2
            return 1
        fi
        printf "${CYAN}${BOLD}==> sudo pacman -Syu${RESET}\n"
        sudo pacman -Syu || return 1
        if command -v yay >/dev/null 2>&1; then
            printf "\n${CYAN}${BOLD}==> yay -Sua${RESET}\n"
            yay -Sua
        else
            printf "${YELLOW}yay absent:${RESET} mise a jour AUR ignoree.\n"
        fi
    }

    __updateman_arch_keys() {
        _ak_target="${1:-help}"
        case "$_ak_target" in
            librewolf|librewolf-bin)
                if ! command -v gpg >/dev/null 2>&1; then
                    printf "${RED}gpg introuvable.${RESET}\n" >&2
                    return 1
                fi
                printf "${CYAN}${BOLD}Import cle LibreWolf${RESET}\n"
                gpg --keyserver keys.openpgp.org --recv-keys 662E3CDD6FE329002D0CA5BB40339DD82B12EF16 ||
                    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 662E3CDD6FE329002D0CA5BB40339DD82B12EF16
                ;;
            *)
                printf "Cles connues:\n"
                printf "  ${BOLD}updateman arch keys librewolf${RESET}  cle LibreWolf Maintainers\n"
                ;;
        esac
    }

    __updateman_arch_clean_hints() {
        printf "${CYAN}${BOLD}Nettoyage prudent (commandes a lancer manuellement)${RESET}\n\n"
        printf "  ${BOLD}yay -Sc${RESET}              nettoie les caches AUR non necessaires\n"
        printf "  ${BOLD}updateman arch fix-cache${RESET}  supprime download-* avant pacman -Sc\n"
        printf "  ${BOLD}sudo pacman -Sc${RESET}           nettoie le cache pacman en gardant les versions utiles\n"
        printf "  ${BOLD}yay -Sc${RESET}                   nettoie le cache AUR utilisateur\n"
        printf "  ${BOLD}rm -rf ~/.cache/yay/<pkg>${RESET}  reconstruit un paquet AUR au prochain yay\n\n"
        printf "${YELLOW}Eviter:${RESET} sudo yay, nettoyage pendant une update en cours.\n"
    }

    __updateman_arch() {
        _arch_sub="${1:-status}"
        case "$_arch_sub" in
            help|-h|--help|aide) __updateman_arch_help ;;
            status|check|diagnose|diagnostic) __updateman_arch_status ;;
            pending|updates|list) __updateman_arch_pending ;;
            update|upgrade|run) __updateman_arch_update ;;
            keys|key|gpg) shift; __updateman_arch_keys "${1:-help}" ;;
            fix-cache|fixcache|repair-cache) __updateman_arch_fix_cache ;;
            clean-hints|clean|cleanup) __updateman_arch_clean_hints ;;
            *)
                printf "${RED}Sous-commande arch inconnue:${RESET} %s\n\n" "$_arch_sub" >&2
                __updateman_arch_help
                return 1
                ;;
        esac
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
        printf "  ${BOLD}updateman cursor check${RESET}        compare version locale et API stable\n"
        printf "  ${BOLD}updateman cursor install${RESET}      installe les unites systemd user\n"
        printf "  ${BOLD}updateman cursor enable${RESET}       installe puis active le timer quotidien\n"
        printf "  ${BOLD}updateman cursor status${RESET}       installation, versions, maj, timer (--verbose)\n"
        printf "  ${BOLD}updateman cursor logs${RESET}         derniers logs du service\n\n"
        printf "Variables utiles:\n"
        printf "  APP_PATH=/chemin/Cursor.AppImage       force le chemin final\n"
        printf "  APP_DIR=/chemin                       force le dossier final si APP_PATH est absent\n"
        printf "  CURRENT_APPIMAGE=/chemin/app.AppImage  force l'ancien chemin a sauvegarder/rediriger\n"
        printf "  DOWNLOAD_URL=https://...               remplace l'URL officielle\n"
        printf "  CURSOR_RELEASE_TRACK=stable            stable ou insiders (API Cursor)\n"
        printf "  CURSOR_UPDATE_FORCE=1                  telecharge meme si version identique\n"
        printf "  BACKUP_KEEP=5                          nombre de backups a garder\n\n"
        printf "Release API: api2.cursor.sh/updates/api/download/<track>/<platform>/cursor\n"
        printf "Fallback: www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable\n\n"
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

    __updateman_local_version() {
        _ulv_tool="$1"
        case "$_ulv_tool" in
            cursor)
                for _ulv_vf in \
                    "$HOME/Applications/.cursor-version" \
                    "$HOME/.config/cursor/version" \
                    "$HOME/Applications/cursor/.cursor-version" \
                    "$HOME/.cursor-version"; do
                    if [ -f "$_ulv_vf" ]; then
                        tr -d ' \n\r' <"$_ulv_vf" 2>/dev/null | head -c 64
                        return 0
                    fi
                done
                for _ulv_df in "$HOME/.local/share/applications/cursor.desktop" /usr/share/applications/cursor.desktop; do
                    if [ -f "$_ulv_df" ] && grep -qE '^Version=' "$_ulv_df" 2>/dev/null; then
                        grep -m1 '^Version=' "$_ulv_df" | cut -d= -f2- | tr -d ' \n\r'
                        return 0
                    fi
                done
                for _ulv_vf in "$HOME/Applications"/Cursor*.AppImage "$HOME/Applications"/cursor*.AppImage /opt/cursor.appimage; do
                    [ -f "$_ulv_vf" ] || continue
                    _ulv_base="$(basename "$_ulv_vf")"
                    case "$_ulv_base" in
                        Cursor-*-*) printf '%s' "$_ulv_base" | sed -n 's/Cursor-\([0-9][0-9.]*\)-.*/\1/p' ;;
                        cursor-*-*) printf '%s' "$_ulv_base" | sed -n 's/cursor-\([0-9][0-9.]*\)-.*/\1/p' ;;
                    esac
                    return 0
                done
                if [ -f /usr/share/cursor/resources/app/product.json ]; then
                    grep -oE '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' \
                        /usr/share/cursor/resources/app/product.json 2>/dev/null \
                        | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || printf 'unknown'
                    return 0
                fi
                if [ -x /opt/cursor.appimage ] || command -v cursor >/dev/null 2>&1 \
                   || [ -d /usr/share/cursor/resources/app ]; then
                    printf 'unknown'
                    return 0
                fi
                printf 'not_installed'
                ;;
            docker)
                if command -v docker >/dev/null 2>&1; then
                    docker --version 2>/dev/null | sed -n 's/.*version \([0-9][^, ]*\).*/\1/p' | head -n1
                    return 0
                fi
                printf 'not_installed'
                ;;
            brave)
                if command -v brave >/dev/null 2>&1; then
                    brave --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
                    return 0
                fi
                if command -v brave-browser >/dev/null 2>&1; then
                    brave-browser --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
                    return 0
                fi
                printf 'not_installed'
                ;;
            *)
                printf 'n/a'
                ;;
        esac
    }

    __updateman_remote_version() {
        _urv_tool="$1"
        _urv_kind="$(updatable_tool_update_kind "$_urv_tool" 2>/dev/null || printf '%s' unknown)"
        case "$_urv_kind" in
            cursor_appimage)
                if command -v tool_release_cursor_fetch >/dev/null 2>&1 && tool_release_cursor_fetch; then
                    printf '%s' "${TOOL_RELEASE_VERSION:-n/a}"
                    return 0
                fi
                printf 'n/a'
                ;;
            pkg)
                if command -v get_latest_version >/dev/null 2>&1; then
                    _urv_lat="$(get_latest_version "$_urv_tool" 2>/dev/null || printf '%s' n/a)"
                    [ -n "$_urv_lat" ] && [ "$_urv_lat" != "latest" ] && { printf '%s' "$_urv_lat"; return 0; }
                fi
                if command -v pkg_backend_tool_has_pending_update >/dev/null 2>&1 \
                   && pkg_backend_tool_has_pending_update "$_urv_tool" 2>/dev/null; then
                    printf 'disponible (depot)'
                    return 0
                fi
                printf 'a jour (depot)'
                ;;
            *)
                if command -v get_latest_version >/dev/null 2>&1; then
                    get_latest_version "$_urv_tool" 2>/dev/null || printf 'n/a'
                else
                    printf 'n/a'
                fi
                ;;
        esac
    }

    __updateman_version_update_label() {
        _vul_cur="$1"
        _vul_rem="$2"
        _vul_tool="${3:-}"
        if [ "$_vul_cur" = "not_installed" ] || [ "$_vul_cur" = "n/a" ]; then
            printf '%s' "-"
            return 0
        fi
        if [ "$_vul_rem" = "disponible (depot)" ]; then
            printf '%s' "oui"
            return 0
        fi
        if [ "$_vul_rem" = "a jour (depot)" ]; then
            printf '%s' "non"
            return 0
        fi
        if [ -n "$_vul_tool" ] && command -v pkg_backend_tool_has_pending_update >/dev/null 2>&1 \
           && pkg_backend_tool_has_pending_update "$_vul_tool" 2>/dev/null; then
            printf '%s' "oui"
            return 0
        fi
        if command -v is_update_available >/dev/null 2>&1 && [ -n "$_vul_tool" ] \
           && is_update_available "$_vul_tool" 2>/dev/null; then
            printf '%s' "oui"
            return 0
        fi
        if [ "$_vul_cur" = "unknown" ] || [ "$_vul_rem" = "n/a" ] || [ -z "$_vul_rem" ]; then
            printf '%s' "?"
            return 0
        fi
        if [ "$_vul_cur" = "$_vul_rem" ]; then
            printf '%s' "non"
            return 0
        fi
        if [ "$(printf '%s\n' "$_vul_cur" "$_vul_rem" | sort -V | head -n1)" = "$_vul_cur" ] \
           && [ "$_vul_cur" != "$_vul_rem" ]; then
            printf '%s' "oui"
            return 0
        fi
        printf '%s' "non"
    }

    __updateman_tool_versions() {
        _uv_tool="$1"
        _uv_current="$(__updateman_local_version "$_uv_tool")"
        if command -v get_current_version >/dev/null 2>&1; then
            case "$_uv_current" in unknown|not_installed|n/a|'')
                _uv_zsh="$(get_current_version "$_uv_tool" 2>/dev/null || true)"
                case "$_uv_zsh" in
                    not_installed|unknown|n/a|'') ;;
                    *) _uv_current="$_uv_zsh" ;;
                esac
                ;;
            esac
        fi
        _uv_latest="$(__updateman_remote_version "$_uv_tool")"
        _uv_update="$(__updateman_version_update_label "$_uv_current" "$_uv_latest" "$_uv_tool")"
        printf '%s|%s|%s' "$_uv_current" "$_uv_latest" "$_uv_update"
    }

    __updateman_tool_installed_label() {
        if updatable_tool_check_installed "$1" 2>/dev/null; then
            printf 'present'
            return 0
        fi
        case "$(__updateman_local_version "$1")" in
            not_installed|n/a|'') printf 'absent' ;;
            *) printf 'present' ;;
        esac
    }

    __updateman_tool_location() {
        case "$1" in
            cursor) __updateman_cursor_path 2>/dev/null || printf '%s' "-" ;;
            docker)
                if command -v docker >/dev/null 2>&1; then command -v docker; else printf '%s' "-"; fi
                ;;
            brave)
                if command -v brave >/dev/null 2>&1; then command -v brave
                elif command -v brave-browser >/dev/null 2>&1; then command -v brave-browser
                else printf '%s' "-"; fi
                ;;
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
            _us_inst="$(__updateman_tool_installed_label "$_us_tool")"
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

    __updateman_cursor_check() {
        if ! command -v tool_release_cursor_fetch >/dev/null 2>&1; then
            printf "${RED}tool_release.sh introuvable.${RESET}\n" >&2
            return 1
        fi
        if ! tool_release_cursor_fetch; then
            printf "${RED}Impossible de joindre l'API Cursor.${RESET}\n" >&2
            return 1
        fi
        _ucc_local="$(__updateman_local_version cursor)"
        if command -v get_current_version >/dev/null 2>&1; then
            case "$_ucc_local" in unknown|not_installed|n/a|'')
                _ucc_z="$(get_current_version cursor 2>/dev/null || true)"
                case "$_ucc_z" in not_installed|unknown|n/a|'') ;; *) _ucc_local="$_ucc_z" ;; esac
                ;;
            esac
        fi
        _ucc_upd="$(__updateman_version_update_label "$_ucc_local" "${TOOL_RELEASE_VERSION:-}" cursor)"
        printf "${CYAN}${BOLD}Cursor — verification release${RESET}\n\n"
        printf "  API:      %s\n" "${TOOL_RELEASE_API_URL:-?}"
        printf "  Locale:   %s\n" "$_ucc_local"
        printf "  Distante: %s\n" "${TOOL_RELEASE_VERSION:-?}"
        printf "  Maj?      %s\n" "$_ucc_upd"
        printf "  URL:      %s\n" "${TOOL_RELEASE_URL:-?}"
        if [ "$_ucc_upd" = "non" ]; then
            printf "\n${GREEN}A jour — aucune action requise.${RESET}\n"
            return 0
        fi
        if [ "$_ucc_local" = "not_installed" ]; then
            printf "\n${YELLOW}Cursor non detecte localement — lance: installman cursor${RESET}\n"
            return 1
        fi
        printf "\n${YELLOW}Mise a jour disponible ou version locale inconnue — lance: updateman cursor${RESET}\n"
        return 0
    }

    __updateman_tool_check() {
        _utc_tool="$1"
        _utc_kind="$(updatable_tool_update_kind "$_utc_tool" 2>/dev/null || printf '%s' unknown)"
        case "$_utc_kind" in
            cursor_appimage) __updateman_cursor_check ;;
            pkg)
                _utc_cur="$(__updateman_local_version "$_utc_tool")"
                _utc_rem="$(__updateman_remote_version "$_utc_tool")"
                _utc_upd="$(__updateman_version_update_label "$_utc_cur" "$_utc_rem" "$_utc_tool")"
                printf "${CYAN}${BOLD}%s — verification${RESET}\n\n" "$_utc_tool"
                printf "  Locale:    %s\n" "$_utc_cur"
                printf "  Depot:     %s\n" "$_utc_rem"
                printf "  Maj?       %s\n" "$_utc_upd"
                if [ "$_utc_cur" = "not_installed" ]; then
                    printf "\n${YELLOW}Non installe — lance: installman %s${RESET}\n" "$_utc_tool"
                    return 1
                fi
                if [ "$_utc_upd" = "oui" ]; then
                    printf "\n${YELLOW}Mise a jour depot disponible — lance: updateman %s${RESET}\n" "$_utc_tool"
                    return 0
                fi
                printf "\n${GREEN}A jour (depot) ou rien en attente.${RESET}\n"
                return 0
                ;;
            *)
                printf "${RED}check non implemente pour:${RESET} %s\n" "$_utc_tool" >&2
                return 1
                ;;
        esac
    }

    __updateman_run_cursor() {
        __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
        if ! command -v bash >/dev/null 2>&1; then
            printf "${RED}bash introuvable:${RESET} l'updater Cursor necessite Bash.\n" >&2
            return 1
        fi
        bash "$UPDATEMAN_SCRIPT"
        return $?
    }

    __updateman_run_tool() {
        _urt_tool="$1"
        _urt_kind="$(updatable_tool_update_kind "$_urt_tool" 2>/dev/null || printf '%s' unknown)"
        case "$_urt_kind" in
            cursor_appimage) __updateman_run_cursor ;;
            pkg)
                if command -v pkg_backend_upgrade_registered_tool >/dev/null 2>&1; then
                    pkg_backend_upgrade_registered_tool "$_urt_tool"
                else
                    printf "${RED}pkg_backend absent pour:${RESET} %s\n" "$_urt_tool" >&2
                    return 1
                fi
                ;;
            *)
                printf "${RED}outil non gere:${RESET} %s\n" "$_urt_tool" >&2
                return 1
                ;;
        esac
    }

    __updateman_update_all() {
        rc=0
        _ua_tools_only=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --tools-only|--registry-only) _ua_tools_only=1; shift ;;
                *) break ;;
            esac
        done
        if [ "$_ua_tools_only" -eq 0 ]; then
            if command -v pkg_backend_refresh_all >/dev/null 2>&1; then
                printf "${CYAN}${BOLD}==> updateman system refresh${RESET}\n"
                pkg_backend_refresh_all || rc=1
                printf "\n${CYAN}${BOLD}==> updateman system update${RESET}\n"
                pkg_backend_upgrade_all || rc=1
            else
                printf "${YELLOW}pkg_backend absent:${RESET} passe systeme ignore (outils registre seulement).\n"
            fi
        fi
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

    __updateman_tool_systemd_paths() {
        _tsp_tool="$1"
        _tsp_line="$(updatable_tool_find "$_tsp_tool" 2>/dev/null)"
        [ -n "$_tsp_line" ] || return 1
        _tsp_timer="$(updatable_tool_field "$_tsp_line" 3)"
        [ -n "$_tsp_timer" ] && [ "$_tsp_timer" != "-" ] || return 1
        _tsp_svc="${_tsp_timer%.timer}.service"
        _TSP_SERVICE_SRC="$DOTFILES_DIR/systemd/user/$_tsp_svc"
        _TSP_TIMER_SRC="$DOTFILES_DIR/systemd/user/$_tsp_timer"
        _TSP_SERVICE_DST="$UPDATEMAN_SYSTEMD_DIR/$_tsp_svc"
        _TSP_TIMER_DST="$UPDATEMAN_SYSTEMD_DIR/$_tsp_timer"
        _TSP_TIMER_UNIT="$_tsp_timer"
        return 0
    }

    __updateman_install_tool_systemd_files() {
        _its_tool="$1"
        if ! __updateman_tool_systemd_paths "$_its_tool"; then
            printf "${YELLOW}aucune unite systemd a installer pour:${RESET} %s\n" "$_its_tool"
            return 0
        fi
        if [ "$_its_tool" = "cursor" ]; then
            __updateman_need_file "$UPDATEMAN_SCRIPT" || return 1
        fi
        __updateman_need_file "$_TSP_SERVICE_SRC" || return 1
        __updateman_need_file "$_TSP_TIMER_SRC" || return 1

        mkdir -p "$UPDATEMAN_SYSTEMD_DIR" || return 1
        cp "$_TSP_SERVICE_SRC" "$_TSP_SERVICE_DST" || return 1
        cp "$_TSP_TIMER_SRC" "$_TSP_TIMER_DST" || return 1
        if [ "$_its_tool" = "cursor" ]; then
            rm -f "$UPDATEMAN_LEGACY_BIN" 2>/dev/null || true
        fi

        if command -v systemctl >/dev/null 2>&1; then
            systemctl --user daemon-reload 2>/dev/null || \
                printf "${YELLOW}Note:${RESET} daemon-reload user ignore (conteneur sans bus systemd user)\n" >&2
        fi

        printf "${GREEN}OK:${RESET} unites %s installees dans %s\n" "$_TSP_TIMER_UNIT" "$UPDATEMAN_SYSTEMD_DIR"
        if [ "$_its_tool" = "cursor" ]; then
            printf "${GREEN}OK:${RESET} pas de commande publique update-cursor-appimage (utiliser updateman cursor)\n"
        fi
    }

    __updateman_enable_tool_timer() {
        _ett_tool="$1"
        if ! __updateman_tool_systemd_paths "$_ett_tool"; then
            printf "${YELLOW}aucun timer configure pour:${RESET} %s\n" "$_ett_tool" >&2
            return 0
        fi
        __updateman_install_tool_systemd_files "$_ett_tool" || return 1
        if ! command -v systemctl >/dev/null 2>&1; then
            printf "${YELLOW}systemctl absent:${RESET} unites copiees dans %s — active sur l'hote avec:${RESET} updateman %s enable\n" \
                "$UPDATEMAN_SYSTEMD_DIR" "$_ett_tool" >&2
            return 1
        fi
        systemctl --user enable --now "$_TSP_TIMER_UNIT"
    }

    __updateman_install_cursor_files() {
        __updateman_install_tool_systemd_files cursor
    }

    __updateman_enable_cursor_timer() {
        __updateman_enable_tool_timer cursor
    }

    __updateman_install_tool_files() {
        __updateman_install_tool_systemd_files "$1"
    }

    __updateman_setup_tool_service() {
        __updateman_enable_tool_timer "$1"
    }

    __updateman_tool_timer_unit() {
        _ttu_line="$(updatable_tool_find "$1" 2>/dev/null)"
        [ -n "$_ttu_line" ] || return 1
        updatable_tool_field "$_ttu_line" 3
    }

    __updateman_tool_status() {
        _uts_tool="$1"
        shift
        _uts_verbose=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --verbose|-v) _uts_verbose=1 ;;
            esac
            shift
        done

        _uts_inst="$(__updateman_tool_installed_label "$_uts_tool")"
        _uts_vers="$(__updateman_tool_versions "$_uts_tool")"
        _uts_cur="${_uts_vers%%|*}"
        _uts_rest="${_uts_vers#*|}"
        _uts_rem="${_uts_rest%%|*}"
        _uts_upd="${_uts_rest#*|}"
        _uts_loc="$(__updateman_tool_location "$_uts_tool")"
        _uts_timer="$(__updateman_tool_timer_unit "$_uts_tool" 2>/dev/null || printf '%s' "-")"
        _uts_kind="$(updatable_tool_update_kind "$_uts_tool" 2>/dev/null || printf '%s' unknown)"

        printf "${CYAN}${BOLD}%s — statut complet${RESET}\n\n" "$_uts_tool"
        printf "  Installation : %s\n" "$_uts_inst"
        printf "  Version locale : %s\n" "$_uts_cur"
        printf "  Version distante : %s\n" "$_uts_rem"
        printf "  Mise a jour : %s\n" "$_uts_upd"
        printf "  Emplacement : %s\n" "$_uts_loc"
        printf "  Type maj : %s\n" "$_uts_kind"

        if [ "$_uts_timer" = "-" ] || [ -z "$_uts_timer" ]; then
            printf "  Timer auto : ${YELLOW}non configure${RESET} (pas de timer systemd pour cet outil)\n"
        elif command -v systemctl >/dev/null 2>&1; then
            _uts_active="$(systemctl --user is-active "$_uts_timer" 2>/dev/null)" || _uts_active="inactive"
            _uts_enabled="$(systemctl --user is-enabled "$_uts_timer" 2>/dev/null)" || _uts_enabled="disabled"
            printf "  Timer : %s\n" "$_uts_timer"
            printf "  Etat timer : %s (enabled: %s)\n" "$_uts_active" "$_uts_enabled"
            _uts_next="$(systemctl --user list-timers "$_uts_timer" --no-pager 2>/dev/null \
                | awk 'NR==2 {print $1, $2, $3, $4, $5}')"
            if [ -n "$_uts_next" ]; then
                printf "  Prochain declenchement : %s\n" "$_uts_next"
            fi
            _uts_svc="${_uts_timer%.timer}.service"
            if command -v journalctl >/dev/null 2>&1; then
                _uts_last="$(journalctl --user -u "$_uts_svc" -n 1 --no-pager -o short-iso 2>/dev/null \
                    | tail -n 1)"
                [ -n "$_uts_last" ] && printf "  Dernier service : %s\n" "$_uts_last"
            fi
        else
            printf "  Timer : %s\n" "$_uts_timer"
            if __updateman_tool_systemd_paths "$_uts_tool" 2>/dev/null && [ -f "$_TSP_TIMER_DST" ]; then
                printf "  Unites user : ${GREEN}installees${RESET} (systemctl absent — activer sur l'hote: updateman %s enable)\n" "$_uts_tool"
            else
                printf "  Unites user : ${YELLOW}non installees${RESET} — lance: updateman %s install\n" "$_uts_tool"
            fi
        fi

        printf "\n${BOLD}Actions :${RESET}\n"
        printf "  updateman %s           mise a jour maintenant\n" "$_uts_tool"
        printf "  updateman %s check     verification versions\n" "$_uts_tool"
        if [ "$_uts_timer" != "-" ] && [ -n "$_uts_timer" ]; then
            printf "  updateman %s install   copier les unites systemd user\n" "$_uts_tool"
            printf "  updateman %s enable    activer le timer auto\n" "$_uts_tool"
            printf "  updateman %s logs      journal systemd\n" "$_uts_tool"
        fi

        if [ "$_uts_upd" = "oui" ]; then
            printf "\n${YELLOW}Mise a jour disponible — lance: updateman %s${RESET}\n" "$_uts_tool"
        elif [ "$_uts_upd" = "non" ] && [ "$_uts_inst" = "present" ]; then
            printf "\n${GREEN}A jour.${RESET}\n"
        fi

        if [ "$_uts_verbose" -eq 1 ] && [ "$_uts_timer" != "-" ] && [ -n "$_uts_timer" ] \
           && command -v systemctl >/dev/null 2>&1; then
            printf "\n${CYAN}--- systemd ---${RESET}\n"
            systemctl --user status "$_uts_timer" --no-pager
        fi
    }

    __updateman_tool_timer_status() {
        __updateman_tool_status "$@"
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
        shift 2
        case "$_dt_sub" in
            help|-h|--help|aide)
                if [ "$_dt_tool" = "cursor" ]; then
                    __updateman_cursor_help
                else
                    printf "${CYAN}updateman %s${RESET} — outil du registre\n" "$_dt_tool"
                fi
                ;;
            run|update|now) __updateman_run_tool "$_dt_tool" ;;
            check|status-release|pending) __updateman_tool_check "$_dt_tool" ;;
            install|setup) __updateman_install_tool_files "$_dt_tool" ;;
            enable|timer|auto) __updateman_setup_tool_service "$_dt_tool" ;;
            status) __updateman_tool_status "$_dt_tool" "$@" ;;
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
            shift
            __updateman_update_all "$@"
            ;;
        system|os|packages)
            shift
            __updateman_system "$@"
            ;;
        arch|pacman|yay)
            shift
            __updateman_arch "$@"
            ;;
        cursor)
            shift
            _dt_sub="${1:-run}"
            shift
            __updateman_dispatch_tool cursor "$_dt_sub" "$@"
            ;;
        *)
            if updatable_tool_is_registered "$cmd" 2>/dev/null; then
                shift
                _dt_sub="${1:-run}"
                shift
                __updateman_dispatch_tool "$cmd" "$_dt_sub" "$@"
                return $?
            fi
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            __updateman_help
            return 1
            ;;
    esac
}
