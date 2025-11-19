#!/bin/bash

################################################################################
# Script de restauration depuis Git
# Restaure l'état du repo depuis origin/main (annule modifications locales)
# Usage: bash ~/dotfiles/scripts/sync/restore_from_git.sh [file_path]
################################################################################

set +e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log_section "Restauration depuis Git"

# Vérifier qu'on est dans un repo git
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    log_error "Ce n'est pas un dépôt Git: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR" || exit 1

# Si un fichier spécifique est fourni, le restaurer uniquement
if [ -n "$1" ]; then
    file="$1"
    
    log_info "Restauration fichier: $file"
    
    # Vérifier si le fichier existe dans le repo distant
    if git ls-tree -r HEAD --name-only | grep -q "^$file$"; then
        git checkout HEAD -- "$file" 2>/dev/null || \
        git checkout origin/main -- "$file" 2>/dev/null || \
        git checkout origin/master -- "$file" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log_info "✅ Fichier restauré: $file"
        else
            log_error "❌ Erreur lors de la restauration"
            exit 1
        fi
    else
        log_warn "⚠️  Fichier non trouvé dans le repo: $file"
        log_info "Vérification s'il existe dans l'historique..."
        
        if git log --all --full-history -- "$file" | head -1 | grep -q "commit"; then
            # Récupérer depuis l'historique
            git checkout $(git log --all --full-history --format=%H -- "$file" | head -1) -- "$file" 2>/dev/null
            if [ $? -eq 0 ]; then
                log_info "✅ Fichier restauré depuis l'historique: $file"
            else
                log_error "❌ Impossible de restaurer depuis l'historique"
                exit 1
            fi
        else
            log_error "❌ Fichier jamais existé dans le repo"
            exit 1
        fi
    fi
    
    exit 0
fi

# Afficher les modifications locales
log_info "Modifications locales détectées:"
git status --short

echo ""
log_warn "⚠️  Cette opération va ANNULER toutes les modifications locales"
log_warn "⚠️  Les fichiers non commités seront perdus"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Opération annulée"
    exit 0
fi

# Option 1: Hard reset vers origin/main (supprime tout)
echo ""
echo "1. Reset hard vers origin/main (supprime toutes modifications)"
echo "2. Restaurer fichiers modifiés uniquement (git checkout)"
echo "3. Annuler"
echo ""
printf "Choix [défaut: 2]: "
read -r choice
choice=${choice:-2}

case "$choice" in
    1)
        log_info "Fetch depuis origin..."
        git fetch origin main 2>/dev/null || git fetch origin master 2>/dev/null || true
        
        log_info "Reset hard vers origin/main..."
        git reset --hard origin/main 2>/dev/null || \
        git reset --hard origin/master 2>/dev/null || \
        git reset --hard HEAD
        
        log_info "Nettoyage fichiers non suivis..."
        git clean -fd
        
        log_info "✅ Restauration complète terminée"
        ;;
    2)
        log_info "Fetch depuis origin..."
        git fetch origin main 2>/dev/null || git fetch origin master 2>/dev/null || true
        
        log_info "Restauration fichiers modifiés..."
        git checkout HEAD -- . 2>/dev/null || \
        git checkout origin/main -- . 2>/dev/null || \
        git checkout origin/master -- .
        
        log_info "✅ Fichiers modifiés restaurés"
        log_warn "⚠️  Les fichiers non suivis ne sont pas supprimés"
        log_info "Utilisez 'git clean -fd' pour les supprimer manuellement"
        ;;
    3)
        log_info "Opération annulée"
        exit 0
        ;;
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

echo ""
log_info "État actuel du repo:"
git status --short | head -10 || log_info "  (aucune modification)"

