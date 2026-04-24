#!/bin/sh
# Extrait de shared/env.sh — Flutter + NDK (exports seuls ; PATH/add_to_path ailleurs).

export ADDED_FLUTTER_PATH="/opt/flutter/bin"
# ANDROID_HOME doit venir de 12_android_exports.sh (ordre lexicographique).
export NDK_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}/ndk"
