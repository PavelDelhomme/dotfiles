# `shared/env/` — variables d’environnement (POSIX)

## Ordre de chargement

Les fichiers `*.sh` sont sourcés par `../lib/bootstrap_posix.sh` dans l’**ordre lexicographique** (`00_`, `01_`, …).

## Migration depuis la prod

- Aujourd’hui, la vérité opérationnelle est encore **`../../shared/env.sh`** (sourcé par `../../shared/config.sh`).
- Migrer **par petits fichiers** ici (ex. `10_xdg.sh`, `20_path_extras.sh`) une fois extraits et testés ; éviter de dupliquer tout `env.sh` d’un coup.
- Ne pas sourcer automatiquement `../../shared/env.sh` depuis ce dossier tant que les effets de bord (messages, dépendances `add_to_path`) ne sont pas audités pour le bac à sable.
