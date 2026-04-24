#!/bin/bash
# =============================================================================
# DOTFILES_DOC - Documentation Interactive Complète des Dotfiles
# =============================================================================
# Description: Système interactif pour naviguer dans toute la documentation
# Auteur: Paul Delhomme
# Version: 1.0
# =============================================================================

# Variables
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ACTIONS_LOG_FILE="$DOTFILES_DIR/logs/actions.log"
INSTALL_LOG_FILE="$DOTFILES_DIR/logs/install.log"
FUNCTION_DOC_FILE="$DOTFILES_DIR/zsh/functions_doc.json"
ALIASES_FILE="$DOTFILES_DIR/zsh/aliases.zsh"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

################################################################################
# DESC: Affiche l'en-tête du menu
# USAGE: show_header [title]
################################################################################
show_header() {
    local title="${1:-Documentation Interactive des Dotfiles}"
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    printf "║%63s║\n" " "
    printf "║%$((${#title}+15))s${RESET}${CYAN}%63s║\n" "$title"
    printf "║%63s║\n" " "
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

################################################################################
# DESC: Affiche le menu principal
# USAGE: show_main_menu
################################################################################
show_main_menu() {
    show_header "Menu Principal - Documentation Dotfiles"
    
    echo -e "${YELLOW}📚 Documentation${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo "  ${BOLD}1${RESET}  📖 Documentation des fonctions"
    echo "  ${BOLD}2${RESET}  📝 Documentation des alias"
    echo "  ${BOLD}3${RESET}  🔧 Documentation des scripts"
    echo "  ${BOLD}4${RESET}  📁 Structure du projet"
    echo "  ${BOLD}5${RESET}  📋 Fichiers de documentation (README, STATUS, STRUCTURE)"
    echo
    echo -e "${YELLOW}🔍 Recherche${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo "  ${BOLD}6${RESET}  🔎 Recherche globale dans la documentation"
    echo "  ${BOLD}7${RESET}  📊 Statistiques du projet"
    echo
    echo -e "${YELLOW}📜 Historique & Logs${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo "  ${BOLD}8${RESET}  📜 Logs d'actions (actions.log)"
    echo "  ${BOLD}9${RESET}  📝 Logs d'installation (install.log)"
    echo
    echo -e "${YELLOW}🛠️  Utilitaires${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo "  ${BOLD}10${RESET} 🔄 Générer/Actualiser documentation"
    echo "  ${BOLD}11${RESET} 📤 Exporter documentation (Markdown)"
    echo "  ${BOLD}12${RESET} 🗂️  Voir structure complète"
    echo
    echo "  ${BOLD}0${RESET}  🚪 Quitter"
    echo
}

################################################################################
# DESC: Menu documentation des fonctions
# USAGE: menu_functions_doc
################################################################################
menu_functions_doc() {
    while true; do
        show_header "Documentation des Fonctions"
        
        echo "  ${BOLD}1${RESET}  📋 Lister toutes les fonctions"
        echo "  ${BOLD}2${RESET}  🔍 Rechercher une fonction"
        echo "  ${BOLD}3${RESET}  📖 Voir documentation d'une fonction"
        echo "  ${BOLD}4${RESET}  📁 Fonctions par catégorie"
        echo "  ${BOLD}0${RESET}  🔙 Retour"
        echo
        read -p "Choix: " choice
        echo
        
        case "$choice" in
            1)
                if [[ -f "$DOTFILES_DIR/scripts/lib/function_doc.sh" ]]; then
                    source "$DOTFILES_DIR/scripts/lib/function_doc.sh"
                    list_all_functions
                    read -p "Appuyez sur Entrée pour continuer..."
                else
                    echo -e "${RED}❌ Script function_doc.sh non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            2)
                read -p "Terme de recherche: " search_term
                if [[ -n "$search_term" ]]; then
                    if [[ -f "$DOTFILES_DIR/scripts/lib/function_doc.sh" ]]; then
                        source "$DOTFILES_DIR/scripts/lib/function_doc.sh"
                        search_function_doc "$search_term"
                    fi
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            3)
                read -p "Nom de la fonction: " func_name
                if [[ -n "$func_name" ]]; then
                    if [[ -f "$DOTFILES_DIR/scripts/lib/function_doc.sh" ]]; then
                        source "$DOTFILES_DIR/scripts/lib/function_doc.sh"
                        show_function_doc "$func_name"
                    fi
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            4)
                show_functions_by_category
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# DESC: Affiche les fonctions par catégorie
# USAGE: show_functions_by_category
################################################################################
show_functions_by_category() {
    show_header "Fonctions par Catégorie"
    
    local categories=(
        "managers:📁 Gestionnaires (*man.zsh)"
        "cyber:🛡️ Cybersécurité"
        "dev:💻 Développement"
        "misc:🔧 Divers"
        "git:📦 Git"
        "utils:🛠️ Utilitaires"
    )
    
    for cat_info in "${categories[@]}"; do
        IFS=':' read -r cat_name cat_label <<< "$cat_info"
        echo -e "\n${CYAN}${cat_label}${RESET}"
        echo "────────────────────────────────────────────────────────────────"
        
        case "$cat_name" in
            managers)
                find "$DOTFILES_DIR/zsh/functions" -maxdepth 1 -name "*man.zsh" -exec basename {} \; | sed 's/.zsh$//' | while read -r func; do
                    echo "  • $func"
                done
                ;;
            cyber)
                find "$DOTFILES_DIR/zsh/functions/cyber" -type f -name "*.sh" -exec basename {} \; | sed 's/.sh$//' | head -10 | while read -r func; do
                    echo "  • $func"
                done
                ;;
            dev)
                find "$DOTFILES_DIR/zsh/functions/dev" -type f -name "*.sh" -exec basename {} \; | sed 's/.sh$//' | while read -r func; do
                    echo "  • $func"
                done
                ;;
            misc)
                find "$DOTFILES_DIR/zsh/functions/misc" -type f -name "*.sh" -exec basename {} \; | sed 's/.sh$//' | head -10 | while read -r func; do
                    echo "  • $func"
                done
                ;;
            git)
                find "$DOTFILES_DIR/zsh/functions/git" -type f -name "*.sh" -exec basename {} \; | sed 's/.sh$//' | while read -r func; do
                    echo "  • $func"
                done
                ;;
            utils)
                find "$DOTFILES_DIR/zsh/functions/utils" -type f -name "*.sh" -exec basename {} \; | sed 's/.sh$//' | while read -r func; do
                    echo "  • $func"
                done
                ;;
        esac
    done
}

################################################################################
# DESC: Menu documentation des alias
# USAGE: menu_aliases_doc
################################################################################
menu_aliases_doc() {
    while true; do
        show_header "Documentation des Alias"
        
        echo "  ${BOLD}1${RESET}  📋 Lister tous les alias"
        echo "  ${BOLD}2${RESET}  🔍 Rechercher un alias"
        echo "  ${BOLD}3${RESET}  📖 Voir documentation d'un alias"
        echo "  ${BOLD}4${RESET}  📊 Statistiques des alias"
        echo "  ${BOLD}0${RESET}  🔙 Retour"
        echo
        read -p "Choix: " choice
        echo
        
        case "$choice" in
            1)
                if [[ -f "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh" ]]; then
                    source "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh"
                    list_alias | less -R
                else
                    echo -e "${RED}❌ Script alias_utils.zsh non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            2)
                read -p "Terme de recherche: " search_term
                if [[ -n "$search_term" ]]; then
                    if [[ -f "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh" ]]; then
                        source "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh"
                        search_alias "$search_term" | less -R
                    fi
                fi
                ;;
            3)
                read -p "Nom de l'alias: " alias_name
                if [[ -n "$alias_name" ]]; then
                    if [[ -f "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh" ]]; then
                        source "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh"
                        get_alias_doc "$alias_name"
                    fi
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            4)
                show_alias_statistics
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# DESC: Affiche les statistiques des alias
# USAGE: show_alias_statistics
################################################################################
show_alias_statistics() {
    show_header "Statistiques des Alias"
    
    if [[ ! -f "$ALIASES_FILE" ]]; then
        echo -e "${RED}❌ Fichier d'alias non trouvé${RESET}"
        return 1
    fi
    
    local total=$(grep -c "^alias " "$ALIASES_FILE" 2>/dev/null || echo "0")
    local with_doc=$(grep -c "^# DESC:" "$ALIASES_FILE" 2>/dev/null || echo "0")
    
    echo -e "${CYAN}Total d'alias:${RESET} $total"
    echo -e "${CYAN}Avec documentation:${RESET} $with_doc"
    echo -e "${CYAN}Sans documentation:${RESET} $((total - with_doc))"
    echo
    
    echo -e "${YELLOW}Top 5 commandes les plus aliasées:${RESET}"
    grep "^alias " "$ALIASES_FILE" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/' | awk '{print $1}' | sort | uniq -c | sort -rn | head -5 | awk '{printf "  %2d × %s\n", $1, $2}'
}

################################################################################
# DESC: Menu documentation des scripts
# USAGE: menu_scripts_doc
################################################################################
menu_scripts_doc() {
    while true; do
        show_header "Documentation des Scripts"
        
        echo "  ${BOLD}1${RESET}  📋 Lister tous les scripts"
        echo "  ${BOLD}2${RESET}  🔍 Rechercher un script"
        echo "  ${BOLD}3${RESET}  📖 Voir documentation d'un script"
        echo "  ${BOLD}4${RESET}  📁 Scripts par catégorie"
        echo "  ${BOLD}0${RESET}  🔙 Retour"
        echo
        read -p "Choix: " choice
        echo
        
        case "$choice" in
            1)
                list_all_scripts
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            2)
                read -p "Terme de recherche: " search_term
                if [[ -n "$search_term" ]]; then
                    search_scripts "$search_term"
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            3)
                read -p "Chemin du script (ex: scripts/install/apps/install_cursor.sh): " script_path
                if [[ -n "$script_path" ]]; then
                    show_script_doc "$script_path"
                fi
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            4)
                show_scripts_by_category
                read -p "Appuyez sur Entrée pour continuer..."
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# DESC: Liste tous les scripts
# USAGE: list_all_scripts
################################################################################
list_all_scripts() {
    show_header "Liste de Tous les Scripts"
    
    local scripts_dir="$DOTFILES_DIR/scripts"
    
    echo -e "${CYAN}Scripts disponibles:${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    find "$scripts_dir" -type f -name "*.sh" | sort | while read -r script; do
        local rel_path="${script#$DOTFILES_DIR/}"
        local desc=$(grep -m1 "^#.*Description:" "$script" 2>/dev/null | sed 's/^#.*Description:\?[[:space:]]*//')
        if [[ -n "$desc" ]]; then
            printf "  ${YELLOW}%-50s${RESET} %s\n" "$rel_path" "$desc"
        else
            echo "  $rel_path"
        fi
    done | less -R
}

################################################################################
# DESC: Recherche dans les scripts
# USAGE: search_scripts <term>
################################################################################
search_scripts() {
    local search_term="$1"
    
    show_header "Recherche dans les Scripts: '$search_term'"
    
    local scripts_dir="$DOTFILES_DIR/scripts"
    
    find "$scripts_dir" -type f -name "*.sh" -exec grep -l "$search_term" {} \; | sort | while read -r script; do
        local rel_path="${script#$DOTFILES_DIR/}"
        local matches=$(grep -c "$search_term" "$script" 2>/dev/null || echo "0")
        echo -e "${CYAN}$rel_path${RESET} (${matches} occurrence(s))"
    done | less -R
}

################################################################################
# DESC: Affiche la documentation d'un script
# USAGE: show_script_doc <script_path>
################################################################################
show_script_doc() {
    local script_path="$1"
    local full_path="$DOTFILES_DIR/$script_path"
    
    if [[ ! -f "$full_path" ]]; then
        echo -e "${RED}❌ Script non trouvé: $script_path${RESET}"
        return 1
    fi
    
    show_header "Documentation: $script_path"
    
    # Extraire la documentation du header
    local in_header=false
    local description=""
    local author=""
    local version=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^#.*Description: ]]; then
            description="${line#*Description:}"
            description="${description## }"
        elif [[ "$line" =~ ^#.*Auteur: ]] || [[ "$line" =~ ^#.*Author: ]]; then
            author="${line#*:}"
            author="${author## }"
        elif [[ "$line" =~ ^#.*Version: ]]; then
            version="${line#*Version:}"
            version="${version## }"
        fi
    done < "$full_path"
    
    [[ -n "$description" ]] && echo -e "${YELLOW}Description:${RESET} $description"
    [[ -n "$author" ]] && echo -e "${CYAN}Auteur:${RESET} $author"
    [[ -n "$version" ]] && echo -e "${BLUE}Version:${RESET} $version"
    echo
    echo -e "${CYAN}Contenu du script (premières 50 lignes):${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    head -50 "$full_path" | less -R
}

################################################################################
# DESC: Affiche les scripts par catégorie
# USAGE: show_scripts_by_category
################################################################################
show_scripts_by_category() {
    show_header "Scripts par Catégorie"
    
    local categories=(
        "install:📦 Installation"
        "config:⚙️ Configuration"
        "sync:🔄 Synchronisation"
        "test:✅ Tests"
        "uninstall:🗑️ Désinstallation"
        "lib:📚 Bibliothèques"
    )
    
    for cat_info in "${categories[@]}"; do
        IFS=':' read -r cat_name cat_label <<< "$cat_info"
        echo -e "\n${CYAN}${cat_label}${RESET}"
        echo "────────────────────────────────────────────────────────────────"
        
        local cat_dir="$DOTFILES_DIR/scripts/$cat_name"
        if [[ -d "$cat_dir" ]]; then
            find "$cat_dir" -type f -name "*.sh" | sort | while read -r script; do
                local rel_path="${script#$DOTFILES_DIR/}"
                local desc=$(grep -m1 "^#.*Description:" "$script" 2>/dev/null | sed 's/^#.*Description:\?[[:space:]]*//')
                if [[ -n "$desc" ]]; then
                    echo "  • $(basename "$script") - $desc"
                else
                    echo "  • $(basename "$script")"
                fi
            done
        else
            echo "  (aucun script)"
        fi
    done
}

################################################################################
# DESC: Affiche la structure du projet
# USAGE: show_project_structure
################################################################################
show_project_structure() {
    show_header "Structure du Projet"
    
    echo -e "${CYAN}Structure principale:${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    tree -L 3 -I 'node_modules|.git|__pycache__|*.pyc|venv' "$DOTFILES_DIR" 2>/dev/null | head -100 || \
    find "$DOTFILES_DIR" -maxdepth 3 -type d | grep -v ".git" | sort | sed 's|'$DOTFILES_DIR'||' | sed 's|^/||' | while read -r dir; do
        echo "  $dir/"
    done | less -R
}

################################################################################
# DESC: Affiche les fichiers de documentation
# USAGE: show_doc_files
################################################################################
show_doc_files() {
    while true; do
        show_header "Fichiers de Documentation"
        
        echo "  ${BOLD}1${RESET}  📖 README.md"
        echo "  ${BOLD}2${RESET}  📋 STATUS.md (racine)"
        echo "  ${BOLD}3${RESET}  ✅ TODOS.md"
        echo "  ${BOLD}4${RESET}  🗂️  STRUCTURE.md"
        echo "  ${BOLD}5${RESET}  📜 REFACTOR_HISTORY.md"
        echo "  ${BOLD}6${RESET}  📝 scripts/README.md (si existe)"
        echo "  ${BOLD}0${RESET}  🔙 Retour"
        echo
        read -p "Choix: " choice
        echo
        
        case "$choice" in
            1)
                if [[ -f "$DOTFILES_DIR/README.md" ]]; then
                    less -R "$DOTFILES_DIR/README.md"
                else
                    echo -e "${RED}❌ README.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            2)
                if [[ -f "$DOTFILES_DIR/STATUS.md" ]]; then
                    less -R "$DOTFILES_DIR/STATUS.md"
                else
                    echo -e "${RED}❌ STATUS.md (racine) non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            3)
                if [[ -f "$DOTFILES_DIR/TODOS.md" ]]; then
                    less -R "$DOTFILES_DIR/TODOS.md"
                else
                    echo -e "${RED}❌ TODOS.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            4)
                if [[ -f "$DOTFILES_DIR/docs/STRUCTURE.md" ]]; then
                    less -R "$DOTFILES_DIR/docs/STRUCTURE.md"
                else
                    echo -e "${RED}❌ STRUCTURE.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            5)
                if [[ -f "$DOTFILES_DIR/docs/REFACTOR_HISTORY.md" ]]; then
                    less -R "$DOTFILES_DIR/docs/REFACTOR_HISTORY.md"
                else
                    echo -e "${RED}❌ docs/REFACTOR_HISTORY.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            6)
                if [[ -f "$DOTFILES_DIR/scripts/README.md" ]]; then
                    less -R "$DOTFILES_DIR/scripts/README.md"
                else
                    echo -e "${RED}❌ scripts/README.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# DESC: Recherche globale dans la documentation
# USAGE: global_search
################################################################################
global_search() {
    read -p "Terme de recherche: " search_term
    
    if [[ -z "$search_term" ]]; then
        return 1
    fi
    
    show_header "Recherche Globale: '$search_term'"
    
    echo -e "${CYAN}Résultats:${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    local results_file=$(mktemp)
    
    # Rechercher dans les fichiers de documentation
    echo -e "\n${YELLOW}📚 Fichiers de documentation:${RESET}"
    grep -r -n "$search_term" "$DOTFILES_DIR"/*.md 2>/dev/null | while IFS=: read -r file line content; do
        echo "  ${CYAN}$(basename "$file")${RESET}:${GREEN}$line${RESET}: ${content#*:}"
    done
    
    # Rechercher dans les fonctions
    echo -e "\n${YELLOW}🔧 Fonctions:${RESET}"
    find "$DOTFILES_DIR/zsh/functions" -type f -name "*.sh" -o -name "*.zsh" | xargs grep -l "$search_term" 2>/dev/null | while read -r file; do
        local rel_path="${file#$DOTFILES_DIR/}"
        echo "  • $rel_path"
    done
    
    # Rechercher dans les scripts
    echo -e "\n${YELLOW}📦 Scripts:${RESET}"
    find "$DOTFILES_DIR/scripts" -type f -name "*.sh" | xargs grep -l "$search_term" 2>/dev/null | while read -r file; do
        local rel_path="${file#$DOTFILES_DIR/}"
        echo "  • $rel_path"
    done
    
    echo
    read -p "Appuyez sur Entrée pour continuer..."
}

################################################################################
# DESC: Affiche les statistiques du projet
# USAGE: show_project_statistics
################################################################################
show_project_statistics() {
    show_header "Statistiques du Projet"
    
    echo -e "${CYAN}📊 Statistiques Générales:${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    
    local total_files=$(find "$DOTFILES_DIR" -type f ! -path "*/.git/*" | wc -l)
    local total_scripts=$(find "$DOTFILES_DIR/scripts" -type f -name "*.sh" 2>/dev/null | wc -l)
    local total_functions=$(find "$DOTFILES_DIR/zsh/functions" -type f \( -name "*.sh" -o -name "*.zsh" \) 2>/dev/null | wc -l)
    local total_aliases=$(grep -c "^alias " "$ALIASES_FILE" 2>/dev/null || echo "0")
    
    echo "Total de fichiers: $total_files"
    echo "Total de scripts: $total_scripts"
    echo "Total de fonctions: $total_functions"
    echo "Total d'alias: $total_aliases"
    echo
    
    echo -e "${CYAN}📁 Structure par catégorie:${RESET}"
    echo "────────────────────────────────────────────────────────────────"
    for dir in scripts install config sync test uninstall lib; do
        if [[ -d "$DOTFILES_DIR/scripts/$dir" ]]; then
            local count=$(find "$DOTFILES_DIR/scripts/$dir" -type f -name "*.sh" 2>/dev/null | wc -l)
            echo "  $dir: $count scripts"
        fi
    done
}

################################################################################
# DESC: Menu principal
# USAGE: dotfiles_doc
################################################################################
dotfiles_doc() {
    while true; do
        show_main_menu
        read -p "Votre choix: " choice
        echo
        
        case "$choice" in
            1) menu_functions_doc ;;
            2) menu_aliases_doc ;;
            3) menu_scripts_doc ;;
            4) show_project_structure ;;
            5) show_doc_files ;;
            6) global_search ;;
            7) show_project_statistics ;;
            8)
                if [[ -f "$DOTFILES_DIR/scripts/lib/actions_logger.sh" ]]; then
                    source "$DOTFILES_DIR/scripts/lib/actions_logger.sh"
                    show_actions_log 50
                else
                    echo -e "${RED}❌ Actions logger non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            9)
                if [[ -f "$INSTALL_LOG_FILE" ]]; then
                    less -R "$INSTALL_LOG_FILE"
                else
                    echo -e "${RED}❌ install.log non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            10)
                echo "🔄 Génération de la documentation..."
                if [[ -f "$DOTFILES_DIR/scripts/lib/function_doc.sh" ]]; then
                    source "$DOTFILES_DIR/scripts/lib/function_doc.sh"
                    generate_all_function_docs
                fi
                echo "✅ Documentation générée"
                sleep 2
                ;;
            11)
                export_documentation
                ;;
            12)
                if [[ -f "$DOTFILES_DIR/docs/STRUCTURE.md" ]]; then
                    less -R "$DOTFILES_DIR/docs/STRUCTURE.md"
                else
                    echo -e "${RED}❌ STRUCTURE.md non trouvé${RESET}"
                    sleep 2
                fi
                ;;
            0)
                echo -e "${GREEN}Au revoir !${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

################################################################################
# DESC: Exporte la documentation en Markdown
# USAGE: export_documentation
################################################################################
export_documentation() {
    local export_file="$DOTFILES_DIR/DOCUMENTATION_COMPLETE.md"
    
    echo "📤 Export de la documentation vers $export_file..."
    
    {
        echo "# Documentation Complète des Dotfiles"
        echo ""
        echo "Généré le: $(date)"
        echo ""
        
        # Fonctions
        echo "## Fonctions"
        echo ""
        if [[ -f "$FUNCTION_DOC_FILE" ]] && command -v jq &>/dev/null; then
            jq -r '.[] | "### \(.name)\n\n**Description:** \(.description // "N/A")\n\n**Usage:** \(.usage // "N/A")\n\n**Exemples:** \(.examples // "N/A")\n\n"' "$FUNCTION_DOC_FILE"
        fi
        
        # Alias
        echo "## Alias"
        echo ""
        if [[ -f "$ALIASES_FILE" ]]; then
            grep "^alias " "$ALIASES_FILE" | sed 's/^alias /- /' >> "$export_file"
        fi
        
        # Scripts
        echo "## Scripts"
        echo ""
        find "$DOTFILES_DIR/scripts" -type f -name "*.sh" | sort | while read -r script; do
            echo "### $(basename "$script")"
            echo ""
            grep -m1 "^#.*Description:" "$script" 2>/dev/null | sed 's/^#.*Description:\?[[:space:]]*/**Description:** /'
            echo ""
        done
        
    } > "$export_file"
    
    echo "✅ Documentation exportée: $export_file"
    sleep 2
}

# Lancer le menu principal
dotfiles_doc

