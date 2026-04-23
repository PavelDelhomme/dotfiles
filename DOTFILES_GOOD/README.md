# DOTFILES_GOOD — bac à sable d’architecture (additif)

Ce répertoire est **expérimental** : il prépare une arborescence plus lisible **sans déplacer ni supprimer** le dépôt `dotfiles/` actuellement utilisé sur ta machine.

## Principes

1. **Zéro impact** sur `~/.zshrc`, `zsh/zshrc_custom`, `shared/config.sh`, etc., tant que tu ne choisis pas explicitement d’y brancher ces chemins.
2. **Noyau POSIX** : la logique réutilisable pour Bash, Zsh, `sh` vit dans `lib/bootstrap_posix.sh` et dans `shared/env/*.sh`, `shared/functions/*.sh`, `shared/aliases.sh` **à l’intérieur de ce bac à sable** (copies ou extraits progressifs depuis la racine du dépôt).
3. **Fish** : pas de sourcing direct des fichiers Zsh ; l’entrée reste `~/.config/fish/config.fish` (ou équivalent) avec un bloc qui appelle le POSIX via `bash` si besoin — voir `snippets/`.
4. **Menus / TUI** : données ou fragments non shell-spécifiques pourront aller dans `shared/menus/` ; le code interactif restera dans `core/` ou scripts dédiés.

## Arborescence prévue

| Élément | Rôle |
|--------|------|
| `lib/bootstrap_posix.sh` | Ordre de chargement POSIX (env → fonctions → aliases) pour ce bac à sable uniquement. |
| `shared/env/` | Variables et chemins (`00_*.sh`, …) migrés progressivement depuis `shared/env.sh` / équivalents. |
| `shared/functions/` | Fonctions `.sh` POSIX communes. |
| `shared/menus/` | Textes, listes, gabarits de menus (non sourcés automatiquement au démarrage). |
| `shared/aliases.sh` | Alias POSIX ; commencer vide ou aligné plus tard sur `../shared/aliases.sh`. |
| `core/` | Placeholder : la vérité des managers reste aujourd’hui dans `../core/managers/`. |
| `images/` | Assets statiques éventuels. |
| `run/` | Fichiers runtime (gitignore local ; le motif `logs/` à la racine du dépôt ignorait `DOTFILES_GOOD/logs/`). |
| `config/` | Modèles / snippets de configuration applicative (hors shell). |
| `snippets/` | **Exemples** de fins de `.zshrc` / `.bashrc` / fish — documentation, pas des installateurs. |

## Tests

```bash
make test-dotfiles-good
```

Smoke : syntaxe `sh -n` + sourcing unique du bootstrap dans un sous-shell.

**Sourcing manuel** : exporter `DOTFILES_DIR` vers la racine du clone **avant** le `.`, car avec `source` / `.` le paramètre `$0` ne pointe pas vers `bootstrap_posix.sh` (comportement shell) — le bootstrap utilise donc `DOTFILES_DIR` ou `$HOME/dotfiles/DOTFILES_GOOD`.

## Migration (plus tard)

Quand une brique sera validée (ex. un `00_paths.sh` aligné sur `dotfiles_roots.sh`), on pourra **référencer** le fichier historique ou le remplacer par un lien symbolique **uniquement** après test Docker + usage quotidien.
