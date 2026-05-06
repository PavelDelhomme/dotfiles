# TODOS — Roadmap et actions (dotfiles)

> **Index doc** : [`docs/STRUCTURE.md`](docs/STRUCTURE.md) · **Statut instantané** : [`STATUS.md`](STATUS.md) (racine) · **Tests manuels** : [`docs/TESTS.md`](docs/TESTS.md) · **Erreurs** : [`docs/ERRORS.md`](docs/ERRORS.md)

---

## Règle de passage (obligatoire)

1. Toute tâche figurant dans **« Finalisées — en attente de validation par moi »** doit être **explicitement validée** (case cochée ou ligne signée) **par toi** avant de traiter les tâches suivantes comme définitivement closes.
2. **Quoi qu’il en coûte** : sans cette validation, on **ne fait pas** comme si la suite du backlog était débloquée sur ce point.
3. À chaque validation (ou fin de lot livré) : **`git add`**, **`git commit`**, **`git push`** pour figer l’état dans l’historique Git.

---

## En cours (lot / tâche actuelle)

- [ ] Exécuter et remplir **[`docs/TESTS.md`](docs/TESTS.md)** pour : installation neutre (ou `docker-in`), **`dotcli`** (TTY + `DOTFILES_DOTCLI_MENU_NO_TUI=1`), et smoke **`help`** pour chaque manager de `migrated_managers.list`.
- [ ] Poursuivre **P1** : normalisation `core/managers/` + adapters ; réduction de la logique résiduelle hors core ; convergence menus vers `dotcli` avec fallbacks.

---

## Dernière tâche terminée (juste avant l’actuelle)

- [x] Réorganisation **`docs/`** par thèmes (sous-dossiers) + racine `docs/` = **`STRUCTURE` / `TESTS` / `ERRORS`** + journal dans **`STATUS.md`** racine.

---

## À faire ensuite (ordre logique)

| Prio | Tâche | Détail |
|------|--------|--------|
| **P1** | Normalisation architecture modulaire | Homogénéiser `core/managers/<nom>/` + adapters ; réduire `zsh/functions/` métier ; monolithes → modules. |
| **P2** | Domaine réseau | Cartographier `zsh/functions/commands/network/*` → `netman` ou commandes transverses. |
| **P3** | TUI mutualisée | `dotcli menu` + fallbacks (`ncmenu`, `fzf`, `read`) sans casser CI. |
| **P4** | `shared/env.sh` → morceaux `DOTFILES_GOOD` | Voir phases historiques ; migration après jalon B si besoin. |
| **P5** | **Épic installman** | [`docs/managers/INSTALLMAN_VISION.md`](docs/managers/INSTALLMAN_VISION.md) — par étapes. |
| **P6** | Niveau 2 tests | Assertions métier (golden / grep) pour N managers pilotes. |
| **P7** | `read` / `clear` hors TTY | Réduire blocages CI / scripts. |

### Phases A → B → C (rappel)

| Phase | Nom | Contenu |
|-------|-----|--------|
| **A** | Préparatif | `DOTFILES_GOOD/`, `make test-dotfiles-good`, `make test`, inventaire couverture (voir aussi **`docs/TESTS.md`**). |
| **B** | Jalon validation | **Toi** : usage réel + cases § *Jalon* ci-dessous. |
| **C** | Bascule racine | **Uniquement après B** + backup + plan écrit. |

---

## Phase A — tests (rappel)

- **Oui (CI)** : présence fichiers, syntaxe, chargement, lignes `scripts/test/subcommands/*.list`, exit code, timeout.
- **Non (souvent)** : comportement métier complet, sorties exactes → **`docs/TESTS.md`**.

Cases qualité :

- [ ] Définir **niveau 2** : 1–2 sous-commandes pilotes avec **assertion** stdout/stderr/fichier.
- [x] Documenter smoke vs métier : `make test-help`, `SANDBOX.md`.
- [ ] (Optionnel) `scripts/test/expected/...`

### Phase A — déjà livré (extraits)

- [x] Bac `DOTFILES_GOOD/` + `make test-dotfiles-good`.
- [x] Extraits `DOTFILES_GOOD/shared/env/` + README.
- [x] `make docker-in` (distros, `DOCKER_*` dans Makefile).
- [x] `TEST_RESULTS_DIR` inscriptible ; **gitman log** ; **installman** core POSIX sur zsh/bash ; phase 2 ignore shells absents (voir [`docs/ERRORS.md`](docs/ERRORS.md)).

---

## Jalon « DOTFILES_GOOD validé » (phase **B**) — *bloquant pour C*

Cocher quand **toi** tu es satisfait :

- [ ] `make test-dotfiles-good` OK (ta machine, dernière branche).
- [ ] `make test` (Docker) OK.
- [ ] Session réelle avec bootstrap `DOTFILES_GOOD` sans casse bloquante.
- [ ] Décision notée : brancher `shared/config.sh` / entrées shell **oui / non / plus tard**.

> Tant que ce bloc n’est pas validé, la **phase C** reste **documentation uniquement**.

---

## Phase **C** — Bascule racine (après B)

- [ ] Backup complet du dépôt ailleurs.
- [ ] Plan écrit des déplacements / symlinks.
- [ ] Exécution + `make test` + login shell.
- [ ] Procédure rollback testée « à froid ».

---

## Roadmap technique (cases courantes)

- [x] Bac à sable `DOTFILES_GOOD/` + tests associés.
- [x] Tableau managers [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) + `migrated_managers.list`.
- [x] MVP **`dotcli`** + `make test-dotcli`.
- [x] Pilotes dotcli sur **netman** / **aliaman** / **cyberlearn** (flag).
- [ ] TUI mutualisée complète ; **`@skip`** phase 2 à réduire pour menus si invocations non-TTY ajoutées.
- [ ] installman vers `core/` définitif ; **read/clear** hors TTY.
- [ ] **`make test`** vert à chaque étape.
- [ ] Fallback visuel multi-shell (dégradation ASCII).

### Transformation globale (fil directeur)

- [ ] Arborescence cible finale + règles de placement strictes.
- [ ] Contrat unique menus/TUI + fallback non-interactif.
- [ ] Installation « nouvelle machine » guidée + silencieuse.
- [ ] Migration progressive + checkpoints tests.

---

## Produit : `infosman` ?

- [ ] Décision : extension **`searchman info …`** *ou* **`infosman`** (justifier dans [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md)).

---

## Docker `docker-in` — variables (Makefile)

| Variable | Défaut | Rôle |
|----------|--------|------|
| `DOCKER_DOTFILES_DIR` | `/root/dotfiles` | Aligné sur le montage volume. |
| `DOCKER_INSTALLMAN_ASSUME` | `1` | `INSTALLMAN_ASSUME_YES` si `1`. |
| `DOCKER_SHELL` | *(vide)* | Menu shell si TTY. |
| `DOCKER_DISTRO` | *(vide)* | `arch`, `ubuntu`, `debian`, etc. |

Exemples : `make docker-in DOCKER_DISTRO=debian` · `make docker-in DOCKER_SHELL=fish`

---

## Suivi `tail -f` (logs)

`tail -f test_results/test_output.log` : `Ctrl+C` n’arrête que le tail.

## Menu `make tests`

Pause max 5 s par défaut ; `DOTFILES_TEST_MENU_SKIP_PAUSE=1` pour supprimer les pauses.

---

## Finalisées — en attente de validation par moi (**bloquant**)

| ID | Description | Validé par moi |
|----|----------------|----------------|
| V-2026-05-dotcli-doc | Lot dotcli + modules aliaman/cyberlearn ; doc : `docs/STRUCTURE` + `TESTS` + `ERRORS` ; STATUS/TODOS **uniquement racine** | [ ] |
| V-2026-05-doc-suite | Suite doc : bannières, SANDBOX/README, DOTCLI_MENU_CONTRACT, `STRUCTURE_ANALYSIS` → `docs/architecture/` | [ ] |
| V-2026-05-docs-tree | Arborescence `docs/` : 3 fichiers racine + dossiers `architecture/`, `guides/`, etc. | [ ] |

> **Tant qu’une ligne ci-dessus n’est pas cochée**, considérer que ce lot n’est pas « officiellement » refermé pour enchaîner une nouvelle vague de tâches dépendantes.

---

## Finalisées — validées par moi (plus récent en haut)

*(Déplacer ici les lignes du tableau « attente de validation » une fois cochées, avec date.)*

- *(vide)*

---

## Rappel final — Git

Avant de passer à la **tâche suivante** après une finalisation : **`git add -A`** (ou ciblé), **`git commit`**, **`git push`**.
