# Vision tests E2E et multi-environnements (dotfiles)

> **Statut** : cadrage **2026-06-16** — **pas** d’implémentation complète immédiate. Référence pour P11/P12 dans [`TODOS.md`](../../TODOS.md).

## Objectif

Tester **tout le système dotfiles** (managers `*man`, scripts, alias, menus, docs, install) dans des **environnements isolés** sans casser la machine hôte : plusieurs OS, shells, DE/WM, et à terme matériel virtualisé.

## Périmètre cible

| Dimension | Exemples |
|-----------|----------|
| **OS / distro** | Debian, Ubuntu, Lubuntu, Kubuntu, Gentoo, Arch, Manjaro, Alpine, Fedora |
| **Shell** | bash, zsh, fish, sh (déjà partiellement couvert — voir `TESTS.md` § C.3) |
| **Interface graphique** | X11, Wayland, sessions légères (LXQt, KDE, …) |
| **Hôte exotique** | macOS (Homebrew), Windows (WSL2, Git Bash, PowerShell), Raspberry Pi, Arduino *(scripts limités)* |
| **Matériel** | DDC/écrans (`displayman`), réseau, disques — mocks ou VM avec périphériques pass-through si besoin |

## Grandes familles de tests (référentiel)

| Famille | Rôle | Où aujourd’hui |
|---------|------|----------------|
| **Fonctionnels** | Règles métier, use cases, user stories | `docs/TESTS.md` (manuel), `scripts/test/subcommands/*.list` |
| **Non fonctionnels** | Perf, sécu, UX, compatibilité | Partiel (`make test-tui-compact`, matrices shells) |
| **Structurels (boîte blanche)** | Couverture, chemins d’exécution | `make test-checks`, syntaxe managers |
| **Changements** | Régression, confirmation correctif, migration | G.0, G.0.b, CI Docker, `ERRORS.md` |
| **Manuels** | Exploratoire, recette, UX TUI | `TESTS.md` A→I, `make tests-start` |
| **Automatisés** | CI/CD, pipelines | `make test`, GitHub Actions `ci-checks.yml` |

## Stack actuelle vs cible

| Outil | Aujourd’hui | Limite | Piste |
|-------|-------------|--------|-------|
| **Docker** | `make test-docker`, image Arch par défaut | Pas de DE complète, pas de DDC réel, lourd pour matrice large | Garder pour smoke CI |
| **Conteneurs légers** | — | — | **Podman** / **distrobox** / **nix-shell** pour matrices distro rapides |
| **VM** | doc `guides/VM.md` | Manuel | **QEMU/KVM** + snapshots, templates par distro |
| **E2E visuel** | — | — | Enregistrement **asciinema** / **video** des sessions ; accès **VNC/noVNC** pour « prendre la main » |
| **Orchestration** | Makefile | — | Pipeline `test/e2e-*` branches + rapport HTML agrégé |

## Principes de conception

1. **Isolation** : aucun test destructif sur l’hôte (`diskman --apply`, `displayman brightness`, etc. restent en dry-run / VM dédiée).
2. **Réutilisabilité** : mêmes listes `scripts/test/subcommands/*.list` et étapes `TESTS.md` ; outil `tests_copy.sh` pour rejouer les commandes.
3. **Parité shells** : généraliser fish/PowerShell là où bash/zsh suffisent aujourd’hui (fishrc, adapters, fallbacks documentés).
4. **Installation multi-OS** : plusieurs chemins d’install (`bootstrap.sh`, profils Windows/WSL, doc par OS) — voir P5 installman.
5. **Visibilité** : chaque passe E2E produit **logs + artefact** (vidéo ou cast) référencé dans `TEST_RESULTS_DIR` ou CI artifacts.

## Prochaines étapes (backlog)

Voir **`TODOS.md`** :

- **P11** — Matrice distro/shell élargie (distrobox ou images Docker supplémentaires).
- **P12** — Lab E2E (VM + enregistrement session + doc rejouable).
- **P13** — Compatibilité cross-OS (WSL, PowerShell wrappers, fishrc complet).

## Liens

- Bac à sable : [`scripts/test/SANDBOX.md`](../../scripts/test/SANDBOX.md)
- Guide manuel : [`docs/TESTS.md`](../TESTS.md)
- Branches : [`GIT_BRANCHING.md`](GIT_BRANCHING.md)
