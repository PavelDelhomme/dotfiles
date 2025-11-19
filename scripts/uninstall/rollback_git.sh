#!/bin/bash

################################################################################
# Rollback Git simple - Revenir à une version précédente
# Usage: bash ~/dotfiles/scripts/uninstall/rollback_git.sh
################################################################################

set +e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"

log_section "Rollback Git - Revenir à une version précédente"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    log_error "Ce n'est pas un dépôt Git!"
    exit 1
fi

cd "$DOTFILES_DIR"

# Afficher les derniers commits
log_info "Derniers commits :"
echo ""
git log --oneline -15
echo ""

# Options
echo "Options :"
echo "  1. Revenir au commit précédent (HEAD~1)"
echo "  2. Revenir à un commit spécifique (par hash)"
echo "  3. Revenir à une version sur origin/main (pull)"
echo "  0. Annuler"
echo ""
printf "Choix: "
read -r choice

case "$choice" in
    1)
        log_warn "Retour au commit précédent..."
        git reset --hard HEAD~1
        log_info "✓ Rollback effectué"
        ;;
    2)
        printf "Entrez le hash du commit (ex: abc1234): "
        read -r commit_hash
        if [ -n "$commit_hash" ]; then
            log_warn "Retour au commit $commit_hash..."
            git reset --hard "$commit_hash" 2>/dev/null || {
                log_error "Commit non trouvé"
                exit 1
            }
            log_info "✓ Rollback effectué"
        fi
        ;;
    3)
        log_info "Récupération de la version sur origin/main..."
        git fetch origin main
        git reset --hard origin/main
        log_info "✓ Retour à origin/main effectué"
        ;;
    0)
        log_info "Annulé"
        exit 0
        ;;
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

echo ""
log_info "État actuel :"
git log --oneline -5
echo ""
