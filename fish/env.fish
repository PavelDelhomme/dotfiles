# Vérifier si PATH_ORIGINAL existe
if not set -q PATH_ORIGINAL
    set -gx PATH_ORIGINAL $PATH
end

# Java (pour Android Studio)
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
#set -gx JAVA_HOME_21 /usr/lib/jvm/java-21-openjdk

# Flutter Path
set -gx FLUTTER_ROOT /opt/flutter

# Dart pub-cache
set -gx PUB_CACHE $HOME/.pub-cache
command mkdir -p $PUB_CACHE/bin

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
add_to_path $PUB_CACHE/bin
add_to_path /opt/flutter/bin
add_to_path $EMACSDIR
add_to_path $DOTNET_PATH
add_to_path /opt/flutter/bin/cache/dart-sdk/bin
add_to_path /home/pactivisme/kotlin/bin

# Nettoyage du PATH (suppression des doublons)
set -gx PATH (string join ' ' (set -l unique; for i in (string split ' ' $PATH); if not contains $i $unique; set unique $unique $i; end; set -l result $unique; echo $result))

set -gx PATH $FLUTTER_ROOT/bin $DART_SDK $PATH
# Ajout de l'exécutable Chrome au PATH
add_to_path /usr/bin


# Ajout chrome executable
set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
echo "✔ ~/dotfiles/fish/env.fish chargé avec succès"

set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
