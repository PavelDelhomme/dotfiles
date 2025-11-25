#!/usr/bin/env python3
import os
import re
import sys
from collections import defaultdict

def truncate_desc(text, max_len):
    if len(text) > max_len:
        return text[:max_len-3] + "..."
    return text

def get_category_from_path(file_path, funcs_dir):
    # Normaliser les chemins
    funcs_dir = os.path.normpath(funcs_dir)
    file_path = os.path.normpath(file_path)
    
    # Obtenir le chemin relatif
    try:
        relative_path = os.path.relpath(file_path, funcs_dir)
    except:
        relative_path = file_path.replace(funcs_dir + "/", "").replace(funcs_dir + "\\", "")
    
    # Gérer les fichiers à la racine (comme *man.zsh)
    if "/" not in relative_path and "\\" not in relative_path:
        if relative_path.endswith("man.zsh") or relative_path.endswith("man.sh"):
            return "gestionnaires"
        # Autres fichiers à la racine
        return "utils"
    
    # Séparer le chemin
    parts = relative_path.replace("\\", "/").split("/")
    
    # Si on a au moins 3 parties (ex: cyber/reconnaissance/domain_whois.sh)
    if len(parts) >= 3:
        return f"{parts[0]}/{parts[1]}"
    # Si on a 2 parties (ex: misc/system/process.sh ou dev/go.sh)
    elif len(parts) == 2:
        # Cas spécial : fichiers dans dev/ (go.sh, docker.sh, etc.)
        if parts[0] == "dev":
            # Extraire le nom de la catégorie depuis le nom du fichier
            filename = parts[1].replace(".sh", "").replace(".zsh", "")
            # Mapping des noms de fichiers vers catégories
            dev_mapping = {
                "go": "dev/go",
                "docker": "dev/docker",
                "c": "dev/c",
                "make": "dev/make"
            }
            return dev_mapping.get(filename, f"dev/{filename}")
        # Cas spécial : fichiers dans git/ ou utils/ (un seul fichier = catégorie racine)
        elif parts[0] in ["git", "utils"]:
            return parts[0]
        # Autres cas (misc/system, etc.) - sous-dossiers
        return f"{parts[0]}/{parts[1]}"
    # Sinon, utils par défaut
    else:
        return "utils"

def main():
    dotfiles_dir = os.environ.get("DOTFILES_DIR", os.path.expanduser("~/dotfiles"))
    funcs_dir = f"{dotfiles_dir}/zsh/functions"
    
    if not os.path.exists(funcs_dir):
        print("❌ Répertoire des fonctions introuvable")
        sys.exit(1)
    
    # Obtenir la largeur du terminal
    try:
        term_width = int(os.environ.get("COLUMNS", 80))
    except:
        term_width = 80
    if term_width < 60:
        term_width = 80
    desc_max_width = term_width - 45
    
    # Collecter toutes les fonctions par catégorie
    categories = defaultdict(list)
    
    for root, dirs, files in os.walk(funcs_dir):
        for filename in files:
            if not (filename.endswith(".sh") or filename.endswith(".zsh")):
                continue
            
            file_path = os.path.join(root, filename)
            category = get_category_from_path(file_path, funcs_dir)
            category = category.replace(".zsh", "").replace(".sh", "")
            
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                    for i, line in enumerate(lines):
                        # Chercher les définitions de fonctions
                        func_match = re.match(r'^(function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', line)
                        if func_match:
                            func_name = func_match.group(2)
                            if func_name in ['if', 'for', 'while', 'case', 'function']:
                                continue
                            
                            # Chercher la description dans les lignes précédentes
                            desc = ""
                            for j in range(max(0, i-20), i):
                                desc_match = re.match(r'^#\s*DESC:\s*(.*)', lines[j])
                                if desc_match:
                                    desc = desc_match.group(1).strip()
                                    break
                            
                            if func_name:
                                categories[category].append((func_name, desc))
            except Exception as e:
                continue
    
    # Supprimer les doublons
    for cat in categories:
        seen = set()
        unique_funcs = []
        for func_name, desc in categories[cat]:
            if func_name not in seen:
                seen.add(func_name)
                unique_funcs.append((func_name, desc))
        categories[cat] = sorted(unique_funcs, key=lambda x: x[0])
    
    # Définir l'ordre d'affichage
    category_order = [
        "gestionnaires",
        "misc/system",
        "misc/clipboard",
        "misc/files",
        "misc/backup",
        "misc/security",
        "dev/go",
        "dev/docker",
        "dev/c",
        "dev/make",
        "dev/projects",
        "cyber/reconnaissance",
        "cyber/scanning",
        "cyber/vulnerability",
        "cyber/attacks",
        "cyber/analysis",
        "cyber/privacy",
        "git",
        "utils"
    ]
    
    # Mapper les noms d'affichage
    display_names = {
        "gestionnaires": "🎛️  GESTIONNAIRES (Managers)",
        "misc/system": "💻 SYSTÈME (System)",
        "misc/clipboard": "📋 PRESSE-PAPIER (Clipboard)",
        "misc/files": "📁 FICHIERS (Files)",
        "misc/backup": "💾 SAUVEGARDE (Backup)",
        "misc/security": "🔒 SÉCURITÉ (Security)",
        "dev/go": "🐹 GO (Go Language)",
        "dev/docker": "🐳 DOCKER (Docker)",
        "dev/c": "⚙️  C/C++ (C/C++)",
        "dev/make": "🔨 MAKE (Make)",
        "dev/projects": "📦 PROJETS (Projects)",
        "cyber/reconnaissance": "🛡️  CYBER / RECONNAISSANCE",
        "cyber/scanning": "🛡️  CYBER / SCANNING",
        "cyber/vulnerability": "🛡️  CYBER / VULNERABILITY",
        "cyber/attacks": "🛡️  CYBER / ATTACKS",
        "cyber/analysis": "🛡️  CYBER / ANALYSIS",
        "cyber/privacy": "🛡️  CYBER / PRIVACY",
        "git": "🔀 GIT (Git)",
        "utils": "🛠️  UTILITAIRES (Utils)"
    }
    
    # Forcer le flush pour un affichage immédiat
    import sys
    sys.stdout.reconfigure(line_buffering=True) if hasattr(sys.stdout, 'reconfigure') else None
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", flush=True)
    print("📋 FONCTIONS DISPONIBLES (organisées par catégories)", flush=True)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", flush=True)
    print(flush=True)
    
    # Afficher les catégories dans l'ordre défini
    displayed_cats = set()
    for cat in category_order:
        # Vérifier que la catégorie existe ET a des fonctions
        if cat in categories and len(categories[cat]) > 0:
            displayed_cats.add(cat)
            display_name = display_names.get(cat, f"📂 {cat.replace('/', ' / ').upper()}")
            
            # Afficher l'en-tête de catégorie
            print(display_name, flush=True)
            print("──────────────────────────────────────────────────────────────────────────", flush=True)
            
            # Afficher TOUTES les fonctions de cette catégorie immédiatement
            for func_name, desc in categories[cat]:
                short_desc = truncate_desc(desc, desc_max_width) if desc else ""
                if short_desc:
                    print(f"  • {func_name:<30} - {short_desc}", flush=True)
                else:
                    print(f"  • {func_name:<30}", flush=True)
            
            # Ligne vide après chaque catégorie
            print(flush=True)
    
    # Afficher les catégories restantes
    for cat in sorted(categories.keys()):
        if cat not in displayed_cats and len(categories[cat]) > 0:
            display_name = f"📂 {cat.replace('/', ' / ').upper()}"
            print(display_name, flush=True)
            print("──────────────────────────────────────────────────────────────────────────", flush=True)
            
            for func_name, desc in categories[cat]:
                short_desc = truncate_desc(desc, desc_max_width) if desc else ""
                if short_desc:
                    print(f"  • {func_name:<30} - {short_desc}", flush=True)
                else:
                    print(f"  • {func_name:<30}", flush=True)
            
            print(flush=True)
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", flush=True)
    print(flush=True)
    print("💡 Utilisez 'help <nom_fonction>' pour obtenir l'aide détaillée", flush=True)
    print("💡 Utilisez 'man <nom_fonction>' pour la documentation complète", flush=True)
    print(flush=True)

if __name__ == "__main__":
    main()

