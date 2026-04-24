# TODOS — Roadmap et actions (dotfiles)

Suivi **opérationnel** : à mettre à jour quand une ligne est faite ou qu’une nouvelle tâche apparaît.  
Vue d’ensemble et tests : **`STATUS.md`** (racine). Architecture : **`docs/ARCHITECTURE.md`**.

---

## Priorités (choisir souvent **une** seule piste)

| # | Tâche | Détail |
|---|--------|--------|
| **1** | Extrait env vers `DOTFILES_GOOD` | Copier un bloc **neutre** depuis `shared/env.sh` vers `DOTFILES_GOOD/shared/env/10_*.sh` (exports simples, pas `add_to_path` / pas d’`echo` bruyant). Noter dans `DOTFILES_GOOD/shared/env/README.md`. Puis `make test-dotfiles-good`. **Ne pas** brancher dans `shared/config.sh` sans validation. |
| **2** | Script sous `DOTFILES_GOOD/scripts/` | Outil ou smoke (ex. `print_roots.sh`). `make test-dotfiles-good`. |
| **3** | Lecture | Tableau managers : `docs/ARCHITECTURE.md`. |
| **4** | Hors bac à sable | Un manager : `read` / `clear` protégés hors TTY si la CI bloque. |

---

## Roadmap (cases)

- [x] Bac à sable **`DOTFILES_GOOD/`** + `make test-dotfiles-good`.
- [x] Tableau managers dans **`docs/ARCHITECTURE.md`** (`migrated_managers.list`).
- [x] Premier extrait **`DOTFILES_GOOD/shared/env/10_toolchain_paths.sh`** (exports neutres depuis `shared/env.sh`).
- [x] Script **`DOTFILES_GOOD/scripts/print_roots.sh`** (affiche `DOTFILES_DIR` / `DOTFILES_GOOD_ROOT` après bootstrap).
- [ ] Déplacer progressivement les modules **installman** vers `core/managers/installman/` + wrappers une ligne.
- [ ] Réduire **`read` / `clear`** hors TTY sur les menus encore touchés par la CI.
- [ ] Garder **`make test`** vert à chaque déplacement.

---

## Fichiers doc : rôle rapide

| Fichier | Rôle |
|---------|------|
| `STATUS.md` | Objectif, état des tests, liens vers la doc. |
| `TODOS.md` | Ce fichier — actions et cases. |
| `docs/MULTISHELL_REPORT.md` | Multi-shell, installman entry, `make test`. |
| `docs/ARCHITECTURE.md` | Entrées shell, tableau managers, `DOTFILES_GOOD`. |
| `docs/REFACTOR_HISTORY.md` | Journal historique des phases (ex-`docs/STATUS.md`). |
| `STRUCTURE_ANALYSIS.md` | Analyse longue / arbre (référence, pas la checklist du jour). |
