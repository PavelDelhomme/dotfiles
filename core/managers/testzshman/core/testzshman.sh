#!/bin/sh
# =============================================================================
# TESTZSHMAN - Test Manager pour ZSH/Dotfiles (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire de tests pour ZSH et les dotfiles
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

# DESC: Gestionnaire de tests pour ZSH et dotfiles
# USAGE: testzshman [test-type] [options]
# EXAMPLE: testzshman
# EXAMPLE: testzshman managers
# EXAMPLE: testzshman functions
testzshman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    TESTZSHMAN_DIR="$DOTFILES_DIR/zsh/functions/testzshman"
    TESTZSHMAN_MODULES_DIR="$TESTZSHMAN_DIR/modules"
    TESTZSHMAN_UTILS_DIR="$TESTZSHMAN_DIR/utils"
    TESTZSHMAN_CONFIG_DIR="$TESTZSHMAN_DIR/config"
    
    # Créer les répertoires si nécessaire
    mkdir -p "$TESTZSHMAN_CONFIG_DIR"
    
    # Charger les utilitaires si disponibles
    if [ -d "$TESTZSHMAN_UTILS_DIR" ]; then
        for util_file in "$TESTZSHMAN_UTILS_DIR"/*.sh; do
            if [ -f "$util_file" ]; then
                . "$util_file" 2>/dev/null || true
            fi
        done
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              TESTZSHMAN - Test Manager ZSH/Dotfiles             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🧪 TESTS DISPONIBLES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "  1. 📦 Test des managers (*man)"
        echo "  2. 🔧 Test des fonctions ZSH"
        echo "  3. 📁 Test de la structure des dotfiles"
        echo "  4. ⚙️  Test de la configuration (zshrc, env, aliases)"
        echo "  5. 🔗 Test des symlinks"
        echo "  6. 📝 Test de la syntaxe ZSH"
        echo "  7. 🎓 Test de cyberlearn (modules, labs, progression)"
        echo "  8. 🚀 Test complet (tous les tests)"
        echo ""
        printf "${YELLOW}  0.${RESET} Quitter\n"
        echo ""
        printf "Choix: "
        read choice
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
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        if [ "$choice" != "0" ]; then
            echo ""
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }
    
    # Test des managers
    test_managers() {
        show_header
        printf "${CYAN}📦 Test des managers (*man)${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        managers="pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman fileman virtman sshman testzshman testman cyberlearn"
        
        success=0
        failed=0
        
        for manager in $managers; do
            if command -v "$manager" >/dev/null 2>&1; then
                printf "${GREEN}✓${RESET} %s est disponible\n" "$manager"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} %s n'est pas disponible\n" "$manager"
                failed=$((failed + 1))
            fi
        done
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} disponibles, ${RED}%d${RESET} manquants\n" "$success" "$failed"
    }
    
    # Test des fonctions ZSH
    test_functions() {
        show_header
        printf "${CYAN}🔧 Test des fonctions ZSH${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        functions_dir="$DOTFILES_DIR/zsh/functions"
        success=0
        failed=0
        
        # Tester quelques fonctions importantes
        test_functions_list="add_to_path load_manager"
        
        for func in $test_functions_list; do
            if command -v "$func" >/dev/null 2>&1; then
                printf "${GREEN}✓${RESET} Fonction %s disponible\n" "$func"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} Fonction %s non disponible\n" "$func"
                failed=$((failed + 1))
            fi
        done
        
        # Compter les fonctions chargées (approximatif)
        if [ "$SHELL_TYPE" = "zsh" ]; then
            total_functions=$(typeset -f 2>/dev/null | grep -c "^[a-zA-Z_][a-zA-Z0-9_]* ()" || echo "0")
        else
            total_functions=$(set | grep -c "^[a-zA-Z_][a-zA-Z0-9_]* ()" || echo "0")
        fi
        printf "${CYAN}ℹ️${RESET} Total de fonctions chargées: %s\n" "$total_functions"
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} fonctions testées, ${RED}%d${RESET} manquantes\n" "$success" "$failed"
    }
    
    # Test de la structure
    test_structure() {
        show_header
        printf "${CYAN}📁 Test de la structure des dotfiles${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        success=0
        failed=0
        
        required_dirs="$DOTFILES_DIR/zsh
$DOTFILES_DIR/zsh/functions
$DOTFILES_DIR/zsh/functions/installman
$DOTFILES_DIR/zsh/functions/configman
$DOTFILES_DIR/.config/moduleman"
        
        required_files="$DOTFILES_DIR/zsh/zshrc_custom
$DOTFILES_DIR/zsh/env.sh
$DOTFILES_DIR/zsh/aliases.zsh
$DOTFILES_DIR/Makefile"
        
        printf "${YELLOW}Vérification des répertoires:${RESET}\n"
        echo "$required_dirs" | while IFS= read -r dir; do
            if [ -d "$dir" ]; then
                printf "${GREEN}✓${RESET} %s\n" "$dir"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} %s manquant\n" "$dir"
                failed=$((failed + 1))
            fi
        done
        
        echo ""
        printf "${YELLOW}Vérification des fichiers:${RESET}\n"
        echo "$required_files" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                printf "${GREEN}✓${RESET} %s\n" "$file"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} %s manquant\n" "$file"
                failed=$((failed + 1))
            fi
        done
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} éléments OK, ${RED}%d${RESET} manquants\n" "$success" "$failed"
    }
    
    # Test de la configuration
    test_config() {
        show_header
        printf "${CYAN}⚙️  Test de la configuration${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        success=0
        failed=0
        
        # Test zshrc_custom
        if [ -f "$HOME/.zshrc" ] && (grep -q "zshrc_custom" "$HOME/.zshrc" 2>/dev/null || [ -L "$HOME/.zshrc" ]); then
            printf "${GREEN}✓${RESET} .zshrc configuré\n"
            success=$((success + 1))
        else
            printf "${RED}✗${RESET} .zshrc non configuré\n"
            failed=$((failed + 1))
        fi
        
        # Test variables d'environnement
        if [ -n "$DOTFILES_DIR" ]; then
            printf "${GREEN}✓${RESET} DOTFILES_DIR défini: %s\n" "$DOTFILES_DIR"
            success=$((success + 1))
        else
            printf "${RED}✗${RESET} DOTFILES_DIR non défini\n"
            failed=$((failed + 1))
        fi
        
        # Test PATH
        if [ -n "$PATH" ]; then
            path_length=$(echo "$PATH" | wc -c)
            printf "${GREEN}✓${RESET} PATH configuré (%d caractères)\n" "$path_length"
            success=$((success + 1))
        else
            printf "${RED}✗${RESET} PATH non configuré\n"
            failed=$((failed + 1))
        fi
        
        # Test modules.conf
        modules_conf="$DOTFILES_DIR/.config/moduleman/modules.conf"
        if [ ! -f "$modules_conf" ]; then
            modules_conf="$HOME/.config/moduleman/modules.conf"
        fi
        if [ -f "$modules_conf" ]; then
            printf "${GREEN}✓${RESET} modules.conf trouvé: %s\n" "$modules_conf"
            success=$((success + 1))
        else
            printf "${YELLOW}⚠️${RESET} modules.conf non trouvé (sera créé automatiquement)\n"
        fi
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} éléments OK, ${RED}%d${RESET} problèmes\n" "$success" "$failed"
    }
    
    # Test des symlinks
    test_symlinks() {
        show_header
        printf "${CYAN}🔗 Test des symlinks${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        success=0
        failed=0
        
        symlinks="$HOME/.zshrc:$DOTFILES_DIR/zshrc
$HOME/.gitconfig:$DOTFILES_DIR/.gitconfig
$HOME/.p10k.zsh:$DOTFILES_DIR/.p10k.zsh"
        
        echo "$symlinks" | while IFS=: read -r symlink target; do
            if [ -L "$symlink" ]; then
                actual_target=$(readlink "$symlink")
                if [ "$actual_target" = "$target" ] || [ "$actual_target" = "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
                    printf "${GREEN}✓${RESET} %s → %s\n" "$symlink" "$actual_target"
                    success=$((success + 1))
                else
                    printf "${YELLOW}⚠️${RESET} %s pointe vers: %s (attendu: %s)\n" "$symlink" "$actual_target" "$target"
                fi
            elif [ -f "$symlink" ]; then
                printf "${YELLOW}⚠️${RESET} %s existe mais n'est pas un symlink\n" "$symlink"
            else
                printf "${RED}✗${RESET} %s manquant\n" "$symlink"
                failed=$((failed + 1))
            fi
        done
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} symlinks OK, ${RED}%d${RESET} manquants\n" "$success" "$failed"
    }
    
    # Test de la syntaxe ZSH
    test_syntax() {
        show_header
        printf "${CYAN}📝 Test de la syntaxe ZSH${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        success=0
        failed=0
        
        files_to_test="$DOTFILES_DIR/zsh/zshrc_custom
$DOTFILES_DIR/zsh/env.sh
$DOTFILES_DIR/zsh/aliases.zsh"
        
        echo "$files_to_test" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                if command -v zsh >/dev/null 2>&1 && zsh -n "$file" 2>/dev/null; then
                    printf "${GREEN}✓${RESET} %s (syntaxe OK)\n" "$file"
                    success=$((success + 1))
                else
                    printf "${RED}✗${RESET} %s (erreur de syntaxe)\n" "$file"
                    if command -v zsh >/dev/null 2>&1; then
                        zsh -n "$file" 2>&1 | head -3
                    fi
                    failed=$((failed + 1))
                fi
            fi
        done
        
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} fichiers OK, ${RED}%d${RESET} erreurs\n" "$success" "$failed"
    }
    
    # Test de cyberlearn (simplifié)
    test_cyberlearn() {
        show_header
        printf "${CYAN}🎓 Test de cyberlearn${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        success=0
        failed=0
        warning=0
        
        # Test 1: cyberlearn disponible
        printf "${YELLOW}1. Vérification de la commande cyberlearn:${RESET}\n"
        if command -v cyberlearn >/dev/null 2>&1; then
            printf "${GREEN}✓${RESET} cyberlearn est disponible\n"
            success=$((success + 1))
        else
            printf "${RED}✗${RESET} cyberlearn n'est pas disponible\n"
            failed=$((failed + 1))
        fi
        
        # Test 2: Structure des répertoires
        echo ""
        printf "${YELLOW}2. Vérification de la structure:${RESET}\n"
        cyberlearn_dir="$DOTFILES_DIR/zsh/functions/cyberlearn"
        required_dirs="$cyberlearn_dir
$cyberlearn_dir/modules
$cyberlearn_dir/modules/basics
$cyberlearn_dir/modules/network
$cyberlearn_dir/modules/web
$cyberlearn_dir/utils
$cyberlearn_dir/labs"
        
        echo "$required_dirs" | while IFS= read -r dir; do
            if [ -d "$dir" ]; then
                printf "${GREEN}✓${RESET} %s\n" "$dir"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} %s manquant\n" "$dir"
                failed=$((failed + 1))
            fi
        done
        
        # Test 3: Modules disponibles
        echo ""
        printf "${YELLOW}3. Vérification des modules:${RESET}\n"
        modules="basics network web crypto linux windows mobile forensics pentest incident"
        modules_found=0
        
        for module in $modules; do
            module_file="$cyberlearn_dir/modules/$module/module.zsh"
            if [ -f "$module_file" ]; then
                printf "${GREEN}✓${RESET} Module %s disponible\n" "$module"
                modules_found=$((modules_found + 1))
                success=$((success + 1))
            else
                printf "${YELLOW}⚠️${RESET} Module %s non implémenté\n" "$module"
                warning=$((warning + 1))
            fi
        done
        printf "${CYAN}ℹ️${RESET} Modules implémentés: %d\n" "$modules_found"
        
        # Test 4: Utilitaires
        echo ""
        printf "${YELLOW}4. Vérification des utilitaires:${RESET}\n"
        utils="progress.sh labs.sh validator.sh"
        for util in $utils; do
            util_file="$cyberlearn_dir/utils/$util"
            if [ -f "$util_file" ]; then
                printf "${GREEN}✓${RESET} %s\n" "$util"
                success=$((success + 1))
            else
                printf "${RED}✗${RESET} %s manquant\n" "$util"
                failed=$((failed + 1))
            fi
        done
        
        # Test 5: Système de progression
        echo ""
        printf "${YELLOW}5. Vérification du système de progression:${RESET}\n"
        progress_dir="$HOME/.cyberlearn"
        if [ -d "$progress_dir" ]; then
            printf "${GREEN}✓${RESET} Répertoire de progression: %s\n" "$progress_dir"
            success=$((success + 1))
            
            # Vérifier si jq est installé
            if command -v jq >/dev/null 2>&1; then
                printf "${GREEN}✓${RESET} jq installé (pour la progression JSON)\n"
                success=$((success + 1))
            else
                printf "${YELLOW}⚠️${RESET} jq non installé (recommandé pour la progression)\n"
                warning=$((warning + 1))
            fi
        else
            printf "${YELLOW}⚠️${RESET} Répertoire de progression non créé (sera créé au premier lancement)\n"
            warning=$((warning + 1))
        fi
        
        # Test 6: Labs Docker
        echo ""
        printf "${YELLOW}6. Vérification des labs Docker:${RESET}\n"
        if command -v docker >/dev/null 2>&1; then
            printf "${GREEN}✓${RESET} Docker installé\n"
            success=$((success + 1))
            
            # Vérifier si Docker est en cours d'exécution
            if docker info >/dev/null 2>&1; then
                printf "${GREEN}✓${RESET} Docker est en cours d'exécution\n"
                success=$((success + 1))
                
                # Vérifier les labs actifs
                active_labs=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -c '^cyberlearn-' || echo "0")
                if [ "$active_labs" -gt 0 ]; then
                    printf "${CYAN}ℹ️${RESET} Labs actifs: %d\n" "$active_labs"
                    docker ps --format '  - {{.Names}} ({{.Status}})' 2>/dev/null | grep '^  - cyberlearn-' || true
                else
                    printf "${CYAN}ℹ️${RESET} Aucun lab actif\n"
                fi
            else
                printf "${YELLOW}⚠️${RESET} Docker installé mais non démarré\n"
                warning=$((warning + 1))
            fi
        else
            printf "${YELLOW}⚠️${RESET} Docker non installé (requis pour les labs)\n"
            printf "${CYAN}💡${RESET} Installez Docker avec: installman docker\n"
            warning=$((warning + 1))
        fi
        
        # Résumé
        echo ""
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Résumé: ${GREEN}%d${RESET} tests réussis, ${RED}%d${RESET} échecs, ${YELLOW}%d${RESET} avertissements\n" "$success" "$failed" "$warning"
        
        # Recommandations
        if [ "$failed" -eq 0 ] && [ "$warning" -gt 0 ]; then
            echo ""
            printf "${CYAN}💡 Recommandations:${RESET}\n"
            if ! command -v docker >/dev/null 2>&1; then
                echo "  • Installez Docker pour utiliser les labs: installman docker"
            fi
            if ! command -v jq >/dev/null 2>&1; then
                echo "  • Installez jq pour la progression: sudo pacman -S jq (ou apt/dnf)"
            fi
        fi
    }
    
    # Test complet
    test_all() {
        show_header
        printf "${CYAN}🚀 Test complet${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        printf "${YELLOW}Exécution de tous les tests...${RESET}\n\n"
        
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
        printf "${GREEN}${BOLD}✅ Tests complets terminés!${RESET}\n"
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
            help|--help|-h)
                echo "🧪 TESTZSHMAN - Test Manager ZSH/Dotfiles"
                echo ""
                echo "Usage: testzshman [test-type]"
                echo ""
                echo "Tests disponibles:"
                echo "  managers   - Test des managers"
                echo "  functions  - Test des fonctions"
                echo "  structure  - Test de la structure"
                echo "  config     - Test de la configuration"
                echo "  symlinks   - Test des symlinks"
                echo "  syntax     - Test de la syntaxe"
                echo "  cyberlearn - Test de cyberlearn"
                echo "  all        - Tous les tests"
                echo ""
                echo "Sans argument: menu interactif"
                ;;
            *)
                printf "${RED}Test inconnu: %s${RESET}\n" "$1"
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
