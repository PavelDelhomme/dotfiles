#!/bin/zsh
# =============================================================================
# INSTALLATION HANDBRAKE - Module installman
# =============================================================================
# Description: Installation de HandBrake CLI et GUI (si interface graphique disponible)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# =============================================================================
# DÉTECTION INTERFACE GRAPHIQUE
# =============================================================================
has_gui() {
    # Vérifier X11
    if [ -n "$DISPLAY" ] && [ "$DISPLAY" != ":0" ]; then
        return 0
    fi
    
    # Vérifier Wayland
    if [ -n "$WAYLAND_DISPLAY" ]; then
        return 0
    fi
    
    # Vérifier si on est dans un environnement graphique (systemd)
    if [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ] || [ "$XDG_SESSION_TYPE" = "x11" ]; then
        return 0
    fi
    
    # Vérifier si on peut lancer une commande graphique
    if command -v xset &>/dev/null || command -v wlr-randr &>/dev/null; then
        return 0
    fi
    
    return 1
}

# =============================================================================
# INSTALLATION HANDBRAKE
# =============================================================================
# DESC: Installe HandBrake CLI et GUI (si interface graphique disponible)
# USAGE: install_handbrake
# EXAMPLE: install_handbrake
install_handbrake() {
    log_step "Installation de HandBrake..."
    
    # Détecter la distribution
    local distro=$(detect_distro 2>/dev/null || echo "arch")
    
    # Vérifier si HandBrake CLI est déjà installé
    if command -v HandBrakeCLI &>/dev/null; then
        log_info "HandBrake CLI est déjà installé"
    else
        log_info "Installation de HandBrake CLI..."
        
        case "$distro" in
            arch|manjaro)
                # Vérifier si yay est disponible
                if command -v yay &>/dev/null; then
                    log_info "Installation via AUR (yay)..."
                    yay -S --noconfirm handbrake-cli || {
                        log_error "Échec de l'installation de handbrake-cli via yay"
                        return 1
                    }
                elif command -v pamac &>/dev/null; then
                    log_info "Installation via AUR (pamac)..."
                    pamac build --no-confirm handbrake-cli || {
                        log_error "Échec de l'installation de handbrake-cli via pamac"
                        return 1
                    }
                else
                    log_error "Aucun helper AUR trouvé (yay ou pamac requis)"
                    log_info "Installez yay ou pamac puis réessayez"
                    return 1
                fi
                ;;
            debian|ubuntu)
                log_info "Installation via apt..."
                sudo apt update && sudo apt install -y handbrake-cli || {
                    log_error "Échec de l'installation de handbrake-cli"
                    return 1
                }
                ;;
            fedora)
                log_info "Installation via dnf..."
                sudo dnf install -y HandBrake-cli || {
                    log_error "Échec de l'installation de HandBrake-cli"
                    return 1
                }
                ;;
            *)
                log_warn "Distribution non supportée: $distro"
                log_info "Installez handbrake-cli manuellement"
                return 1
                ;;
        esac
        
        log_info "✓ HandBrake CLI installé"
    fi
    
    # Installer libdvdcss pour les DVD chiffrés (Arch/Manjaro)
    if [ "$distro" = "arch" ] || [ "$distro" = "manjaro" ]; then
        if ! pacman -Q libdvdcss &>/dev/null 2>&1; then
            log_info "Installation de libdvdcss (pour DVD chiffrés)..."
            if command -v yay &>/dev/null; then
                yay -S --noconfirm libdvdcss || log_warn "Impossible d'installer libdvdcss"
            elif command -v pamac &>/dev/null; then
                pamac build --no-confirm libdvdcss || log_warn "Impossible d'installer libdvdcss"
            else
                log_warn "libdvdcss non installé (yay ou pamac requis)"
            fi
        fi
    fi
    
    # Installer dvdbackup (requis pour le script de ripping)
    if ! command -v dvdbackup &>/dev/null; then
        log_info "Installation de dvdbackup (pour ripping DVD)..."
        case "$distro" in
            arch|manjaro)
                sudo pacman -S --noconfirm dvdbackup || log_warn "Impossible d'installer dvdbackup"
                ;;
            debian|ubuntu)
                sudo apt install -y dvdbackup || log_warn "Impossible d'installer dvdbackup"
                ;;
            fedora)
                sudo dnf install -y dvdbackup || log_warn "Impossible d'installer dvdbackup"
                ;;
        esac
    fi
    
    # Installer HandBrake GUI si interface graphique disponible
    if has_gui; then
        log_info "Interface graphique détectée, installation de HandBrake GUI..."
        
        if command -v HandBrake &>/dev/null || command -v handbrake &>/dev/null; then
            log_info "HandBrake GUI est déjà installé"
        else
            case "$distro" in
                arch|manjaro)
                    if command -v yay &>/dev/null; then
                        log_info "Installation de HandBrake GUI via AUR (yay)..."
                        yay -S --noconfirm handbrake || {
                            log_warn "Échec de l'installation de HandBrake GUI via yay"
                            log_info "HandBrake CLI reste disponible"
                        }
                    elif command -v pamac &>/dev/null; then
                        log_info "Installation de HandBrake GUI via AUR (pamac)..."
                        pamac build --no-confirm handbrake || {
                            log_warn "Échec de l'installation de HandBrake GUI via pamac"
                            log_info "HandBrake CLI reste disponible"
                        }
                    fi
                    ;;
                debian|ubuntu)
                    log_info "Installation de HandBrake GUI via apt..."
                    sudo apt install -y handbrake || {
                        log_warn "Échec de l'installation de HandBrake GUI"
                        log_info "HandBrake CLI reste disponible"
                    }
                    ;;
                fedora)
                    log_info "Installation de HandBrake GUI via dnf..."
                    sudo dnf install -y HandBrake-gui || {
                        log_warn "Échec de l'installation de HandBrake GUI"
                        log_info "HandBrake CLI reste disponible"
                    }
                    ;;
            esac
            
            if command -v HandBrake &>/dev/null || command -v handbrake &>/dev/null; then
                log_info "✓ HandBrake GUI installé"
            fi
        fi
    else
        log_info "Aucune interface graphique détectée, HandBrake GUI non installé"
        log_info "HandBrake CLI est disponible pour utilisation en ligne de commande"
    fi
    
    log_info "✓ Installation HandBrake terminée!"
    log_info "  - HandBrake CLI: disponible"
    if has_gui && (command -v HandBrake &>/dev/null || command -v handbrake &>/dev/null); then
        log_info "  - HandBrake GUI: disponible"
    fi
    
    local dvdbackup_status="non installé"
    if command -v dvdbackup &>/dev/null; then
        dvdbackup_status="installé"
    fi
    log_info "  - dvdbackup: $dvdbackup_status"
    
    if [ "$distro" = "arch" ] || [ "$distro" = "manjaro" ]; then
        local libdvdcss_status="non installé"
        if pacman -Q libdvdcss &>/dev/null 2>&1; then
            libdvdcss_status="installé"
        fi
        log_info "  - libdvdcss: $libdvdcss_status"
    fi
    
    return 0
}

