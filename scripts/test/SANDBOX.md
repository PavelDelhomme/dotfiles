# Bac à sable tests dotfiles (Docker)

Ce fichier est dans le dépôt : dans un conteneur, il est visible sous  
`/root/dotfiles/scripts/test/SANDBOX.md` (montage en lecture seule par défaut).

## Objectif

Lancer les managers et la matrice de sous-commandes **sans toucher** à ta machine : tout s’exécute dans l’image `dotfiles-test` avec les dotfiles montés en **RO**.

## Commandes essentielles (sur l’hôte)

| Action | Commande |
|--------|----------|
| Aide variables + flux | `make test-help` |
| Tests managers (Docker) | `make test` |
| Un sous-ensemble de managers | `DOTFILES_TEST_MANAGERS=pathman,installman make test` |
| Équivalent explicite | `TEST_MANAGERS="pathman installman" make test` |
| Shells uniquement zsh | `TEST_SHELLS=zsh make test` |
| Matrice sous-commandes | `make test-subcommands` |
| Même filtre managers | `DOTFILES_TEST_MANAGERS=searchman,pathman make test-subcommands` |
| Copie du dépôt dans `/tmp` puis test (pas de bind direct sur ton arbre) | `TEST_DOTFILES_ISOLATE=1 make test` |
| Shell interactif dans le conteneur | `make docker-in` puis `DOCKER_SHELL=bash make docker-in` |
| Menu tests expliqué | `make tests` |

`DOTFILES_TEST_MANAGERS` accepte **virgules ou espaces**. Si `TEST_MANAGERS` est déjà défini, il **prime** sur `DOTFILES_TEST_MANAGERS`.

Fichier d’options persistant (non versionné) :  
`cp scripts/test/config/test.local.env.example scripts/test/config/test.local.env`

## Dans le conteneur (« sandbox live »)

Après `make docker-in` (ou équivalent) :

- `DOTFILES_DIR` vaut en général `/root/dotfiles` (dépôt monté).
- Recharger Zsh : `source /root/dotfiles/zsh/zshrc_custom`
- Tester un manager : `pathman help`, `installman help`, etc.
- Tests auto dans le conteneur (si tu copies les scripts) :  
  `bash /root/dotfiles/scripts/test/docker/run_tests.sh`
- Guide Makefile depuis le conteneur : `make -C /root/dotfiles test-help` (si `make` est installé dans l’image).

## Migration POSIX (voir `docs/ACTION_PLAN_ARCHITECTURE.md`)

Les cores partagés vivent sous `core/managers/<nom>/core/<nom>.sh` ; les adaptateurs sous `shells/*/adapters/`. La liste utilisée par défaut pour les tests Docker est `scripts/test/config/migrated_managers.list`.
