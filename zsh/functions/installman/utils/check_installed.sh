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

# DESC: Vérifie si une version spécifique de Java est installée
# USAGE: check_java_version_installed <version>
check_java_version_installed() {
    local version="$1"
    
    if [ -z "$version" ]; then
        echo "not_installed"
        return 1
    fi
    
    # Vérifier via command java
    if command -v java &>/dev/null; then
        local java_version_output=$(java -version 2>&1 | head -n1)
        if echo "$java_version_output" | grep -q "version \"${version}[^\"]*\""; then
            echo "installed"
            return 0
        fi
    fi
    
    # Vérifier dans /usr/lib/jvm
    local java_path=""
    if [ "$version" = "25" ]; then
        # Java 25 peut être dans différents chemins - vérifier le paquet installé
        if pacman -Q jdk-openjdk &>/dev/null 2>&1; then
            echo "installed"
            return 0
        fi
        # Vérifier aussi les chemins possibles
        if [ -d "/usr/lib/jvm/java-25-openjdk" ] || [ -d "/usr/lib/jvm/default" ] || [ -d "/usr/lib/jvm/java-openjdk" ]; then
            echo "installed"
            return 0
        fi
    else
        # Pour les autres versions, vérifier le paquet spécifique
        if [ "$version" = "8" ]; then
            if pacman -Q jdk8-openjdk &>/dev/null 2>&1 || [ -d "/usr/lib/jvm/java-8-openjdk" ]; then
                echo "installed"
                return 0
            fi
        elif [ "$version" = "11" ]; then
            if pacman -Q jdk11-openjdk &>/dev/null 2>&1 || [ -d "/usr/lib/jvm/java-11-openjdk" ]; then
                echo "installed"
                return 0
            fi
        elif [ "$version" = "17" ]; then
            if pacman -Q jdk17-openjdk &>/dev/null 2>&1 || [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
                echo "installed"
                return 0
            fi
        elif [ "$version" = "21" ]; then
            if pacman -Q jdk21-openjdk &>/dev/null 2>&1 || [ -d "/usr/lib/jvm/java-21-openjdk" ]; then
                echo "installed"
                return 0
            fi
        fi
        
        # Fallback: vérifier le répertoire
        java_path="/usr/lib/jvm/java-${version}-openjdk"
        if [ -d "$java_path" ]; then
            echo "installed"
            return 0
        fi
    fi
    
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Java 8 est installé
# USAGE: check_java8_installed
check_java8_installed() {
    check_java_version_installed 8
}

# DESC: Vérifie si Java 11 est installé
# USAGE: check_java11_installed
check_java11_installed() {
    check_java_version_installed 11
}

# DESC: Vérifie si Java 17 est installé
# USAGE: check_java17_installed
check_java17_installed() {
    check_java_version_installed 17
}

# DESC: Vérifie si Java 21 est installé
# USAGE: check_java21_installed
check_java21_installed() {
    check_java_version_installed 21
}

# DESC: Vérifie si Java 25 est installé
# USAGE: check_java25_installed
check_java25_installed() {
    check_java_version_installed 25
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
    # Vérifier si la commande cursor est dans le PATH
    if command -v cursor &>/dev/null; then
        echo "installed"
        return 0
    fi
    
    # Vérifier dans ~/Applications/ (AppImage)
    local cursor_paths=(
        "$HOME/Applications/cursor.AppImage"
        "$HOME/Applications/Cursor.AppImage"
        "$HOME/Applications/cursor"
        "$HOME/Applications/Cursor"
        "/Applications/cursor.AppImage"
        "/Applications/Cursor.AppImage"
        "/Applications/cursor"
        "/Applications/Cursor"
        "/opt/cursor/cursor"
        "/usr/local/bin/cursor"
        "$HOME/.local/bin/cursor"
    )
    
    for cursor_path in "${cursor_paths[@]}"; do
        if [ -f "$cursor_path" ] && [ -x "$cursor_path" ]; then
            echo "installed"
            return 0
        fi
    done
    
    # Vérifier aussi les variantes avec extension
    local cursor_variants=(
        "$HOME/Applications/cursor*.AppImage"
        "$HOME/Applications/Cursor*.AppImage"
    )
    
    for pattern in "${cursor_variants[@]}"; do
        # Utiliser find pour éviter les problèmes de glob
        if find "$HOME/Applications" -maxdepth 1 -iname "cursor*.AppImage" -type f 2>/dev/null | grep -q .; then
            echo "installed"
            return 0
        fi
    done
    
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

# DESC: Vérifie si les licences Android SDK sont acceptées
# USAGE: check_android_licenses_accepted
check_android_licenses_accepted() {
    local ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
    
    # Vérifier si le répertoire des licences existe et contient des licences
    if [ -d "$ANDROID_HOME/licenses" ]; then
        # Compter les fichiers de licence (peuvent être .txt ou sans extension)
        local license_count=$(find "$ANDROID_HOME/licenses" -type f \( -name "*.txt" -o -name "android-*" -o -name "google-*" -o -name "intel-*" -o -name "mips-*" \) 2>/dev/null | wc -l)
        if [ "$license_count" -gt 0 ]; then
            echo "installed"
            return 0
        fi
    fi
    
    echo "not_installed"
    return 1
}

# DESC: Vérifie si SSH est configuré (au moins une connexion dans ~/.ssh/config)
# USAGE: check_ssh_configured
check_ssh_configured() {
    local SSH_CONFIG="$HOME/.ssh/config"
    
    # Vérifier si le fichier config existe et contient au moins un Host (non commenté)
    if [ -f "$SSH_CONFIG" ]; then
        local host_count=$(grep -E "^Host " "$SSH_CONFIG" 2>/dev/null | grep -v "^\*$" | wc -l)
        if [ "$host_count" -gt 0 ]; then
            echo "installed"
            return 0
        fi
    fi
    
    echo "not_installed"
    return 1
}

# DESC: Vérifie si HandBrake est installé (CLI ou GUI)
# USAGE: check_handbrake_installed
check_handbrake_installed() {
    if command -v HandBrakeCLI &>/dev/null || command -v HandBrake &>/dev/null || command -v handbrake &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si les outils réseau sont installés
# USAGE: check_network_tools_installed
check_network_tools_installed() {
    local tools_installed=0
    local tools_total=9
    
    # Vérifier chaque outil
    command -v nslookup &>/dev/null && ((tools_installed++))
    command -v dig &>/dev/null && ((tools_installed++))
    command -v traceroute &>/dev/null && ((tools_installed++))
    command -v whois &>/dev/null && ((tools_installed++))
    command -v nmap &>/dev/null && ((tools_installed++))
    command -v tcpdump &>/dev/null && ((tools_installed++))
    command -v iftop &>/dev/null && ((tools_installed++))
    (command -v nc &>/dev/null || command -v netcat &>/dev/null) && ((tools_installed++))
    command -v lsof &>/dev/null && ((tools_installed++))
    
    # Considérer comme installé si au moins 7/9 outils sont présents
    if [ "$tools_installed" -ge 7 ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

