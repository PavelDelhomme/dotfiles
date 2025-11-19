#!/bin/bash

################################################################################
# Désinstallation gestionnaires de paquets
# Supprime yay, snapd, flatpak
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation gestionnaires de paquets"

log_warn "⚠️  Cette opération va supprimer les gestionnaires de paquets"
log_warn "⚠️  Gestionnaires concernés :"
echo "  - yay (AUR helper)"
echo "  - snapd (Snap)"
echo "  - flatpak"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

# Détecter le gestionnaire de paquets
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
else
    log_error "Gestionnaire de paquets non supporté"
    exit 1
fi

# yay (AUR helper) - Arch seulement
if [ "$PKG_MANAGER" = "pacman" ]; then
    if command -v yay &> /dev/null; then
        log_info "Suppression de yay..."
        sudo pacman -Rns --noconfirm yay 2>/dev/null && log_info "✓ yay supprimé" || log_warn "Impossible de supprimer yay"
    else
        log_skip "yay non installé"
    fi
else
    log_skip "yay non applicable (Arch Linux uniquement)"
fi

# snapd
if command -v snap &> /dev/null || systemctl is-enabled snapd.socket &> /dev/null 2>&1; then
    log_info "Arrêt et suppression de snapd..."
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo systemctl stop snapd.socket 2>/dev/null
        sudo systemctl disable snapd.socket 2>/dev/null
        sudo systemctl stop snapd.service 2>/dev/null
        sudo systemctl disable snapd.service 2>/dev/null
        sudo pacman -Rns --noconfirm snapd 2>/dev/null && log_info "✓ snapd supprimé" || log_warn "Impossible de supprimer snapd"
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo systemctl stop snapd.socket 2>/dev/null
        sudo systemctl disable snapd.socket 2>/dev/null
        sudo apt remove -y snapd 2>/dev/null && log_info "✓ snapd supprimé" || log_warn "Impossible de supprimer snapd"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo systemctl stop snapd.socket 2>/dev/null
        sudo systemctl disable snapd.socket 2>/dev/null
        sudo dnf remove -y snapd 2>/dev/null && log_info "✓ snapd supprimé" || log_warn "Impossible de supprimer snapd"
    fi
    
    # Supprimer le lien symbolique
    sudo rm -f /snap 2>/dev/null || true
else
    log_skip "snapd non installé"
fi

# flatpak
if command -v flatpak &> /dev/null; then
    log_info "Suppression de flatpak..."
    
    # Désinstaller toutes les applications flatpak d'abord (optionnel)
    log_warn "⚠️  Voulez-vous aussi désinstaller toutes les applications flatpak?"
    printf "Désinstaller applications flatpak? (o/n): "
    read -r remove_apps
    if [[ "$remove_apps" =~ ^[oO]$ ]]; then
        flatpak list --app 2>/dev/null | while read -r app; do
            app_id=$(echo "$app" | awk '{print $1}')
            if [ -n "$app_id" ]; then
                flatpak uninstall --assumeyes "$app_id" 2>/dev/null || true
            fi
        done
        log_info "✓ Applications flatpak désinstallées"
    fi
    
    # Supprimer flatpak
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -Rns --noconfirm flatpak 2>/dev/null && log_info "✓ flatpak supprimé" || log_warn "Impossible de supprimer flatpak"
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt remove -y flatpak 2>/dev/null && log_info "✓ flatpak supprimé" || log_warn "Impossible de supprimer flatpak"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf remove -y flatpak 2>/dev/null && log_info "✓ flatpak supprimé" || log_warn "Impossible de supprimer flatpak"
    fi
else
    log_skip "flatpak non installé"
fi

log_info "✅ Désinstallation gestionnaires de paquets terminée"

