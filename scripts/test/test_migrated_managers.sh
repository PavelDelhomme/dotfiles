#!/bin/sh
# =============================================================================
# TEST_MIGRATED_MANAGERS - Test des managers migrés uniquement
# =============================================================================
# Description: Teste uniquement les managers déjà migrés vers la structure hybride
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh"
    dotfiles_test_load_user_env
fi

# Respecter TEST_MANAGERS déjà défini (make … TEST_MANAGERS=… ou test.local.env)
if [ -z "${TEST_MANAGERS:-}" ]; then
    if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh"
        TEST_MANAGERS=$(dotfiles_migrated_managers_space)
        export TEST_MANAGERS
    else
        export TEST_MANAGERS="pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman doctorman netman sshman testman testzshman moduleman multimediaman cyberlearn"
    fi
fi

exec "$DOTFILES_DIR/scripts/test/test_all_managers.sh"

