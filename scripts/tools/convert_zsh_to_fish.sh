#!/bin/bash
# =============================================================================
# CONVERTISSEUR ZSH → FISH
# =============================================================================
# Description: Convertit le code ZSH vers Fish en adaptant la syntaxe
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${BLUE}[→]${NC} $1"; }

# Usage
if [ $# -lt 2 ]; then
    echo "Usage: $0 <fichier_zsh> <fichier_fish_sortie>"
    echo "Exemple: $0 zsh/functions/installman/core/installman.zsh fish/functions/installman/core/installman.fish"
    exit 1
fi

ZSH_FILE="$1"
FISH_FILE="$2"

if [ ! -f "$ZSH_FILE" ]; then
    log_error "Fichier ZSH introuvable: $ZSH_FILE"
    exit 1
fi

# Créer le répertoire de sortie si nécessaire
mkdir -p "$(dirname "$FISH_FILE")"

log_step "Conversion ZSH → Fish: $(basename "$ZSH_FILE")"

# Conversion basique (à améliorer progressivement)
# Pour l'instant, conversion manuelle sera nécessaire pour les parties complexes

cat > "$FISH_FILE" << 'FISH_HEADER'
# Converted from ZSH to Fish
# Original: 
# 
# NOTE: Cette conversion est automatique mais peut nécessiter des ajustements manuels
# pour les patterns complexes (arrays associatifs, etc.)

FISH_HEADER

# Lire le fichier ZSH ligne par ligne et convertir
while IFS= read -r line || [ -n "$line" ]; do
    # Ignorer les lignes vides et commentaires simples
    if [[ "$line" =~ ^[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line" >> "$FISH_FILE"
        continue
    fi
    
    # Conversion des variables locales
    if [[ "$line" =~ ^[[:space:]]*local[[:space:]]+([^=]+)= ]]; then
        var_name=$(echo "$line" | sed -n 's/.*local[[:space:]]\+\([^=]*\)=.*/\1/p' | tr -d ' ')
        value=$(echo "$line" | sed -n 's/.*=\(.*\)/\1/p')
        echo "set -l $var_name $value" >> "$FISH_FILE"
        continue
    fi
    
    # Conversion des fonctions
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\)[[:space:]]*\{ ]]; then
        func_name=$(echo "$line" | sed -n 's/.*\([a-zA-Z_][a-zA-Z0-9_]*\)().*/\1/p')
        echo "function $func_name" >> "$FISH_FILE"
        continue
    fi
    
    # Conversion des fins de fonction
    if [[ "$line" =~ ^[[:space:]]*\}\s*$ ]]; then
        echo "end" >> "$FISH_FILE"
        continue
    fi
    
    # Pour l'instant, copier la ligne telle quelle (sera amélioré)
    echo "$line" >> "$FISH_FILE"
done < "$ZSH_FILE"

log_warn "⚠️  Conversion automatique basique effectuée"
log_warn "   Une conversion manuelle sera nécessaire pour les patterns complexes"
log_info "✓ Fichier Fish créé: $FISH_FILE"

