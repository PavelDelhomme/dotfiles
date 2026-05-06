> **Index** : [`../STRUCTURE.md`](../STRUCTURE.md) · [`../TESTS.md`](../TESTS.md) · [`../ERRORS.md`](../ERRORS.md) · Statut [`STATUS.md`](../../STATUS.md)

# 📚 Guide d'affichage pour la commande `help`

> Mise à jour 2026-05 : à harmoniser avec la couche d'affichage commune (roadmap : `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

Ce document explique toutes les méthodes possibles pour structurer l'affichage de la commande `help`, avec des exemples de code et des instructions pour tester les modifications.

## 📋 Table des matières

1. [Structure actuelle](#structure-actuelle)
2. [Méthodes d'affichage](#méthodes-daffichage)
3. [Où modifier le code](#où-modifier-le-code)
4. [Exemples de modifications](#exemples-de-modifications)
5. [Tests et validation](#tests-et-validation)

---

## 🏗️ Structure actuelle

### Fichiers concernés

- **Script Python principal** : `zsh/functions/helpman/utils/list_functions.py`
  - C'est ici que se fait l'affichage principal
  - Format actuel : catégorie → séparateur → fonctions (une par ligne)

- **Fonction shell wrapper** : `zsh/functions/helpman/modules/help_system.sh`
  - Fonction `list_functions()` qui appelle le script Python
  - Ligne ~89-99 : point d'entrée principal

### Format actuel

```
🎛️  GESTIONNAIRES (Managers)
──────────────────────────────────────────────────────────────────────────
  • aliaman                        - Description tronquée...
  • pathman                        - Description tronquée...
```

---

## 🎨 Méthodes d'affichage

### 1. Affichage en colonnes (Tableau)

**Avantages** : Compact, facile à scanner
**Inconvénients** : Peut être difficile à lire sur petits terminaux

```python
# Exemple : 2 colonnes
print(f"{func_name:<25} │ {desc:<40}")
print("─" * 70)

# Exemple : 3 colonnes
print(f"{func_name:<20} │ {desc:<30} │ {category:<15}")
```

**Code à modifier dans `list_functions.py`** :
- Ligne ~140-150 : Boucle d'affichage des fonctions
- Remplacer le `print(f"  • {func_name:<30} - {short_desc}")` par un format en colonnes

### 2. Affichage en grille (Grid)

**Avantages** : Très compact, beaucoup d'informations visibles
**Inconvénients** : Peut être difficile à lire

```python
# Exemple : Grille 2x2
funcs = categories[cat]
cols = 2
for i in range(0, len(funcs), cols):
    row_funcs = funcs[i:i+cols]
    row = " │ ".join([f"{f[0]:<25}" for f in row_funcs])
    print(f"  {row}")
```

**Code à modifier** :
- Ligne ~140-150 : Remplacer la boucle simple par une boucle avec calcul de colonnes

### 3. Affichage avec séparateurs verticaux

**Avantages** : Clair, organisé
**Inconvénients** : Prend plus de place

```python
# Exemple : Avec séparateurs │
print(f"  • {func_name:<30} │ {short_desc}")
print("  " + "─" * 30 + "┼" + "─" * (term_width - 35))
```

**Code à modifier** :
- Ligne ~140-150 : Ajouter des séparateurs dans le format

### 4. Affichage avec indentation hiérarchique

**Avantages** : Montre la hiérarchie clairement
**Inconvénients** : Peut être verbeux

```python
# Exemple : Indentation par niveau
print(f"    ├─ {func_name}")
print(f"    │  └─ {short_desc}")
```

**Code à modifier** :
- Ligne ~140-150 : Changer les préfixes et ajouter des caractères d'arborescence

### 5. Affichage avec couleurs et emojis par type

**Avantages** : Visuellement attrayant, facile à identifier
**Inconvénients** : Peut être distrayant

```python
# Exemple : Emojis par type de fonction
emoji_map = {
    "docker": "🐳",
    "git": "🔀",
    "go": "🐹"
}
emoji = emoji_map.get(cat.split("/")[-1], "⚙️")
print(f"  {emoji} {func_name:<30} - {short_desc}")
```

**Code à modifier** :
- Ligne ~140-150 : Ajouter un mapping d'emojis et les inclure dans l'affichage

### 6. Affichage avec pagination

**Avantages** : Gère les grandes listes
**Inconvénients** : Nécessite interaction utilisateur

```python
# Exemple : Pagination
page_size = 20
for i in range(0, len(funcs), page_size):
    page = funcs[i:i+page_size]
    for func_name, desc in page:
        print(f"  • {func_name:<30} - {short_desc}")
    if i + page_size < len(funcs):
        input("Appuyez sur Entrée pour continuer...")
```

**Code à modifier** :
- Ligne ~140-150 : Ajouter une logique de pagination

### 7. Affichage avec largeur adaptative

**Avantages** : S'adapte au terminal
**Inconvénients** : Plus complexe

```python
# Exemple : Colonnes adaptatives
term_width = int(os.environ.get("COLUMNS", 80))
if term_width > 120:
    cols = 3
elif term_width > 80:
    cols = 2
else:
    cols = 1
```

**Code à modifier** :
- Ligne ~30-35 : Calcul de la largeur
- Ligne ~140-150 : Utiliser le nombre de colonnes calculé

### 8. Affichage avec statistiques par catégorie

**Avantages** : Informations supplémentaires
**Inconvénients** : Peut être verbeux

```python
# Exemple : Avec compteur
print(f"{display_name} ({len(categories[cat])} fonctions)")
```

**Code à modifier** :
- Ligne ~130-135 : Ajouter le compteur dans l'en-tête

---

## 🔧 Où modifier le code

### Fichier principal : `zsh/functions/helpman/utils/list_functions.py`

#### Section 1 : Configuration (lignes ~20-35)

```python
# Obtenir la largeur du terminal
term_width = int(os.environ.get("COLUMNS", 80))
desc_max_width = term_width - 45
```

**Modifications possibles** :
- Changer le calcul de `desc_max_width`
- Ajouter des constantes pour le nombre de colonnes
- Définir des seuils pour différents formats

#### Section 2 : Collecte des données (lignes ~40-80)

```python
# Collecter toutes les fonctions par catégorie
categories = defaultdict(list)
```

**Modifications possibles** :
- Ajouter des métadonnées supplémentaires (ex: nombre d'arguments, tags)
- Filtrer certaines fonctions
- Trier différemment

#### Section 3 : Affichage des catégories (lignes ~120-150)

**C'EST LA SECTION PRINCIPALE À MODIFIER POUR L'AFFICHAGE**

```python
# Ligne ~130-135 : En-tête de catégorie
print(display_name)
print("──────────────────────────────────────────────────────────────────────────")

# Ligne ~140-150 : Affichage des fonctions (À MODIFIER ICI)
for func_name, desc in categories[cat]:
    short_desc = truncate_desc(desc, desc_max_width) if desc else ""
    if short_desc:
        print(f"  • {func_name:<30} - {short_desc}")
    else:
        print(f"  • {func_name:<30}")
```

**Modifications possibles** :
- Changer le format de la ligne (ligne 143-146)
- Ajouter des séparateurs
- Créer des colonnes multiples
- Ajouter des couleurs/emojis

---

## 📝 Exemples de modifications

### Exemple 1 : Affichage en 2 colonnes

**Modifier `list_functions.py` ligne ~140-150** :

```python
# AVANT
for func_name, desc in categories[cat]:
    short_desc = truncate_desc(desc, desc_max_width) if desc else ""
    if short_desc:
        print(f"  • {func_name:<30} - {short_desc}")
    else:
        print(f"  • {func_name:<30}")

# APRÈS (2 colonnes)
funcs = categories[cat]
cols = 2
col_width = (term_width - 10) // cols  # Réserver 10 pour marges et séparateurs

for i in range(0, len(funcs), cols):
    row_funcs = funcs[i:i+cols]
    row_parts = []
    for func_name, desc in row_funcs:
        short_desc = truncate_desc(desc, col_width - 35) if desc else ""
        row_parts.append(f"{func_name:<25} {short_desc}")
    print("  " + " │ ".join(row_parts))
```

### Exemple 2 : Affichage avec séparateurs verticaux

**Modifier `list_functions.py` ligne ~140-150** :

```python
# APRÈS (avec séparateurs)
for func_name, desc in categories[cat]:
    short_desc = truncate_desc(desc, desc_max_width) if desc else ""
    print(f"  • {func_name:<30} │ {short_desc}")
    if func_name != categories[cat][-1][0]:  # Pas la dernière
        print("  " + "─" * 30 + "┼" + "─" * (term_width - 35))
```

### Exemple 3 : Affichage avec emojis par type

**Modifier `list_functions.py` ligne ~100-110 (ajouter mapping)** :

```python
# Ajouter après display_names
emoji_by_category = {
    "docker": "🐳",
    "go": "🐹",
    "git": "🔀",
    "cyber": "🛡️",
    "misc": "🔧",
    "dev": "💻"
}

# Modifier ligne ~140-150
for func_name, desc in categories[cat]:
    # Déterminer l'emoji
    cat_key = cat.split("/")[0] if "/" in cat else cat
    emoji = emoji_by_category.get(cat_key, "⚙️")
    
    short_desc = truncate_desc(desc, desc_max_width) if desc else ""
    if short_desc:
        print(f"  {emoji} {func_name:<28} - {short_desc}")
    else:
        print(f"  {emoji} {func_name:<28}")
```

### Exemple 4 : Affichage avec compteur

**Modifier `list_functions.py` ligne ~130** :

```python
# AVANT
print(display_name)
print("──────────────────────────────────────────────────────────────────────────")

# APRÈS
func_count = len(categories[cat])
print(f"{display_name} ({func_count} fonction{'s' if func_count > 1 else ''})")
print("──────────────────────────────────────────────────────────────────────────")
```

### Exemple 5 : Affichage adaptatif (colonnes selon largeur)

**Modifier `list_functions.py` ligne ~30-35 et ~140-150** :

```python
# Ligne ~30-35 : Calculer le nombre de colonnes
term_width = int(os.environ.get("COLUMNS", 80))
if term_width > 120:
    num_cols = 3
elif term_width > 80:
    num_cols = 2
else:
    num_cols = 1
col_width = (term_width - 10) // num_cols

# Ligne ~140-150 : Affichage adaptatif
funcs = categories[cat]
for i in range(0, len(funcs), num_cols):
    row_funcs = funcs[i:i+num_cols]
    row_parts = []
    for func_name, desc in row_funcs:
        short_desc = truncate_desc(desc, col_width - 30) if desc else ""
        row_parts.append(f"{func_name:<25} {short_desc}")
    print("  " + " │ ".join(row_parts))
```

---

## 🧪 Tests et validation

### Comment tester les modifications

1. **Modifier le fichier** :
   ```bash
   nano ~/dotfiles/zsh/functions/helpman/utils/list_functions.py
   ```

2. **Tester directement** :
   ```bash
   # Tester le script Python directement
   python3 ~/dotfiles/zsh/functions/helpman/utils/list_functions.py
   ```

3. **Tester via help** :
   ```bash
   # Recharger le shell ou sourcer le fichier
   source ~/dotfiles/zsh/zshrc_custom
   
   # Tester la commande help
   help
   ```

4. **Tester avec différentes largeurs de terminal** :
   ```bash
   # Terminal étroit (80 colonnes)
   COLUMNS=80 help
   
   # Terminal moyen (100 colonnes)
   COLUMNS=100 help
   
   # Terminal large (150 colonnes)
   COLUMNS=150 help
   ```

### Points de vérification

- ✅ Les catégories s'affichent dans le bon ordre
- ✅ Les fonctions sont groupées sous leurs catégories
- ✅ Les descriptions sont tronquées correctement
- ✅ L'affichage s'adapte à la largeur du terminal
- ✅ Pas de doublons de fonctions
- ✅ Les séparateurs sont alignés correctement

### Debugging

Si l'affichage ne fonctionne pas :

1. **Vérifier les erreurs Python** :
   ```bash
   python3 ~/dotfiles/zsh/functions/helpman/utils/list_functions.py 2>&1
   ```

2. **Vérifier que le script est exécutable** :
   ```bash
   ls -l ~/dotfiles/zsh/functions/helpman/utils/list_functions.py
   chmod +x ~/dotfiles/zsh/functions/helpman/utils/list_functions.py
   ```

3. **Vérifier les variables d'environnement** :
   ```bash
   echo $DOTFILES_DIR
   echo $COLUMNS
   ```

4. **Tester avec des données minimales** :
   - Commenter temporairement certaines catégories
   - Réduire le nombre de fonctions affichées

---

## 📊 Comparaison des méthodes

| Méthode | Compacité | Lisibilité | Complexité | Recommandé pour |
|---------|-----------|------------|------------|-----------------|
| Ligne simple | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Petites listes |
| 2 colonnes | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | Listes moyennes |
| 3+ colonnes | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Grandes listes, terminaux larges |
| Grille | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | Maximum d'informations |
| Séparateurs | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Clarté maximale |
| Pagination | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Très grandes listes |

---

## 🎯 Recommandations

### Pour un terminal standard (80-100 colonnes)
- **Méthode recommandée** : Ligne simple avec troncature intelligente
- **Format** : `  • nom_fonction - description...`

### Pour un terminal large (120+ colonnes)
- **Méthode recommandée** : 2 colonnes avec séparateurs
- **Format** : `  nom_fonction │ description`

### Pour un terminal très large (150+ colonnes)
- **Méthode recommandée** : 3 colonnes
- **Format** : `  nom │ desc │ cat`

---

## 🔄 Workflow de modification

1. **Faire une copie de sauvegarde** :
   ```bash
   cp zsh/functions/helpman/utils/list_functions.py zsh/functions/helpman/utils/list_functions.py.bak
   ```

2. **Modifier le fichier** selon les exemples ci-dessus

3. **Tester** :
   ```bash
   python3 zsh/functions/helpman/utils/list_functions.py
   ```

4. **Valider** avec `help`

5. **Commit** si satisfait :
   ```bash
   git add zsh/functions/helpman/utils/list_functions.py
   git commit -m "feat: amélioration affichage help() - [description]"
   ```

---

## 📚 Ressources supplémentaires

- Documentation Python `str.format()` : https://docs.python.org/3/library/string.html#formatstrings
- ANSI colors : https://en.wikipedia.org/wiki/ANSI_escape_code
- Terminal width detection : Variable `COLUMNS` ou `tput cols`

---

**Dernière mise à jour** : $(date)
**Fichier modifié** : `zsh/functions/helpman/utils/list_functions.py` (lignes ~140-150 pour l'affichage principal)

