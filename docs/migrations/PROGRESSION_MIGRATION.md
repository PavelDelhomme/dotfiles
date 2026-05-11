> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# 📊 Progression de la Migration Multi-Shells

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

## ✅ Managers Convertis (3/18)

### 1. installman ✅
- **Bash**: ✅ Converti (~370 lignes)
- **Fish**: ✅ Converti (~350 lignes)
- **Tests**: ✅ ZSH ✅, Bash ✅
- **Modules**: Partagés depuis `zsh/functions/installman/modules/`

### 2. configman ✅
- **Bash**: ✅ Converti (258 lignes)
- **Fish**: ✅ Converti (258 lignes)
- **Modules**: Partagés depuis `zsh/functions/configman/modules/`

### 3. pathman 🔄
- **Bash**: ✅ Converti (297 lignes)
- **Fish**: ⏳ En cours
- **Fonctions globales**: `add_to_path`, `clean_path` exportées

---

## ⏳ Managers à Convertir (15 restants)

### Groupe 1 - Simples/Monolithiques (4)
1. **pathman** Fish ⏳ (Bash fait)
2. **aliaman** (~500 lignes) - Monolithique
3. **searchman** (~600 lignes) - Monolithique
4. **manman** (~200 lignes) - Monolithique

### Groupe 2 - Moyens (6)
5. **netman** (885 lignes)
6. **gitman** (608 lignes)
7. **helpman**
8. **fileman**
9. **miscman**
10. **devman**

### Groupe 3 - Avec modules (4)
11. **virtman**
12. **sshman**
13. **testman**
14. **testzshman**

### Groupe 4 - Complexe (1)
15. **cyberman** (très complexe, nombreux modules)

### Groupe 5 - Spécialisés (1)
16. **moduleman** (gestion des modules)

---

## 📈 Statistiques Globales

- **Total managers**: 18
- **Convertis**: 3 (16.7%)
- **En cours**: 1 (pathman Fish)
- **Restants**: 15 (83.3%)

---

## 🎯 Prochaines Étapes

1. Finaliser pathman Fish
2. Convertir les managers simples (Groupe 1)
3. Continuer avec les moyens (Groupe 2)
4. Gérer les avec modules (Groupe 3)
5. Terminer avec les complexes (Groupe 4-5)

---

## 📝 Notes

- Les modules `.sh` peuvent être partagés entre ZSH, Bash et Fish
- Les modules sont utilisés depuis `zsh/functions/{manager}/modules/`
- Les wrappers permettent le chargement dynamique dans chaque shell
- Structure créée pour tous les managers

---

*Dernière mise à jour: $(date)*

