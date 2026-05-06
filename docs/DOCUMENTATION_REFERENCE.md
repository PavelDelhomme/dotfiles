# Référence — cartographie de la documentation

_Index canonique du dossier `docs/` : point d’entrée pour humains et agents._

**Fichier maître** : ce document décrit *où* trouver quoi. Les agents et contributeurs doivent s’y référer en priorité, avec **`STATUS.md`** (racine) pour l’instantané et **`TODOS.md`** (racine) pour les tâches.

| Fichier | Rôle |
|--------|------|
| **`STATUS.md`** (racine) | État **instantané** du projet, objectifs courants, liens vers `docs/`. |
| **`TODOS.md`** (racine) | **Toutes** les tâches : en cours, suivantes, finalisées, **jalons validés par toi** (bloquant). |
| **[`docs/STATUS.md`](STATUS.md)** | Suivi **détaillé** ordonné : dernière réalisation, à faire maintenant, journal des résolutions. |
| **[`docs/TESTS.md`](TESTS.md)** | **Fiche de suivi des tests manuels** (commande par commande, résultats attendus, cases à cocher). |
| **[`docs/ERRORS.md`](ERRORS.md)** | Journal des **erreurs** (passées / en cours), causes, correctifs, pistes. |
| **[`docs/STRUCTURE_ANALYSIS.md`](STRUCTURE_ANALYSIS.md)** | Analyse **longue** de l’arborescence (inventaire), pas la checklist du jour. |
| **[`docs/ARCHITECTURE.md`](ARCHITECTURE.md)** | Entrées shell, managers, `DOTFILES_GOOD`, refonte modulaire. |
| **[`docs/REFACTOR_HISTORY.md`](REFACTOR_HISTORY.md)** | Historique des refactors (ex-`docs/STATUS` détaillé historique). |
| **[`docs/MULTISHELL_REPORT.md`](MULTISHELL_REPORT.md)** | Multi-shell, `make test`, matrice. |
| **[`docs/ACTION_PLAN_ARCHITECTURE.md`](ACTION_PLAN_ARCHITECTURE.md)** | Plan TUI / logs / modules. |
| **[`docs/STRUCTURE.md`](STRUCTURE.md)** | Structure du dépôt (vue synthétique). |
| **[`docs/COMPATIBILITY.md`](COMPATIBILITY.md)** / **[`COMPATIBILITY_SUMMARY.md`](COMPATIBILITY_SUMMARY.md)** | Compatibilité shells / distros. |
| **[`docs/CYBERMAN_WORKFLOWS.md`](CYBERMAN_WORKFLOWS.md)** | Workflows cyberman. |
| **[`docs/HELP_DISPLAY_GUIDE.md`](HELP_DISPLAY_GUIDE.md)** | Affichage d’aide. |
| **[`docs/INSTALLMAN_VISION.md`](INSTALLMAN_VISION.md)** | Vision installman trans-distro. |
| **[`docs/MAN_MARKDOWN_GUIDE.md`](MAN_MARKDOWN_GUIDE.md)** | Format doc man markdown. |
| **[`docs/MANAGER_DATA_STORAGE.md`](MANAGER_DATA_STORAGE.md)** | Stockage données managers. |
| **[`docs/MANAGERS_SEARCH_VS_INFO.md`](MANAGERS_SEARCH_VS_INFO.md)** | searchman vs infos. |
| **[`docs/MODULEMAN_EXPLICATION.md`](MODULEMAN_EXPLICATION.md)** | moduleman. |
| **[`docs/TROUBLESHOOTING_MAN_GIT.md`](TROUBLESHOOTING_MAN_GIT.md)** | `git help` / `man`. |
| **[`docs/DOTCLI_MENU_CONTRACT.md`](DOTCLI_MENU_CONTRACT.md)** | Contrat API `dotcli menu`. |
| **[`docs/UNIFIED_PLATFORM_ROADMAP.md`](UNIFIED_PLATFORM_ROADMAP.md)** | Roadmap plateforme unifiée. |
| **`scripts/test/SANDBOX.md`** | Bac à sable Docker, chemins conteneur, commandes. |
| **`README.md`** (racine) | Installation, usage quotidien, liens vers cette carte. |

## Dossier `docs/man/`

Pages **man** markdown par manager / outil : `aliaman`, `cyberman`, `extract`, `manman`, `miscman`, `netman`, `pathman`, `processman`, `routeman`, `searchman`, `sshman`. Référence croisée : **`docs/MAN_MARKDOWN_GUIDE.md`**.

## Dossier `docs/migrations/`

| Fichier | Rôle |
|---------|------|
| [`COMPLETE_MIGRATION_LIST.md`](migrations/COMPLETE_MIGRATION_LIST.md) | Liste complète à migrer (référence). |
| [`MIGRATION_COMPLETE_GUIDE.md`](migrations/MIGRATION_COMPLETE_GUIDE.md) | Guide pas à pas. |
| [`MIGRATION_MULTI_SHELLS.md`](migrations/MIGRATION_MULTI_SHELLS.md) | Explications multi-shells. |
| [`MIGRATION_PLAN.md`](migrations/MIGRATION_PLAN.md) | Plan détaillé. |
| [`PROGRESSION_MIGRATION.md`](migrations/PROGRESSION_MIGRATION.md) | Progression. |

## Règles de maintenance

1. **Ne pas** recréer `ERRORS.md` à la racine : tout incident documenté va dans **`docs/ERRORS.md`**.
2. Après une modification **code / doc / action** : mettre à jour **`TODOS.md`**, puis **`STATUS.md`** (racine), puis **`docs/STATUS.md`** si pertinent.
3. Les tests **manuels** suivis dans **`docs/TESTS.md`** complètent `make test` (smoke) ; ils ne se substituent pas à la CI.
