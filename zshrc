# =============================================================================
# DOTFILES - Configuration Shell
# =============================================================================
# Ce fichier détecte le shell actif et source la configuration appropriée
# Usage: Symlink ~/.zshrc -> ~/dotfiles/zshrc
# =============================================================================

# Détection du shell et chargement de la configuration appropriée
if [ -n "$ZSH_VERSION" ]; then
    # Configuration ZSH
    if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
        source "$HOME/dotfiles/zsh/zshrc_custom"
    else
        echo "⚠️  Fichier $HOME/dotfiles/zsh/zshrc_custom introuvable."
    fi
elif [ -n "$FISH_VERSION" ]; then
    # Configuration Fish (ce fichier est normalement dans .config/fish/config.fish)
    # Note: Fish ne peut pas source ce fichier directement, il doit être dans .config/fish/config.fish
    if [ -f "$HOME/dotfiles/fish/config_custom.fish" ]; then
        # Pour Fish, on affiche juste un message car le sourcing doit être fait dans config.fish
        echo "ℹ️  Configuration Fish disponible dans $HOME/dotfiles/fish/config_custom.fish"
    else
        echo "⚠️  Fichier $HOME/dotfiles/fish/config_custom.fish introuvable."
    fi
elif [ -n "$BASH_VERSION" ]; then
    # Configuration Bash (unifiée avec Zsh)
    # Charger les variables d'environnement communes
    if [ -f "$HOME/dotfiles/zsh/env.sh" ]; then
        # Source env.sh qui est compatible bash
        source "$HOME/dotfiles/zsh/env.sh"
    fi
    # Charger les alias si possible (bash compatible)
    if [ -f "$HOME/dotfiles/zsh/aliases.zsh" ]; then
        # Les alias simples devraient fonctionner
        source "$HOME/dotfiles/zsh/aliases.zsh" 2>/dev/null || true
    fi
    # Afficher un message
    echo "ℹ️  Configuration Bash chargée (mode unifié avec Zsh)"
fi
