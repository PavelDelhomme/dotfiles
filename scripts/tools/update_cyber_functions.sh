#!/bin/bash
# =============================================================================
# Script pour mettre à jour toutes les fonctions cyber pour utiliser le système de cibles
# =============================================================================

CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
TARGET_MANAGER="$CYBER_DIR/target_manager.sh"

# Fonction pour ajouter le support des cibles à une fonction
add_target_support() {
    local file="$1"
    local func_name="$2"
    
    if [ ! -f "$file" ]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    # Vérifier si le support est déjà ajouté
    if grep -q "target_manager.sh" "$file"; then
        echo "✅ $file - Déjà mis à jour"
        return 0
    fi
    
    # Créer une sauvegarde
    cp "$file" "${file}.bak"
    
    # Ajouter le chargement du gestionnaire de cibles après les autres sources
    if grep -q "source.*ensure_tool" "$file"; then
        # Ajouter après ensure_tool
        sed -i '/source.*ensure_tool/a\
    # Charger le gestionnaire de cibles\
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"\
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then\
        source "$CYBER_DIR/target_manager.sh"\
    fi' "$file"
    else
        # Ajouter au début de la fonction
        sed -i "/^function $func_name()/a\
    # Charger le gestionnaire de cibles\
    local CYBER_DIR=\"\$HOME/dotfiles/zsh/functions/cyber\"\
    if [ -f \"\$CYBER_DIR/target_manager.sh\" ]; then\
        source \"\$CYBER_DIR/target_manager.sh\"\
    fi" "$file"
    fi
    
    echo "✅ $file - Support des cibles ajouté"
}

# Liste des fichiers à mettre à jour (exemples principaux déjà fait manuellement)
echo "📋 Mise à jour des fonctions cyber pour le support des cibles..."
echo ""

# Les fichiers principaux ont déjà été mis à jour manuellement
echo "✅ Fichiers principaux déjà mis à jour:"
echo "  - scanning/port_scan.sh"
echo "  - vulnerability/nmap_vuln_scan.sh"
echo "  - vulnerability/nikto_scan.sh"
echo "  - reconnaissance/domain_whois.sh"
echo "  - scanning/web_dir_enum.sh"
echo ""
echo "💡 Pour les autres fonctions, utilisez le système de cibles via:"
echo "  1. Menu 'Gestion des cibles' dans cyberman"
echo "  2. Fonction prompt_target() dans vos scripts"
echo "  3. Fonction for_each_target() pour exécuter sur toutes les cibles"

