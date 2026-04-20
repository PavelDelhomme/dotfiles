#!/bin/zsh
# =============================================================================
# MANMAN - Manager of Managers
# =============================================================================
# Description: Gestionnaire centralisé pour tous les gestionnaires (*man.zsh)
# Auteur: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Gestionnaire centralisé pour accéder à tous les gestionnaires interactifs (*man). Permet de lancer rapidement pathman, netman, aliaman, miscman, searchman et cyberman depuis un menu unique.
# USAGE: manman
# EXAMPLE: manman
manman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local DOTFILES_FUNCTIONS_DIR="$HOME/dotfiles/zsh/functions"
    
    # Détecter tous les gestionnaires disponibles
    local managers=()
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/pathman.zsh" ]]; then
        managers+=("pathman:📁 Gestionnaire PATH|pathman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/netman.zsh" ]]; then
        managers+=("netman:🌐 Gestionnaire réseau|netman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/aliaman.zsh" ]]; then
        managers+=("aliaman:📝 Gestionnaire alias|aliaman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/miscman.zsh" ]]; then
        managers+=("miscman:🔧 Gestionnaire divers|miscman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/searchman.zsh" ]]; then
        managers+=("searchman:🔍 Gestionnaire recherche|searchman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/cyberman.zsh" ]]; then
        managers+=("cyberman:🛡️ Gestionnaire cybersécurité|cyberman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/devman.zsh" ]]; then
        managers+=("devman:💻 Gestionnaire développement|devman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/gitman.zsh" ]]; then
        managers+=("gitman:📦 Gestionnaire Git|gitman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/helpman.zsh" ]]; then
        managers+=("helpman:📚 Gestionnaire aide/documentation|helpman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/configman.zsh" ]]; then
        managers+=("configman:⚙️ Gestionnaire configuration|configman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/installman.zsh" ]]; then
        managers+=("installman:📦 Gestionnaire installation|installman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/moduleman.zsh" ]]; then
        managers+=("moduleman:⚙️ Gestionnaire modules|moduleman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/fileman.zsh" ]]; then
        managers+=("fileman:📁 Gestionnaire fichiers|fileman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/virtman.zsh" ]]; then
        managers+=("virtman:🖥️ Gestionnaire virtualisation|virtman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/sshman.zsh" ]]; then
        managers+=("sshman:🔐 Gestionnaire SSH|sshman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/testzshman.zsh" ]]; then
        managers+=("testzshman:🧪 Gestionnaire tests ZSH/dotfiles|testzshman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/testman.zsh" ]]; then
        managers+=("testman:🧪 Gestionnaire tests applications|testman")
    fi
    if [[ -f "$DOTFILES_FUNCTIONS_DIR/doctorman.zsh" ]]; then
        managers+=("doctorman:🩺 Diagnostic dotfiles / dev|doctorman")
    fi

    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  MANMAN - Manager of Managers                   ║"
    echo "║           Gestionnaire centralisé des gestionnaires            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo
    
    echo -e "${YELLOW}Gestionnaires disponibles:${RESET}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo
    
    local index=1
    for manager_info in "${managers[@]}"; do
        IFS=':' read -r name description command <<< "$manager_info"
        printf "  ${BOLD}%d${RESET}  %-40s ${CYAN}%s${RESET}\n" "$index" "$description" "$command"
        ((index++))
    done
    
    echo
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
    echo "  0) Retour"
    echo
    printf "${YELLOW}Choisir un gestionnaire [1-%d]: ${RESET}" "${#managers[@]}"
    read -r choice
    echo
    
    if [[ "$choice" = "0" ]] || [[ -z "$choice" ]]; then
        return 0
    fi
    
    if [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#managers[@]} ]]; then
        local selected_manager="${managers[$choice]}"
        IFS=':' read -r name description command <<< "$selected_manager"
        
        echo -e "${GREEN}Lancement de $description...${RESET}"
        echo
        sleep 1
        
        # S'assurer que le gestionnaire est chargé
        local manager_file="$DOTFILES_FUNCTIONS_DIR/${name}.zsh"
        if [[ -f "$manager_file" ]]; then
            # Source le fichier si nécessaire (s'il n'est pas déjà chargé)
            source "$manager_file" 2>/dev/null || true
        fi
        
        # Appeler directement la fonction du gestionnaire
        # Utiliser "$command" directement plutôt que eval pour éviter les problèmes
        if command -v "$command" >/dev/null 2>&1; then
            "$command"
        else
            # Si la fonction n'existe pas, essayer avec eval en dernier recours
            eval "$command" 2>/dev/null || {
                echo -e "${RED}❌ Erreur: Impossible de lancer $name${RESET}"
                echo "💡 Assurez-vous que le gestionnaire est correctement chargé"
                sleep 2
            }
        fi
        
        # Retourner au menu manman après avoir quitté le gestionnaire
        echo
        read -k 1 "?Appuyez sur une touche pour retourner au menu..."
        manman
    else
        echo -e "${RED}Choix invalide${RESET}"
        sleep 2
        manman
    fi
}

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🎯 MANMAN chargé - Tapez 'manman' ou 'mmg' pour démarrer"

# Alias
alias mmg='manman'
alias managers='manman'

