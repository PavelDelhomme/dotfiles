# Complétions Zsh / Bash / Fish (dotfiles)

## Zsh (`zsh/completions/`)

Ajouté au `fpath` dans `zshrc_custom` **avant** `compinit`.

| Fichier | Rôle |
|---------|------|
| `_make` | Cibles Makefile |
| `_dfm` | Menus `share/menus/*.menu` |
| **`_dotfiles_mans`** | Sous-commandes de tous les `*man` (+ `dfm`) |

Données : [`share/completions/mans.conf`](../../share/completions/mans.conf).

Recharger après ajout : `rm -f "${ZSH_COMPDUMP:-$HOME/.cache/zsh/zcompdump-*}" && exec zsh`  
Puis : `netman <Tab>` → `dig`, `lookup`, …

## Bash (`bash/completions/`)

Sourcé depuis `bash/bashrc_custom` :

- `dotfiles_mans.sh` — `complete -F` pour chaque entrée de `mans.conf`

## Fish (`fish/completions/`)

Sourcé depuis `fish/config_custom.fish` :

- `dotfiles_mans.fish` — `complete -c` par manager

Optionnel : symlink vers `~/.config/fish/completions/dotfiles_mans.fish` si tu n’utilises pas `config_custom.fish`.

## sh (POSIX)

Pas de système de complétion standard. Utiliser bash/zsh/fish, ou `netman help` / `helpman <man>`.

## Ajouter / mettre à jour des sous-commandes

1. Éditer **`share/completions/mans.conf`** : `commande:sous1 sous2 …`
2. Recharger le shell (zsh : invalider le dump compinit).
3. Pas besoin de retoucher les scripts zsh/bash/fish (ils lisent le conf).
