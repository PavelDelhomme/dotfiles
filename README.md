# Dotfiles — PavelDelhomme

Configuration personnelle Linux (Arch / Manjaro en priorité, support Debian / Fedora / Gentoo / openSUSE / Alpine pour les fonctions transverses) avec installation automatisée, **managers interactifs** (zsh / bash / fish via adaptateurs), **TUI mutualisée `dotcli`** et bac à sable Docker.

**Version :** 2.10.0

---

## Démarrage rapide

### Installation en une commande (nouvelle machine)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
```

Le bootstrap affiche un **preflight** (état détecté + plan) et demande `OUI` avant d’agir.

### Machine vide — tout explorer SANS installer sur l’hôte

```bash
git clone https://github.com/PavelDelhomme/dotfiles.git ~/dotfiles
cd ~/dotfiles
make init help          # procédures init / install / tests
make init status        # que détecte déjà la machine ?
make init plan          # plan d’install sans appliquer
make help               # aide courte Makefile
make help-all           # catalogue complet
make tests              # menu tests
make docker-in          # bac à sable isolé
bash test-docker.sh --help
```

> Détails → [`docs/guides/INSTALL.md`](docs/guides/INSTALL.md).

### Après installation (hôte)

```bash
cd ~/dotfiles
make init status
make setup       # menu interactif scripts/setup.sh
make validate
make tests-start # parcours docs/TESTS.md
```

---

## Documentation du dépôt

> **Point d’entrée unique** : [`docs/INDEX.md`](docs/INDEX.md). Il dit dans quel fichier vit chaque chose.

| Besoin | Aller dans |
|--------|------------|
| **Hub** — où aller pour quoi | [`docs/INDEX.md`](docs/INDEX.md) |
| **Format d’une étape** (`Conforme O·N·NA`, Notes, Assistant relecture…) | [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) |
| **Statut instantané** + journal récent | [`STATUS.md`](STATUS.md) |
| **Tâches** (en cours, à faire, validation bloquante) | [`TODOS.md`](TODOS.md) |
| **Disposition racine** (moins de fichiers à la racine) | [`docs/architecture/ROOT_LAYOUT.md`](docs/architecture/ROOT_LAYOUT.md) |
| **Shells** (zsh/bash/fish session ou login) | `shellman` · [`docs/man/shellman.md`](docs/man/shellman.md) |
| **Tests manuels** pas à pas | [`docs/TESTS.md`](docs/TESTS.md) |
| **Erreurs** / correctifs | [`docs/ERRORS.md`](docs/ERRORS.md) |
| **Carte doc** (`docs/`) | [`docs/STRUCTURE.md`](docs/STRUCTURE.md) |
| **Carte code** (scripts, managers, fonctions zsh) | [`docs/CODEMAP.md`](docs/CODEMAP.md) |

**Règle** : une tâche « finalisée » doit être **validée par toi** dans `TODOS.md`, puis enregistrée avec **`git commit`** / **`push`** avant d’enchaîner la suite.

### Guides utilisateur (sortis de ce README)

| Guide | Contenu |
|-------|---------|
| [`docs/guides/INSTALL.md`](docs/guides/INSTALL.md) | Installation rapide (curl) ; réinstallation ; configuration GitHub SSH ; workflow nouvelle machine ; rollback / désinstallation ; options menu `setup.sh` ; scripts modulaires ; Flutter & Android ; NVIDIA. |
| [`docs/guides/USAGE.md`](docs/guides/USAGE.md) | Usage quotidien (Makefile, recharger config, mise à jour) ; système d’aide (`help` / `man`) ; validation setup ; Powerlevel10k ; maintenance ; fichiers de configuration (`.env`, aliases, zshrc) ; troubleshooting. |
| [`docs/guides/MANAGERS.md`](docs/guides/MANAGERS.md) | Description et usage des managers (`pathman`, `netman`, `installman`, `configman`, `cyberman`, `devman`, `gitman`, `multimediaman`, `moduleman`, `testman`, …) + compatibilité multi-shells. |
| [`docs/guides/DOCKER.md`](docs/guides/DOCKER.md) | Installation Docker + BuildKit + Docker Desktop optionnel + tests dans conteneur isolé (`make docker-in`). |
| [`docs/guides/VM.md`](docs/guides/VM.md) | Gestion VM QEMU/KVM en CLI (création, snapshots, rollback, test des dotfiles). |

### Pour aller plus loin

| Sujet | Document |
|-------|----------|
| Architecture cible managers / shells / `dotcli` | [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) |
| Roadmap plateforme unifiée | [`docs/platform/UNIFIED_PLATFORM_ROADMAP.md`](docs/platform/UNIFIED_PLATFORM_ROADMAP.md) |
| Contrat menu `dotcli` | [`docs/platform/DOTCLI_MENU_CONTRACT.md`](docs/platform/DOTCLI_MENU_CONTRACT.md) |
| Migration multi-shells | [`docs/migrations/`](docs/migrations/) |
| Compatibilité shells / distros | [`docs/compatibility/COMPATIBILITY.md`](docs/compatibility/COMPATIBILITY.md) |
| Pages **man** par manager | [`docs/man/`](docs/man/) |
| Bac à sable Docker (tests) | [`scripts/test/SANDBOX.md`](scripts/test/SANDBOX.md) |

---

## Licence

Configuration personnelle — libre d’utilisation et modification.

## Auteur

**PavelDelhomme** — GitHub : [@PavelDelhomme](https://github.com/PavelDelhomme)

---

*Dernière mise à jour de ce README : 2026-05-11. Toutes les sections détaillées qui figuraient ici (Installation, Usage, Managers, Docker, VM, Maintenance, Troubleshooting…) sont désormais dans **`docs/guides/`** pour éviter un README de 3000+ lignes.*
