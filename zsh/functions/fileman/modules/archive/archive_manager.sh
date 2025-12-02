#!/bin/bash

################################################################################
# Archive Manager - Gestion des archives (création et extraction)
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'fileman archive'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Gestionnaire d'Archives"

echo ""
echo "Options disponibles:"
echo "1. Extraire une archive (extract)"
echo "2. Créer une archive (tar, zip, etc.)"
echo "3. Lister le contenu d'une archive"
echo "4. Vérifier l'intégrité d'une archive"
echo ""
printf "Choix [1-4]: "
read -r choice

case "$choice" in
    1)
        log_info "Extraction d'archive..."
        printf "Chemin de l'archive: "
        read -r archive_path
        
        if [ ! -f "$archive_path" ]; then
            log_error "Archive introuvable: $archive_path"
            return 1 2>/dev/null || exit 1
        fi
        
        # Détecter le type d'archive et extraire
        case "$archive_path" in
            *.tar.gz|*.tgz)
                log_info "Extraction archive tar.gz..."
                tar -xzf "$archive_path"
                ;;
            *.tar.bz2|*.tbz2)
                log_info "Extraction archive tar.bz2..."
                tar -xjf "$archive_path"
                ;;
            *.tar.xz|*.txz)
                log_info "Extraction archive tar.xz..."
                tar -xJf "$archive_path"
                ;;
            *.tar)
                log_info "Extraction archive tar..."
                tar -xf "$archive_path"
                ;;
            *.zip)
                log_info "Extraction archive zip..."
                if command -v unzip >/dev/null 2>&1; then
                    unzip "$archive_path"
                else
                    log_error "unzip non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.rar)
                log_info "Extraction archive rar..."
                if command -v unrar >/dev/null 2>&1; then
                    unrar x "$archive_path"
                else
                    log_error "unrar non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.7z)
                log_info "Extraction archive 7z..."
                if command -v 7z >/dev/null 2>&1; then
                    7z x "$archive_path"
                else
                    log_error "7z non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.gz)
                log_info "Décompression fichier gz..."
                gunzip "$archive_path"
                ;;
            *.bz2)
                log_info "Décompression fichier bz2..."
                bunzip2 "$archive_path"
                ;;
            *.xz)
                log_info "Décompression fichier xz..."
                unxz "$archive_path"
                ;;
            *)
                log_error "Format d'archive non supporté: $archive_path"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        
        log_info "✓ Extraction terminée"
        ;;
    2)
        log_info "Création d'archive..."
        printf "Répertoire/fichier à archiver: "
        read -r source_path
        
        if [ ! -e "$source_path" ]; then
            log_error "Source introuvable: $source_path"
            return 1 2>/dev/null || exit 1
        fi
        
        echo "Format d'archive:"
        echo "1. tar.gz (recommandé)"
        echo "2. tar.bz2"
        echo "3. tar.xz"
        echo "4. zip"
        echo "5. tar"
        printf "Choix [1-5]: "
        read -r format_choice
        
        printf "Nom de l'archive (sans extension): "
        read -r archive_name
        
        case "$format_choice" in
            1)
                archive_file="${archive_name}.tar.gz"
                log_info "Création archive tar.gz..."
                tar -czf "$archive_file" "$source_path"
                ;;
            2)
                archive_file="${archive_name}.tar.bz2"
                log_info "Création archive tar.bz2..."
                tar -cjf "$archive_file" "$source_path"
                ;;
            3)
                archive_file="${archive_name}.tar.xz"
                log_info "Création archive tar.xz..."
                tar -cJf "$archive_file" "$source_path"
                ;;
            4)
                archive_file="${archive_name}.zip"
                log_info "Création archive zip..."
                if command -v zip >/dev/null 2>&1; then
                    zip -r "$archive_file" "$source_path"
                else
                    log_error "zip non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            5)
                archive_file="${archive_name}.tar"
                log_info "Création archive tar..."
                tar -cf "$archive_file" "$source_path"
                ;;
            *)
                log_error "Choix invalide"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        
        log_info "✓ Archive créée: $archive_file"
        ;;
    3)
        log_info "Liste du contenu d'une archive..."
        printf "Chemin de l'archive: "
        read -r archive_path
        
        if [ ! -f "$archive_path" ]; then
            log_error "Archive introuvable: $archive_path"
            return 1 2>/dev/null || exit 1
        fi
        
        case "$archive_path" in
            *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar)
                tar -tf "$archive_path" | less
                ;;
            *.zip)
                if command -v unzip >/dev/null 2>&1; then
                    unzip -l "$archive_path" | less
                else
                    log_error "unzip non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.rar)
                if command -v unrar >/dev/null 2>&1; then
                    unrar l "$archive_path" | less
                else
                    log_error "unrar non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.7z)
                if command -v 7z >/dev/null 2>&1; then
                    7z l "$archive_path" | less
                else
                    log_error "7z non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *)
                log_error "Format d'archive non supporté"
                return 1 2>/dev/null || exit 1
                ;;
        esac
        ;;
    4)
        log_info "Vérification de l'intégrité d'une archive..."
        printf "Chemin de l'archive: "
        read -r archive_path
        
        if [ ! -f "$archive_path" ]; then
            log_error "Archive introuvable: $archive_path"
            return 1 2>/dev/null || exit 1
        fi
        
        case "$archive_path" in
            *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar)
                log_info "Vérification archive tar..."
                if tar -tf "$archive_path" >/dev/null 2>&1; then
                    log_info "✓ Archive valide"
                else
                    log_error "✗ Archive corrompue"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *.zip)
                if command -v unzip >/dev/null 2>&1; then
                    log_info "Vérification archive zip..."
                    if unzip -t "$archive_path" >/dev/null 2>&1; then
                        log_info "✓ Archive valide"
                    else
                        log_error "✗ Archive corrompue"
                        return 1 2>/dev/null || exit 1
                    fi
                else
                    log_error "unzip non installé"
                    return 1 2>/dev/null || exit 1
                fi
                ;;
            *)
                log_warn "Vérification non disponible pour ce format"
                ;;
        esac
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Opération terminée!"

