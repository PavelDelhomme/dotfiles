# Vérifier si PATH_ORIGINAL existe
if not set -q PATH_ORIGINAL
    set -gx PATH_ORIGINAL $PATH
end

# Java (pour Android Studio)
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
#set -gx JAVA_HOME_21 /usr/lib/jvm/java-21-openjdk

# Flutter Path
set -gx FLUTTER_ROOT /opt/flutter

# Android Home
set -gx ANDROID_HOME $HOME/Android/Sdk

# Dart pub-cache
set -gx PUB_CACHE $HOME/.pub-cache
/usr/bin/mkdir -p $PUB_CACHE/bin

# Emacs & Doom
set -gx EMACSDIR $HOME/.emacs.d/bin

# .NET SDK
set -gx DOTNET_PATH $HOME/.dotnet/tools

# Fonction pour ajouter des chemins au PATH
function add_to_path
    contains $argv $PATH; or set -gx PATH $argv $PATH
end

# Ajout des chemins au PATH
add_to_path $JAVA_HOME/bin
add_to_path $PUB_CACHE/bin
add_to_path /opt/flutter/bin
add_to_path $EMACSDIR
add_to_path $DOTNET_PATH
add_to_path /opt/flutter/bin/cache/dart-sdk/bin
add_to_path /home/pactivisme/kotlin/bin
add_to_path $ANDROID_HOME/platforms-tools
add_to_path $ANDROID_HOME/cmdline-tools/latest/bin
add_to_path $ANDROID_HOME/emulator


# Ajout de l'exécutable Chrome au PATH
add_to_path /usr/bin

# Utilisation de fish_add_path pour ajouter des chemins
fish_add_path $FLUTTER_ROOT/bin
fish_add_path /home/pactivisme/kotlin/bin

echo "PATH ACTUEL : $PATH"
# Ajout chrome executable
set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
echo "✔ ~/dotfiles/fish/env.fish chargé avec succès"

set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable

# Activation des fonctionnalité expérimentales
export COMPOSE_BAKE=true
export DOCKER_BUILDKIT=1

