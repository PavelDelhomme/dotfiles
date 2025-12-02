#!/bin/bash

################################################################################
# Search Manager - Recherche de fichiers
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'fileman search'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Gestionnaire de Recherche"

echo ""
echo "Options disponibles:"
echo "1. Rechercher un fichier par nom"
echo "2. Rechercher un fichier par contenu"
echo "3. Rechercher des fichiers par taille"
echo "4. Rechercher des fichiers par date de modification"
echo ""
printf "Choix [1-4]: "
read -r choice

case "$choice" in
    1)
        log_info "Recherche de fichier par nom..."
        printf "Nom du fichier (ou pattern): "
        read -r filename
        printf "Répertoire de recherche [défaut: .]: "
        read -r search_dir
        search_dir="${search_dir:-.}"
        
        if [ ! -d "$search_dir" ]; then
            log_error "Répertoire introuvable: $search_dir"
            return 1 2>/dev/null || exit 1
        fi
        
        log_info "Recherche en cours..."
        find "$search_dir" -name "$filename" -type f 2>/dev/null | head -20
        ;;
    2)
        log_info "Recherche de fichier par contenu..."
        printf "Texte à rechercher: "
        read -r search_text
        printf "Répertoire de recherche [défaut: .]: "
        read -r search_dir
        search_dir="${search_dir:-.}"
        
        if [ ! -d "$search_dir" ]; then
            log_error "Répertoire introuvable: $search_dir"
            return 1 2>/dev/null || exit 1
        fi
        
        log_info "Recherche en cours..."
        grep -r -l "$search_text" "$search_dir" 2>/dev/null | head -20
        ;;
    3)
        log_info "Recherche de fichiers par taille..."
        echo "Taille minimale:"
        echo "1. 1MB"
        echo "2. 10MB"
        echo "3. 100MB"
        echo "4. 1GB"
        echo "5. Personnalisée"
        printf "Choix [1-5]: "
        read -r size_choice
        
        case "$size_choice" in
            1) size="1M" ;;
            2) size="10M" ;;
            3) size="100M" ;;
            4) size="1G" ;;
            5)
                printf "Taille (ex: 50M, 2G): "
                read -r size
                ;;
            *)
                log_error "Choix invalide"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        
        printf "Répertoire de recherche [défaut: .]: "
        read -r search_dir
        search_dir="${search_dir:-.}"
        
        if [ ! -d "$search_dir" ]; then
            log_error "Répertoire introuvable: $search_dir"
            return 1 2>/dev/null || exit 1
        fi
        
        log_info "Recherche de fichiers > $size..."
        find "$search_dir" -type f -size +$size -exec ls -lh {} \; 2>/dev/null | awk '{print $9 " (" $5 ")"}' | head -20
        ;;
    4)
        log_info "Recherche de fichiers par date..."
        echo "Fichiers modifiés:"
        echo "1. Aujourd'hui"
        echo "2. Cette semaine"
        echo "3. Ce mois"
        echo "4. Personnalisé (jours)"
        printf "Choix [1-4]: "
        read -r date_choice
        
        case "$date_choice" in
            1) days=1 ;;
            2) days=7 ;;
            3) days=30 ;;
            4)
                printf "Nombre de jours: "
                read -r days
                ;;
            *)
                log_error "Choix invalide"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        
        printf "Répertoire de recherche [défaut: .]: "
        read -r search_dir
        search_dir="${search_dir:-.}"
        
        if [ ! -d "$search_dir" ]; then
            log_error "Répertoire introuvable: $search_dir"
            return 1 2>/dev/null || exit 1
        fi
        
        log_info "Recherche de fichiers modifiés dans les $days derniers jours..."
        find "$search_dir" -type f -mtime -$days -exec ls -lh {} \; 2>/dev/null | awk '{print $9 " (" $6 " " $7 " " $8 ")"}' | head -20
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Recherche terminée!"

