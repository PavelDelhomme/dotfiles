# =============================================================================
# UPDATE_SYSTEM - Mise à jour intelligente du système selon la distribution
# =============================================================================
# DESC: Détecte automatiquement la distribution Linux et utilise le bon
#       gestionnaire de paquets pour mettre à jour le système.
#       Supporte : Arch, Debian, Ubuntu, Fedora, Gentoo, NixOS, openSUSE, etc.
# USAGE: update
# EXAMPLES:
#   update          # Mise à jour des paquets (sans upgrade)
#   upgrade         # Mise à jour complète du système
# RETURNS: 0 si succès, 1 si erreur
# =============================================================================

# Couleurs
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g CYAN '\033[0;36m'
set -g NC '\033[0m'

################################################################################
# DESC: Détecte la distribution Linux
# USAGE: detect_distro
# RETURNS: Nom de la distribution
################################################################################
function detect_distro
    # Arch Linux et dérivés
    if test -f /etc/arch-release
        echo "arch"
        return 0
    end
    
    # Debian et dérivés
    if test -f /etc/debian_version
        if test -f /etc/lsb-release
            source /etc/lsb-release
            if test "$DISTRIB_ID" = "Ubuntu"
                echo "ubuntu"
                return 0
            else if test "$DISTRIB_ID" = "LinuxMint"
                echo "mint"
                return 0
            end
        end
        echo "debian"
        return 0
    end
    
    # Fedora et dérivés
    if test -f /etc/fedora-release
        echo "fedora"
        return 0
    end
    
    # Gentoo
    if test -f /etc/gentoo-release; or test -f /etc/portage/make.conf
        echo "gentoo"
        return 0
    end
    
    # NixOS
    if test -f /etc/nixos/configuration.nix; or test -f /nix/var/nix/profiles/system
        echo "nixos"
        return 0
    end
    
    # openSUSE
    if test -f /etc/SUSE-brand; or (test -f /etc/os-release; and grep -q "openSUSE" /etc/os-release 2>/dev/null)
        echo "opensuse"
        return 0
    end
    
    # Alpine Linux
    if test -f /etc/alpine-release
        echo "alpine"
        return 0
    end
    
    # Red Hat Enterprise Linux
    if test -f /etc/redhat-release; and grep -q "Red Hat" /etc/redhat-release 2>/dev/null
        echo "rhel"
        return 0
    end
    
    # CentOS
    if test -f /etc/redhat-release; and grep -q "CentOS" /etc/redhat-release 2>/dev/null
        echo "centos"
        return 0
    end
    
    # Autres distributions via os-release
    if test -f /etc/os-release
        set -l distro_id (grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
        switch "$distro_id"
            case "arch" "manjaro" "endeavouros"
                echo "arch"
            case "debian" "ubuntu" "mint" "kali" "parrot"
                echo "debian"
            case "fedora"
                echo "fedora"
            case "gentoo"
                echo "gentoo"
            case "nixos"
                echo "nixos"
            case "opensuse*" "suse*"
                echo "opensuse"
            case "alpine"
                echo "alpine"
            case "rhel"
                echo "rhel"
            case "centos"
                echo "centos"
            case '*'
                echo "unknown"
        end
        return 0
    end
    
    echo "unknown"
    return 1
end

################################################################################
# DESC: Met à jour les paquets (sans upgrade)
# USAGE: update
# RETURNS: 0 si succès, 1 si erreur
################################################################################
function update
    set -l distro (detect_distro)
    set -l cmd ""
    
    echo -e "$BLUE🔄 Mise à jour des paquets...$NC"
    echo -e "$CYANDistribution détectée: $YELLOW$distro$NC"
    echo ""
    
    switch "$distro"
        case "arch" "manjaro" "endeavouros"
            set cmd "sudo pacman -Sy"
            echo -e "$GREENUtilisation de: $CYANpacman$NC"
        case "debian" "ubuntu" "mint" "kali" "parrot"
            set cmd "sudo apt update"
            echo -e "$GREENUtilisation de: $CYANapt$NC"
        case "fedora"
            set cmd "sudo dnf check-update; or sudo dnf makecache"
            echo -e "$GREENUtilisation de: $CYANdnf$NC"
        case "gentoo"
            set cmd "sudo emerge --sync"
            echo -e "$GREENUtilisation de: $CYANemerge$NC"
        case "nixos"
            set cmd "sudo nix-channel --update"
            echo -e "$GREENUtilisation de: $CYANnix-channel$NC"
        case "opensuse"
            set cmd "sudo zypper refresh"
            echo -e "$GREENUtilisation de: $CYANzypper$NC"
        case "alpine"
            set cmd "sudo apk update"
            echo -e "$GREENUtilisation de: $CYANapk$NC"
        case "rhel" "centos"
            set cmd "sudo yum check-update; or sudo yum makecache"
            echo -e "$GREENUtilisation de: $CYANyum$NC"
        case '*'
            echo -e "$RED❌ Distribution non supportée: $distro$NC"
            echo -e "$YELLOWVeuillez mettre à jour manuellement votre système$NC"
            return 1
    end
    
    echo -e "$BLUECommande: $CYAN$cmd$NC"
    echo ""
    
    eval "$cmd"
    set -l exit_code $status
    
    if test $exit_code -eq 0
        echo ""
        echo -e "$GREEN✅ Mise à jour des paquets terminée$NC"
        return 0
    else
        echo ""
        echo -e "$RED❌ Erreur lors de la mise à jour$NC"
        return 1
    end
end

################################################################################
# DESC: Met à jour complètement le système (upgrade)
# USAGE: upgrade
# RETURNS: 0 si succès, 1 si erreur
################################################################################
function upgrade
    set -l distro (detect_distro)
    set -l cmd ""
    
    echo -e "$BLUE🚀 Mise à jour complète du système...$NC"
    echo -e "$CYANDistribution détectée: $YELLOW$distro$NC"
    echo ""
    
    switch "$distro"
        case "arch" "manjaro" "endeavouros"
            set cmd "sudo pacman -Syu"
            echo -e "$GREENUtilisation de: $CYANpacman$NC"
        case "debian" "ubuntu" "mint" "kali" "parrot"
            set cmd "sudo apt update; and sudo apt upgrade -y"
            echo -e "$GREENUtilisation de: $CYANapt$NC"
        case "fedora"
            set cmd "sudo dnf upgrade -y"
            echo -e "$GREENUtilisation de: $CYANdnf$NC"
        case "gentoo"
            set cmd "sudo emerge -auDN @world"
            echo -e "$GREENUtilisation de: $CYANemerge$NC"
        case "nixos"
            set cmd "sudo nixos-rebuild switch --upgrade"
            echo -e "$GREENUtilisation de: $CYANnixos-rebuild$NC"
        case "opensuse"
            set cmd "sudo zypper update -y"
            echo -e "$GREENUtilisation de: $CYANzypper$NC"
        case "alpine"
            set cmd "sudo apk update; and sudo apk upgrade"
            echo -e "$GREENUtilisation de: $CYANapk$NC"
        case "rhel" "centos"
            set cmd "sudo yum update -y"
            echo -e "$GREENUtilisation de: $CYANyum$NC"
        case '*'
            echo -e "$RED❌ Distribution non supportée: $distro$NC"
            echo -e "$YELLOWVeuillez mettre à jour manuellement votre système$NC"
            return 1
    end
    
    echo -e "$BLUECommande: $CYAN$cmd$NC"
    echo ""
    echo -e "$YELLOW⚠️  Cette opération peut prendre du temps...$NC"
    echo ""
    
    eval "$cmd"
    set -l exit_code $status
    
    if test $exit_code -eq 0
        echo ""
        echo -e "$GREEN✅ Mise à jour complète terminée$NC"
        return 0
    else
        echo ""
        echo -e "$RED❌ Erreur lors de la mise à jour complète$NC"
        return 1
    end
end

