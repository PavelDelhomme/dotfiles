# Rapport multi-shell (dotfiles)

## Vue d’ensemble

Les dotfiles visent une **base unique** utilisable par **tous les shells** (sh, bash, zsh, fish).  
- **Cartographie des dossiers** : voir [`shells/README.md`](../shells/README.md) (adaptateurs, `core/`, `shared/`, menus).  
- **Implémentation canonique** : souvent Zsh (`zsh/functions/…`) ; cœur POSIX sous `core/managers/<name>/core/` quand il existe.  
- **Installman** : `core/managers/installman/installman_entry.sh` (Zsh par défaut ; `INSTALLMAN_ENGINE=posix` pour le core sh).  
- **Librairies partagées** : `scripts/lib/` (TUI, logs), `shared/functions/dotfiles_roots.sh` (variables de chemins après `DOTFILES_DIR`).

## Base commune

| Emplacement | Rôle |
|-------------|------|
| `core/managers/installman/installman_entry.sh` | **Entrée unique** : exécutable par tout shell, lance le core Zsh |
| `zsh/functions/installman/core/installman.zsh` | **Implémentation canonique** (menu paginé, log, tous les outils) |
| `scripts/lib/tui_core.sh` | Taille terminal, pagination (POSIX sh) |
| `scripts/lib/installman_log.sh` | Log installman → `logs/installman.log` |
| `scripts/lib/managers_log.sh` | Log générique pour tous les *man → `logs/managers.log` |
| `scripts/install/*.sh` | Scripts d’installation (bash/sh) |

## Par shell

| Shell | Installman |
|-------|------------|
| **Zsh** | Charge directement le core (`shells/zsh/adapters/installman.zsh` → `zsh/.../installman.zsh`). Pas de sous-processus. |
| **Bash** | `shells/bash/adapters/installman.sh` définit `installman()` qui exécute `installman_entry.sh` (zsh). |
| **Fish** | `shells/fish/adapters/installman.fish` définit `installman` qui exécute `installman_entry.sh` (sh puis zsh). |

## Vérification multi-shell

```bash
bash scripts/test/verify_multishell.sh
```

Vérifie que `installman help` fonctionne depuis zsh, bash et sh.

## Filtrer les managers dans les tests Docker

Variable recommandée : **`DOTFILES_TEST_MANAGERS`** (noms séparés par **virgules** ou espaces).  
Si **`TEST_MANAGERS`** est défini, il est prioritaire. Voir **`make test-help`** et **`scripts/test/SANDBOX.md`**.

## `make test` (régression hôte → conteneur)

- **Phase 1** : matrice **manager × shell** (zsh, bash, fish par défaut), rapport `test_results/all_managers_test_report.txt`.  
- **Phase 2** : matrice **sous-commandes** (`scripts/test/manager_subcommand_matrix.sh`), lignes définies dans `scripts/test/subcommands/<manager>.list` (préfixe **`@skip`** = non exécuté en CI).  
- Sortie **terminal + fichier** : `test_results/test_output.log`. Vérifier la phase 2 :  
  `grep -E 'Matrice sous-commandes|échec:' test_results/test_output.log | tail -20`  
- Vue d’ensemble : **`STATUS.md`** (racine), section *État des tests Docker*.

## Docker / VM pour tests

- **Docker** : `scripts/test/docker/` (Dockerfile.test, docker-compose.yml). Lancer les tests : `docker-compose -f scripts/test/docker/docker-compose.yml run --rm dotfiles-test`. Test bootstrap : `bash scripts/test/docker/run_dotfiles_bootstrap.sh` (à lancer depuis l’hôte ou dans le conteneur).
- **VM** : `scripts/vm/` (QEMU/KVM, snapshots). Voir `scripts/vm/README.md`.

## Logs

- **Installman** : `$DOTFILES_DIR/logs/installman.log` (option **logs** dans le menu installman).  
- **Tous les managers** : `$DOTFILES_DIR/logs/managers.log` si utilisation de `log_manager_action` (voir `scripts/lib/managers_log.sh`).

## Rapports multi-shells générés (instantanés)

D’anciens fichiers du type **`TEST_MULTI_SHELLS_REPORT.md`** à la racine du dépôt étaient des **captures ponctuelles** de run local (souvent avec des liens vers `/tmp/...` déjà périmés). Ils ne sont **plus** versionnés à la racine.

- **Référence CI / hôte** : lancer **`make test`**, consulter **`test_results/test_output.log`** (dossier gitignored si configuré ainsi) et la section *État des tests Docker* dans **`STATUS.md`** (racine).
- **Actions à suivre** : **`TODOS.md`** (racine).
- **Script `scripts/test/test_multi_shells.sh`** : écrit le rapport Markdown sous **`test_results/TEST_MULTI_SHELLS_REPORT.md`** (plus à la racine du dépôt).
