# État instantané du projet (dotfiles)

> **Rôle de ce fichier** : version, **objectifs en cours**, **journal récent**. Il n’y a **ni backlog complet** (→ [`TODOS.md`](TODOS.md)) **ni procédure de test** (→ [`docs/TESTS.md`](docs/TESTS.md)) **ni incidents** (→ [`docs/ERRORS.md`](docs/ERRORS.md)). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md).

**Dernière mise à jour** : 2026-06-12

## En bref

- **Architecture** : managers sous `core/managers/<nom>/` + adapters `shells/{zsh,bash,fish}/adapters/` ; tests Docker par défaut sur la liste `scripts/test/config/migrated_managers.list`. **diffman** : diffs colorés / rapports ; **diskman** : diagnostic disque et nettoyage prudent (`clean --dry-run` par défaut).
- **Socle `dotcli`** : C dans `tools/dotcli/` ; `make build-dotcli` / `make test-dotcli` ; menus pilotés derrière `DOTFILES_DOTCLI_ENABLE=1` (**netman**, **aliaman**, **cyberlearn**) ; mode prudent `DOTFILES_DOTCLI_MENU_NO_TUI=1` ou `dotcli menu --no-tui`.
- **updateman** : registre partage avec **installman** (`updatable-tools.list`) ; `updateman status` / `updateman all` ; `installman cursor` active le timer via `updateman cursor enable` ; pas de commande publique `update-cursor-appimage`.
- **UX terminal / menus** : P3b est separe en **P3b-a** (restructuration UI/menus : `shared/` vs `share/`, adapters minces, selection commune `manager_ui_select_file`, `dfm` declaratif avec fallback pagine + pause apres action) puis **P3b-b** (adaptatif pur). Docs : [`docs/architecture/UI_MENU_RESTRUCTURE.md`](docs/architecture/UI_MENU_RESTRUCTURE.md), [`core/managers/MANAGERS_UI.md`](core/managers/MANAGERS_UI.md), [`share/menus/README.md`](share/menus/README.md).
- **CI** : `make test` (managers + matrice sous-commandes) ; rapports sous `TEST_RESULTS_DIR` inscriptible dans le conteneur.

## Objectifs actuels (priorité) — reprise prévue plus tard

1. **P3b-b (suite)** : `tui_truncate`, pagination menus longs, validation manuelle terminaux étroits (EXT-002) ; vérifier les managers non encore alignés (cyberman, installman, etc.).
2. **`updateman`** : validation manuelle `status` / `all` / timer (V-2026-05-22-updateman-cursor).
3. **P1** : adapters minces, menus `dotcli` ; **P8b** / **P8c** : `updateman dotfiles`, registre outils.
4. **Tests** : [`docs/TESTS.md`](docs/TESTS.md) — Blocs F.6 → I ; `make test-tui-compact` en CI locale avant reprise.
5. Jalon de validation [`TODOS.md`](TODOS.md) avant bascule structurelle majeure.

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

1. **Livraison 2026-06-12** — lot **« diskman »** :
   - **Nouveau manager [`diskman`](core/managers/diskman/core/diskman.sh)** — diagnostic disque : `overview`, `usage`, `biggest`, `inodes`, `mounts`, `health`, `clean`, `report`. Le nettoyage est **dry-run par défaut** ; l’exécution réelle demande `--apply` et confirmation TTY (ou `--yes` en non-TTY contrôlé).
   - **Adapters** zsh / bash / fish + `load_manager` + entrée **`manman`** + liste migrée + [`scripts/test/subcommands/diskman.list`](scripts/test/subcommands/diskman.list) + page man [`docs/man/diskman.md`](docs/man/diskman.md) ; **TESTS.md** : **G.0.f**, tableau **G.26**.
2. **Livraison 2026-05-22** — lots **dfm**, **P3b-b**, **sortie menus** :
   - **`dfm`** (`600a3be`) : fallback pagine, pause apres action.
   - **P3b-b** (`f9b130c`, `d660c9a`) : bannieres, `manager_ui_section_line`, smoke terminal etroit.
   - **Menus quit** (`0e5647a`) : `0` / `q` pour quitter `*man --help` (plus de boucle infinie + Ctrl+C) ; fzf adapte petits terminaux (69×24) ; `make test-tui-compact` elargi.
   - **Pause documentee** : reprise P3b-b / tests manuels / updateman — voir [`TODOS.md`](TODOS.md).
3. **Livraison en cours 2026-05-22** — lot **« updateman Cursor »** :
   - **Nouveau manager [`updateman`](core/managers/updateman/core/updateman.sh)** — commandes globales `updateman status`, `updateman all`, puis module `updateman cursor`.
   - **Updater Cursor AppImage** [`scripts/update/update-cursor-appimage`](scripts/update/update-cursor-appimage) : telechargement officiel, detection du Cursor local (`.desktop`, processus, commande `cursor`, `/opt`, `~/Applications`), chemin stable `Cursor.AppImage`, backups, shim `~/.local/bin/cursor`, lanceur desktop.
   - **Commande publique nettoyee** : l'ancien `~/.local/bin/update-cursor-appimage` n'est plus l'interface utilisateur ; le service systemd appelle maintenant `updateman cursor run`.
   - **Automatisation utilisateur** : unites [`systemd/user/cursor-update.service`](systemd/user/cursor-update.service) et [`systemd/user/cursor-update.timer`](systemd/user/cursor-update.timer), installees/activees sur la machine via `updateman cursor enable` (`cursor-update.timer` enabled + active).
   - **Validation manuelle debloquee** : si Cursor est ouvert, `updateman cursor` propose de le fermer proprement en terminal interactif ; hors TTY, le timer echoue proprement et reessaiera plus tard.
   - **2026-05-22 (suite)** : registre `updatable-tools.list` ; `installman` appelle `updateman <outil> enable` ; shim `update-cursor` retire de `shared/config.sh` ; helpers TUI et pilotes manman/updateman status.
   - **Suite planifiee** : P3b (autres `*man`), P8c (plus d'outils au registre), P8b (`updateman dotfiles`).
4. **Livraison 2026-05-15** — lot **« diffman »** :
   - **Nouveau manager [`diffman`](core/managers/diffman/core/diffman.sh)** — comparaison de fichiers : `compare` / `cmp` (unifié coloré via `git diff --no-index` ou `diff -u`), `side` (côte à côte `diff -y`), `report` (plusieurs fichiers, option `--all-pairs`), `diff3` si l’outil est présent. Variables `NO_COLOR` / `FORCE_COLOR=1`.
   - **Adapters** zsh / bash / fish + `load_manager` + entrée **`manman`** + liste migrée + [`scripts/test/subcommands/diffman.list`](scripts/test/subcommands/diffman.list) + page man [`docs/man/diffman.md`](docs/man/diffman.md) ; **TESTS.md** : **G.0** (`MANS`), **G.0.e**, tableau **G.25** ; mises à jour **INDEX**, **ARCHITECTURE**, **TODOS**, **CODEMAP**, **MANAGERS**, **sync_managers**.
5. **Dernière livraison notable (2026-05-13)** — lot **« displayman + diagnostic écran »** :
   - **Nouveau manager [`displayman`](core/managers/displayman/core/displayman.sh)** — pilote DDC/CI (`ddcutil`) sur écrans externes : `detect`, `info`, `dump`, `brightness`, `contrast`, `preset`, `reset`, `range`, `osd-guide`. Convention G.x respectée (no-args / `help` / `-h` / `aide` / `help --interactive` / `--help` / arg inconnu → stderr + `rc≠0`).
   - **Adapters** zsh / bash / fish + enregistrement `manman` + 3 rc files + `scripts/tools/sync_managers.sh` + page man [`docs/man/displayman.md`](docs/man/displayman.md) + liste tests CI [`scripts/test/subcommands/displayman.list`](scripts/test/subcommands/displayman.list).
   - **Diagnostic écran Xiaomi (XMI Mi Monitor)** mené : brightness `100/100` et contraste `100/100` côté DDC, preset `0x0b` (User 1) **verrouillé en écriture par le firmware** Mi Monitor (MCCS 2.1). Aller-retour brightness `100→50→100` confirme que le canal DDC fonctionne ; seul le preset couleur est bloqué côté firmware.
   - **Guide complet** [`docs/guides/SCREEN_DISPLAY.md`](docs/guides/SCREEN_DISPLAY.md) — 3 étapes : **A** diagnostic DDC non destructif · **B** OSD physique (joystick au dos, `Picture Mode / HDMI Black Level / Factory Reset`) · **C** Full Range HDMI NVIDIA propriétaire (fragment `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf`, alternatives Intel/AMD via `kscreen-doctor`).
   - **`docs/ERRORS.md`** : entrée ajoutée sur le bug firmware Mi Monitor preset DDC. **`TODOS.md`** : `V-2026-05-13-displayman` en attente + `P9 displayman`. **`docs/TESTS.md`** : bloc test dédié à intégrer (24<sup>e</sup> manager dans G.0).
   - **Étape C appliquée 2026-05-13** : fragment `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf` installé (`Option "ColorRange" "Full"`, `root:root 0644`) → **relog graphique requis** pour effet. Rollback documenté dans `docs/guides/SCREEN_DISPLAY.md`.
   - **Correctif `netman` (menu Informations IP)** : affichage IPv4/IPv6 réécrit avec `ip -4|-6 -o addr show` + `awk` (fini les colonnes vides `:` et les faux noms d’interface sur IPv6). Fichiers : `core/managers/netman/core/netman.sh` + `zsh/functions/netman/core/netman.zsh`. Doc : **`docs/TESTS.md` § C.3** (matrice shells), **EXT-006**, **`docs/ERRORS.md`**, **`TODOS.md` V-2026-05-13-netman-ip** + **P10**.
6. **Livraison 2026-05-12** — lot **« cohérence CLI + UX terminal »** :
   - **Convention aide/CLI unifiée** sur tous les `*man` : `manager` / `help` / `-h` / `aide` → aide stdout non-interactive ; `help --interactive` → aide détaillée + pause si TTY ; `--help` → aide + pause + menu interactif (TTY) ou exit (non-TTY) ; **arg inconnu** → erreur stderr + `rc ≠ 0` (fin des **boucles infinies** type `aliaman --` corrigées sur `aliaman`, `cyberman`, `pathman`, `multimediaman`, `cyberlearn`, etc.).
   - **`core/utils/progress_bar.sh` adaptatif** : `\r` en TTY interactif, ligne par mise à jour en non-TTY (pipe, log, terminal IDE) → plus de réécriture sale. Variable `DOTFILES_PROGRESS_PLAIN=1` pour forcer le mode ligne.
   - **`shared/functions/lsblk_color.sh`** : wrapper `lsblk` colorisant la sortie par TYPE (gras+cyan pour `disk`, vert pour `part`, gris pour `loop`, etc.) en TTY ; passe-plat automatique hors TTY ou avec options machine (`-J/-P/-r/-n/-o/-O`). Chargé via `shared/config.sh` pour sh/bash/zsh.
   - **CI GitHub Actions** : guide [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md) (correctif `dawidd6/action-send-mail` : pas de `content_type`, secret `EMAIL_FROM` obligatoire ou job `if:`) ; workflow [`.github/workflows/ci-checks.yml`](.github/workflows/ci-checks.yml) (`make test-checks` sur Ubuntu). Roadmap CI complète → **`TODOS.md` P8**.
   - **TESTS.md Blocs A → F.5** validés (verdicts `O` posés + relectures) ; Bloc G étendu aux 23 managers (G.0 + G.0.b reproducteur `aliaman --` + G.0.c smoke `aliaman search/list`) ; F.6 réécrit (l’ancienne consigne « pipe + TUI » était contradictoire).
   - **Jalon B avance** : 2/4 cases couvertes par TESTS.md E.2 (`make test-dotfiles-good : OK`) et E.3 (`make test : 69/69 cellules OK`). Restent à valider : *session réelle bootstrap DOTFILES_GOOD* + *décision branchement entrées shell*.
7. **Livraison 2026-05-11 (2)** — scission `docs/STRUCTURE.md` → **`STRUCTURE` (carte doc)** + **`CODEMAP.md` (arborescence code)** ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** : `INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`. Mise à jour `INDEX.md` + bandeaux thématiques.
8. **Livraison 2026-05-11 (1)** — réorganisation doc : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub) et [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel format d’étapes) ; allègement [`docs/TESTS.md`](docs/TESTS.md) ; clarification rôles STATUS / TODOS / ERRORS.
9. **Livraison 2026-05-06** — `dotcli` (TUI, `--no-tui`, dry-run), pilotes netman/aliaman/cyberlearn, modules aliaman/cyberlearn.
10. **À la reprise** : valider `updateman` en reel ; P3b-b restant ; [`docs/TESTS.md`](docs/TESTS.md) F.6 → I ; **P8c** / **P8b**.

| Période | Sujet |
|---------|--------|
| 2026-06-12 | **diskman** (diagnostic disque, nettoyage dry-run/apply, rapport) |
| 2026-05-22 | **updateman cursor/status/all** (Cursor AppImage + timer systemd user) ; P3b/P8b/P8c planifies |
| 2026-05-15 | **diffman** (diff coloré, rapports) + doc INDEX / ARCHITECTURE / TODOS |
| 2026-05-13 | displayman + écran / **netman** (fix IP `ip -o`) + **TESTS § C.3** matrice shells + jalons doc |
| 2026-05-12 | CI GitHub : `ci-checks.yml` + guide GITHUB_ACTIONS (e-mail / secrets) |
| 2026-05-12 | convention aide/CLI unifiée (`*man`) + fix boucles arg inconnu |
| 2026-05-12 | progress_bar adaptatif TTY / non-TTY |
| 2026-05-12 | wrapper `lsblk` colorisé (POSIX, auto-disable hors TTY) |
| 2026-05 | dotcli + menus managers |
| 2026-05 | tee RO → `TEST_RESULTS_DIR` hors dépôt |
| 2026-05 | gitman / installman matrice |

---

## Règle de fin de cycle (obligatoire)

Avant de considérer une **tâche finalisée** comme acquise pour enchaîner la suivante (voir `TODOS.md`, section validation) :

1. **Tu valides** explicitement la tâche dans `TODOS.md` (case / tableau).
2. Tu enregistres le travail dans Git : **`git add`**, **`git commit`**, **`git push`** (ou équivalent sur ta branche).

Sans cette validation, la **suite du planning** reste en attente par convention du dépôt.
