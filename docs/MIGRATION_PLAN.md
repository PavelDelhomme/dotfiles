# 🔄 Plan de Migration Multi-Shells

## 📋 Vue d'ensemble

Migration complète de **toutes** les fonctionnalités ZSH vers Fish et Bash, avec synchronisation automatique.

## 🎯 Objectifs

1. **Parité fonctionnelle complète** : Tous les managers ZSH disponibles en Fish et Bash
2. **Synchronisation automatique** : Les mises à jour ZSH se propagent automatiquement
3. **Même interface utilisateur** : UX identique dans les 3 shells
4. **Maintenance simplifiée** : Source ZSH unique, conversions automatiques

## 📊 État actuel

### ZSH ✅
- 18 managers complets
- Structure modulaire
- ~35 fichiers de code
- Architecture bien définie

### Fish ⚠️
- Quelques fonctions isolées
- Pas de structure modulaire cohérente
- Pas de managers

### Bash ❌
- Variables d'environnement seulement
- Pas de managers
- Structure absente

## 🏗️ Architecture cible

```
dotfiles/
├── zsh/functions/          # SOURCE PRINCIPALE (ZSH)
│   ├── installman/
│   ├── configman/
│   └── ...
├── fish/functions/         # VERSION FISH (synchronisée)
│   ├── installman/
│   ├── configman/
│   └── ...
└── bash/functions/         # VERSION BASH (synchronisée)
    ├── installman/
    ├── configman/
    └── ...
```

## 🔧 Système de conversion

### Script de conversion automatique

**Fichier :** `scripts/tools/sync_managers.sh`

**Fonctionnalités :**
- Convertit ZSH → Fish (adaptation syntaxe)
- Convertit ZSH → Bash (adaptation syntaxe)
- Préserve la structure modulaire
- Gère les différences de syntaxe entre shells

### Conversions principales

**ZSH → Fish :**
- `local VAR="value"` → `set -l VAR "value"`
- `typeset -A hash` → `set -g hash (dict)`
- `function name() { }` → `function name; ...; end`
- `[[ condition ]]` → `test condition`
- Arrays : `array=()` → `set -l array`

**ZSH → Bash :**
- `typeset -A hash` → `declare -A hash`
- Arrays similaires mais syntaxe légèrement différente
- `[[ ]]` fonctionne dans Bash aussi

## 📝 Plan d'exécution

### Phase 1 : Infrastructure ⏳

- [x] Documentation du plan
- [ ] Créer structure `fish/functions/` complète
- [ ] Créer structure `bash/functions/` complète
- [ ] Script de conversion automatique
- [ ] Système de détection et chargement

### Phase 2 : Migration pilote ⏳

- [ ] Migrer `installman` vers Fish
- [ ] Migrer `installman` vers Bash
- [ ] Tester et valider
- [ ] Ajuster le script de conversion

### Phase 3 : Migration complète ⏳

- [ ] `configman`
- [ ] `pathman`
- [ ] `netman`
- [ ] `gitman`
- [ ] `cyberman`
- [ ] `devman`
- [ ] `miscman`
- [ ] `aliaman`
- [ ] `searchman`
- [ ] `helpman`
- [ ] `fileman`
- [ ] `virtman`
- [ ] `sshman`
- [ ] `testman`
- [ ] `testzshman`
- [ ] `moduleman`
- [ ] `manman`

### Phase 4 : Synchronisation ⏳

- [ ] Script de synchronisation automatique
- [ ] Hook Git pre-commit pour auto-sync
- [ ] Documentation de maintenance

### Phase 5 : Tests et validation ⏳

- [ ] Tests dans Docker (ZSH/Fish/Bash)
- [ ] Validation fonctionnelle
- [ ] Documentation utilisateur

## 🔄 Système de synchronisation

### Option 1 : Script manuel

```bash
./scripts/tools/sync_managers.sh
```

### Option 2 : Hook Git (recommandé)

Hook pre-commit qui synchronise automatiquement avant chaque commit.

### Option 3 : Makefile target

```bash
make sync-all-shells
```

## ⚠️ Défis identifiés

1. **Syntaxe très différente** entre les shells
2. **Fonctionnalités spécifiques ZSH** à adapter
3. **Maintenance de 3 versions** (mais auto-synchronisées)
4. **Tests multi-shells** nécessaires

## ✅ Avantages

1. Parité complète entre tous les shells
2. Flexibilité totale du choix du shell
3. Maintenance simplifiée (source unique ZSH)
4. Expérience utilisateur uniforme

## 📅 Timeline estimée

- Phase 1 : 1-2 jours
- Phase 2 : 2-3 jours
- Phase 3 : 5-7 jours
- Phase 4 : 1-2 jours
- Phase 5 : 2-3 jours

**Total estimé :** 11-17 jours de travail

## 🚀 Prochaines étapes immédiates

1. Créer la structure de base Fish/Bash
2. Créer le script de conversion
3. Migrer `installman` comme exemple
4. Valider l'approche
5. Continuer avec les autres managers

