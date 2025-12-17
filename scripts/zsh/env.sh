# Variables d'environnement
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH="$PATH:$JAVA_HOME/bin"

export ANDROID_HOME=${ANDROID_HOME:-/opt/android-sdk}
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin"

export PATH="$PATH:/opt/flutter/bin"
export PUB_CACHE="$HOME/.pub-cache"
export PATH="$PATH:$PUB_CACHE/bin"

export PATH="$PATH:$HOME/.dotnet/tools"
