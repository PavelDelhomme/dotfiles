#!/bin/zsh
# =============================================================================
# INSTALLATION EMACS + DOOM EMACS - Module installman
# =============================================================================
# Description: Installation d'Emacs, Doom Emacs et configuration de base
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/path_utils.sh" ] && source "$INSTALLMAN_UTILS_DIR/path_utils.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# CONFIGURATION EMACS DE BASE
# =============================================================================
# DESC: Configure Emacs de base avec mode sombre, numéros de ligne, outils dev
# USAGE: configure_emacs_base
# EXAMPLE: configure_emacs_base
configure_emacs_base() {
    log_step "Configuration d'Emacs de base pour le développement..."
    
    local emacs_config="$HOME/.emacs"
    local emacs_dir="$HOME/.emacs.d"
    
    # Créer le répertoire .emacs.d si nécessaire
    mkdir -p "$emacs_dir"
    
    # Configuration Emacs de base avec mode sombre, numéros de ligne, outils dev
    log_step "Création de la configuration Emacs de base..."
    cat > "$emacs_config" <<'EMACSCONF'
;; Configuration Emacs de base pour le développement
;; Mode sombre, numéros de ligne, outils de développement

;; Désactiver la barre d'outils et le menu
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Activer les numéros de ligne
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Thème sombre
(load-theme 'modus-vivendi t)  ; Thème sombre par défaut
;; Alternative: (load-theme 'wombat t) ou (load-theme 'dracula t)

;; Configuration de base pour le développement
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default python-indent-offset 4)

;; Activer le mode parenthèses correspondantes
(show-paren-mode t)
(setq show-paren-delay 0)

;; Activer le mode auto-complétion
(electric-pair-mode t)

;; Activer le mode auto-save
(setq auto-save-default t)
(setq backup-inhibited t)

;; Configuration pour différents langages
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'prog-mode-hook 'electric-pair-mode)

;; Couleurs personnalisées
(set-face-attribute 'default nil :height 110)
(set-face-attribute 'line-number nil :foreground "#666666")
(set-face-attribute 'line-number-current-line nil :foreground "#ffffff" :background "#333333")

;; Raccourcis utiles
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c C-c") 'comment-region)
(global-set-key (kbd "C-c C-u") 'uncomment-region)

;; Message de bienvenue
(message "Configuration Emacs chargée - Mode développement activé")
EMACSCONF

    log_info "✓ Configuration Emacs de base créée dans ~/.emacs"
    log_info "  - Mode sombre activé"
    log_info "  - Numéros de ligne activés"
    log_info "  - Outils de développement configurés"
    
    return 0
}

# =============================================================================
# INSTALLATION EMACS + DOOM EMACS
# =============================================================================
# DESC: Installe Emacs, Doom Emacs et configure Emacs de base
# USAGE: install_emacs
# EXAMPLE: install_emacs
install_emacs() {
    log_step "Installation d'Emacs, Doom Emacs et configuration de base..."
    
    # Détection de la distribution
    local distro=$(detect_distro)
    
    # Installation d'Emacs selon la distribution
    if ! command -v emacs &>/dev/null; then
        log_step "Installation d'Emacs..."
        case "$distro" in
            arch)
                sudo pacman -S --noconfirm emacs || {
                    log_error "Échec de l'installation d'Emacs"
                    return 1
                }
                ;;
            debian)
                sudo apt update
                sudo apt install -y emacs || {
                    log_error "Échec de l'installation d'Emacs"
                    return 1
                }
                ;;
            fedora)
                sudo dnf install -y emacs || {
                    log_error "Échec de l'installation d'Emacs"
                    return 1
                }
                ;;
            *)
                log_error "Distribution non supportée: $distro"
                return 1
                ;;
        esac
    else
        log_info "Emacs est déjà installé: $(emacs --version | head -n1)"
    fi
    
    # Configuration Emacs de base
    configure_emacs_base
    
    # Installation de Doom Emacs
    log_step "Installation de Doom Emacs..."
    local emacs_dir="$HOME/.emacs.d"
    local doom_dir="$HOME/.doom.d"
    
    if [ -d "$emacs_dir" ] && [ -f "$emacs_dir/bin/doom" ]; then
        log_info "Doom Emacs est déjà installé"
        read -p "Réinstaller Doom Emacs? (o/N): " reinstall_doom
        if [[ "$reinstall_doom" =~ ^[oO]$ ]]; then
            rm -rf "$emacs_dir" "$doom_dir"
        else
            log_info "Installation Doom ignorée"
            return 0
        fi
    fi
    
    if [ ! -d "$emacs_dir" ] || [ ! -f "$emacs_dir/bin/doom" ]; then
        log_step "Clonage de Doom Emacs..."
        git clone --depth 1 https://github.com/doomemacs/doomemacs "$emacs_dir" || {
            log_error "Échec du clonage de Doom Emacs"
            return 1
        }
        
        log_step "Installation de Doom Emacs..."
        "$emacs_dir/bin/doom" install --yes || {
            log_warn "Installation Doom terminée avec des avertissements"
        }
    fi
    
    # Ajouter Doom Emacs au PATH
    local doom_bin="$emacs_dir/bin"
    if [ -d "$doom_bin" ]; then
        add_path_to_env "$doom_bin" "Doom Emacs"
        log_info "✓ Emacs et Doom Emacs installés et configurés avec succès!"
        log_info "  - Configuration de base créée (~/.emacs)"
        log_info "  - Mode sombre activé"
        log_info "  - Numéros de ligne activés"
        log_info "  - Outils de développement configurés"
        log_info "  - Doom Emacs installé"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Doom Emacs"
        return 0
    fi
    
    return 1
}

