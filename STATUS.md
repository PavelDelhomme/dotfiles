# État instantané du projet (dotfiles)

**Dernière mise à jour** : 2026-05-06

## En bref

- **Architecture** : managers sous `core/managers/<nom>/` + adapters `shells/{zsh,bash,fish}/adapters/` ; tests Docker par défaut sur la liste `scripts/test/config/migrated_managers.list`.
- **Socle `dotcli`** : C dans `tools/dotcli/` ; `make build-dotcli` / `make test-dotcli` ; menus pilotés derrière `DOTFILES_DOTCLI_ENABLE=1` (**netman**, **aliaman**, **cyberlearn**) ; mode prudent `DOTFILES_DOTCLI_MENU_NO_TUI=1` ou `dotcli menu --no-tui`.
- **CI** : `make test` (managers + matrice sous-commandes) ; rapports sous `TEST_RESULTS_DIR` inscriptible dans le conteneur.

## Objectifs actuels (priorité)

1. Poursuivre la **normalisation modulaire** et la **TUI unifiée** (`dotcli`) sans casser les fallbacks.
2. Compléter les **tests manuels** : [`docs/TESTS.md`](docs/TESTS.md).
3. Respecter le **jalon de validation** dans [`TODOS.md`](TODOS.md) avant toute bascule structurelle majeure.

## Où lire la suite

| Besoin | Fichier |
|--------|---------|
| Carte de **toute** la documentation | [`docs/DOCUMENTATION_REFERENCE.md`](docs/DOCUMENTATION_REFERENCE.md) |
| Statut **détaillé** (dernière action, résolutions) | [`docs/STATUS.md`](docs/STATUS.md) |
| **Tâches** (en cours, suivantes, validées) | [`TODOS.md`](TODOS.md) |
| **Tests manuels** (checklist) | [`docs/TESTS.md`](docs/TESTS.md) |
| **Erreurs / correctifs** | [`docs/ERRORS.md`](docs/ERRORS.md) |
| Bac à sable Docker | [`scripts/test/SANDBOX.md`](scripts/test/SANDBOX.md) |

---

## Règle de fin de cycle (obligatoire)

Avant de considérer une **tâche finalisée** comme acquise pour enchaîner la suivante (voir `TODOS.md`, section validation) :

1. **Tu valides** explicitement la tâche dans `TODOS.md` (case / tableau).
2. Tu enregistres le travail dans Git : **`git add`**, **`git commit`**, **`git push`** (ou équivalent sur ta branche).

Sans cette validation, la **suite du planning** reste en attente par convention du dépôt.
