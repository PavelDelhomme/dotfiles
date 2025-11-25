#!/bin/bash

################################################################################
# Menu d'installation - Menu interactif pour installer les applications
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

show_install_menu() {
    clear
    log_section "Menu d'installation"
    
    echo "Applications disponibles:"
    echo "  1. Docker & Docker Compose"
    echo "  2. Go (Golang)"
    echo "  3. Cursor IDE"
    echo "  4. Brave Browser"
    echo "  5. yay (AUR helper - Arch Linux)"
    echo "  6. NVM (Node Version Manager)"
    echo ""
    echo "Outils système:"
    echo "  7. Packages de base (Arch Linux)"
    echo "  8. Gestionnaires de paquets"
    echo "  9. QEMU/KVM complet"
    echo " 10. Neofetch (affichage système)"
    echo ""
    echo "Cybersécurité (cyberman):"
    echo " 11. Outils de cybersécurité complets"
    echo " 12. Dépendances cyberman (jq pour workflows/rapports)"
    echo ""
    echo "🛠️  Managers & Outils:"
    echo " 13. Vérifier/Configurer tous les managers (cyberman, devman, gitman, etc.)"
    echo " 14. Installer dépendances managers (jq, git, etc.)"
    echo ""
    echo "  0. Retour au menu principal"
    echo ""
    
    printf "Votre choix [0-14]: "
    read -r choice
    
    case "$choice" in
        1)
            log_section "Installation Docker"
            bash "$SCRIPT_DIR/install/dev/install_docker.sh"
            ;;
        2)
            log_section "Installation Go"
            bash "$SCRIPT_DIR/install/dev/install_go.sh"
            ;;
        3)
            log_section "Installation Cursor"
            bash "$SCRIPT_DIR/install/apps/install_cursor.sh"
            ;;
        4)
            log_section "Installation Brave"
            bash "$SCRIPT_DIR/install/apps/install_brave.sh"
            ;;
        5)
            log_section "Installation yay"
            bash "$SCRIPT_DIR/install/tools/install_yay.sh"
            ;;
        6)
            log_section "Installation NVM"
            bash "$SCRIPT_DIR/install/tools/install_nvm.sh"
            ;;
        7)
            log_section "Installation packages de base"
            bash "$SCRIPT_DIR/install/system/packages_base.sh"
            ;;
        8)
            log_section "Installation gestionnaires de paquets"
            bash "$SCRIPT_DIR/install/system/package_managers.sh"
            ;;
        9)
            log_section "Installation QEMU/KVM"
            bash "$SCRIPT_DIR/install/tools/install_qemu_full.sh"
            ;;
        10)
            log_section "Installation Neofetch"
            if command -v pacman >/dev/null 2>&1; then
                log_info "Installation via pacman..."
                sudo pacman -S --noconfirm neofetch
            elif command -v apt-get >/dev/null 2>&1; then
                log_info "Installation via apt-get..."
                sudo apt-get install -y neofetch
            elif command -v yum >/dev/null 2>&1; then
                log_info "Installation via yum..."
                sudo yum install -y neofetch
            else
                log_error "Gestionnaire de paquets non supporté"
            fi
            if command -v neofetch >/dev/null 2>&1; then
                log_info "✓ Neofetch installé avec succès"
            else
                log_error "✗ Erreur lors de l'installation de Neofetch"
            fi
            ;;
        11)
            log_section "Installation outils de cybersécurité"
            bash "$SCRIPT_DIR/install/cyber/install_cyber_tools.sh"
            ;;
        12)
            log_section "Installation dépendances cyberman"
            bash "$SCRIPT_DIR/tools/install_cyberman_deps.sh"
            ;;
        13)
            log_section "Vérification et configuration des managers"
            verify_and_configure_managers
            ;;
        14)
            log_section "Installation dépendances managers"
            install_managers_dependencies
            ;;
        0)
            return 0
            ;;
        *)
            log_error "Choix invalide"
            sleep 1
            ;;
    esac
    
    echo ""
    printf "Appuyez sur Entrée pour continuer... "
    read -r dummy
}

# Fonction pour vérifier et configurer tous les managers
verify_and_configure_managers() {
    log_info "Vérification des managers disponibles..."
    echo ""
    
    local managers=(
        "cyberman:Cyberman - Gestionnaire cybersécurité"
        "devman:Devman - Gestionnaire développement"
        "gitman:Gitman - Gestionnaire Git"
        "miscman:Miscman - Gestionnaire outils divers"
        "pathman:Pathman - Gestionnaire PATH"
        "netman:Netman - Gestionnaire réseau"
        "helpman:Helpman - Gestionnaire documentation"
    )
    
    local all_ok=true
    
    for manager_info in "${managers[@]}"; do
        IFS=':' read -r manager_name manager_desc <<< "$manager_info"
        local manager_file="$DOTFILES_DIR/zsh/functions/${manager_name}.zsh"
        
        if [ -f "$manager_file" ]; then
            log_info "✅ $manager_desc: Disponible"
        else
            log_warn "❌ $manager_desc: Fichier manquant ($manager_file)"
            all_ok=false
        fi
    done
    
    echo ""
    if [ "$all_ok" = true ]; then
        log_info "✅ Tous les managers sont disponibles"
        echo ""
        log_info "Commandes disponibles:"
        echo "  - cyberman    : Gestionnaire cybersécurité"
        echo "  - devman      : Gestionnaire développement"
        echo "  - gitman      : Gestionnaire Git"
        echo "  - miscman     : Gestionnaire outils divers"
        echo "  - pathman     : Gestionnaire PATH"
        echo "  - netman      : Gestionnaire réseau"
        echo "  - helpman     : Gestionnaire documentation"
    else
        log_warn "⚠️  Certains managers sont manquants"
        log_info "Vérifiez que les fichiers sont présents dans zsh/functions/"
    fi
}

# Fonction pour installer les dépendances des managers
install_managers_dependencies() {
    log_info "Installation des dépendances pour tous les managers..."
    echo ""
    
    # Dépendances communes
    local deps=("jq" "git")
    
    # Vérifier le gestionnaire de paquets
    if command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get install -y"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
    else
        log_error "Gestionnaire de paquets non supporté"
        return 1
    fi
    
    log_info "Gestionnaire détecté: $PKG_MANAGER"
    echo ""
    
    # Installer les dépendances manquantes
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            log_info "✅ $dep déjà installé"
        else
            log_info "📦 Installation de $dep..."
            $INSTALL_CMD "$dep" || log_warn "⚠️  Échec installation de $dep"
        fi
    done
    
    echo ""
    log_info "✅ Installation des dépendances terminée"
    echo ""
    log_info "Dépendances installées:"
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo "  ✅ $dep"
        else
            echo "  ❌ $dep"
        fi
    done
}

# Boucle principale
while true; do
    show_install_menu
    if [ $? -eq 0 ] && [ "$choice" = "0" ]; then
        break
    fi
done

