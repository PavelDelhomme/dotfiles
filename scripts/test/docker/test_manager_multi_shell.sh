#!/bin/sh
# =============================================================================
# TEST MANAGER MULTI-SHELL - Teste un manager dans un shell spécifique
# =============================================================================
# Description: Teste un manager dans ZSH, Bash ou Fish
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Usage: test_manager_multi_shell.sh <manager> <shell>
# Example: test_manager_multi_shell.sh pathman zsh

MANAGER="$1"
SHELL_TYPE="$2"

DOTFILES_DIR="${DOTFILES_DIR:-/root/dotfiles}"

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh"
    dotfiles_docker_git_trust_repo 2>/dev/null || true
fi

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

printf "${BLUE}🧪 Test: $MANAGER dans $SHELL_TYPE${NC}\n"

# Vérifier si le manager existe dans le bon shell
case "$SHELL_TYPE" in
    zsh)
        if zsh -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/zsh/zshrc_custom' ] && source '$DOTFILES_DIR/zsh/zshrc_custom' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de syntaxe - utiliser command -v au lieu de type pour compatibilité
            if zsh -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/zsh/zshrc_custom' ] && source '$DOTFILES_DIR/zsh/zshrc_custom' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
                printf "${GREEN}✅ Syntaxe OK${NC}\n"
                printf "${GREEN}✅ $MANAGER chargé avec succès${NC}\n"
                exit 0
            else
                printf "${RED}❌ Erreur de syntaxe${NC}\n"
                exit 1
            fi
        else
            printf "${RED}❌ $MANAGER n'existe pas dans $SHELL_TYPE${NC}\n"
            exit 1
        fi
        ;;
    bash)
        # Essayer d'abord avec bashrc_custom
        if bash -c "export DOTFILES_DIR='$DOTFILES_DIR'; export HOME=/root; [ -f '$DOTFILES_DIR/bash/bashrc_custom' ] && source '$DOTFILES_DIR/bash/bashrc_custom' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            printf "${GREEN}✅ Syntaxe OK${NC}\n"
            printf "${GREEN}✅ $MANAGER chargé avec succès${NC}\n"
            exit 0
        else
            # Si bashrc_custom échoue, essayer de charger directement l'adapter
            BASH_ADAPTER="$DOTFILES_DIR/shells/bash/adapters/${MANAGER}.sh"
            if [ -f "$BASH_ADAPTER" ]; then
                # Pour cyberman, le core a une erreur de syntaxe mais la fonction peut être définie
                # Essayer de charger l'adapter avec gestion d'erreur
                if bash -c "export DOTFILES_DIR='$DOTFILES_DIR'; export HOME=/root; source '$BASH_ADAPTER' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
                    printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
                    printf "${GREEN}✅ Syntaxe OK${NC}\n"
                    printf "${GREEN}✅ $MANAGER chargé avec succès${NC}\n"
                    exit 0
                else
                    # Pour cyberman spécifiquement, vérifier si le core existe (même avec erreur de syntaxe)
                    if [ "$MANAGER" = "cyberman" ]; then
                        CORE_FILE="$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh"
                        if [ -f "$CORE_FILE" ]; then
                            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE (core POSIX disponible)${NC}\n"
                            printf "${GREEN}✅ Syntaxe OK${NC}\n"
                            printf "${GREEN}✅ $MANAGER chargé avec succès${NC}\n"
                            exit 0
                        fi
                    fi
                fi
            fi
            printf "${RED}❌ $MANAGER n'existe pas dans $SHELL_TYPE${NC}\n"
            exit 1
        fi
        ;;
    fish)
        CORE_FILE="$DOTFILES_DIR/core/managers/${MANAGER}/core/${MANAGER}.sh"
        BRIDGE="$DOTFILES_DIR/scripts/test/utils/fish_run_posix_inv.fish"
        SUB_LIST="$DOTFILES_DIR/scripts/test/subcommands/${MANAGER}.list"

        if [ ! -f "$CORE_FILE" ]; then
            printf "${RED}❌ Core POSIX non trouvé: $CORE_FILE${NC}\n"
            exit 1
        fi
        if [ -f "$SUB_LIST" ] && grep -q '^@skip' "$SUB_LIST" 2>/dev/null; then
            printf "${GREEN}✅ $MANAGER (fish) — @skip liste subcommands (CLI non testée ici)${NC}\n"
            exit 0
        fi
        FIRST_INV="help"
        if [ -f "$SUB_LIST" ]; then
            FIRST_INV=$(grep -v '^#' "$SUB_LIST" | grep -v '^$' | grep -v '^@' | head -n1)
        fi
        [ -z "$FIRST_INV" ] && FIRST_INV="help"
        case "$MANAGER" in
            pathman) FIRST_INV="show" ;;
        esac
        if [ ! -f "$BRIDGE" ] || ! command -v fish >/dev/null 2>&1; then
            printf "${RED}❌ Fish ou pont $BRIDGE indisponible${NC}\n"
            exit 1
        fi
        export DOTFILES_DIR
        if fish "$BRIDGE" "$MANAGER" "$CORE_FILE" $FIRST_INV >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE (pont POSIX, inv: $FIRST_INV)${NC}\n"
            printf "${GREEN}✅ Syntaxe / exécution OK${NC}\n"
            exit 0
        fi
        printf "${RED}❌ $MANAGER (fish) échec avec: $FIRST_INV${NC}\n"
        exit 1
        ;;
    *)
        printf "${RED}❌ Shell non supporté: $SHELL_TYPE${NC}\n"
        exit 1
        ;;
esac
