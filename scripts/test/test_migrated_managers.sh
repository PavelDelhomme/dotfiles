#!/bin/sh
# =============================================================================
# TEST_MIGRATED_MANAGERS - Test des managers migrés uniquement
# =============================================================================
# Description: Teste uniquement les managers déjà migrés vers la structure hybride
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh"
    TEST_MANAGERS=$(dotfiles_migrated_managers_space)
    export TEST_MANAGERS
else
    export TEST_MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman doctorman"
fi

exec "$DOTFILES_DIR/scripts/test/test_all_managers.sh"

