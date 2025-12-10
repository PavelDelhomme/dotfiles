#!/bin/zsh
# =============================================================================
# PAGINATION UTILITY - Utilitaires de pagination pour cyberman
# =============================================================================
# Description: Fonctions de pagination pour affichage de listes longues
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# DESC: Affiche une liste paginée avec navigation
# USAGE: paginate_list <array_name> <items_per_page> <display_function>
# EXAMPLE: paginate_list "my_array" 10 "display_item"
paginate_list() {
    local array_name="$1"
    local items_per_page="${2:-10}"
    local display_func="$3"
    local current_page=1
    
    # Récupérer le tableau
    local -a items=("${(@P)array_name}")
    local total_items=${#items[@]}
    local total_pages=$(( (total_items + items_per_page - 1) / items_per_page ))
    
    if [ $total_items -eq 0 ]; then
        echo "⚠️  Aucun élément à afficher"
        return 0
    fi
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${CYAN}${BOLD}Page $current_page / $total_pages (Total: $total_items éléments)${RESET}"
        echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Calculer les indices
        local start=$(( (current_page - 1) * items_per_page + 1 ))
        local end=$(( current_page * items_per_page ))
        if [ $end -gt $total_items ]; then
            end=$total_items
        fi
        
        # Afficher les éléments de la page
        local idx=$start
        while [ $idx -le $end ]; do
            local item="${items[$idx]}"
            if [ -n "$display_func" ] && type "$display_func" >/dev/null 2>&1; then
                "$display_func" "$item" "$idx"
            else
                echo "  $idx. $item"
            fi
            ((idx++))
        done
        
        echo ""
        echo -e "${YELLOW}Navigation:${RESET}"
        if [ $current_page -gt 1 ]; then
            echo "  p - Page précédente"
        fi
        if [ $current_page -lt $total_pages ]; then
            echo "  n - Page suivante"
        fi
        echo "  <numéro> - Aller à la page <numéro>"
        echo "  q - Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 10)
        
        case "$choice" in
            p|P|prev|previous)
                if [ $current_page -gt 1 ]; then
                    ((current_page--))
                fi
                ;;
            n|N|next)
                if [ $current_page -lt $total_pages ]; then
                    ((current_page++))
                fi
                ;;
            q|Q|quit|exit)
                return 0
                ;;
            [0-9]*)
                local page_num=$((choice))
                if [ $page_num -ge 1 ] && [ $page_num -le $total_pages ]; then
                    current_page=$page_num
                else
                    echo -e "${RED}Page invalide (1-$total_pages)${RESET}"
                    sleep 1
                fi
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# DESC: Affiche du texte avec pagination (pour notes, historique, etc.)
# USAGE: paginate_text <text_content> [items_per_page]
# EXAMPLE: paginate_text "$long_text" 20
paginate_text() {
    local text_content="$1"
    local lines_per_page="${2:-20}"
    
    if [ -z "$text_content" ]; then
        echo "⚠️  Aucun contenu à afficher"
        return 0
    fi
    
    # Convertir en tableau de lignes
    local -a lines=("${(f)text_content}")
    local total_lines=${#lines[@]}
    local current_page=1
    local total_pages=$(( (total_lines + lines_per_page - 1) / lines_per_page ))
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${CYAN}${BOLD}Page $current_page / $total_pages (Total: $total_lines lignes)${RESET}"
        echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Calculer les indices
        local start=$(( (current_page - 1) * lines_per_page + 1 ))
        local end=$(( current_page * lines_per_page ))
        if [ $end -gt $total_lines ]; then
            end=$total_lines
        fi
        
        # Afficher les lignes de la page
        local idx=$start
        while [ $idx -le $end ]; do
            echo "${lines[$idx]}"
            ((idx++))
        done
        
        echo ""
        echo -e "${YELLOW}Navigation:${RESET}"
        if [ $current_page -gt 1 ]; then
            echo "  p - Page précédente"
        fi
        if [ $current_page -lt $total_pages ]; then
            echo "  n - Page suivante"
        fi
        echo "  <numéro> - Aller à la page <numéro>"
        echo "  q - Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 10)
        
        case "$choice" in
            p|P|prev|previous)
                if [ $current_page -gt 1 ]; then
                    ((current_page--))
                fi
                ;;
            n|N|next)
                if [ $current_page -lt $total_pages ]; then
                    ((current_page++))
                fi
                ;;
            q|Q|quit|exit)
                return 0
                ;;
            [0-9]*)
                local page_num=$((choice))
                if [ $page_num -ge 1 ] && [ $page_num -le $total_pages ]; then
                    current_page=$page_num
                else
                    echo -e "${RED}Page invalide (1-$total_pages)${RESET}"
                    sleep 1
                fi
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

