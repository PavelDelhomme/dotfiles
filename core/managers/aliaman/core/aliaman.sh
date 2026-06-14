#!/bin/sh
# =============================================================================
# ALIAMAN - Alias Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet et interactif des alias
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

# DESC: Gestionnaire interactif complet pour gérer les alias
# USAGE: aliaman [command]
# EXAMPLE: aliaman
# EXAMPLE: aliaman add
# EXAMPLE: aliaman search git
aliaman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Fichier des alias (adaptatif selon shell)
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        dotfiles_manager_load_ui_libs
    elif [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    if [ "$SHELL_TYPE" = "zsh" ]; then
        ALIASES_FILE="$DOTFILES_DIR/zsh/aliases.zsh"
    elif [ "$SHELL_TYPE" = "bash" ]; then
        ALIASES_FILE="$DOTFILES_DIR/bash/aliases.sh"
    elif [ "$SHELL_TYPE" = "fish" ]; then
        ALIASES_FILE="$DOTFILES_DIR/fish/aliases.fish"
    else
        ALIASES_FILE="$DOTFILES_DIR/zsh/aliases.zsh"
    fi
    
    BACKUP_DIR="$DOTFILES_DIR/zsh/backups"
    
    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }
    _aliaman_tui_mod="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/aliaman/modules/tui.sh"
    if [ -f "$_aliaman_tui_mod" ]; then
        # shellcheck source=/dev/null
        . "$_aliaman_tui_mod"
    else
        aliaman_dotcli_menu_pick() { return 1; }
    fi
    
    # Fonction pour créer le fichier d'alias s'il n'existe pas
    ensure_aliases_file() {
        if [ ! -f "$ALIASES_FILE" ]; then
            mkdir -p "$(dirname "$ALIASES_FILE")"
            touch "$ALIASES_FILE"
            echo "# Fichier des alias - Géré par ALIAMAN" > "$ALIASES_FILE"
            echo "" >> "$ALIASES_FILE"
        fi
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        if command -v manager_ui_print_banner >/dev/null 2>&1; then
            manager_ui_print_banner "ALIAMAN - Alias Manager" "Gestionnaire d'Alias"
        else
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                   ALIAMAN - Alias Manager                      ║"
            echo "║                   Gestionnaire d'Alias                        ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
        fi
        printf "${RESET}"
        echo
    }

    # Aide CLI (stdout, pas de clear ni menu)
    aliaman_print_usage() {
        cat <<'EOF'
Usage :
  aliaman                        cette aide sur stdout (non interactif)
  aliaman help | -h | aide       idem
  aliaman help --interactive     aide détaillée + pause (TTY requis)
  aliaman --help                 menu interactif (terminal requis)

Commandes directes :
  aliaman search|find|s [terme]  rechercher un alias (fzf si dispo, sinon prompt)
  aliaman list|ls                lister les alias (fzf si dispo)
  aliaman add <nom> <cmd>        ajouter un alias
  aliaman remove|rm <nom>        supprimer un alias
EOF
    }

    # Aide détaillée CLI (sans clear) + pause en TTY — aligné help --interactive
    aliaman_print_interactive_help_cli() {
        printf "${CYAN}📚 Aide — ALIAMAN${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo
        echo "ALIAMAN est un gestionnaire complet d'alias."
        echo
        echo "Fonctionnalités principales:"
        echo "  • Gestion interactive des alias"
        echo "  • Recherche et filtrage"
        echo "  • Sauvegarde automatique avant modifications"
        echo "  • Test et validation des alias"
        echo "  • Statistiques détaillées"
        echo "  • Export/Import facile"
        echo
        echo "Raccourcis directs:"
        echo "  aliaman                    - Aide sur stdout (sans menu)"
        echo "  aliaman --help             - Menu interactif"
        echo "  aliaman search <terme>     - Recherche rapide"
        echo "  aliaman list               - Liste tous les alias"
        echo "  aliaman add <nom> <cmd>    - Ajoute un alias"
        echo "  aliaman remove <nom>       - Supprime un alias"
        echo
        pause_if_tty
    }
    
    # Fonction pour sauvegarder les alias
    backup_aliases() {
        ensure_aliases_file
        mkdir -p "$BACKUP_DIR"
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_file="$BACKUP_DIR/aliases_backup_$timestamp.sh"
        cp "$ALIASES_FILE" "$backup_file"
        printf "${GREEN}✅ Sauvegarde créée : $backup_file${RESET}\n"
    }
    
    # Fonction pour parser les alias du fichier
    # DESC: Parse et retourne les alias depuis le fichier de configuration
    # USAGE: parse_aliases [search_pattern]
    parse_aliases() {
        ensure_aliases_file
        search_pattern="${1:-}"

        # Source = fichier d'alias + aliases déjà chargés dans le shell courant.
        # On normalise ensuite sur des lignes "alias nom=commande".
        alias_rows=$(
            {
                grep -E "^alias [^=]+=" "$ALIASES_FILE" 2>/dev/null || true
                alias 2>/dev/null || true
            } | grep -E "^alias [^=]+=" | awk '!seen[$0]++'
        )

        if [ -n "$search_pattern" ]; then
            printf '%s\n' "$alias_rows" | grep -F -i -- "$search_pattern" || true
        else
            printf '%s\n' "$alias_rows" || true
        fi
    }

    # Sélection interactive d'un alias via fzf (si disponible)
    pick_alias_with_fzf() {
        _query="${1:-}"
        _rows=$(parse_aliases "$_query" | while IFS= read -r _line; do
            _name=$(echo "$_line" | sed 's/^alias \([^=]*\)=.*/\1/')
            _cmd=$(echo "$_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            printf "%s\t%s\n" "$_name" "$_cmd"
        done)
        [ -z "$_rows" ] && return 1
        _selected=$(printf '%s\n' "$_rows" | \
            fzf --height=80% --layout=reverse --border --ansi \
                --delimiter='\t' --with-nth=1,2 \
                --prompt='Alias > ' --query "$_query" 2>/dev/null || true)
        [ -z "$_selected" ] && return 1
        printf '%s' "$(printf '%s' "$_selected" | cut -f1)"
    }

    _aliaman_crud_mod="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/aliaman/modules/alias_crud.sh"
    if [ -f "$_aliaman_crud_mod" ]; then
        # shellcheck source=/dev/null
        . "$_aliaman_crud_mod"
    fi
    
    # Fonction pour afficher la liste des alias (version simplifiée POSIX)
    # DESC: Affiche la liste des alias avec recherche
    # USAGE: show_aliases_list
    show_aliases_list() {
        show_header
        printf "${YELLOW}📋 Liste des alias${RESET}\n"
        if [ -n "$SEARCH_TERM" ]; then
            printf "${BLUE}🔍 Recherche: '$SEARCH_TERM'${RESET}\n"
        fi
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        
        all_aliases=""
        if [ -n "$SEARCH_TERM" ]; then
            all_aliases=$(parse_aliases "$SEARCH_TERM")
        else
            all_aliases=$(parse_aliases)
        fi
        
        if [ -z "$all_aliases" ]; then
            if [ -n "$SEARCH_TERM" ]; then
                printf "${RED}❌ Aucun alias trouvé pour '$SEARCH_TERM'${RESET}\n"
            else
                printf "${RED}❌ Aucun alias trouvé${RESET}\n"
            fi
            echo
            pause_if_tty
            return
        fi
        
        printf "${CYAN}%-5s %-20s %-50s${RESET}\n" "N°" "ALIAS" "COMMANDE"
        echo "────────────────────────────────────────────────────────────────────────────────"
        
        i=1
        echo "$all_aliases" | while IFS= read -r line; do
            if [ -n "$line" ]; then
                alias_name=$(echo "$line" | sed -E "s/^alias[[:space:]]+([^=]+)=.*/\\1/")
                alias_command=$(echo "$line" | sed -E "s/^alias[[:space:]]+[^=]+=//")
                alias_command=${alias_command#\"}
                alias_command=${alias_command#\'}
                alias_command=${alias_command%\"}
                alias_command=${alias_command%\'}
                
                # Tronquer la commande si trop longue
                if [ ${#alias_command} -gt 45 ]; then
                    alias_command=$(echo "$alias_command" | cut -c1-42)
                    alias_command="$alias_command..."
                fi
                
                printf "%-5d %-20.20s %-50.50s\n" "$i" "$alias_name" "$alias_command"
                i=$((i + 1))
            fi
        done
        
        echo
        printf "${YELLOW}────────────────────────────────────────────────────────────────────${RESET}\n"
        printf "${GREEN}Actions:${RESET}\n"
        echo "  [s]    Rechercher       [c] Effacer recherche"
        echo "  [+]    Ajouter un nouvel alias"
        echo "  [e]    Éditer un alias  [d] Supprimer un alias"
        echo "  [b]    Sauvegarder      [r] Recharger"
        echo "  [0]    Retour au menu principal"
        echo "  [q]    Retour au menu principal"
        echo
        if [ -t 0 ] && [ -t 1 ] && [ "${DOTFILES_DOTCLI_ENABLE:-0}" = "1" ]; then
            _actions_file=$(mktemp)
            cat > "$_actions_file" <<'EOF'
Rechercher|s
Effacer la recherche|c
Ajouter un alias|+
Editer un alias|e
Supprimer un alias|d
Sauvegarder les alias|b
Recharger les alias|r
Retour menu principal|0
Retour menu principal|q
EOF
            action=$(aliaman_dotcli_menu_pick "Aliaman actions" "$_actions_file" || true)
            rm -f "$_actions_file"
        fi
        if [ -z "$action" ] && [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
            action=$(printf '%s\n' \
                "Rechercher|s" \
                "Effacer la recherche|c" \
                "Ajouter un alias|+" \
                "Editer un alias|e" \
                "Supprimer un alias|d" \
                "Sauvegarder les alias|b" \
                "Recharger les alias|r" \
                "Retour menu principal|0" \
                "Retour menu principal|q" | \
                fzf --height=60% --layout=reverse --border --ansi \
                    --prompt="Aliaman actions > " 2>/dev/null | cut -d'|' -f2)
        else
            if [ -z "$action" ]; then
                printf "Votre choix: "
                read action
            fi
        fi
        
        case "$action" in
            s|S)
                printf "Entrez le terme de recherche: "
                read search_input
                SEARCH_TERM="$search_input"
                if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                    selected_alias=$(pick_alias_with_fzf "$search_input" || true)
                    if [ -n "$selected_alias" ]; then
                        SEARCH_TERM="$selected_alias"
                    fi
                fi
                show_aliases_list
                ;;
            c|C)
                SEARCH_TERM=""
                show_aliases_list
                ;;
            +)
                add_new_alias
                ;;
            e|E)
                edit_alias_interactive
                ;;
            d|D)
                delete_alias_interactive
                ;;
            b|B)
                backup_aliases
                sleep 2
                show_aliases_list
                ;;
            r|R)
                reload_aliases
                sleep 2
                show_aliases_list
                ;;
            0|q|Q|quit|exit)
                return
                ;;
            *)
                show_aliases_list
                ;;
        esac
    }
    
    # Fonction pour recharger les alias
    # DESC: Recharge les alias depuis le fichier de configuration
    # USAGE: reload_aliases
    reload_aliases() {
        ensure_aliases_file
        if [ -f "$ALIASES_FILE" ]; then
            if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                . "$ALIASES_FILE" 2>/dev/null || true
            fi
            printf "${GREEN}✅ Alias rechargés depuis $ALIASES_FILE${RESET}\n"
        else
            printf "${RED}❌ Fichier d'alias introuvable${RESET}\n"
        fi
    }
    
    _aliaman_alias_ops_mod="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers/aliaman/modules/aliases_ops.sh"
    if [ -f "$_aliaman_alias_ops_mod" ]; then
        # shellcheck source=/dev/null
        . "$_aliaman_alias_ops_mod"
    fi
    
    # Variables globales pour la session
    SEARCH_TERM=""

    # Dispatch CLI — séparation stricte : vide / help / --help / sous-commandes / erreur
    if [ -z "$1" ]; then
        aliaman_print_usage
        return 0
    fi

    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log aliaman "$@"

    case "$1" in
        help|-h|aide)
            case "${2:-}" in
            --interactive|-i)
                if [ -t 0 ] && [ -t 1 ]; then
                    aliaman_print_interactive_help_cli
                else
                    printf '%s\n' "aliaman: help --interactive nécessite un TTY." >&2
                    aliaman_print_usage
                fi
                ;;
            *)
                aliaman_print_usage
                ;;
            esac
            return 0
            ;;
        search|find|s)
            term="${2:-}"
            if [ -n "$term" ]; then
                quick_search "$term"
                return $?
            fi
            if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                list_aliases_fzf
                return $?
            fi
            if [ -t 0 ] && [ -t 1 ]; then
                printf "Terme à rechercher: "
                read term
                if [ -n "$term" ]; then
                    quick_search "$term"
                    return $?
                fi
            fi
            list_all_aliases
            return 0
            ;;
        list|ls)
            if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                list_aliases_fzf
            else
                list_all_aliases
            fi
            return 0
            ;;
        add)
            if [ -n "$2" ] && [ -n "$3" ]; then
                alias_name="$2"
                alias_command="$3"
                ensure_aliases_file
                if [ "$SHELL_TYPE" = "fish" ]; then
                    echo "alias $alias_name='$alias_command'" >> "$ALIASES_FILE"
                else
                    echo "alias $alias_name=\"$alias_command\"" >> "$ALIASES_FILE"
                fi
                printf "${GREEN}✅ Alias '$alias_name' ajouté${RESET}\n"
            else
                add_new_alias
            fi
            return 0
            ;;
        remove|rm|delete|del)
            if [ -n "$2" ]; then
                alias_to_remove="$2"
                if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE" 2>/dev/null; then
                    sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE" 2>/dev/null || \
                    sed "/^alias $alias_to_remove=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                    mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                    printf "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}\n"
                else
                    printf "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}\n" >&2
                    return 1
                fi
            else
                delete_alias_interactive
            fi
            return 0
            ;;
        --help)
            aliaman_print_usage
            return 0
            ;;
        menu|--interactive)
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                printf '%s\n' "aliaman: menu nécessite un terminal (TTY)." >&2
                return 2
            fi
            ;;
        *)
            printf '%s\n' "aliaman: commande inconnue : $1" >&2
            printf '%s\n' "aliaman help — aide sur stdout." >&2
            return 1
            ;;
    esac

    while true; do
        show_header
        printf "${GREEN}Menu Principal${RESET}\n"
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        echo
        echo "  ${BOLD}1${RESET}  📋 Gérer les alias (interactif)"
        echo "  ${BOLD}2${RESET}  ➕ Ajouter un nouvel alias"
        echo "  ${BOLD}3${RESET}  🔍 Rechercher un alias"
        echo "  ${BOLD}4${RESET}  📜 Lister tous les alias"
        echo "  ${BOLD}5${RESET}  🗑️  Supprimer un alias spécifique"
        echo "  ${BOLD}6${RESET}  ✏️ Éditer un alias spécifique"
        echo "  ${BOLD}7${RESET}  💾 Sauvegarder les alias"
        echo "  ${BOLD}8${RESET}  🔄 Recharger les alias"
        echo "  ${BOLD}9${RESET}  📊 Statistiques"
        echo "  ${BOLD}x${RESET}  📤 Exporter les alias"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}0${RESET}  🚪 Quitter"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        manager_ui_section_line "${BLUE}" "${RESET}\n"
        choice=""
        if [ -t 0 ] && [ -t 1 ]; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Gerer les alias (interactif)|1
Ajouter un nouvel alias|2
Rechercher un alias|3
Lister tous les alias|4
Supprimer un alias specifique|5
Editer un alias specifique|6
Sauvegarder les alias|7
Recharger les alias|8
Statistiques|9
Exporter les alias|x
Aide|h
Quitter|0
Quitter|q
EOF
            choice=$(aliaman_dotcli_menu_pick "ALIAMAN - Menu principal" "$menu_input_file" || true)
            if [ -z "$choice" ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
                choice=$(dotfiles_ncmenu_select "ALIAMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            fi
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Votre choix: "
            read choice
        fi
        
        case "$choice" in
            1)
                SEARCH_TERM=""
                show_aliases_list
                ;;
            2) add_new_alias ;;
            3)
                if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                    list_aliases_fzf
                else
                    printf "Terme à rechercher: "
                    read search_term
                    quick_search "$search_term"
                fi
                echo
                pause_if_tty
                ;;
            4)
                if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
                    list_aliases_fzf
                else
                    list_all_aliases
                fi
                echo
                pause_if_tty
                ;;
            5)
                printf "Nom de l'alias à supprimer: "
                read alias_to_remove
                if [ -n "$alias_to_remove" ]; then
                    if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE" 2>/dev/null; then
                        printf "Supprimer l'alias '$alias_to_remove'? [y/N]: "
                        read confirm
                        case "$confirm" in
                            [yY])
                                backup_aliases
                                sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE" 2>/dev/null || \
                                sed "/^alias $alias_to_remove=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                                mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                                if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                                    unalias "$alias_to_remove" 2>/dev/null || true
                                fi
                                printf "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}\n"
                                ;;
                        esac
                    else
                        printf "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}\n"
                    fi
                fi
                sleep 2
                ;;
            6)
                printf "Nom de l'alias à éditer: "
                read alias_to_edit
                if [ -n "$alias_to_edit" ]; then
                    current_command=$(grep "^alias $alias_to_edit=" "$ALIASES_FILE" 2>/dev/null | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                    if [ -n "$current_command" ]; then
                        printf "Commande actuelle: $current_command\n"
                        printf "Nouvelle commande: "
                        read new_command
                        if [ -n "$new_command" ]; then
                            backup_aliases
                            sed -i "/^alias $alias_to_edit=/d" "$ALIASES_FILE" 2>/dev/null || \
                            sed "/^alias $alias_to_edit=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                            mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                            if [ "$SHELL_TYPE" = "fish" ]; then
                                echo "alias $alias_to_edit='$new_command'" >> "$ALIASES_FILE"
                            else
                                echo "alias $alias_to_edit=\"$new_command\"" >> "$ALIASES_FILE"
                            fi
                            if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                                eval "alias $alias_to_edit=\"$new_command\"" 2>/dev/null || true
                            fi
                            printf "${GREEN}✅ Alias '$alias_to_edit' modifié${RESET}\n"
                        fi
                    else
                        printf "${RED}❌ Alias '$alias_to_edit' non trouvé${RESET}\n"
                    fi
                fi
                sleep 2
                ;;
            7)
                backup_aliases
                sleep 2
                ;;
            8)
                reload_aliases
                sleep 2
                ;;
            9) show_statistics ;;
            x|X) export_aliases ;;
            h|H)
                show_header
                printf "${CYAN}📚 Aide - ALIAMAN${RESET}\n"
                manager_ui_section_line "${BLUE}" "${RESET}\n"
                echo
                echo "ALIAMAN est un gestionnaire complet d'alias."
                echo
                echo "Fonctionnalités principales:"
                echo "  • Gestion interactive des alias"
                echo "  • Recherche et filtrage"
                echo "  • Sauvegarde automatique avant modifications"
                echo "  • Test et validation des alias"
                echo "  • Statistiques détaillées"
                echo "  • Export/Import facile"
                echo
                echo "Raccourcis directs:"
                echo "  aliaman                    - Lance le gestionnaire"
                echo "  aliaman search <terme>     - Recherche rapide"
                echo "  aliaman list               - Liste tous les alias"
                echo "  aliaman add <nom> <cmd>    - Ajoute un alias"
                echo "  aliaman remove <nom>      - Supprime un alias"
                echo
                pause_if_tty
                ;;
            0|q|Q|quit|exit)
                printf "${GREEN}Au revoir!${RESET}\n"
                break
                ;;
            *)
                printf "${RED}Option invalide${RESET}\n"
                sleep 1
                ;;
        esac
    done
}
