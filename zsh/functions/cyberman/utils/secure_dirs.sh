#!/bin/zsh
# =============================================================================
# Sécurisation automatique des dossiers cyberman
# =============================================================================
# Description: Sécurise les dossiers .cyberman avec les bonnes permissions
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Fonction pour sécuriser les dossiers cyberman
secure_cyberman_dirs() {
    local cyberman_dir="$HOME/.cyberman"
    
    if [ ! -d "$cyberman_dir" ]; then
        return 0  # N'existe pas encore, sera créé avec les bonnes permissions
    fi
    
    # Créer les sous-dossiers s'ils n'existent pas
    local subdirs=(
        "$cyberman_dir/environments"
        "$cyberman_dir/reports"
        "$cyberman_dir/workflows"
        "$cyberman_dir/scans"
        "$cyberman_dir/templates"
        "$cyberman_dir/config"
        "$cyberman_dir/scripts"
    )
    
    for dir in "${subdirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
        fi
        # Permissions 700 pour dossiers
        chmod 700 "$dir" 2>/dev/null || true
    done
    
    # Permissions 700 pour le dossier principal
    chmod 700 "$cyberman_dir" 2>/dev/null || true
    
    # Permissions 600 pour tous les fichiers
    find "$cyberman_dir" -type f -exec chmod 600 {} \; 2>/dev/null || true
    
    # S'assurer que l'utilisateur est propriétaire
    chown -R "$USER:$USER" "$cyberman_dir" 2>/dev/null || true
}

# Appeler automatiquement si le script est sourcé
if [ "${ZSH_EVAL_CONTEXT:-}" = "toplevel:file" ] || [ -n "${ZSH_VERSION:-}" ]; then
    secure_cyberman_dirs
fi

