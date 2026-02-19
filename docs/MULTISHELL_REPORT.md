# Rapport multi-shell (dotfiles)

## Vue d’ensemble

Les dotfiles visent une base **unique** utilisable par **plusieurs shells** (sh, bash, zsh, fish).  
Ce qui est commun est dans `scripts/`, `core/` et éventuellement `shared/`.  
Ce qui est spécifique à un shell est dans `zsh/`, `bash/`, `fish/`, `shells/`.

## Base commune (indépendante du shell)

| Emplacement | Rôle |
|-------------|------|
| `scripts/lib/common.sh` | Logging, couleurs, détection distro (bash) |
| `scripts/lib/tui_core.sh` | Taille terminal, pagination (POSIX sh) |
| `scripts/lib/installman_log.sh` | Log des actions installman (bash) |
| `scripts/install/*.sh` | Scripts d’installation (bash/sh) |
| `core/managers/installman/` | Version POSIX de installman (sh) |

## Par shell

| Shell | Chargement | Gestionnaires (*man) |
|-------|------------|----------------------|
| **Zsh** | `zshrc` → `zshrc_custom`, `aliases.zsh`, `functions/*.zsh` | `zsh/functions/installman/`, `configman/`, etc. |
| **Bash** | `~/.bashrc` → dotfiles bash | `bash/functions/installman/` |
| **Fish** | `config.fish`, `aliases.fish` | `fish/functions/installman/` |

## Installman

- **Zsh** : implémentation principale dans `zsh/functions/installman/` (menu paginé, log, TUI).
- **Bash/Fish** : adaptateurs dans `shells/*/adapters/installman.*` ou `bash/functions/installman/`, `fish/functions/installman/` qui peuvent appeler la même logique (scripts ou core) pour garder une seule base.
- **Logs** : tous les shells peuvent écrire dans le même fichier `dotfiles/logs/installman.log` via `scripts/lib/installman_log.sh` (sourcé ou appelé depuis le script d’installation).

## Utilisation des logs installman

- Fichier : `$DOTFILES_DIR/logs/installman.log`
- Depuis le menu : option **logs** dans installman.
- En ligne de commande : `show_installman_logs` (si la lib est sourcée) ou `tail -f ~/dotfiles/logs/installman.log`.
