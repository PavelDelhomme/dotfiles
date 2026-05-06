# Journal des erreurs, incidents et correctifs

> **Index** : [`STRUCTURE.md`](STRUCTURE.md) · **Statut** : [`../STATUS.md`](../STATUS.md) (racine) · **Tests** : [`TESTS.md`](TESTS.md)

Tout incident **récurrent** (CI, Docker, shell, manager) doit être consigné ici pour éviter de réinventer le diagnostic. Les entrées **résolues** restent dans l’historique ; les entrées **ouvertes** sont en tête de la section active.

## Comment ajouter une entrée

1. **Nouveau bloc** avec date `AAAA-MM`.
2. Tableau : **Problème** | **Cause** | **Correctif** | **Statut** (`ouvert` / `résolu`).
3. Lier un commit ou une PR si applicable.

---

## Actif / récent

| Problème | Cause | Correctif | Statut |
|----------|--------|-----------|--------|
| *(à compléter au fil des incidents)* | | | |

---

## 2026-05 — `make test` phase 2 & matrice

| Problème | Cause | Correctif | Statut |
|----------|--------|-----------|--------|
| `tee: …/dotfiles/test_results/… Read-only file system` | Écriture des rapports sous le dépôt monté RO dans le conteneur | `run_tests.sh`, `manager_subcommand_matrix.sh`, `run_tests_in_current_env` : `TEST_RESULTS_DIR` bascule vers `/root/test_results` ou `/tmp/dotfiles_test_results` | résolu |
| `❌ échec: zsh\|bash\|fish gitman log 1` | `git log` avec pager ou dépôt sans commit → code ≠ 0 ; sous zsh, parse du core `gitman.sh` hors émulation sh | `git --no-pager` + `gitman_log_oneline` (HEAD absent → message, exit 0) ; adapter zsh : `emulate -L sh` + `source` du core | résolu |
| `installman help` verbeux en zsh/bash, court en fish | Fish matrice = core POSIX ; zsh/bash = ancien core ou entry zsh | Adapters `shells/zsh|bash/adapters/installman.*` chargent **`core/managers/installman/core/installman.sh`** | résolu |

### Fichiers utiles (diagnostic)

- `scripts/test/subcommands/*.list` — invocations phase 2 (ajuster ou `@skip` si trop interactif).
- `test_output.log`, `subcommand_matrix_summary.txt`, `all_managers_test_report.txt` sous **`TEST_RESULTS_DIR`**.

---

## Historique (archives courtes)

Les anciens incidents massifs peuvent être **résumés** ici ; le détail narratif long reste dans les commits Git et, le cas échéant, [`REFACTOR_HISTORY.md`](REFACTOR_HISTORY.md).

| Période | Thème | Où détailler |
|---------|--------|----------------|
| 2025–2026 | Migration multi-shell, wrappers → POSIX | `docs/migrations/`, `REFACTOR_HISTORY.md` |
| 2025–2026 | Docker / sandbox RO | `scripts/test/SANDBOX.md` |
