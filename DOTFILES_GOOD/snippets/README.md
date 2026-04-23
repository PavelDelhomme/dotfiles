# Snippets — entrées shell **minces** (documentation)

Objectif : **une logique POSIX commune**, puis **uniquement** le spécifique au shell (Zsh : complétions, prompt ; Fish : syntaxe native ; Bash : `shopt`, etc.).

## Zsh (exemple de chaîne cible, non appliqué par défaut)

1. Sourcer le bootstrap POSIX du bac à sable **ou** le `shared/config.sh` historique du dépôt (une seule source de vérité à choisir lors de la migration).
2. Sourcer `zsh/zshrc_custom` pour tout ce qui est **vraiment** Zsh.

## Bash

1. Même bootstrap POSIX (ou `shared/config.sh`).
2. `bash/bashrc_custom` pour le spécifique Bash.

## Fish

Fish ne peut pas `.` un script Zsh. Pattern courant : dans `config.fish`, appeler `bash -c 'source …/bootstrap_posix.sh'` si tu dois réutiliser du POSIX, **ou** dupliquer uniquement les `set -gx` nécessaires en fish, en visant à générer / partager les listes depuis `shared/env` (fichiers clé=valeur) plus tard.

Les fichiers `*.snippet.*` dans ce dossier sont des **modèles** commentés ; ne les symlink pas vers `$HOME` sans relecture.
