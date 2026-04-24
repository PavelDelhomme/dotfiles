#!/bin/sh
# Extrait de shared/env.sh — chemins outils Android (exports seuls, pas de mkdir).
# Requiert ANDROID_HOME (12_android_exports.sh).

# Si ANDROID_HOME manque (échec d’un extrait précédent), les chemins restent vides sans bloquer.
export CMDLINE_TOOLS="${ANDROID_HOME}/cmdline-tools/latest/bin"
export PLATFORM_TOOLS="$ANDROID_HOME/platform-tools"
export ANDROID_TOOLS="$ANDROID_HOME/tools"
