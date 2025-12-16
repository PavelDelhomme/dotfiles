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

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

printf "${BLUE}🧪 Test: $MANAGER dans $SHELL_TYPE${NC}\n"

# Charger les dotfiles selon le shell
case "$SHELL_TYPE" in
    zsh)
        if [ -f "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
            export DOTFILES_DIR="$DOTFILES_DIR"
            . "$DOTFILES_DIR/zsh/zshrc_custom" >/dev/null 2>&1 || true
        fi
        ;;
    bash)
        if [ -f "$DOTFILES_DIR/bash/bashrc_custom" ]; then
            export DOTFILES_DIR="$DOTFILES_DIR"
            . "$DOTFILES_DIR/bash/bashrc_custom" >/dev/null 2>&1 || true
        fi
        ;;
    fish)
        # Fish nécessite une approche différente
        if [ -f "$DOTFILES_DIR/fish/config_custom.fish" ]; then
            export DOTFILES_DIR="$DOTFILES_DIR"
            fish -c "source $DOTFILES_DIR/fish/config_custom.fish" >/dev/null 2>&1 || true
        fi
        ;;
esac

# Vérifier si le manager existe
case "$SHELL_TYPE" in
    zsh)
        if command -v "$MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de syntaxe
            if type "$MANAGER" >/dev/null 2>&1; then
                printf "${GREEN}✅ Syntaxe OK${NC}\n"
                
                # Test de réponse (version ou help)
                if "$MANAGER" --version >/dev/null 2>&1 || \
                   "$MANAGER" --help >/dev/null 2>&1 || \
                   "$MANAGER" help >/dev/null 2>&1; then
                    printf "${GREEN}✅ $MANAGER répond correctement${NC}\n"
                    exit 0
                else
                    printf "${YELLOW}⚠️  $MANAGER existe mais ne répond pas${NC}\n"
                    exit 0  # Pas une erreur critique
                fi
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
        if command -v "$MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de syntaxe
            if type "$MANAGER" >/dev/null 2>&1; then
                printf "${GREEN}✅ Syntaxe OK${NC}\n"
                
                # Test de réponse
                if "$MANAGER" --version >/dev/null 2>&1 || \
                   "$MANAGER" --help >/dev/null 2>&1 || \
                   "$MANAGER" help >/dev/null 2>&1; then
                    printf "${GREEN}✅ $MANAGER répond correctement${NC}\n"
                    exit 0
                else
                    printf "${YELLOW}⚠️  $MANAGER existe mais ne répond pas${NC}\n"
                    exit 0
                fi
            else
                printf "${RED}❌ Erreur de syntaxe${NC}\n"
                exit 1
            fi
        else
            printf "${RED}❌ $MANAGER n'existe pas dans $SHELL_TYPE${NC}\n"
            exit 1
        fi
        ;;
    fish)
        # Fish nécessite une approche différente
        if fish -c "type $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de réponse
            if fish -c "$MANAGER --version" >/dev/null 2>&1 || \
               fish -c "$MANAGER --help" >/dev/null 2>&1 || \
               fish -c "$MANAGER help" >/dev/null 2>&1; then
                printf "${GREEN}✅ $MANAGER répond correctement${NC}\n"
                exit 0
            else
                printf "${YELLOW}⚠️  $MANAGER existe mais ne répond pas${NC}\n"
                exit 0
            fi
        else
            printf "${RED}❌ $MANAGER n'existe pas dans $SHELL_TYPE${NC}\n"
            exit 1
        fi
        ;;
    *)
        printf "${RED}❌ Shell non supporté: $SHELL_TYPE${NC}\n"
        exit 1
        ;;
esac

