#!/bin/sh
# =============================================================================
# MANMAN - Manager of Managers (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire centralisé pour tous les gestionnaires (*man)
# Author: Paul Delhomme
# Version: 2.0 - Structure Hybride
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

# DESC: Gestionnaire centralisé pour accéder à tous les gestionnaires interactifs (*man)
# USAGE: manman
# EXAMPLE: manman
manman() {
    # Couleurs (compatibles tous shells)
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    DOTFILES_FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
    if [ -f "$DOTFILES_DIR/scripts/lib/managers_log_posix.sh" ]; then
        # shellcheck source=managers_log_posix.sh
        . "$DOTFILES_DIR/scripts/lib/managers_log_posix.sh"
        managers_log_line "manman" "invoke" "menu" "info" "session interactive"
    fi
    
    # Détecter tous les gestionnaires disponibles (utiliser un fichier temporaire)
    managers_file=$(mktemp)
    index=1
    
    check_manager() {
        local name="$1"
        local desc="$2"
        local cmd="$3"
        if [ -f "$DOTFILES_FUNCTIONS_DIR/${name}.zsh" ] || command -v "$cmd" >/dev/null 2>&1; then
            echo "${index}:${name}:${desc}:${cmd}" >> "$managers_file"
            index=$((index + 1))
        fi
    }
    
    check_manager "pathman" "📁 Gestionnaire PATH" "pathman"
    check_manager "netman" "🌐 Gestionnaire réseau" "netman"
    check_manager "aliaman" "📝 Gestionnaire alias" "aliaman"
    check_manager "miscman" "🔧 Gestionnaire divers" "miscman"
    check_manager "searchman" "🔍 Gestionnaire recherche" "searchman"
    check_manager "cyberman" "🛡️ Gestionnaire cybersécurité" "cyberman"
    check_manager "devman" "💻 Gestionnaire développement" "devman"
    check_manager "gitman" "📦 Gestionnaire Git" "gitman"
    check_manager "helpman" "📚 Gestionnaire aide/documentation" "helpman"
    check_manager "configman" "⚙️ Gestionnaire configuration" "configman"
    check_manager "installman" "📦 Gestionnaire installation" "installman"
    check_manager "moduleman" "⚙️ Gestionnaire modules" "moduleman"
    check_manager "fileman" "📁 Gestionnaire fichiers" "fileman"
    check_manager "virtman" "🖥️ Gestionnaire virtualisation" "virtman"
    check_manager "sshman" "🔐 Gestionnaire SSH" "sshman"
    check_manager "testzshman" "🧪 Gestionnaire tests ZSH/dotfiles" "testzshman"
    check_manager "testman" "🧪 Gestionnaire tests applications" "testman"
    check_manager "doctorman" "🩺 Diagnostic dotfiles / dev" "doctorman"

    clear
    printf "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  MANMAN - Manager of Managers                   ║"
    echo "║           Gestionnaire centralisé des gestionnaires            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    printf "${RESET}\n"
    echo
    
    printf "${YELLOW}Gestionnaires disponibles:${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
    echo
    
    # Compter les managers
    manager_count=$(wc -l < "$managers_file" 2>/dev/null || echo "0")
    if [ "$manager_count" -eq 0 ]; then
        printf "${RED}❌ Aucun gestionnaire disponible${RESET}\n"
        rm -f "$managers_file"
        return 1
    fi
    
    # Afficher les managers avec numérotation
    while IFS=':' read -r num name desc cmd; do
        if [ -n "$name" ]; then
            printf "  ${BOLD}%s${RESET}  %-40s ${CYAN}%s${RESET}\n" "$num" "$desc" "$cmd"
        fi
    done < "$managers_file"
    
    echo
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
    echo "  0) Retour"
    echo
    printf "${YELLOW}Choisir un gestionnaire [1-%d]: ${RESET}" "$manager_count"
    read -r choice
    echo
    
    if [ "$choice" = "0" ] || [ -z "$choice" ]; then
        rm -f "$managers_file"
        return 0
    fi
    
    # Récupérer le manager sélectionné
    selected_line=$(grep "^${choice}:" "$managers_file" 2>/dev/null)
    if [ -z "$selected_line" ]; then
        printf "${RED}Choix invalide${RESET}\n"
        rm -f "$managers_file"
        sleep 2
        manman
        return
    fi
    
    IFS=':' read -r num name description command <<EOF
$selected_line
EOF
    rm -f "$managers_file"
    
    printf "${GREEN}Lancement de $description...${RESET}\n"
    echo
    sleep 1
    
    # S'assurer que le gestionnaire est chargé
    manager_file="$DOTFILES_FUNCTIONS_DIR/${name}.zsh"
    if [ -f "$manager_file" ]; then
        # Source le fichier si nécessaire (s'il n'est pas déjà chargé)
        . "$manager_file" 2>/dev/null || true
    fi
    
    # Appeler directement la fonction du gestionnaire
    if command -v "$command" >/dev/null 2>&1; then
        "$command"
    else
        # Si la fonction n'existe pas, essayer avec eval en dernier recours
        eval "$command" 2>/dev/null || {
            printf "${RED}❌ Erreur: Impossible de lancer $name${RESET}\n"
            echo "💡 Assurez-vous que le gestionnaire est correctement chargé"
            sleep 2
        }
    fi
    
    # Retourner au menu manman après avoir quitté le gestionnaire
    echo
    printf "Appuyez sur une touche pour retourner au menu...\n"
    read -r dummy
    manman
}

