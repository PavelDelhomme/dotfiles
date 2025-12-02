#!/bin/bash

################################################################################
# Permissions Manager - Gestion des permissions de fichiers
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'fileman permissions'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Gestionnaire de Permissions"

echo ""
echo "Options disponibles:"
echo "1. Changer les permissions d'un fichier/répertoire"
echo "2. Afficher les permissions actuelles"
echo "3. Appliquer des permissions par défaut (fichier/répertoire)"
echo "4. Rechercher des fichiers avec permissions spécifiques"
echo ""
printf "Choix [1-4]: "
read -r choice

case "$choice" in
    1)
        log_info "Changement de permissions..."
        printf "Fichier/répertoire: "
        read -r target_path
        
        if [ ! -e "$target_path" ]; then
            log_error "Fichier/répertoire introuvable: $target_path"
            return 1 2>/dev/null || exit 1
        fi
        
        echo "Mode de permissions:"
        echo "1. 755 (rwxr-xr-x) - Exécutable"
        echo "2. 644 (rw-r--r--) - Fichier standard"
        echo "3. 600 (rw-------) - Privé"
        echo "4. 700 (rwx------) - Privé exécutable"
        echo "5. Personnalisé (ex: 755)"
        printf "Choix [1-5]: "
        read -r mode_choice
        
        case "$mode_choice" in
            1) mode="755" ;;
            2) mode="644" ;;
            3) mode="600" ;;
            4) mode="700" ;;
            5)
                printf "Mode (ex: 755): "
                read -r mode
                ;;
            *)
                log_error "Choix invalide"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        
        chmod "$mode" "$target_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Permissions changées: $mode"
        else
            log_error "✗ Erreur lors du changement de permissions"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    2)
        log_info "Affichage des permissions..."
        printf "Fichier/répertoire: "
        read -r target_path
        
        if [ ! -e "$target_path" ]; then
            log_error "Fichier/répertoire introuvable: $target_path"
            return 1 2>/dev/null || exit 1
        fi
        
        echo ""
        ls -l "$target_path"
        echo ""
        log_info "Permissions: $(stat -c '%a' "$target_path" 2>/dev/null || stat -f '%A' "$target_path" 2>/dev/null)"
        ;;
    3)
        log_info "Application de permissions par défaut..."
        printf "Fichier/répertoire: "
        read -r target_path
        
        if [ ! -e "$target_path" ]; then
            log_error "Fichier/répertoire introuvable: $target_path"
            return 1 2>/dev/null || exit 1
        fi
        
        if [ -d "$target_path" ]; then
            log_info "Application permissions répertoire (755)..."
            chmod 755 "$target_path"
            mode="755"
        else
            log_info "Application permissions fichier (644)..."
            chmod 644 "$target_path"
            mode="644"
        fi
        
        if [ $? -eq 0 ]; then
            log_info "✓ Permissions appliquées: $mode"
        else
            log_error "✗ Erreur lors de l'application des permissions"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    4)
        log_info "Recherche de fichiers avec permissions spécifiques..."
        printf "Mode de permissions (ex: 777, 755): "
        read -r search_mode
        printf "Répertoire de recherche [défaut: .]: "
        read -r search_dir
        search_dir="${search_dir:-.}"
        
        if [ ! -d "$search_dir" ]; then
            log_error "Répertoire introuvable: $search_dir"
            return 1 2>/dev/null || exit 1
        fi
        
        log_info "Recherche de fichiers avec permissions $search_mode..."
        find "$search_dir" -type f -perm "$search_mode" -exec ls -lh {} \; 2>/dev/null | head -20
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Opération terminée!"

