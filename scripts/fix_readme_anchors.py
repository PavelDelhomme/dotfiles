#!/usr/bin/env python3
"""
Script pour corriger les ancres GitHub dans README.md
GitHub génère les ancres en :
- Convertissant en minuscules
- Remplaçant les espaces par des tirets
- Supprimant les caractères spéciaux (accents, emojis, guillemets, etc.)
"""

import re
import sys

def github_anchor(text):
    """Génère une ancre GitHub à partir d'un titre (règles GitHub)"""
    # Convertir en minuscules
    text = text.lower()
    # Remplacer les espaces par des tirets
    text = text.replace(' ', '-')
    # Supprimer les emojis et caractères spéciaux (garder seulement lettres, chiffres, tirets)
    text = re.sub(r'[^a-z0-9\-]', '', text)
    # Supprimer les tirets multiples
    text = re.sub(r'-+', '-', text)
    # Supprimer les tirets en début/fin
    text = text.strip('-')
    return text

def normalize_text(text):
    """Normalise un texte pour comparaison (enlève emojis, caractères spéciaux)"""
    text = text.lower()
    # Enlever emojis et caractères spéciaux, garder seulement lettres et chiffres
    text = re.sub(r'[^a-z0-9\s]', '', text)
    # Normaliser les espaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def fix_readme_anchors(filepath):
    """Corrige toutes les ancres dans README.md"""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Étape 1: Extraire tous les titres et créer un mapping
    headings_map = {}
    for i, line in enumerate(lines):
        if line.startswith('## '):
            heading = line[3:].strip()
            anchor = github_anchor(heading)
            headings_map[heading] = anchor
        elif line.startswith('### '):
            heading = line[4:].strip()
            anchor = github_anchor(heading)
            headings_map[heading] = anchor
    
    # Étape 2: Reconstruire le contenu en corrigeant les liens
    new_lines = []
    for line in lines:
        # Si c'est un lien dans la table des matières [texte](#ancor)
        if re.search(r'\[([^\]]+)\]\(#([^\)]+)\)', line):
            def replace_link(match):
                link_text = match.group(1)
                old_anchor = match.group(2)
                
                # Normaliser le texte du lien pour comparaison
                link_normalized = normalize_text(link_text)
                
                # Chercher le titre correspondant dans le mapping
                best_match = None
                best_score = 0
                
                for heading, correct_anchor in headings_map.items():
                    heading_normalized = normalize_text(heading)
                    
                    # Score de correspondance
                    score = 0
                    
                    # Correspondance exacte
                    if heading_normalized == link_normalized:
                        score = 100
                    # Le texte du lien est dans le titre
                    elif link_normalized in heading_normalized:
                        score = len(link_normalized) / len(heading_normalized) * 80
                    # Le titre est dans le texte du lien
                    elif heading_normalized in link_normalized:
                        score = len(heading_normalized) / len(link_normalized) * 80
                    # Correspondance partielle (mots communs)
                    else:
                        link_words = set(link_normalized.split())
                        heading_words = set(heading_normalized.split())
                        common_words = link_words & heading_words
                        if common_words:
                            score = len(common_words) / max(len(link_words), len(heading_words)) * 60
                    
                    if score > best_score:
                        best_score = score
                        best_match = (heading, correct_anchor)
                
                # Si on a trouvé une bonne correspondance (score > 50)
                if best_match and best_score > 50:
                    return f"[{link_text}](#{best_match[1]})"
                
                # Sinon, générer l'ancre depuis le texte du lien
                new_anchor = github_anchor(link_text)
                return f"[{link_text}](#{new_anchor})"
            
            line = re.sub(r'\[([^\]]+)\]\(#([^\)]+)\)', replace_link, line)
        
        new_lines.append(line)
    
    # Sauvegarder
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print(f"✅ {len(headings_map)} titres trouvés, ancres corrigées dans {filepath}")
    return len(headings_map)

if __name__ == '__main__':
    fix_readme_anchors('README.md')
