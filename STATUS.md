# État instantané du projet (dotfiles)

> **Rôle de ce fichier** : version, **objectifs en cours**, **journal récent**. Il n’y a **ni backlog complet** (→ [`TODOS.md`](TODOS.md)) **ni procédure de test** (→ [`docs/TESTS.md`](docs/TESTS.md)) **ni incidents** (→ [`docs/ERRORS.md`](docs/ERRORS.md)). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md).

**Dernière mise à jour** : 2026-05-12

## En bref

- **Architecture** : managers sous `core/managers/<nom>/` + adapters `shells/{zsh,bash,fish}/adapters/` ; tests Docker par défaut sur la liste `scripts/test/config/migrated_managers.list`.
- **Socle `dotcli`** : C dans `tools/dotcli/` ; `make build-dotcli` / `make test-dotcli` ; menus pilotés derrière `DOTFILES_DOTCLI_ENABLE=1` (**netman**, **aliaman**, **cyberlearn**) ; mode prudent `DOTFILES_DOTCLI_MENU_NO_TUI=1` ou `dotcli menu --no-tui`.
- **CI** : `make test` (managers + matrice sous-commandes) ; rapports sous `TEST_RESULTS_DIR` inscriptible dans le conteneur.

## Objectifs actuels (priorité)

1. Poursuivre la **normalisation modulaire** et la **TUI unifiée** (`dotcli`) sans casser les fallbacks.
2. Compléter les **tests manuels** : [`docs/TESTS.md`](docs/TESTS.md) — entrée menu `make tests-start`.
3. Respecter le **jalon de validation** dans [`TODOS.md`](TODOS.md) avant toute bascule structurelle majeure.

## Où lire la suite

> **Hub doc** : [`docs/INDEX.md`](docs/INDEX.md) — un seul point d’entrée pour savoir **où aller pour quoi**.

| Besoin | Fichier |
|--------|---------|
| **Hub** — quel doc pour quel besoin | [`docs/INDEX.md`](docs/INDEX.md) |
| **Format des étapes** (Conforme `O·N·NA`, Notes, Assistant…) | [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) |
| **Tâches** (lots, ordre, validation bloquante) | [`TODOS.md`](TODOS.md) |
| **Tests manuels** (checklist) | [`docs/TESTS.md`](docs/TESTS.md) |
| **Erreurs / correctifs** | [`docs/ERRORS.md`](docs/ERRORS.md) |
| **Carte technique** (arborescence) | [`docs/STRUCTURE.md`](docs/STRUCTURE.md) |
| Bac à sable Docker | [`scripts/test/SANDBOX.md`](scripts/test/SANDBOX.md) |

---

## Journal récent (suivi détaillé)

1. **Dernière livraison notable (2026-05-12)** — lot **« cohérence CLI + UX terminal »** :
   - **Convention aide/CLI unifiée** sur tous les `*man` : `manager` / `help` / `-h` / `aide` → aide stdout non-interactive ; `help --interactive` → aide détaillée + pause si TTY ; `--help` → aide + pause + menu interactif (TTY) ou exit (non-TTY) ; **arg inconnu** → erreur stderr + `rc ≠ 0` (fin des **boucles infinies** type `aliaman --` corrigées sur `aliaman`, `cyberman`, `pathman`, `multimediaman`, `cyberlearn`, etc.).
   - **`core/utils/progress_bar.sh` adaptatif** : `\r` en TTY interactif, ligne par mise à jour en non-TTY (pipe, log, terminal IDE) → plus de réécriture sale. Variable `DOTFILES_PROGRESS_PLAIN=1` pour forcer le mode ligne.
   - **`shared/functions/lsblk_color.sh`** : wrapper `lsblk` colorisant la sortie par TYPE (gras+cyan pour `disk`, vert pour `part`, gris pour `loop`, etc.) en TTY ; passe-plat automatique hors TTY ou avec options machine (`-J/-P/-r/-n/-o/-O`). Chargé via `shared/config.sh` pour sh/bash/zsh.
   - **CI GitHub Actions** : guide [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md) (correctif `dawidd6/action-send-mail` : pas de `content_type`, secret `EMAIL_FROM` obligatoire ou job `if:`) ; workflow [`.github/workflows/ci-checks.yml`](.github/workflows/ci-checks.yml) (`make test-checks` sur Ubuntu). Roadmap CI complète → **`TODOS.md` P8**.
   - **TESTS.md Blocs A → F.5** validés (verdicts `O` posés + relectures) ; Bloc G étendu aux 23 managers (G.0 + G.0.b reproducteur `aliaman --` + G.0.c smoke `aliaman search/list`) ; F.6 réécrit (l’ancienne consigne « pipe + TUI » était contradictoire).
   - **Jalon B avance** : 2/4 cases couvertes par TESTS.md E.2 (`make test-dotfiles-good : OK`) et E.3 (`make test : 69/69 cellules OK`). Restent à valider : *session réelle bootstrap DOTFILES_GOOD* + *décision branchement entrées shell*.
2. **Livraison 2026-05-11 (2)** — scission `docs/STRUCTURE.md` → **`STRUCTURE` (carte doc)** + **`CODEMAP.md` (arborescence code)** ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** : `INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`. Mise à jour `INDEX.md` + bandeaux thématiques.
3. **Livraison 2026-05-11 (1)** — réorganisation doc : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub) et [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel format d’étapes) ; allègement [`docs/TESTS.md`](docs/TESTS.md) ; clarification rôles STATUS / TODOS / ERRORS.
4. **Livraison 2026-05-06** — `dotcli` (TUI, `--no-tui`, dry-run), pilotes netman/aliaman/cyberlearn, modules aliaman/cyberlearn.
5. **À faire maintenant** : finir [`docs/TESTS.md`](docs/TESTS.md) — Blocs F.6 → I (puis cocher Jalon B au § correspondant de `TODOS.md`) ; valider les lignes « En attente de validation » du 2026-05-12 ; en parallèle ou après : brancher / corriger les workflows GitHub (voir [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md), **P8** dans `TODOS.md`).

| Période | Sujet |
|---------|--------|
| 2026-05-12 | CI GitHub : `ci-checks.yml` + guide GITHUB_ACTIONS (e-mail / secrets) |
| 2026-05-12 | convention aide/CLI unifiée (`*man`) + fix boucles arg inconnu |
| 2026-05-12 | progress_bar adaptatif TTY / non-TTY |
| 2026-05-12 | wrapper `lsblk` colorisé (POSIX, auto-disable hors TTY) |
| 2026-05 | dotcli + menus managers |
| 2026-05 | tee RO → `TEST_RESULTS_DIR` hors dépôt |
| 2026-05 | gitman / installman matrice |

---

## Règle de fin de cycle (obligatoire)

Avant de considérer une **tâche finalisée** comme acquise pour enchaîner la suivante (voir `TODOS.md`, section validation) :

1. **Tu valides** explicitement la tâche dans `TODOS.md` (case / tableau).
2. Tu enregistres le travail dans Git : **`git add`**, **`git commit`**, **`git push`** (ou équivalent sur ta branche).

Sans cette validation, la **suite du planning** reste en attente par convention du dépôt.
