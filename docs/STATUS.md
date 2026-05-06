# Suivi détaillé du projet (dotfiles)

> **Référence** : [`DOCUMENTATION_REFERENCE.md`](DOCUMENTATION_REFERENCE.md) · **Vue instantanée** : `STATUS.md` à la racine · **Tâches** : `TODOS.md` à la racine

Ce fichier suit l’**ordre suivant** (mis à jour quand une étape significative est faite ou résolue).

---

## 1. Dernière chose réalisée (travail / livraison)

- **2026-05-06** — Socle **`dotcli`** : menu TUI (surlignage, flèches / j k), `--no-tui`, `--dry-run`, `--simulate-index` ; intégration **netman** / **aliaman** / **cyberlearn** derrière `DOTFILES_DOTCLI_ENABLE` ; correctif menu **ports** (touche `g`) ; modules **aliaman** (`alias_crud`) et **cyberlearn** (`courses_menu`, `labs_menu`, `progress_menu`) ; documentation roadmap / contrat menu ; `.gitignore` pour `bin/dotcli` et `run/artifacts/home-import/`.

---

## 2. À faire maintenant (priorité immédiate)

- Lire **`TODOS.md`** (racine), section **« En cours »** : c’est la source de vérité opérationnelle.
- En parallèle : remplir / exécuter **[`TESTS.md`](TESTS.md)** pour les parcours **docker-in** + **dotcli** (TTY et `DOTFILES_DOTCLI_MENU_NO_TUI=1`).
- Maintenir **`make test`** vert lors des changements de managers ou de `scripts/test/subcommands/*.list`.

---

## 3. Dernière chose résolue et fermée (hors travail en cours)

- **CI Docker phase 2** : écriture `TEST_RESULTS_DIR` hors dépôt RO ; **gitman log** sans pager ; **installman** aide alignée multi-shell (voir [`ERRORS.md`](ERRORS.md)).

---

## 4. Journal des résolutions (du plus récent au plus ancien)

| Date (approx.) | Sujet | Résumé |
|----------------|--------|--------|
| 2026-05 | dotcli + menus managers | Feature flag, fallbacks, tests Makefile |
| 2026-05 | tee RO filesystem | `TEST_RESULTS_DIR` → `/root/test_results` ou `/tmp/...` |
| 2026-05 | gitman / installman matrice | Voir tableau dans [`ERRORS.md`](ERRORS.md) |

*(Ajouter des lignes au-dessus de ce tableau pour chaque résolution notable.)*

---

## 5. État architectural (rappel court)

- **Cible** : `core/managers/<nom>/` (POSIX) + `shells/{zsh,bash,fish}/adapters/`.
- **Liste managers testés Docker par défaut** : `scripts/test/config/migrated_managers.list`.
- **Analyse longue d’arborescence** : [`STRUCTURE_ANALYSIS.md`](STRUCTURE_ANALYSIS.md).
- **Historique refactor** : [`REFACTOR_HISTORY.md`](REFACTOR_HISTORY.md).

---

## 6. Phases migration (vue condensée)

Le détail des phases 0–5, listes de managers et métriques **historiques** volumineuses ont été déplacées vers la **vue synthétique** ci-dessus et vers **`docs/migrations/`** + **`REFACTOR_HISTORY.md`** pour limiter la duplication avec **`TODOS.md`**.

Si tu réintroduis une checklist de phase longue ici, synchronise obligatoirement **`TODOS.md`** pour éviter deux sources divergentes.
