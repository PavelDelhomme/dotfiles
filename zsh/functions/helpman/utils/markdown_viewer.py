#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Visualiseur Markdown simple avec support UTF-8 et couleurs basiques
Utilisé comme fallback si aucun autre outil n'est disponible
"""
import sys
import os
import re

def print_markdown_colored(file_path):
    """Affiche un fichier Markdown avec coloration basique et support UTF-8"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Codes ANSI pour les couleurs
        HEADER = '\033[1;36m'  # Cyan bold
        TITLE = '\033[1;33m'    # Yellow bold
        SUBTITLE = '\033[1;35m' # Magenta bold
        BOLD = '\033[1m'        # Bold
        CODE = '\033[0;32m'     # Green
        ITALIC = '\033[3m'      # Italic
        RESET = '\033[0m'       # Reset
        
        lines = content.split('\n')
        in_code = False
        in_list = False
        
        for line in lines:
            # Détection des blocs de code
            if line.strip().startswith('```'):
                in_code = not in_code
                print(f"{CODE}{line}{RESET}")
                continue
            
            if in_code:
                print(f"{CODE}{line}{RESET}")
                continue
            
            # Titres
            if line.startswith('# '):
                print(f"\n{HEADER}{line}{RESET}")
            elif line.startswith('## '):
                print(f"\n{TITLE}{line}{RESET}")
            elif line.startswith('### '):
                print(f"\n{SUBTITLE}{line}{RESET}")
            elif line.startswith('#### '):
                print(f"\n{BOLD}{line}{RESET}")
            # Listes
            elif line.strip().startswith('- ') or line.strip().startswith('* '):
                in_list = True
                # Remplacer les puces par des caractères Unicode
                line = re.sub(r'^(\s*)[-*] ', r'\1• ', line)
                # Gras dans les listes
                line = re.sub(r'\*\*(.*?)\*\*', f'{BOLD}\\1{RESET}', line)
                print(f"  {line}")
            # Code inline
            elif '`' in line:
                line = re.sub(r'`([^`]+)`', f'{CODE}\\1{RESET}', line)
                # Gras
                line = re.sub(r'\*\*(.*?)\*\*', f'{BOLD}\\1{RESET}', line)
                print(line)
            # Gras
            elif '**' in line:
                line = re.sub(r'\*\*(.*?)\*\*', f'{BOLD}\\1{RESET}', line)
                print(line)
            # Lignes vides
            elif line.strip() == '':
                if in_list:
                    in_list = False
                print()
            else:
                print(line)
                
    except UnicodeDecodeError:
        # Essayer avec latin-1 si UTF-8 échoue
        try:
            with open(file_path, 'r', encoding='latin-1') as f:
                print(f.read())
        except:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                print(f.read())
    except Exception as e:
        # En cas d'erreur, afficher simplement avec UTF-8
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                print(f.read())
        except:
            print(f"❌ Erreur lors de la lecture du fichier: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 markdown_viewer.py <file.md>")
        sys.exit(1)
    
    print_markdown_colored(sys.argv[1])

