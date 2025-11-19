#!/bin/bash

################################################################################
# Détection des composants manquants dans dotfiles
# Vérifie tous les éléments installables et retourne ce qui manque
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

MISSING_ITEMS=()

# Fonction pour vérifier et ajouter un élément manquant
check_and_add() {
    local check_type="$1"  # "command", "file", "service", "symlink", "config"
    local name="$2"
    local check_command="$3"
    local install_action="$4"
    
    # Ne pas logger si check_missing.sh est sourcé (éviter doubles logs)
    if eval "$check_command" 2>/dev/null; then
        return 0  # Présent
    else
        MISSING_ITEMS+=("$check_type:$name:$install_action")
        return 1  # Manquant
    fi
}

# Détecter tous les éléments manquants
detect_missing_components() {
    MISSING_ITEMS=()
    
    log_section "Détection des composants manquants"
    
    # Paquets de base
    log_info "Vérification paquets de base..."
    check_and_add "command" "git" "command -v git" "install_base_packages"
    check_and_add "command" "curl" "command -v curl" "install_base_packages"
    check_and_add "command" "wget" "command -v wget" "install_base_packages"
    check_and_add "command" "make" "command -v make" "install_base_packages"
    check_and_add "command" "gcc" "command -v gcc" "install_base_packages"
    check_and_add "command" "zsh" "command -v zsh" "install_base_packages"
    check_and_add "command" "btop" "command -v btop" "install_base_packages"
    
    # Gestionnaires de paquets (Arch seulement)
    if [ -f /etc/arch-release ]; then
        log_info "Vérification gestionnaires de paquets..."
        check_and_add "command" "yay" "command -v yay" "install_yay"
        check_and_add "service" "snapd" "systemctl is-enabled snapd.socket" "install_package_managers"
        check_and_add "command" "flatpak" "command -v flatpak" "install_package_managers"
    fi
    
    # Applications
    log_info "Vérification applications..."
    check_and_add "command" "cursor" "command -v cursor || [ -f /opt/cursor.appimage ] || [ -f \$HOME/.local/bin/cursor ]" "install_cursor"
    check_and_add "command" "brave" "command -v brave || command -v brave-browser" "install_brave"
    
    # Outils de développement
    log_info "Vérification outils de développement..."
    check_and_add "command" "docker" "command -v docker" "install_docker"
    check_and_add "command" "docker-compose" "command -v docker-compose || docker compose version" "install_docker"
    check_and_add "command" "go" "command -v go" "install_go"
    
    # Configuration Git
    log_info "Vérification configuration Git..."
    check_and_add "config" "git_user.name" "[ -n \"\$(git config --global user.name 2>/dev/null)\" ]" "config_git"
    check_and_add "config" "git_user.email" "[ -n \"\$(git config --global user.email 2>/dev/null)\" ]" "config_git"
    
    # Git remote
    log_info "Vérification remote Git..."
    check_and_add "config" "git_remote" "[ -n \"\$(git -C \$HOME/dotfiles remote get-url origin 2>/dev/null)\" ]" "config_git_remote"
    
    # Auto-sync
    log_info "Vérification auto-sync..."
    check_and_add "service" "auto-sync" "systemctl --user is-enabled dotfiles-sync.timer" "install_auto_sync"
    
    # Symlinks
    log_info "Vérification symlinks..."
    check_and_add "symlink" ".zshrc" "[ -L \"\$HOME/.zshrc\" ] && [[ \"\$(readlink \$HOME/.zshrc)\" == *\"dotfiles\"* ]]" "create_symlinks"
    check_and_add "symlink" ".gitconfig" "[ -L \"\$HOME/.gitconfig\" ] && [[ \"\$(readlink \$HOME/.gitconfig)\" == *\"dotfiles\"* ]]" "create_symlinks"
    
    return 0
}

# Afficher les éléments manquants de manière organisée
show_missing_components() {
    detect_missing_components
    
    if [ ${#MISSING_ITEMS[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Tous les composants sont installés!${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️  ${#MISSING_ITEMS[@]} composant(s) manquant(s):${NC}"
    echo ""
    
    # Grouper par catégorie
    local commands=()
    local configs=()
    local services=()
    local symlinks=()
    
    for item in "${MISSING_ITEMS[@]}"; do
        IFS=':' read -r type name action <<< "$item"
        case "$type" in
            command) commands+=("$name ($action)") ;;
            config) configs+=("$name ($action)") ;;
            service) services+=("$name ($action)") ;;
            symlink) symlinks+=("$name ($action)") ;;
        esac
    done
    
    if [ ${#commands[@]} -gt 0 ]; then
        echo -e "${CYAN}📦 Commandes/Outil manquants:${NC}"
        for cmd in "${commands[@]}"; do
            echo "  - $cmd"
        done
        echo ""
    fi
    
    if [ ${#configs[@]} -gt 0 ]; then
        echo -e "${CYAN}⚙️  Configurations manquantes:${NC}"
        for cfg in "${configs[@]}"; do
            echo "  - $cfg"
        done
        echo ""
    fi
    
    if [ ${#services[@]} -gt 0 ]; then
        echo -e "${CYAN}🔧 Services manquants:${NC}"
        for svc in "${services[@]}"; do
            echo "  - $svc"
        done
        echo ""
    fi
    
    if [ ${#symlinks[@]} -gt 0 ]; then
        echo -e "${CYAN}🔗 Symlinks manquants:${NC}"
        for link in "${symlinks[@]}"; do
            echo "  - $link"
        done
        echo ""
    fi
    
    return 1
}

# Obtenir la liste des éléments manquants (pour scripts)
get_missing_list() {
    detect_missing_components
    printf '%s\n' "${MISSING_ITEMS[@]}"
}

