#!/bin/sh
# =============================================================================
# TESTMAN - Test Manager pour Applications (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire de tests pour applications (tous langages)
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

# DESC: Gestionnaire de tests pour applications (tous langages)
# USAGE: testman [langage] [test-type] [options]
# EXAMPLE: testman
# EXAMPLE: testman python
# EXAMPLE: testman node unit
# EXAMPLE: testman rust
testman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    TESTMAN_DIR="$DOTFILES_DIR/zsh/functions/testman"
    TESTMAN_MODULES_DIR="$TESTMAN_DIR/modules"
    TESTMAN_UTILS_DIR="$TESTMAN_DIR/utils"
    TESTMAN_CONFIG_DIR="$TESTMAN_DIR/config"
    
    # Créer les répertoires si nécessaire
    if [ -n "$TESTMAN_DIR" ]; then
        mkdir -p "$TESTMAN_CONFIG_DIR" 2>/dev/null || true
    fi
    
    # Charger les utilitaires si disponibles
    if [ -d "$TESTMAN_UTILS_DIR" ]; then
        for util_file in "$TESTMAN_UTILS_DIR"/*.sh; do
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
        echo "║              TESTMAN - Test Manager Applications                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour détecter le langage du projet
    detect_language() {
        dir="${1:-.}"
        
        if [ -f "$dir/package.json" ]; then
            echo "node"
        elif [ -f "$dir/PyProject.toml" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/requirements.txt" ] || [ -f "$dir/pyproject.toml" ]; then
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
        elif ls "$dir"/*.asd 2>/dev/null | head -1 >/dev/null || ls "$dir"/*.lisp 2>/dev/null | head -1 >/dev/null || [ -f "$dir/package.lisp" ]; then
            echo "lisp"
        elif ls "$dir"/*.el 2>/dev/null | head -1 >/dev/null; then
            echo "lisp"
        else
            echo "unknown"
        fi
    }
    
    # Test Python
    test_python() {
        test_type="${1:-all}"
        test_dir="${2:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}🐍 Tests Python${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        # Vérifier si Docker Compose est utilisé
        if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
            printf "${YELLOW}🐳 Docker Compose détecté${RESET}\n"
            printf "Voulez-vous lancer les tests dans Docker? (y/N): "
            read use_docker
            echo ""
            case "$use_docker" in
                [yY]*)
                    printf "${CYAN}Lancement des tests dans Docker...${RESET}\n\n"
                    docker compose run --rm test python -m pytest -v 2>/dev/null || \
                    docker compose run --rm app python -m pytest -v 2>/dev/null || \
                    docker compose exec test python -m pytest -v 2>/dev/null || \
                    docker compose exec app python -m pytest -v 2>/dev/null || \
                    docker-compose run --rm test python -m pytest -v 2>/dev/null || \
                    docker-compose run --rm app python -m pytest -v 2>/dev/null
                    exit_code=$?
                    cd "$original_dir" 2>/dev/null || true
                    return $exit_code
                    ;;
            esac
        fi
        
        # Détecter le framework de test
        if [ -f "pytest.ini" ] || ([ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null); then
            printf "${YELLOW}Framework détecté: pytest${RESET}\n\n"
            case "$test_type" in
                unit|u)
                    python -m pytest tests/unit/ -v || python -m pytest test/unit/ -v
                    ;;
                integration|i)
                    python -m pytest tests/integration/ -v || python -m pytest test/integration/ -v
                    ;;
                coverage|cov)
                    python -m pytest --cov=. --cov-report=html -v || python -m pytest --cov=. -v
                    ;;
                all|*)
                    python -m pytest tests/ -v || python -m pytest test/ -v || python -m pytest -v
                    ;;
            esac
        elif [ -f "setup.py" ] && grep -q "unittest" setup.py 2>/dev/null; then
            printf "${YELLOW}Framework détecté: unittest${RESET}\n\n"
            python -m unittest discover -v
        elif [ -f "manage.py" ]; then
            printf "${YELLOW}Framework détecté: Django${RESET}\n\n"
            python manage.py test
        else
            printf "${YELLOW}Aucun framework détecté, recherche de tests...${RESET}\n\n"
            python -m pytest tests/ -v 2>/dev/null || \
            python -m pytest test/ -v 2>/dev/null || \
            python -m unittest discover -v 2>/dev/null || \
            printf "${RED}✗ Aucun test trouvé${RESET}\n"
        fi
        
        exit_code=$?
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Node.js
    test_node() {
        test_type="${1:-all}"
        test_dir="${2:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}📦 Tests Node.js${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        # Vérifier si Docker Compose est utilisé
        if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
            printf "${YELLOW}🐳 Docker Compose détecté${RESET}\n"
            printf "Voulez-vous lancer les tests dans Docker? (y/N): "
            read use_docker
            echo ""
            case "$use_docker" in
                [yY]*)
                    printf "${CYAN}Lancement des tests dans Docker...${RESET}\n\n"
                    docker compose run --rm test npm test 2>/dev/null || \
                    docker compose run --rm app npm test 2>/dev/null || \
                    docker compose exec test npm test 2>/dev/null || \
                    docker-compose run --rm test npm test 2>/dev/null
                    exit_code=$?
                    cd "$original_dir" 2>/dev/null || true
                    return $exit_code
                    ;;
            esac
        fi
        
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
                    coverage|cov)
                        npm test -- --coverage || npm run test:coverage || npm run test -- --coverage
                        ;;
                    all|*)
                        npm test
                        ;;
                esac
            else
                printf "${YELLOW}Script 'test' non trouvé dans package.json${RESET}\n"
                printf "${YELLOW}Exécution de npm test par défaut...${RESET}\n\n"
                npm test
            fi
        else
            printf "${RED}✗ package.json non trouvé${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Rust
    test_rust() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}🦀 Tests Rust${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "Cargo.toml" ]; then
            cargo test --verbose
        else
            printf "${RED}✗ Cargo.toml non trouvé${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Go
    test_go() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}🐹 Tests Go${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "go.mod" ] || [ -d ".git" ]; then
            go test ./... -v
        else
            printf "${RED}✗ Projet Go non détecté${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Java
    test_java() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}☕ Tests Java${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "pom.xml" ]; then
            printf "${YELLOW}Framework détecté: Maven${RESET}\n\n"
            mvn test
        elif [ -f "build.gradle" ]; then
            printf "${YELLOW}Framework détecté: Gradle${RESET}\n\n"
            ./gradlew test || gradle test
        else
            printf "${RED}✗ Projet Java non détecté (Maven/Gradle)${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Flutter
    test_flutter() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}🎯 Tests Flutter${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "pubspec.yaml" ]; then
            flutter test
        else
            printf "${RED}✗ pubspec.yaml non trouvé${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Ruby
    test_ruby() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}💎 Tests Ruby${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "Gemfile" ]; then
            if [ -f "Rakefile" ] && grep -q "test" Rakefile 2>/dev/null; then
                bundle exec rake test
            else
                bundle exec rspec 2>/dev/null || bundle exec minitest 2>/dev/null || printf "${RED}✗ Aucun framework de test détecté${RESET}\n"
            fi
        else
            printf "${RED}✗ Gemfile non trouvé${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test PHP
    test_php() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}🐘 Tests PHP${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        if [ -f "composer.json" ]; then
            if grep -q "phpunit" composer.json 2>/dev/null; then
                vendor/bin/phpunit
            elif [ -f "phpunit.xml" ]; then
                phpunit
            else
                printf "${YELLOW}Aucun framework de test détecté${RESET}\n"
            fi
        else
            printf "${RED}✗ composer.json non trouvé${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Test Lisp (simplifié)
    test_lisp() {
        test_dir="${1:-.}"
        original_dir=$(pwd)
        
        # Aller dans le répertoire de test si spécifié
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$test_dir" || return 1
        fi
        
        printf "${CYAN}💬 Tests Lisp${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        printf "${YELLOW}Répertoire: %s${RESET}\n\n" "$(pwd)"
        
        # Détecter le type de Lisp
        if ls *.asd 2>/dev/null | head -1 >/dev/null || ls *.lisp 2>/dev/null | head -1 >/dev/null; then
            # Common Lisp (ASDF)
            if command -v sbcl >/dev/null 2>&1; then
                printf "${YELLOW}Interpréteur détecté: SBCL${RESET}\n\n"
                if ls *.asd 2>/dev/null | head -1 >/dev/null; then
                    sbcl --eval "(asdf:test-system :$(basename $(pwd)))" --quit
                else
                    printf "${YELLOW}Exécution des fichiers de test...${RESET}\n\n"
                    for test_file in test/*.lisp tests/*.lisp *.test.lisp; do
                        [ -f "$test_file" ] && sbcl --script "$test_file" 2>/dev/null || true
                    done
                fi
            elif command -v clisp >/dev/null 2>&1; then
                printf "${YELLOW}Interpréteur détecté: CLISP${RESET}\n\n"
                for test_file in test/*.lisp tests/*.lisp *.test.lisp; do
                    [ -f "$test_file" ] && clisp "$test_file" 2>/dev/null || true
                done
            else
                printf "${RED}✗ Aucun interpréteur Lisp trouvé (SBCL ou CLISP)${RESET}\n"
                exit_code=1
            fi
        elif [ -f "package.lisp" ] || ls *.el 2>/dev/null | head -1 >/dev/null; then
            # Emacs Lisp
            printf "${YELLOW}Type détecté: Emacs Lisp${RESET}\n\n"
            if command -v emacs >/dev/null 2>&1; then
                for test_file in *-test.el *test.el test/*.el; do
                    [ -f "$test_file" ] && emacs --batch -l "$test_file" 2>/dev/null || true
                done
            else
                printf "${RED}✗ Emacs non trouvé${RESET}\n"
                exit_code=1
            fi
        else
            printf "${RED}✗ Projet Lisp non détecté${RESET}\n"
            exit_code=1
        fi
        
        exit_code=${exit_code:-$?}
        # Revenir au répertoire original si on a changé
        if [ "$test_dir" != "." ] && [ -d "$test_dir" ]; then
            cd "$original_dir" 2>/dev/null || true
        fi
        return $exit_code
    }
    
    # Menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🧪 LANGAGES SUPPORTÉS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        lang=$(detect_language)
        if [ "$lang" != "unknown" ]; then
            printf "${GREEN}✓ Langage détecté: %s${RESET}\n\n" "$lang"
        fi
        
        echo "  1. 🐍 Python (pytest, unittest, Django)"
        echo "  2. 📦 Node.js (npm, jest, mocha)"
        echo "  3. 🦀 Rust (cargo test)"
        echo "  4. 🐹 Go (go test)"
        echo "  5. ☕ Java (Maven, Gradle)"
        echo "  6. 🎯 Flutter (flutter test)"
        echo "  7. 💎 Ruby (RSpec, Minitest)"
        echo "  8. 🐘 PHP (PHPUnit)"
        echo "  9. 💬 Lisp (Common Lisp, Emacs Lisp)"
        echo " 10. 🔍 Détecter automatiquement le langage"
        echo ""
        printf "${YELLOW}  0.${RESET} Quitter\n"
        echo ""
        printf "${CYAN}💡 Vous pouvez aussi taper directement le nom du langage${RESET}\n"
        printf "${CYAN}   Exemples: python, node, rust, go, java, flutter, ruby, php, lisp${RESET}\n"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
        
        # Mapper les noms de langages
        case "$choice" in
            python|py|pytest|django|1)
                test_python
                ;;
            node|nodejs|js|npm|jest|mocha|2)
                test_node
                ;;
            rust|rs|cargo|3)
                test_rust
                ;;
            go|golang|4)
                test_go
                ;;
            java|maven|gradle|5)
                test_java
                ;;
            flutter|dart|6)
                test_flutter
                ;;
            ruby|rb|rspec|minitest|7)
                test_ruby
                ;;
            php|phpunit|8)
                test_php
                ;;
            lisp|cl|common-lisp|emacs-lisp|elisp|9)
                test_lisp
                ;;
            10|detect|auto|d)
                detected=$(detect_language)
                if [ "$detected" != "unknown" ]; then
                    printf "${GREEN}Langage détecté: %s${RESET}\n\n" "$detected"
                    "test_${detected}"
                else
                    printf "${RED}✗ Impossible de détecter le langage${RESET}\n"
                    printf "${YELLOW}Choisissez manuellement un langage${RESET}\n"
                fi
                ;;
            0|q|Q|quit|exit)
                printf "${GREEN}Au revoir!${RESET}\n"
                return 0
                ;;
            *)
                printf "${RED}Choix invalide: %s${RESET}\n" "$choice"
                printf "${YELLOW}Utilisez un numéro (1-10), un nom de langage, ou 0/q pour quitter${RESET}\n"
                sleep 2
                ;;
        esac
        
        # Retourner au menu après action (sauf si choix 0, q, quit, exit)
        case "$choice" in
            0|q|Q|quit|exit) ;;
            *)
                echo ""
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                testman
                ;;
        esac
    }
    
    # Si des arguments sont fournis, exécuter directement
    if [ -n "$1" ]; then
        lang=$(echo "$1" | tr '[:upper:]' '[:lower:]')
        test_type="$2"
        test_dir="${3:-.}"
        
        case "$lang" in
            python|py|pytest|django)
                test_python "$test_type" "$test_dir"
                ;;
            node|nodejs|js|npm|jest|mocha)
                test_node "$test_type" "$test_dir"
                ;;
            rust|rs|cargo)
                test_rust "$test_dir"
                ;;
            go|golang)
                test_go "$test_dir"
                ;;
            java|maven|gradle)
                test_java "$test_dir"
                ;;
            flutter|dart)
                test_flutter "$test_dir"
                ;;
            ruby|rb|rspec|minitest)
                test_ruby "$test_dir"
                ;;
            php|phpunit)
                test_php "$test_dir"
                ;;
            lisp|cl|common-lisp|emacs-lisp|elisp)
                test_lisp "$test_dir"
                ;;
            detect|auto|d)
                detected=$(detect_language "$test_dir")
                if [ "$detected" != "unknown" ]; then
                    printf "${GREEN}Langage détecté: %s${RESET}\n\n" "$detected"
                    "test_${detected}" "$test_type" "$test_dir"
                else
                    printf "${RED}✗ Impossible de détecter le langage${RESET}\n"
                    return 1
                fi
                ;;
            help|--help|-h)
                echo "🧪 TESTMAN - Test Manager Applications"
                echo ""
                echo "Usage: testman [langage] [test-type] [dir]"
                echo ""
                echo "Langages disponibles:"
                echo "  python [unit|integration|coverage|all] [dir]"
                echo "  node [unit|integration|watch|coverage|all] [dir]"
                echo "  rust [dir]"
                echo "  go [dir]"
                echo "  java [dir]"
                echo "  flutter [dir]"
                echo "  ruby [dir]"
                echo "  php [dir]"
                echo "  lisp [dir]"
                echo "  detect [dir]  - Détecter automatiquement"
                echo ""
                echo "Exemples:"
                echo "  testman python unit"
                echo "  testman node coverage ./frontend"
                echo "  testman detect"
                echo ""
                echo "Sans argument: menu interactif"
                ;;
            *)
                printf "${RED}Langage inconnu: %s${RESET}\n" "$1"
                echo ""
                echo "Langages disponibles:"
                echo "  testman python [unit|integration|coverage|all] [dir]"
                echo "  testman node [unit|integration|watch|coverage|all] [dir]"
                echo "  testman rust [dir]"
                echo "  testman go [dir]"
                echo "  testman java [dir]"
                echo "  testman flutter [dir]"
                echo "  testman ruby [dir]"
                echo "  testman php [dir]"
                echo "  testman lisp [dir]"
                echo "  testman detect [dir]  - Détecter automatiquement"
                echo ""
                echo "Exemples:"
                echo "  testman python unit"
                echo "  testman node coverage ./frontend"
                echo "  testman detect"
                return 1
                ;;
        esac
    else
        # Mode interactif
        show_main_menu
    fi
}
