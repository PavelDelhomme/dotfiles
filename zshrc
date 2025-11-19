# =============================================================================
# DOTFILES - Configuration Shell
# =============================================================================
# Ce fichier détecte le shell actif et source la configuration appropriée
# Usage: Symlink ~/.zshrc -> ~/dotfiles/zshrc
# =============================================================================

# Détection du shell
if [ -n "$ZSH_VERSION" ]; then
    # Configuration ZSH
    if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
        source "$HOME/dotfiles/zsh/zshrc_custom"
    else
        echo "⚠️  Fichier $HOME/dotfiles/zsh/zshrc_custom introuvable."
    fi
elif [ -n "$FISH_VERSION" ]; then
    # Configuration Fish (ce fichier est normalement dans .config/fish/config.fish)
    if [ -f "$HOME/dotfiles/fish/config_custom.fish" ]; then
        source "$HOME/dotfiles/fish/config_custom.fish"
    else
        echo "⚠️  Fichier $HOME/dotfiles/fish/config_custom.fish introuvable."
    fi
fi
