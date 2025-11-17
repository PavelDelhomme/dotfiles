#!/bin/bash

################################################################################
# Configuration Git initiale - Pactivisme
# À utiliser AVANT de commit/push dans dotfiles
################################################################################

echo "Configuration Git pour Pactivisme"
echo "=================================="

# Configuration globale
git config --global user.name "Pactivisme"
git config --global user.email "dev@delhomme.ovh"

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
