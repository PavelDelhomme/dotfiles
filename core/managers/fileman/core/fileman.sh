#!/bin/sh
# =============================================================================
# FILEMAN - File Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des opérations sur fichiers et répertoires
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif complet pour les opérations sur fichiers
# USAGE: fileman [category]
# EXAMPLE: fileman
# EXAMPLE: fileman archive
# EXAMPLE: fileman backup

_dotfiles_mgr_df="${DOTFILES_DIR:-${HOME:-}/dotfiles}"
if [ -f "$_dotfiles_mgr_df/scripts/lib/manager_cli_help_posix.sh" ]; then
    # shellcheck source=/dev/null
    . "$_dotfiles_mgr_df/scripts/lib/manager_cli_help_posix.sh"
fi

fileman_print_usage() {
    dotfiles_mgr_safe_out "FILEMAN — gestion fichiers, archives, recherche, permissions"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Interface :"
    dotfiles_mgr_safe_out "  fileman                           cette aide détaillée"
    dotfiles_mgr_safe_out "  fileman help | -h | aide          idem"
    dotfiles_mgr_safe_out "  fileman --help                    idem (documentation, pas de menu)"
    dotfiles_mgr_safe_out "  fileman help --interactive        aide + pause (TTY)"
    dotfiles_mgr_safe_out "  fileman menu                      menu interactif (TTY)"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Modules (menu interactif si sans sous-commande) :"
    dotfiles_mgr_safe_out "  fileman archive    fileman arch       archives (créer / extraire / lister)"
    dotfiles_mgr_safe_out "  fileman backup     fileman back       sauvegardes"
    dotfiles_mgr_safe_out "  fileman search     fileman find       recherche de fichiers"
    dotfiles_mgr_safe_out "  fileman permissions fileman perms     chmod / audit permissions"
    dotfiles_mgr_safe_out "  fileman files      fileman ops        copier / déplacer / supprimer"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Sous-commandes archive :"
    dotfiles_mgr_safe_out "  fileman archive extract ARCHIVE [DEST]     extraire"
    dotfiles_mgr_safe_out "  fileman archive create SRC [ARCHIVE]       créer tar.gz / zip"
    dotfiles_mgr_safe_out "  fileman archive list ARCHIVE                 lister le contenu"
    dotfiles_mgr_safe_out "  fileman archive verify ARCHIVE               vérifier intégrité"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Sous-commandes search :"
    dotfiles_mgr_safe_out "  fileman search name PATTERN [DIR]          find par nom"
    dotfiles_mgr_safe_out "  fileman search content TEXTE [DIR]         grep récursif"
    dotfiles_mgr_safe_out "  fileman search size TAILLE [DIR]           find par taille (+10M, 1G…)"
    dotfiles_mgr_safe_out "  fileman search mtime JOURS [DIR]           modifiés depuis N jours"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Sous-commandes backup :"
    dotfiles_mgr_safe_out "  fileman backup create SRC [DEST]           sauvegarder"
    dotfiles_mgr_safe_out "  fileman backup list [DIR]                  lister sauvegardes"
    dotfiles_mgr_safe_out "  fileman backup restore BACKUP DEST         restaurer"
    dotfiles_mgr_safe_out "  fileman backup remove BACKUP                 supprimer"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Sous-commandes files :"
    dotfiles_mgr_safe_out "  fileman files copy SRC DEST | move | remove | rename | mkdir | info"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Sous-commandes permissions :"
    dotfiles_mgr_safe_out "  fileman permissions show PATH              afficher"
    dotfiles_mgr_safe_out "  fileman permissions set MODE PATH          chmod"
    dotfiles_mgr_safe_out "  fileman permissions find MODE [DIR]        trouver par mode"
    dotfiles_mgr_safe_out ""
    dotfiles_mgr_safe_out "Exemples :"
    dotfiles_mgr_safe_out "  fileman search name '*.log' ~"
    dotfiles_mgr_safe_out "  fileman archive extract game.zip /data/jeux"
    dotfiles_mgr_safe_out "  fileman files copy ~/doc.pdf /data/"
}

fileman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    FILEMAN_DIR="$DOTFILES_DIR/zsh/functions/fileman"
    FILEMAN_MODULES_DIR="$FILEMAN_DIR/modules"
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
            read -r dummy || true
        fi
    }

    # Fonction pour afficher le header
    show_header() {
        if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput cols 2>/dev/null || echo 80)" -ge 40 ]; then
            clear 2>/dev/null || true
        fi
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "FILEMAN - FILE MANAGER" 2>/dev/null || dotfiles_mgr_safe_out "FILEMAN - FILE MANAGER"
        else
            dotfiles_mgr_safe_out "FILEMAN - FILE MANAGER"
        fi
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}GESTION DES FICHIERS${RESET}\n"
        if command -v manager_ui_section_line >/dev/null 2>&1; then
            manager_ui_section_line "${BLUE}" "${RESET}\n\n" 2>/dev/null || printf '\n'
        else
            printf '\n'
        fi

        dotfiles_mgr_safe_out "1.  Archive (creer/extraire)"
        dotfiles_mgr_safe_out "2.  Backup (creer/sauvegarder)"
        dotfiles_mgr_safe_out "3.  Recherche (trouver fichiers)"
        dotfiles_mgr_safe_out "4.  Permissions"
        dotfiles_mgr_safe_out "5.  Operations fichiers"
        dotfiles_mgr_safe_out ""
        dotfiles_mgr_safe_out "0.  Quitter"
        dotfiles_mgr_safe_out ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Archive (creer/extraires archives)|1
Backup (creer/sauvegarder)|2
Recherche (trouver fichiers)|3
Permissions (gerer permissions)|4
Operations fichiers (copier/deplacer/supprimer)|5
Quitter|0
EOF
            choice=$(dotfiles_ncmenu_select "FILEMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix: "
            read choice
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        fi
        
        case "$choice" in
            1)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/archive/archive_manager.sh"
                else
                    printf "${RED}❌ Module Archive non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/backup/backup_manager.sh"
                else
                    printf "${RED}❌ Module Backup non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/search/search_manager.sh"
                else
                    printf "${RED}❌ Module Recherche non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh"
                else
                    printf "${RED}❌ Module Permissions non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            5)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/files/files_manager.sh"
                else
                    printf "${RED}❌ Module Fichiers non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            0|q|Q|quit|exit)
                printf "${GREEN}Au revoir!${RESET}\n"
                return 1
                ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
        
        # Retour au menu : pause puis boucle externe
        case "$choice" in
            0) ;;
            *)
                echo ""
                pause_if_tty
                ;;
        esac
        return 0
    }
    
    if [ -z "${1-}" ]; then
        fileman_print_usage
        return 0
    fi
    if [ "$1" = help ] || [ "$1" = "-h" ] || [ "$1" = aide ]; then
        case "${2:-}" in
        --interactive|-i)
            fileman_print_usage
            pause_if_tty
            return 0
            ;;
        *)
            fileman_print_usage
            return 0
            ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        fileman_print_usage
        return 0
    fi
    if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then
        if ! { [ -t 0 ] && [ -t 1 ]; }; then
            printf '%s\n' "fileman: menu nécessite un terminal (TTY)." >&2
            return 2
        fi
        while true; do
            show_main_menu || break
        done
        return 0
    fi

    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log fileman "$@"
        _fm_mod="$1"
        shift
        case "$_fm_mod" in
            archive|arch)
                if [ -f "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/archive/archive_manager.sh" "$@"
                else
                    printf "${RED}Module Archive non disponible${RESET}\n" >&2
                    return 1
                fi
                ;;
            backup|back)
                if [ -f "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/backup/backup_manager.sh" "$@"
                else
                    printf "${RED}Module Backup non disponible${RESET}\n" >&2
                    return 1
                fi
                ;;
            search|find|recherche)
                if [ -f "$FILEMAN_MODULES_DIR/search/search_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/search/search_manager.sh" "$@"
                else
                    printf "${RED}Module Recherche non disponible${RESET}\n" >&2
                    return 1
                fi
                ;;
            permissions|perms|chmod)
                if [ -f "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/permissions/permissions_manager.sh" "$@"
                else
                    printf "${RED}Module Permissions non disponible${RESET}\n" >&2
                    return 1
                fi
                ;;
            files|file|ops)
                if [ -f "$FILEMAN_MODULES_DIR/files/files_manager.sh" ]; then
                    sh "$FILEMAN_MODULES_DIR/files/files_manager.sh" "$@"
                else
                    printf "${RED}Module Fichiers non disponible${RESET}\n" >&2
                    return 1
                fi
                ;;
            *)
                printf "${RED}Module inconnu: %s${RESET}\n" "$_fm_mod" >&2
                fileman_print_usage >&2
                return 1
                ;;
        esac
    fi
}
