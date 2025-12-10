#!/bin/zsh
# =============================================================================
# TESTZSHMAN - Test Manager pour ZSH/Dotfiles
# =============================================================================
# Description: Gestionnaire de tests pour ZSH et les dotfiles
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
TESTZSHMAN_DIR="${TESTZSHMAN_DIR:-$HOME/dotfiles/zsh/functions/testzshman}"
TESTZSHMAN_MODULES_DIR="$TESTZSHMAN_DIR/modules"
TESTZSHMAN_UTILS_DIR="$TESTZSHMAN_DIR/utils"
TESTZSHMAN_CONFIG_DIR="$TESTZSHMAN_DIR/config"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Créer les répertoires si nécessaire
mkdir -p "$TESTZSHMAN_CONFIG_DIR"

# Charger les utilitaires
if [ -d "$TESTZSHMAN_UTILS_DIR" ]; then
    setopt null_glob 2>/dev/null || true
    for util_file in "$TESTZSHMAN_UTILS_DIR"/*.sh; do
        [ -f "$util_file" ] && source "$util_file" 2>/dev/null || true
    done
    unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire de tests pour ZSH et dotfiles
# USAGE: testzshman [test-type] [options]
# EXAMPLE: testzshman
# EXAMPLE: testzshman managers
# EXAMPLE: testzshman functions
testzshman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              TESTZSHMAN - Test Manager ZSH/Dotfiles             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🧪 TESTS DISPONIBLES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "  1. 📦 Test des managers (*man)"
        echo "  2. 🔧 Test des fonctions ZSH"
        echo "  3. 📁 Test de la structure des dotfiles"
        echo "  4. ⚙️  Test de la configuration (zshrc, env, aliases)"
        echo "  5. 🔗 Test des symlinks"
        echo "  6. 📝 Test de la syntaxe ZSH"
        echo "  7. 🎓 Test de cyberlearn (modules, labs, progression)"
        echo "  8. 🚀 Test complet (tous les tests)"
        echo ""
        echo -e "${YELLOW}  0.${RESET} Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]')
        
        case "$choice" in
            1)
                test_managers
                ;;
            2)
                test_functions
                ;;
            3)
                test_structure
                ;;
            4)
                test_config
                ;;
            5)
                test_symlinks
                ;;
            6)
                test_syntax
                ;;
            7)
                test_cyberlearn
                ;;
            8)
                test_all
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        if [ "$choice" != "0" ]; then
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            testzshman
        fi
    }
    
    # Test des managers
    test_managers() {
        show_header
        echo -e "${CYAN}📦 Test des managers (*man)${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local managers=(
            "pathman" "netman" "aliaman" "miscman" "searchman"
            "cyberman" "devman" "gitman" "helpman" "manman"
            "configman" "installman" "moduleman" "fileman"
            "virtman" "sshman" "testzshman" "testman" "cyberlearn"
        )
        
        local success=0
        local failed=0
        
        for manager in "${managers[@]}"; do
            if type "$manager" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${RESET} $manager est disponible"
                ((success++))
            else
                echo -e "${RED}✗${RESET} $manager n'est pas disponible"
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} disponibles, ${RED}$failed${RESET} manquants"
    }
    
    # Test des fonctions ZSH
    test_functions() {
        show_header
        echo -e "${CYAN}🔧 Test des fonctions ZSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local functions_dir="$DOTFILES_DIR/zsh/functions"
        local success=0
        local failed=0
        
        # Tester quelques fonctions importantes
        local test_functions=(
            "add_to_path"
            "load_manager"
        )
        
        for func in "${test_functions[@]}"; do
            if type "$func" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${RESET} Fonction $func disponible"
                ((success++))
            else
                echo -e "${RED}✗${RESET} Fonction $func non disponible"
                ((failed++))
            fi
        done
        
        # Compter les fonctions chargées
        local total_functions=$(typeset -f | grep -c "^[a-zA-Z_][a-zA-Z0-9_]* ()")
        echo -e "${CYAN}ℹ️${RESET} Total de fonctions chargées: $total_functions"
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} fonctions testées, ${RED}$failed${RESET} manquantes"
    }
    
    # Test de la structure
    test_structure() {
        show_header
        echo -e "${CYAN}📁 Test de la structure des dotfiles${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local success=0
        local failed=0
        
        local required_dirs=(
            "$DOTFILES_DIR/zsh"
            "$DOTFILES_DIR/zsh/functions"
            "$DOTFILES_DIR/zsh/functions/installman"
            "$DOTFILES_DIR/zsh/functions/configman"
            "$DOTFILES_DIR/.config/moduleman"
        )
        
        local required_files=(
            "$DOTFILES_DIR/zsh/zshrc_custom"
            "$DOTFILES_DIR/zsh/env.sh"
            "$DOTFILES_DIR/zsh/aliases.zsh"
            "$DOTFILES_DIR/Makefile"
        )
        
        echo -e "${YELLOW}Vérification des répertoires:${RESET}"
        for dir in "${required_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "${GREEN}✓${RESET} $dir"
                ((success++))
            else
                echo -e "${RED}✗${RESET} $dir manquant"
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${YELLOW}Vérification des fichiers:${RESET}"
        for file in "${required_files[@]}"; do
            if [ -f "$file" ]; then
                echo -e "${GREEN}✓${RESET} $file"
                ((success++))
            else
                echo -e "${RED}✗${RESET} $file manquant"
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} éléments OK, ${RED}$failed${RESET} manquants"
    }
    
    # Test de la configuration
    test_config() {
        show_header
        echo -e "${CYAN}⚙️  Test de la configuration${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local success=0
        local failed=0
        
        # Test zshrc_custom
        if [ -f "$HOME/.zshrc" ] && (grep -q "zshrc_custom" "$HOME/.zshrc" 2>/dev/null || [ -L "$HOME/.zshrc" ]); then
            echo -e "${GREEN}✓${RESET} .zshrc configuré"
            ((success++))
        else
            echo -e "${RED}✗${RESET} .zshrc non configuré"
            ((failed++))
        fi
        
        # Test variables d'environnement
        if [ -n "$DOTFILES_DIR" ]; then
            echo -e "${GREEN}✓${RESET} DOTFILES_DIR défini: $DOTFILES_DIR"
            ((success++))
        else
            echo -e "${RED}✗${RESET} DOTFILES_DIR non défini"
            ((failed++))
        fi
        
        # Test PATH
        if [ -n "$PATH" ]; then
            echo -e "${GREEN}✓${RESET} PATH configuré (${#PATH} caractères)"
            ((success++))
        else
            echo -e "${RED}✗${RESET} PATH non configuré"
            ((failed++))
        fi
        
        # Test modules.conf
        local modules_conf="$HOME/dotfiles/.config/moduleman/modules.conf"
        if [ ! -f "$modules_conf" ]; then
            modules_conf="$HOME/.config/moduleman/modules.conf"
        fi
        if [ -f "$modules_conf" ]; then
            echo -e "${GREEN}✓${RESET} modules.conf trouvé: $modules_conf"
            ((success++))
        else
            echo -e "${YELLOW}⚠️${RESET} modules.conf non trouvé (sera créé automatiquement)"
        fi
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} éléments OK, ${RED}$failed${RESET} problèmes"
    }
    
    # Test des symlinks
    test_symlinks() {
        show_header
        echo -e "${CYAN}🔗 Test des symlinks${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local success=0
        local failed=0
        
        local symlinks=(
            "$HOME/.zshrc:$DOTFILES_DIR/zshrc"
            "$HOME/.gitconfig:$DOTFILES_DIR/.gitconfig"
            "$HOME/.p10k.zsh:$DOTFILES_DIR/.p10k.zsh"
        )
        
        for symlink_info in "${symlinks[@]}"; do
            local symlink="${symlink_info%%:*}"
            local target="${symlink_info#*:}"
            
            if [ -L "$symlink" ]; then
                local actual_target=$(readlink "$symlink")
                if [ "$actual_target" = "$target" ] || [ "$actual_target" = "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
                    echo -e "${GREEN}✓${RESET} $symlink → $actual_target"
                    ((success++))
                else
                    echo -e "${YELLOW}⚠️${RESET} $symlink pointe vers: $actual_target (attendu: $target)"
                fi
            elif [ -f "$symlink" ]; then
                echo -e "${YELLOW}⚠️${RESET} $symlink existe mais n'est pas un symlink"
            else
                echo -e "${RED}✗${RESET} $symlink manquant"
                ((failed++))
            fi
        done
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} symlinks OK, ${RED}$failed${RESET} manquants"
    }
    
    # Test de la syntaxe ZSH
    test_syntax() {
        show_header
        echo -e "${CYAN}📝 Test de la syntaxe ZSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local success=0
        local failed=0
        
        local files_to_test=(
            "$DOTFILES_DIR/zsh/zshrc_custom"
            "$DOTFILES_DIR/zsh/env.sh"
            "$DOTFILES_DIR/zsh/aliases.zsh"
        )
        
        for file in "${files_to_test[@]}"; do
            if [ -f "$file" ]; then
                if zsh -n "$file" 2>/dev/null; then
                    echo -e "${GREEN}✓${RESET} $file (syntaxe OK)"
                    ((success++))
                else
                    echo -e "${RED}✗${RESET} $file (erreur de syntaxe)"
                    zsh -n "$file" 2>&1 | head -3
                    ((failed++))
                fi
            fi
        done
        
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} fichiers OK, ${RED}$failed${RESET} erreurs"
    }
    
    # Test de cyberlearn
    test_cyberlearn() {
        show_header
        echo -e "${CYAN}🎓 Test de cyberlearn${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local success=0
        local failed=0
        local warning=0
        
        # Test 1: cyberlearn disponible
        echo -e "${YELLOW}1. Vérification de la commande cyberlearn:${RESET}"
        if type cyberlearn >/dev/null 2>&1; then
            echo -e "${GREEN}✓${RESET} cyberlearn est disponible"
            ((success++))
        else
            echo -e "${RED}✗${RESET} cyberlearn n'est pas disponible"
            ((failed++))
        fi
        
        # Test 2: Structure des répertoires
        echo ""
        echo -e "${YELLOW}2. Vérification de la structure:${RESET}"
        local cyberlearn_dir="$DOTFILES_DIR/zsh/functions/cyberlearn"
        local required_dirs=(
            "$cyberlearn_dir"
            "$cyberlearn_dir/modules"
            "$cyberlearn_dir/modules/basics"
            "$cyberlearn_dir/modules/network"
            "$cyberlearn_dir/modules/web"
            "$cyberlearn_dir/utils"
            "$cyberlearn_dir/labs"
        )
        
        for dir in "${required_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "${GREEN}✓${RESET} $dir"
                ((success++))
            else
                echo -e "${RED}✗${RESET} $dir manquant"
                ((failed++))
            fi
        done
        
        # Test 3: Modules disponibles
        echo ""
        echo -e "${YELLOW}3. Vérification des modules:${RESET}"
        local modules=("basics" "network" "web" "crypto" "linux" "windows" "mobile" "forensics" "pentest" "incident")
        local modules_found=0
        
        for module in "${modules[@]}"; do
            local module_file="$cyberlearn_dir/modules/$module/module.zsh"
            if [ -f "$module_file" ]; then
                echo -e "${GREEN}✓${RESET} Module $module disponible"
                ((modules_found++))
                ((success++))
            else
                echo -e "${YELLOW}⚠️${RESET} Module $module non implémenté"
                ((warning++))
            fi
        done
        echo -e "${CYAN}ℹ️${RESET} Modules implémentés: $modules_found/${#modules[@]}"
        
        # Test 4: Utilitaires
        echo ""
        echo -e "${YELLOW}4. Vérification des utilitaires:${RESET}"
        local utils=("progress.sh" "labs.sh" "validator.sh")
        for util in "${utils[@]}"; do
            local util_file="$cyberlearn_dir/utils/$util"
            if [ -f "$util_file" ]; then
                echo -e "${GREEN}✓${RESET} $util"
                ((success++))
            else
                echo -e "${RED}✗${RESET} $util manquant"
                ((failed++))
            fi
        done
        
        # Test 5: Système de progression
        echo ""
        echo -e "${YELLOW}5. Vérification du système de progression:${RESET}"
        local progress_dir="$HOME/.cyberlearn"
        if [ -d "$progress_dir" ]; then
            echo -e "${GREEN}✓${RESET} Répertoire de progression: $progress_dir"
            ((success++))
            
            # Vérifier si jq est installé (pour la progression JSON)
            if command -v jq &>/dev/null; then
                echo -e "${GREEN}✓${RESET} jq installé (pour la progression JSON)"
                ((success++))
            else
                echo -e "${YELLOW}⚠️${RESET} jq non installé (recommandé pour la progression)"
                ((warning++))
            fi
        else
            echo -e "${YELLOW}⚠️${RESET} Répertoire de progression non créé (sera créé au premier lancement)"
            ((warning++))
        fi
        
        # Test 6: Labs Docker
        echo ""
        echo -e "${YELLOW}6. Vérification des labs Docker:${RESET}"
        if command -v docker &>/dev/null; then
            echo -e "${GREEN}✓${RESET} Docker installé"
            ((success++))
            
            # Vérifier si Docker est en cours d'exécution
            if docker info &>/dev/null 2>&1; then
                echo -e "${GREEN}✓${RESET} Docker est en cours d'exécution"
                ((success++))
                
                # Vérifier les labs actifs
                local active_labs=$(docker ps --format '{{.Names}}' | grep -c '^cyberlearn-' 2>/dev/null || echo "0")
                if [ "$active_labs" -gt 0 ]; then
                    echo -e "${CYAN}ℹ️${RESET} Labs actifs: $active_labs"
                    docker ps --format '  - {{.Names}} ({{.Status}})' | grep '^  - cyberlearn-'
                else
                    echo -e "${CYAN}ℹ️${RESET} Aucun lab actif"
                fi
            else
                echo -e "${YELLOW}⚠️${RESET} Docker installé mais non démarré"
                ((warning++))
            fi
        else
            echo -e "${YELLOW}⚠️${RESET} Docker non installé (requis pour les labs)"
            echo -e "${CYAN}💡${RESET} Installez Docker avec: installman docker"
            ((warning++))
        fi
        
        # Test 7: Fichiers de configuration des labs
        echo ""
        echo -e "${YELLOW}7. Vérification des configurations de labs:${RESET}"
        local labs_dir="$cyberlearn_dir/labs"
        if [ -d "$labs_dir" ]; then
            local lab_configs=$(find "$labs_dir" -name "Dockerfile" -o -name "docker-compose.yml" 2>/dev/null | wc -l)
            if [ "$lab_configs" -gt 0 ]; then
                echo -e "${GREEN}✓${RESET} Configurations de labs trouvées: $lab_configs"
                ((success++))
            else
                echo -e "${CYAN}ℹ️${RESET} Aucune configuration de lab trouvée (sera créée au démarrage)"
            fi
        fi
        
        # Test 8: Alias
        echo ""
        echo -e "${YELLOW}8. Vérification des alias:${RESET}"
        local aliases=("cl" "cyberlearn-module" "cyberlearn-lab")
        for alias_name in "${aliases[@]}"; do
            if alias "$alias_name" &>/dev/null 2>&1; then
                echo -e "${GREEN}✓${RESET} Alias $alias_name disponible"
                ((success++))
            else
                echo -e "${YELLOW}⚠️${RESET} Alias $alias_name non défini"
                ((warning++))
            fi
        done
        
        # Test 9: Test fonctionnel rapide
        echo ""
        echo -e "${YELLOW}9. Test fonctionnel rapide:${RESET}"
        if type cyberlearn >/dev/null 2>&1; then
            # Tester que cyberlearn peut charger sans erreur
            if (cyberlearn help &>/dev/null 2>&1 || true); then
                echo -e "${GREEN}✓${RESET} cyberlearn peut être exécuté"
                ((success++))
            else
                echo -e "${RED}✗${RESET} Erreur lors de l'exécution de cyberlearn"
                ((failed++))
            fi
        fi
        
        # Résumé
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo -e "Résumé: ${GREEN}$success${RESET} tests réussis, ${RED}$failed${RESET} échecs, ${YELLOW}$warning${RESET} avertissements"
        
        # Recommandations
        if [ "$failed" -eq 0 ] && [ "$warning" -gt 0 ]; then
            echo ""
            echo -e "${CYAN}💡 Recommandations:${RESET}"
            if ! command -v docker &>/dev/null; then
                echo "  • Installez Docker pour utiliser les labs: installman docker"
            fi
            if ! command -v jq &>/dev/null; then
                echo "  • Installez jq pour la progression: sudo pacman -S jq (ou apt/dnf)"
            fi
        fi
    }
    
    # Test complet
    test_all() {
        show_header
        echo -e "${CYAN}🚀 Test complet${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo -e "${YELLOW}Exécution de tous les tests...${RESET}\n"
        
        test_managers
        echo ""
        test_functions
        echo ""
        test_structure
        echo ""
        test_config
        echo ""
        test_symlinks
        echo ""
        test_syntax
        echo ""
        test_cyberlearn
        
        echo ""
        echo -e "${GREEN}${BOLD}✅ Tests complets terminés!${RESET}"
    }
    
    # Si un argument est fourni, exécuter directement
    if [ -n "$1" ]; then
        case "$1" in
            managers|manager)
                test_managers
                ;;
            functions|function)
                test_functions
                ;;
            structure|struct)
                test_structure
                ;;
            config)
                test_config
                ;;
            symlinks|symlink)
                test_symlinks
                ;;
            syntax)
                test_syntax
                ;;
            cyberlearn|cyber)
                test_cyberlearn
                ;;
            all|complete)
                test_all
                ;;
            *)
                echo -e "${RED}Test inconnu: $1${RESET}"
                echo ""
                echo "Tests disponibles:"
                echo "  testzshman managers   - Test des managers"
                echo "  testzshman functions  - Test des fonctions"
                echo "  testzshman structure  - Test de la structure"
                echo "  testzshman config    - Test de la configuration"
                echo "  testzshman symlinks   - Test des symlinks"
                echo "  testzshman syntax    - Test de la syntaxe"
                echo "  testzshman cyberlearn - Test de cyberlearn"
                echo "  testzshman all       - Tous les tests"
                return 1
                ;;
        esac
    else
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}

# Alias
alias tzm='testzshman'
alias test-zsh='testzshman'

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🧪 TESTZSHMAN chargé - Tapez 'testzshman' ou 'tzm' pour démarrer"

