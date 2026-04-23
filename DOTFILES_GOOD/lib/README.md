# `lib/` — amorces et chargeurs

- **`bootstrap_posix.sh`** : point d’entrée POSIX du bac à sable (env → fonctions → aliases).
- Futurs scripts : `path.sh`, détection TTY, etc., **uniquement** s’ils restent POSIX et sans effet de bord sur la prod tant qu’ils ne sont pas référencés depuis `shared/config.sh`.
