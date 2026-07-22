# Disposition cible de la racine `~/dotfiles/`

> Hub : [`../INDEX.md`](../INDEX.md) · Backlog : [`../../TODOS.md`](../../TODOS.md) (P19)

## Objectif

Avoir **peu de fichiers à la racine** : entrée bootstrap, README, STATUS/TODOS, `.env*`, Makefile.
Le reste vit dans des dossiers dédiés (`scripts/`, `core/`, `docs/`, `docker/`, `var/`…).

## Racine cible (essentielle)

| Élément | Rôle |
|---------|------|
| `README.md` | Point d’entrée humain |
| `STATUS.md` / `TODOS.md` | État + backlog (ou liens vers `docs/` plus tard) |
| `Makefile` | Orchestration |
| `bootstrap.sh` | **Reste à la racine** (URL `curl …/bootstrap.sh \| bash`) |
| `.env` / `.env.example` | Secrets / config locale (jamais committer `.env`) |
| `.gitignore` | — |

## Dossiers stables

| Dossier | Contenu |
|---------|---------|
| `core/` | Managers POSIX |
| `shells/` | Adapters zsh/bash/fish |
| `zsh/` `bash/` `fish/` | RC / fonctions shell |
| `shared/` `share/` | Config partagée / menus déclaratifs |
| `scripts/` | Install, test, tools, bootstrap helpers |
| `docs/` | Documentation |
| `systemd/` | Unités user |
| `tools/` | dotcli, ncmenu, … |
| `bin/` | Binaires générés |
| `.github/` | CI |

## Déplacements progressifs (P19)

| Aujourd’hui (racine) | Cible | État |
|----------------------|-------|------|
| `test-docker.sh` | `scripts/test/test_docker.sh` + wrapper racine | en cours |
| `install_zsh_complete.sh` | `scripts/install/install_zsh_complete.sh` + wrapper | en cours |
| `Dockerfile` / `Dockerfile.test` / `docker-compose.yml` | `docker/` (symlinks ou Make mis à jour) | planifié |
| `run/` `images/` `logs/` `test_results/` | `var/run` `var/images` `var/logs` `var/test_results` | planifié |
| `DOTFILES_GOOD/` | fusion après jalon B (P4) puis **suppression** | bloqué tant que B incomplet |
| `zshrc` (sans point) | archive `scripts/legacy/` ou suppression | planifié |
| `.p10k*.zsh` `.gitconfig` | restent ou `config/user/` selon choix | à décider |

## Règles

1. **Ne pas casser** l’URL publique de `bootstrap.sh`.
2. Wrappers racines minces (`#!/bin/sh` → `exec "$DOTFILES_DIR/scripts/..."`) pendant la transition.
3. Mettre à jour **Makefile** + docs à chaque déplacement.
4. `DOTFILES_GOOD/` ne disparaît **qu’après** validation jalon B + migration `shared/env`.

## Tests

Tout déplacement de script de test : rejouer `make test-checks` et smoke Docker concernés.
