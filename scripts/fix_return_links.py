#!/usr/bin/env python3
"""
Script pour corriger tous les liens "Retour en haut" dans README.md
"""

import re

def github_anchor(text):
    """Génère une ancre GitHub à partir d'un titre"""
    text = text.lower()
    text = text.replace(' ', '-')
    text = re.sub(r'[^a-z0-9\-]', '', text)
    text = re.sub(r'-+', '-', text)
    text = text.strip('-')
    return text

def fix_return_links(filepath):
    """Corrige tous les liens Retour en haut dans README.md"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Ancre pour le titre principal
    main_title_anchor = github_anchor("Dotfiles - PavelDelhomme")
    # Ancre pour la table des matières
    toc_anchor = github_anchor("📑 Table des matières")
    
    # Remplacer tous les liens "Retour en haut" qui pointent vers des ancres incorrectes
    # Pattern: [🔝 Retour en haut](#ancor)
    patterns = [
        (r'\[🔝 Retour en haut\]\(#retour-en-haut\)', f'[🔝 Retour en haut](#{main_title_anchor})'),
        (r'\[🔝 Retour en haut\]\(#dotfiles---paveldelhomme\)', f'[🔝 Retour en haut](#{main_title_anchor})'),
        (r'\[🔝 Retour en haut\]\(#[^\)]+\)', f'[🔝 Retour en haut](#{main_title_anchor})'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # Sauvegarder
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Liens 'Retour en haut' corrigés dans {filepath}")
    print(f"   Tous pointent maintenant vers: #{main_title_anchor}")

if __name__ == '__main__':
    fix_return_links('README.md')

