# Multi-shell : `shells/` et le reste du dépôt

Ce dossier regroupe les **adaptateurs** par shell. L’idée est : **une logique métier** (souvent POSIX dans `core/managers/<name>/core/*.sh`, ou Zsh dans `zsh/functions/<name>/`), et **des entrées minces** par shell qui fixent `DOTFILES_DIR`, sourcent ou délèguent.

## Rôles des répertoires

| Chemin | Rôle |
|--------|------|
| **`shells/zsh/adapters/*.zsh`** | Charge le core du manager (POSIX sous `core/managers/…` ou Zsh sous `zsh/functions/…`). Alias légers possibles. |
| **`shells/bash/adapters/*.sh`** | Idem ; privilégier `DOTFILES_DIR` et `shared/functions/dotfiles_roots.sh` si besoin. |
| **`shells/fish/adapters/*.fish`** | Fish ne source pas toujours le `.sh` : wrapper `bash`/`sh` ou délégation (ex. `installman` → `installman_entry.sh`). |
| **`core/managers/<manager>/core/*.sh`** | Cœur **POSIX** quand il existe (pathman, installman, etc.) : même fichier pour bash/zsh qui `source` le core. |
| **`zsh/functions/<manager>/`** | Implémentation **riche Zsh** (menus paginés, complétions) quand le manager n’est pas entièrement porté en sh. |
| **`bash/functions/`**, **`fish/functions/`** | Compatibilité / anciens chemins ; viser **shells/*/adapters** + `installman_entry.sh` pour les nouveaux chargements. |
| **`shared/`** | `config.sh`, `env.sh`, `aliases.sh` + **`shared/functions/*.sh`** (ex. `dotfiles_roots.sh`) : commun sh-compatible. |
| **`scripts/lib/`** | TUI (`tui_core.sh`), logs (`managers_log.sh`), menu (`dotfiles_menu.sh`). |

## Personnalisation par shell

- **Variables** : exporter `DOTFILES_DIR` avant d’ouvrir un terminal (ou symlink `~/dotfiles` → ton clone). Les adaptateurs utilisent `DOTFILES_DIR` avec repli sur `$HOME/dotfiles`.
- **Zsh** : `zshrc_custom` charge les adaptateurs depuis `shells/zsh/adapters/`.
- **Bash** : `bashrc_custom` charge `shells/bash/adapters/`.
- **Fish** : `config_custom.fish` charge `shells/fish/adapters/`.
- **Menus TUI** : binaire `bin/dotfiles-menu` + fichiers `share/menus/*.menu` ; helper `scripts/lib/dotfiles_menu.sh` (commande type `dfm pathman` selon ton alias).

## Installman (exemple documenté)

- Entrée unique : `core/managers/installman/installman_entry.sh`.
- Par défaut : **core Zsh** ; avec `INSTALLMAN_ENGINE=posix` ou `--posix` : **core POSIX** (tests / environnement sans zsh).
- Voir aussi `docs/MULTISHELL_REPORT.md` et `scripts/test/installman_check.sh`.

## Outils de synchro / vérif

- `scripts/tools/sync_managers.sh` — repère `core/managers` et les trois dossiers d’adaptateurs.
- `scripts/test/verify_multishell.sh` — smoke test installman depuis zsh/bash/sh.
- **Tests Docker filtrés** : `DOTFILES_TEST_MANAGERS=pathman,netman make test` (ou `make test-help`).

Pour aller plus loin (TUI partout, logging unifié), voir `docs/ACTION_PLAN_ARCHITECTURE.md`.
