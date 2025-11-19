#!/bin/bash
################################################################################
# Script temporaire pour refactoriser tous les scripts
# Remplace les définitions de couleurs et fonctions de log par common.sh
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Fonction pour modifier un fichier
refactor_file() {
    local file="$1"
    local common_include="$2"
    
    echo "Traitement: $file"
    
    # Lire le fichier
    local content=$(cat "$file")
    
    # Vérifier si déjà modifié
    if echo "$content" | grep -q "source.*lib/common.sh"; then
        echo "  → Déjà modifié, ignoré"
        return
    fi
    
    # Extraire le shebang et les premiers commentaires (jusqu'à set -e/+e)
    local shebang=$(echo "$content" | head -n 1)
    local comments=$(echo "$content" | sed -n '2,/^set [+-]e/p' | head -n -1)
    local set_line=$(echo "$content" | grep "^set [+-]e" | head -n 1)
    
    # Trouver où commencent les définitions de couleurs
    local color_start=$(echo "$content" | grep -n "^RED=" | head -n 1 | cut -d: -f1)
    if [ -z "$color_start" ]; then
        echo "  → Pas de définition de couleurs trouvée"
        return
    fi
    
    # Trouver où se termine le bloc (DOTFILES_DIR ou première fonction utile)
    local color_end=$(echo "$content" | sed -n "${color_start},\$p" | grep -n "^[A-Z_]*=.*\$HOME\|^[a-z_]*()" | head -n 2 | tail -n 1 | cut -d: -f1)
    color_end=$((color_start + color_end - 1))
    
    if [ -z "$color_end" ]; then
        # Chercher la première ligne qui n'est pas une définition
        color_end=$(echo "$content" | sed -n "${color_start},\$p" | grep -n -v "^[A-Z_]*=\|^log_[a-z]*()" | head -n 1 | cut -d: -f1)
        color_end=$((color_start + color_end - 1))
    fi
    
    # Créer le nouveau contenu
    local before=$(echo "$content" | head -n $((color_start - 1)))
    local after=$(echo "$content" | sed -n "$((color_end + 1)),\$p")
    
    # Écrire le nouveau fichier
    {
        echo "$before"
        echo ""
        echo "# Charger la bibliothèque commune"
        echo "$common_include"
        echo ""
        echo "$after"
    } > "$file.tmp"
    
    mv "$file.tmp" "$file"
    echo "  → Modifié avec succès"
}

# Liste des fichiers à modifier
files=(
    "scripts/config/git_config.sh"
    "scripts/config/git_remote.sh"
    "scripts/config/qemu_libvirt.sh"
    "scripts/config/qemu_network.sh"
    "scripts/install/dev/install_docker.sh"
    "scripts/install/dev/install_docker_tools.sh"
    "scripts/install/dev/install_go.sh"
    "scripts/install/apps/install_portproton.sh"
    "scripts/install/system/package_managers.sh"
    "scripts/install/system/packages_base.sh"
    "scripts/install/tools/install_yay.sh"
    "scripts/install/tools/install_qemu_full.sh"
    "scripts/install/tools/install_qemu_simple.sh"
    "scripts/install/install_all.sh"
    "scripts/install/verify_network.sh"
    "scripts/install/archive_manjaro_setup_final.sh"
    "scripts/uninstall/rollback_all.sh"
    "scripts/uninstall/rollback_git.sh"
    "scripts/uninstall/reset_all.sh"
    "scripts/migrate_existing_user.sh"
    "scripts/migrate_shell.sh"
    "scripts/sync/install_auto_sync.sh"
    "scripts/test/validate_setup.sh"
    "scripts/vm/create_test_vm.sh"
)

for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Fichier non trouvé: $file"
        continue
    fi
    
    # Calculer le chemin relatif vers lib/common.sh
    depth=$(echo "$file" | tr -cd '/' | wc -c)
    depth=$((depth - 1))  # -1 pour scripts/
    
    if [ "$depth" -eq 1 ]; then
        # Dans scripts/config/ ou scripts/install/
        common_include='SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}'
    else
        # Dans scripts/install/apps/ etc (depth 2)
        common_include='SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}'
    fi
    
    refactor_file "$file" "$common_include"
done

echo ""
echo "Refactorisation terminée!"

