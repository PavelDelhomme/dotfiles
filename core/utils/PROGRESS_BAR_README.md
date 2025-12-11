# 📊 PROGRESS_BAR - Barre de progression réutilisable

## 📋 Description

Système de barre de progression réutilisable pour afficher l'avancement de traitements dans les scripts shell et Python.

**Compatible** : ZSH, Bash, Fish (via sh), POSIX sh, Python 3.6+

---

## 🚀 Utilisation rapide

### Shell (POSIX)

```bash
# Charger le script
source ~/dotfiles/core/utils/progress_bar.sh

# Initialiser avec 100 éléments
progress_init 100 "Installation de paquets"

# Dans une boucle
for i in {1..100}; do
    # Votre traitement ici
    do_something
    
    # Mettre à jour la progression
    progress_update $i $successful $failed
done

# Terminer et afficher le résumé
progress_finish
```

### Python

```python
from progress_utils import ProgressBar

# Créer une barre de progression
progress = ProgressBar(100, "Traitement de fichiers")

# Dans une boucle
for i in range(100):
    # Votre traitement ici
    result = do_something()
    
    # Incrémenter
    progress.increment(successful=result)
    
# Terminer
progress.finish()
```

---

## 📖 Documentation complète

### Fonctions Shell (POSIX)

#### `progress_init TOTAL [DESCRIPTION]`

Initialise la barre de progression.

**Arguments :**
- `TOTAL` : Nombre total d'éléments à traiter
- `DESCRIPTION` : Description du traitement (optionnel)

**Exemple :**
```bash
progress_init 50 "Installation de paquets"
```

#### `progress_update COMPLETED [SUCCESSFUL] [FAILED]`

Met à jour la barre de progression.

**Arguments :**
- `COMPLETED` : Nombre d'éléments complétés
- `SUCCESSFUL` : Nombre d'éléments réussis (optionnel)
- `FAILED` : Nombre d'éléments échoués (optionnel)

**Exemple :**
```bash
progress_update 25 20 5
```

#### `progress_increment [SUCCESSFUL] [COUNT]`

Incrémente la progression d'un ou plusieurs éléments.

**Arguments :**
- `SUCCESSFUL` : `true`/`false` ou `1`/`0` (défaut: `true`)
- `COUNT` : Nombre d'éléments à incrémenter (défaut: `1`)

**Exemple :**
```bash
progress_increment true 1   # Incrémenter 1 élément réussi
progress_increment false 1  # Incrémenter 1 élément échoué
```

#### `progress_finish [SHOW_SUMMARY]`

Termine la barre de progression et affiche le résumé.

**Arguments :**
- `SHOW_SUMMARY` : `true`/`false` pour afficher le résumé (défaut: `true`)

**Exemple :**
```bash
progress_finish        # Affiche le résumé
progress_finish false # Sans résumé
```

#### `progress_reset`

Réinitialise toutes les variables de progression.

**Exemple :**
```bash
progress_reset
```

---

### Classe Python

#### `ProgressBar(total, description="Traitement")`

Classe pour gérer une barre de progression.

**Méthodes :**

- `update(completed, successful=None, failed=None, force=False)` : Met à jour la progression
- `increment(successful=True, count=1)` : Incrémente la progression
- `finish(show_summary=True)` : Termine et affiche le résumé

**Exemple :**
```python
progress = ProgressBar(100, "Installation")
for i in range(100):
    progress.increment(successful=True)
progress.finish()
```

---

## 💡 Exemples d'utilisation

### Exemple 1 : Installation de paquets

```bash
#!/bin/sh
source ~/dotfiles/core/utils/progress_bar.sh

packages="package1 package2 package3 package4 package5"
total=$(echo "$packages" | wc -w)

progress_init "$total" "Installation de paquets"

successful=0
failed=0
completed=0

for package in $packages; do
    if install_package "$package"; then
        successful=$((successful + 1))
    else
        failed=$((failed + 1))
    fi
    completed=$((completed + 1))
    progress_update "$completed" "$successful" "$failed"
done

progress_finish
```

### Exemple 2 : Traitement de fichiers

```python
#!/usr/bin/env python3
from progress_utils import ProgressBar
import os

files = [f for f in os.listdir('.') if os.path.isfile(f)]
progress = ProgressBar(len(files), "Traitement de fichiers")

for file in files:
    try:
        process_file(file)
        progress.increment(successful=True)
    except Exception as e:
        print(f"Erreur avec {file}: {e}")
        progress.increment(successful=False)

progress.finish()
```

### Exemple 3 : Migration de données

```bash
#!/bin/sh
source ~/dotfiles/core/utils/progress_bar.sh

total=1000
progress_init "$total" "Migration de données"

successful=0
failed=0

for i in $(seq 1 "$total"); do
    if migrate_item "$i"; then
        successful=$((successful + 1))
    else
        failed=$((failed + 1))
    fi
    progress_update "$i" "$successful" "$failed"
done

progress_finish
```

---

## 🎨 Affichage

La barre de progression affiche :

```
[25/50] 50.0% |████████████████████░░░░░░░░░░░░░░░░░░░░| ✅ 20 | ❌ 5 | ⏱️  00:00:05 écoulé | ~00:00:05 restant
```

**Composants :**
- `[25/50]` : Éléments complétés / Total
- `50.0%` : Pourcentage
- `|████████████████████░░░░░░░░░░░░░░░░░░░░|` : Barre visuelle
- `✅ 20 | ❌ 5` : Statistiques (réussis / échoués)
- `⏱️  00:00:05 écoulé | ~00:00:05 restant` : Temps

**Résumé final :**
```
═══════════════════════════════════════════════════════════════
📊 RÉSUMÉ - Installation de paquets
═══════════════════════════════════════════════════════════════
⏱️  Temps total: 00:00:10
✅ Réussis: 20 (40.0%)
❌ Échoués: 5 (10.0%)
═══════════════════════════════════════════════════════════════
```

---

## 🔧 Configuration

### Variables globales (Shell)

- `PROGRESS_START_TIME` : Timestamp de début
- `PROGRESS_TOTAL` : Nombre total d'éléments
- `PROGRESS_COMPLETED` : Nombre d'éléments complétés
- `PROGRESS_SUCCESSFUL` : Nombre d'éléments réussis
- `PROGRESS_FAILED` : Nombre d'éléments échoués
- `PROGRESS_DESCRIPTION` : Description du traitement

### Paramètres Python

- `bar_length` : Longueur de la barre (défaut: 40)
- `print_interval` : Intervalle d'affichage en secondes (défaut: 0.3)

---

## ✅ Compatibilité

### Shells supportés

- ✅ **ZSH** : Testé et fonctionnel
- ✅ **Bash** : Testé et fonctionnel
- ✅ **Fish** : Compatible via `sh` (source depuis sh)
- ✅ **POSIX sh** : Complètement compatible

### Python

- ✅ **Python 3.6+** : Testé et fonctionnel
- ✅ **Python 3.7+** : Recommandé (meilleure performance)

---

## 📝 Notes

1. **Performance** : La barre s'affiche toutes les 0.3 secondes minimum (Python) pour éviter la surcharge
2. **Terminal** : Utilise `\r` pour écraser la ligne précédente (compatible avec la plupart des terminaux)
3. **Calculs** : Utilise `awk` pour les calculs flottants (compatible POSIX)
4. **Temps** : Format HH:MM:SS pour le temps écoulé et estimé

---

## 🐛 Dépannage

### La barre ne s'affiche pas

- Vérifiez que le script est bien sourcé : `source ~/dotfiles/core/utils/progress_bar.sh`
- Vérifiez que `printf` est disponible
- Vérifiez que `awk` est installé

### Les calculs sont incorrects

- Vérifiez que `awk` est disponible
- Vérifiez que les nombres sont bien des entiers

### Le résumé ne s'affiche pas

- Vérifiez que `progress_finish` est appelé
- Vérifiez que `show_summary` n'est pas `false`

---

## 📚 Références

- Fichier shell : `core/utils/progress_bar.sh`
- Fichier Python : `core/utils/progress_utils.py`
- Exemple shell : `core/utils/example_progress.sh`

---

## 🔄 Changelog

### Version 1.0 (2024-12-XX)
- ✅ Support POSIX complet
- ✅ Support Python 3.6+
- ✅ Statistiques (réussis/échoués)
- ✅ Estimation du temps restant
- ✅ Résumé final détaillé
- ✅ Compatible ZSH, Bash, Fish, POSIX sh

