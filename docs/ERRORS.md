# Journal des erreurs, incidents et correctifs

> **Rôle de ce fichier** : tracer les **incidents reproductibles** (CI, Docker, shell, manager). **Pas** la roadmap (→ [`../TODOS.md`](../TODOS.md)) ni le journal éditorial (→ [`../STATUS.md`](../STATUS.md)).
>
> **Index général** : [`INDEX.md`](INDEX.md) · **Format des étapes** (si tu déroules un correctif pas à pas) : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) · **Carte technique** : [`STRUCTURE.md`](STRUCTURE.md) · **Tests** : [`TESTS.md`](TESTS.md).

Tout incident **récurrent** doit être consigné ici pour éviter de réinventer le diagnostic. Les entrées **résolues** restent dans l’historique ; les entrées **ouvertes** sont en tête de la section active.

## Comment ajouter une entrée

1. **Nouveau bloc** avec date `AAAA-MM`.
2. Tableau : **Problème** | **Cause** | **Correctif** | **Statut** (`ouvert` / `résolu`).
3. Lier un commit ou une PR si applicable.

---

## Actif / récent

| Problème | Cause | Correctif | Statut |
|----------|--------|-----------|--------|
| GitHub Actions : `Send Email` — `Unexpected input(s) 'content_type'` ; `Input required and not supplied: from` | L’action `dawidd6/action-send-mail@v3` n’accepte pas `content_type` ; secret `EMAIL_FROM` (ou autres SMTP) absent | Supprimer `content_type` du YAML ; renseigner les secrets (`EMAIL_FROM`, `EMAIL_TO`, `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`) **ou** rendre le job optionnel avec `if: secrets.EMAIL_FROM != '' && …` — voir [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md). Le workflow **`.github/workflows/ci-checks.yml`** du dépôt ne dépend pas de l’e-mail. | partiellement résolu *(doc + CI sans e-mail ; fusionner / corriger sur GitHub le workflow « notify » encore cassé)* |
| Écran Mi Monitor (XMI) — image lavée / peu lumineuse alors que `brightness=100/100` DDC | (a) `VCP 14` (color preset) sur `0x0b` User 1 + **firmware MCCS 2.1 refuse silencieusement** `setvcp 14` (DDCRC_VERIFY puis relecture inchangée même avec `--noverify`) ; (b) HDMI Limited Range (16-235) côté NVIDIA propriétaire négocié au lieu de Full (0-255). | (a) **OSD physique uniquement** : joystick au DOS du moniteur → `Picture Mode = Standard/sRGB` + `HDMI Black Level = Normal` + désactiver `DCR/Low Blue Light` (cf. `displayman osd-guide`). (b) Fragment `/etc/X11/xorg.deconf.d/20-nvidia-fullrange.conf` `Option "ColorRange" "Full"` puis relog (cf. `displayman range` et [`docs/guides/SCREEN_DISPLAY.md`](docs/guides/SCREEN_DISPLAY.md) Étape C). Diagnostic outillé : `displayman dump 1`. | partiellement résolu *(diag complet + outillage `displayman` livrés 2026-05-13 ; étape C à appliquer manuellement par l’utilisateur)* |

---

## 2026-05 — `make test` phase 2 & matrice

| Problème | Cause | Correctif | Statut |
|----------|--------|-----------|--------|
| `tee: …/dotfiles/test_results/… Read-only file system` | Écriture des rapports sous le dépôt monté RO dans le conteneur | `run_tests.sh`, `manager_subcommand_matrix.sh`, `run_tests_in_current_env` : `TEST_RESULTS_DIR` bascule vers `/root/test_results` ou `/tmp/dotfiles_test_results` | résolu |
| `❌ échec: zsh\|bash\|fish gitman log 1` | `git log` avec pager ou dépôt sans commit → code ≠ 0 ; sous zsh, parse du core `gitman.sh` hors émulation sh | `git --no-pager` + `gitman_log_oneline` (HEAD absent → message, exit 0) ; adapter zsh : `emulate -L sh` + `source` du core | résolu |
| `installman help` verbeux en zsh/bash, court en fish | Fish matrice = core POSIX ; zsh/bash = ancien core ou entry zsh | Adapters `shells/zsh|bash/adapters/installman.*` chargent **`core/managers/installman/core/installman.sh`** | résolu |

### Fichiers utiles (diagnostic)

- `scripts/test/subcommands/*.list` — invocations phase 2 (ajuster ou `@skip` si trop interactif).
- `test_output.log`, `subcommand_matrix_summary.txt`, `all_managers_test_report.txt` sous **`TEST_RESULTS_DIR`**.

---

## Historique (archives courtes)

Les anciens incidents massifs peuvent être **résumés** ici ; le détail narratif long reste dans les commits Git et, le cas échéant, [`REFACTOR_HISTORY.md`](REFACTOR_HISTORY.md).

| Période | Thème | Où détailler |
|---------|--------|----------------|
| 2025–2026 | Migration multi-shell, wrappers → POSIX | `docs/migrations/`, `REFACTOR_HISTORY.md` |
| 2025–2026 | Docker / sandbox RO | `scripts/test/SANDBOX.md` |
