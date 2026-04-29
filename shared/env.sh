if [ -z "${PATH_ORIGINAL:-}" ]; then
	export PATH_ORIGINAL="$PATH"
fi

# Log discret (désactivable via DOTFILES_ENV_QUIET=1)
_dotfiles_env_log() {
	[ -n "${DOTFILES_ENV_QUIET:-}" ] && return 0
	printf '%s\n' "$1"
}

# === Export des variables d'environnement ===

# Java (pour Android Studio)
#export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export CHROME_EXECUTABLE="/usr/bin/chromium"

CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools/latest/bin"
PLATFORM_TOOLS="$ANDROID_HOME/platform-tools"
ANDROID_TOOLS="$ANDROID_HOME/tools"

# Crée les répertoires nécessaires s'ils n'existent pas (tolérant en lecture seule)
mkdir -p "$CMDLINE_TOOLS" "$PLATFORM_TOOLS" "$ANDROID_TOOLS" 2>/dev/null || true


# Dart pub-cache
PUB_FLUTTER="$HOME/.pub-cache"
PUB_FLUTTER_BIN="$PUB_FLUTTER/bin"
mkdir -p "$PUB_FLUTTER_BIN" 2>/dev/null || true
export PUB_CACHE="$PUB_FLUTTER"

# Emacs & Doom
export EMACSDIR="$HOME/.emacs.d/bin"

# .NET SDK
export DOTNET_PATH="$HOME/.dotnet/tools"

# === Ajout des chemins au PATH ===
_dotfiles_add_to_path() {
	_p="$1"
	[ -z "$_p" ] && return 0
	case ":$PATH:" in
		*":$_p:"*) ;;
		*) PATH="$_p:$PATH" ;;
	esac
}

if type add_to_path >/dev/null 2>&1; then
	add_to_path "/usr/lib/jvm/java-17-openjdk/bin"
	add_to_path "$CMDLINE_TOOLS"
	add_to_path "$PLATFORM_TOOLS"
	add_to_path "$ANDROID_TOOLS"
	add_to_path "$PUB_FLUTTER_BIN"
	add_to_path "/opt/flutter/bin"
	add_to_path "$EMACSDIR"
	add_to_path "$DOTNET_PATH"
else
	_dotfiles_add_to_path "/usr/lib/jvm/java-17-openjdk/bin"
	_dotfiles_add_to_path "$CMDLINE_TOOLS"
	_dotfiles_add_to_path "$PLATFORM_TOOLS"
	_dotfiles_add_to_path "$ANDROID_TOOLS"
	_dotfiles_add_to_path "$PUB_FLUTTER_BIN"
	_dotfiles_add_to_path "/opt/flutter/bin"
	_dotfiles_add_to_path "$EMACSDIR"
	_dotfiles_add_to_path "$DOTNET_PATH"
fi

export PATH
export ADDED_FLUTTER_PATH="/opt/flutter/bin"

# Nettoyage du PATH
if type clean_path >/dev/null 2>&1; then
	clean_path
fi

case ":$PATH:" in
	*":$ADDED_FLUTTER_PATH:"*) ;;
	*) PATH="$PATH:$ADDED_FLUTTER_PATH" ;;
esac
export PATH

export NDK_HOME="$ANDROID_HOME/ndk"

# Affiche un message de confirmation (interactive uniquement)
if [ -t 1 ]; then
	_dotfiles_env_log "✔ env.sh chargé"
fi

