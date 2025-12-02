#!/bin/bash
################################################################################
# Script de test complet pour dotfiles
# Teste tous les managers et fonctionnalités dans un environnement isolé
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Répertoire de test isolé
TEST_DIR="${TEST_DIR:-/tmp/dotfiles_test_$(date +%Y%m%d_%H%M%S)}"
TEST_HOME="$TEST_DIR/home"
TEST_DOTFILES="$TEST_DIR/dotfiles"

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_test() { echo -e "${CYAN}[TEST]${NC} $1"; }

################################################################################
# Fonction de test
################################################################################
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL_TESTS++))
    log_test "Test $TOTAL_TESTS: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        ((PASSED_TESTS++))
        log_info "✓ $test_name"
        return 0
    else
        ((FAILED_TESTS++))
        log_error "✗ $test_name"
        return 1
    fi
}

run_test_warn() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL_TESTS++))
    log_test "Test $TOTAL_TESTS: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        ((PASSED_TESTS++))
        log_info "✓ $test_name"
        return 0
    else
        ((WARNINGS++))
        log_warn "⚠ $test_name (avertissement)"
        return 1
    fi
}

################################################################################
# Préparation de l'environnement de test
################################################################################
setup_test_environment() {
    log_info "Création de l'environnement de test..."
    
    # Créer les répertoires
    mkdir -p "$TEST_HOME"
    mkdir -p "$TEST_DOTFILES"
    
    # Copier les dotfiles
    log_info "Copie des dotfiles..."
    cp -r "$HOME/dotfiles"/* "$TEST_DOTFILES/" 2>/dev/null || true
    
    # Créer un .zshrc de test
    cat > "$TEST_HOME/.zshrc" << 'EOF'
# Zshrc de test pour dotfiles
export DOTFILES_PATH="$HOME/dotfiles"
export DOTFILES_ZSH_PATH="$DOTFILES_PATH/zsh"

# Charger zshrc_custom
if [ -f "$DOTFILES_ZSH_PATH/zshrc_custom" ]; then
    source "$DOTFILES_ZSH_PATH/zshrc_custom"
fi
EOF
    
    log_info "Environnement de test créé: $TEST_DIR"
}

################################################################################
# Tests des managers
################################################################################
test_managers() {
    log_info "Tests des managers..."
    
    # Test 1: Vérifier que tous les managers existent
    run_test "Vérification existence managers" \
        "test -f '$TEST_DOTFILES/zsh/functions/pathman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/netman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/aliaman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/miscman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/searchman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/cyberman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/devman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/gitman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/helpman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/configman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/installman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/fileman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/virtman.zsh' && \
         test -f '$TEST_DOTFILES/zsh/functions/manman.zsh'"
    
    # Test 2: Vérifier la syntaxe Zsh des managers
    for manager in pathman netman aliaman miscman searchman cyberman devman gitman helpman configman installman fileman virtman manman; do
        run_test_warn "Syntaxe Zsh: $manager" \
            "zsh -n '$TEST_DOTFILES/zsh/functions/${manager}.zsh'"
    done
    
    # Test 3: Vérifier les structures modulaires
    run_test "Structure modulaire cyberman" \
        "test -d '$TEST_DOTFILES/zsh/functions/cyberman/core' && \
         test -d '$TEST_DOTFILES/zsh/functions/cyberman/modules' && \
         test -d '$TEST_DOTFILES/zsh/functions/cyberman/config'"
    
    run_test "Structure modulaire fileman" \
        "test -d '$TEST_DOTFILES/zsh/functions/fileman/core' && \
         test -d '$TEST_DOTFILES/zsh/functions/fileman/modules' && \
         test -d '$TEST_DOTFILES/zsh/functions/fileman/config'"
    
    run_test "Structure modulaire virtman" \
        "test -d '$TEST_DOTFILES/zsh/functions/virtman/core' && \
         test -d '$TEST_DOTFILES/zsh/functions/virtman/modules' && \
         test -d '$TEST_DOTFILES/zsh/functions/virtman/config'"
}

################################################################################
# Tests des scripts de configuration
################################################################################
test_config_scripts() {
    log_info "Tests des scripts de configuration..."
    
    # Test syntaxe bash des scripts configman
    if [ -d "$TEST_DOTFILES/zsh/functions/configman/modules" ]; then
        find "$TEST_DOTFILES/zsh/functions/configman/modules" -name "*.sh" | while read script; do
            run_test_warn "Syntaxe Bash: $(basename $script)" \
                "bash -n '$script'"
        done
    fi
    
    # Test syntaxe bash des scripts virtman
    if [ -d "$TEST_DOTFILES/zsh/functions/virtman/modules" ]; then
        find "$TEST_DOTFILES/zsh/functions/virtman/modules" -name "*.sh" | while read script; do
            run_test_warn "Syntaxe Bash: $(basename $script)" \
                "bash -n '$script'"
        done
    fi
}

################################################################################
# Tests des alias
################################################################################
test_aliases() {
    log_info "Tests des alias..."
    
    # Test 1: Vérifier que le fichier aliases existe
    run_test_warn "Fichier aliases.zsh existe" \
        "test -f '$TEST_DOTFILES/zsh/aliases.zsh'"
    
    # Test 2: Vérifier la syntaxe du fichier aliases
    if [ -f "$TEST_DOTFILES/zsh/aliases.zsh" ]; then
        run_test_warn "Syntaxe aliases.zsh" \
            "zsh -n '$TEST_DOTFILES/zsh/aliases.zsh'"
    fi
}

################################################################################
# Tests des bibliothèques communes
################################################################################
test_common_libs() {
    log_info "Tests des bibliothèques communes..."
    
    # Test 1: Vérifier common.sh
    run_test "Bibliothèque common.sh existe" \
        "test -f '$TEST_DOTFILES/scripts/lib/common.sh'"
    
    # Test 2: Syntaxe common.sh
    if [ -f "$TEST_DOTFILES/scripts/lib/common.sh" ]; then
        run_test_warn "Syntaxe common.sh" \
            "bash -n '$TEST_DOTFILES/scripts/lib/common.sh'"
    fi
    
    # Test 3: Vérifier que les scripts configman peuvent charger common.sh
    if [ -f "$TEST_DOTFILES/scripts/lib/common.sh" ]; then
        for script in "$TEST_DOTFILES/zsh/functions/configman/modules"/*/*.sh; do
            if [ -f "$script" ]; then
                run_test_warn "Chargement common.sh: $(basename $script)" \
                    "grep -q 'common.sh' '$script' && bash -c 'DOTFILES_DIR=\"$TEST_DOTFILES\" source \"$TEST_DOTFILES/scripts/lib/common.sh\" && echo OK'"
            fi
        done
    fi
}

################################################################################
# Tests de zshrc_custom
################################################################################
test_zshrc_custom() {
    log_info "Tests de zshrc_custom..."
    
    # Test 1: Vérifier que zshrc_custom existe
    run_test "zshrc_custom existe" \
        "test -f '$TEST_DOTFILES/zsh/zshrc_custom'"
    
    # Test 2: Syntaxe zshrc_custom
    if [ -f "$TEST_DOTFILES/zsh/zshrc_custom" ]; then
        run_test_warn "Syntaxe zshrc_custom" \
            "zsh -n '$TEST_DOTFILES/zsh/zshrc_custom'"
    fi
    
    # Test 3: Vérifier qu'il n'y a pas de variables en conflit (status)
    if [ -f "$TEST_DOTFILES/zsh/zshrc_custom" ]; then
        run_test "Pas de variable 'status' en conflit" \
            "! grep -E 'local status=|status=' '$TEST_DOTFILES/zsh/zshrc_custom' || grep -q 'module_status' '$TEST_DOTFILES/zsh/zshrc_custom'"
    fi
}

################################################################################
# Tests spécifiques aliaman
################################################################################
test_aliaman() {
    log_info "Tests spécifiques aliaman..."
    
    # Test 1: Vérifier qu'il n'y a pas de variable 'status' en conflit
    run_test "aliaman: pas de variable 'status' en conflit" \
        "! grep -E 'local status=|status=' '$TEST_DOTFILES/zsh/functions/aliaman.zsh' || grep -q 'alias_status' '$TEST_DOTFILES/zsh/functions/aliaman.zsh'"
    
    # Test 2: Syntaxe aliaman
    run_test_warn "Syntaxe aliaman.zsh" \
        "zsh -n '$TEST_DOTFILES/zsh/functions/aliaman.zsh'"
}

################################################################################
# Tests spécifiques searchman
################################################################################
test_searchman() {
    log_info "Tests spécifiques searchman..."
    
    # Test 1: Syntaxe searchman
    run_test_warn "Syntaxe searchman.zsh" \
        "zsh -n '$TEST_DOTFILES/zsh/functions/searchman.zsh'"
}

################################################################################
# Rapport final
################################################################################
show_report() {
    echo ""
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                    RAPPORT DE TEST${NC}"
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Total de tests:     ${BOLD}$TOTAL_TESTS${NC}"
    echo -e "Tests réussis:      ${GREEN}${BOLD}$PASSED_TESTS${NC}"
    echo -e "Tests échoués:      ${RED}${BOLD}$FAILED_TESTS${NC}"
    echo -e "Avertissements:     ${YELLOW}${BOLD}$WARNINGS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✅ Tous les tests critiques ont réussi!${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}❌ Certains tests ont échoué${NC}"
        return 1
    fi
}

################################################################################
# Nettoyage
################################################################################
cleanup() {
    if [ "${KEEP_TEST_DIR:-}" != "1" ]; then
        log_info "Nettoyage de l'environnement de test..."
        rm -rf "$TEST_DIR"
        log_info "Environnement de test supprimé"
    else
        log_info "Environnement de test conservé: $TEST_DIR"
        log_info "Pour le supprimer: rm -rf $TEST_DIR"
    fi
}

################################################################################
# Main
################################################################################
main() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              TEST COMPLET DES DOTFILES                         ║"
    echo "║         Environnement de test isolé                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Vérifier que nous sommes dans le bon répertoire
    if [ ! -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
        log_error "Ce script doit être exécuté depuis le répertoire dotfiles"
        exit 1
    fi
    
    # Setup
    setup_test_environment
    
    # Tests
    test_managers
    test_config_scripts
    test_aliases
    test_common_libs
    test_zshrc_custom
    test_aliaman
    test_searchman
    
    # Rapport
    show_report
    local exit_code=$?
    
    # Nettoyage
    cleanup
    
    exit $exit_code
}

# Trap pour nettoyage en cas d'interruption
trap cleanup EXIT INT TERM

# Lancer les tests
main

