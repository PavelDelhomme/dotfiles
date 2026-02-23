#!/bin/zsh
# =============================================================================
# CHECK INSTALLED - Utilitaires pour vérifier les installations
# =============================================================================
# Description: Fonctions pour vérifier si un outil est installé (toute distro, toute méthode)
# Author: Paul Delhomme
# Version: 1.1
# =============================================================================

# =============================================================================
# HELPERS GÉNÉRIQUES (détection multi-distro / multi-méthode)
# =============================================================================

# DESC: Retourne 0 si un binaire est trouvé dans le PATH (liste de noms)
# USAGE: _check_binaries name1 name2 ...
_check_binaries() {
    for name in "$@"; do
        command -v "$name" &>/dev/null && return 0
    done
    return 1
}

# DESC: Retourne 0 si un fichier .desktop correspondant existe (nom ou contenu Exec/Name)
# USAGE: _check_desktop_pattern pattern
_check_desktop_pattern() {
    local pattern="$1"
    local dirs=("/usr/share/applications" "$HOME/.local/share/applications")
    local f list
    for dir in "${dirs[@]}"; do
        [ ! -d "$dir" ] && continue
        # Liste des .desktop (find évite les soucis de glob vide)
        list=("${(@f)$(find "$dir" -maxdepth 2 -name "*.desktop" -type f 2>/dev/null)}")
        for f in "${list[@]}"; do
            [ ! -f "$f" ] && continue
            echo "${f:t}" | grep -qi "$pattern" && return 0
            grep -qiE "^(Exec|Name|Comment)=.*$pattern" "$f" 2>/dev/null && return 0
        done
    done
    return 1
}

# DESC: Retourne 0 si un paquet est installé (pacman, dpkg, rpm, snap, flatpak)
# USAGE: _check_package pkg1 pkg2 ... (au moins un trouvé)
_check_package() {
    if command -v pacman &>/dev/null; then
        for pkg in "$@"; do
            pacman -Qq "$pkg" 2>/dev/null && return 0
        done
    fi
    if command -v dpkg &>/dev/null; then
        for pkg in "$@"; do
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" && return 0
        done
    fi
    if command -v rpm &>/dev/null; then
        for pkg in "$@"; do
            rpm -q "$pkg" 2>/dev/null && return 0
        done
    fi
    if command -v snap &>/dev/null; then
        for pkg in "$@"; do
            snap list 2>/dev/null | awk '{print $1}' | grep -qi "^${pkg}$" && return 0
        done
    fi
    if command -v flatpak &>/dev/null; then
        for pkg in "$@"; do
            flatpak list --app 2>/dev/null | grep -qi "$pkg" && return 0
        done
    fi
    return 1
}

# DESC: Retourne 0 si un chemin exécutable existe
# USAGE: _check_paths /path1 /path2 ...
_check_paths() {
    for p in "$@"; do
        [ -x "$p" ] && [ -f "$p" ] && return 0
    done
    return 1
}

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

# DESC: Vérifie si CMake est installé
# USAGE: check_cmake_installed
check_cmake_installed() {
    if command -v cmake &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si GDB est installé
# USAGE: check_gdb_installed
check_gdb_installed() {
    if command -v gdb &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si les outils C sont installés (GCC, make)
# USAGE: check_c_tools_installed
check_c_tools_installed() {
    if command -v gcc &>/dev/null && command -v make &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si les outils C++ sont installés (G++, make, CMake)
# USAGE: check_cpp_tools_installed
check_cpp_tools_installed() {
    if command -v g++ &>/dev/null && command -v make &>/dev/null; then
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

# DESC: Vérifie si Docker est installé (binaire, socket, paquet)
# USAGE: check_docker_installed
check_docker_installed() {
    _check_binaries docker docker.io && { echo "installed"; return 0; }
    _check_package docker docker.io docker-ce docker-ce-cli containerd.io && { echo "installed"; return 0; }
    [[ -S /var/run/docker.sock ]] && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Brave est installé (toute distro: binaire, .desktop, paquet, flatpak, snap)
# USAGE: check_brave_installed
check_brave_installed() {
    _check_binaries brave brave-browser brave-browser-stable && { echo "installed"; return 0; }
    _check_paths /usr/bin/brave /usr/bin/brave-browser /usr/lib/brave/brave /usr/lib64/brave/brave && { echo "installed"; return 0; }
    _check_desktop_pattern "brave" && { echo "installed"; return 0; }
    _check_package brave-bin brave-browser com.brave.Browser && { echo "installed"; return 0; }
    # Fichiers .desktop nommés exactement (Arch: brave-bin.desktop)
    [[ -f /usr/share/applications/brave-bin.desktop ]] && { echo "installed"; return 0; }
    [[ -f /usr/share/applications/brave-browser.desktop ]] && { echo "installed"; return 0; }
    [[ -f $HOME/.local/share/applications/brave-bin.desktop ]] && { echo "installed"; return 0; }
    [[ -f $HOME/.local/share/applications/brave-browser.desktop ]] && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Google Chrome est installé
# USAGE: check_chrome_installed
check_chrome_installed() {
    _check_binaries google-chrome google-chrome-stable && { echo "installed"; return 0; }
    _check_paths /usr/bin/google-chrome /usr/bin/google-chrome-stable /opt/google/chrome/google-chrome && { echo "installed"; return 0; }
    _check_desktop_pattern "google-chrome" "chrome" && { echo "installed"; return 0; }
    _check_package google-chrome google-chrome-stable && { echo "installed"; return 0; }
    [[ -f /usr/share/applications/google-chrome.desktop ]] && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Cursor est installé (AppImage, paquet /usr/share/cursor, binaire, .desktop)
# USAGE: check_cursor_installed
check_cursor_installed() {
    _check_binaries cursor && { echo "installed"; return 0; }
    # Installation type paquet: /usr/bin/cursor -> /usr/share/cursor/cursor et resources/app
    _check_paths /usr/bin/cursor /usr/share/cursor/cursor && { echo "installed"; return 0; }
    [[ -d /usr/share/cursor/resources/app ]] && { echo "installed"; return 0; }
    # AppImage et autres chemins
    _check_paths /opt/cursor.appimage /opt/cursor/cursor /usr/local/bin/cursor "$HOME/.local/bin/cursor" \
        "$HOME/Applications/cursor.AppImage" "$HOME/Applications/Cursor.AppImage" \
        "$HOME/Applications/cursor" "$HOME/Applications/Cursor" \
        "/Applications/cursor.AppImage" "/Applications/Cursor.AppImage" "/Applications/cursor" "/Applications/Cursor" && { echo "installed"; return 0; }
    _check_desktop_pattern "cursor" && { echo "installed"; return 0; }
    [[ -f $HOME/.local/share/applications/cursor.desktop ]] && { echo "installed"; return 0; }
    [[ -f /usr/share/applications/cursor.desktop ]] && { echo "installed"; return 0; }
    if [[ -d "$HOME/Applications" ]]; then
        for f in "$HOME/Applications"/cursor*.AppImage "$HOME/Applications"/Cursor*.AppImage; do
            [[ -f "$f" ]] && [[ -x "$f" ]] && { echo "installed"; return 0; }
        done
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

# DESC: Vérifie si HandBrake est installé (CLI, GUI, toute distro: ghb, HandBrakeCLI, flatpak, .desktop)
# USAGE: check_handbrake_installed
check_handbrake_installed() {
    _check_binaries HandBrakeCLI HandBrake handbrake handbrake-cli ghb && { echo "installed"; return 0; }
    _check_paths /usr/bin/HandBrakeCLI /usr/bin/handbrake /usr/bin/ghb /usr/bin/HandBrake && { echo "installed"; return 0; }
    _check_desktop_pattern "handbrake" && { echo "installed"; return 0; }
    _check_desktop_pattern "ghb" && { echo "installed"; return 0; }
    _check_package handbrake handbrake-cli HandBrake-cli fr.handbrake.ghb org.handbrake.HandBrake && { echo "installed"; return 0; }
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

# DESC: Vérifie si Wine est installé (binaire, paquet toute distro)
# USAGE: check_wine_installed
check_wine_installed() {
    _check_binaries wine wine64 wine32 && { echo "installed"; return 0; }
    _check_package wine wine-staging wine64 wine32 wine-devel && { echo "installed"; return 0; }
    _check_paths /usr/bin/wine /usr/bin/wine64 && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

# DESC: Vérifie si PortProton est installé (native)
# USAGE: check_portproton_installed
check_portproton_installed() {
    local pp_paths=(
        "$HOME/PortProton/PortProton/data_from_portwine/scripts/start.sh"
        "$HOME/Games/PortProton/data_from_portwine/scripts/start.sh"
        "/opt/portproton/data_from_portwine/scripts/start.sh"
    )
    for p in "${pp_paths[@]}"; do
        [ -f "$p" ] && [ -x "$p" ] && { echo "installed"; return 0; }
    done
    if command -v portproton &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Proton Mail (client/bridge) est installé
# USAGE: check_protonmail_installed
check_protonmail_installed() {
    if command -v protonmail-bridge &>/dev/null || command -v proton-mail &>/dev/null; then
        echo "installed"
        return 0
    fi
    if flatpak list --app 2>/dev/null | grep -qi "proton.*mail\|ProtonMail"; then
        echo "installed"
        return 0
    fi
    if [ -f /usr/share/applications/protonmail*.desktop ] || [ -f "$HOME/.local/share/applications/protonmail*.desktop" ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si BlueMail est installé
# USAGE: check_bluemail_installed
check_bluemail_installed() {
    if command -v bluemail &>/dev/null || command -v BlueMail &>/dev/null; then
        echo "installed"
        return 0
    fi
    if flatpak list --app 2>/dev/null | grep -qi "bluemail\|BlueMail\|com.bluemail"; then
        echo "installed"
        return 0
    fi
    if [ -f /usr/share/applications/bluemail*.desktop ] || [ -f "$HOME/.local/share/applications/bluemail*.desktop" ]; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si Snap est installé (snapd)
# USAGE: check_snap_installed
check_snap_installed() {
    if command -v snap &>/dev/null; then
        echo "installed"
        return 0
    fi
    if systemctl is-enabled snapd &>/dev/null || systemctl is-active snapd &>/dev/null; then
        echo "installed"
        return 0
    fi
    echo "not_installed"
    return 1
}

# DESC: Vérifie si le client Nextcloud (sync) est installé
# USAGE: check_nextcloud_installed
check_nextcloud_installed() {
    _check_binaries nextcloud nextcloudcmd nextcloud-desktop && { echo "installed"; return 0; }
    _check_desktop_pattern "nextcloud" && { echo "installed"; return 0; }
    _check_package nextcloud-client nextcloud-desktop com.nextcloud.desktopclient.nextcloud && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

# DESC: Vérifie si DB Browser for SQLite est installé
# USAGE: check_db_browser_installed
check_db_browser_installed() {
    _check_binaries sqlitebrowser db-browser-for-sqlite && { echo "installed"; return 0; }
    _check_desktop_pattern "sqlitebrowser" && { echo "installed"; return 0; }
    _check_desktop_pattern "db-browser" && { echo "installed"; return 0; }
    _check_package sqlitebrowser db-browser-for-sqlite org.sqlitebrowser.sqlitebrowser && { echo "installed"; return 0; }
    echo "not_installed"
    return 1
}

