#!/bin/zsh
# =============================================================================
# TESTMAN - Test Manager pour Applications
# =============================================================================
# Description: Gestionnaire de tests pour applications (tous langages)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
TESTMAN_DIR="${TESTMAN_DIR:-$HOME/dotfiles/zsh/functions/testman}"
TESTMAN_MODULES_DIR="$TESTMAN_DIR/modules"
TESTMAN_UTILS_DIR="$TESTMAN_DIR/utils"
TESTMAN_CONFIG_DIR="$TESTMAN_DIR/config"

# Créer les répertoires si nécessaire
mkdir -p "$TESTMAN_CONFIG_DIR"

# Charger les utilitaires
if [ -d "$TESTMAN_UTILS_DIR" ]; then
    setopt null_glob 2>/dev/null || true
    for util_file in "$TESTMAN_UTILS_DIR"/*.sh; do
        [ -f "$util_file" ] && source "$util_file" 2>/dev/null || true
    done
    unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire de tests pour applications (tous langages)
# USAGE: testman [langage] [test-type] [options]
# EXAMPLE: testman
# EXAMPLE: testman python
# EXAMPLE: testman node unit
# EXAMPLE: testman rust
testman() {
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
        echo "║              TESTMAN - Test Manager Applications                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour détecter le langage du projet
    detect_language() {
        local dir="${1:-.}"
        
        if [ -f "$dir/package.json" ]; then
            echo "node"
        elif [ -f "$dir/PyProject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/requirements.txt" ]; then
            echo "python"
        elif [ -f "$dir/Cargo.toml" ]; then
            echo "rust"
        elif [ -f "$dir/go.mod" ]; then
            echo "go"
        elif [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ]; then
            echo "java"
        elif [ -f "$dir/pubspec.yaml" ]; then
            echo "flutter"
        elif [ -f "$dir/Gemfile" ]; then
            echo "ruby"
        elif [ -f "$dir/composer.json" ]; then
            echo "php"
        else
            echo "unknown"
        fi
    }
    
    # Test Python
    test_python() {
        local test_type="${1:-all}"
        
        echo -e "${CYAN}🐍 Tests Python${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        # Détecter le framework de test
        if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null; then
            echo -e "${YELLOW}Framework détecté: pytest${RESET}\n"
            case "$test_type" in
                unit|u)
                    python -m pytest tests/unit/ -v || python -m pytest test/unit/ -v
                    ;;
                integration|i)
                    python -m pytest tests/integration/ -v || python -m pytest test/integration/ -v
                    ;;
                all|*)
                    python -m pytest tests/ -v || python -m pytest test/ -v || python -m pytest -v
                    ;;
            esac
        elif [ -f "setup.py" ] && grep -q "unittest" setup.py 2>/dev/null; then
            echo -e "${YELLOW}Framework détecté: unittest${RESET}\n"
            python -m unittest discover -v
        elif [ -f "manage.py" ]; then
            echo -e "${YELLOW}Framework détecté: Django${RESET}\n"
            python manage.py test
        else
            echo -e "${YELLOW}Aucun framework détecté, recherche de tests...${RESET}\n"
            python -m pytest tests/ -v 2>/dev/null || \
            python -m pytest test/ -v 2>/dev/null || \
            python -m unittest discover -v 2>/dev/null || \
            echo -e "${RED}✗ Aucun test trouvé${RESET}"
        fi
    }
    
    # Test Node.js
    test_node() {
        local test_type="${1:-all}"
        
        echo -e "${CYAN}📦 Tests Node.js${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "package.json" ]; then
            # Vérifier les scripts de test
            if grep -q '"test"' package.json; then
                case "$test_type" in
                    unit|u)
                        npm test -- --testPathPattern=unit || npm run test:unit || npm test
                        ;;
                    integration|i)
                        npm test -- --testPathPattern=integration || npm run test:integration
                        ;;
                    watch|w)
                        npm test -- --watch || npm run test:watch
                        ;;
                    all|*)
                        npm test
                        ;;
                esac
            else
                echo -e "${YELLOW}Script 'test' non trouvé dans package.json${RESET}"
                echo -e "${YELLOW}Exécution de npm test par défaut...${RESET}\n"
                npm test
            fi
        else
            echo -e "${RED}✗ package.json non trouvé${RESET}"
        fi
    }
    
    # Test Rust
    test_rust() {
        echo -e "${CYAN}🦀 Tests Rust${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "Cargo.toml" ]; then
            cargo test
        else
            echo -e "${RED}✗ Cargo.toml non trouvé${RESET}"
        fi
    }
    
    # Test Go
    test_go() {
        echo -e "${CYAN}🐹 Tests Go${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "go.mod" ] || [ -d ".git" ]; then
            go test ./... -v
        else
            echo -e "${RED}✗ Projet Go non détecté${RESET}"
        fi
    }
    
    # Test Java
    test_java() {
        echo -e "${CYAN}☕ Tests Java${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "pom.xml" ]; then
            echo -e "${YELLOW}Framework détecté: Maven${RESET}\n"
            mvn test
        elif [ -f "build.gradle" ]; then
            echo -e "${YELLOW}Framework détecté: Gradle${RESET}\n"
            ./gradlew test || gradle test
        else
            echo -e "${RED}✗ Projet Java non détecté (Maven/Gradle)${RESET}"
        fi
    }
    
    # Test Flutter
    test_flutter() {
        echo -e "${CYAN}🎯 Tests Flutter${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "pubspec.yaml" ]; then
            flutter test
        else
            echo -e "${RED}✗ pubspec.yaml non trouvé${RESET}"
        fi
    }
    
    # Test Ruby
    test_ruby() {
        echo -e "${CYAN}💎 Tests Ruby${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "Gemfile" ]; then
            if [ -f "Rakefile" ] && grep -q "test" Rakefile 2>/dev/null; then
                bundle exec rake test
            else
                bundle exec rspec 2>/dev/null || bundle exec minitest 2>/dev/null || echo -e "${RED}✗ Aucun framework de test détecté${RESET}"
            fi
        else
            echo -e "${RED}✗ Gemfile non trouvé${RESET}"
        fi
    }
    
    # Test PHP
    test_php() {
        echo -e "${CYAN}🐘 Tests PHP${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if [ -f "composer.json" ]; then
            if grep -q "phpunit" composer.json 2>/dev/null; then
                vendor/bin/phpunit
            elif [ -f "phpunit.xml" ]; then
                phpunit
            else
                echo -e "${YELLOW}Aucun framework de test détecté${RESET}"
            fi
        else
            echo -e "${RED}✗ composer.json non trouvé${RESET}"
        fi
    }
    
    # Menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🧪 LANGAGES SUPPORTÉS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        local lang=$(detect_language)
        if [ "$lang" != "unknown" ]; then
            echo -e "${GREEN}✓ Langage détecté: $lang${RESET}\n"
        fi
        
        echo "  1. 🐍 Python (pytest, unittest, Django)"
        echo "  2. 📦 Node.js (npm, jest, mocha)"
        echo "  3. 🦀 Rust (cargo test)"
        echo "  4. 🐹 Go (go test)"
        echo "  5. ☕ Java (Maven, Gradle)"
        echo "  6. 🎯 Flutter (flutter test)"
        echo "  7. 💎 Ruby (RSpec, Minitest)"
        echo "  8. 🐘 PHP (PHPUnit)"
        echo "  9. 🔍 Détecter automatiquement le langage"
        echo ""
        echo -e "${YELLOW}  0.${RESET} Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]')
        
        case "$choice" in
            1)
                test_python
                ;;
            2)
                test_node
                ;;
            3)
                test_rust
                ;;
            4)
                test_go
                ;;
            5)
                test_java
                ;;
            6)
                test_flutter
                ;;
            7)
                test_ruby
                ;;
            8)
                test_php
                ;;
            9)
                local detected=$(detect_language)
                if [ "$detected" != "unknown" ]; then
                    echo -e "${GREEN}Langage détecté: $detected${RESET}\n"
                    "test_${detected}"
                else
                    echo -e "${RED}✗ Impossible de détecter le langage${RESET}"
                    echo -e "${YELLOW}Choisissez manuellement un langage${RESET}"
                fi
                ;;
            0)
                echo -e "${GREEN}Au revoir!${RESET}"
                return 0
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action (sauf si choix 0)
        if [ "$choice" != "0" ]; then
            echo ""
            read -k 1 "?Appuyez sur une touche pour continuer... "
            testman
        fi
    }
    
    # Si des arguments sont fournis, exécuter directement
    if [ -n "$1" ]; then
        case "$1" in
            python|py)
                test_python "$2"
                ;;
            node|js|npm)
                test_node "$2"
                ;;
            rust|rs)
                test_rust
                ;;
            go|golang)
                test_go
                ;;
            java)
                test_java
                ;;
            flutter|dart)
                test_flutter
                ;;
            ruby|rb)
                test_ruby
                ;;
            php)
                test_php
                ;;
            detect|auto)
                local detected=$(detect_language)
                if [ "$detected" != "unknown" ]; then
                    echo -e "${GREEN}Langage détecté: $detected${RESET}\n"
                    "test_${detected}" "$2"
                else
                    echo -e "${RED}✗ Impossible de détecter le langage${RESET}"
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}Langage inconnu: $1${RESET}"
                echo ""
                echo "Langages disponibles:"
                echo "  testman python [unit|integration|all]"
                echo "  testman node [unit|integration|watch|all]"
                echo "  testman rust"
                echo "  testman go"
                echo "  testman java"
                echo "  testman flutter"
                echo "  testman ruby"
                echo "  testman php"
                echo "  testman detect  - Détecter automatiquement"
                return 1
                ;;
        esac
    else
        # Mode interactif
        show_main_menu
    fi
}

# Alias
alias tm='testman'
alias test-app='testman'

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🧪 TESTMAN chargé - Tapez 'testman' ou 'tm' pour démarrer"

