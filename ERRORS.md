# ERRORS — journal des incidents tests / CI (dotfiles)

Fichier **court** : symptômes résolus ou pistes, pour ne pas répéter les mêmes écarts. Le détail procédural reste dans `STATUS.md`, `scripts/test/SANDBOX.md`, `make test-help`.

## 2026-05 — `make test` phase 2

| Problème | Cause | Correctif |
|----------|--------|-----------|
| `tee: …/dotfiles/test_results/… Read-only file system` | Écriture des rapports sous le dépôt monté RO dans le conteneur | `run_tests.sh`, `manager_subcommand_matrix.sh`, `run_tests_in_current_env` : `TEST_RESULTS_DIR` bascule vers `/root/test_results` ou `/tmp/dotfiles_test_results` |
| `❌ échec: zsh\|bash\|fish gitman log 1` | `git log` avec pager ou dépôt sans commit → code ≠ 0 ; sous zsh, parse du core `gitman.sh` hors émulation sh | `git --no-pager` + `gitman_log_oneline` (HEAD absent → message, exit 0) ; adapter zsh : `emulate -L sh` + `source` du core |
| `installman help` verbeux en zsh/bash, court en fish | Fish matrice = core POSIX ; zsh/bash = ancien core ou entry zsh | Adapters `shells/zsh|bash/adapters/installman.*` chargent **`core/managers/installman/core/installman.sh`** |

## Fichiers utiles

- `scripts/test/subcommands/*.list` — invocations phase 2 (ajuster ou `@skip` si trop interactif).
- `test_output.log`, `subcommand_matrix_summary.txt`, `all_managers_test_report.txt` sous **`TEST_RESULTS_DIR`**.
