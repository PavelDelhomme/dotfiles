# dockerman(1) — vue et aide Docker quotidienne

## Nom

**dockerman** — retrouver et utiliser les commandes Docker sans les mémoriser : état du daemon, listes (conteneurs / images / réseaux / volumes), aide-mémoire, recherche, et nettoyage **dry-run par défaut**.

## Synopsis

```text
dockerman [help | -h | --help | aide]
dockerman menu
dockerman status | doctor | version | context
dockerman ps [all]
dockerman images | networks | volumes | df | stats
dockerman logs <conteneur> [N]
dockerman inspect <id>
dockerman compose [ps | ls | config | file]
dockerman cheat [groupe]
dockerman search <mot>
dockerman explain <commande>
dockerman prefix | sandbox
dockerman prune [--dry-run | --apply] [--yes]
dockerman cmd [--run] -- docker <args>
```

## Description

`dockerman` est le pendant Docker des autres `*man` : **aide lisible**, **vue d’état**, **pas d’action destructive par défaut**.

- `virtman docker` reste le menu virtualisation plus large (QEMU, LXC, …).
- `dockerman` se concentre sur **les commandes `docker` / `docker compose` du quotidien**.
- Les tests du dépôt restent isolés sous le préfixe `dotfiles-test` (`make docker-in`, `bash test-docker.sh --help`).

Sans daemon Docker, `doctor` / `status` / `cheat` fonctionnent quand même (le daemon n’est requis que pour `ps`, `images`, etc.).

## Commandes

| Commande | Effet |
|----------|-------|
| `dockerman help` | Aide stdout (contrat G.x). |
| `dockerman doctor` | Binaire, plugin compose, socket, daemon, groupe `docker`. |
| `dockerman status` | Version + `ps -a` compact + `system df`. |
| `dockerman ps [all]` | `docker ps` ou `docker ps -a`. |
| `dockerman images` | Images locales. |
| `dockerman networks` / `volumes` / `df` / `stats` | Vues lecture. |
| `dockerman logs NAME [N]` | Derniers logs (défaut 100). |
| `dockerman inspect ID` | `docker inspect` (80 premières lignes). |
| `dockerman compose ps\|ls\|config\|file` | Compose **lecture**. Pas de `up`/`down` ici. |
| `dockerman cheat [groupe]` | Aide-mémoire : `all`, `ps`, `run`, `images`, `compose`, `net`, `vol`, `build`, `sys`, `exec`, `sandbox`. |
| `dockerman search MOT` | Grep dans l’aide-mémoire. |
| `dockerman explain CMD` | Fiche du groupe + `docker CMD --help` si disponible. |
| `dockerman prefix` | Conteneurs/images `dotfiles-test*` seulement. |
| `dockerman sandbox` | Rappel `make docker-in` / `test-docker.sh`. |
| `dockerman prune --dry-run` | Liste stopped + dangling, **rien ne supprime**. |
| `dockerman prune --apply` | `docker system prune` après `OUI` (TTY) ou `--yes`. Pas de `-a --volumes`. |
| `dockerman cmd -- docker ps` | Affiche la commande. Ajoute `--run` pour l’exécuter. |

## Groupes `cheat`

| Groupe | Contenu |
|--------|---------|
| `ps` | `ps`, `stats`, `top`, `port` |
| `run` | `run`, `start/stop/rm`, ports, volumes |
| `exec` | `exec`, `logs`, `inspect`, `cp` |
| `images` | `pull/push/rmi/tag/save/load` |
| `build` | `docker build`, BuildKit |
| `compose` | plugin v2 `docker compose …` |
| `net` / `vol` | réseaux et volumes |
| `sys` | `version`, `info`, `system df/prune`, `login` |
| `sandbox` | commandes Make / préfixe tests |

## Sécurité

- Timeout par commande daemon : `DOCKERMAN_TIMEOUT` (défaut **8** s).
- `prune` est **dry-run** si tu omets `--apply`.
- `--apply` hors TTY exige `--yes`.
- `compose up/down` et `run` **ne sont pas** lancés par le manager : ils sont documentés (`cheat` / `explain`) pour que tu les tapes toi-même.
- `cmd` n’exécute rien sans `--run`.
- Le préfixe `dotfiles-test` isole les images de test ; `bash test-docker.sh --clean` ne touche **que** ce préfixe.

## Exemples

```bash
dockerman help
dockerman doctor
dockerman cheat run
dockerman search compose
dockerman explain prune
dockerman ps all
dockerman prefix
dockerman prune --dry-run
dockerman cmd -- docker ps -a
dockerman cmd --run -- docker ps
```

## Fichiers

- Core : `core/managers/dockerman/core/dockerman.sh`
- Adaptateurs : `shells/{zsh,bash,fish}/adapters/dockerman.*`
- Tests : `scripts/test/subcommands/dockerman.list`
- Guide Docker dépôt : [`docs/guides/DOCKER.md`](../guides/DOCKER.md)

## Voir aussi

`docker(1)`, `docker-compose(1)`, `virtman`, `diskman`, `installman docker`, `manman`, `helpman`, `make docker-in`.
