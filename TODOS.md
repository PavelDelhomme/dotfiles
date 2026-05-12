# TODOS — Roadmap et actions (dotfiles)

> **Rôle de ce fichier** : **toutes les tâches** — en cours, à faire, finalisées (en attente de validation bloquante / validées). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md). Pour le **format d’une étape** (cases, `Conforme`, Notes, Assistant…) : [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md).
>
> **Liens connexes** : statut instantané [`STATUS.md`](STATUS.md) · tests manuels [`docs/TESTS.md`](docs/TESTS.md) · incidents [`docs/ERRORS.md`](docs/ERRORS.md) · carte technique [`docs/STRUCTURE.md`](docs/STRUCTURE.md).

---

## Règle de passage (obligatoire)

1. Toute tâche figurant dans **« Finalisées — en attente de validation par moi »** doit être **explicitement validée** (case cochée ou ligne signée) **par toi** avant de traiter les tâches suivantes comme définitivement closes.
2. **Quoi qu’il en coûte** : sans cette validation, on **ne fait pas** comme si la suite du backlog était débloquée sur ce point.
3. À chaque validation (ou fin de lot livré) : **`git add`**, **`git commit`**, **`git push`** pour figer l’état dans l’historique Git.

---

## En cours (lot / tâche actuelle)

- [~] Exécuter et remplir **[`docs/TESTS.md`](docs/TESTS.md)** (procédure ordonnée + cases à cocher) ; menu d’appui : **`make tests-start`**.
  - **Avancement 2026-05-12** : Blocs **A**, **B**, **C**, **D**, **E**, **F.1 → F.5** validés (verdicts `O` + relectures). **Reste** : **F.6** (`--no-tui` / `--query`), **F.7** (manager + `DOTFILES_DOTCLI_ENABLE=1` en TTY), **Bloc G** (préalable + G.0/G.0.b/G.0.c + tableau G.1–G.23), **H** (matrice variables), **I** (synthèse + cocher cases Jalon B).
- [ ] Poursuivre **P1** : normalisation `core/managers/` + adapters ; réduction de la logique résiduelle hors core ; convergence menus vers `dotcli` avec fallbacks.

---

## Dernière tâche terminée (juste avant l’actuelle)

- [x] Réorganisation doc 3 : scission **`docs/STRUCTURE.md`** → carte doc + **`docs/CODEMAP.md`** (arborescence code) ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** (`INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`).
- [x] Réorganisation doc 2 : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub navigation) + [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel champs O·N·NA / Assistant relecture) ; allègement de **`docs/TESTS.md`** (renvoie à la légende) ; clarification rôles **STATUS / TODOS / ERRORS**.
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

- [~] `make test-dotfiles-good` OK (ta machine, dernière branche). *— vérifié via `docs/TESTS.md` § E.2 (2026-05-12 = `O`) ; coche définitivement après ta relecture finale de TESTS.md.*
- [~] `make test` (Docker) OK. *— vérifié via `docs/TESTS.md` § E.3 (2026-05-12 = `O`, **69/69 cellules**, 352 tests, 0 échec) ; coche définitivement après ta relecture finale.*
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
| V-2026-05-tests-start | Procédure `docs/TESTS.md` réécrite (A–I, champs O·N·NA + Assistant relecture) + cible `make tests-start` + menu `scripts/test/tests_manual_start.sh`. | [ ] |
| V-2026-05-doc-index | Hub [`docs/INDEX.md`](docs/INDEX.md) + référentiel [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) ; renvois harmonisés (STATUS / TODOS / ERRORS / STRUCTURE / TESTS / README). | [ ] |
| V-2026-05-doc-split | Scission `STRUCTURE.md` → `STRUCTURE.md` (carte doc) + `CODEMAP.md` (arbo code) ; `README.md` allégé (~82 lignes) ; guides utilisateur dans `docs/guides/` (`INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`). | [ ] |
| V-2026-05-12-cli-help | **Convention aide/CLI unifiée** sur tous les `*man` (stdout sans arg / `help` / `-h` / `aide` ; `help --interactive` = aide + pause TTY ; `--help` = aide + pause + menu interactif ; arg inconnu → stderr + `rc≠0`). Corrige les boucles `aliaman --` / `pathman --bogus` / etc. **Couverture** : `aliaman`, `cyberman`, `pathman`, `multimediaman`, `cyberlearn`, `helpman`, `gitman`, `miscman`, `routeman`, `processman`, `devman`, `virtman`, `searchman`, `testzshman`, `testman`, `fileman`, `sshman`. Tests : `docs/TESTS.md` Bloc G (préalable + G.0 + G.0.b + G.0.c). | [ ] |
| V-2026-05-12-progress | **`core/utils/progress_bar.sh` adaptatif** : `\r` en TTY interactif, ligne par mise à jour en non-TTY (pipe, log, terminal IDE Cursor). Variable `DOTFILES_PROGRESS_PLAIN=1` pour forcer le mode ligne. Plus de réécriture sale dans les logs / `tee` / capture terminal. | [ ] |
| V-2026-05-12-lsblk | **`shared/functions/lsblk_color.sh`** : wrapper `lsblk` colorisant la sortie par TYPE (gras+cyan `disk`, vert `part`, gris `loop`, jaune `raid`, magenta `crypt/lvm/dm`, rouge `rom/tape`). Passe-plat automatique hors TTY ou sur options machine (`-J/-P/-r/-n/-o/-O/-H/--filter/--tree=…/-V`). Forçage : `DOTFILES_LSBLK_FORCE_COLOR=1`. Échappatoire : `DOTFILES_LSBLK_NOCOLOR=1` ou `NO_COLOR`. Chargé via `shared/config.sh` (sh/bash/zsh). | [ ] |
| V-2026-05-12-tests-progress | **`docs/TESTS.md` avancée** : Blocs **A → F.5** validés (verdicts `O` + relectures) ; Bloc **G** étendu aux 23 managers (G.0 + G.0.b reproducteur bug `aliaman --` + G.0.c smoke `aliaman search/list`) ; Bloc **F.6** réécrit (`--no-tui` / `--query` testables + clarification *vrai TUI = F.7*) ; § 12 EXT-002 (petits écrans) + EXT-003 (couleurs ANSI conditionnelles). **2/4 cases Jalon B couvertes** (E.2 + E.3). | [ ] |

> **Tant qu’une ligne ci-dessus n’est pas cochée**, considérer que ce lot n’est pas « officiellement » refermé pour enchaîner une nouvelle vague de tâches dépendantes.

---

## Finalisées — validées par moi (plus récent en haut)

*(Déplacer ici les lignes du tableau « attente de validation » une fois cochées, avec date.)*

- *(vide)*

---

## Rappel final — Git

Avant de passer à la **tâche suivante** après une finalisation : **`git add -A`** (ou ciblé), **`git commit`**, **`git push`**.
