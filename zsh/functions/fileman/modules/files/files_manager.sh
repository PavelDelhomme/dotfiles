#!/bin/bash

################################################################################
# Files Manager - Opérations sur fichiers (copier, déplacer, supprimer)
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'fileman files'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Gestionnaire d'Opérations Fichiers"

echo ""
echo "Options disponibles:"
echo "1. Copier un fichier/répertoire"
echo "2. Déplacer un fichier/répertoire"
echo "3. Supprimer un fichier/répertoire"
echo "4. Renommer un fichier/répertoire"
echo "5. Créer un répertoire"
echo "6. Afficher les informations d'un fichier"
echo ""
printf "Choix [1-6]: "
read -r choice

case "$choice" in
    1)
        log_info "Copie d'un fichier/répertoire..."
        printf "Source: "
        read -r source_path
        
        if [ ! -e "$source_path" ]; then
            log_error "Source introuvable: $source_path"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Destination: "
        read -r dest_path
        
        log_info "Copie en cours..."
        cp -r "$source_path" "$dest_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Copie terminée: $source_path -> $dest_path"
        else
            log_error "✗ Erreur lors de la copie"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    2)
        log_info "Déplacement d'un fichier/répertoire..."
        printf "Source: "
        read -r source_path
        
        if [ ! -e "$source_path" ]; then
            log_error "Source introuvable: $source_path"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Destination: "
        read -r dest_path
        
        log_info "Déplacement en cours..."
        mv "$source_path" "$dest_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Déplacement terminé: $source_path -> $dest_path"
        else
            log_error "✗ Erreur lors du déplacement"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    3)
        log_info "Suppression d'un fichier/répertoire..."
        printf "Fichier/répertoire à supprimer: "
        read -r target_path
        
        if [ ! -e "$target_path" ]; then
            log_error "Fichier/répertoire introuvable: $target_path"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Confirmer la suppression de '$target_path'? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            if [ -d "$target_path" ]; then
                log_info "Suppression du répertoire..."
                rm -rf "$target_path"
            else
                log_info "Suppression du fichier..."
                rm "$target_path"
            fi
            
            if [ $? -eq 0 ]; then
                log_info "✓ Suppression terminée"
            else
                log_error "✗ Erreur lors de la suppression"
                return 1 2>/dev/null || exit 1
            fi
        else
            log_info "Suppression annulée"
        fi
        ;;
    4)
        log_info "Renommage d'un fichier/répertoire..."
        printf "Fichier/répertoire à renommer: "
        read -r old_path
        
        if [ ! -e "$old_path" ]; then
            log_error "Fichier/répertoire introuvable: $old_path"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Nouveau nom: "
        read -r new_name
        
        # Obtenir le répertoire parent
        dir_path=$(dirname "$old_path")
        new_path="$dir_path/$new_name"
        
        log_info "Renommage en cours..."
        mv "$old_path" "$new_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Renommage terminé: $old_path -> $new_path"
        else
            log_error "✗ Erreur lors du renommage"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    5)
        log_info "Création d'un répertoire..."
        printf "Chemin du répertoire: "
        read -r dir_path
        
        log_info "Création en cours..."
        mkdir -p "$dir_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Répertoire créé: $dir_path"
        else
            log_error "✗ Erreur lors de la création"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    6)
        log_info "Informations sur un fichier/répertoire..."
        printf "Fichier/répertoire: "
        read -r target_path
        
        if [ ! -e "$target_path" ]; then
            log_error "Fichier/répertoire introuvable: $target_path"
            return 1 2>/dev/null || exit 1
        fi
        
        echo ""
        echo "Informations:"
        ls -lh "$target_path"
        echo ""
        echo "Type: $(file "$target_path")"
        echo "Permissions: $(stat -c '%a' "$target_path" 2>/dev/null || stat -f '%A' "$target_path" 2>/dev/null)"
        echo "Propriétaire: $(stat -c '%U:%G' "$target_path" 2>/dev/null || stat -f '%Su:%Sg' "$target_path" 2>/dev/null)"
        echo "Taille: $(du -sh "$target_path" | cut -f1)"
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Opération terminée!"

