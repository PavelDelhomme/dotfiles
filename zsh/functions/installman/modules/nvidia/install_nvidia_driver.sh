#!/bin/zsh
# =============================================================================
# PILOTES NVIDIA - Module installman
# =============================================================================
# Description: Détection GPU NVIDIA (lspci) et installation des pilotes selon la distro
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

INSTALLMAN_DIR="${INSTALLMAN_DIR:-$HOME/dotfiles/zsh/functions/installman}"
INSTALLMAN_UTILS_DIR="$INSTALLMAN_DIR/utils"

[ -f "$INSTALLMAN_UTILS_DIR/logger.sh" ] && source "$INSTALLMAN_UTILS_DIR/logger.sh"
[ -f "$INSTALLMAN_UTILS_DIR/distro_detect.sh" ] && source "$INSTALLMAN_UTILS_DIR/distro_detect.sh"
[ -f "$INSTALLMAN_UTILS_DIR/package_manager.sh" ] && source "$INSTALLMAN_UTILS_DIR/package_manager.sh"
[ -f "$INSTALLMAN_UTILS_DIR/check_installed.sh" ] && source "$INSTALLMAN_UTILS_DIR/check_installed.sh"
[ -f "$INSTALLMAN_UTILS_DIR/installman_confirm.sh" ] && source "$INSTALLMAN_UTILS_DIR/installman_confirm.sh"

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# DESC: Détecte un GPU NVIDIA (exclut souvent l'audio HDMI)
# USAGE: installman_has_nvidia_gpu ; echo $?
installman_has_nvidia_gpu() {
    if ! command -v lspci &>/dev/null; then
        return 1
    fi
    # Contrôleur VGA / 3D avec vendeur NVIDIA (PCI 10de)
    if lspci -nn 2>/dev/null | grep -iE 'vga|3d|display' | grep -qiE 'nvidia|\[10de:'; then
        return 0
    fi
    if lspci -nn 2>/dev/null | grep -qi '\[10de:' && lspci 2>/dev/null | grep -qi nvidia; then
        return 0
    fi
    return 1
}

# DESC: Active RPM Fusion (free + nonfree) pour Fedora / EL compatible
_install_nvidia_rpmfusion_nonfree() {
    [[ -f /etc/os-release ]] || return 1
    # shellcheck disable=SC1091
    . /etc/os-release
    local id="${ID:-}"
    id="${id:l}"
    if [[ "$id" == "fedora" ]]; then
        local base="${VERSION_ID:-}"
        [[ -z "$base" ]] && return 1
        sudo dnf install -y \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${base}.noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${base}.noarch.rpm" 2>/dev/null
        return $?
    fi
    if [[ "$id" == "centos" || "$id" == "rhel" || "$id" == "rocky" || "$id" == "almalinux" ]]; then
        local el="${VERSION_ID%%.*}"
        [[ -z "$el" ]] && return 1
        sudo dnf install -y \
            "https://download1.rpmfusion.org/free/el/rpmfusion-free-release-el${el}.noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-el${el}.noarch.rpm" 2>/dev/null
        return $?
    fi
    return 1
}

# DESC: Installe les pilotes NVIDIA propriétaires (paquets distro)
# USAGE: install_nvidia_driver
install_nvidia_driver() {
    log_step "Pilotes NVIDIA — détection matériel..."

    if ! installman_has_nvidia_gpu; then
        log_warn "Aucun GPU NVIDIA détecté (lspci). Pas d'installation des pilotes NVIDIA."
        return 1
    fi
    log_info "GPU NVIDIA détecté :"
    lspci -nn 2>/dev/null | grep -iE 'nvidia|\[10de:' | head -n5 || true

    if ! installman_confirm "Installer les pilotes propriétaires NVIDIA (sudo, redémarrage souvent nécessaire) ?"; then
        log_info "Annulé."
        return 1
    fi

    if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
        log_info "nvidia-smi répond déjà : $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n1 || echo ok)"
        read "reinstall?Réinstaller / réappliquer les paquets ? (o/N): "
        if [[ ! "$reinstall" =~ ^[oOyY]$ ]]; then
            return 0
        fi
    fi

    local distro
    distro=$(detect_distro)
    local install_success=false

    case "$distro" in
        arch|manjaro)
            log_step "Arch / Manjaro — pilotes NVIDIA..."
            if command -v mhwd &>/dev/null; then
                if sudo mhwd -a pci nonfree 0300 2>/dev/null; then
                    install_success=true
                fi
            fi
            if [[ "$install_success" != true ]]; then
                if sudo pacman -S --needed --noconfirm nvidia nvidia-utils nvidia-settings libvdpau 2>/dev/null; then
                    install_success=true
                elif sudo pacman -S --needed --noconfirm nvidia-open nvidia-utils nvidia-settings 2>/dev/null; then
                    log_info "Paquets nvidia-open installés (noyau récent / open kernel)."
                    install_success=true
                fi
            fi
            ;;
        debian|ubuntu)
            log_step "Debian / Ubuntu — pilotes NVIDIA..."
            if [[ "$distro" == ubuntu ]] && command -v ubuntu-drivers &>/dev/null; then
                sudo ubuntu-drivers autoinstall && install_success=true
            elif sudo apt-get update && sudo apt-get install -y ubuntu-drivers-common 2>/dev/null && command -v ubuntu-drivers &>/dev/null; then
                sudo ubuntu-drivers autoinstall && install_success=true
            elif sudo apt-get install -y nvidia-driver firmware-nvidia-gsp 2>/dev/null; then
                install_success=true
            elif sudo apt-get install -y nvidia-driver 2>/dev/null; then
                install_success=true
            fi
            ;;
        fedora|centos)
            log_step "Fedora / EL — RPM Fusion + akmod-nvidia..."
            if _install_nvidia_rpmfusion_nonfree && sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda 2>/dev/null; then
                install_success=true
            elif sudo dnf install -y akmod-nvidia 2>/dev/null; then
                install_success=true
            fi
            ;;
        gentoo)
            log_warn "Gentoo : émergez x11-drivers/nvidia-drivers (USE, noyau) — pas d'automatisation ici."
            log_info "Exemple : sudo emerge x11-drivers/nvidia-drivers"
            return 1
            ;;
        alpine)
            log_warn "Alpine : pilotes NVIDIA propriétaires non gérés automatiquement par installman."
            log_info "Voir la doc Alpine / NVIDIA ou utilisez une distro avec paquets NVIDIA prêts à l'emploi."
            return 1
            ;;
        opensuse)
            log_step "openSUSE — pilotes NVIDIA (essai paquets courants)..."
            if sudo zypper install -y nvidia-open-dkms 2>/dev/null; then
                install_success=true
            elif sudo zypper install -y nvidia-gfxG06-kmp-default 2>/dev/null; then
                install_success=true
            elif sudo zypper install -y x11-video-nvidiaG06 2>/dev/null; then
                install_success=true
            fi
            ;;
        *)
            log_warn "Distribution inconnue : $distro"
            if install_package nvidia-driver auto 2>/dev/null; then
                install_success=true
            fi
            ;;
    esac

    if [[ "$install_success" == true ]]; then
        log_info "Paquets installés. Redémarrez la machine si nvidia-smi n'est pas encore disponible."
        if command -v nvidia-smi &>/dev/null; then
            nvidia-smi -L 2>/dev/null || nvidia-smi 2>/dev/null | head -n12 || true
        fi
        return 0
    fi

    log_error "Installation NVIDIA échouée ou incomplète. Vérifiez les dépôts non-free / RPM Fusion et la doc de votre distro."
    return 1
}
