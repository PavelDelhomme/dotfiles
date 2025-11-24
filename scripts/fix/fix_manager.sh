#!/bin/bash

################################################################################
# Fix Manager - Système de correction automatique des problèmes détectés
# Usage: bash scripts/fix/fix_manager.sh [fix_name]
################################################################################

set +e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

################################################################################
# DÉFINITION DES FIXES DISPONIBLES
################################################################################

declare -A FIXES
declare -A FIX_DESCRIPTIONS
declare -A FIX_SCRIPTS

# Fix: Rendre les scripts exécutables
FIXES["exec"]="Rendre tous les scripts non-exécutables exécutables"
FIX_DESCRIPTIONS["exec"]="Ajoute les permissions d'exécution à tous les scripts .sh du projet"
FIX_SCRIPTS["exec"]="fix_exec_scripts"

# Fix: Timer auto-sync
FIXES["timer-auto-sync"]="Configurer le timer auto-sync Git"
FIX_DESCRIPTIONS["timer-auto-sync"]="Installe et active le timer systemd pour la synchronisation automatique Git"
FIX_SCRIPTS["timer-auto-sync"]="fix_timer_auto_sync"

# Fix: Symlink .gitconfig
FIXES["symlink-gitconfig"]="Créer le symlink .gitconfig"
FIX_DESCRIPTIONS["symlink-gitconfig"]="Crée un symlink de .gitconfig vers dotfiles"
FIX_SCRIPTS["symlink-gitconfig"]="fix_symlink_gitconfig"

################################################################################
# FONCTIONS DE FIX
################################################################################

fix_exec_scripts() {
    log_section "Fix: Rendre les scripts exécutables"
    
    # S'assurer que DOTFILES_DIR est défini
    # Si DOTFILES_DIR contient déjà "scripts", ne pas l'ajouter deux fois
    local dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
    
    # Nettoyer le chemin pour éviter les doubles "scripts"
    dotfiles_dir="${dotfiles_dir%/scripts}"
    dotfiles_dir="${dotfiles_dir%/}"
    
    # Vérifier que le répertoire existe
    local scripts_dir="$dotfiles_dir/scripts"
    if [ ! -d "$scripts_dir" ]; then
        log_error "Répertoire scripts non trouvé: $scripts_dir"
        log_info "DOTFILES_DIR actuel: ${DOTFILES_DIR:-non défini}"
        log_info "dotfiles_dir calculé: $dotfiles_dir"
        return 1
    fi
    
    local count=0
    local fixed=0
    local errors=0
    
    # Trouver tous les scripts .sh non-exécutables
    # Utiliser find avec ! -perm pour trouver directement les fichiers sans permission d'exécution
    local non_exec_scripts
    non_exec_scripts=$(find "$scripts_dir" -type f -name "*.sh" ! -perm -111 2>/dev/null)
    
    if [ -n "$non_exec_scripts" ]; then
        # Traiter chaque script trouvé
        while IFS= read -r script; do
            if [ -f "$script" ]; then
                ((count++))
                if chmod +x "$script" 2>/dev/null; then
                    log_info "✓ Rendu exécutable: $script"
                    ((fixed++))
                else
                    log_error "✗ Erreur lors du chmod: $script"
                    ((errors++))
                fi
            fi
        done <<< "$non_exec_scripts"
    fi
    
    # Fallback: utiliser l'approche alternative si find -perm ne trouve rien
    if [ $count -eq 0 ]; then
        # Utiliser un tableau pour gérer correctement les espaces dans les noms
        local scripts_array
        mapfile -t scripts_array < <(find "$scripts_dir" -type f -name "*.sh" 2>/dev/null | sort)
        
        for script in "${scripts_array[@]}"; do
            # Vérifier si le fichier existe et n'a pas la permission d'exécution
            if [ -f "$script" ] && ! test -x "$script"; then
                ((count++))
                if chmod +x "$script" 2>/dev/null; then
                    log_info "✓ Rendu exécutable: $script"
                    ((fixed++))
                else
                    log_error "✗ Erreur lors du chmod: $script"
                    ((errors++))
                fi
            fi
        done
    fi
    
    # Vérifier aussi les scripts de migration à la racine
    for script in "$scripts_dir/migrate_shell.sh" "$scripts_dir/migrate_existing_user.sh"; do
        if [ -f "$script" ] && ! test -x "$script"; then
            ((count++))
            if chmod +x "$script" 2>/dev/null; then
                log_info "✓ Rendu exécutable: $script"
                ((fixed++))
            else
                log_error "✗ Erreur lors du chmod: $script"
                ((errors++))
            fi
        fi
    done
    
    if [ $count -eq 0 ]; then
        log_info "✓ Tous les scripts sont déjà exécutables"
    else
        if [ $errors -gt 0 ]; then
            log_warn "⚠️ $fixed/$count scripts rendus exécutables ($errors erreurs)"
        else
            log_info "✓ $fixed/$count scripts rendus exécutables"
        fi
    fi
}

fix_timer_auto_sync() {
    log_section "Fix: Configuration timer auto-sync"
    
    if [ -f "$DOTFILES_DIR/scripts/sync/install_auto_sync.sh" ]; then
        log_info "Installation du timer auto-sync..."
        bash "$DOTFILES_DIR/scripts/sync/install_auto_sync.sh"
    else
        log_error "Script install_auto_sync.sh non trouvé"
        return 1
    fi
}

fix_symlink_gitconfig() {
    log_section "Fix: Création symlink .gitconfig"
    
    local gitconfig_source="$DOTFILES_DIR/.gitconfig"
    local gitconfig_target="$HOME/.gitconfig"
    
    # Vérifier si le fichier source existe
    if [ ! -f "$gitconfig_source" ]; then
        log_warn "Fichier source non trouvé: $gitconfig_source"
        log_info "Création d'un fichier .gitconfig vide..."
        touch "$gitconfig_source"
    fi
    
    # Backup si .gitconfig existe déjà
    if [ -f "$gitconfig_target" ] && [ ! -L "$gitconfig_target" ]; then
        local backup_file="${gitconfig_target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Sauvegarde de l'ancien .gitconfig: $backup_file"
        cp "$gitconfig_target" "$backup_file"
    fi
    
    # Supprimer l'ancien fichier/symlink
    if [ -e "$gitconfig_target" ]; then
        rm -f "$gitconfig_target"
    fi
    
    # Créer le symlink
    if ln -s "$gitconfig_source" "$gitconfig_target" 2>/dev/null; then
        log_info "✓ Symlink .gitconfig créé: $gitconfig_target -> $gitconfig_source"
    else
        log_error "✗ Erreur lors de la création du symlink"
        return 1
    fi
}

################################################################################
# DÉTECTION AUTOMATIQUE DES PROBLÈMES
################################################################################

detect_fixes_needed() {
    local fixes_needed=()
    
    # Détecter scripts non-exécutables
    local non_exec_count=$(find "$DOTFILES_DIR/scripts" -type f -name "*.sh" ! -executable 2>/dev/null | wc -l)
    if [ "$non_exec_count" -gt 0 ]; then
        fixes_needed+=("exec")
    fi
    
    # Détecter timer auto-sync non configuré
    if ! systemctl --user is-enabled dotfiles-sync.timer &>/dev/null 2>&1; then
        fixes_needed+=("timer-auto-sync")
    fi
    
    # Détecter .gitconfig non symlink
    if [ ! -L "$HOME/.gitconfig" ] || [[ $(readlink "$HOME/.gitconfig") != *"dotfiles"* ]]; then
        fixes_needed+=("symlink-gitconfig")
    fi
    
    echo "${fixes_needed[@]}"
}

################################################################################
# AFFICHAGE DE L'AIDE
################################################################################

show_fix_help() {
    echo ""
    log_section "Fix Manager - Corrections automatiques"
    echo ""
    echo "Usage:"
    echo "  make fix                    - Afficher les fixes disponibles"
    echo "  make fix=<nom>              - Appliquer un fix spécifique"
    echo "  make fix=all                 - Appliquer tous les fixes détectés"
    echo "  make fix=detect              - Détecter les problèmes et proposer les fixes"
    echo ""
    echo "Fixes disponibles:"
    for fix_name in "${!FIXES[@]}"; do
        echo -e "  ${CYAN}$fix_name${NC}"
        echo "    → ${FIX_DESCRIPTIONS[$fix_name]}"
    done
    echo ""
}

################################################################################
# FONCTION PRINCIPALE
################################################################################

main() {
    local fix_name="${1:-}"
    
    # Afficher l'aide si aucun argument
    if [ -z "$fix_name" ]; then
        show_fix_help
        
        # Détecter et proposer les fixes
        log_section "Détection automatique des problèmes"
        local fixes_needed=($(detect_fixes_needed))
        
        if [ ${#fixes_needed[@]} -eq 0 ]; then
            log_info "✅ Aucun problème détecté, tout est OK !"
        else
            echo ""
            log_warn "Problèmes détectés (${#fixes_needed[@]}):"
            for fix in "${fixes_needed[@]}"; do
                echo -e "  ${YELLOW}⚠️${NC} ${FIXES[$fix]}"
                echo "     → ${FIX_DESCRIPTIONS[$fix]}"
            done
            echo ""
            echo "Pour appliquer tous les fixes détectés:"
            echo "  make fix=all"
            echo ""
            echo "Pour appliquer un fix spécifique:"
            echo "  make fix=<nom-du-fix>"
        fi
        return 0
    fi
    
    # Mode "detect"
    if [ "$fix_name" = "detect" ]; then
        log_section "Détection des problèmes"
        local fixes_needed=($(detect_fixes_needed))
        
        if [ ${#fixes_needed[@]} -eq 0 ]; then
            log_info "✅ Aucun problème détecté"
        else
            echo ""
            log_warn "Problèmes détectés (${#fixes_needed[@]}):"
            for fix in "${fixes_needed[@]}"; do
                echo -e "  ${YELLOW}⚠️${NC} ${FIXES[$fix]}"
            done
        fi
        return 0
    fi
    
    # Mode "all" - Appliquer tous les fixes détectés
    if [ "$fix_name" = "all" ]; then
        log_section "Application de tous les fixes détectés"
        local fixes_needed=($(detect_fixes_needed))
        
        if [ ${#fixes_needed[@]} -eq 0 ]; then
            log_info "✅ Aucun fix nécessaire"
            return 0
        fi
        
        echo ""
        log_warn "Fixes à appliquer (${#fixes_needed[@]}):"
        for fix in "${fixes_needed[@]}"; do
            echo "  - ${FIXES[$fix]}"
        done
        echo ""
        
        printf "Appliquer tous ces fixes? (o/n) [défaut: n]: "
        read -r confirm
        confirm=${confirm:-n}
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            log_info "Opération annulée"
            return 0
        fi
        
        echo ""
        for fix in "${fixes_needed[@]}"; do
            local fix_func="${FIX_SCRIPTS[$fix]}"
            if [ -n "$fix_func" ] && type "$fix_func" &>/dev/null; then
                log_section "Application: ${FIXES[$fix]}"
                "$fix_func"
                echo ""
            else
                log_error "Fonction de fix non trouvée: $fix_func"
            fi
        done
        
        log_info "✅ Tous les fixes ont été appliqués"
        return 0
    fi
    
    # Mode fix spécifique
    if [ -z "${FIXES[$fix_name]}" ]; then
        log_error "Fix inconnu: $fix_name"
        echo ""
        show_fix_help
        return 1
    fi
    
    # Demander confirmation
    log_section "Fix: ${FIXES[$fix_name]}"
    echo ""
    echo "Description: ${FIX_DESCRIPTIONS[$fix_name]}"
    echo ""
    printf "Appliquer ce fix? (o/n) [défaut: n]: "
    read -r confirm
    confirm=${confirm:-n}
    
    if [[ ! "$confirm" =~ ^[oO]$ ]]; then
        log_info "Opération annulée"
        return 0
    fi
    
    echo ""
    local fix_func="${FIX_SCRIPTS[$fix_name]}"
    if [ -n "$fix_func" ] && type "$fix_func" &>/dev/null; then
        "$fix_func"
        log_info "✅ Fix appliqué avec succès"
    else
        log_error "Fonction de fix non trouvée: $fix_func"
        return 1
    fi
}

# Exécuter la fonction principale
main "$@"

