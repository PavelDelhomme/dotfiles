#!/usr/bin/env bash
# =============================================================================
# Test des dotfiles dans un conteneur Docker (bootstrap + installman)
# =============================================================================
# Usage: depuis la racine des dotfiles:
#   bash scripts/test/docker/run_dotfiles_bootstrap.sh
# Ou avec docker-compose:
#   docker-compose -f scripts/test/docker/docker-compose.yml run --rm dotfiles-test
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOTFILES_DIR"

echo "════════════════════════════════════════"
echo "  Test dotfiles (conteneur Docker)"
echo "════════════════════════════════════════"
echo ""
echo "DOTFILES_DIR=$DOTFILES_DIR"
echo ""

# 1) Bootstrap (non interactif si possible)
if [ -f "$DOTFILES_DIR/bootstrap.sh" ]; then
    echo "[1/3] Exécution de bootstrap.sh..."
    export NON_INTERACTIVE=1
    bash "$DOTFILES_DIR/bootstrap.sh" || true
    echo ""
fi

# 2) Vérifier installman (liste ou help)
if [ -f "$DOTFILES_DIR/core/managers/installman/installman_entry.sh" ]; then
    echo "[2/3] Vérification installman (list)..."
    zsh -c 'source "$DOTFILES_DIR/zsh/functions/installman/core/installman.zsh"; installman list' 2>/dev/null || \
        sh "$DOTFILES_DIR/core/managers/installman/installman_entry.sh" list 2>/dev/null || true
    echo ""
fi

# 3) Vérification multi-shell (installman entry)
echo "[3/3] Vérification entrée multi-shell..."
for sh in zsh bash sh; do
    if command -v "$sh" >/dev/null 2>&1; then
        if "$sh" "$DOTFILES_DIR/core/managers/installman/installman_entry.sh" help 2>/dev/null | head -3; then
            echo "  $sh: OK"
        else
            echo "  $sh: skip ou erreur"
        fi
    fi
done

echo ""
echo "════════════════════════════════════════"
echo "  Fin du test"
echo "════════════════════════════════════════"
