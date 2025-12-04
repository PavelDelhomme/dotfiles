#!/bin/bash
# =============================================================================
# SYNC MANAGERS MULTI-SHELLS - Synchronisation automatique des managers
# =============================================================================
# Description: Convertit et synchronise les managers ZSH vers Fish et Bash
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZSH_FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
FISH_FUNCTIONS_DIR="$DOTFILES_DIR/fish/functions"
BASH_FUNCTIONS_DIR="$DOTFILES_DIR/bash/functions"

# Liste des managers à migrer
MANAGERS=(
    "installman"
    "configman"
    "pathman"
    "netman"
    "gitman"
    "cyberman"
    "devman"
    "miscman"
    "aliaman"
    "searchman"
    "helpman"
    "fileman"
    "virtman"
    "sshman"
    "testman"
    "testzshman"
    "moduleman"
    "manman"
)

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔄 SYNC MANAGERS MULTI-SHELLS"
echo "═══════════════════════════════════════════════════════════"
echo ""

log_info "Ce script va synchroniser les managers ZSH vers Fish et Bash"
log_warn "⚠️  Cette opération va créer/modifier des fichiers dans fish/ et bash/"
echo ""
read -p "Continuer ? (o/N): " confirm
confirm=${confirm:-n}

if [[ ! "$confirm" =~ ^[oO]$ ]]; then
    log_info "Opération annulée"
    exit 0
fi

# Créer les répertoires de base
log_step "Création de la structure de base..."
mkdir -p "$FISH_FUNCTIONS_DIR"
mkdir -p "$BASH_FUNCTIONS_DIR"
log_info "Structure créée"

# Fonction pour convertir ZSH → Fish
convert_zsh_to_fish() {
    local zsh_file="$1"
    local fish_file="$2"
    
    log_step "Conversion ZSH → Fish: $(basename "$zsh_file")"
    
    # Conversion basique (à améliorer)
    # Pour l'instant, on crée un wrapper qui appelle la version ZSH via bash
    cat > "$fish_file" << EOF
# Converted from ZSH - Version Fish
# Original: $zsh_file
# 
# TODO: Conversion complète de la syntaxe ZSH vers Fish
# Pour l'instant, utilisation d'un wrapper

function $(basename "$fish_file" .fish) -d "Manager converti depuis ZSH"
    # Appeler via bash pour compatibilité temporaire
    bash -c "source '$zsh_file' && \$(basename '$zsh_file' .zsh) \$argv"
end
EOF
    
    log_info "Fichier Fish créé (wrapper temporaire)"
}

# Fonction pour convertir ZSH → Bash
convert_zsh_to_bash() {
    local zsh_file="$1"
    local bash_file="$2"
    
    log_step "Conversion ZSH → Bash: $(basename "$zsh_file")"
    
    # Conversion basique (à améliorer)
    # Pour l'instant, on crée un wrapper qui appelle la version ZSH
    cat > "$bash_file" << EOF
# Converted from ZSH - Version Bash
# Original: $zsh_file
# 
# TODO: Conversion complète de la syntaxe ZSH vers Bash
# Pour l'instant, utilisation d'un wrapper

$(basename "$bash_file" .sh)() {
    # Appeler via zsh pour compatibilité temporaire
    if command -v zsh >/dev/null 2>&1; then
        zsh -c "source '$zsh_file' && \$(basename '$zsh_file' .zsh) \"\$@\""
    else
        echo "❌ ZSH requis pour utiliser ce manager"
        return 1
    fi
}
EOF
    
    log_info "Fichier Bash créé (wrapper temporaire)"
}

log_step "Migration des managers..."

for manager in "${MANAGERS[@]}"; do
    log_step "Traitement de $manager..."
    
    zsh_wrapper="$ZSH_FUNCTIONS_DIR/${manager}.zsh"
    zsh_core="$ZSH_FUNCTIONS_DIR/${manager}/core/${manager}.zsh"
    
    # Vérifier quelle structure existe
    if [ -f "$zsh_core" ]; then
        source_file="$zsh_core"
    elif [ -f "$zsh_wrapper" ]; then
        source_file="$zsh_wrapper"
    else
        log_warn "⚠️  $manager non trouvé, ignoré"
        continue
    fi
    
    # Créer la structure dans Fish
    fish_dir="$FISH_FUNCTIONS_DIR/${manager}"
    mkdir -p "$fish_dir/core" 2>/dev/null || true
    
    # Créer la version Fish
    if [ -f "$zsh_core" ]; then
        convert_zsh_to_fish "$zsh_core" "$fish_dir/core/${manager}.fish"
    fi
    convert_zsh_to_fish "$source_file" "$FISH_FUNCTIONS_DIR/${manager}.fish"
    
    # Créer la structure dans Bash
    bash_dir="$BASH_FUNCTIONS_DIR/${manager}"
    mkdir -p "$bash_dir/core" 2>/dev/null || true
    
    # Créer la version Bash
    if [ -f "$zsh_core" ]; then
        convert_zsh_to_bash "$zsh_core" "$bash_dir/core/${manager}.sh"
    fi
    convert_zsh_to_bash "$source_file" "$BASH_FUNCTIONS_DIR/${manager}.sh"
    
    log_info "✓ $manager synchronisé"
done

echo ""
log_info "═══════════════════════════════════════════════════════════"
log_info "✅ Synchronisation terminée"
log_info "═══════════════════════════════════════════════════════════"
echo ""
log_warn "⚠️  NOTE: Les versions Fish et Bash utilisent des wrappers temporaires"
log_warn "   Une conversion complète de la syntaxe sera nécessaire"
log_warn "   Voir docs/MIGRATION_PLAN.md pour plus de détails"
echo ""
