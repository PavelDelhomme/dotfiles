#!/bin/bash

################################################################################
# Script de rollback complet - Désinstallation de tout ce qui a été installé
# Usage: bash ~/dotfiles/scripts/uninstall/rollback_all.sh
################################################################################

set +e  # Ne pas arrêter sur erreurs pour continuer le nettoyage

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

log_section "ROLLBACK COMPLET - Désinstallation dotfiles"

################################################################################
# CONFIRMATION
################################################################################
log_warn "⚠️  ATTENTION : Ce script va désinstaller TOUT ce qui a été installé"
log_warn "⚠️  Cela inclut :"
echo "  - Configuration Git"
echo "  - Clés SSH"
echo "  - Services systemd (auto-sync)"
echo "  - Applications installées (Docker, Cursor, Brave, Go, etc.)"
echo "  - Configuration ZSH"
echo "  - Dossier dotfiles"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirmation

if [ "$confirmation" != "OUI" ]; then
    log_info "Rollback annulé"
    exit 0
fi

################################################################################
# 1. ARRÊTER ET SUPPRIMER SERVICES SYSTEMD
################################################################################
log_section "1. Arrêt et suppression services systemd"

if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
    log_info "Arrêt du timer auto-sync..."
    systemctl --user stop dotfiles-sync.timer 2>/dev/null
    systemctl --user disable dotfiles-sync.timer 2>/dev/null
    log_info "✓ Timer arrêté"
fi

if [ -f "$HOME/.config/systemd/user/dotfiles-sync.timer" ]; then
    log_info "Suppression des fichiers systemd..."
    rm -f "$HOME/.config/systemd/user/dotfiles-sync.timer"
    rm -f "$HOME/.config/systemd/user/dotfiles-sync.service"
    systemctl --user daemon-reload 2>/dev/null
    log_info "✓ Fichiers systemd supprimés"
fi

################################################################################
# 2. DÉSINSTALLER APPLICATIONS
################################################################################
log_section "2. Désinstallation applications"

# Docker
if command -v docker &> /dev/null; then
    log_info "Désinstallation Docker..."
    if [ -f /etc/arch-release ]; then
        sudo pacman -Rns --noconfirm docker docker-compose 2>/dev/null || true
    elif command -v apt &> /dev/null; then
        sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
        sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
    fi
    sudo systemctl stop docker 2>/dev/null || true
    sudo systemctl disable docker 2>/dev/null || true
    sudo groupdel docker 2>/dev/null || true
    rm -rf ~/.docker 2>/dev/null || true
    log_info "✓ Docker désinstallé"
fi

# Docker Desktop
if command -v docker-desktop &> /dev/null || [ -f /opt/docker-desktop/docker-desktop ]; then
    log_info "Désinstallation Docker Desktop..."
    if [ -f /etc/arch-release ] && command -v yay &> /dev/null; then
        yay -Rns --noconfirm docker-desktop 2>/dev/null || true
    elif command -v apt &> /dev/null; then
        sudo apt remove -y docker-desktop 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
        sudo dnf remove -y docker-desktop 2>/dev/null || true
    fi
    log_info "✓ Docker Desktop désinstallé"
fi

# Cursor
if [ -f /opt/cursor.appimage ] || command -v cursor &> /dev/null; then
    log_info "Désinstallation Cursor..."
    sudo rm -f /opt/cursor.appimage 2>/dev/null || true
    sudo rm -f /usr/local/bin/cursor 2>/dev/null || true
    rm -f ~/.local/bin/update-cursor 2>/dev/null || true
    rm -f ~/.local/share/applications/cursor.desktop 2>/dev/null || true
    rm -rf ~/.cursor 2>/dev/null || true
    log_info "✓ Cursor désinstallé"
fi

# Brave
if command -v brave &> /dev/null || command -v brave-browser &> /dev/null; then
    log_info "Désinstallation Brave..."
    if [ -f /etc/arch-release ] && command -v yay &> /dev/null; then
        yay -Rns --noconfirm brave-bin 2>/dev/null || true
    elif command -v apt &> /dev/null; then
        sudo apt remove -y brave-browser 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
        sudo dnf remove -y brave-browser 2>/dev/null || true
    fi
    log_info "✓ Brave désinstallé"
fi

# PortProton
if flatpak list | grep -q "PortProton" 2>/dev/null; then
    log_info "Désinstallation PortProton..."
    flatpak uninstall -y ru.linux_gaming.PortProton 2>/dev/null || true
    log_info "✓ PortProton désinstallé"
fi

# Go
if command -v go &> /dev/null; then
    log_info "Désinstallation Go..."
    sudo rm -rf /usr/local/go 2>/dev/null || true
    rm -rf ~/go 2>/dev/null || true
    log_info "✓ Go désinstallé"
fi

# yay
if command -v yay &> /dev/null; then
    log_info "Désinstallation yay..."
    if [ -f /etc/arch-release ]; then
        sudo pacman -Rns --noconfirm yay 2>/dev/null || true
    fi
    log_info "✓ yay désinstallé"
fi

################################################################################
# 3. SUPPRIMER CONFIGURATION GIT
################################################################################
log_section "3. Suppression configuration Git"

log_info "Suppression configuration Git globale..."
git config --global --unset user.name 2>/dev/null || true
git config --global --unset user.email 2>/dev/null || true
git config --global --unset credential.helper 2>/dev/null || true
git config --global --unset init.defaultBranch 2>/dev/null || true
git config --global --unset core.editor 2>/dev/null || true
git config --global --unset color.ui 2>/dev/null || true
log_info "✓ Configuration Git supprimée"

################################################################################
# 4. SUPPRIMER CLÉS SSH
################################################################################
log_section "4. Suppression clés SSH"

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    log_warn "Suppression de la clé SSH..."
    printf "Supprimer la clé SSH? (o/n): "
    read -r delete_ssh
    if [[ "$delete_ssh" =~ ^[oO]$ ]]; then
        rm -f "$HOME/.ssh/id_ed25519" 2>/dev/null || true
        rm -f "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
        log_info "✓ Clé SSH supprimée"
    else
        log_info "Clé SSH conservée"
    fi
fi

################################################################################
# 5. SUPPRIMER CONFIGURATION ZSH
################################################################################
log_section "5. Suppression configuration ZSH"

if [ -f "$HOME/.zshrc" ]; then
    log_info "Nettoyage de .zshrc..."
    # Supprimer les lignes liées aux dotfiles
    sed -i '/dotfiles/d' "$HOME/.zshrc" 2>/dev/null || true
    sed -i '/zshrc_custom/d' "$HOME/.zshrc" 2>/dev/null || true
    log_info "✓ .zshrc nettoyé"
fi

################################################################################
# 6. SUPPRIMER DOSSIER DOTFILES
################################################################################
log_section "6. Suppression dossier dotfiles"

if [ -d "$HOME/dotfiles" ]; then
    log_warn "Suppression du dossier dotfiles..."
    printf "Supprimer le dossier ~/dotfiles? (o/n): "
    read -r delete_dotfiles
    if [[ "$delete_dotfiles" =~ ^[oO]$ ]]; then
        rm -rf "$HOME/dotfiles" 2>/dev/null || true
        log_info "✓ Dossier dotfiles supprimé"
    else
        log_info "Dossier dotfiles conservé"
    fi
fi

################################################################################
# 7. NETTOYER FICHIERS LOGS
################################################################################
log_section "7. Nettoyage fichiers logs"

rm -f "$HOME/dotfiles/auto_sync.log" 2>/dev/null || true
rm -f /tmp/dotfiles_auto_sync.lock 2>/dev/null || true
log_info "✓ Logs supprimés"

################################################################################
# 8. SUPPRIMER ALIAS ET FONCTIONS DES FICHIERS ZSH
################################################################################
log_section "8. Nettoyage alias et fonctions"

if [ -f "$HOME/dotfiles/zsh/aliases.zsh" ]; then
    log_info "Nettoyage des alias créés par les scripts..."
    # Supprimer les alias créés par nos scripts
    sed -i '/# Cursor IDE/,/^alias cursor=/d' "$HOME/dotfiles/zsh/aliases.zsh" 2>/dev/null || true
    sed -i '/# PortProton helpers/,/^alias pp=/d' "$HOME/dotfiles/zsh/aliases.zsh" 2>/dev/null || true
    log_info "✓ Alias nettoyés"
fi

################################################################################
# 9. SUPPRIMER VARIABLES PATH DANS ENV.SH
################################################################################
log_section "9. Nettoyage variables PATH"

if [ -f "$HOME/dotfiles/zsh/env.sh" ]; then
    log_info "Nettoyage des chemins ajoutés..."
    # Supprimer les chemins Go
    sed -i '/# Go paths/,/export PATH.*go/d' "$HOME/dotfiles/zsh/env.sh" 2>/dev/null || true
    log_info "✓ Variables PATH nettoyées"
fi

################################################################################
# 10. OPTION ROLLBACK GIT (si dotfiles existe encore)
################################################################################
if [ -d "$HOME/dotfiles" ] && [ -d "$HOME/dotfiles/.git" ]; then
    log_section "10. Option rollback Git"
    
    printf "Faire un rollback Git vers une version précédente? (o/n): "
    read -r git_rollback
    if [[ "$git_rollback" =~ ^[oO]$ ]]; then
        cd "$HOME/dotfiles"
        log_info "Affichage des 10 derniers commits..."
        git log --oneline -10
        echo ""
        printf "Entrez le hash du commit vers lequel revenir (ou 'annuler'): "
        read -r commit_hash
        if [ "$commit_hash" != "annuler" ] && [ -n "$commit_hash" ]; then
            log_warn "⚠️  Retour vers commit $commit_hash..."
            git reset --hard "$commit_hash" 2>/dev/null || log_error "Erreur lors du reset"
            log_info "✓ Rollback Git effectué"
        else
            log_info "Rollback Git annulé"
        fi
    fi
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Rollback terminé!"

log_info "✅ Désinstallation complète effectuée"
echo ""
log_warn "⚠️  Actions restantes (manuelles si nécessaire):"
echo "  - Redémarrer le shell pour que les changements prennent effet"
echo "  - Vérifier ~/.zshrc pour d'autres modifications"
echo "  - Vérifier les groupes utilisateur (docker, libvirt) si nécessaire"
echo ""
log_info "Pour réinstaller :"
echo "  curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
echo ""

