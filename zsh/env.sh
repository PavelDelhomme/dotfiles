if [ -z "$PATH_ORIGINAL" ]; then
	export PATH_ORIGINAL=$PATH
fi

# === Export des variables d'environnement ===

# Java (pour Android Studio)
#export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"


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
if type add_to_path &> /dev/null; then
    add_to_path "/usr/lib/jvm/java-17-openjdk/bin"
    add_to_path "$CMDLINE_TOOLS"
    add_to_path "$PLATFORM_TOOLS"
    add_to_path "$ANDROID_TOOLS"
    add_to_path "$PUB_FLUTTER_BIN"
    add_to_path "/opt/flutter/bin"
    add_to_path "$EMACSDIR"
    add_to_path "$DOTNET_PATH"
else
    echo "❌ La fonction add_to_path n'est pas disponible."
fi

# Nettoyage du PATH
if type clean_path &> /dev/null; then
	clean_path
else
	echo "❌ La fonction clean_path n'est pas disponible."
fi

export PATH="$PATH:$PATH_ORIGINAL"

# Affiche un message de confirmation
echo "✔️  ~/dotfiles/zsh/env.sh chargé avec succès"

