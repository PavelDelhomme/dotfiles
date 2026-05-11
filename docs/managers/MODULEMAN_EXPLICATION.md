> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# 📦 MODULEMAN - Explication Complète

> Mise à jour 2026-05 : ce document reste une référence fonctionnelle ; l'intégration modulaire globale est pilotée dans `docs/architecture/ARCHITECTURE.md`.

## 🎯 Qu'est-ce que MODULEMAN ?

**MODULEMAN** est le **"Gestionnaire de Gestionnaires"** - c'est le système qui **contrôle quels autres managers sont chargés** dans votre shell.

## 🔧 Comment ça fonctionne ?

### 1. **Fichier de Configuration**
Moduleman utilise un fichier de configuration : `~/.config/moduleman/modules.conf`

Ce fichier contient des lignes comme :
```bash
MODULE_pathman=enabled
MODULE_netman=disabled
MODULE_cyberman=enabled
MODULE_devman=enabled
# etc...
```

### 2. **Chargement dans zshrc_custom**
Dans `zshrc_custom`, il y a une fonction `load_manager()` qui :
- Vérifie la variable `MODULE_<nom>=enabled/disabled`
- Si `enabled` → charge le manager
- Si `disabled` → ne charge PAS le manager

```zsh
load_manager "cyberman" "$DOTFILES_ZSH_PATH/functions/cyberman.zsh" "CYBERMAN"
# Vérifie MODULE_cyberman
# Si enabled → source cyberman.zsh
# Si disabled → ne fait rien
```

### 3. **Ordre de Chargement**
1. **D'abord** : Moduleman charge le fichier `modules.conf`
2. **Ensuite** : Moduleman lui-même est chargé
3. **Puis** : Tous les autres managers sont chargés selon leur statut

## ✅ Pourquoi MODULEMAN est-il IMPORTANT ?

### **Sans MODULEMAN :**
- ❌ Tous les managers sont chargés (même ceux que vous n'utilisez pas)
- ❌ Démarrage du shell plus lent
- ❌ Pas de contrôle sur ce qui est chargé
- ❌ Impossible de désactiver un manager sans modifier le code

### **Avec MODULEMAN :**
- ✅ Contrôle total sur quels managers sont actifs
- ✅ Démarrage plus rapide (charge seulement ce dont vous avez besoin)
- ✅ Interface interactive pour activer/désactiver (`moduleman`)
- ✅ Configuration persistante dans `modules.conf`

## 🎮 Utilisation de MODULEMAN

### **Menu Interactif**
```bash
moduleman
# ou
mm
```

Affiche un menu avec tous les managers et leur statut (activé/désactivé).

### **Commandes en Ligne**
```bash
# Activer un manager
moduleman enable cyberman

# Désactiver un manager
moduleman disable netman

# Voir le statut de tous les managers
moduleman status

# Lister tous les managers
moduleman list
```

## ⚠️ IMPORTANT : Doit-on activer MODULEMAN ?

### **OUI, ABSOLUMENT !** ✅

**Moduleman DOIT être activé** car :
1. **Il est chargé AVANT les autres managers** (ligne 58 de zshrc_custom)
2. **Il lit le fichier de configuration** qui contrôle les autres managers
3. **Sans lui, les autres managers ne peuvent pas être contrôlés**

### **Paradoxe ?**
- Moduleman contrôle les autres managers
- Mais moduleman lui-même est aussi contrôlé par... moduleman !
- C'est normal : moduleman se charge d'abord, puis lit sa propre config

## 🔄 Cycle de Chargement

```
1. zshrc_custom démarre
   ↓
2. Charge modules.conf (ligne 54)
   ↓
3. Charge moduleman.zsh (ligne 58)
   ↓
4. Moduleman est maintenant disponible
   ↓
5. load_manager() vérifie MODULE_<nom> pour chaque manager
   ↓
6. Charge seulement les managers avec enabled
```

## 📝 Exemple Concret

### **Configuration dans modules.conf :**
```bash
MODULE_pathman=enabled      # ✅ Chargé
MODULE_netman=disabled      # ❌ Pas chargé
MODULE_cyberman=enabled    # ✅ Chargé
MODULE_devman=enabled       # ✅ Chargé
MODULE_moduleman=enabled    # ✅ Chargé (toujours recommandé)
```

### **Résultat :**
- `pathman` → disponible ✅
- `netman` → non disponible ❌
- `cyberman` → disponible ✅
- `devman` → disponible ✅
- `moduleman` → disponible ✅

## 🎯 Conclusion

**MODULEMAN est ESSENTIEL** :
- ✅ Activez-le TOUJOURS
- ✅ C'est le système de contrôle central
- ✅ Sans lui, vous ne pouvez pas gérer les autres managers
- ✅ Il se charge en premier, donc il peut contrôler les autres

**Dans Docker :**
- Activez moduleman (option 13)
- Puis choisissez les autres managers que vous voulez

