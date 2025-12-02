#!/bin/zsh
# =============================================================================
# INSTALLATION JAVA - Module installman
# =============================================================================
# Description: Installation de Java OpenJDK (versions 8, 11, 17, 21, 25)
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
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# INSTALLATION JAVA GÉNÉRIQUE
# =============================================================================
# DESC: Installe une version spécifique de Java OpenJDK
# USAGE: install_java_version <version>
# EXAMPLE: install_java_version 25
install_java_version() {
    local java_version="$1"
    
    if [ -z "$java_version" ]; then
        log_error "Version Java non spécifiée"
        return 1
    fi
    
    log_step "Installation de Java ${java_version} OpenJDK..."
    
    # Détection de la distribution
    local distro=$(detect_distro)
    
    case "$distro" in
        arch)
            # Déterminer le nom du paquet selon la version
            local package_name=""
            case "$java_version" in
                8)
                    package_name="jdk8-openjdk"
                    ;;
                11)
                    package_name="jdk11-openjdk"
                    ;;
                17)
                    package_name="jdk17-openjdk"
                    ;;
                21)
                    package_name="jdk21-openjdk"
                    ;;
                25)
                    package_name="jdk-openjdk"
                    ;;
                *)
                    log_error "Version Java non supportée: $java_version"
                    log_info "Versions supportées: 8, 11, 17, 21, 25"
                    return 1
                    ;;
            esac
            
            log_step "Installation de $package_name (Arch Linux)..."
            sudo pacman -S --noconfirm "$package_name" || {
                log_error "Échec de l'installation de Java $java_version"
                return 1
            }
            
            # Configurer le PATH selon la version
            local java_path=""
            if [ "$java_version" = "25" ]; then
                # Java 25 utilise jdk-openjdk - chercher le chemin réel
                # Sur Arch, Java 25 peut être dans différents emplacements
                if [ -d "/usr/lib/jvm/java-25-openjdk/bin" ]; then
                    java_path="/usr/lib/jvm/java-25-openjdk/bin"
                elif [ -d "/usr/lib/jvm/default/bin" ]; then
                    java_path="/usr/lib/jvm/default/bin"
                elif [ -d "/usr/lib/jvm/java-openjdk/bin" ]; then
                    java_path="/usr/lib/jvm/java-openjdk/bin"
                else
                    # Chercher dans /usr/lib/jvm
                    java_path=$(find /usr/lib/jvm -maxdepth 2 -type d -name "*openjdk*" -o -name "default" 2>/dev/null | grep -E "(openjdk|default)" | head -1)
                    if [ -n "$java_path" ] && [ -d "$java_path/bin" ]; then
                        java_path="$java_path/bin"
                    else
                        java_path="/usr/lib/jvm/default/bin"
                    fi
                fi
            else
                java_path="/usr/lib/jvm/java-${java_version}-openjdk/bin"
            fi
            
            if [ -d "$java_path" ] && [ -x "$java_path/java" ]; then
                add_path_to_env "$java_path" "Java ${java_version} OpenJDK"
                log_info "✓ Java ${java_version} installé et configuré avec succès!"
                log_info "💡 Rechargez votre shell (exec zsh) pour utiliser Java ${java_version}"
                return 0
            else
                log_warn "Chemin Java non trouvé automatiquement: $java_path"
                log_info "Java ${java_version} est installé, mais le PATH doit être configuré manuellement"
                log_info "Cherchez le chemin Java avec: find /usr/lib/jvm -name java"
                return 0
            fi
            ;;
        debian)
            log_error "Installation Java pour Debian/Ubuntu non encore implémentée dans installman"
            log_info "Utilisez le script: scripts/install/dev/install_java${java_version}.sh"
            return 1
            ;;
        fedora)
            log_error "Installation Java pour Fedora non encore implémentée dans installman"
            log_info "Utilisez le script: scripts/install/dev/install_java${java_version}.sh"
            return 1
            ;;
        *)
            log_error "Distribution non supportée: $distro"
            return 1
            ;;
    esac
}

# Fonctions spécifiques pour chaque version
install_java8() {
    install_java_version 8
}

install_java11() {
    install_java_version 11
}

install_java17() {
    install_java_version 17
}

install_java21() {
    install_java_version 21
}

install_java25() {
    install_java_version 25
}

