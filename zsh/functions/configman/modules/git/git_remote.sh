#!/bin/bash

echo "🔧 Fix Git Push - Dotfiles"
echo "=========================="
echo ""

cd ~/dotfiles

echo "État actuel:"
# Afficher la branche uniquement si on est dans un dépôt Git
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Branche: $(git branch --show-current)"
fi
echo "Remote: $(git remote get-url origin)"
echo ""

read -p "Changer remote en SSH? (o/n): " use_ssh

if [[ "$use_ssh" =~ ^[oO]$ ]]; then
    echo "Changement remote vers SSH..."
    git remote set-url origin git@github.com:PavelDelhomme/dotfiles.git
    echo "✓ Remote changé"
fi

echo ""
read -p "Renommer branche en 'main'? (o/n): " rename_branch

if [[ "$rename_branch" =~ ^[oO]$ ]]; then
    echo "Renommage master → main..."
    git branch -M main
    echo "✓ Branche renommée"

    echo "Push vers origin main..."
    git push -u origin main
else
    echo "Push vers origin master..."
    git push -u origin master
fi

echo ""
echo "✓ Push effectué!"
echo ""
echo "Vérification:"
if git rev-parse --git-dir > /dev/null 2>&1; then
    git remote -v
    git branch
fi
