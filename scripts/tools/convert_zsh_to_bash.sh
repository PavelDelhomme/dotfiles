#!/bin/bash
# =============================================================================
# CONVERTISSEUR ZSH → BASH
# =============================================================================
# Description: Convertit le code ZSH vers Bash en adaptant la syntaxe
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
    echo "Usage: $0 <fichier_zsh> <fichier_bash_sortie>"
    echo "Exemple: $0 zsh/functions/installman/core/installman.zsh bash/functions/installman/core/installman.sh"
    exit 1
fi

ZSH_FILE="$1"
BASH_FILE="$2"

if [ ! -f "$ZSH_FILE" ]; then
    log_error "Fichier ZSH introuvable: $ZSH_FILE"
    exit 1
fi

# Créer le répertoire de sortie si nécessaire
mkdir -p "$(dirname "$BASH_FILE")"

log_step "Conversion ZSH → Bash: $(basename "$ZSH_FILE")"

# Conversion basique (à améliorer progressivement)
cat > "$BASH_FILE" << 'BASH_HEADER'
# Converted from ZSH to Bash
# Original: 
# 
# NOTE: Cette conversion est automatique mais peut nécessiter des ajustements manuels
# pour les patterns ZSH spécifiques

BASH_HEADER

# Lire le fichier ZSH ligne par ligne et convertir
while IFS= read -r line || [ -n "$line" ]; do
    # Ignorer les lignes vides et commentaires simples
    if [[ "$line" =~ ^[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line" >> "$BASH_FILE"
        continue
    fi
    
    # Conversion typeset → declare
    if [[ "$line" =~ typeset[[:space:]]+ ]]; then
        echo "$line" | sed 's/typeset/declare/g' >> "$BASH_FILE"
        continue
    fi
    
    # Conversion des arrays ZSH spécifiques
    # "${(@s/:/)string}" → IFS=':' read -ra array <<< "$string"
    if [[ "$line" =~ \$\{\(@s/[^\)]+\) ]]; then
        # Pattern complexe, nécessite conversion manuelle
        echo "# TODO: Convertir pattern ZSH spécifique: $line" >> "$BASH_FILE"
        echo "$line" >> "$BASH_FILE"
        continue
    fi
    
    # Pour l'instant, copier la ligne telle quelle (sera amélioré)
    echo "$line" >> "$BASH_FILE"
done < "$ZSH_FILE"

log_warn "⚠️  Conversion automatique basique effectuée"
log_warn "   Une conversion manuelle sera nécessaire pour les patterns ZSH spécifiques"
log_info "✓ Fichier Bash créé: $BASH_FILE"

