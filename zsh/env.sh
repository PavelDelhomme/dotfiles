# === Export des variables d'environnement ===
# Java (pour Android Studio)
#export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Dart pub-cache
export PUB_CACHE="$HOME/.pub-cache"

# Emacs & Doom
export EMACSDIR="$HOME/.emacs.d/bin"

export DOTNET_ROOT="/usr/share/dotnet"
export MSBuildSDKsPath="$DOTNET_ROOT/sdk/$(${DOTNET_ROOT}/dotnet --version)/Sdks"

# === Ajout des chemins au PATH ===
if type add_to_path &> /dev/null; then
    #add_to_path "$JAVA_HOME/bin"
    add_to_path "/usr/lib/jvm/java-17-openjdk/bin"
    #add_to_path "$ANDROID_HOME/emulator"
    add_to_path "$ANDROID_HOME/cmdline-tools/bin"
    add_to_path "$ANDROID_HOME/platform-tools"
    add_to_path "$ANDROID_HOME/tools"
    add_to_path "$PUB_CACHE/bin"
    add_to_path "/opt/flutter/bin"
    #add_to_path "/usr/local/share/doom-emacs/bin"
    add_to_path "$EMACSDIR"
    add_to_path "$DOTNET_ROOT"
    add_to_path "$HOME/.dotnet/tools"
else
    echo "❌ La fonction add_to_path n'est pas disponible."
fi

# Affiche un message de confirmation
echo "✔️  ~/dotfiles/zsh/env.sh chargé avec succès"

