#!/bin/bash

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'configman git-remote'
# Il ne doit JAMAIS être sourcé ou exécuté automatiquement au chargement de zshrc

# Vérifier si le script est sourcé (pas exécuté)
# Si sourcé, on retourne simplement sans erreur pour éviter de fermer le terminal
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Script sourcé, ne rien faire
    return 0 2>/dev/null || exit 0
fi

# Vérifier si on est dans un terminal interactif
if [ ! -t 0 ]; then
    echo "❌ Ce script nécessite un terminal interactif"
    return 1 2>/dev/null || exit 1
fi

echo "🔧 Fix Git Push - Dotfiles"
echo "=========================="
echo ""

cd ~/dotfiles

# Vérifier qu'on est dans un dépôt Git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Ce répertoire n'est pas un dépôt Git"
    return 1 2>/dev/null || exit 1
fi

echo "État actuel:"
echo "Branche: $(git branch --show-current)"
echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'Non configuré')"
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
    # Désactiver le pager pour git branch
    git --no-pager branch
fi
