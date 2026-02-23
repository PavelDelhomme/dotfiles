#!/bin/zsh
# =============================================================================
# VERSION UTILS - Utilitaires pour gérer les versions d'outils
# =============================================================================
# Description: Fonctions pour détecter et gérer les versions d'outils
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# =============================================================================
# FONCTIONS DE DÉTECTION DE VERSION
# =============================================================================

# DESC: Obtient la version actuelle d'un outil installé
# USAGE: get_current_version <tool_name>
# RETURNS: Version actuelle ou "not_installed" si non installé
get_current_version() {
    local tool_name="$1"
    
    case "$tool_name" in
        flutter)
            if command -v flutter &>/dev/null; then
                flutter --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        dotnet)
            if command -v dotnet &>/dev/null; then
                dotnet --version 2>/dev/null || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        docker)
            if command -v docker &>/dev/null; then
                docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        java8|java11|java17|java21|java25)
            local java_version=$(echo "$tool_name" | sed 's/java//')
            if command -v "java${java_version}" &>/dev/null || command -v java &>/dev/null; then
                java -version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        emacs)
            if command -v emacs &>/dev/null; then
                emacs --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        cursor)
            if [ -x "/opt/cursor.appimage" ]; then
                /opt/cursor.appimage --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            elif command -v cursor &>/dev/null; then
                cursor --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            elif [ -f /usr/share/cursor/resources/app/product.json ]; then
                grep -oE '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' /usr/share/cursor/resources/app/product.json 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        brave)
            if command -v brave &>/dev/null || command -v brave-browser &>/dev/null; then
                (brave --version 2>/dev/null || brave-browser --version 2>/dev/null) | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        chrome|google-chrome)
            if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
                (google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null) | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown"
            else
                echo "not_installed"
            fi
            ;;
        *)
            # Pour les autres outils, essayer de détecter via command --version
            if command -v "$tool_name" &>/dev/null; then
                local version_output=$("$tool_name" --version 2>/dev/null | head -n1)
                if [ -n "$version_output" ]; then
                    echo "$version_output" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 || echo "installed"
                else
                    echo "installed"
                fi
            else
                echo "not_installed"
            fi
            ;;
    esac
}

# DESC: Obtient les versions disponibles pour un outil
# USAGE: get_available_versions <tool_name>
# RETURNS: Liste des versions disponibles (une par ligne)
get_available_versions() {
    local tool_name="$1"
    
    case "$tool_name" in
        flutter)
            # Récupérer les versions Flutter depuis GitHub
            curl -s https://api.github.com/repos/flutter/flutter/releases 2>/dev/null | \
                grep -oE '"tag_name":\s*"v?[0-9]+\.[0-9]+\.[0-9]+' | \
                sed 's/"tag_name":\s*"v\?//' | \
                sed 's/"//' | \
                sort -V -r | head -20 || echo "latest"
            ;;
        dotnet)
            # Récupérer les versions .NET depuis Microsoft
            curl -s https://api.github.com/repos/dotnet/core/releases 2>/dev/null | \
                grep -oE '"tag_name":\s*"v?[0-9]+\.[0-9]+\.[0-9]+' | \
                sed 's/"tag_name":\s*"v\?//' | \
                sed 's/"//' | \
                sort -V -r | head -20 || echo "latest"
            ;;
        docker)
            # Pour Docker, on utilise généralement la dernière version du repo
            echo "latest"
            ;;
        java8|java11|java17|java21|java25)
            # Pour Java, les versions sont fixes
            local java_version=$(echo "$tool_name" | sed 's/java//')
            echo "$java_version"
            ;;
        cursor)
            # Version lue dynamiquement depuis https://cursor.com/download lors de l'install/update
            echo "latest"
            ;;
        *)
            # Pour les autres outils, on propose "latest"
            echo "latest"
            ;;
    esac
}

# DESC: Obtient la dernière version disponible
# USAGE: get_latest_version <tool_name>
# RETURNS: Dernière version disponible
get_latest_version() {
    local tool_name="$1"
    local versions=$(get_available_versions "$tool_name")
    echo "$versions" | head -n1
}

# DESC: Compare deux versions
# USAGE: compare_versions <version1> <version2>
# RETURNS: -1 si version1 < version2, 0 si égales, 1 si version1 > version2
compare_versions() {
    local v1="$1"
    local v2="$2"
    
    # Si une version est "latest" ou "not_installed", on ne peut pas comparer
    if [ "$v1" = "latest" ] || [ "$v1" = "not_installed" ] || [ "$v1" = "unknown" ] || \
       [ "$v2" = "latest" ] || [ "$v2" = "not_installed" ] || [ "$v2" = "unknown" ]; then
        return 0
    fi
    
    # Comparaison simple avec sort -V
    if [ "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1)" = "$v1" ]; then
        if [ "$v1" = "$v2" ]; then
            return 0  # Égales
        else
            return -1  # v1 < v2
        fi
    else
        return 1  # v1 > v2
    fi
}

# DESC: Vérifie si une mise à jour est disponible
# USAGE: is_update_available <tool_name>
# RETURNS: 0 si mise à jour disponible, 1 sinon
is_update_available() {
    local tool_name="$1"
    local current_version=$(get_current_version "$tool_name")
    local latest_version=$(get_latest_version "$tool_name")
    
    if [ "$current_version" = "not_installed" ] || [ "$current_version" = "unknown" ]; then
        return 1
    fi
    
    if [ "$latest_version" = "latest" ] || [ "$latest_version" = "unknown" ]; then
        return 1
    fi
    
    compare_versions "$current_version" "$latest_version"
    local cmp_result=$?
    
    # Si current < latest, mise à jour disponible
    if [ $cmp_result -eq -1 ]; then
        return 0
    else
        return 1
    fi
}

