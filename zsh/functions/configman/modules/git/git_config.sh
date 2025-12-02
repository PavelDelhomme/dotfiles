#!/bin/bash

################################################################################
# Configuration Git initiale
# À utiliser AVANT de commit/push dans dotfiles
# Charge les valeurs depuis .env ou demande à l'utilisateur
################################################################################

DOTFILES_DIR="$HOME/dotfiles"

# Charger .env si disponible
if [ -f "$DOTFILES_DIR/.env" ]; then
    source "$DOTFILES_DIR/.env"
fi

# Demander les valeurs si non définies dans .env
if [ -z "$GIT_USER_NAME" ]; then
    printf "Nom Git (obligatoire): "
    read -r GIT_USER_NAME
    if [ -z "$GIT_USER_NAME" ]; then
        echo "Erreur: Le nom Git est obligatoire"
        exit 1
    fi
fi

if [ -z "$GIT_USER_EMAIL" ]; then
    printf "Email Git (obligatoire): "
    read -r GIT_USER_EMAIL
    if [ -z "$GIT_USER_EMAIL" ]; then
        echo "Erreur: L'email Git est obligatoire"
        exit 1
    fi
    if [[ ! "$GIT_USER_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Erreur: Format d'email invalide"
        exit 1
    fi
fi

echo "Configuration Git"
echo "================="

# Configuration globale
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# Configuration optionnelle recommandée
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global color.ui auto

echo ""
echo "✓ Configuration Git appliquée:"
echo "  Nom: $(git config --global user.name)"
echo "  Email: $(git config --global user.email)"
echo ""
echo "Vous pouvez maintenant:"
echo "  cd ~/dotfiles"
echo "  git add ."
echo "  git commit -m 'Initial dotfiles setup'"
echo "  git push origin main"
