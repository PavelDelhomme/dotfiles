# =============================================================================
# LOAD COMMANDS - Charge toutes les commandes standalone
# =============================================================================
# Description: Charge automatiquement toutes les commandes standalone (non-managers)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoire des commandes standalone
set -g COMMANDS_DIR "$HOME/dotfiles/fish/functions/commands"

# Charger toutes les commandes standalone
if test -d "$COMMANDS_DIR"
    for cmd_file in $COMMANDS_DIR/*.fish
        if test -f "$cmd_file"
            source "$cmd_file" 2>/dev/null
        end
    end
end

