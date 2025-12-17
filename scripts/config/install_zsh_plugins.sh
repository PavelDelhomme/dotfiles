#!/bin/bash

################################################################################
# Script d'installation des plugins ZSH (zsh-users)
# Installe zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions
# Usage: bash ~/dotfiles/scripts/config/install_zsh_plugins.sh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation des plugins ZSH (zsh-users)"

# Répertoire pour les plugins ZSH
ZSH_PLUGINS_DIR="$HOME/.zsh"
ZSH_PLUGINS_REPO="https://github.com/zsh-users"

# Créer le répertoire si nécessaire
mkdir -p "$ZSH_PLUGINS_DIR"

# Liste des plugins à installer
declare -A PLUGINS=(
    ["zsh-autosuggestions"]="zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
    ["zsh-completions"]="zsh-completions"
)

# Fonction pour installer un plugin
install_plugin() {
    local plugin_name="$1"
    local plugin_repo="$2"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    if [ -d "$plugin_dir" ]; then
        log_info "Plugin $plugin_name déjà installé, mise à jour..."
        cd "$plugin_dir"
        if git pull >/dev/null 2>&1; then
            log_info "✓ $plugin_name mis à jour"
        else
            log_warn "⚠️  Impossible de mettre à jour $plugin_name (peut être normal)"
        fi
    else
        log_info "Installation de $plugin_name..."
        if git clone "$ZSH_PLUGINS_REPO/$plugin_repo.git" "$plugin_dir" >/dev/null 2>&1; then
            log_info "✓ $plugin_name installé"
        else
            log_error "✗ Erreur lors de l'installation de $plugin_name"
            return 1
        fi
    fi
}

# Installer tous les plugins
for plugin_name in "${!PLUGINS[@]}"; do
    install_plugin "$plugin_name" "${PLUGINS[$plugin_name]}"
done

log_section "Résumé de l'installation"

echo ""
echo "Plugins installés dans : $ZSH_PLUGINS_DIR"
for plugin_name in "${!PLUGINS[@]}"; do
    if [ -d "$ZSH_PLUGINS_DIR/$plugin_name" ]; then
        echo "  ✅ $plugin_name"
    else
        echo "  ❌ $plugin_name (échec)"
    fi
done
echo ""

log_info "✅ Installation des plugins ZSH terminée"
echo ""
log_info "Les plugins seront chargés automatiquement dans zshrc_custom"
log_info "Rechargez votre shell avec : exec zsh"

