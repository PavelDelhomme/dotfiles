#!/bin/sh
# Extrait partiel de shared/env.sh — SDK Android (exports seuls).
# Les mkdir sur cmdline-tools / platform-tools / tools restent dans ../../shared/env.sh jusqu’à migration dédiée.

export ANDROID_HOME="${HOME:-}/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
