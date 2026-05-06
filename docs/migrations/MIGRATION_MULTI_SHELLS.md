# 🔄 Migration Multi-Shells - Plan d'Action

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/UNIFIED_PLATFORM_ROADMAP.md`).

## 📋 Vue d'ensemble

Ce document décrit le plan pour migrer **toutes** les fonctionnalités ZSH vers Fish et Bash, avec synchronisation automatique.

## 🎯 Objectifs

1. **Parité fonctionnelle** : Tous les managers ZSH disponibles aussi en Fish et Bash
2. **Synchronisation automatique** : Les mises à jour ZSH propagées automatiquement
3. **Même interface** : Même UX dans les 3 shells

## 📊 État actuel

### ZSH (Complet)
- ✅ 18 managers disponibles
- ✅ Architecture modulaire
- ✅ Fonctions complètes

### Fish (Partiel)
- ⚠️ Quelques fonctions isolées
- ⚠️ Pas de structure modulaire
- ❌ Pas de managers

### Bash (Minimal)
- ⚠️ Variables d'environnement seulement
- ❌ Pas de managers
- ❌ Pas de fonctions

## 🏗️ Architecture proposée

### Structure cible
```
dotfiles/
├── zsh/functions/        # Version ZSH (source principale)
│   ├── installman/
│   ├── configman/
│   └── ...
├── fish/functions/       # Version Fish (générée/synchronisée)
│   ├── installman/
│   ├── configman/
│   └── ...
└── bash/functions/       # Version Bash (générée/synchronisée)
    ├── installman/
    ├── configman/
    └── ...
```

### Système de synchronisation

**Option 1 : Script de conversion automatique**
- Script Python/Bash qui convertit ZSH → Fish/Bash
- Adapte la syntaxe selon le shell
- Lancement manuel ou automatique

**Option 2 : Source unique avec adaptateurs**
- Code commun dans un format intermédiaire
- Adaptateurs shell-specific qui convertissent
- Plus complexe mais plus maintenable

**Option 3 : Wrapper multi-shells**
- Fonctions wrapper qui détectent le shell
- Appellent la version appropriée
- Plus simple mais moins performant

## 📝 Plan de migration

### Phase 1 : Infrastructure de base
- [ ] Créer structure `fish/functions/` et `bash/functions/`
- [ ] Script de conversion ZSH → Fish/Bash
- [ ] Système de détection et chargement automatique

### Phase 2 : Migration des managers
- [ ] `installman` (prioritaire - outils de base)
- [ ] `configman` (configuration)
- [ ] `pathman` (gestion PATH)
- [ ] `netman` (réseau)
- [ ] `gitman` (Git)
- [ ] `cyberman` (cybersécurité)
- [ ] `devman` (développement)
- [ ] `miscman` (divers)
- [ ] `aliaman` (alias)
- [ ] `searchman` (recherche)
- [ ] `helpman` (aide)
- [ ] `fileman` (fichiers)
- [ ] `virtman` (virtualisation)
- [ ] `sshman` (SSH)
- [ ] `testman` (tests)
- [ ] `testzshman` (tests ZSH)
- [ ] `moduleman` (modules)
- [ ] `manman` (manager of managers)

### Phase 3 : Synchronisation automatique
- [ ] Script de synchronisation
- [ ] Hook Git pre-commit pour synchroniser
- [ ] Documentation de maintenance

## 🔧 Détails techniques

### Conversion ZSH → Fish

**Syntaxe ZSH :**
```zsh
local VAR="value"
typeset -A hash
function name() { ... }
```

**Syntaxe Fish :**
```fish
set -l VAR "value"
set -g hash (dict)
function name
    ...
end
```

### Conversion ZSH → Bash

**Syntaxe ZSH :**
```zsh
local VAR="value"
typeset -A hash
function name() { ... }
```

**Syntaxe Bash :**
```bash
local VAR="value"
declare -A hash
function name() { ... }
```

## ⚠️ Défis identifiés

1. **Syntaxe différente** : ZSH, Fish et Bash ont des syntaxes très différentes
2. **Fonctionnalités spécifiques** : Certaines fonctions ZSH n'existent pas ailleurs
3. **Maintenance** : Synchroniser 3 versions peut être complexe
4. **Tests** : Tester dans 3 shells différents

## ✅ Avantages

1. **Parité complète** : Mêmes fonctionnalités partout
2. **Flexibilité** : Choix du shell sans perte de fonctionnalités
3. **Maintenabilité** : Source unique, conversions automatiques

## 🚀 Prochaines étapes

1. Créer le script de conversion
2. Migrer `installman` comme pilote
3. Tester et ajuster
4. Migrer les autres managers progressivement
