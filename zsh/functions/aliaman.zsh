#!/bin/zsh
# =============================================================================
# ALIAMAN - Alias Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet et interactif des alias ZSH
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

aliaman() {
    # Configuration des couleurs
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fichier des alias
    local ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"
    local BACKUP_DIR="$HOME/dotfiles/zsh/backups"
    
    # Variables globales
    local SELECTED_ALIASES=""
    local SEARCH_TERM=""
    local CURRENT_PAGE=1
    local ALIASES_PER_PAGE=15
    
    # Fonction pour créer le fichier d'alias s'il n'existe pas
    ensure_aliases_file() {
        if [[ ! -f "$ALIASES_FILE" ]]; then
            mkdir -p "$(dirname "$ALIASES_FILE")"
            touch "$ALIASES_FILE"
            echo "# ~/dotfiles/zsh/aliases.zsh - Fichier des alias ZSH" > "$ALIASES_FILE"
            echo "# Géré par ALIAMAN - Alias Manager" >> "$ALIASES_FILE"
            echo >> "$ALIASES_FILE"
        fi
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                   ALIAMAN - Alias Manager                      ║"
        echo "║                   Gestionnaire d'Alias ZSH                     ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo
    }
    
    # Fonction pour sauvegarder les alias
    backup_aliases() {
        ensure_aliases_file
        mkdir -p "$BACKUP_DIR"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$BACKUP_DIR/aliases_backup_$timestamp.zsh"
        cp "$ALIASES_FILE" "$backup_file"
        echo "✅ Sauvegarde créée : $backup_file"
    }
    
    # Fonction pour parser les alias du fichier
    parse_aliases() {
        ensure_aliases_file
        local search_pattern="${1:-}"
        
        if [[ -n "$search_pattern" ]]; then
            grep -E "^alias [^=]+=" "$ALIASES_FILE" | grep -i "$search_pattern"
        else
            grep -E "^alias [^=]+=" "$ALIASES_FILE"
        fi
    }
    
    # Fonction pour afficher la liste des alias avec pagination
    show_aliases_list() {
        show_header
        echo -e "${YELLOW}📋 Liste des alias${RESET}"
        if [[ -n "$SEARCH_TERM" ]]; then
            echo -e "${BLUE}🔍 Recherche: '$SEARCH_TERM'${RESET}"
        fi
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        local all_aliases
        if [[ -n "$SEARCH_TERM" ]]; then
            all_aliases=$(parse_aliases "$SEARCH_TERM")
        else
            all_aliases=$(parse_aliases)
        fi
        
        if [[ -z "$all_aliases" ]]; then
            if [[ -n "$SEARCH_TERM" ]]; then
                echo -e "${RED}❌ Aucun alias trouvé pour '$SEARCH_TERM'${RESET}"
            else
                echo -e "${RED}❌ Aucun alias trouvé${RESET}"
            fi
            echo
            read -k 1 "?Appuyez sur une touche pour continuer..."
            return
        fi
        
        local total_aliases=$(echo "$all_aliases" | wc -l)
        local total_pages=$(( (total_aliases + ALIASES_PER_PAGE - 1) / ALIASES_PER_PAGE ))
        
        # Calcul des alias à afficher pour cette page
        local start_line=$(( (CURRENT_PAGE - 1) * ALIASES_PER_PAGE + 1 ))
        local end_line=$(( CURRENT_PAGE * ALIASES_PER_PAGE ))
        
        local page_aliases=$(echo "$all_aliases" | sed -n "${start_line},${end_line}p")
        
        echo -e "${CYAN}Page $CURRENT_PAGE/$total_pages (Alias $start_line-$(echo "$page_aliases" | wc -l | xargs expr $start_line - 1 +) sur $total_aliases)${RESET}"
        echo
        
        printf "${CYAN}%-5s %-20s %-40s %s${RESET}\n" "N°" "ALIAS" "COMMANDE" "STATUS"
        echo "────────────────────────────────────────────────────────────────────────────────"
        
        local alias_array=()
        local i=1
        
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                alias_array+=("$line")
                local alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
                local alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                
                # Tronquer la commande si trop longue
                if [[ ${#alias_command} -gt 35 ]]; then
                    alias_command="${alias_command:0:32}..."
                fi
                
                # Vérifier si l'alias est sélectionné
                local status="[ ]"
                if [[ " $SELECTED_ALIASES " =~ " $i " ]]; then
                    status="${GREEN}[✓]${RESET}"
                fi
                
                printf "%-5d %-20.20s %-40.40s %s\n" "$i" "$alias_name" "$alias_command" "$status"
                ((i++))
            fi
        done <<< "$page_aliases"
        
        echo
        echo -e "${YELLOW}────────────────────────────────────────────────────────────────────${RESET}"
        echo -e "${GREEN}Navigation:${RESET}"
        echo "  [1-9]  Sélectionner/Désélectionner un alias"
        echo "  [n]    Page suivante    [p] Page précédente"
        echo "  [s]    Rechercher       [c] Effacer recherche"
        echo "  [a]    Tout sélectionner [x] Tout désélectionner"
        echo
        echo -e "${GREEN}Actions:${RESET}"
        echo "  [e]    Éditer les alias sélectionnés"
        echo "  [d]    Supprimer les alias sélectionnés"
        echo "  [i]    Informations détaillées"
        echo "  [t]    Tester l'alias"
        echo "  [+]    Ajouter un nouvel alias"
        echo "  [b]    Sauvegarder       [r] Recharger"
        echo "  [q]    Retour au menu principal"
        echo
        
        # Stocker les alias de la page pour les actions
        CURRENT_PAGE_ALIASES=()
        local j=1
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                CURRENT_PAGE_ALIASES[$j]="$line"
                ((j++))
            fi
        done <<< "$page_aliases"
        
        read -k 1 "action?Votre choix: "
        echo
        
        case "$action" in
            [1-9])
                if [[ -n "${CURRENT_PAGE_ALIASES[$action]}" ]]; then
                    if [[ " $SELECTED_ALIASES " =~ " $action " ]]; then
                        SELECTED_ALIASES=${SELECTED_ALIASES// $action /}
                    else
                        SELECTED_ALIASES="$SELECTED_ALIASES $action "
                    fi
                fi
                show_aliases_list
                ;;
            n|N)
                if [[ $CURRENT_PAGE -lt $total_pages ]]; then
                    ((CURRENT_PAGE++))
                    SELECTED_ALIASES=""
                fi
                show_aliases_list
                ;;
            p|P)
                if [[ $CURRENT_PAGE -gt 1 ]]; then
                    ((CURRENT_PAGE--))
                    SELECTED_ALIASES=""
                fi
                show_aliases_list
                ;;
            s|S)
                read "search_input?Entrez le terme de recherche: "
                SEARCH_TERM="$search_input"
                CURRENT_PAGE=1
                SELECTED_ALIASES=""
                show_aliases_list
                ;;
            c|C)
                SEARCH_TERM=""
                CURRENT_PAGE=1
                SELECTED_ALIASES=""
                show_aliases_list
                ;;
            a|A)
                SELECTED_ALIASES=""
                for ((j=1; j<=i-1; j++)); do
                    SELECTED_ALIASES="$SELECTED_ALIASES $j "
                done
                show_aliases_list
                ;;
            x|X)
                SELECTED_ALIASES=""
                show_aliases_list
                ;;
            e|E)
                edit_selected_aliases
                ;;
            d|D)
                delete_selected_aliases
                ;;
            i|I)
                show_selected_aliases_info
                ;;
            t|T)
                test_selected_aliases
                ;;
            +)
                add_new_alias
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
    
    # Fonction pour éditer les alias sélectionnés
    edit_selected_aliases() {
        if [[ -z "$SELECTED_ALIASES" ]]; then
            echo -e "${RED}⚠️ Aucun alias sélectionné${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        show_header
        echo -e "${YELLOW}✏️ Édition des alias sélectionnés${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        for num in $SELECTED_ALIASES; do
            local alias_line="${CURRENT_PAGE_ALIASES[$num]}"
            if [[ -n "$alias_line" ]]; then
                local alias_name=$(echo "$alias_line" | sed 's/^alias \([^=]*\)=.*/\1/')
                local alias_command=$(echo "$alias_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                
                echo -e "\n${CYAN}Édition de l'alias: $alias_name${RESET}"
                echo "Commande actuelle: $alias_command"
                echo
                
                read "new_command?Nouvelle commande (Entrée pour garder): "
                read "description?Description (optionnelle): "
                
                if [[ -n "$new_command" ]]; then
                    # Supprimer l'ancien alias
                    sed -i "/^alias $alias_name=/d" "$ALIASES_FILE"
                    
                    # Ajouter la description si fournie
                    if [[ -n "$description" ]]; then
                        echo "# DESC: $description" >> "$ALIASES_FILE"
                    fi
                    
                    # Ajouter le nouvel alias
                    echo "alias $alias_name=\"$new_command\"" >> "$ALIASES_FILE"
                    
                    echo -e "${GREEN}✅ Alias '$alias_name' modifié${RESET}"
                else
                    echo -e "${BLUE}ℹ️ Alias '$alias_name' inchangé${RESET}"
                fi
            fi
        done
        
        SELECTED_ALIASES=""
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
        show_aliases_list
    }
    
    # Fonction pour supprimer les alias sélectionnés
    delete_selected_aliases() {
        if [[ -z "$SELECTED_ALIASES" ]]; then
            echo -e "${RED}⚠️ Aucun alias sélectionné${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        show_header
        echo -e "${YELLOW}🗑️ Suppression des alias${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo "Alias sélectionnés pour suppression:"
        for num in $SELECTED_ALIASES; do
            local alias_line="${CURRENT_PAGE_ALIASES[$num]}"
            if [[ -n "$alias_line" ]]; then
                local alias_name=$(echo "$alias_line" | sed 's/^alias \([^=]*\)=.*/\1/')
                echo "  • $alias_name"
            fi
        done
        
        echo
        read -k 1 "confirm?Confirmer la suppression? [y/N]: "
        echo
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            backup_aliases
            
            for num in $SELECTED_ALIASES; do
                local alias_line="${CURRENT_PAGE_ALIASES[$num]}"
                if [[ -n "$alias_line" ]]; then
                    local alias_name=$(echo "$alias_line" | sed 's/^alias \([^=]*\)=.*/\1/')
                    
                    # Supprimer l'alias du fichier
                    sed -i "/^alias $alias_name=/d" "$ALIASES_FILE"
                    # Supprimer aussi la description précédente si elle existe
                    sed -i "/^# DESC:.*/{N; /\nalias $alias_name=/d;}" "$ALIASES_FILE"
                    
                    # Désactiver l'alias dans la session courante
                    unalias "$alias_name" 2>/dev/null
                    
                    echo -e "${GREEN}✅ Alias '$alias_name' supprimé${RESET}"
                fi
            done
            
            SELECTED_ALIASES=""
        else
            echo -e "${BLUE}ℹ️ Suppression annulée${RESET}"
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
        show_aliases_list
    }
    
    # Fonction pour afficher les informations détaillées
    show_selected_aliases_info() {
        if [[ -z "$SELECTED_ALIASES" ]]; then
            echo -e "${RED}⚠️ Aucun alias sélectionné${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        show_header
        echo -e "${YELLOW}📋 Informations détaillées${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        for num in $SELECTED_ALIASES; do
            local alias_line="${CURRENT_PAGE_ALIASES[$num]}"
            if [[ -n "$alias_line" ]]; then
                local alias_name=$(echo "$alias_line" | sed 's/^alias \([^=]*\)=.*/\1/')
                local alias_command=$(echo "$alias_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                
                echo -e "\n${CYAN}Alias: $alias_name${RESET}"
                echo "─────────────────────────"
                echo "Commande: $alias_command"
                
                # Chercher une description
                local line_num=$(grep -n "^alias $alias_name=" "$ALIASES_FILE" | cut -d: -f1)
                if [[ -n "$line_num" ]]; then
                    local desc_line=$((line_num - 1))
                    local description=$(sed -n "${desc_line}p" "$ALIASES_FILE" | grep "^# DESC:" | sed 's/^# DESC: //')
                    if [[ -n "$description" ]]; then
                        echo "Description: $description"
                    fi
                fi
                
                # Vérifier si l'alias est actif dans la session courante
                if alias "$alias_name" &>/dev/null; then
                    echo -e "État: ${GREEN}Actif${RESET}"
                else
                    echo -e "État: ${RED}Inactif${RESET}"
                fi
                
                # Type de commande
                if [[ "$alias_command" =~ ^cd ]]; then
                    echo "Type: Navigation"
                elif [[ "$alias_command" =~ ^git ]]; then
                    echo "Type: Git"
                elif [[ "$alias_command" =~ ^docker ]]; then
                    echo "Type: Docker"
                elif [[ "$alias_command" =~ ^sudo ]]; then
                    echo "Type: Système (sudo)"
                else
                    echo "Type: Commande générale"
                fi
                
                # Longueur de la commande
                echo "Taille: ${#alias_command} caractères"
            fi
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
        show_aliases_list
    }
    
    # Fonction pour tester les alias sélectionnés
    test_selected_aliases() {
        if [[ -z "$SELECTED_ALIASES" ]]; then
            echo -e "${RED}⚠️ Aucun alias sélectionné${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        show_header
        echo -e "${YELLOW}🧪 Test des alias sélectionnés${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        for num in $SELECTED_ALIASES; do
            local alias_line="${CURRENT_PAGE_ALIASES[$num]}"
            if [[ -n "$alias_line" ]]; then
                local alias_name=$(echo "$alias_line" | sed 's/^alias \([^=]*\)=.*/\1/')
                local alias_command=$(echo "$alias_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                
                echo -e "\n${CYAN}Test de l'alias: $alias_name${RESET}"
                echo "Commande: $alias_command"
                
                # Vérifier si la commande de base existe
                local base_cmd=$(echo "$alias_command" | awk '{print $1}')
                if command -v "$base_cmd" &>/dev/null; then
                    echo -e "Commande de base: ${GREEN}✅ Trouvée${RESET}"
                else
                    echo -e "Commande de base: ${RED}❌ Non trouvée${RESET}"
                fi
                
                # Pour les alias cd, vérifier si le répertoire existe
                if [[ "$alias_command" =~ ^cd ]]; then
                    local target_dir=$(echo "$alias_command" | sed 's/^cd[[:space:]]*//')
                    if [[ -d "$target_dir" ]]; then
                        echo -e "Répertoire cible: ${GREEN}✅ Existe${RESET}"
                    else
                        echo -e "Répertoire cible: ${RED}❌ N'existe pas${RESET}"
                    fi
                fi
                
                # Test d'exécution simple (dry-run pour les commandes dangereuses)
                if [[ "$alias_command" =~ (rm|sudo|kill|shutdown|reboot) ]]; then
                    echo -e "Test d'exécution: ${YELLOW}⚠️ Commande potentiellement dangereuse${RESET}"
                else
                    echo -n "Test d'exécution: "
                    if timeout 2s bash -c "type $alias_name" &>/dev/null; then
                        echo -e "${GREEN}✅ OK${RESET}"
                    else
                        echo -e "${RED}❌ Erreur${RESET}"
                    fi
                fi
            fi
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
        show_aliases_list
    }
    
    # Fonction pour ajouter un nouvel alias
    add_new_alias() {
        show_header
        echo -e "${YELLOW}➕ Ajouter un nouvel alias${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        read "alias_name?Nom de l'alias: "
        if [[ -z "$alias_name" ]]; then
            echo -e "${RED}❌ Nom d'alias requis${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        # Vérifier si l'alias existe déjà
        if grep -q "^alias $alias_name=" "$ALIASES_FILE"; then
            echo -e "${RED}❌ L'alias '$alias_name' existe déjà${RESET}"
            read -k 1 "overwrite?Remplacer? [y/N]: "
            echo
            if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
                show_aliases_list
                return
            fi
            # Supprimer l'ancien alias
            sed -i "/^alias $alias_name=/d" "$ALIASES_FILE"
        fi
        
        read "alias_command?Commande de l'alias: "
        if [[ -z "$alias_command" ]]; then
            echo -e "${RED}❌ Commande requise${RESET}"
            sleep 2
            show_aliases_list
            return
        fi
        
        read "description?Description (optionnelle): "
        
        # Ajouter la description si fournie
        if [[ -n "$description" ]]; then
            echo "# DESC: $description" >> "$ALIASES_FILE"
        fi
        
        # Ajouter l'alias
        echo "alias $alias_name=\"$alias_command\"" >> "$ALIASES_FILE"
        
        # Activer l'alias dans la session courante
        alias "$alias_name"="$alias_command"
        
        echo -e "${GREEN}✅ Alias '$alias_name' ajouté avec succès${RESET}"
        sleep 2
        show_aliases_list
    }
    
    # Fonction pour recharger les alias
    reload_aliases() {
        ensure_aliases_file
        source "$ALIASES_FILE"
        echo -e "${GREEN}✅ Alias rechargés depuis $ALIASES_FILE${RESET}"
    }
    
    # Fonction pour recherche rapide
    quick_search() {
        local search_term="$1"
        if [[ -z "$search_term" ]]; then
            echo -e "${RED}❌ Terme de recherche requis${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}🔍 Recherche d'alias contenant '$search_term':${RESET}"
        local results=$(parse_aliases "$search_term")
        
        if [[ -z "$results" ]]; then
            echo -e "${RED}❌ Aucun alias trouvé${RESET}"
            return 1
        fi
        
        echo "$results" | while IFS= read -r line; do
            local alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
            local alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
        done
    }
    
    # Fonction pour lister tous les alias (format simple)
    list_all_aliases() {
        echo -e "${CYAN}📋 Liste complète des alias:${RESET}"
        parse_aliases | while IFS= read -r line; do
            local alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
            local alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            printf "  ${YELLOW}%-20s${RESET} %s\n" "$alias_name" "$alias_command"
        done
    }
    
    # Fonction pour exporter les alias
    export_aliases() {
        show_header
        echo -e "${YELLOW}💾 Export des alias${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local export_file="$HOME/aliases_export_$timestamp.zsh"
        
        {
            echo "#!/bin/zsh"
            echo "# Export des alias - $(date)"
            echo "# Généré par ALIAMAN - Alias Manager"
            echo
            cat "$ALIASES_FILE"
        } > "$export_file"
        
        echo -e "${GREEN}✅ Alias exportés vers: $export_file${RESET}"
        echo
        echo "Pour importer ces alias sur un autre système:"
        echo "  source $export_file"
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour les statistiques
    show_statistics() {
        show_header
        echo -e "${YELLOW}📊 Statistiques des alias${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        local total_aliases=$(parse_aliases | wc -l)
        echo "Nombre total d'alias: $total_aliases"
        
        echo -e "\n${CYAN}Top 5 des commandes les plus aliasées:${RESET}"
        parse_aliases | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/' | \
        awk '{print $1}' | sort | uniq -c | sort -rn | head -5 | \
        awk '{printf "  %2d × %s\n", $1, $2}'
        
        echo -e "\n${CYAN}Répartition par type:${RESET}"
        local git_count=$(parse_aliases | grep -c "git")
        local docker_count=$(parse_aliases | grep -c "docker")
        local cd_count=$(parse_aliases | grep -c "cd ")
        local sudo_count=$(parse_aliases | grep -c "sudo")
        
        echo "  Git: $git_count alias"
        echo "  Docker: $docker_count alias"
        echo "  Navigation (cd): $cd_count alias"
        echo "  Système (sudo): $sudo_count alias"
        
        echo -e "\n${CYAN}Alias les plus longs:${RESET}"
        parse_aliases | while IFS= read -r line; do
            local alias_name=$(echo "$line" | sed 's/^alias \([^=]*\)=.*/\1/')
            local alias_command=$(echo "$line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
            echo "${#alias_command} $alias_name $alias_command"
        done | sort -rn | head -3 | while read length name command; do
            echo "  $name ($length caractères)"
        done
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Menu principal
    while true; do
        show_header
        echo -e "${GREEN}Menu Principal${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
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
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        read -k 1 "choice?Votre choix: "
        echo
        
        case "$choice" in
            1)
                CURRENT_PAGE=1
                SELECTED_ALIASES=""
                SEARCH_TERM=""
                show_aliases_list
                ;;
            2) add_new_alias ;;
            3)
                read "search_term?Terme à rechercher: "
                quick_search "$search_term"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                list_all_aliases
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                read "alias_to_remove?Nom de l'alias à supprimer: "
                if [[ -n "$alias_to_remove" ]]; then
                    if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE"; then
                        read -k 1 "confirm?Supprimer l'alias '$alias_to_remove'? [y/N]: "
                        echo
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            backup_aliases
                            sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE"
                            unalias "$alias_to_remove" 2>/dev/null
                            echo -e "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}"
                        fi
                    else
                        echo -e "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}"
                    fi
                fi
                sleep 2
                ;;
            6)
                read "alias_to_edit?Nom de l'alias à éditer: "
                if [[ -n "$alias_to_edit" ]]; then
                    local current_command=$(grep "^alias $alias_to_edit=" "$ALIASES_FILE" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
                    if [[ -n "$current_command" ]]; then
                        echo "Commande actuelle: $current_command"
                        read "new_command?Nouvelle commande: "
                        if [[ -n "$new_command" ]]; then
                            backup_aliases
                            sed -i "/^alias $alias_to_edit=/d" "$ALIASES_FILE"
                            echo "alias $alias_to_edit=\"$new_command\"" >> "$ALIASES_FILE"
                            alias "$alias_to_edit"="$new_command"
                            echo -e "${GREEN}✅ Alias '$alias_to_edit' modifié${RESET}"
                        fi
                    else
                        echo -e "${RED}❌ Alias '$alias_to_edit' non trouvé${RESET}"
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
                echo -e "${CYAN}📚 Aide - ALIAMAN${RESET}"
                echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
                echo
                echo "ALIAMAN est un gestionnaire complet d'alias pour ZSH."
                echo
                echo "Fonctionnalités principales:"
                echo "  • Gestion interactive avec sélection multiple"
                echo "  • Recherche et filtrage avancé"
                echo "  • Pagination pour de grandes listes"
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
                echo "  aliaman remove <nom>       - Supprime un alias"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            q|Q)
                echo -e "${GREEN}Au revoir!${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Option invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Alias et raccourcis pour ALIAMAN
alias am='aliaman'
alias alias-manager='aliaman'

# Fonction pour accès direct aux sous-commandes
if [[ "$1" == "search" && -n "$2" ]]; then
    shift
    aliaman
    quick_search "$@"
elif [[ "$1" == "list" ]]; then
    aliaman
    list_all_aliases
elif [[ "$1" == "add" && -n "$2" && -n "$3" ]]; then
    name="$2"
    command="$3"
    description="$4"
    ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"
    
    if grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        echo "❌ L'alias '$name' existe déjà"
        return 1
    fi
    
    if [[ -n "$description" ]]; then
        echo "# DESC: $description" >> "$ALIASES_FILE"
    fi
    echo "alias $name=\"$command\"" >> "$ALIASES_FILE"
    alias "$name"="$command"
    echo "✅ Alias '$name' ajouté"
elif [[ "$1" == "remove" && -n "$2" ]]; then
    name="$2"
    ALIASES_FILE="$HOME/dotfiles/zsh/aliases.zsh"
    
    if grep -q "^alias $name=" "$ALIASES_FILE" 2>/dev/null; then
        sed -i "/^alias $name=/d" "$ALIASES_FILE"
        unalias "$name" 2>/dev/null
        echo "✅ Alias '$name' supprimé"
    else
        echo "❌ Alias '$name' non trouvé"
    fi
elif [[ "$1" == "reload" ]]; then
    source "$HOME/dotfiles/zsh/aliases.zsh" 2>/dev/null
    echo "✅ Alias rechargés"
fi

# Message d'initialisation
echo "🚀 ALIAMAN chargé - Tapez 'aliaman' ou 'am' pour démarrer"
