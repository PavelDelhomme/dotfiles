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
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
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
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                   ALIAMAN - Alias Manager                      ║"
        echo "║                   Gestionnaire d'Alias                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo
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
        
        if [ -n "$search_pattern" ]; then
            grep -E "^alias [^=]+=" "$ALIASES_FILE" 2>/dev/null | grep -i "$search_pattern" || true
        else
            grep -E "^alias [^=]+=" "$ALIASES_FILE" 2>/dev/null || true
        fi
    }
    
    # Fonction pour afficher la liste des alias (version simplifiée POSIX)
    # DESC: Affiche la liste des alias avec recherche
    # USAGE: show_aliases_list
    show_aliases_list() {
        show_header
        printf "${YELLOW}📋 Liste des alias${RESET}\n"
        if [ -n "$SEARCH_TERM" ]; then
            printf "${BLUE}🔍 Recherche: '$SEARCH_TERM'${RESET}\n"
        fi
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
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
                alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
                alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                
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
        echo "  [q]    Retour au menu principal"
        echo
        printf "Votre choix: "
        read action
        
        case "$action" in
            s|S)
                printf "Entrez le terme de recherche: "
                read search_input
                SEARCH_TERM="$search_input"
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
            q|Q)
                return
                ;;
            *)
                show_aliases_list
                ;;
        esac
    }
    
    # Fonction pour ajouter un nouvel alias
    # DESC: Ajoute un nouvel alias de manière interactive
    # USAGE: add_new_alias
    add_new_alias() {
        show_header
        printf "${YELLOW}➕ Ajouter un nouvel alias${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Nom de l'alias: "
        read alias_name
        if [ -z "$alias_name" ]; then
            printf "${RED}❌ Nom d'alias requis${RESET}\n"
            sleep 2
            show_aliases_list
            return
        fi
        
        # Vérifier si l'alias existe déjà
        if grep -q "^alias $alias_name=" "$ALIASES_FILE" 2>/dev/null; then
            printf "${RED}❌ L'alias '$alias_name' existe déjà${RESET}\n"
            printf "Remplacer? [y/N]: "
            read overwrite
            case "$overwrite" in
                [yY])
                    sed -i "/^alias $alias_name=/d" "$ALIASES_FILE" 2>/dev/null || \
                    sed "/^alias $alias_name=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                    mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                    ;;
                *)
                    show_aliases_list
                    return
                    ;;
            esac
        fi
        
        printf "Commande de l'alias: "
        read alias_command
        if [ -z "$alias_command" ]; then
            printf "${RED}❌ Commande requise${RESET}\n"
            sleep 2
            show_aliases_list
            return
        fi
        
        printf "Description (optionnelle): "
        read description
        
        # Ajouter la description si fournie
        if [ -n "$description" ]; then
            echo "# DESC: $description" >> "$ALIASES_FILE"
        fi
        
        # Ajouter l'alias selon le shell
        if [ "$SHELL_TYPE" = "fish" ]; then
            echo "alias $alias_name='$alias_command'" >> "$ALIASES_FILE"
        else
            echo "alias $alias_name=\"$alias_command\"" >> "$ALIASES_FILE"
        fi
        
        # Activer l'alias dans la session courante si possible
        if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
            eval "alias $alias_name=\"$alias_command\"" 2>/dev/null || true
        fi
        
        printf "${GREEN}✅ Alias '$alias_name' ajouté avec succès${RESET}\n"
        sleep 2
        show_aliases_list
    }
    
    # Fonction pour éditer un alias de manière interactive
    # DESC: Modifie un alias de manière interactive
    # USAGE: edit_alias_interactive
    edit_alias_interactive() {
        show_header
        printf "${YELLOW}✏️ Édition d'alias${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Nom de l'alias à éditer: "
        read alias_to_edit
        if [ -z "$alias_to_edit" ]; then
            printf "${RED}❌ Nom d'alias requis${RESET}\n"
            sleep 2
            show_aliases_list
            return
        fi
        
        current_line=$(grep "^alias $alias_to_edit=" "$ALIASES_FILE" 2>/dev/null)
        if [ -z "$current_line" ]; then
            printf "${RED}❌ Alias '$alias_to_edit' non trouvé${RESET}\n"
            sleep 2
            show_aliases_list
            return
        fi
        
        current_command=$(echo "$current_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
        printf "Commande actuelle: $current_command\n"
        printf "Nouvelle commande: "
        read new_command
        
        if [ -n "$new_command" ]; then
            backup_aliases
            
            # Supprimer l'ancien alias
            sed -i "/^alias $alias_to_edit=/d" "$ALIASES_FILE" 2>/dev/null || \
            sed "/^alias $alias_to_edit=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
            mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
            
            # Ajouter le nouvel alias
            if [ "$SHELL_TYPE" = "fish" ]; then
                echo "alias $alias_to_edit='$new_command'" >> "$ALIASES_FILE"
            else
                echo "alias $alias_to_edit=\"$new_command\"" >> "$ALIASES_FILE"
            fi
            
            # Activer dans la session courante
            if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                eval "alias $alias_to_edit=\"$new_command\"" 2>/dev/null || true
            fi
            
            printf "${GREEN}✅ Alias '$alias_to_edit' modifié${RESET}\n"
        fi
        
        sleep 2
        show_aliases_list
    }
    
    # Fonction pour supprimer un alias de manière interactive
    # DESC: Supprime un alias avec confirmation
    # USAGE: delete_alias_interactive
    delete_alias_interactive() {
        show_header
        printf "${YELLOW}🗑️ Suppression d'alias${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "Nom de l'alias à supprimer: "
        read alias_to_remove
        if [ -z "$alias_to_remove" ]; then
            printf "${RED}❌ Nom d'alias requis${RESET}\n"
            sleep 2
            show_aliases_list
            return
        fi
        
        if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE" 2>/dev/null; then
            printf "Confirmer la suppression? [y/N]: "
            read confirm
            case "$confirm" in
                [yY])
                    backup_aliases
                    
                    # Supprimer l'alias du fichier
                    sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE" 2>/dev/null || \
                    sed "/^alias $alias_to_remove=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                    mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                    
                    # Désactiver l'alias dans la session courante si possible
                    if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                        unalias "$alias_to_remove" 2>/dev/null || true
                    fi
                    
                    printf "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}\n"
                    ;;
                *)
                    printf "${BLUE}ℹ️ Suppression annulée${RESET}\n"
                    ;;
            esac
        else
            printf "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}\n"
        fi
        
        sleep 2
        show_aliases_list
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
    
    # Fonction pour recherche rapide
    # DESC: Recherche rapide d'alias
    # USAGE: quick_search <term>
    quick_search() {
        search_term="$1"
        if [ -z "$search_term" ]; then
            printf "${RED}❌ Terme de recherche requis${RESET}\n"
            return 1
        fi
        
        printf "${CYAN}🔍 Recherche d'alias contenant '$search_term':${RESET}\n"
        results=$(parse_aliases "$search_term")
        
        if [ -z "$results" ]; then
            printf "${RED}❌ Aucun alias trouvé${RESET}\n"
            return 1
        fi
        
        echo "$results" | while IFS= read -r line; do
            alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
            alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
        done
    }
    
    # Fonction pour lister tous les alias
    # DESC: Liste tous les alias en format simple
    # USAGE: list_all_aliases
    list_all_aliases() {
        printf "${CYAN}📋 Liste complète des alias:${RESET}\n"
        parse_aliases | while IFS= read -r line; do
            alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
            alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
        done
    }
    
    # Fonction pour exporter les alias
    # DESC: Exporte les alias dans un fichier
    # USAGE: export_aliases
    export_aliases() {
        show_header
        printf "${YELLOW}💾 Export des alias${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        timestamp=$(date +%Y%m%d_%H%M%S)
        export_file="$HOME/aliases_export_$timestamp.sh"
        
        {
            echo "#!/bin/sh"
            echo "# Export des alias - $(date)"
            echo "# Généré par ALIAMAN - Alias Manager"
            echo
            cat "$ALIASES_FILE"
        } > "$export_file"
        
        printf "${GREEN}✅ Alias exportés vers: $export_file${RESET}\n"
        echo
        echo "Pour importer ces alias sur un autre système:"
        echo "  source $export_file"
        echo
        pause_if_tty
    }
    
    # Fonction pour les statistiques
    # DESC: Affiche des statistiques sur les alias
    # USAGE: show_statistics
    show_statistics() {
        show_header
        printf "${YELLOW}📊 Statistiques des alias${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        total_aliases=$(parse_aliases | wc -l | tr -d ' ')
        echo "Nombre total d'alias: $total_aliases"
        
        printf "\n${CYAN}Top 5 des commandes les plus aliasées:${RESET}\n"
        parse_aliases | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/' | \
        awk '{print $1}' | sort | uniq -c | sort -rn | head -5 | \
        awk '{printf "  %2d × %s\n", $1, $2}'
        
        printf "\n${CYAN}Répartition par type:${RESET}\n"
        git_count=$(parse_aliases | grep -c "git" || echo "0")
        docker_count=$(parse_aliases | grep -c "docker" || echo "0")
        cd_count=$(parse_aliases | grep -c "cd " || echo "0")
        sudo_count=$(parse_aliases | grep -c "sudo" || echo "0")
        
        echo "  Git: $git_count alias"
        echo "  Docker: $docker_count alias"
        echo "  Navigation (cd): $cd_count alias"
        echo "  Système (sudo): $sudo_count alias"
        
        echo
        pause_if_tty
    }
    
    # Variables globales pour la session
    SEARCH_TERM=""
    
    # Gestion des arguments rapides
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log aliaman "$@"
    fi
    case "$1" in
        search)
            if [ -n "$2" ]; then
                quick_search "$2"
            else
                printf "Terme à rechercher: "
                read term
                quick_search "$term"
            fi
            return 0
            ;;
        list)
            list_all_aliases
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
        remove)
            if [ -n "$2" ]; then
                alias_to_remove="$2"
                if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE" 2>/dev/null; then
                    sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE" 2>/dev/null || \
                    sed "/^alias $alias_to_remove=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                    mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                    printf "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}\n"
                else
                    printf "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}\n"
                fi
            else
                delete_alias_interactive
            fi
            return 0
            ;;
    esac
    
    # Menu principal
    while true; do
        show_header
        printf "${GREEN}Menu Principal${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
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
        echo "  ${BOLD}0${RESET}  📤 Exporter les alias"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
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
Exporter les alias|0
Aide|h
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "ALIAMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
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
                printf "Terme à rechercher: "
                read search_term
                quick_search "$search_term"
                echo
                pause_if_tty
                ;;
            4)
                list_all_aliases
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
            0) export_aliases ;;
            h|H)
                show_header
                printf "${CYAN}📚 Aide - ALIAMAN${RESET}\n"
                printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
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
            q|Q)
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
