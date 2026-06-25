# TODOS — Roadmap et actions (dotfiles)

> **Rôle de ce fichier** : **toutes les tâches** — en cours, à faire, finalisées (en attente de validation bloquante / validées). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md). Pour le **format d’une étape** (cases, `Conforme`, Notes, Assistant…) : [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md).
>
> **Liens connexes** : statut instantané [`STATUS.md`](STATUS.md) · tests manuels [`docs/TESTS.md`](docs/TESTS.md) · incidents [`docs/ERRORS.md`](docs/ERRORS.md) · carte technique [`docs/STRUCTURE.md`](docs/STRUCTURE.md).

---

## Règle de passage (obligatoire)

1. Toute tâche figurant dans **« Finalisées — en attente de validation par moi »** doit être **explicitement validée** (case cochée ou ligne signée) **par toi** avant de traiter les tâches suivantes comme définitivement closes.
2. **Quoi qu’il en coûte** : sans cette validation, on **ne fait pas** comme si la suite du backlog était débloquée sur ce point.
3. À chaque validation (ou fin de lot livré) : **`git add`**, **`git commit`**, **`git push`** pour figer l’état dans l’historique Git.
4. **Branches** : ne **plus supprimer** les branches `feat/`, `test/`, `fix/` après merge — les conserver pour traçabilité. Voir [`docs/architecture/GIT_BRANCHING.md`](docs/architecture/GIT_BRANCHING.md).

---

## En cours (lot / tâche actuelle)

- [~] **Prompt root / sudo Powerlevel10k** (**immédiat**) : reproduire le design du prompt utilisateur (`~/.p10k.zsh` → `~/dotfiles/.p10k.zsh`) pour root sans casser le compte normal.
  - **Diagnostic 2026-06-12** : utilisateur `pactivisme` OK (`~/.p10k.zsh` symlink vers `~/dotfiles/.p10k.zsh`, `p10k` disponible) ; root incomplet (`/root/.zshrc` absent, `/root/.p10k.zsh` absent).
  - **Livré 2026-06-12** : procédure `configman p10k root --dry-run|--apply` via [`scripts/config/setup_root_prompt.sh`](scripts/config/setup_root_prompt.sh), variante [`.p10k-root.zsh`](.p10k-root.zsh), backup `/root/.zshrc` + `/root/.p10k.zsh`, symlinks prudents, vérification Powerlevel10k / MesloLGS-Nerd Fonts.
  - **Livré 2026-06-12 (suite)** : ré-application idempotente `configman apply shell --dry-run|--apply` via [`scripts/bootstrap/apply_dotfiles.sh`](scripts/bootstrap/apply_dotfiles.sh) ; `configman p10k` vérifie/propose l'installation P10k + Nerd Fonts ; smoke Docker local `make test-bootstrap-apply`.
  - **Sécurité** : privilégier `sudo` (pas de commande `surdo`) ; ne pas forcer root par défaut ; garder rollback documenté.
- [~] **updateman Cursor** : updater AppImage reutilisable (`scripts/update/update-cursor-appimage`) + manager `updateman cursor` + timer `systemd --user`.
  - **Objectif** : `updateman cursor` met Cursor a jour maintenant ; `updateman cursor enable` installe/active l'automatisation quotidienne.
  - **Point cle** : detection adaptee au poste (`.desktop`, processus Cursor, commande `cursor`, `/opt`, `~/Applications`) au lieu d'un chemin versionne fixe.
  - **Etat local 2026-05-22** : l'updater reste interne au depot ; la commande publique `~/.local/bin/update-cursor-appimage` est retiree au profit de `updateman cursor`; timer `cursor-update.timer` enabled + active.
  - [x] Registre `updatable-tools.list` + lib `updatable_tools.sh` + `updateman status` / `updateman all`.
  - [x] `installman` active le timer via `updateman <outil> enable` (registre) et delegue les updates au registre.
  - [x] Shim legacy `update-cursor` retire de `shared/config.sh`.
  - [x] Garde-fou validation manuelle : si Cursor est ouvert, `updateman cursor` propose de le fermer en TTY ; le timer systemd echoue proprement sans tuer l'application.
  - **Reste** : validation manuelle utilisateur (tableau V-2026-05-22) ; ajouter d'autres outils installman au registre (P8c).
- [~] **P3b-a — restructuration UI / menus avant adaptatif** (prioritaire) : `shared/` vs `share`, `scripts/menu/README.md` + LEGACY, `make bootstrap-menu` → `setup.sh`, selection via `manager_ui_select_file`, `dfm` reserve aux menus declaratifs `share/menus` (zsh/bash/fish), fallback pagine sans `fzf` + pause apres action, matrice core vs declaratif dans [`docs/architecture/UI_MENU_RESTRUCTURE.md`](docs/architecture/UI_MENU_RESTRUCTURE.md). **Reste** : verifier adapters minces, bannieres autres `*man`, menus inline sans wrapper.
- [~] **P3b-b — interfaces terminal adaptatives** : bannieres + `manager_ui_section_line` ; pathman/doctorman ; `processman` + `tui_menu_height` ; sortie menu **0/q** (`manager_ui_is_quit_choice`, boucle `show_main_menu || break`) — `0e5647a` ; smoke `make test-tui-compact` (COLUMNS 60/69). **En pause** — suite plus tard : `tui_truncate`, pagination menus longs, aligner cyberman/installman/autres boucles inline, replay manuel EXT-002 sur `*man --help`.
- [~] **P1 — normalisation modulaire** (demarre) : convention UI POSIX documentee (`MANAGERS_UI.md`, `dotfiles_manager_load_ui_libs`). **Reste** : adapters minces, logique hors `zsh/functions/`, menus `dotcli`.
- [~] Exécuter et remplir **[`docs/TESTS.md`](docs/TESTS.md)** (procédure ordonnée + cases à cocher) ; menu d’appui : **`make tests-start`** ; copie commandes : **`make tests-copy STEP=…`**.
  - **Avancement 2026-06-16** : **G.0→G.0.f**, tableau **G.1–G.27**, **H.1–H.3**, **I.1–I.2** validés. Merge **`feat/manual-tests-g0` → `dev`**. **Reste** : validation utilisateur lignes TODOS « Finalisées » ; **P5** modules installman ; **P11** CI multi-distro.
  - **Ajout 2026-05-13** : nouveau manager `displayman` → **G.0.d** + ligne **G.24** ; **§ C.3** (matrice zsh/bash/fish/sh dans le conteneur) + lien **jalon B / `DOTFILES_GOOD`** ↔ **E.2** dans la table de correspondance avec `TESTS.md`.
  - **Ajout 2026-05-15** : manager **`diffman`** (diff coloré / côte à côte / rapports) → **G.0.e** + ligne **G.25** ; intégration `manman`, `migrated_managers.list`, [`docs/man/diffman.md`](docs/man/diffman.md).
  - **Ajout 2026-06-12** : manager **`diskman`** (diagnostic espace disque / nettoyage dry-run/apply) → **G.0.f** + ligne **G.26** ; intégration `manman`, adapters multi-shells, [`docs/man/diskman.md`](docs/man/diskman.md).
  - **Ajout 2026-06-12 (F.7)** : Bloc **F.7** complété (`dotcli --items-file`, smoke `make test-dotcli-f7`, F.7.a/b/c cochés dans TESTS.md). **Reste manuel optionnel** : navigation TUI visuelle sur `netman ports` / `cyberlearn --help` en terminal réel.
  - **Ajout 2026-06-12 (suite)** : **E.4** ajouté pour la passe Docker actuelle : `make test-docker` = managers **81/81 OK** (**412 tests**), Phase 2b `menu_quit_smoke` OK, matrice sous-commandes **114 exécutions / 0 échec** (`displayman detect` hors CI car matériel DDC réel) ; `make test-menu-quit` disponible pour vérifier rapidement les menus `0/q`.
  - **Correctif 2026-05-13** : **`netman` menu Informations IP** — affichage IPv4/IPv6 réécrit (`ip -o` + `awk`) ; voir **`docs/ERRORS.md`** + **EXT-006** dans `TESTS.md`.

---

## Dernière tâche terminée (juste avant l’actuelle)

- [x] Réorganisation doc 3 : scission **`docs/STRUCTURE.md`** → carte doc + **`docs/CODEMAP.md`** (arborescence code) ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** (`INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`).
- [x] Réorganisation doc 2 : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub navigation) + [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel champs O·N·NA / Assistant relecture) ; allègement de **`docs/TESTS.md`** (renvoie à la légende) ; clarification rôles **STATUS / TODOS / ERRORS**.
- [x] Réorganisation **`docs/`** par thèmes (sous-dossiers) + racine `docs/` = **`STRUCTURE` / `TESTS` / `ERRORS`** + journal dans **`STATUS.md`** racine.

---

## À faire ensuite (ordre logique)

| Prio | Tâche | Détail |
|------|--------|--------|
| **P1** | Normalisation architecture modulaire | Homogénéiser `core/managers/<nom>/` + adapters ; réduire `zsh/functions/` métier ; monolithes → modules. |
| **P2** | Domaine réseau | Cartographier `zsh/functions/commands/network/*` → `netman` ou commandes transverses. *(Note 2026-05-13 : menu **Informations IP** de `netman` corrigé — parsing `ip -o` ; voir `ERRORS.md` + `TESTS.md` C.3.)* |
| **P3** | TUI mutualisée | `dotcli menu` + fallbacks (`ncmenu`, `fzf`, `read`) sans casser CI. |
| **P3c** | **Moteur TUI Ink/TS (spike Hermes)** | Étude [`docs/architecture/TUI_HERMES_RESEARCH.md`](docs/architecture/TUI_HERMES_RESEARCH.md) — Hermes utilise **Ink + TypeScript** (pas MPJS/TJS). Prototype `tools/dotcli-tui/` + flag `DOTFILES_DOTCLI_TUI_ENABLE=1`. **Livré 2026-06-15** : spike menu ; **reste** : pagination longue liste, test visuel TTY, décider Ink vs dotcli C par défaut. |
| **P3b** | **Interfaces terminal adaptatives** | Les menus et affichages `*man` doivent s'adapter a la taille reelle du terminal : largeur/hauteur via `tput cols/lines`, mode compact si petit ecran, pagination/scroll propre, colonnes tronquees intelligemment, fallback non-TTY testable. Centraliser les helpers dans `dotcli`/utils au lieu de corriger chaque manager a la main. |
| **P4** | `shared/env.sh` → morceaux `DOTFILES_GOOD` | Voir phases historiques ; migration après jalon B si besoin. |
| **P5** | **Épic installman** | [`docs/managers/INSTALLMAN_VISION.md`](docs/managers/INSTALLMAN_VISION.md) — par étapes. |
| **P6** | Niveau 2 tests | Assertions métier (golden / grep) pour N managers pilotes. |
| **P7** | `read` / `clear` hors TTY | Réduire blocages CI / scripts. |
| **P8** | **CI GitHub Actions** | **Maintenant** : workflow [`.github/workflows/ci-checks.yml`](.github/workflows/ci-checks.yml) + guide [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md) (correctif e-mail `action-send-mail`, secrets OVH `dev@…`, job optionnel `if:`). **Ensuite** (après passe [`docs/TESTS.md`](docs/TESTS.md) A→I) : `make test-dotfiles-good`, `make test-dotcli`, stratégie `make test` Docker sur runner ; pas de secrets en clair dans le YAML. |
| **P8b** | **Synchronisation/mise a jour dotfiles multi-machines** | Prochaine grande etape : concevoir un `updateman dotfiles` prudent pour tirer les mises a jour GitHub du coeur (`core/`, `scripts/`, managers, tests, systemd user) sans ecraser les choix locaux par machine. Prevoir analyse des fichiers locaux variables (`pathman`, chemins, secrets, host overrides), sauvegarde, dry-run, detection de conflits, journal, rollback et politique claire entre fichiers versionnes et overrides locaux. |
| **P8d** | **`savemanager` — sauvegarde Git régulière des dotfiles** | Concevoir un manager dédié aux sauvegardes prudentes du dépôt dotfiles via Git : détection des changements utiles, `git status`/diff résumé, commits automatiques optionnels avec message daté, push régulier, dry-run, journal, verrou anti-concurrence et timer `systemd --user`. Objectif : sauvegarde fiable mais économe en ressources (pas de scan lourd inutile, pas de boucle permanente, fréquence configurable, exclusion claire des secrets/caches/gros fichiers). Étudier aussi les modes manuel/interactif (`savemanager status`, `backup`, `enable`, `disable`) et l’articulation avec `updateman dotfiles`. |
| **P8c** | **Registre updateman pour les outils installman** | Base livree (`updatable-tools.list`, `installman` → `updateman <outil> enable`, sous-commandes generiques). **Suite** : ajouter docker, brave, etc. au registre + templates systemd par outil si besoin (pas de fichiers systemd eparpilles hors depot). |
| **P10** | **Matrice shells conteneur** | Après la passe **A→D** « classique » : rejouer **`docs/TESTS.md` § C.3** (`C.3.a` → `C.3.d` : zsh, bash, fish, `sh`) pour valider chargement + smoke + menu **netman → 3** (IP) sur la **même distro**. Optionnel mais recommandé avant de considérer la couverture Docker « complète ». |
| **P11** | **Matrice distro élargie** | Images ou **distrobox** pour Debian, Ubuntu, Manjaro, etc. — smoke `make test` sans toucher l’hôte. Voir [`docs/architecture/E2E_TESTING_VISION.md`](docs/architecture/E2E_TESTING_VISION.md). |
| **P12** | **Lab E2E (VM + enregistrement)** | QEMU/KVM + **asciinema** ou vidéo ; accès VNC pour inspection ; rejouer `TESTS.md` dans VM isolée. |
| **P13** | **Cross-OS (WSL, fish, PowerShell)** | fishrc complet, wrappers Windows, scripts PowerShell pour managers ; parité installation. |
| **P14** | **Personnalisation gitman / profils** | Profils utilisateur activables (conventions branches, hooks) sans casser le gitman générique du dépôt. |
| **P9** | **displayman** (écran / luminosité / DDC) | Nouveau manager [`core/managers/displayman/`](core/managers/displayman/) — DDC/CI via `ddcutil`, preset couleur, range HDMI, guide OSD physique. Convention G.x respectée. **Ensuite** : étape C (override Full Range NVIDIA `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf`) à appliquer après validation manuelle ; tests dans [`docs/TESTS.md`](docs/TESTS.md) G.0 + bloc dédié displayman. Guide complet : [`docs/guides/SCREEN_DISPLAY.md`](docs/guides/SCREEN_DISPLAY.md). |

### Phases A → B → C (rappel)

| Phase | Nom | Contenu |
|-------|-----|--------|
| **A** | Préparatif | `DOTFILES_GOOD/`, `make test-dotfiles-good`, `make test`, inventaire couverture (voir aussi **`docs/TESTS.md`**). |
| **B** | Jalon validation | **Toi** : usage réel + cases § *Jalon* ci-dessous. |
| **C** | Bascule racine | **Uniquement après B** + backup + plan écrit. |

---

## Phase A — tests (rappel)

- **Oui (CI)** : présence fichiers, syntaxe, chargement, lignes `scripts/test/subcommands/*.list`, exit code, timeout.
- **Non (souvent)** : comportement métier complet, sorties exactes → **`docs/TESTS.md`**.

Cases qualité :

- [ ] Définir **niveau 2** : 1–2 sous-commandes pilotes avec **assertion** stdout/stderr/fichier.
- [x] Documenter smoke vs métier : `make test-help`, `SANDBOX.md`.
- [ ] (Optionnel) `scripts/test/expected/...`

### Phase A — déjà livré (extraits)

- [x] Bac `DOTFILES_GOOD/` + `make test-dotfiles-good`.
- [x] Extraits `DOTFILES_GOOD/shared/env/` + README.
- [x] `make docker-in` (distros, `DOCKER_*` dans Makefile).
- [x] `TEST_RESULTS_DIR` inscriptible ; **gitman log** ; **installman** core POSIX sur zsh/bash ; phase 2 ignore shells absents (voir [`docs/ERRORS.md`](docs/ERRORS.md)).

---

## Jalon « DOTFILES_GOOD validé » (phase **B**) — *bloquant pour C*

Cocher quand **toi** tu es satisfait :

- [~] `make test-dotfiles-good` OK (ta machine, dernière branche). *— vérifié via `docs/TESTS.md` § E.2 (2026-05-12 = `O`) ; coche définitivement après ta relecture finale de TESTS.md.*
- [~] `make test` / `make test-docker` (Docker) OK. *— vérifié via `docs/TESTS.md` § E.3 (2026-05-12 = `O`, **69/69 cellules**) puis § **E.4** (2026-06-12 : **81/81 cellules**, **412 tests managers**, `menu_quit_smoke OK`, matrice sous-commandes **114 exécutions / 0 échec** après exclusion du test matériel `displayman detect`) ; coche définitivement après ta relecture finale.*
- [ ] Session réelle avec bootstrap `DOTFILES_GOOD` sans casse bloquante.
- [ ] Décision notée : brancher `shared/config.sh` / entrées shell **oui / non / plus tard**.

> Tant que ce bloc n’est pas validé, la **phase C** reste **documentation uniquement**.

---

## Phase **C** — Bascule racine (après B)

- [ ] Backup complet du dépôt ailleurs.
- [ ] Plan écrit des déplacements / symlinks.
- [ ] Exécution + `make test` + login shell.
- [ ] Procédure rollback testée « à froid ».

---

## Roadmap technique (cases courantes)

- [x] Bac à sable `DOTFILES_GOOD/` + tests associés.
- [x] Tableau managers [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) + `migrated_managers.list`.
- [x] MVP **`dotcli`** + `make test-dotcli`.
- [x] Pilotes dotcli sur **netman** / **aliaman** / **cyberlearn** (flag).
- [ ] TUI mutualisée complète ; **`@skip`** phase 2 à réduire pour menus si invocations non-TTY ajoutées.
- [~] Contrat **responsive terminal** : helpers communs dans `scripts/lib/tui_core.sh` ; pilotes manman + updateman status. **Reste** : etendre aux menus interactifs restants + EXT-002.
- [ ] installman vers `core/` définitif ; **read/clear** hors TTY.
- [ ] **`make test`** vert à chaque étape.
- [x] Smoke menus `0/q` automatisé : `make test-menu-quit` + Phase 2b dans `make test-docker`.
- [ ] Fallback visuel multi-shell (dégradation ASCII).

### Transformation globale (fil directeur)

- [ ] Arborescence cible finale + règles de placement strictes.
- [ ] Contrat unique menus/TUI + fallback non-interactif.
- [ ] Installation « nouvelle machine » guidée + silencieuse.
- [ ] Migration progressive + checkpoints tests.

---

## Produit : `infosman` ?

- [ ] Décision : extension **`searchman info …`** *ou* **`infosman`** (justifier dans [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md)).

---

## Docker `docker-in` — variables (Makefile)

| Variable | Défaut | Rôle |
|----------|--------|------|
| `DOCKER_DOTFILES_DIR` | `/root/dotfiles` | Aligné sur le montage volume. |
| `DOCKER_INSTALLMAN_ASSUME` | `1` | `INSTALLMAN_ASSUME_YES` si `1`. |
| `DOCKER_SHELL` | *(vide)* | Menu shell si TTY. |
| `DOCKER_DISTRO` | *(vide)* | `arch`, `ubuntu`, `debian`, etc. |

Exemples : `make docker-in DOCKER_DISTRO=debian` · `make docker-in DOCKER_SHELL=fish`

---

## Suivi `tail -f` (logs)

`tail -f test_results/test_output.log` : `Ctrl+C` n’arrête que le tail.

## Menu `make tests`

Pause max 5 s par défaut ; `DOTFILES_TEST_MENU_SKIP_PAUSE=1` pour supprimer les pauses.

---

## Finalisées — en attente de validation par moi (**bloquant**)

| ID | Description | Validé par moi |
|----|----------------|----------------|
| V-2026-05-dotcli-doc | Lot dotcli + modules aliaman/cyberlearn ; doc : `docs/STRUCTURE` + `TESTS` + `ERRORS` ; STATUS/TODOS **uniquement racine** | [ ] |
| V-2026-05-doc-suite | Suite doc : bannières, SANDBOX/README, DOTCLI_MENU_CONTRACT, `STRUCTURE_ANALYSIS` → `docs/architecture/` | [ ] |
| V-2026-05-docs-tree | Arborescence `docs/` : 3 fichiers racine + dossiers `architecture/`, `guides/`, etc. | [ ] |
| V-2026-05-tests-start | Procédure `docs/TESTS.md` réécrite (A–I, champs O·N·NA + Assistant relecture) + cible `make tests-start` + menu `scripts/test/tests_manual_start.sh`. | [ ] |
| V-2026-05-doc-index | Hub [`docs/INDEX.md`](docs/INDEX.md) + référentiel [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) ; renvois harmonisés (STATUS / TODOS / ERRORS / STRUCTURE / TESTS / README). | [ ] |
| V-2026-05-doc-split | Scission `STRUCTURE.md` → `STRUCTURE.md` (carte doc) + `CODEMAP.md` (arbo code) ; `README.md` allégé (~82 lignes) ; guides utilisateur dans `docs/guides/` (`INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`). | [ ] |
| V-2026-05-12-cli-help | **Convention aide/CLI unifiée** sur tous les `*man` (stdout sans arg / `help` / `-h` / `aide` ; `help --interactive` = aide + pause TTY ; `--help` = aide + pause + menu interactif ; arg inconnu → stderr + `rc≠0`). Corrige les boucles `aliaman --` / `pathman --bogus` / etc. **Couverture** : `aliaman`, `cyberman`, `pathman`, `multimediaman`, `cyberlearn`, `helpman`, `gitman`, `miscman`, `routeman`, `processman`, `devman`, `virtman`, `searchman`, `testzshman`, `testman`, `fileman`, `sshman`. Tests : `docs/TESTS.md` Bloc G (préalable + G.0 + G.0.b + G.0.c). | [ ] |
| V-2026-05-12-progress | **`core/utils/progress_bar.sh` adaptatif** : `\r` en TTY interactif, ligne par mise à jour en non-TTY (pipe, log, terminal IDE Cursor). Variable `DOTFILES_PROGRESS_PLAIN=1` pour forcer le mode ligne. Plus de réécriture sale dans les logs / `tee` / capture terminal. | [ ] |
| V-2026-05-12-lsblk | **`shared/functions/lsblk_color.sh`** : wrapper `lsblk` colorisant la sortie par TYPE (gras+cyan `disk`, vert `part`, gris `loop`, jaune `raid`, magenta `crypt/lvm/dm`, rouge `rom/tape`). Passe-plat automatique hors TTY ou sur options machine (`-J/-P/-r/-n/-o/-O/-H/--filter/--tree=…/-V`). Forçage : `DOTFILES_LSBLK_FORCE_COLOR=1`. Échappatoire : `DOTFILES_LSBLK_NOCOLOR=1` ou `NO_COLOR`. Chargé via `shared/config.sh` (sh/bash/zsh). | [ ] |
| V-2026-05-12-tests-progress | **`docs/TESTS.md` avancée** : Blocs **A → F.5** validés (verdicts `O` + relectures) ; Bloc **G** étendu aux 23 managers (G.0 + G.0.b reproducteur bug `aliaman --` + G.0.c smoke `aliaman search/list`) ; Bloc **F.6** réécrit (`--no-tui` / `--query` testables + clarification *vrai TUI = F.7*) ; § 12 EXT-002 (petits écrans) + EXT-003 (couleurs ANSI conditionnelles). **2/4 cases Jalon B couvertes** (E.2 + E.3). | [ ] |
| V-2026-05-12-github-ci | **CI GitHub Actions** : guide [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md) (erreurs `content_type` / `from` sur `dawidd6/action-send-mail@v3`, secrets OVH, job e-mail optionnel `if:`) ; workflow [`.github/workflows/ci-checks.yml`](.github/workflows/ci-checks.yml) (`make test-checks`) ; `.github/README.md` ; **EXT-005** + point **6** dans `docs/TESTS.md` ; **P8** dans `TODOS.md`. *(L’ancien workflow « Send Email » sur GitHub doit être corrigé ou fusionné à la main s’il n’est pas dans ce clone.)* | [ ] |
| V-2026-05-13-netman-ip | **`netman` — menu Informations IP** : affichage IPv4/IPv6 corrigé (`ip -4|-6 -o addr show` + `awk`, plus de `grep -B2` / `grep -oP` fragile sur IPv6). Fichiers : [`core/managers/netman/core/netman.sh`](core/managers/netman/core/netman.sh), [`zsh/functions/netman/core/netman.zsh`](zsh/functions/netman/core/netman.zsh). Doc : [`docs/TESTS.md`](docs/TESTS.md) § **C.3** + **EXT-006** ; [`docs/ERRORS.md`](docs/ERRORS.md) ; [`docs/guides/MANAGERS.md`](docs/guides/MANAGERS.md). À valider : menu **3** en TTY (interfaces alignées avec `ip -o`). | [ ] |
| V-2026-05-13-displayman | **Nouveau manager `displayman`** (écran externe / luminosité / DDC) — core POSIX [`core/managers/displayman/core/displayman.sh`](core/managers/displayman/core/displayman.sh), adapters zsh/bash/fish, page man [`docs/man/displayman.md`](docs/man/displayman.md), liste tests CI [`scripts/test/subcommands/displayman.list`](scripts/test/subcommands/displayman.list), enregistré dans `manman` + 3 rc files + `sync_managers.sh` + `scripts/test/config/migrated_managers.list` (24<sup>e</sup> manager) + fallbacks `run_tests.sh` / `test_migrated_managers.sh` / `dotfiles_test_config.sh` + tableau [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md). **Convention G.x** respectée (no-args / help / -h / aide / help --interactive / --help / arg inconnu → stderr+rc1). **Sous-commandes** : `detect`, `info`, `dump`, `brightness`, `contrast`, `preset`, `reset`, `range`, `osd-guide`. **Diagnostic Xiaomi** mené (étape A) : brightness/contraste déjà 100/100, preset `0x0b` (User 1) verrouillé en écriture par firmware. **Guide complet** : [`docs/guides/SCREEN_DISPLAY.md`](docs/guides/SCREEN_DISPLAY.md) (étapes A diag DDC / B OSD physique avec variantes A internationale + B française minimaliste / C Full Range NVIDIA). **Bug firmware** documenté dans [`docs/ERRORS.md`](docs/ERRORS.md). | [ ] |
| V-2026-05-13-fullrange | **Étape C appliquée** — fragment `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf` (`Option "ColorRange" "Full"`) installé `root:root 0644` ; **relog graphique requis** pour observer le changement (noirs plus francs, blancs moins ternes). Rollback : `sudo rm /etc/X11/xorg.conf.d/20-nvidia-fullrange.conf` puis relog. À valider visuellement après relog ; si pire qu'avant → rollback. Lié à `V-2026-05-13-displayman`. | [ ] |
| V-2026-05-22-updateman-cursor | **`updateman cursor`** : updater Cursor AppImage adaptable (`scripts/update/update-cursor-appimage`) + timer `systemd --user` (`systemd/user/cursor-update.service`, `.timer`) + adapters zsh/bash/fish + page man [`docs/man/updateman.md`](docs/man/updateman.md). Detection du Cursor existant via `.desktop`, processus, commande `cursor`, `/opt`, `~/Applications`; installation vers un chemin stable `Cursor.AppImage`, backups `.cursor-backups`, shim `~/.local/bin/cursor`, lanceur desktop. L'updater reste interne : pas de commande publique `update-cursor-appimage`, usage via `updateman cursor`. Base globale : `updateman status` + `updateman all`. Si Cursor est ouvert, le mode manuel propose de fermer proprement l'application ; le timer n'essaie pas de tuer Cursor sans confirmation. A valider : lancer `updateman cursor`, accepter la fermeture de Cursor si demandee, relancer Cursor, verifier `updateman status`, `updateman cursor status` et `updateman cursor logs`. | [ ] |
| V-2026-06-12-menu-quit-docker | **Menus `0/q` + tests Docker + F.7 dotcli** : `ncmenu`/`dotcli --items-file`, `make test-menu-quit`, `make test-dotcli-f7`, Phase 2b Docker, **E.4** + **F.7** dans TESTS.md. Validation auto : managers **81/81**, `menu_quit_smoke OK`, matrice **114/0**, F.7 smoke OK. Reste optionnel : validation visuelle TUI en terminal réel + **Bloc G**. | [ ] |

> **Tant qu’une ligne ci-dessus n’est pas cochée**, considérer que ce lot n’est pas « officiellement » refermé pour enchaîner une nouvelle vague de tâches dépendantes.

---

## Finalisées — validées par moi (plus récent en haut)

*(Déplacer ici les lignes du tableau « attente de validation » une fois cochées, avec date.)*

- *(vide)*

---

## Rappel final — Git

Avant de passer à la **tâche suivante** après une finalisation : **`git add -A`** (ou ciblé), **`git commit`**, **`git push`**.

**Branches** (depuis 2026-06-16) : `main` (prod), `dev` (intégration), `feat/*`, `test/*`, `fix/*`, `preprod`. **Ne pas supprimer** les branches distantes après merge. Guide : [`docs/architecture/GIT_BRANCHING.md`](docs/architecture/GIT_BRANCHING.md).
