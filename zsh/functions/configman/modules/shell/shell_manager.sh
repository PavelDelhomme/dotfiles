#!/bin/bash

################################################################################
# Shell Manager - Gestion unifiée des shells (Zsh, Fish, Bash)
# Permet d'installer, configurer et définir le shell par défaut
################################################################################

set +e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    return 1 2/dev/null || exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

################################################################################
# FONCTIONS UTILITAIRES
################################################################################

detect_installed_shells() {
    local shells=()
    
    if command -v zsh &>/dev/null; then
        shells+=("zsh:$(which zsh)")
    fi
    
    if command -v fish &>/dev/null; then
        shells+=("fish:$(which fish)")
    fi
    
    if command -v bash &>/dev/null; then
        shells+=("bash:$(which bash)")
    fi
    
    echo "${shells[@]}"
}

get_current_shell() {
    local current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    echo "$current_shell"
}

install_shell() {
    local shell_name="$1"
    
    case "$shell_name" in
        zsh)
            log_info "Installation de Zsh..."
            if command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm zsh
            elif command -v apt-get &>/dev/null; then
                sudo apt-get install -y zsh
            elif command -v yum &>/dev/null; then
                sudo yum install -y zsh
            else
                log_error "Gestionnaire de paquets non supporté"
                return 1
            fi
            ;;
        fish)
            log_info "Installation de Fish..."
            if command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm fish
            elif command -v apt-get &>/dev/null; then
                sudo apt-get install -y fish
            elif command -v yum &>/dev/null; then
                sudo yum install -y fish
            else
                log_error "Gestionnaire de paquets non supporté"
                return 1
            fi
            ;;
        bash)
            log_info "Bash est généralement déjà installé"
            if ! command -v bash &>/dev/null; then
                if command -v pacman &>/dev/null; then
                    sudo pacman -S --noconfirm bash
                elif command -v apt-get &>/dev/null; then
                    sudo apt-get install -y bash
                fi
            fi
            ;;
        *)
            log_error "Shell non supporté: $shell_name"
            return 1
            ;;
    esac
}

set_default_shell() {
    local shell_path="$1"
    local shell_name="$2"
    
    if [ ! -f "$shell_path" ]; then
        log_error "Shell non trouvé: $shell_path"
        return 1
    fi
    
    # Vérifier que le shell est dans /etc/shells
    if ! grep -q "$shell_path" /etc/shells 2>/dev/null; then
        log_info "Ajout de $shell_path à /etc/shells..."
        echo "$shell_path" | sudo tee -a /etc/shells > /dev/null
    fi
    
    log_info "Changement du shell par défaut vers $shell_name..."
    if chsh -s "$shell_path"; then
        log_info "✓ Shell par défaut changé vers $shell_name"
        log_warn "⚠️  Vous devez vous déconnecter et reconnecter pour que le changement prenne effet"
        return 0
    else
        log_error "✗ Erreur lors du changement de shell"
        return 1
    fi
}

configure_shell() {
    local shell_name="$1"
    
    log_section "Configuration de $shell_name"
    
    case "$shell_name" in
        zsh)
            # Créer le symlink .zshrc si nécessaire
            if [ ! -L "$HOME/.zshrc" ] || [ ! -f "$HOME/.zshrc" ]; then
                if [ -f "$HOME/.zshrc" ]; then
                    log_warn "Fichier .zshrc existe déjà"
                    printf "Créer un backup et remplacer? (o/n) [défaut: n]: "
                    read -r backup
                    if [[ "$backup" =~ ^[oO]$ ]]; then
                        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
                        mkdir -p "$BACKUP_DIR"
                        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
                        log_info "✓ Backup créé: $BACKUP_DIR/.zshrc"
                        rm "$HOME/.zshrc"
                    else
                        return 0
                    fi
                fi
                
                # Créer le symlink vers .zshrc (wrapper unifié)
                if [ -f "$DOTFILES_DIR/.zshrc" ]; then
                    ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
                    log_info "✓ Symlink .zshrc créé (config unifiée)"
                elif [ -f "$DOTFILES_DIR/zshrc" ]; then
                    ln -s "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
                    log_info "✓ Symlink .zshrc créé (legacy)"
                elif [ -f "$DOTFILES_DIR/zsh/zshrc_custom" ]; then
                    ln -s "$DOTFILES_DIR/zsh/zshrc_custom" "$HOME/.zshrc"
                    log_info "✓ Symlink .zshrc créé (custom)"
                fi
            else
                log_info "✓ .zshrc déjà configuré"
            fi
            ;;
        fish)
            # Créer le symlink config.fish si nécessaire
            FISH_CONFIG_DIR="$HOME/.config/fish"
            mkdir -p "$FISH_CONFIG_DIR"
            
            if [ ! -L "$FISH_CONFIG_DIR/config.fish" ] || [ ! -f "$FISH_CONFIG_DIR/config.fish" ]; then
                if [ -f "$FISH_CONFIG_DIR/config.fish" ]; then
                    log_warn "Fichier config.fish existe déjà"
                    printf "Créer un backup et remplacer? (o/n) [défaut: n]: "
                    read -r backup
                    if [[ "$backup" =~ ^[oO]$ ]]; then
                        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
                        mkdir -p "$BACKUP_DIR"
                        cp "$FISH_CONFIG_DIR/config.fish" "$BACKUP_DIR/config.fish"
                        log_info "✓ Backup créé: $BACKUP_DIR/config.fish"
                        rm "$FISH_CONFIG_DIR/config.fish"
                    else
                        return 0
                    fi
                fi
                
                # Créer le symlink (priorité au wrapper unifié)
                if [ -f "$DOTFILES_DIR/.config/fish/config.fish" ]; then
                    ln -s "$DOTFILES_DIR/.config/fish/config.fish" "$FISH_CONFIG_DIR/config.fish"
                    log_info "✓ Symlink config.fish créé (config unifiée)"
                elif [ -f "$DOTFILES_DIR/fish/config_custom.fish" ]; then
                    ln -s "$DOTFILES_DIR/fish/config_custom.fish" "$FISH_CONFIG_DIR/config.fish"
                    log_info "✓ Symlink config.fish créé (custom)"
                fi
            else
                log_info "✓ config.fish déjà configuré"
            fi
            ;;
        bash)
            # Créer le symlink .bashrc si nécessaire
            if [ ! -L "$HOME/.bashrc" ] || [ ! -f "$HOME/.bashrc" ]; then
                if [ -f "$HOME/.bashrc" ]; then
                    log_warn "Fichier .bashrc existe déjà"
                    printf "Créer un backup et remplacer? (o/n) [défaut: n]: "
                    read -r backup
                    if [[ "$backup" =~ ^[oO]$ ]]; then
                        BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
                        mkdir -p "$BACKUP_DIR"
                        cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc"
                        log_info "✓ Backup créé: $BACKUP_DIR/.bashrc"
                        rm "$HOME/.bashrc"
                    else
                        return 0
                    fi
                fi
                
                # Créer le symlink vers .bashrc (wrapper unifié)
                if [ -f "$DOTFILES_DIR/.bashrc" ]; then
                    ln -s "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
                    log_info "✓ Symlink .bashrc créé (config unifiée)"
                elif [ -f "$DOTFILES_DIR/zshrc" ]; then
                    # Le wrapper zshrc détecte aussi bash
                    ln -s "$DOTFILES_DIR/zshrc" "$HOME/.bashrc"
                    log_info "✓ Symlink .bashrc créé (legacy wrapper)"
                fi
            else
                log_info "✓ .bashrc déjà configuré"
            fi
            ;;
    esac
}

################################################################################
# MENU INTERACTIF
################################################################################

show_shell_menu() {
    clear
    log_section "Gestionnaire de Shell"
    
    CURRENT_SHELL=$(get_current_shell)
    log_info "Shell actuel: $CURRENT_SHELL ($SHELL)"
    echo ""
    
    echo "Shells disponibles:"
    local shells=($(detect_installed_shells))
    local index=1
    declare -A shell_paths
    
    for shell_entry in "${shells[@]}"; do
        IFS=':' read -r shell_name shell_path <<< "$shell_entry"
        shell_paths["$shell_name"]="$shell_path"
        local marker=""
        if [ "$shell_name" = "$CURRENT_SHELL" ]; then
            marker=" (actuel)"
        fi
        echo "  $index. $shell_name: $shell_path$marker"
        ((index++))
    done
    echo ""
    
    echo "Actions disponibles:"
    echo "  $index. Installer un shell (zsh/fish/bash)"
    ((index++))
    echo "  $index. Configurer un shell (créer les symlinks)"
    ((index++))
    echo "  $index. Changer le shell par défaut"
    ((index++))
    echo "  $index. Retour au menu principal"
    echo ""
    
    printf "Votre choix [1-$index]: "
    read -r choice
    
    local shell_count=${#shells[@]}
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le "$shell_count" ]; then
        # Afficher les informations sur le shell sélectionné
        local selected_entry="${shells[$((choice-1))]}"
        IFS=':' read -r shell_name shell_path <<< "$selected_entry"
        log_section "Informations: $shell_name"
        log_info "Chemin: $shell_path"
        log_info "Version: $($shell_path --version 2>/dev/null | head -n1 || echo "non disponible")"
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read -r dummy
    elif [ "$choice" -eq $((shell_count+1)) ]; then
        # Installer un shell
        log_section "Installation d'un shell"
        echo "Quel shell voulez-vous installer?"
        echo "  1. zsh"
        echo "  2. fish"
        echo "  3. bash"
        printf "Votre choix [1-3]: "
        read -r install_choice
        case "$install_choice" in
            1) install_shell "zsh" ;;
            2) install_shell "fish" ;;
            3) install_shell "bash" ;;
            *) log_error "Choix invalide" ;;
        esac
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read -r dummy
    elif [ "$choice" -eq $((shell_count+2)) ]; then
        # Configurer un shell
        log_section "Configuration d'un shell"
        echo "Quel shell voulez-vous configurer?"
        echo "  1. zsh"
        echo "  2. fish"
        echo "  3. bash"
        printf "Votre choix [1-3]: "
        read -r config_choice
        case "$config_choice" in
            1) configure_shell "zsh" ;;
            2) configure_shell "fish" ;;
            3) configure_shell "bash" ;;
            *) log_error "Choix invalide" ;;
        esac
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read -r dummy
    elif [ "$choice" -eq $((shell_count+3)) ]; then
        # Changer le shell par défaut
        log_section "Changer le shell par défaut"
        echo "Vers quel shell voulez-vous changer?"
        local change_index=1
        for shell_entry in "${shells[@]}"; do
            IFS=':' read -r shell_name shell_path <<< "$shell_entry"
            echo "  $change_index. $shell_name ($shell_path)"
            ((change_index++))
        done
        printf "Votre choix [1-$shell_count]: "
        read -r change_choice
        
        if [ "$change_choice" -ge 1 ] && [ "$change_choice" -le "$shell_count" ]; then
            local selected_entry="${shells[$((change_choice-1))]}"
            IFS=':' read -r shell_name shell_path <<< "$selected_entry"
            set_default_shell "$shell_path" "$shell_name"
        else
            log_error "Choix invalide"
        fi
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read -r dummy
    elif [ "$choice" -eq $((shell_count+4)) ]; then
        return 0
    else
        log_error "Choix invalide"
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read -r dummy
    fi
}

################################################################################
# MODE AUTOMATIQUE (pour setup.sh)
################################################################################

if [ "$1" = "menu" ]; then
    while true; do
        show_shell_menu
    done
elif [ -n "$1" ]; then
    # Mode automatique avec paramètres
    case "$1" in
        install)
            if [ -z "$2" ]; then
                log_error "Usage: $0 install <zsh|fish|bash>"
                return 1 2/dev/null || exit 1
            fi
            install_shell "$2"
            ;;
        configure)
            if [ -z "$2" ]; then
                log_error "Usage: $0 configure <zsh|fish|bash>"
                return 1 2/dev/null || exit 1
            fi
            configure_shell "$2"
            ;;
        set-default)
            if [ -z "$2" ]; then
                log_error "Usage: $0 set-default <zsh|fish|bash>"
                return 1 2/dev/null || exit 1
            fi
            local shell_path=$(which "$2" 2>/dev/null)
            if [ -z "$shell_path" ]; then
                log_error "Shell $2 non trouvé. Installez-le d'abord."
                return 1 2/dev/null || exit 1
            fi
            set_default_shell "$shell_path" "$2"
            ;;
        *)
            log_error "Commande inconnue: $1"
            echo "Usage: $0 [menu|install|configure|set-default] [shell_name]"
            return 1 2/dev/null || exit 1
            ;;
    esac
else
    # Mode interactif par défaut
    show_shell_menu
fi

