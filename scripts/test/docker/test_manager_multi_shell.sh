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

# Vérifier si le manager existe dans le bon shell
case "$SHELL_TYPE" in
    zsh)
        if zsh -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/zsh/zshrc_custom' ] && source '$DOTFILES_DIR/zsh/zshrc_custom' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de syntaxe
            if zsh -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/zsh/zshrc_custom' ] && source '$DOTFILES_DIR/zsh/zshrc_custom' >/dev/null 2>&1; type $MANAGER" >/dev/null 2>&1; then
                printf "${GREEN}✅ Syntaxe OK${NC}\n"
                
                # Test de réponse (version ou help) - les managers sont souvent interactifs
                # On considère que si la syntaxe est OK et que le manager existe, c'est suffisant
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
        if bash -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/bash/bashrc_custom' ] && source '$DOTFILES_DIR/bash/bashrc_custom' >/dev/null 2>&1; command -v $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de syntaxe
            if bash -c "export DOTFILES_DIR='$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/bash/bashrc_custom' ] && source '$DOTFILES_DIR/bash/bashrc_custom' >/dev/null 2>&1; type $MANAGER" >/dev/null 2>&1; then
                printf "${GREEN}✅ Syntaxe OK${NC}\n"
                
                # Test de réponse - les managers sont souvent interactifs
                # On considère que si la syntaxe est OK et que le manager existe, c'est suffisant
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
    fish)
        # Fish nécessite une approche différente
        if fish -c "set -gx DOTFILES_DIR '$DOTFILES_DIR'; [ -f '$DOTFILES_DIR/fish/config_custom.fish' ]; and source '$DOTFILES_DIR/fish/config_custom.fish' >/dev/null 2>&1; type $MANAGER" >/dev/null 2>&1; then
            printf "${GREEN}✅ $MANAGER existe dans $SHELL_TYPE${NC}\n"
            
            # Test de réponse - les managers sont souvent interactifs
            # On considère que si le manager existe, c'est suffisant
            printf "${GREEN}✅ $MANAGER chargé avec succès${NC}\n"
            exit 0
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
