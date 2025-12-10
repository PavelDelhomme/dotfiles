#!/bin/bash
# =============================================================================
# LOAD COMMANDS - Charge toutes les commandes standalone
# =============================================================================
# Description: Charge automatiquement toutes les commandes standalone (non-managers)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoire des commandes standalone
COMMANDS_DIR="${COMMANDS_DIR:-$HOME/dotfiles/bash/functions/commands}"

# Charger toutes les commandes standalone
if [ -d "$COMMANDS_DIR" ]; then
    for cmd_file in "$COMMANDS_DIR"/*.sh; do
        [ -f "$cmd_file" ] && source "$cmd_file" 2>/dev/null || true
    done
fi

