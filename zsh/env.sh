if [ -z "$PATH_ORIGINAL" ]; then
	export PATH_ORIGINAL=$PATH
fi

# === Export des variables d'environnement ===

# Java (pour Android Studio et Flutter)
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk}"
export PATH="$PATH:$JAVA_HOME/bin"

# Android SDK
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
# Fallback vers l'ancien emplacement si /opt/android-sdk n'existe pas
if [ ! -d "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
fi
export CHROME_EXECUTABLE="/usr/bin/chromium"

CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools/latest/bin"
PLATFORM_TOOLS="$ANDROID_HOME/platform-tools"
ANDROID_TOOLS="$ANDROID_HOME/tools"

# Crée les répertoires nécessaires s'ils n'existent pas
mkdir -p "$CMDLINE_TOOLS" "$PLATFORM_TOOLS" "$ANDROID_TOOLS"


# Dart pub-cache
PUB_FLUTTER="$HOME/.pub-cache"
PUB_FLUTTER_BIN="$PUB_FLUTTER/bin"
mkdir -p "$PUB_FLUTTER_BIN"
export PUB_CACHE="$PUB_FLUTTER"

# Emacs & Doom
export EMACSDIR="$HOME/.emacs.d/bin"

# .NET SDK
export DOTNET_PATH="$HOME/.dotnet/tools"

# === Ajout des chemins au PATH ===
# Vérifier si add_to_path est disponible (fonction définie dans pathman.zsh)
if command -v add_to_path >/dev/null 2>&1 || type add_to_path >/dev/null 2>&1 || declare -f add_to_path >/dev/null 2>&1; then
    add_to_path "$JAVA_HOME/bin" 2>/dev/null || true
    add_to_path "$CMDLINE_TOOLS" 2>/dev/null || true
    add_to_path "$PLATFORM_TOOLS" 2>/dev/null || true
    add_to_path "$ANDROID_TOOLS" 2>/dev/null || true
    add_to_path "$PUB_FLUTTER_BIN" 2>/dev/null || true
    add_to_path "/opt/flutter/bin" 2>/dev/null || true
    add_to_path "$EMACSDIR" 2>/dev/null || true
    add_to_path "$DOTNET_PATH" 2>/dev/null || true
    # Android Platform Tools (ADB) - /opt/android-sdk
    if [ -d "/opt/android-sdk/platform-tools" ]; then
        add_to_path "/opt/android-sdk/platform-tools" 2>/dev/null || true
    fi
    # Android Build Tools - /opt/android-sdk
    if [ -d "/opt/android-sdk/build-tools" ]; then
        LATEST_BUILD_TOOLS=$(ls -td /opt/android-sdk/build-tools/*/ 2>/dev/null | head -1)
        if [ -n "$LATEST_BUILD_TOOLS" ]; then
            add_to_path "${LATEST_BUILD_TOOLS%/}" 2>/dev/null || true
        fi
    fi
    # Android SDK Tools - /opt/android-sdk
    if [ -d "/opt/android-sdk/tools" ]; then
        add_to_path "/opt/android-sdk/tools" 2>/dev/null || true
        add_to_path "/opt/android-sdk/tools/bin" 2>/dev/null || true
    fi
    # .NET Tools
    add_to_path "$HOME/.dotnet/tools" 2>/dev/null || true
else
    # Fallback: ajouter directement au PATH si la fonction n'est pas disponible
    for dir in "/usr/lib/jvm/java-17-openjdk/bin" "$CMDLINE_TOOLS" "$PLATFORM_TOOLS" "$ANDROID_TOOLS" "$PUB_FLUTTER_BIN" "/opt/flutter/bin" "$EMACSDIR" "$DOTNET_PATH"; do
        if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
            export PATH="$dir:$PATH"
        fi
    done
fi
export ADDED_FLUTTER_PATH="/opt/flutter/bin"

# Nettoyage du PATH
if command -v clean_path >/dev/null 2>&1 || type clean_path >/dev/null 2>&1 || declare -f clean_path >/dev/null 2>&1; then
    clean_path 2>/dev/null || true
else
    # Fallback: nettoyage basique du PATH
    # Supprimer les doublons et les chemins invalides
    local old_IFS="$IFS"
    IFS=':'
    local path_array=($PATH)
    IFS="$old_IFS"
    local new_path=""
    local seen=""
    for dir in "${path_array[@]}"; do
        if [ -n "$dir" ] && [ -d "$dir" ]; then
            if [[ ":$seen:" != *":$dir:"* ]]; then
                new_path="$new_path:$dir"
                seen="$seen:$dir"
            fi
        fi
    done
    export PATH="${new_path#:}"
fi

export PATH="$PATH:$PATH_ORIGINAL:$ADDED_FLUTTER_PATH"

export NDK_HOME="$ANDROID_HOME/ndk"

# Affiche un message de confirmation
echo "✔️  ~/dotfiles/zsh/env.sh chargé avec succès"


# Local bin (PortProton, etc.)
export PATH="$PATH:$HOME/.local/bin"
