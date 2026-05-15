# diffman(1) — comparaison de fichiers

## Nom

**diffman** — diff unifié coloré, côte à côte, rapports multi-fichiers.

## Synopsis

```text
diffman [help | -h | --help]
diffman compare [--side] [--width N] [--no-git] FICHIER_A FICHIER_B
diffman side [opts] FICHIER_A FICHIER_B
diffman report [--out FILE] [--all-pairs] [--base REF] F1 F2 [F3 …]
diffman diff3 FICHIER_A FICHIER_B FICHIER_C
```

## Description

`diffman` encapsule `git diff --no-index` (couleurs ANSI) ou, à défaut, `diff` GNU avec `--color=always`. Le mode **side** utilise `diff -y` (deux colonnes). Le mode **report** concatène plusieurs diffs dans un fichier ou sur stdout.

## Codes de retour

- **compare** / **side** : `0` fichiers identiques, `1` différences, `2` erreur (fichier manquant, option invalide).
- **report** : `0` si le rapport a été produit.
- **diff3** : code de `diff3(1)`.

## Variables d'environnement

| Variable | Effet |
|----------|--------|
| `NO_COLOR` | Désactive les couleurs. |
| `FORCE_COLOR=1` | Colore la sortie même si stdout n'est pas un TTY. |
| `DOTFILES_DIR` | Racine des dotfiles (logs managers). |

## Fichiers

- Core : `core/managers/diffman/core/diffman.sh`
- Adaptateurs : `shells/{zsh,bash,fish}/adapters/diffman.*`

## Voir aussi

`diff(1)`, `git-diff(1)`, `diff3(1)`, `docs/guides/MANAGERS.md`.
