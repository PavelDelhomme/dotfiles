#!/bin/zsh
# =============================================================================
# INSTALLATION C++ - Module installman
# =============================================================================
# Description: Installation des outils de développement C++ (G++, CMake, etc.) - multi-distributions
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les utilitaires
INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

# Charger les fonctions utilitaires
[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"

# Chemins
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# =============================================================================
# INSTALLATION OUTILS C++
# =============================================================================
# DESC: Installe les outils de développement C++ (G++, CMake, etc.)
# USAGE: install_cpp_tools
# EXAMPLE: install_cpp_tools
install_cpp_tools() {
    log_step "Installation des outils de développement C++..."
    
    # Détecter la distribution
    local distro=$(detect_distro)
    local install_success=false
    local packages=""
    
    # Définir les paquets selon la distribution
    case "$distro" in
        arch)
            packages="gcc make cmake"
            log_step "Installation via pacman (Arch Linux)..."
            if sudo pacman -S --noconfirm $packages 2>/dev/null; then
                install_success=true
            else
                log_warn "Échec installation via pacman, essai avec yay..."
                if command -v yay &>/dev/null; then
                    yay -S --noconfirm $packages && install_success=true
                fi
            fi
            ;;
        debian|ubuntu)
            packages="g++ make build-essential cmake"
            log_step "Installation via apt (Debian/Ubuntu)..."
            sudo apt-get update && sudo apt-get install -y $packages && install_success=true
            ;;
        fedora)
            packages="gcc-c++ make cmake"
            log_step "Installation via dnf (Fedora)..."
            sudo dnf install -y $packages && install_success=true
            ;;
        alpine)
            packages="g++ make cmake"
            log_step "Installation via apk (Alpine)..."
            sudo apk add --no-cache $packages && install_success=true
            ;;
        gentoo)
            packages="sys-devel/gcc sys-devel/make dev-util/cmake"
            log_step "Installation via emerge (Gentoo)..."
            sudo emerge -q $packages && install_success=true
            ;;
        opensuse)
            packages="gcc-c++ make cmake"
            log_step "Installation via zypper (openSUSE)..."
            sudo zypper install -y $packages && install_success=true
            ;;
        centos)
            packages="gcc-c++ make cmake"
            log_step "Installation via yum (CentOS)..."
            sudo yum install -y $packages && install_success=true
            ;;
        *)
            log_warn "Distribution non reconnue: $distro"
            log_info "Tentative d'installation générique..."
            if install_package "g++" "auto" && install_package "make" "auto" && install_package "cmake" "auto"; then
                install_success=true
            fi
            ;;
    esac
    
    if [ "$install_success" = true ]; then
        # Vérifier l'installation
        local gpp_installed=false
        local make_installed=false
        local cmake_installed=false
        
        if command -v g++ &>/dev/null; then
            gpp_installed=true
            local gpp_version=$(g++ --version | head -n1)
            log_info "✅ G++ installé: $gpp_version"
        fi
        
        if command -v make &>/dev/null; then
            make_installed=true
            local make_version=$(make --version | head -n1)
            log_info "✅ Make installé: $make_version"
        fi
        
        if command -v cmake &>/dev/null; then
            cmake_installed=true
            local cmake_version=$(cmake --version | head -n1)
            log_info "✅ CMake installé: $cmake_version"
        fi
        
        if [ "$gpp_installed" = true ] && [ "$make_installed" = true ]; then
            log_info "✅ Outils C++ installés avec succès!"
            if [ "$cmake_installed" = true ]; then
                log_info "✅ CMake également installé"
            fi
            log_info "💡 Vérifiez avec: g++ --version && make --version && cmake --version"
            log_info "💡 Compilez avec: g++ -o programme programme.cpp"
            log_info "💡 Ou avec CMake: cmake . && make"
            return 0
        else
            log_error "❌ Certains outils ne sont pas installés correctement"
            return 1
        fi
    else
        log_error "❌ Échec de l'installation des outils C++"
        log_warn "💡 Installez manuellement:"
        case "$distro" in
            arch) echo "   sudo pacman -S gcc make cmake" ;;
            debian|ubuntu) echo "   sudo apt-get install build-essential cmake" ;;
            fedora) echo "   sudo dnf install gcc-c++ make cmake" ;;
            alpine) echo "   sudo apk add g++ make cmake" ;;
            gentoo) echo "   sudo emerge gcc make cmake" ;;
            opensuse) echo "   sudo zypper install gcc-c++ make cmake" ;;
            centos) echo "   sudo yum install gcc-c++ make cmake" ;;
            *) echo "   Utilisez le gestionnaire de paquets de votre distribution" ;;
        esac
        return 1
    fi
}

