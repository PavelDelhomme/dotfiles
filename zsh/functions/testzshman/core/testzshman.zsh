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
        echo "  7. 🚀 Test complet (tous les tests)"
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
            "virtman" "sshman" "testzshman" "testman"
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

