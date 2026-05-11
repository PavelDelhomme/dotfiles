# État instantané du projet (dotfiles)

> **Rôle de ce fichier** : version, **objectifs en cours**, **journal récent**. Il n’y a **ni backlog complet** (→ [`TODOS.md`](TODOS.md)) **ni procédure de test** (→ [`docs/TESTS.md`](docs/TESTS.md)) **ni incidents** (→ [`docs/ERRORS.md`](docs/ERRORS.md)). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md).

**Dernière mise à jour** : 2026-05-11

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

1. **Dernière livraison notable** : 2026-05-11 (2) — scission `docs/STRUCTURE.md` → **`STRUCTURE` (carte doc)** + **`CODEMAP.md` (arborescence code)** ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** : `INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`. Mise à jour `INDEX.md` + bandeaux thématiques.
2. **Livraison précédente** : 2026-05-11 (1) — réorganisation doc : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub) et [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel format d’étapes) ; allègement [`docs/TESTS.md`](docs/TESTS.md) ; clarification rôles STATUS / TODOS / ERRORS.
3. **Livraison antérieure** : 2026-05-06 — `dotcli` (TUI, `--no-tui`, dry-run), pilotes netman/aliaman/cyberlearn, modules aliaman/cyberlearn.
4. **À faire maintenant** : section **« En cours »** de [`TODOS.md`](TODOS.md) ; remplir [`docs/TESTS.md`](docs/TESTS.md) (champs `Conforme` / `Assistant (relecture)`) ; garder `make test` vert.
5. **Dernière résolution** : CI phase 2 — `TEST_RESULTS_DIR` inscriptible ; `gitman log` ; installman multi-shell (détails [`docs/ERRORS.md`](docs/ERRORS.md)).

| Période | Sujet |
|---------|--------|
| 2026-05 | dotcli + menus managers |
| 2026-05 | tee RO → `TEST_RESULTS_DIR` hors dépôt |
| 2026-05 | gitman / installman matrice |

---

## Règle de fin de cycle (obligatoire)

Avant de considérer une **tâche finalisée** comme acquise pour enchaîner la suivante (voir `TODOS.md`, section validation) :

1. **Tu valides** explicitement la tâche dans `TODOS.md` (case / tableau).
2. Tu enregistres le travail dans Git : **`git add`**, **`git commit`**, **`git push`** (ou équivalent sur ta branche).

Sans cette validation, la **suite du planning** reste en attente par convention du dépôt.
