#!/bin/bash

################################################################################
# Backup Manager - Gestion des sauvegardes
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'fileman backup'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

log_section "Gestionnaire de Sauvegardes"

echo ""
echo "Options disponibles:"
echo "1. Créer une sauvegarde"
echo "2. Lister les sauvegardes"
echo "3. Restaurer une sauvegarde"
echo "4. Supprimer une sauvegarde"
echo ""
printf "Choix [1-4]: "
read -r choice

case "$choice" in
    1)
        log_info "Création d'une sauvegarde..."
        printf "Répertoire/fichier à sauvegarder: "
        read -r source_path
        
        if [ ! -e "$source_path" ]; then
            log_error "Source introuvable: $source_path"
            return 1 2>/dev/null || exit 1
        fi
        
        # Créer le répertoire de backup si nécessaire
        mkdir -p "$BACKUP_DIR"
        
        # Nom de la sauvegarde
        backup_name="backup_$(basename "$source_path")_$(date +%Y%m%d_%H%M%S)"
        backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
        
        log_info "Création de la sauvegarde: $backup_file"
        tar -czf "$backup_file" "$source_path"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Sauvegarde créée: $backup_file"
            log_info "Taille: $(du -h "$backup_file" | cut -f1)"
        else
            log_error "✗ Erreur lors de la création de la sauvegarde"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    2)
        log_info "Liste des sauvegardes..."
        
        if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
            log_warn "Aucune sauvegarde trouvée dans $BACKUP_DIR"
            return 0 2>/dev/null || exit 0
        fi
        
        echo ""
        echo "Sauvegardes disponibles:"
        ls -lh "$BACKUP_DIR" | tail -n +2 | awk '{print "  " $9 " (" $5 ")"}'
        echo ""
        ;;
    3)
        log_info "Restauration d'une sauvegarde..."
        
        if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
            log_warn "Aucune sauvegarde trouvée dans $BACKUP_DIR"
            return 0 2>/dev/null || exit 0
        fi
        
        echo ""
        echo "Sauvegardes disponibles:"
        ls -1 "$BACKUP_DIR" | nl
        echo ""
        printf "Numéro de la sauvegarde à restaurer: "
        read -r backup_num
        
        backup_file=$(ls -1 "$BACKUP_DIR" | sed -n "${backup_num}p")
        
        if [ -z "$backup_file" ]; then
            log_error "Sauvegarde introuvable"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Répertoire de destination: "
        read -r dest_dir
        
        if [ ! -d "$dest_dir" ]; then
            log_info "Création du répertoire de destination..."
            mkdir -p "$dest_dir"
        fi
        
        log_info "Restauration de: $backup_file"
        tar -xzf "$BACKUP_DIR/$backup_file" -C "$dest_dir"
        
        if [ $? -eq 0 ]; then
            log_info "✓ Sauvegarde restaurée dans: $dest_dir"
        else
            log_error "✗ Erreur lors de la restauration"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    4)
        log_info "Suppression d'une sauvegarde..."
        
        if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
            log_warn "Aucune sauvegarde trouvée dans $BACKUP_DIR"
            return 0 2>/dev/null || exit 0
        fi
        
        echo ""
        echo "Sauvegardes disponibles:"
        ls -1 "$BACKUP_DIR" | nl
        echo ""
        printf "Numéro de la sauvegarde à supprimer: "
        read -r backup_num
        
        backup_file=$(ls -1 "$BACKUP_DIR" | sed -n "${backup_num}p")
        
        if [ -z "$backup_file" ]; then
            log_error "Sauvegarde introuvable"
            return 1 2>/dev/null || exit 1
        fi
        
        printf "Confirmer la suppression de '$backup_file'? (o/n): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[oO]$ ]]; then
            rm "$BACKUP_DIR/$backup_file"
            log_info "✓ Sauvegarde supprimée"
        else
            log_info "Suppression annulée"
        fi
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Opération terminée!"

