#!/bin/bash
################################################################################
# Installation paquets de base - multi-distro
# Inclut dig (bind / dnsutils / bind-utils) pour netman et co.
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

# Nom de paquet pour un binaire (ou groupe) selon la distro
# USAGE: _base_pkg_for <bin_or_key>
_base_pkg_for() {
    local key="$1"
    local distro
    distro="$(detect_distro)"
    case "$distro" in
        arch|manjaro)
            case "$key" in
                dig|nslookup|host) echo "bind" ;;
                jq) echo "jq" ;;
                base-devel) echo "base-devel" ;;
                zsh-theme-powerlevel10k) echo "zsh-theme-powerlevel10k" ;;
                *) echo "$key" ;;
            esac
            ;;
        debian|ubuntu)
            case "$key" in
                dig|nslookup|host) echo "dnsutils" ;;
                jq) echo "jq" ;;
                base-devel|gcc) echo "build-essential" ;;
                zsh-theme-powerlevel10k) echo "zsh-theme-powerlevel10k" ;; # peut être absent → skip
                *) echo "$key" ;;
            esac
            ;;
        fedora)
            case "$key" in
                dig|nslookup|host) echo "bind-utils" ;;
                jq) echo "jq" ;;
                base-devel) echo "@development-tools" ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            case "$key" in
                dig) echo "dnsutils" ;;
                *) echo "$key" ;;
            esac
            ;;
    esac
}

_install_pkg() {
    local pkg="$1"
    local distro
    distro="$(detect_distro)"
    case "$distro" in
        arch|manjaro)
            sudo pacman -S --noconfirm --needed "$pkg"
            ;;
        debian|ubuntu)
            sudo apt-get update -qq
            sudo apt-get install -y "$pkg"
            ;;
        fedora)
            sudo dnf install -y "$pkg"
            ;;
        *)
            log_warn "Distro non supportée pour install auto de $pkg — installez manuellement"
            return 1
            ;;
    esac
}

_bin_ok() {
    command -v "$1" >/dev/null 2>&1
}

_need_bin_or_pkg() {
    # $1 = binaire à vérifier (vide = vérifier seulement le paquet)
    # $2 = clé de mapping paquet
    local bin="$1"
    local key="$2"
    local pkg
    pkg="$(_base_pkg_for "$key")"

    if [ -n "$bin" ] && _bin_ok "$bin"; then
        log_skip "$bin déjà présent"
        return 0
    fi
    if [ -z "$bin" ] && is_package_installed "$pkg" 2>/dev/null; then
        log_skip "$pkg déjà installé"
        return 0
    fi

    log_info "Installation de $pkg (pour ${bin:-$key})..."
    if _install_pkg "$pkg"; then
        if [ -n "$bin" ] && ! _bin_ok "$bin"; then
            log_warn "$pkg installé mais binaire « $bin » toujours absent"
            return 1
        fi
        log_info "✓ $pkg"
        return 0
    fi
    log_warn "Échec installation $pkg"
    return 1
}

log_section "Paquets de base (multi-distro)"
log_info "Distribution: $(detect_distro)"

# Outils CLI génériques
for tool in xclip curl wget make cmake git zsh btop jq; do
    _need_bin_or_pkg "$tool" "$tool" || true
done

# Compilateur / toolchain
case "$(detect_distro)" in
    arch|manjaro)
        _need_bin_or_pkg "gcc" "gcc" || true
        _need_bin_or_pkg "" "base-devel" || true
        _need_bin_or_pkg "" "zsh-theme-powerlevel10k" || true
        ;;
    debian|ubuntu)
        _need_bin_or_pkg "gcc" "gcc" || true
        _need_bin_or_pkg "" "base-devel" || true
        ;;
    fedora)
        _need_bin_or_pkg "gcc" "gcc" || true
        ;;
esac

# DNS — dig / nslookup / host (même paquet)
log_info "Outils DNS (dig)…"
_need_bin_or_pkg "dig" "dig" || true
# nslookup/host viennent souvent du même paquet ; pas de double install si déjà là
if ! _bin_ok nslookup; then
    _need_bin_or_pkg "nslookup" "nslookup" || true
fi

if [ -f "$SCRIPT_DIR/install/system/packages_ssh.sh" ]; then
    bash "$SCRIPT_DIR/install/system/packages_ssh.sh" || log_warn "Paquets SSH (sshpass) non installés — option installman sshpass"
fi

echo ""
log_info "Vérification dig:"
if _bin_ok dig; then
    log_info "✓ dig → $(command -v dig)"
else
    log_warn "dig toujours absent — essayez: installman network-tools"
fi

log_info "✓ Paquets de base traités"
