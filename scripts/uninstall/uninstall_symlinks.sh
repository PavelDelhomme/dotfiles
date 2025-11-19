#!/bin/bash

################################################################################
# Désinstallation symlinks (retour aux fichiers originaux)
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation symlinks"

log_warn "⚠️  Cette opération va supprimer les symlinks et restaurer les fichiers originaux"
log_warn "⚠️  Symlinks concernés :"
echo "  - ~/.zshrc"
echo "  - ~/.gitconfig"
echo "  - ~/.ssh (optionnel)"
echo "  - Autres symlinks créés par create_symlinks.sh"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

# .zshrc
if [ -L "$HOME/.zshrc" ]; then
    LINK_TARGET=$(readlink "$HOME/.zshrc")
    log_info "Suppression symlink .zshrc (pointait vers: $LINK_TARGET)..."
    
    # Créer un .zshrc minimal si le symlink est supprimé
    rm -f "$HOME/.zshrc" && {
        cat > "$HOME/.zshrc" << 'EOF'
# ~/.zshrc - Fichier minimal après suppression du symlink dotfiles
# Ajoutez votre configuration ici
EOF
        log_info "✓ Symlink .zshrc supprimé, fichier minimal créé"
    } || log_warn "Impossible de supprimer symlink .zshrc"
else
    log_skip ".zshrc n'est pas un symlink"
fi

# .gitconfig
if [ -L "$HOME/.gitconfig" ]; then
    LINK_TARGET=$(readlink "$HOME/.gitconfig")
    log_info "Suppression symlink .gitconfig (pointait vers: $LINK_TARGET)..."
    
    rm -f "$HOME/.gitconfig" && {
        cat > "$HOME/.gitconfig" << 'EOF'
# ~/.gitconfig - Fichier minimal après suppression du symlink dotfiles
# Ajoutez votre configuration Git ici
EOF
        log_info "✓ Symlink .gitconfig supprimé, fichier minimal créé"
    } || log_warn "Impossible de supprimer symlink .gitconfig"
else
    log_skip ".gitconfig n'est pas un symlink"
fi

# .ssh (optionnel)
if [ -L "$HOME/.ssh" ]; then
    log_warn "⚠️  Supprimer le symlink .ssh?"
    printf "Supprimer symlink .ssh? (o/n): "
    read -r remove_ssh
    if [[ "$remove_ssh" =~ ^[oO]$ ]]; then
        LINK_TARGET=$(readlink "$HOME/.ssh")
        log_info "Suppression symlink .ssh (pointait vers: $LINK_TARGET)..."
        rm -f "$HOME/.ssh" && log_info "✓ Symlink .ssh supprimé" || log_warn "Impossible de supprimer symlink .ssh"
    fi
fi

# Autres symlinks possibles
log_info "Recherche d'autres symlinks vers dotfiles..."
find "$HOME" -maxdepth 1 -type l 2>/dev/null | while read -r link; do
    link_target=$(readlink "$link")
    if [[ "$link_target" == *"dotfiles"* ]]; then
        link_name=$(basename "$link")
        log_warn "⚠️  Symlink trouvé: ~/$link_name -> $link_target"
        printf "Supprimer ~/$link_name? (o/n): "
        read -r remove_link
        if [[ "$remove_link" =~ ^[oO]$ ]]; then
            rm -f "$link" && log_info "✓ Symlink ~/$link_name supprimé" || log_warn "Impossible de supprimer"
        fi
    fi
done

log_info "✅ Désinstallation symlinks terminée"

