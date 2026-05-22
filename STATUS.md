# État instantané du projet (dotfiles)

> **Rôle de ce fichier** : version, **objectifs en cours**, **journal récent**. Il n’y a **ni backlog complet** (→ [`TODOS.md`](TODOS.md)) **ni procédure de test** (→ [`docs/TESTS.md`](docs/TESTS.md)) **ni incidents** (→ [`docs/ERRORS.md`](docs/ERRORS.md)). Pour s’orienter dans la doc : [`docs/INDEX.md`](docs/INDEX.md).

**Dernière mise à jour** : 2026-05-22

## En bref

- **Architecture** : managers sous `core/managers/<nom>/` + adapters `shells/{zsh,bash,fish}/adapters/` ; tests Docker par défaut sur la liste `scripts/test/config/migrated_managers.list`. **diffman** : `diffman compare|side|report` pour diffs colorés / côte à côte / rapports multi-fichiers ([`docs/man/diffman.md`](docs/man/diffman.md)).
- **Socle `dotcli`** : C dans `tools/dotcli/` ; `make build-dotcli` / `make test-dotcli` ; menus pilotés derrière `DOTFILES_DOTCLI_ENABLE=1` (**netman**, **aliaman**, **cyberlearn**) ; mode prudent `DOTFILES_DOTCLI_MENU_NO_TUI=1` ou `dotcli menu --no-tui`.
- **updateman** : registre partage avec **installman** (`updatable-tools.list`) ; `updateman status` / `updateman all` ; `installman cursor` active le timer via `updateman cursor enable` ; pas de commande publique `update-cursor-appimage`.
- **UX terminal** : prochaine amélioration TUI = rendre les menus `*man` adaptatifs aux tailles de terminal (compact, pagination, troncature, fallback non-TTY).
- **CI** : `make test` (managers + matrice sous-commandes) ; rapports sous `TEST_RESULTS_DIR` inscriptible dans le conteneur.

## Objectifs actuels (priorité)

1. Poursuivre la **normalisation modulaire** et la **TUI unifiée** (`dotcli`) sans casser les fallbacks.
2. Stabiliser **`updateman`** : usage unique via `updateman`, pas de commande publique `update-cursor-appimage`; validation `status` / `all` / timer.
3. Concevoir la prochaine etape **registre installman → updateman** puis **`updateman dotfiles`** : mises a jour des outils et du coeur des dotfiles sans ecraser les overrides locaux par machine.
4. Formaliser le contrat **responsive terminal** des interfaces `*man` (largeur/hauteur, mode compact, pagination, CI non-TTY).
5. Compléter les **tests manuels** : [`docs/TESTS.md`](docs/TESTS.md) — entrée menu `make tests-start`.
6. Respecter le **jalon de validation** dans [`TODOS.md`](TODOS.md) avant toute bascule structurelle majeure.

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

1. **Livraison en cours 2026-05-22** — lot **« updateman Cursor »** :
   - **Nouveau manager [`updateman`](core/managers/updateman/core/updateman.sh)** — commandes globales `updateman status`, `updateman all`, puis module `updateman cursor`.
   - **Updater Cursor AppImage** [`scripts/update/update-cursor-appimage`](scripts/update/update-cursor-appimage) : telechargement officiel, detection du Cursor local (`.desktop`, processus, commande `cursor`, `/opt`, `~/Applications`), chemin stable `Cursor.AppImage`, backups, shim `~/.local/bin/cursor`, lanceur desktop.
   - **Commande publique nettoyee** : l'ancien `~/.local/bin/update-cursor-appimage` n'est plus l'interface utilisateur ; le service systemd appelle maintenant `updateman cursor run`.
   - **Automatisation utilisateur** : unites [`systemd/user/cursor-update.service`](systemd/user/cursor-update.service) et [`systemd/user/cursor-update.timer`](systemd/user/cursor-update.timer), installees/activees sur la machine via `updateman cursor enable` (`cursor-update.timer` enabled + active).
   - **Suite planifiee dans `TODOS.md` P3b/P8b/P8c** : responsive terminal pour les menus `*man`, registre `installman` → `updateman` avec services/timers declares, puis `updateman dotfiles` pour synchroniser le coeur du depot depuis GitHub entre machines, avec dry-run, backups, conflits et overrides locaux.
2. **Livraison 2026-05-15** — lot **« diffman »** :
   - **Nouveau manager [`diffman`](core/managers/diffman/core/diffman.sh)** — comparaison de fichiers : `compare` / `cmp` (unifié coloré via `git diff --no-index` ou `diff -u`), `side` (côte à côte `diff -y`), `report` (plusieurs fichiers, option `--all-pairs`), `diff3` si l’outil est présent. Variables `NO_COLOR` / `FORCE_COLOR=1`.
   - **Adapters** zsh / bash / fish + `load_manager` + entrée **`manman`** + liste migrée + [`scripts/test/subcommands/diffman.list`](scripts/test/subcommands/diffman.list) + page man [`docs/man/diffman.md`](docs/man/diffman.md) ; **TESTS.md** : **G.0** (`MANS`), **G.0.e**, tableau **G.25** ; mises à jour **INDEX**, **ARCHITECTURE**, **TODOS**, **CODEMAP**, **MANAGERS**, **sync_managers**.
3. **Dernière livraison notable (2026-05-13)** — lot **« displayman + diagnostic écran »** :
   - **Nouveau manager [`displayman`](core/managers/displayman/core/displayman.sh)** — pilote DDC/CI (`ddcutil`) sur écrans externes : `detect`, `info`, `dump`, `brightness`, `contrast`, `preset`, `reset`, `range`, `osd-guide`. Convention G.x respectée (no-args / `help` / `-h` / `aide` / `help --interactive` / `--help` / arg inconnu → stderr + `rc≠0`).
   - **Adapters** zsh / bash / fish + enregistrement `manman` + 3 rc files + `scripts/tools/sync_managers.sh` + page man [`docs/man/displayman.md`](docs/man/displayman.md) + liste tests CI [`scripts/test/subcommands/displayman.list`](scripts/test/subcommands/displayman.list).
   - **Diagnostic écran Xiaomi (XMI Mi Monitor)** mené : brightness `100/100` et contraste `100/100` côté DDC, preset `0x0b` (User 1) **verrouillé en écriture par le firmware** Mi Monitor (MCCS 2.1). Aller-retour brightness `100→50→100` confirme que le canal DDC fonctionne ; seul le preset couleur est bloqué côté firmware.
   - **Guide complet** [`docs/guides/SCREEN_DISPLAY.md`](docs/guides/SCREEN_DISPLAY.md) — 3 étapes : **A** diagnostic DDC non destructif · **B** OSD physique (joystick au dos, `Picture Mode / HDMI Black Level / Factory Reset`) · **C** Full Range HDMI NVIDIA propriétaire (fragment `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf`, alternatives Intel/AMD via `kscreen-doctor`).
   - **`docs/ERRORS.md`** : entrée ajoutée sur le bug firmware Mi Monitor preset DDC. **`TODOS.md`** : `V-2026-05-13-displayman` en attente + `P9 displayman`. **`docs/TESTS.md`** : bloc test dédié à intégrer (24<sup>e</sup> manager dans G.0).
   - **Étape C appliquée 2026-05-13** : fragment `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf` installé (`Option "ColorRange" "Full"`, `root:root 0644`) → **relog graphique requis** pour effet. Rollback documenté dans `docs/guides/SCREEN_DISPLAY.md`.
   - **Correctif `netman` (menu Informations IP)** : affichage IPv4/IPv6 réécrit avec `ip -4|-6 -o addr show` + `awk` (fini les colonnes vides `:` et les faux noms d’interface sur IPv6). Fichiers : `core/managers/netman/core/netman.sh` + `zsh/functions/netman/core/netman.zsh`. Doc : **`docs/TESTS.md` § C.3** (matrice shells), **EXT-006**, **`docs/ERRORS.md`**, **`TODOS.md` V-2026-05-13-netman-ip** + **P10**.
4. **Livraison 2026-05-12** — lot **« cohérence CLI + UX terminal »** :
   - **Convention aide/CLI unifiée** sur tous les `*man` : `manager` / `help` / `-h` / `aide` → aide stdout non-interactive ; `help --interactive` → aide détaillée + pause si TTY ; `--help` → aide + pause + menu interactif (TTY) ou exit (non-TTY) ; **arg inconnu** → erreur stderr + `rc ≠ 0` (fin des **boucles infinies** type `aliaman --` corrigées sur `aliaman`, `cyberman`, `pathman`, `multimediaman`, `cyberlearn`, etc.).
   - **`core/utils/progress_bar.sh` adaptatif** : `\r` en TTY interactif, ligne par mise à jour en non-TTY (pipe, log, terminal IDE) → plus de réécriture sale. Variable `DOTFILES_PROGRESS_PLAIN=1` pour forcer le mode ligne.
   - **`shared/functions/lsblk_color.sh`** : wrapper `lsblk` colorisant la sortie par TYPE (gras+cyan pour `disk`, vert pour `part`, gris pour `loop`, etc.) en TTY ; passe-plat automatique hors TTY ou avec options machine (`-J/-P/-r/-n/-o/-O`). Chargé via `shared/config.sh` pour sh/bash/zsh.
   - **CI GitHub Actions** : guide [`docs/guides/GITHUB_ACTIONS.md`](docs/guides/GITHUB_ACTIONS.md) (correctif `dawidd6/action-send-mail` : pas de `content_type`, secret `EMAIL_FROM` obligatoire ou job `if:`) ; workflow [`.github/workflows/ci-checks.yml`](.github/workflows/ci-checks.yml) (`make test-checks` sur Ubuntu). Roadmap CI complète → **`TODOS.md` P8**.
   - **TESTS.md Blocs A → F.5** validés (verdicts `O` posés + relectures) ; Bloc G étendu aux 23 managers (G.0 + G.0.b reproducteur `aliaman --` + G.0.c smoke `aliaman search/list`) ; F.6 réécrit (l’ancienne consigne « pipe + TUI » était contradictoire).
   - **Jalon B avance** : 2/4 cases couvertes par TESTS.md E.2 (`make test-dotfiles-good : OK`) et E.3 (`make test : 69/69 cellules OK`). Restent à valider : *session réelle bootstrap DOTFILES_GOOD* + *décision branchement entrées shell*.
5. **Livraison 2026-05-11 (2)** — scission `docs/STRUCTURE.md` → **`STRUCTURE` (carte doc)** + **`CODEMAP.md` (arborescence code)** ; simplification **`README.md`** (3107 → ~82 lignes) ; contenu détaillé déplacé dans **`docs/guides/`** : `INSTALL.md`, `USAGE.md`, `MANAGERS.md`, `DOCKER.md`, `VM.md`. Mise à jour `INDEX.md` + bandeaux thématiques.
6. **Livraison 2026-05-11 (1)** — réorganisation doc : ajout [`docs/INDEX.md`](docs/INDEX.md) (hub) et [`docs/LEGENDE_CHAMPS.md`](docs/LEGENDE_CHAMPS.md) (référentiel format d’étapes) ; allègement [`docs/TESTS.md`](docs/TESTS.md) ; clarification rôles STATUS / TODOS / ERRORS.
7. **Livraison 2026-05-06** — `dotcli` (TUI, `--no-tui`, dry-run), pilotes netman/aliaman/cyberlearn, modules aliaman/cyberlearn.
8. **À faire maintenant** : valider `updateman status` / `updateman cursor` en réel, puis finir [`docs/TESTS.md`](docs/TESTS.md) — Blocs **F.6 → I** (optionnel : **§ C.3** matrice shells zsh/bash/fish/sh + validation menu **netman → 3**) ; cocher Jalon B au § correspondant de `TODOS.md` ; valider les lignes « En attente de validation » ; concevoir **P3b** responsive terminal, **P8c** registre outils et **P8b** `updateman dotfiles`.

| Période | Sujet |
|---------|--------|
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
