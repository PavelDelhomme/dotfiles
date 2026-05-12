# Index documentation — où aller pour quoi (dotfiles)

> **Point d’entrée unique** pour toute la doc. Si tu hésites, ouvre **ce fichier** d’abord ; il dit dans quel document chaque chose vit.

---

## 1. Les 5 documents à connaître

| # | Document | Rôle exact | Quand l’ouvrir |
|---|----------|-----------|----------------|
| 1 | [`../STATUS.md`](../STATUS.md) | **État instantané** : version, objectifs en cours, journal récent. | Pour savoir **où en est** le projet aujourd’hui. |
| 2 | [`../TODOS.md`](../TODOS.md) | **Backlog** : tâches en cours, à faire, finalisées en attente de validation. | Pour savoir **ce qu’il reste à faire** et valider explicitement les étapes bloquantes. |
| 3 | [`TESTS.md`](TESTS.md) | **Procédure tests manuels** : cases à cocher, Bloc A→I. | Pour **tester** depuis zéro (`make tests-start` en parallèle). |
| 4 | [`ERRORS.md`](ERRORS.md) | **Journal des incidents** : problème / cause / correctif. | Quand tu hites une erreur récurrente ou tu veux comprendre une régression. |
| 5 | [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) | **Référentiel unique** : format d’une étape (Commande, Attendu, Conforme O/N/NA, Notes, Assistant relecture…). | Avant d’ajouter ou de modifier une étape dans un guide. |

> **Carte doc** : [`STRUCTURE.md`](STRUCTURE.md) — où se trouvent les fichiers `docs/`. **Carte code** : [`CODEMAP.md`](CODEMAP.md) — arborescence des scripts, managers, fonctions zsh. **INDEX** (ce fichier) te dit **quoi lire**.

---

## 2. Cas d’usage rapides

| Tu veux… | Va dans |
|----------|---------|
| Tester depuis zéro (ordre A→I, validation O/N/NA). | [`TESTS.md`](TESTS.md) + `make tests-start` |
| Définir comment remplir un champ d’étape. | [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) |
| Valider une tâche finalisée (case bloquante). | [`../TODOS.md`](../TODOS.md) → **« Finalisées — en attente de validation »** |
| Documenter une erreur reproductible. | [`ERRORS.md`](ERRORS.md) → ajouter une entrée datée |
| Connaître la version et le journal récent. | [`../STATUS.md`](../STATUS.md) |
| Trouver un fichier de **doc**, comprendre l’arborescence `docs/`. | [`STRUCTURE.md`](STRUCTURE.md) |
| Trouver un fichier de **code** (script, manager, fonction). | [`CODEMAP.md`](CODEMAP.md) |
| **Installer** sur une nouvelle machine. | [`guides/INSTALL.md`](guides/INSTALL.md) |
| **Usage quotidien** (Makefile, aide, maintenance, Powerlevel10k…). | [`guides/USAGE.md`](guides/USAGE.md) |
| **Utiliser les managers** (`pathman`, `netman`, `installman`, …). | [`guides/MANAGERS.md`](guides/MANAGERS.md) + [`managers/`](managers/) + [`man/`](man/) |
| **Docker** (utilisateur, BuildKit, conteneur isolé). | [`guides/DOCKER.md`](guides/DOCKER.md) |
| **VM** QEMU/KVM (tests isolés). | [`guides/VM.md`](guides/VM.md) |
| **CI GitHub Actions** (workflows, secrets e-mail, roadmap). | [`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md) |
| Comprendre l’architecture managers / shells / `dotcli`. | [`architecture/ARCHITECTURE.md`](architecture/ARCHITECTURE.md) + [`platform/UNIFIED_PLATFORM_ROADMAP.md`](platform/UNIFIED_PLATFORM_ROADMAP.md) |
| Voir la roadmap unifiée (TUI / `dotcli`). | [`platform/UNIFIED_PLATFORM_ROADMAP.md`](platform/UNIFIED_PLATFORM_ROADMAP.md) |
| Vérifier le contrat menu `dotcli`. | [`platform/DOTCLI_MENU_CONTRACT.md`](platform/DOTCLI_MENU_CONTRACT.md) |
| Suivre / comprendre une migration multi-shells. | [`migrations/`](migrations/) |
| Voir une page **man** d’un manager. | [`man/`](man/) |
| Tester dans un conteneur (bac à sable). | [`../scripts/test/SANDBOX.md`](../scripts/test/SANDBOX.md) |

---

## 3. Cycle de travail (vue d’ensemble)

```
+-------------------+      +------------------+      +-------------------+
| 1) TODOS.md       |  →   | 2) Action / test |  →   | 3) Commit / push  |
|  (tâche choisie)  |      |  (TESTS.md +     |      |  (STATUS.md MAJ   |
|                   |      |   LEGENDE_CHAMPS)|      |   si milestone)   |
+-------------------+      +------------------+      +-------------------+
         ↑                          ↓                          ↓
         |                  +---------------+         +-------------------+
         +-- valide -------|  4) Validation  |←------ |  ERRORS.md (si    |
                          |  (TODOS.md :     |         |  incident à tracer)|
                          |  case "validée") |         +-------------------+
                          +---------------+
```

**Règle de fin de cycle (inchangée)** : avant d’enchaîner sur une nouvelle tâche, **cocher** la ligne « Finalisées — en attente de validation » dans [`../TODOS.md`](../TODOS.md) puis **`git add` / `commit` / `push`** ([`../STATUS.md`](../STATUS.md)).

---

## 4. Pour ajouter / modifier un guide pas-à-pas

1. Le guide commence par : `> **Format des étapes** : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md).`
2. Chaque étape utilise **strictement** le bloc défini en [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) (§1).
3. **`Conforme`** = `O` / `N` / `NA` (voir §3 du même fichier).
4. **`Assistant (relecture)`** reste **vide** tant qu’une revue n’est pas faite.
5. Ajouter une **section « EXT-xxx »** en bas du guide si on veut accumuler des demandes structurées.

---

## 5. Conventions de classement (rappel)

- **Racine du dépôt** : `STATUS.md`, `TODOS.md`, `README.md` (et c’est tout côté doc projet).
- **`docs/` racine** : `INDEX.md` (ce fichier), `LEGENDE_CHAMPS.md`, `STRUCTURE.md`, `CODEMAP.md`, `TESTS.md`, `ERRORS.md`. Rien d’autre.
- **Thèmes** : `architecture/`, `compatibility/`, `guides/`, `managers/`, `platform/`, `reports/`, `man/`, `migrations/`.

Toute nouvelle page **thématique** va dans un sous-dossier ; on l’ajoute ensuite à `STRUCTURE.md` (carte technique) et — si elle est centrale — au tableau §1 ci-dessus.
