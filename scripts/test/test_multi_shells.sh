#!/bin/bash
# =============================================================================
# TEST MULTI-SHELLS - Tests complets des managers dans tous les shells
# =============================================================================
# Description: Teste tous les managers dans ZSH, Bash et Fish
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -uo pipefail  # -e désactivé pour permettre la continuation même en cas d'erreur

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SCRIPT_DIR="$DOTFILES_DIR/scripts/test"
DOCKER_DIR="$SCRIPT_DIR/docker"
REPORT_FILE="$DOTFILES_DIR/TEST_MULTI_SHELLS_REPORT.md"

# Liste des managers à tester
MANAGERS="pathman manman searchman aliaman helpman fileman miscman installman configman gitman cyberman devman virtman netman sshman testman testzshman moduleman multimediaman cyberlearn"

# Liste des shells à tester
SHELLS="zsh bash fish"

# Fonction pour afficher le header
show_header() {
    clear
    printf "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         TESTS MULTI-SHELLS - Tous les Managers                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    printf "${NC}"
    echo
}

# Fonction pour tester un manager dans un shell
test_manager_in_shell() {
    local manager="$1"
    local shell_type="$2"
    local container_name="dotfiles-test-${shell_type}-${manager}"
    
    printf "${BLUE}🧪 Test: $manager dans $shell_type${NC}\n"
    
    # Vérifier si le conteneur existe
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker rm -f "$container_name" >/dev/null 2>&1 || true
    fi
    
    # Lancer le test
    local shell_cmd
    case "$shell_type" in
        zsh) shell_cmd="/bin/zsh" ;;
        bash) shell_cmd="/bin/bash" ;;
        fish) shell_cmd="/usr/bin/fish" ;;
        *) shell_cmd="/bin/sh" ;;
    esac
    
    if docker run --rm \
        --name "$container_name" \
        -v "$DOTFILES_DIR:/root/dotfiles:ro" \
        -e DOTFILES_DIR=/root/dotfiles \
        dotfiles-test:latest \
        "$shell_cmd" \
        -c "cd /root/dotfiles && bash scripts/test/docker/test_manager_multi_shell.sh $manager $shell_type" \
        2>&1 | tee "/tmp/test_${shell_type}_${manager}.log"
    then
        printf "${GREEN}✅ $manager ($shell_type): OK${NC}\n"
        return 0
    else
        printf "${RED}❌ $manager ($shell_type): ÉCHEC${NC}\n"
        return 1
    fi
}

# Fonction pour générer le rapport
generate_report() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    {
        echo "# 📊 Rapport de Tests Multi-Shells"
        echo ""
        echo "**Date:** $(date)"
        echo "**Dotfiles:** $DOTFILES_DIR"
        echo ""
        echo "## Résultats par Shell"
        echo ""
        
        for shell in $SHELLS; do
            echo "### $shell"
            echo ""
            echo "| Manager | Statut | Logs |"
            echo "|---------|--------|------|"
            
            for manager in $MANAGERS; do
                total_tests=$((total_tests + 1))
                log_file="/tmp/test_${shell}_${manager}.log"
                
                if [ -f "$log_file" ]; then
                    if grep -q "✅.*OK" "$log_file" 2>/dev/null; then
                        echo "| $manager | ✅ OK | [Voir]($log_file) |"
                        passed_tests=$((passed_tests + 1))
                    else
                        echo "| $manager | ❌ ÉCHEC | [Voir]($log_file) |"
                        failed_tests=$((failed_tests + 1))
                    fi
                else
                    echo "| $manager | ⚠️ NON TESTÉ | - |"
                fi
            done
            echo ""
        done
        
        echo "## Résumé Global"
        echo ""
        echo "- **Total:** $total_tests tests"
        echo "- **Réussis:** $passed_tests"
        echo "- **Échoués:** $failed_tests"
        echo "- **Taux de réussite:** $((passed_tests * 100 / total_tests))%"
    } > "$REPORT_FILE"
    
    printf "${GREEN}📊 Rapport généré: $REPORT_FILE${NC}\n"
}

# Fonction principale
main() {
    show_header
    
    printf "${YELLOW}🔨 Vérification de l'image Docker...${NC}\n"
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^dotfiles-test:latest$"; then
        printf "${YELLOW}⚠️  Image Docker non trouvée, construction...${NC}\n"
        cd "$DOTFILES_DIR"
        DOCKER_BUILDKIT=0 docker build -f "$DOCKER_DIR/Dockerfile.test" -t dotfiles-test:latest . || {
            printf "${RED}❌ Erreur lors de la construction de l'image${NC}\n"
            return 1
        }
    fi
    
    printf "${GREEN}✅ Image Docker prête${NC}\n"
    echo
    
    # Tests pour chaque shell
    for shell in $SHELLS; do
        printf "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}\n"
        printf "${CYAN}${BOLD}Tests dans $shell${NC}\n"
        printf "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════${NC}\n"
        echo
        
        for manager in $MANAGERS; do
            test_manager_in_shell "$manager" "$shell" || true
        done
        
        echo
    done
    
    # Générer le rapport
    generate_report
    
    printf "${GREEN}${BOLD}✅ Tests multi-shells terminés!${NC}\n"
    printf "📊 Rapport: $REPORT_FILE\n"
}

# Exécuter
main "$@"

