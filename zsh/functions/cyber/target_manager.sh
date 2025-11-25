#!/bin/zsh
# =============================================================================
# TARGET MANAGER - Gestionnaire de cibles pour cyberman
# =============================================================================
# Description: Gère les cibles pour les scans et tests de sécurité
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Variable globale pour stocker les cibles
typeset -g -a CYBER_TARGETS=()

# DESC: Affiche les cibles actuellement configurées
# USAGE: show_targets
# EXAMPLE: show_targets
show_targets() {
    if [ ${#CYBER_TARGETS[@]} -eq 0 ]; then
        echo "⚠️  Aucune cible configurée"
        return 1
    fi
    
    echo "🎯 Cibles configurées (${#CYBER_TARGETS[@]}):"
    local i=1
    for target in "${CYBER_TARGETS[@]}"; do
        echo "  $i. $target"
        ((i++))
    done
    return 0
}

# DESC: Ajoute une ou plusieurs cibles à la liste
# USAGE: add_target <target1> [target2] [target3] ...
# EXAMPLE: add_target example.com
# EXAMPLE: add_target 192.168.1.1 192.168.1.2 example.com
add_target() {
    if [ $# -eq 0 ]; then
        echo "❌ Usage: add_target <target1> [target2] ..."
        echo "Exemple: add_target example.com"
        echo "Exemple: add_target 192.168.1.1 192.168.1.2 example.com"
        return 1
    fi
    
    local added=0
    for target in "$@"; do
        # Vérifier si la cible n'existe pas déjà
        if [[ ! " ${CYBER_TARGETS[@]} " =~ " ${target} " ]]; then
            CYBER_TARGETS+=("$target")
            echo "✅ Cible ajoutée: $target"
            ((added++))
        else
            echo "⚠️  Cible déjà présente: $target"
        fi
    done
    
    if [ $added -gt 0 ]; then
        echo "📋 Total: ${#CYBER_TARGETS[@]} cible(s)"
    fi
    return 0
}

# DESC: Supprime une cible de la liste par index ou par nom
# USAGE: remove_target <index|target>
# EXAMPLE: remove_target 1
# EXAMPLE: remove_target example.com
remove_target() {
    if [ $# -eq 0 ]; then
        echo "❌ Usage: remove_target <index|target>"
        echo "Exemple: remove_target 1"
        echo "Exemple: remove_target example.com"
        return 1
    fi
    
    local arg="$1"
    
    # Si c'est un nombre, supprimer par index
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
        local index=$((arg - 1))
        if [ $index -ge 0 ] && [ $index -lt ${#CYBER_TARGETS[@]} ]; then
            local removed="${CYBER_TARGETS[$index]}"
            CYBER_TARGETS=("${CYBER_TARGETS[@]:0:$index}" "${CYBER_TARGETS[@]:$((index+1))}")
            echo "✅ Cible supprimée: $removed"
            echo "📋 Total: ${#CYBER_TARGETS[@]} cible(s)"
            return 0
        else
            echo "❌ Index invalide: $arg"
            return 1
        fi
    else
        # Supprimer par nom
        local found=false
        local new_targets=()
        for target in "${CYBER_TARGETS[@]}"; do
            if [ "$target" != "$arg" ]; then
                new_targets+=("$target")
            else
                found=true
            fi
        done
        
        if [ "$found" = true ]; then
            CYBER_TARGETS=("${new_targets[@]}")
            echo "✅ Cible supprimée: $arg"
            echo "📋 Total: ${#CYBER_TARGETS[@]} cible(s)"
            return 0
        else
            echo "❌ Cible non trouvée: $arg"
            return 1
        fi
    fi
}

# DESC: Vide la liste des cibles
# USAGE: clear_targets
# EXAMPLE: clear_targets
clear_targets() {
    local count=${#CYBER_TARGETS[@]}
    CYBER_TARGETS=()
    echo "🗑️  Toutes les cibles ont été supprimées ($count cible(s))"
    return 0
}

# DESC: Obtient une cible par index (1-based) ou retourne la première si aucun index
# USAGE: get_target [index]
# EXAMPLE: get_target
# EXAMPLE: get_target 1
# EXAMPLE: get_target 2
get_target() {
    if [ ${#CYBER_TARGETS[@]} -eq 0 ]; then
        echo ""
        return 1
    fi
    
    local index=${1:-1}
    index=$((index - 1))
    
    if [ $index -ge 0 ] && [ $index -lt ${#CYBER_TARGETS[@]} ]; then
        echo "${CYBER_TARGETS[$index]}"
        return 0
    else
        echo ""
        return 1
    fi
}

# DESC: Obtient toutes les cibles
# USAGE: get_all_targets
# EXAMPLE: get_all_targets
get_all_targets() {
    echo "${CYBER_TARGETS[@]}"
    return 0
}

# DESC: Vérifie si des cibles sont configurées
# USAGE: has_targets
# EXAMPLE: has_targets
has_targets() {
    [ ${#CYBER_TARGETS[@]} -gt 0 ]
}

# DESC: Demande interactivement une cible si aucune n'est fournie
# USAGE: prompt_target [message]
# EXAMPLE: prompt_target "Entrez la cible: "
prompt_target() {
    local message="${1:-🎯 Entrez la cible (IP, domaine ou URL): }"
    
    # Si des cibles sont déjà configurées, proposer de les utiliser
    if has_targets; then
        echo ""
        show_targets
        echo ""
        echo "Options:"
        echo "  1-${#CYBER_TARGETS[@]}. Utiliser une cible existante"
        echo "  n. Nouvelle cible"
        echo ""
        printf "Choix: "
        read -r choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le ${#CYBER_TARGETS[@]} ]; then
            echo "${CYBER_TARGETS[$((choice-1))]}"
            return 0
        elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
            # Continuer pour demander une nouvelle cible
            :
        else
            echo "❌ Choix invalide"
            return 1
        fi
    fi
    
    # Demander une nouvelle cible
    printf "$message"
    read -r target
    
    if [ -z "$target" ]; then
        echo "❌ Cible vide"
        return 1
    fi
    
    # Ajouter automatiquement à la liste si elle n'existe pas
    if [[ ! " ${CYBER_TARGETS[@]} " =~ " ${target} " ]]; then
        CYBER_TARGETS+=("$target")
    fi
    
    echo "$target"
    return 0
}

# DESC: Exécute une fonction pour chaque cible configurée
# USAGE: for_each_target <function_name> [args...]
# EXAMPLE: for_each_target port_scan
# EXAMPLE: for_each_target nmap_vuln_scan --script vuln
for_each_target() {
    if [ $# -eq 0 ]; then
        echo "❌ Usage: for_each_target <function_name> [args...]"
        return 1
    fi
    
    if ! has_targets; then
        echo "❌ Aucune cible configurée. Utilisez 'add_target' d'abord."
        return 1
    fi
    
    local func_name="$1"
    shift
    local args="$@"
    
    echo "🔄 Exécution de '$func_name' sur ${#CYBER_TARGETS[@]} cible(s)..."
    echo ""
    
    local i=1
    for target in "${CYBER_TARGETS[@]}"; do
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🎯 Cible $i/${#CYBER_TARGETS[@]}: $target"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Exécuter la fonction avec la cible et les arguments supplémentaires
        if command -v "$func_name" >/dev/null 2>&1 || type "$func_name" >/dev/null 2>&1; then
            $func_name "$target" $args
        else
            echo "❌ Fonction '$func_name' non trouvée"
        fi
        
        echo ""
        ((i++))
    done
    
    echo "✅ Scan terminé pour toutes les cibles"
    return 0
}

