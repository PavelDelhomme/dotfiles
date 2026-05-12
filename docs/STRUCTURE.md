> **Hub doc** : [`INDEX.md`](INDEX.md) — point d’entrée principal. **Format des étapes** (Conforme `O·N·NA`, Assistant relecture…) : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md).
>
> **À la racine de `docs/`** : [`INDEX.md`](INDEX.md) · [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) · ce fichier ([`STRUCTURE.md`](STRUCTURE.md)) · [`TESTS.md`](TESTS.md) · [`ERRORS.md`](ERRORS.md). **À la racine du dépôt** : [`STATUS.md`](../STATUS.md) · [`TODOS.md`](../TODOS.md).

# Documentation et structure du dépôt

> **Rôle de ce fichier** : **carte technique** — arborescence des sous-dossiers `docs/` + structure code. Pour **« où lire quoi »**, utiliser [`INDEX.md`](INDEX.md).

## Arborescence `docs/`

```
docs/
├── INDEX.md            ← hub navigation (où aller pour quoi)
├── LEGENDE_CHAMPS.md   ← référentiel format d’étape (Conforme O·N·NA, Assistant, etc.)
├── STRUCTURE.md        ← ce fichier (carte de la doc)
├── CODEMAP.md          ← arborescence code (scripts, managers, fonctions zsh)
├── TESTS.md            ← tests manuels (checklist A–I)
├── ERRORS.md           ← journal incidents / correctifs
├── architecture/       ← architecture, plan d’action, historique refactors, analyse longue
├── compatibility/      ← matrices compatibilité
├── guides/             ← guides utilisateur (install, usage, docker, VM, GitHub Actions, …)
├── managers/           ← docs par domaine manager (cyberman, installman, moduleman, …)
├── platform/           ← roadmap unifiée, contrat dotcli
├── reports/            ← rapports (ex. multi-shell)
├── man/                ← pages man markdown par outil
└── migrations/         ← guides de migration multi-shells
```

## Carte des documents (par dossier)

| Emplacement | Rôle |
|-------------|------|
| **[`INDEX.md`](INDEX.md)** (`docs/`) | **Hub** : où aller pour quoi. À ouvrir en premier. |
| **[`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md)** (`docs/`) | **Référentiel** unique des champs d’étape (Conforme `O·N·NA`, Notes, Assistant relecture). |
| **[`CODEMAP.md`](CODEMAP.md)** (`docs/`) | **Carte code** : arborescence des scripts, managers, fonctions zsh, utilitaires. |
| **`STATUS.md`** (racine dépôt) | État **instantané**, objectifs, journal récent. |
| **`TODOS.md`** (racine dépôt) | **Lots / tâches** : en cours, suivantes, validées (bloquant sans ta validation). |
| **[`TESTS.md`](TESTS.md)** | Procédure **tests manuels** pas à pas ; entrée menu : `make tests-start`. |
| **[`ERRORS.md`](ERRORS.md)** | **Erreurs** passées / en cours, correctifs. |
| [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md) | Entrées shell, managers, `DOTFILES_GOOD`, refonte modulaire. |
| [`architecture/ACTION_PLAN_ARCHITECTURE.md`](architecture/ACTION_PLAN_ARCHITECTURE.md) | Plan TUI / logs / modules. |
| [`architecture/REFACTOR_HISTORY.md`](architecture/REFACTOR_HISTORY.md) | Archive historique des refactors. |
| [`architecture/STRUCTURE_ANALYSIS.md`](architecture/STRUCTURE_ANALYSIS.md) | Analyse **longue** de l’arborescence. |
| [`compatibility/COMPATIBILITY.md`](compatibility/COMPATIBILITY.md) · [`compatibility/COMPATIBILITY_SUMMARY.md`](compatibility/COMPATIBILITY_SUMMARY.md) | Compatibilité shells / distros. |
| [`guides/INSTALL.md`](guides/INSTALL.md) | Installation rapide, réinstallation, SSH GitHub, rollback, options menu, scripts modulaires, Flutter/Android, NVIDIA. |
| [`guides/USAGE.md`](guides/USAGE.md) | Usage quotidien (Makefile, recharger config, mise à jour), `help`/`man`, validation setup, Powerlevel10k, maintenance, fichiers de config, troubleshooting. |
| [`guides/MANAGERS.md`](guides/MANAGERS.md) | Description / usage des managers + compatibilité multi-shells. |
| [`guides/DOCKER.md`](guides/DOCKER.md) | Docker utilisateur (BuildKit, Docker Desktop, conteneur isolé `make docker-in`). |
| [`guides/VM.md`](guides/VM.md) | Gestion VM QEMU/KVM en CLI (snapshots, rollback, tests). |
| [`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md) | CI GitHub Actions : workflow `ci-checks`, secrets SMTP / e-mail (OVH), correctif `action-send-mail`, roadmap tests automatisés. |
| [`guides/HELP_DISPLAY_GUIDE.md`](guides/HELP_DISPLAY_GUIDE.md) | Affichage d’aide. |
| [`guides/MAN_MARKDOWN_GUIDE.md`](guides/MAN_MARKDOWN_GUIDE.md) | Format doc man markdown (`man/`). |
| [`guides/TROUBLESHOOTING_MAN_GIT.md`](guides/TROUBLESHOOTING_MAN_GIT.md) | `git help` / `man`. |
| [`managers/CYBERMAN_WORKFLOWS.md`](managers/CYBERMAN_WORKFLOWS.md) | Workflows cyberman. |
| [`managers/INSTALLMAN_VISION.md`](managers/INSTALLMAN_VISION.md) | Vision installman trans-distro. |
| [`managers/MANAGER_DATA_STORAGE.md`](managers/MANAGER_DATA_STORAGE.md) | Stockage données managers. |
| [`managers/MANAGERS_SEARCH_VS_INFO.md`](managers/MANAGERS_SEARCH_VS_INFO.md) | searchman vs infos. |
| [`managers/MODULEMAN_EXPLICATION.md`](managers/MODULEMAN_EXPLICATION.md) | moduleman. |
| [`platform/UNIFIED_PLATFORM_ROADMAP.md`](platform/UNIFIED_PLATFORM_ROADMAP.md) | Roadmap plateforme unifiée. |
| [`platform/DOTCLI_MENU_CONTRACT.md`](platform/DOTCLI_MENU_CONTRACT.md) | Contrat API `dotcli menu`. |
| [`reports/MULTISHELL_REPORT.md`](reports/MULTISHELL_REPORT.md) | Multi-shell, `make test`, matrice. |
| [`man/`](man/) | Pages man par manager / outil. |
| [`migrations/`](migrations/) | Guides migration (liste, plan, progression). |
| **`scripts/test/SANDBOX.md`** | Bac à sable Docker. |
| **`README.md`** (racine) | Installation et usage. |

### Règles de maintenance

1. **`docs/` racine** contient **exactement** 6 fichiers : `INDEX.md`, `LEGENDE_CHAMPS.md`, `STRUCTURE.md`, `CODEMAP.md`, `TESTS.md`, `ERRORS.md`. Tout le reste va dans un sous-dossier thématique.
2. Ne pas recréer **`ERRORS.md`** à la racine du dépôt : uniquement **`docs/ERRORS.md`**.
3. Après modification **code / doc / action** : mettre à jour **`TODOS.md`** puis **`STATUS.md`** (racine).
4. Nouvelle page thématique : la placer dans **`architecture/`**, **`guides/`**, **`managers/`**, **`platform/`** ou **`reports/`**.
5. Mettre à jour **ce fichier** (`STRUCTURE.md`) si tu ajoutes un dossier ou un document majeur ; **`INDEX.md`** uniquement si la page est centrale.
6. **Format d’étape** identique partout : voir [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md). Toute redéfinition locale est un bug à corriger.


---

## Arborescence code → [`CODEMAP.md`](CODEMAP.md)

L’arborescence détaillée des **scripts**, **fonctions zsh**, **managers** et **utilitaires** a été déplacée dans un fichier dédié pour garder `STRUCTURE.md` court : **[`CODEMAP.md`](CODEMAP.md)**.

| Tu cherches… | Va dans |
|--------------|---------|
| Carte de la **doc** (`docs/`) | **ce fichier** |
| Arborescence du **code** (scripts, managers, fonctions) | [`CODEMAP.md`](CODEMAP.md) |
| Architecture **cible** managers / shells / `dotcli` | [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md) |
| Roadmap plateforme unifiée | [`platform/UNIFIED_PLATFORM_ROADMAP.md`](platform/UNIFIED_PLATFORM_ROADMAP.md) |
