#!/bin/zsh
# =============================================================================
# CHECK INSTALLED - Utilitaires pour vérifier les installations
# =============================================================================
# Description: Fonctions pour vérifier si un outil est installé
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# =============================================================================
# FONCTIONS DE VÉRIFICATION
# =============================================================================

# DESC: Vérifie si Flutter est installé
# USAGE: check_flutter_installed
check_flutter_installed() {
    local flutter_bin="/opt/flutter/bin/flutter"
    if [ -f "$flutter_bin" ] && [ -x "$flutter_bin" ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si .NET est installé
# USAGE: check_dotnet_installed
check_dotnet_installed() {
    if command -v dotnet &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Emacs est installé
# USAGE: check_emacs_installed
check_emacs_installed() {
    if command -v emacs &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Java 17 est installé
# USAGE: check_java17_installed
check_java17_installed() {
    if command -v java &>/dev/null; then
        local java_version=$(java -version 2>&1 | head -n1 | grep -oP 'version "17[^"]*"')
        if [ -n "$java_version" ]; then
            echo "installed"
            return 0
        fi
    fi
    # Vérifier aussi dans /usr/lib/jvm
    if [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Android Studio est installé
# USAGE: check_android_studio_installed
check_android_studio_installed() {
    if command -v android-studio &>/dev/null || [ -f /opt/android-studio/bin/studio.sh ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si les outils Android (ADB, SDK) sont installés
# USAGE: check_android_tools_installed
check_android_tools_installed() {
    if command -v adb &>/dev/null; then
        echo "installed"
        return 0
    fi
    # Vérifier aussi dans /opt/android-sdk
    if [ -d "/opt/android-sdk/platform-tools" ] && [ -f "/opt/android-sdk/platform-tools/adb" ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Android SDK est installé (pour Flutter)
# USAGE: check_android_sdk_installed
check_android_sdk_installed() {
    # Vérifier plusieurs emplacements possibles
    local android_sdk_paths=(
        "/opt/android-sdk"
        "$HOME/Android/Sdk"
        "$HOME/.android/sdk"
    )
    
    for sdk_path in "${android_sdk_paths[@]}"; do
        if [ -d "$sdk_path" ] && [ -d "$sdk_path/platform-tools" ]; then
            echo "installed"
            return 0
        fi
    done
    
    # Vérifier aussi via adb
    if command -v adb &>/dev/null; then
        echo "installed"
        return 0
    fi
    
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Docker est installé
# USAGE: check_docker_installed
check_docker_installed() {
    if command -v docker &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Brave est installé
# USAGE: check_brave_installed
check_brave_installed() {
    if command -v brave &>/dev/null || command -v brave-browser &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Cursor est installé
# USAGE: check_cursor_installed
check_cursor_installed() {
    if command -v cursor &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si QEMU/KVM est installé
# USAGE: check_qemu_installed
check_qemu_installed() {
    if command -v qemu-system-x86_64 &>/dev/null && command -v virsh &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

