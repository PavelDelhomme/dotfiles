#!/bin/sh
# =============================================================================
# TEST_MIGRATED_MANAGERS - Test des managers migrés uniquement
# =============================================================================
# Description: Teste uniquement les managers déjà migrés vers la structure hybride
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Exporter la variable pour le script de test
export TEST_MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman"

# Lancer le script principal avec les managers migrés
exec "$DOTFILES_DIR/scripts/test/test_all_managers.sh"

