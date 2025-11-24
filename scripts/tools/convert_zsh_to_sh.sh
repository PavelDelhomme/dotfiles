#!/bin/sh
################################################################################
# Script de conversion Zsh -> Sh compatible
# Convertit les fonctions et scripts Zsh en Sh compatible avec tous les shells
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Charger la bibliothèque commune
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
}

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

convert_zsh_function() {
    local zsh_file="$1"
    local sh_file="$2"
    
    if [ ! -f "$zsh_file" ]; then
        log_warn "Fichier source non trouvé: $zsh_file"
        return 1
    fi
    
    log_info "Conversion: $(basename "$zsh_file") -> $(basename "$sh_file")"
    
    # Créer le répertoire de destination si nécessaire
    mkdir -p "$(dirname "$sh_file")"
    
    # Conversion basique (remplacer les syntaxes Zsh par Sh)
    sed -e 's/^#!/#!/bin/sh/' \
        -e 's/\[\[ /[ /g' \
        -e 's/ \]\]/ ]/g' \
        -e 's/&>/ 2>\&1/g' \
        -e 's/function \([a-zA-Z_][a-zA-Z0-9_]*\)()/\1()/g' \
        -e 's/\([a-zA-Z_][a-zA-Z0-9_]*\)() {/\1() {/g' \
        "$zsh_file" > "$sh_file"
    
    # Rendre exécutable
    chmod +x "$sh_file" 2>/dev/null
    
    return 0
}

convert_all_functions() {
    log_section "Conversion des fonctions Zsh vers Sh"
    
    local zsh_func_dir="$DOTFILES_DIR/zsh/functions"
    local shared_func_dir="$DOTFILES_DIR/shared/functions"
    
    if [ ! -d "$zsh_func_dir" ]; then
        log_error "Répertoire Zsh functions non trouvé: $zsh_func_dir"
        return 1
    fi
    
    mkdir -p "$shared_func_dir"
    
    # Convertir les fonctions principales
    local count=0
    find "$zsh_func_dir" -name "*.zsh" -o -name "*.sh" | while read -r zsh_file; do
        # Calculer le chemin relatif
        rel_path="${zsh_file#$zsh_func_dir/}"
        sh_file="$shared_func_dir/${rel_path%.zsh}.sh"
        
        if convert_zsh_function "$zsh_file" "$sh_file"; then
            ((count++))
        fi
    done
    
    log_info "✓ $count fonctions converties"
    return 0
}

main() {
    log_section "Conversion Zsh -> Sh compatible"
    
    printf "Ce script va convertir les fonctions Zsh en Sh compatible.\n"
    printf "Continuer? (o/n) [défaut: n]: "
    read -r confirm
    confirm=${confirm:-n}
    
    if [[ ! "$confirm" =~ ^[oO]$ ]]; then
        log_info "Conversion annulée"
        return 0
    fi
    
    convert_all_functions
    
    log_section "Conversion terminée"
    log_info "Les fonctions converties sont dans: $DOTFILES_DIR/shared/functions"
    log_warn "⚠️  Vérifiez manuellement les conversions pour les syntaxes spécifiques Zsh"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

