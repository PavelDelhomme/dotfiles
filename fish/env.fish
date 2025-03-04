# Vérifier si PATH_ORIGINAL existe
if not set -q PATH_ORIGINAL
    set -gx PATH_ORIGINAL $PATH
end

# Java (pour Android Studio)
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk

# Android SDK
#set -gx ANDROID_HOME $HOME/Android/Sdk
#set -gx ANDROID_SDK_ROOT $ANDROID_HOME

# Flutter Path
#set -gx FLUTTER_ROOT $HOME/flutter/bin
set -gx FLUTTER_ROOT /opt/flutter

# Création des répertoires nécessaires
#mkdir -p $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/tools

# Dart pub-cache
set -gx PUB_CACHE $HOME/.pub-cache
mkdir -p $PUB_CACHE/bin

# Emacs & Doom
set -gx EMACSDIR $HOME/.emacs.d/bin

# .NET SDK
set -gx DOTNET_PATH $HOME/.dotnet/tools

# Fonction pour ajouter des chemins au PATH
function add_to_path
    contains $argv $PATH; or set -gx PATH $argv $PATH
end
# Ajout des chemins au PATH
function add_to_path
    contains $argv $PATH; or set -gx PATH $argv $PATH
end
# Ajout des chemins au PATH
add_to_path $JAVA_HOME/bin
#add_to_path $ANDROID_HOME/cmdline-tools/latest/bin
#add_to_path $ANDROID_HOME/platform-tools
#add_to_path $ANDROID_HOME/tools
add_to_path $PUB_CACHE/bin
add_to_path /opt/flutter/bin
#add_to_path $FLUTTER_ROOT/bin
add_to_path $EMACSDIR
add_to_path $DOTNET_PATH
add_to_path /opt/flutter/bin/cache/dart-sdk/bin

# Nettoyage du PATH (suppression des doublons)
set -gx PATH (echo $PATH | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ')
set -gx PATH $FLUTTER_ROOT/bin $DART_SDK $PATH
#set -gx PATH $FLUTTER_ROOT/bin $DART_SDK $ANDROID_HOME/platform-tools $PATH
# Ajout de l'exécutable Chrome au PATH
add_to_path /usr/bin


# Ajout chrome executable
set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
echo "✔ ~/dotfiles/fish/env.fish chargé avec succès"

set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
