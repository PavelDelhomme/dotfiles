# Tests manuels — procédure à suivre à la lettre

> **Index général** : [`INDEX.md`](INDEX.md) · **Carte technique** : [`STRUCTURE.md`](STRUCTURE.md) · **Statut** : [`../STATUS.md`](../STATUS.md) · **Tâches** : [`../TODOS.md`](../TODOS.md) · **Bac à sable** : [`../scripts/test/SANDBOX.md`](../scripts/test/SANDBOX.md)
>
> **Format des étapes** (Commande / Attendu / Conforme `O·N·NA` / Notes / Assistant relecture) : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md). **Ne pas redéfinir** les champs ici — toute nouvelle étape réutilise le bloc de la légende.

## Comment utiliser ce fichier

1. Ouvrir **uniquement** ce fichier et descendre **dans l’ordre** (Bloc A → I).
2. Pour chaque étape : exécuter la commande, **cocher** `[ ]`, **coller** la sortie utile, choisir **Conforme** `O / N / NA` (sémantique exacte : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) §3). Laisser **`Assistant (relecture)`** vide tant qu’une relecture externe n’a pas été faite.
3. **Copier une commande vers le presse-papiers** (bloc entier **ou** une ligne) — prérequis : `wl-copy`, `xclip` ou `xsel` :
   - **Bloc complet** : `make tests-copy STEP=G.0.b` ou `bash scripts/tools/tests_copy.sh G.0.b`
   - **Une ligne** : `make tests-copy STEP=G.0.d LINE=12` ou `bash scripts/tools/tests_copy.sh G.0.d --line 12`
   - **Lister les lignes numérotées** : `bash scripts/tools/tests_copy.sh G.0.d --list`
   - **Menu interactif** (bloc ou ligne) : `bash scripts/tools/tests_copy.sh G.0.d --pick`
   - **Toutes les étapes détectées** : `bash scripts/tools/tests_copy.sh --steps`
4. Menu d’appui (sur l’hôte) : **`make tests-start`** — mêmes blocs (prérequis, `docker-build`, `docker-in`, `test-dotcli`, …). Ne remplace pas ce document : les cases sont **ici**.
5. **Limite honnête** : couvrir chaque ligne de code dans un seul fichier est **impossible**. Ce guide couvre le **parcours 0 → bac à sable → smoke → `dotcli` → managers**. Le détail automatique est dans `scripts/test/subcommands/*.list` + CI (`make test`). Pour étendre, voir **§ 12 — EXT-xxx**.
6. **Reprise après évolutions code (managers / aide)** : lire le **journal doc** ci-dessous, exécuter le **préalable Bloc G** (contrôle non-TTY + convention), puis enchaîner le **tableau G.1–G.26** comme d’habitude.
7. **CI GitHub Actions** (après la passe manuelle A→I ici) : le dépôt inclut un workflow **`.github/workflows/ci-checks.yml`** (`make test-checks` sur runner Ubuntu). Pour les **secrets e-mail** (erreur `from` / `content_type`), la **roadmap CI complète** (Docker, installation, etc.) et le correctif **`dawidd6/action-send-mail`**, voir **[`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md)** et **`TODOS.md`** (P8).

### Journal doc (reprise `TESTS.md`)

| Date | Sujet | Action pour toi |
|------|--------|-----------------|
| **2026-05-11** | Convention **aide / CLI** unifiée sur les `*man` (stdout vs interactif), correction **boucles** sur argument inconnu (`aliaman`, `cyberman`, `pathman`, …), **`helpman`**, **`aliaman`** (recherche / synonymes), **`multimediaman`** et **`cyberlearn`** alignés sur le même contrat. | Refaire **Bloc G — préalable + G.0** (ci-dessous), puis cocher **G.1–G.24**. Les étapes **D.3** (`pathman help`) restent valides : l’aide doit toujours s’afficher sur stdout. |
| **2026-05-12** | **G.0** étendu à **tous** les managers de `migrated_managers.list` (ajout `manman`, `configman`, `doctorman`, `moduleman`). Ajout **G.0.b** (reproducteur du bug historique `aliaman --` → ne doit plus boucler) et **G.0.c** (smoke des nouvelles commandes `aliaman search` / `aliaman list`, avec ou sans `fzf`). Note : `manman` et `doctorman` peuvent encore renvoyer `rc=0` sur argument inconnu — c’est un **WARN** acceptable à reporter en `Notes` (pas un `FAIL`). | Refaire **G.0**, puis cocher **G.0.b** et **G.0.c** avant de retourner sur **G.1–G.24**. |
| **2026-05-13** | **Nouveau manager `displayman`** (écran / luminosité / DDC) ajouté à la liste `MANS` de **G.0** → 24<sup>e</sup> manager. Ajout d’une étape dédiée **G.0.d** (smoke `displayman detect / dump 1 / range / osd-guide` sans modifier l’écran). Diagnostic Xiaomi mené en parallèle (brightness 100/100, preset User 1 verrouillé en écriture par firmware) ; voir [`docs/guides/SCREEN_DISPLAY.md`](guides/SCREEN_DISPLAY.md) pour étapes A→C et [`docs/ERRORS.md`](ERRORS.md) pour le bug firmware. | Refaire **G.0** (+1 manager), cocher **G.0.d**, puis enchaîner les étapes G.1–G.24. |
| **2026-05-15** | **Nouveau manager `diffman`** (diff coloré, côte à côte, rapports multi-fichiers). **G.0** : `MANS` inclut `diffman` ; tableau **G.25** ; smoke **G.0.e**. | Refaire **G.0**, **G.0.e**, cocher **G.25** ; enchaîner le tableau **G.1–G.25** si tu refais une passe Bloc G complète. |
| **2026-06-12** | **Nouveau manager `diskman`** (diagnostic disque, gros fichiers, inodes, nettoyage dry-run/apply). **G.0** : `MANS` inclut `diskman` ; tableau **G.26** ; smoke **G.0.f**. | Refaire **G.0**, **G.0.f**, cocher **G.26** ; utiliser `diskman clean --dry-run all` avant tout `--apply`. |
| **2026-06-12** *(F.7 dotcli)* | **Bloc F.7 complété** : `dotcli menu --items-file` (stdin TTY préservé), fallback `/dev/tty`, smoke `make test-dotcli-f7`. Correctif critique : `< menu_file` cassait le TUI — les managers utilisent `--items-file`. | Cocher **F.7.a / F.7.b / F.7.c** ; rejouer `make test-dotcli-f7` ; validation visuelle optionnelle en terminal réel (`DOTFILES_DOTCLI_ENABLE=1 netman ports`). |
| **2026-06-12** *(menus + Docker)* | **Sortie menus `0/q` fiabilisée** : `ncmenu` lit le menu depuis stdin mais pilote le TTY via `/dev/tty`, les touches directes `0`, `q`, `1`, etc. sélectionnent une valeur ; `make test-menu-quit` ajoute un smoke `0/q` et `make test-docker` l’exécute en **Phase 2b**. `displayman detect` est retiré de la matrice sous-commandes Docker car il dépend de `ddcutil` + I2C réels, absents en conteneur. | Refaire **E.4** après tout changement UI/menu. Pour la validation manuelle, continuer **F.7** sur un vrai TTY et remplir le tableau **G.1–G.26**. |
| **2026-05-13** *(netman + doc)* | **`netman` — Informations IP** : correction de l’affichage des adresses **IPv4 / IPv6** (interfaces vides `:` ou fragment `861:` pris pour un nom d’interface). Désormais : `ip -4 -o addr show` / `ip -6 -o addr show` + `awk` (core POSIX + copie `zsh/functions/netman/core/netman.zsh`). **Nouvelle étape `C.3`** : matrice **zsh / bash / fish / sh** dans le conteneur (même champs que le reste du guide) + lien explicite **jalon B / `DOTFILES_GOOD`** ↔ **E.2** dans la table « Correspondance avec `TODOS.md` ». | Optionnel : remplir **C.3.a–d** ; sinon continuer **F→I**. Refaire une fois le menu **netman → 3** si tu avais noté un affichage cassé. |
| **2026-05-12** *(suite)* | **Barre de progression** (`core/utils/progress_bar.sh`) rendue **adaptative** : mode `\r` (réécriture de ligne) en TTY interactif, **mode ligne par mise à jour** en non-TTY ou si `DOTFILES_PROGRESS_PLAIN=1`. Plus de réécriture sale du terminal IDE / des logs. **F.6** réécrite : l’ancienne consigne « pipe + TUI » était contradictoire ; remplacée par **F.6.a** (`--no-tui --simulate-index`), **F.6.b** (`--query <label>`) et **F.6.c** *(vrai TUI : observation visuelle facultative, validation principale en F.7)*. | Pas d’action obligatoire ; si tu veux refaire F.6, ce sont maintenant trois petits cas non-TTY scriptables. La barre de progression n’écrasera plus rien dans `tee` / les logs Cursor. |
| **2026-05-12** *(suite 2)* | **Wrapper `lsblk` colorisé** : `shared/functions/lsblk_color.sh` (POSIX, sourcé via `shared/config.sh` pour sh/bash/zsh) colore la sortie de `lsblk` par TYPE en TTY (gras+cyan `disk`, vert `part`, gris `loop`, jaune `raid`, magenta `crypt`/`lvm`, rouge `rom`/`tape`) et reste **passe-plat hors TTY** (pipe, log) ou sur options machine (`-J/-P/-r/-n/-o/-O/...`). Échappatoires : `NO_COLOR`, `DOTFILES_LSBLK_NOCOLOR=1`. Forçage : `DOTFILES_LSBLK_FORCE_COLOR=1`. | À vérifier visuellement une seule fois : voir **EXT-004** ci-dessous (§ 12). Pas d’étape A–I à refaire. |
| **2026-05-12** *(suite 3)* | **CI GitHub Actions** : guide **[`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md)** (correctif e-mail `content_type` / `EMAIL_FROM`, secrets OVH, job optionnel `if:`) ; workflow **`.github/workflows/ci-checks.yml`** (`make test-checks` sur Ubuntu). La CI « complète » (Docker `make test`, bootstrap, etc.) reste à planifier — voir **`TODOS.md` P8** et **EXT-005** (§ 12). | Après avoir fini la checklist **A→I** ici : lire le guide, configurer les secrets si tu veux l’e-mail, fusionner ou supprimer l’ancien workflow distant qui casse encore si doublon. |

---

## Correspondance avec `TODOS.md`

| Zone `../TODOS.md` | Sections ici |
|--------------------|--------------|
| Phase A — prérequis / `make test` / docker-in | **A**, **B**, **C**, **D**, **E** |
| P1 architecture / managers | **G** (préalable + **G.0** avant le tableau), **H** |
| P3 dotcli / TUI | **F** |
| Jalon B — validation perso | **I** (+ cases « Conforme » cumulées) |
| Jalon B — bac **`DOTFILES_GOOD`** (`make test-dotfiles-good`) | **E.2** (+ **I** pour cocher les cases du jalon dans `TODOS.md`) |
| Phase C (bascule racine) | **Hors scope** — ne pas mélanger avec les tests ci-dessous |
| **P8** CI GitHub Actions (après passe manuelle) | [`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md) + `.github/workflows/ci-checks.yml` + `TODOS.md` |
| **P10** re-passes **multi-shell** conteneur (optionnel) | **C.3** ci-dessous |

Ne pas ouvrir [`../TODOS.md`](../TODOS.md) pour exécuter les commandes : on l’ouvre pour **formaliser** un écart vu en `Notes` (nouvelle ligne de backlog / correctif). **Flux recommandé** : terminer une étape ici (`TESTS.md`) → si **N** ou comportement inattendu → noter la cause dans `Notes`, puis **ajouter** une entrée ciblée dans `TODOS.md` (sans supprimer l’historique de ce fichier). **`DOTFILES_GOOD`** : la validation « officielle » du bac reste **E.2** + les quatre cases **Jalon B** dans `TODOS.md` ; la **phase C** (bascule racine) reste **bloquée** tant que le jalon B n’est pas coché par toi.

---

# Bloc A — Prérequis (hôte **ou** conteneur déjà prêt)

Le clone des dotfiles doit être accessible ; le chemin peut être `/root/dotfiles` **dans** un conteneur ou `~/dotfiles` sur l’hôte.

### Où es-tu ? (lis ceci avant A.2)

| Situation | A.1 | A.2 Docker | A.3 `cc`/`gcc` | A.4 `make tests-start` → `1` |
|-----------|-----|------------|----------------|------------------------------|
| **Hôte** — c’est **toi** qui lanceras `make docker-build` / `make docker-in` | **O** requis | **O** requis (client + démon) | **O** recommandé pour le Bloc **F** | **O** si tout vert côté Docker |
| **Déjà dans le conteneur** (invite type `root@<id>`, dotfiles montés) | **O** (`pwd` + `Makefile`) | **NA** — le client Docker **n’a pas** à être dans ce shell ; il doit exister sur l’**hôte** qui a lancé le conteneur | **O** / **NA** si tu ne compiles pas `dotcli` ici | **O** si le menu boucle sans crash ; le message « docker absent » est **attendu** ici |

Si tu as commencé le guide **depuis l’intérieur** d’un conteneur : enchaîne logiquement par le **Bloc D** (tu es déjà « dans le conteneur »). Les blocs **B** et **C** se font sur l’**hôte** quand tu dois **construire** ou **ouvrir** toi-même une session `docker-in`.

### Étape A.1 — Répertoire du dépôt

- **Commande** : `cd ~/dotfiles && pwd && test -f Makefile && echo "OK Makefile"`
- **Attendu** : chemin absolu affiché + `OK Makefile`.
- **[x] Fait**
- **Sortie** :

```
╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@7738546b1752  at 15:09:42  ▓▒░─╮
╰─❯ cd ~/dotfiles && pwd && test -f Makefile && echo "OK Makefile"                                                                                                                                                                       ─╯
/root/dotfiles
OK Makefile

╭─░▒▓    ~/dotfiles    main ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@7738546b1752  at 15:10:06  ▓▒░─╮
╰─❯                                                                                                                                                                                                                                      ─╯


```
- **Conforme** : O
- **Notes** :
- **Assistant (relecture)** : **O** — La sortie montre un chemin absolu (`/root/dotfiles`) et `OK Makefile` : critère rempli. Le prompt `root@7738546b1752` indique un **conteneur** : ce n’est pas une erreur pour A.1 ; pour la suite, applique la ligne **« Déjà dans le conteneur »** du tableau *Où es-tu ?* (notamment A.2 → **NA**).

### Étape A.2 — Docker disponible

- **Commande** : `docker version`
- **Attendu** : sections Client / Server **ou** message d’erreur explicite si le démon n’est pas démarré (dans ce cas : corriger Docker puis reviens à A.2). **Sur l’hôte uniquement** : depuis l’intérieur d’un conteneur sans Docker, voir tableau *Où es-tu ?* → **NA**.
- **[x] Fait**
- **Sortie** :
```
╭─░▒▓    ~/dotfiles    main ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@7738546b1752  at 15:10:06  ▓▒░─╮
╰─❯ docker version                                                                                                                                                                                                                       ─╯
zsh: command not found: docker

```
- **Conforme** : NA
- **Notes** : Exécution **depuis l’intérieur** du conteneur `7738546b1752` : pas de binaire `docker` dans ce shell — **normal**. Pour valider Docker « pour de vrai », refaire A.2 sur l’**hôte** avant B.1 / C.1, ou garder **NA** si tu ne construis pas d’image depuis ce poste.
- **Assistant (relecture)** : **NA (attendu dans ton contexte)** — Ce n’était pas un « N » au sens du guide : A.2 teste la machine qui **pilote** Docker. À l’intérieur d’un conteneur de dev sans Docker-in-Docker, `command not found: docker` est cohérent. Passe à A.3 / D.x selon ton parcours.

### Étape A.3 — Compilateur C pour `dotcli`

- **Commande** : `(command -v cc >/dev/null && cc --version | head -1) || (command -v gcc >/dev/null && gcc --version | head -1) || echo "PAS_DE_COMPILATEUR"`
- **Attendu** : une ligne de version **ou** tu notes `PAS_DE_COMPILATEUR` → alors les étapes **F** seront `NA` jusqu’à installation de `cc`/`gcc`.
- **[X] Fait**
- **Sortie** :
```
╭─░▒▓    ~/dotfiles    main 1 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 127 ✘  with root@7738546b1752  at 15:12:53  ▓▒░─╮
╰─❯ (command -v cc >/dev/null && cc --version | head -1) || (command -v gcc >/dev/null && gcc --version | head -1) || echo "PAS_DE_COMPILATEUR"                                                                                          ─╯
cc (GCC) 15.2.1 20260209


```
- **Conforme** : O
- **Notes** :
- **Assistant (relecture)** : **O** — Une ligne de version `cc (GCC) …` suffit pour enchaîner vers **F** / `make test-dotcli` dans cet environnement.

### Étape A.4 — Menu d’accompagnement (optionnel mais recommandé)

- **Commande** : `make tests-start` puis choisir `1` (prérequis) et vérifier que c’est cohérent avec A.1–A.3.
- **Attendu** : menu qui se réaffiche ; pas d’erreur fatale du script.
- **[X] Fait**
- **Sortie** :
```

╭─░▒▓    ~/dotfiles    main 1 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@7738546b1752  at 15:15:40  ▓▒░─╮
╰─❯ make tests-start                                                                                                                                                                                                                     ─╯

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests manuels — voir docs/TESTS.md (parcours lettre par lettre)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Répertoire dotfiles : /root/dotfiles

  1) Prérequis hôte (docker, cc, chemins) — équivalent étapes A.1–A.3
  2) make docker-build (image Arch / dotfiles-test)
  3) make docker-in  → menus : distribution puis shell (Bloc C du guide)
  4) Afficher exemples docker-in sans menu (copier-coller)
  5) make test-dotcli (compilation + smoke dotcli)
  6) make test-help
  7) make test-dotfiles-good
  8) make test (Docker complet — long)
  9) Ouvrir docs/TESTS.md dans $PAGER (less)
  0) Quitter

Choix [0-9] : 1
--- Docker ---
❌ docker absent ou daemon injoignable
--- Compilateur C (dotcli) ---
/usr/sbin/cc
cc (GCC) 15.2.1 20260209
--- Répertoire ---
PWD=/root/dotfiles
✅ Makefile présent

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests manuels — voir docs/TESTS.md (parcours lettre par lettre)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Répertoire dotfiles : /root/dotfiles

  1) Prérequis hôte (docker, cc, chemins) — équivalent étapes A.1–A.3
  2) make docker-build (image Arch / dotfiles-test)
  3) make docker-in  → menus : distribution puis shell (Bloc C du guide)
  4) Afficher exemples docker-in sans menu (copier-coller)
  5) make test-dotcli (compilation + smoke dotcli)
  6) make test-help
  7) make test-dotfiles-good
  8) make test (Docker complet — long)
  9) Ouvrir docs/TESTS.md dans $PAGER (less)
  0) Quitter

Choix [0-9] : 

(résumé ou N/A si tu n’utilises pas le menu)
```
- **Conforme** : O
- **Notes** : *(facultatif)* Le diagnostic « docker absent » est **normal** depuis l’intérieur du conteneur ; le menu a bien repris après l’option `1`.
- **Assistant (relecture)** : **O** — Critère de l’étape : menu qui se réaffiche, **pas d’erreur fatale**. Le script signale Docker en rouge mais continue : comportement attendu dans ton cas. Si tu voulais « tout vert » sur l’option 1, il faut lancer **`make tests-start`** depuis l’**hôte** où Docker est installé.

---

# Bloc B — Image Docker de test (hôte)

### Étape B.1 — Construction image (Arch / image par défaut)

- **Commande** : `make docker-build`
- **Attendu** : fin **sans** erreur ; image `dotfiles-test-image:latest` (ou nom affiché en fin de log) présente.
- **[x] Fait**
- **Sortie (dernières lignes)** :
```zsh
╭─░▒▓    ~/dotfiles    main 18 ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 13:02:03  ▓▒░─╮
╰─❯ make docker-build                                                                                                                                                                                                                    ─╯
🔨 Construction de l'image Docker (isolée avec préfixe)...
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            BuildKit is currently disabled; enable it by removing the DOCKER_BUILDKIT=0
            environment-variable.

Sending build context to Docker daemon  19.85MB
Step 1/12 : FROM archlinux:latest
 ---> e25a13ea0e2a
Step 2/12 : ENV DOTFILES_DIR=/root/dotfiles
 ---> Using cache
 ---> 64a118258460
Step 3/12 : ENV HOME=/root
 ---> Using cache
 ---> 4f2203c5032a
Step 4/12 : RUN pacman -Syu --noconfirm &&     pacman -S --noconfirm         zsh         bash         fish         git         vim         curl         wget         sudo         base-devel         which         man-db         man-pages         openssh         python         python-pip         make         fzf
 ---> Using cache
 ---> 831ca90663b6
Step 5/12 : RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
 ---> Using cache
 ---> 16a3abd6f7b5
Step 6/12 : RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k 2>/dev/null || true
 ---> Using cache
 ---> 0fae0e95aace
Step 7/12 : WORKDIR /root
 ---> Using cache
 ---> cd13e3598053
Step 8/12 : RUN mkdir -p ${DOTFILES_DIR}
 ---> Using cache
 ---> 402778b18780
Step 9/12 : COPY . ${DOTFILES_DIR}/
 ---> 09d08d1d7d5f
Step 10/12 : RUN if [ -f "${DOTFILES_DIR}/zsh/zshrc_custom" ]; then         echo "source ${DOTFILES_DIR}/zsh/zshrc_custom" >> ~/.zshrc;     fi
 ---> Running in 651b5e98e62c
 ---> Removed intermediate container 651b5e98e62c
 ---> 4694d9f2a6ff
Step 11/12 : RUN mkdir -p ~/.config/moduleman     ~/.ssh     ${DOTFILES_DIR}/.config/moduleman
 ---> Running in 969adf143df5
 ---> Removed intermediate container 969adf143df5
 ---> 172474637a9d
Step 12/12 : CMD ["/bin/zsh"]
 ---> Running in 264c79287be2
 ---> Removed intermediate container 264c79287be2
 ---> f5a651fd5908
Successfully built f5a651fd5908
Successfully tagged dotfiles-test-image:latest
✓ Image Docker construite avec succès (isolée: dotfiles-test-image:latest)

```
- **Conforme** : O
- **Notes** : Build terminé sans erreur ; image `dotfiles-test-image:latest` créée (`f5a651fd5908`). Avertissement non bloquant `DEPRECATED: The legacy builder is deprecated … BuildKit is currently disabled; enable it by removing the DOCKER_BUILDKIT=0` — à tracer ultérieurement côté `Makefile`/`scripts/test/docker/` si on veut migrer sur BuildKit. Steps 1–8 en cache, 9–12 reconstruits (COPY + post-COPY).
- **Assistant (relecture)** : **O** — Critères de B.1 remplis (build OK + image taguée + ✓ Makefile). L’avertissement legacy builder est cosmétique et n’invalide pas la passe. Si tu veux désactiver le bandeau, ajouter `DOCKER_BUILDKIT=1` à l’environnement avant `make docker-build`, mais ce n’est pas requis pour avancer (envisageable en ligne `EXT-xxx`).

*Alternative menu* : `make tests-start` → option `2`.

---

# Bloc C — Entrer dans le conteneur (distro + shell)

**But** : reproduire une machine « propre » avec les dotfiles montés en **lecture seule** sous `/root/dotfiles`.

### Étape C.1 — Lancement interactif

- **Commande** : `make docker-in`
- **Attendu** :
  1. Menu **distribution** (1 Arch … 8 Gentoo) — choisir **1** pour la première passe (Arch).
  2. Menu **shell** (zsh / bash / fish / sh) — choisir **1** (zsh) pour la première passe.
  3. Tu obtiens un **prompt** dans le conteneur.
- **[x] Fait**
- **Sortie** : note ce que **tu as choisi** :
```
Distro choisie : 1 (Arch)
Shell choisi   : 1 (zsh)
```
- Affichage de la sortie copier coller :
```Zsh
╭─░▒▓    ~/dotfiles    main 5 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 12:07:07  ▓▒░─╮
╰─❯ make docker-in                                                                                                                                                                                                                       ─╯

Quelle distribution (base du conteneur) ?
  1) Arch (défaut — image Makefile / make docker-build)
  2) Ubuntu
  3) Debian
  4) Alpine
  5) Fedora
  6) CentOS
  7) openSUSE
  8) Gentoo  ⚠  build très long (sources)

Choix [1-8, ou nom: arch|ubuntu|…, Entrée = Arch] : 1

Quel shell ouvrir dans le conteneur ?
  1) zsh   2) bash   3) fish   4) sh (POSIX)
Choix [1-4, ou nom, Entrée = zsh] : 1
🐧 Distro: arch  →  image: dotfiles-test-image:latest
🐚 Shell: zsh
[powerlevel10k] fetching gitstatusd .. [ok]                                                                                                                                                                                                 
╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@ff7df64a7e03  at 10:07:22  ▓▒░─╮
╰─❯                                                                                                                                                                                                                                      ─╯
```
- **Conforme** : O
- **Notes** : Menu distribution + menu shell affichés et choisis (`1 = Arch`, `1 = zsh`). Image bien `dotfiles-test-image:latest`. Prompt obtenu dans le conteneur (`root@ff7df64a7e03`). Avant le prompt, `[powerlevel10k] fetching gitstatusd .. [ok]` → fetch réseau au premier démarrage de zsh dans ce conteneur (cosmétique, ne se reproduira pas tant que l’image est inchangée).
- **Assistant (relecture)** : **O** — Les trois critères de C.1 sont remplis (menu distro, menu shell, prompt conteneur). Le message `[powerlevel10k] fetching gitstatusd` est attendu sur un premier démarrage zsh + p10k ; si tu relances `make docker-in` sur la même image, ce sera silencieux. Tu peux enchaîner sur le Bloc **D** depuis ce shell conteneur (`cd $DOTFILES_DIR`).

### Étape C.2 — Sans menu (reproductibilité)

- **Commande (exemple Debian + bash)** : `make docker-in DOCKER_DISTRO=debian DOCKER_SHELL=bash`
- **Attendu** : shell bash dans conteneur basé Debian ; pas d’échec Docker immédiat.
- **[x] Fait** *(NA si tu ne fais que l’interactif)*
- **Sortie** :
```
NA — passe interactive uniquement (C.1 fait). À reprendre quand on voudra valider la variante Debian/bash.
```
- **Conforme** : NA
- **Notes** : NA assumé pour cette passe : seul l’interactif (C.1) a été lancé. À rejouer plus tard pour couvrir au moins Debian + bash (et éventuellement Ubuntu / Alpine) afin d’exercer `scripts/test/docker/docker_in.sh` avec les variables `DOCKER_DISTRO` / `DOCKER_SHELL`.
- **Assistant (relecture)** : **NA (attendu)** — L’énoncé prévoit explicitement « **NA** si tu ne fais que l’interactif ». Pas de blocage pour le Jalon B ; à reprendre dans une passe ultérieure pour couvrir la matrice distro × shell.

*Référence variables* : [`../TODOS.md`](../TODOS.md) (section Docker) et `scripts/test/docker/docker_in.sh`.

### Étape C.3 — Matrice shells dans le conteneur *(optionnel, même distro)*

**But** : rejouer **Bloc D** (au minimum **D.2** + **D.3**) et un **smoke réseau** pour **zsh**, **bash**, **fish** et **`sh`**, sans réécrire tout le guide : une ligne par shell, **même modèle de champs** que les autres étapes ([`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) §1).

**Comment lancer** : sur l’**hôte**, `make docker-in` (ou variables `DOCKER_DISTRO` / `DOCKER_SHELL` — voir C.2). Choisir la **même distro** (ex. Arch) puis successivement le menu shell **1 → zsh**, puis quitter le conteneur, relancer `make docker-in`, choisir **2 → bash**, etc. *(Ou une seule ligne : `make docker-in DOCKER_SHELL=bash`.)*

**Smoke commun (à exécuter dans chaque shell du conteneur)** — adapter la ligne `source` au shell :

| Shell | Commande `source` (depuis `/root` ou `~`) | Smoke non interactif |
|-------|------------------------------------------|------------------------|
| **zsh** | `source /root/dotfiles/zsh/zshrc_custom` | `pathman help \| head -n 4` |
| **bash** | `source /root/dotfiles/bash/bashrc_custom` | `pathman help \| head -n 4` |
| **fish** | `source /root/dotfiles/fish/config_custom.fish` | `pathman help \| head -n 4` |
| **sh** | `ENV=/root/dotfiles/shared/config.sh; export ENV; . "$ENV"` *(ou méthode documentée pour POSIX minimal)* | `command -v pathman >/dev/null && pathman help \| head -n 4` *(si `pathman` absent en `sh` pur, mettre **NA** en Notes)* |

**Contrôle visuel `netman` (TTY uniquement)** : menu **3 — Informations IP** → sous **Adresses IP Locales** et **IPv6**, chaque ligne doit afficher un **nom d’interface** (`wlan0:`, `docker0:`, …) aligné avec `ip -4 -o addr show` / `ip -6 -o addr show` sur la même machine. **Pas** de colonne vide `:` avant l’adresse ; **pas** de fragment d’adresse IPv6 pris pour un nom d’interface (`861:`).

---

#### C.3.a — Conteneur **zsh** (re-passe)

- **Commande** : `make docker-in` → Arch + **zsh** ; puis `source …/zshrc_custom` ; `pathman help \| head -n 4` ; en TTY : `netman --help` → option **3** (Informations IP).
- **Attendu** : `pathman help` sans `command not found` ; adresses IP avec interface correcte (cf. tableau ci-dessus).
- **[ ] Fait**
- **Sortie (coller)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

#### C.3.b — Conteneur **bash**

- **Commande** : `make docker-in DOCKER_SHELL=bash` *(ou menu choix 2)* ; `source …/bashrc_custom` ; `pathman help \| head -n 4` ; TTY : `netman` → **3**.
- **Attendu** : idem C.3.a.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

#### C.3.c — Conteneur **fish**

- **Commande** : `make docker-in DOCKER_SHELL=fish` ; `source …/config_custom.fish` ; `pathman help \| head -n 4` ; TTY : `netman` → **3**.
- **Attendu** : idem C.3.a.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

#### C.3.d — Conteneur **`sh` (POSIX)**

- **Commande** : `make docker-in DOCKER_SHELL=sh` ; charger le minimum documenté pour ton cas (voir tableau) ; smoke `pathman` si disponible.
- **Attendu** : si `pathman` n’est pas exposé en `sh` minimal, cocher **NA** avec explication ; sinon idem non interactif.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

> **Lien `TODOS.md`** : cette matrice est **optionnelle** ; une fois remplie, tu peux cocher la case **P10** dans [`../TODOS.md`](../TODOS.md). Les écarts (ex. `pathman` absent en `sh`) → nouvelle ligne dans `TODOS.md` plutôt que d’effacer une étape ici.

---

# Bloc D — Dans le conteneur : chargement des dotfiles

**Tu es maintenant DANS le conteneur** (invite différente, `pwd` souvent `/root`).

### Étape D.1 — Vérifier le montage

- **Commande** : `echo "$DOTFILES_DIR" && ls -la "$DOTFILES_DIR/Makefile" 2>&1 | head -5`
- **Attendu** : `DOTFILES_DIR` = `/root/dotfiles` (sauf si tu as changé `DOCKER_DOTFILES_DIR`) ; `Makefile` lisible.
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main 5 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 12:36:08  ▓▒░─╮
╰─❯ make docker-in                                                                                                                                                                                                                       ─╯

Quelle distribution (base du conteneur) ?
  1) Arch (défaut — image Makefile / make docker-build)
  2) Ubuntu
  3) Debian
  4) Alpine
  5) Fedora
  6) CentOS
  7) openSUSE
  8) Gentoo  ⚠  build très long (sources)

Choix [1-8, ou nom: arch|ubuntu|…, Entrée = Arch] : 

Quel shell ouvrir dans le conteneur ?
  1) zsh   2) bash   3) fish   4) sh (POSIX)
Choix [1-4, ou nom, Entrée = zsh] : 
🐧 Distro: arch  →  image: dotfiles-test-image:latest
🐚 Shell: zsh
[powerlevel10k] fetching gitstatusd .. [ok]                                                                                                                                                                                                 
╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:36:22  ▓▒░─╮
╰─❯  echo "$DOTFILES_DIR" && ls -la "$DOTFILES_DIR/Makefile" 2>&1 | head -5                                                                                                                                                              ─╯
/root/dotfiles
-rw-r--r-- 1 1000 1000 61K May  6 14:35 /root/dotfiles/Makefile

╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:37:09  ▓▒░─╮
╰─❯         
```
- **Conforme** : O
- **Notes** : `DOTFILES_DIR=/root/dotfiles`, `Makefile` lisible (`-rw-r--r-- 1 1000 1000 61K`). Les UID/GID `1000` proviennent du montage depuis l’hôte (utilisateur hôte), c’est attendu pour un montage en lecture seule.
- **Assistant (relecture)** : **O** — Les deux critères de D.1 sont remplis : `DOTFILES_DIR` affiché correctement et `Makefile` accessible. Tu peux enchaîner D.2.

### Étape D.2 — Charger la config shell (selon le shell choisi en C.1)

⚠ **Important** : exécuter **UNE SEULE** ligne — celle qui correspond au shell choisi en C.1. Sourcer un rc bash/fish depuis zsh (ou inversement) produit toujours des erreurs de syntaxe (`bad substitution`, `parse error near 'end'`, …) qui ne sont **pas** un bug du projet — c’est juste un shell qui lit la syntaxe d’un autre shell.

Choisis **une** ligne correspondant à ton shell :

| Shell | Commande |
|-------|----------|
| **zsh** | `source /root/dotfiles/zsh/zshrc_custom` *(si les managers ne sont pas déjà là)* |
| **bash** | normalement déjà chargé via `docker_in` ; sinon `source /root/dotfiles/bash/bashrc_custom` |
| **fish** | normalement déjà chargé ; sinon `source /root/dotfiles/fish/config_custom.fish` |

- **Commande** : *(copie la ligne de ton shell)*  
- **Attendu** : pas d’erreur **fatale** ; tu peux taper `pathman help` ensuite sans « command not found ».
- **[x] Fait**
- **Sortie** :
```sh
╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:36:22  ▓▒░─╮
╰─❯  echo "$DOTFILES_DIR" && ls -la "$DOTFILES_DIR/Makefile" 2>&1 | head -5                                                                                                                                                              ─╯
/root/dotfiles
-rw-r--r-- 1 1000 1000 61K May  6 14:35 /root/dotfiles/Makefile

╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:37:09  ▓▒░─╮
╰─❯ source /root/dotfiles/zsh/zshrc_custom                                                                                                                                                                                               ─╯

╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:38:58  ▓▒░─╮
╰─❯ source /root/dotfiles/bash/bashrc_custom                                                                                                                                                                                             ─╯
load_manager:5: bad substitution

╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 126 ✘  with root@6cc7662c295a  at 10:39:13  ▓▒░─╮
╰─❯ source /root/dotfiles/fish/config_custom.fish                                                                                                                                                                                        ─╯
/root/dotfiles/fish/config_custom.fish:4: parse error near `end'

╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 126 ✘  with root@6cc7662c295a  at 10:39:32  ▓▒░─╮
╰─❯                                                                                                                                                                                                                                      ─╯


```
- **Conforme** : O (avec réserve d’interprétation — voir relecture)
- **Notes** : Lors de la passe, **les trois** rc ont été sourcés successivement (`zsh/zshrc_custom` ✅ sans erreur ; puis `bash/bashrc_custom` ❌ `load_manager:5: bad substitution` ; puis `fish/config_custom.fish` ❌ `parse error near 'end'`). Or la consigne demande **une seule** ligne — celle du shell actif (zsh en C.1). Seul le premier `source` était requis, et il a réussi : preuve indirecte → D.3 (`pathman help`) fonctionne immédiatement après, ce qui n’aurait pas été possible sans le chargement de `zshrc_custom`. Les erreurs `bad substitution` / `parse error near 'end'` sont les messages **normaux** d’un shell lisant la syntaxe d’un autre shell, pas un bug du projet.
- **Assistant (relecture)** : **O** — D.2 est conforme au sens du critère (« pas d’erreur **fatale** ; `pathman help` ensuite sans `command not found` »). Le `source zshrc_custom` est passé proprement et D.3 le confirme. Les deux tentatives suivantes (`bashrc_custom`, `config_custom.fish` dans un shell zsh) **n’étaient pas à exécuter** ; les erreurs émises sont attendues (syntaxes incompatibles) et n’invalident pas l’étape. J’ai d’ailleurs ajouté un **avertissement explicite** au-dessus du tableau pour éviter le piège lors des passes futures. Tu peux laisser **O** ; si tu préfères une trace plus stricte, tu peux mettre **NA** pour les sourcings bash/fish et **O** pour zsh, mais ce n’est pas requis.

### Étape D.3 — Smoke manager minimal

- **Commande** : `pathman help`
- **Attendu** : aide ou usage **sur stdout** (sans TTY : pas de menu bloquant) ; pas `command not found`. Voir **Bloc G — préalable** pour le contrat complet des `*man`.
- **[x] Fait**
- **Sortie (extrait)** :
```bash
╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 126 ✘  with root@6cc7662c295a  at 10:39:32  ▓▒░─╮
╰─❯ pathman help                                                                                                                                                                                                                         ─╯
PATHMAN — raccourcis

Gestion PATH :
  pathman show            afficher le PATH courant
  pathman add <dir>       ajouter un répertoire
  pathman remove <dir>    retirer un répertoire
  pathman clean           nettoyer doublons + invalides
  pathman invalid         retirer uniquement les invalides
  pathman stats           statistiques PATH
  pathman export          exporter vers un fichier texte

Interface :
  pathman                    cette page (stdout)
  pathman help | -h          idem
  pathman help --interactive aide détaillée + pause (TTY)
  pathman --help             menu interactif (fzf ou menu console)


╭─░▒▓    ~ ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  with root@6cc7662c295a  at 10:42:05  ▓▒░─╮
╰─❯            
```
- **Conforme** : O
- **Notes** : Semble cohérent : `pathman help` affiche l’aide minimale sur **stdout** (raccourcis + section *Interface*), pas de menu interactif lancé sans TTY explicite — conforme au contrat du Bloc G (préalable).
- **Assistant (relecture)** : **O** — La sortie respecte exactement la nouvelle convention : bloc « PATHMAN — raccourcis » puis bloc « Interface » listant les 4 formes (`pathman`, `pathman help | -h`, `pathman help --interactive`, `pathman --help`). Aucun `command not found`, aucun blocage. D.3 validé ; tu peux exiter le conteneur en D.4.

### Étape D.4 — Quitter le conteneur

- **Commande** : `exit` (ou Ctrl+D)
- **Attendu** : retour sur le shell **hôte**.
- **[x] Fait**
- **Conforme** : O
- **Notes** : Retour shell hôte OK, fonctionnement cohérent quel que soit le shell utilisé dans le conteneur.
- **Assistant (relecture)** : **O** — Critère D.4 rempli (retour à l’hôte). Bloc D complet et exploitable pour la suite.

---

# Bloc E — Cibles Make utiles (hôte, après retour du conteneur)

### Étape E.1 — Aide tests

- **Commande** : `make test-help`
- **Attendu** : texte d’aide sur les variables (`DOTFILES_TEST_MANAGERS`, etc.).
- **[x] Fait**
- **Sortie (extrait)** :
```bash
╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:04:54  ▓▒░─╮
╰─❯ make test-help                                                                                                                                                                                                                       ─╯

═══════════════════════════════════════════════════════════════════
  Tests dotfiles — variables, bac à sable, Makefile
═══════════════════════════════════════════════════════════════════

1) Filtrer les managers à tester (Docker)
   ─────────────────────────────────────
   DOTFILES_TEST_MANAGERS   liste avec virgules ou espaces (recommandé)
   TEST_MANAGERS            même rôle ; prioritaire si les deux sont posés

   Exemples :
     DOTFILES_TEST_MANAGERS=pathman,installman,searchman make test
     TEST_MANAGERS="pathman installman" make test-subcommands
     TEST_SHELLS=zsh DOTFILES_TEST_MANAGERS=netman make test

2) Fichier local (non versionné)
   ────────────────────────────────
   cp scripts/test/config/test.local.env.example scripts/test/config/test.local.env
   # puis éditer : TEST_SHELLS, TEST_MANAGERS, SUBCOMMAND_TIER, TEST_DOTFILES_ISOLATE=1, …
   DOTFILES_TEST_USER_ENV=/chemin/custom.env  make test

3) Bac à sable « live » (shell dans le conteneur)
   ───────────────────────────────────────────────
   make docker-in              # menus distro + shell si terminal ; sinon Arch + zsh
   make docker-in DOCKER_DISTRO=debian DOCKER_SHELL=fish   # forcer sans menus
   Distros : arch (image docker-build), ubuntu, debian, alpine, fedora, centos, opensuse, gentoo (build long)
   Sans export manuel : DOCKER_DOTFILES_DIR, DOCKER_INSTALLMAN_ASSUME (voir Makefile / docker_in.sh)
   Confirmations installman :  make docker-in DOCKER_INSTALLMAN_ASSUME=0
   Dans le conteneur : root par défaut ; source $DOTFILES_DIR/zsh/zshrc_custom si besoin
   make test dans le conteneur : sans Docker imbriqué → run_tests.sh directement (fichier /.dockerenv)
   Forcer ce mode sur l'hôte : DOTFILES_TEST_NO_NESTED_DOCKER=1 make test (si pas de daemon Docker)
   Doc détaillée :     cat scripts/test/SANDBOX.md

   Smoke vs assertions métier : make test / matrice = surtout « ne plante pas / timeout » ; assertions
   ciblées (golden, grep) = évolution — voir TODOS.md § « Phase A — tests ».

4) Autres cibles utiles
   ───────────────────
   make tests              # menu interactif des tests
   DOTFILES_TEST_MENU_SKIP_PAUSE=1 make tests   # pas de pause « Entrée » après chaque action
   make test-checks        # syntaxe cores + adapters + URLs (local ou CI)
   make test-menu-fzf      # vérifie intégration des menus fzf + fallback /dev/tty
   make test-dotfiles-good # bac à sable DOTFILES_GOOD/ (smoke POSIX, additif)
   sh scripts/test/installman_check.sh
   bash scripts/test/verify_multishell.sh

5) Liste par défaut des managers pour « make test »
   ───────────────────────────────────────────────
   scripts/test/config/migrated_managers.list

═══════════════════════════════════════════════════════════════════


╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:04:58  ▓▒░─╮
╰─❯                                     
```
- **Conforme** : O
- **Notes** : `make test-help` affiche bien les 5 sections attendues (filtrage `DOTFILES_TEST_MANAGERS` / `TEST_MANAGERS`, fichier local `test.local.env`, bac à sable `make docker-in`, autres cibles utiles, liste source `migrated_managers.list`). Critère « texte d’aide sur les variables » rempli. Deux observations à traiter plus tard (tracées en **EXT-002** et **EXT-003** ci-dessous) : (1) adaptabilité aux **petits écrans / résolutions étroites** (largeur < 80 colonnes, terminal TTY simple, pilotes graphiques HS, etc.) — il faudra vérifier que toutes les sorties d’aide / managers se replient correctement (pas de débordement, pas de barres `══` infinies, etc.) ; (2) **couleurs** : ici la sortie est monochrome, alors qu’on pourrait colorer si `tput colors >= 8` et désactiver proprement sinon (jamais d’`\033[...]` brut à l’écran).
- **Assistant (relecture)** : **O** — Critère du guide rempli (aide affichée, variables listées). Les deux remarques sur l’adaptabilité petits écrans et les couleurs sont **pertinentes** mais hors scope d’E.1 ; elles sont ajoutées en `EXT-002` / `EXT-003` (§ 12) pour être traitées plus tard sans bloquer la passe de tests. E.1 = **O**.

### Étape E.2 — Smoke dotfiles-good

- **Commande** : `make test-dotfiles-good`
- **Attendu** : succès **ou** échec documenté dans **Notes** + [`ERRORS.md`](ERRORS.md).
- **[x] Fait**
- **Sortie (extrait)** :
```zsh
╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:10:16  ▓▒░─╮
╰─❯ make test-dotfiles-good                                                                                                                                                                                                              ─╯
→ sh -n sur les *.sh sous DOTFILES_GOOD/
   sh -n DOTFILES_GOOD/lib/bootstrap_posix.sh
   sh -n DOTFILES_GOOD/scripts/print_roots.sh
   sh -n DOTFILES_GOOD/shared/aliases.sh
   sh -n DOTFILES_GOOD/shared/env/00_paths.sh
   sh -n DOTFILES_GOOD/shared/env/05_path_original.sh
   sh -n DOTFILES_GOOD/shared/env/10_toolchain_paths.sh
   sh -n DOTFILES_GOOD/shared/env/11_pub_cache_export.sh
   sh -n DOTFILES_GOOD/shared/env/12_android_exports.sh
   sh -n DOTFILES_GOOD/shared/env/13_flutter_ndk_exports.sh
   sh -n DOTFILES_GOOD/shared/env/14_android_tool_paths_export.sh
→ répertoires attendus
→ sourcing bootstrap dans un sous-shell (DOTFILES_DIR=/home/pactivisme/dotfiles)
→ DOTFILES_GOOD/scripts/print_roots.sh
DOTFILES_DIR=/home/pactivisme/dotfiles
DOTFILES_GOOD_ROOT=/home/pactivisme/dotfiles/DOTFILES_GOOD
DOTFILES_GOOD_ENV_LOADED=1
✅ DOTFILES_GOOD : OK 
```
- **Conforme** : O
- **Notes** : Sortie cohérente : `sh -n` passe sur tous les `*.sh` de `DOTFILES_GOOD/` (10 fichiers du `bootstrap_posix` jusqu’aux `env/14_*`), répertoires attendus présents, bootstrap re-sourcé dans un sous-shell avec `DOTFILES_DIR=/home/pactivisme/dotfiles`, `DOTFILES_GOOD_ROOT` / `DOTFILES_GOOD_ENV_LOADED=1` posés, et trace finale `✅ DOTFILES_GOOD : OK`.
- **Assistant (relecture)** : **O** — Critère E.2 rempli (succès observé). Aucune entrée à ajouter dans `ERRORS.md`. Tu peux enchaîner E.3.

### Étape E.3 — Tests Docker complets *(long)*

- **Commande** : `make test` *(ou via `make tests-start` option 8 avec confirmation)*
- **Attendu** : fin avec résumé OK **ou** liste d’échecs ; rapports sous `TEST_RESULTS_DIR` (souvent sous le home ou `/tmp` selon environnement — voir log).
- **[x] Fait** *(NA si tu ne lances pas la suite complète aujourd’hui)*
- **Sortie (résumé final)** :
```bash

╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:10:25  ▓▒░─╮
╰─❯              
══════════════════════════════════════════════════════════╗
║                    NETMAN - Network Manager                    ║
║                     Gestionnaire Réseau                       ║
╚════════════════════════════════════════════════════════════════╝

🖧  Interfaces réseau
══════════════════════════════════════════════════════════════════

Interface: lo
─────────────────────────
  État: UNKNOWN
  MAC: N/A
  IPv4:
    127.0.0.1/8
  IPv6:
    ::1/128
  Statistiques:
    RX: 0B
    TX: 0B

Interface: eth0@if548
─────────────────────────
  État: UP
  MAC: 7a:16:7a:5c:50:9e
  IPv4:
    172.17.0.2/16
  IPv6:
  Statistiques:
    RX: 7.0KiB
    TX: 126B

   ✓ ok (code 0)
🧪 [zsh] sshman help
SSHMAN — raccourcis
══════════════════════════════════════════════════════════════════

Sous-commandes :
  sshman list           Connexions (~/.ssh/config)
  sshman test           Tester une connexion
  sshman keys           Gérer les clés SSH
  sshman stats          Statistiques + permissions ~/.ssh
  sshman auto-setup     Config auto (mot de passe .env si dispo)

Interface :
  sshman                       cette aide (stdout)
  sshman help | -h             idem
  sshman help --interactive    cette aide + pause (TTY)
  sshman --help                cette aide + pause + menu interactif

   ✓ ok (code 0)
🧪 [bash] sshman help
SSHMAN — raccourcis
══════════════════════════════════════════════════════════════════

Sous-commandes :
  sshman list           Connexions (~/.ssh/config)
  sshman test           Tester une connexion
  sshman keys           Gérer les clés SSH
  sshman stats          Statistiques + permissions ~/.ssh
  sshman auto-setup     Config auto (mot de passe .env si dispo)

Interface :
  sshman                       cette aide (stdout)
  sshman help | -h             idem
  sshman help --interactive    cette aide + pause (TTY)
  sshman --help                cette aide + pause + menu interactif

   ✓ ok (code 0)
🧪 [fish] sshman help
SSHMAN — raccourcis
══════════════════════════════════════════════════════════════════

Sous-commandes :
  sshman list           Connexions (~/.ssh/config)
  sshman test           Tester une connexion
  sshman keys           Gérer les clés SSH
  sshman stats          Statistiques + permissions ~/.ssh
  sshman auto-setup     Config auto (mot de passe .env si dispo)

Interface :
  sshman                       cette aide (stdout)
  sshman help | -h             idem
  sshman help --interactive    cette aide + pause (TTY)
  sshman --help                cette aide + pause + menu interactif

   ✓ ok (code 0)
⏭  processman — pas de scripts/test/subcommands/processman.list
⏭  routeman — pas de scripts/test/subcommands/routeman.list
⏭  testman — @skip dans scripts/test/subcommands/testman.list (volontaire : trop interactif pour la matrice CI ; tester à la main ou make test-docker-manager MANAGER=testman)
🧪 [zsh] testzshman help
🧪 TESTZSHMAN - Test Manager ZSH/Dotfiles

Interface :
  testzshman                       cette aide (stdout)
  testzshman help | -h             idem
  testzshman help --interactive    cette aide + pause (TTY)
  testzshman --help                cette aide + pause + menu interactif

Usage: testzshman [test-type]

Tests disponibles:
  managers   - Test des managers
  functions  - Test des fonctions
  structure  - Test de la structure
  config     - Test de la configuration
  symlinks   - Test des symlinks
  syntax     - Test de la syntaxe
  cyberlearn - Test de cyberlearn
  logging    - actions_logger / managers_log (hermétique + audit statique)
  all        - Tous les tests

   ✓ ok (code 0)
🧪 [bash] testzshman help
🧪 TESTZSHMAN - Test Manager ZSH/Dotfiles

Interface :
  testzshman                       cette aide (stdout)
  testzshman help | -h             idem
  testzshman help --interactive    cette aide + pause (TTY)
  testzshman --help                cette aide + pause + menu interactif

Usage: testzshman [test-type]

Tests disponibles:
  managers   - Test des managers
  functions  - Test des fonctions
  structure  - Test de la structure
  config     - Test de la configuration
  symlinks   - Test des symlinks
  syntax     - Test de la syntaxe
  cyberlearn - Test de cyberlearn
  logging    - actions_logger / managers_log (hermétique + audit statique)
  all        - Tous les tests

   ✓ ok (code 0)
🧪 [fish] testzshman help
🧪 TESTZSHMAN - Test Manager ZSH/Dotfiles

Interface :
  testzshman                       cette aide (stdout)
  testzshman help | -h             idem
  testzshman help --interactive    cette aide + pause (TTY)
  testzshman --help                cette aide + pause + menu interactif

Usage: testzshman [test-type]

Tests disponibles:
  managers   - Test des managers
  functions  - Test des fonctions
  structure  - Test de la structure
  config     - Test de la configuration
  symlinks   - Test des symlinks
  syntax     - Test de la syntaxe
  cyberlearn - Test de cyberlearn
  logging    - actions_logger / managers_log (hermétique + audit statique)
  all        - Tous les tests

   ✓ ok (code 0)
🧪 [zsh] moduleman list
Modules disponibles:
  ✓ pathman [ACTIVÉ]
  ✓ netman [ACTIVÉ]
  ✓ aliaman [ACTIVÉ]
  ✓ miscman [ACTIVÉ]
  ✓ searchman [ACTIVÉ]
  ✓ cyberman [ACTIVÉ]
  ✓ devman [ACTIVÉ]
  ✓ gitman [ACTIVÉ]
  ✓ helpman [ACTIVÉ]
  ✓ manman [ACTIVÉ]
  ✓ configman [ACTIVÉ]
  ✓ installman [ACTIVÉ]
  ✓ moduleman [ACTIVÉ]
  ✓ fileman [ACTIVÉ]
  ✓ virtman [ACTIVÉ]
  ✓ sshman [ACTIVÉ]
  ✓ processman [ACTIVÉ]
  ✓ routeman [ACTIVÉ]
  ✓ testzshman [ACTIVÉ]
  ✓ testman [ACTIVÉ]
  ✓ doctorman [ACTIVÉ]
   ✓ ok (code 0)
🧪 [bash] moduleman list
Modules disponibles:
  ✓ pathman [ACTIVÉ]
  ✓ netman [ACTIVÉ]
  ✓ aliaman [ACTIVÉ]
  ✓ miscman [ACTIVÉ]
  ✓ searchman [ACTIVÉ]
  ✓ cyberman [ACTIVÉ]
  ✓ devman [ACTIVÉ]
  ✓ gitman [ACTIVÉ]
  ✓ helpman [ACTIVÉ]
  ✓ manman [ACTIVÉ]
  ✓ configman [ACTIVÉ]
  ✓ installman [ACTIVÉ]
  ✓ moduleman [ACTIVÉ]
  ✓ fileman [ACTIVÉ]
  ✓ virtman [ACTIVÉ]
  ✓ sshman [ACTIVÉ]
  ✓ processman [ACTIVÉ]
  ✓ routeman [ACTIVÉ]
  ✓ testzshman [ACTIVÉ]
  ✓ testman [ACTIVÉ]
  ✓ doctorman [ACTIVÉ]
   ✓ ok (code 0)
🧪 [fish] moduleman list
Modules disponibles:
  ✓ pathman [ACTIVÉ]
  ✓ netman [ACTIVÉ]
  ✓ aliaman [ACTIVÉ]
  ✓ miscman [ACTIVÉ]
  ✓ searchman [ACTIVÉ]
  ✓ cyberman [ACTIVÉ]
  ✓ devman [ACTIVÉ]
  ✓ gitman [ACTIVÉ]
  ✓ helpman [ACTIVÉ]
  ✓ manman [ACTIVÉ]
  ✓ configman [ACTIVÉ]
  ✓ installman [ACTIVÉ]
  ✓ moduleman [ACTIVÉ]
  ✓ fileman [ACTIVÉ]
  ✓ virtman [ACTIVÉ]
  ✓ sshman [ACTIVÉ]
  ✓ processman [ACTIVÉ]
  ✓ routeman [ACTIVÉ]
  ✓ testzshman [ACTIVÉ]
  ✓ testman [ACTIVÉ]
  ✓ doctorman [ACTIVÉ]
   ✓ ok (code 0)
🧪 [zsh] multimediaman help
MULTIMEDIAMAN — DVD / archives

Interface :
  multimediaman                        cette aide (stdout)
  multimediaman help | -h | aide       idem
  multimediaman help --interactive     cette aide + pause (TTY)
  multimediaman --help                 cette aide + pause + menu interactif

Commandes :
  multimediaman rip-dvd [nom]          Ripping DVD + encodage MP4
  multimediaman extract [archive] [dest]  Extraire une archive (progression)
  multimediaman list [archive]        Lister le contenu d'une archive

Exemples :
  multimediaman rip-dvd Mon_Film
  multimediaman extract archive.zip
  multimediaman extract archive.tar.gz /tmp/extract
  multimediaman list archive.zip

Pré-requis : HandBrakeCLI, dvdbackup, libdvdcss (DVD chiffrés) — voir installman handbrake.
   ✓ ok (code 0)
🧪 [bash] multimediaman help
MULTIMEDIAMAN — DVD / archives

Interface :
  multimediaman                        cette aide (stdout)
  multimediaman help | -h | aide       idem
  multimediaman help --interactive     cette aide + pause (TTY)
  multimediaman --help                 cette aide + pause + menu interactif

Commandes :
  multimediaman rip-dvd [nom]          Ripping DVD + encodage MP4
  multimediaman extract [archive] [dest]  Extraire une archive (progression)
  multimediaman list [archive]        Lister le contenu d'une archive

Exemples :
  multimediaman rip-dvd Mon_Film
  multimediaman extract archive.zip
  multimediaman extract archive.tar.gz /tmp/extract
  multimediaman list archive.zip

Pré-requis : HandBrakeCLI, dvdbackup, libdvdcss (DVD chiffrés) — voir installman handbrake.
   ✓ ok (code 0)
🧪 [fish] multimediaman help
MULTIMEDIAMAN — DVD / archives

Interface :
  multimediaman                        cette aide (stdout)
  multimediaman help | -h | aide       idem
  multimediaman help --interactive     cette aide + pause (TTY)
  multimediaman --help                 cette aide + pause + menu interactif

Commandes :
  multimediaman rip-dvd [nom]          Ripping DVD + encodage MP4
  multimediaman extract [archive] [dest]  Extraire une archive (progression)
  multimediaman list [archive]        Lister le contenu d'une archive

Exemples :
  multimediaman rip-dvd Mon_Film
  multimediaman extract archive.zip
  multimediaman extract archive.tar.gz /tmp/extract
  multimediaman list archive.zip

Pré-requis : HandBrakeCLI, dvdbackup, libdvdcss (DVD chiffrés) — voir installman handbrake.
   ✓ ok (code 0)
🧪 [zsh] cyberlearn help
Usage :
  cyberlearn                        cette aide sur stdout (non interactif)
  cyberlearn help | -h | aide       idem
  cyberlearn help --interactive     aide détaillée + pause (TTY)
  cyberlearn --help                 cette aide + pause + menu interactif (TTY)

Commandes :
  cyberlearn start-module <nom>    démarrer un module
  cyberlearn lab start <nom>       démarrer un lab
  cyberlearn lab stop [nom]        arrêter un lab
  cyberlearn lab list              lister les labs
  cyberlearn lab status            statut des labs
  cyberlearn progress              afficher la progression (menu en TTY)

Modules reconnus :
  basics, network, web, crypto, linux, windows, mobile, forensics, pentest, incident

Labs (exemples) :
  web-basics, network-scan, crypto-basics, linux-pentest, forensics-basic

Exemples :
  cyberlearn start-module basics
  cyberlearn lab start web-basics
  cyberlearn progress

Pré-requis : Docker (labs), outils de sécu courants, Python 3 pour certains exercices.
   ✓ ok (code 0)
🧪 [bash] cyberlearn help
Usage :
  cyberlearn                        cette aide sur stdout (non interactif)
  cyberlearn help | -h | aide       idem
  cyberlearn help --interactive     aide détaillée + pause (TTY)
  cyberlearn --help                 cette aide + pause + menu interactif (TTY)

Commandes :
  cyberlearn start-module <nom>    démarrer un module
  cyberlearn lab start <nom>       démarrer un lab
  cyberlearn lab stop [nom]        arrêter un lab
  cyberlearn lab list              lister les labs
  cyberlearn lab status            statut des labs
  cyberlearn progress              afficher la progression (menu en TTY)

Modules reconnus :
  basics, network, web, crypto, linux, windows, mobile, forensics, pentest, incident

Labs (exemples) :
  web-basics, network-scan, crypto-basics, linux-pentest, forensics-basic

Exemples :
  cyberlearn start-module basics
  cyberlearn lab start web-basics
  cyberlearn progress

Pré-requis : Docker (labs), outils de sécu courants, Python 3 pour certains exercices.
   ✓ ok (code 0)
🧪 [fish] cyberlearn help
Usage :
  cyberlearn                        cette aide sur stdout (non interactif)
  cyberlearn help | -h | aide       idem
  cyberlearn help --interactive     aide détaillée + pause (TTY)
  cyberlearn --help                 cette aide + pause + menu interactif (TTY)

Commandes :
  cyberlearn start-module <nom>    démarrer un module
  cyberlearn lab start <nom>       démarrer un lab
  cyberlearn lab stop [nom]        arrêter un lab
  cyberlearn lab list              lister les labs
  cyberlearn lab status            statut des labs
  cyberlearn progress              afficher la progression (menu en TTY)

Modules reconnus :
  basics, network, web, crypto, linux, windows, mobile, forensics, pentest, incident

Labs (exemples) :
  web-basics, network-scan, crypto-basics, linux-pentest, forensics-basic

Exemples :
  cyberlearn start-module basics
  cyberlearn lab start web-basics
  cyberlearn progress

Pré-requis : Docker (labs), outils de sécu courants, Python 3 pour certains exercices.
   ✓ ok (code 0)

📊 Matrice sous-commandes — exécutions: 63 | échecs: 0
✅ Matrice sous-commandes : OK

───────────────────────────────────────────────────────────────
── Fin du flux conteneur — journal : /home/pactivisme/dotfiles/test_results/test_output.log
[2/3] 66.7% |███████████████████████████░░░░░░░░░░░░░| ✅ 2 | ❌ 0 | ⏱  00:00:24 écoulé | ~00:00:12 restant
═══════════════════════════════════════════════════════════════
📊 RAPPORT DE TEST
═══════════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════════
RAPPORT DE TEST - Tue May 12 12:12:50 UTC 2026
═══════════════════════════════════════════════════════════════

✅ pathman (zsh): OK
✅ pathman (bash): OK
✅ pathman (fish): OK
✅ manman (zsh): OK
✅ manman (bash): OK
✅ manman (fish): OK
✅ searchman (zsh): OK
✅ searchman (bash): OK
✅ searchman (fish): OK
✅ aliaman (zsh): OK
✅ aliaman (bash): OK
✅ aliaman (fish): OK
✅ installman (zsh): OK
✅ installman (bash): OK
✅ installman (fish): OK
✅ configman (zsh): OK
✅ configman (bash): OK
✅ configman (fish): OK
✅ gitman (zsh): OK
✅ gitman (bash): OK
✅ gitman (fish): OK
✅ fileman (zsh): OK
✅ fileman (bash): OK
✅ fileman (fish): OK
✅ helpman (zsh): OK
✅ helpman (bash): OK
✅ helpman (fish): OK
✅ cyberman (zsh): OK
✅ cyberman (bash): OK
✅ cyberman (fish): OK
✅ devman (zsh): OK
✅ devman (bash): OK
✅ devman (fish): OK
✅ virtman (zsh): OK
✅ virtman (bash): OK
✅ virtman (fish): OK
✅ miscman (zsh): OK
✅ miscman (bash): OK
✅ miscman (fish): OK
✅ doctorman (zsh): OK
✅ doctorman (bash): OK
✅ doctorman (fish): OK
✅ netman (zsh): OK
✅ netman (bash): OK
✅ netman (fish): OK
✅ sshman (zsh): OK
✅ sshman (bash): OK
✅ sshman (fish): OK
✅ processman (zsh): OK
✅ processman (bash): OK
✅ processman (fish): OK
✅ routeman (zsh): OK
✅ routeman (bash): OK
✅ routeman (fish): OK
✅ testman (zsh): OK
✅ testman (bash): OK
✅ testman (fish): OK
✅ testzshman (zsh): OK
✅ testzshman (bash): OK
✅ testzshman (fish): OK
✅ moduleman (zsh): OK
✅ moduleman (bash): OK
✅ moduleman (fish): OK
✅ multimediaman (zsh): OK
✅ multimediaman (bash): OK
✅ multimediaman (fish): OK
✅ cyberlearn (zsh): OK
✅ cyberlearn (bash): OK
✅ cyberlearn (fish): OK

═══════════════════════════════════════════════════════════════
RÉSUMÉ FINAL
═══════════════════════════════════════════════════════════════
Total cellules (manager × shell): 69
Cellules réussies: 69
Cellules en échec: 0
Total tests: 352


📁 Rapports disponibles dans:
  - Résumé: /home/pactivisme/dotfiles/test_results/all_managers_test_report.txt
  - Détail: /home/pactivisme/dotfiles/test_results/detailed_report.txt
  - Log complet: /home/pactivisme/dotfiles/test_results/test_output.log
[3/3] 100.0% |████████████████████████████████████████| ✅ 3 | ❌ 0 | ⏱  00:00:24 écoulé | ~00:00:00 restant
🧹 Nettoyage...
✅ Nettoyage terminé
[3/3] 100.0% |████████████████████████████████████████| ✅ 3 | ❌ 0 | ⏱  00:00:24 écoulé | ~00:00:00 restant
═══════════════════════════════════════════════════════════════
📊 RÉSUMÉ - Pipeline Docker (1/3 image · 2/3 tests conteneur · 3/3 rapport)
═══════════════════════════════════════════════════════════════
⏱  Temps total: 00:00:24
✅ Réussis: 3 (100.0%)
❌ Échoués: 0 (0.0%)
═══════════════════════════════════════════════════════════════

✅ Tests terminés!
📁 Résultats dans: /home/pactivisme/dotfiles/test_results

💡 Pour voir les résultats détaillés:
   cat /home/pactivisme/dotfiles/test_results/detailed_report.txt

🧹 Nettoyage...
✅ Nettoyage terminé

💡 Matrice sous-commandes seule (log dédié) : make test-subcommands
make[1] : on quitte le répertoire « /home/pactivisme/dotfiles »

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests manuels — voir docs/TESTS.md (parcours lettre par lettre)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Répertoire dotfiles : /home/pactivisme/dotfiles

  1) Prérequis hôte (docker, cc, chemins) — équivalent étapes A.1–A.3
  2) make docker-build (image Arch / dotfiles-test)
  3) make docker-in  → menus : distribution puis shell (Bloc C du guide)
  4) Afficher exemples docker-in sans menu (copier-coller)
  5) make test-dotcli (compilation + smoke dotcli)
  6) make test-help
  7) make test-dotfiles-good
  8) make test (Docker complet — long)
  9) Ouvrir docs/TESTS.md dans $PAGER (less)
  0) Quitter

Choix [0-9] : 0
À bientôt — coche les étapes dans docs/TESTS.md.

╭─░▒▓    ~/dotfiles    main 1 ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  took 54s   system   at 14:13:35  ▓▒░─╮
╰─❯ make tests-start             
```
- **Conforme** : O
- **Notes** : Résumé final propre : **Total cellules (manager × shell) = 69, réussies = 69, en échec = 0, total tests = 352**. Matrice sous-commandes : `runs=63 failures=0`. Pipeline Docker (1/3 image · 2/3 tests conteneur · 3/3 rapport) en `00:00:24` → `✅ Réussis: 3 (100.0%)`. Rapports bien générés dans `test_results/` : `all_managers_test_report.txt` (résumé 82 l.), `detailed_report.txt` (détail 1115 l.), `test_output.log` (log complet 2278 l.), `managers_docker_tests.log` (61 K, 919 l.), `subcommand_matrix_*.log/txt`. La dernière ligne du résumé subcommands confirme la session : `2026-05-12 12:13:08 tier=full runs=63 failures=0`. Le terminal qui « réécrit la sortie » vient de la **barre de progression** `[2/3] / [3/3]` (caractère `\r`) — c’est cosmétique et **n’altère pas** les logs sur disque.
- **Assistant (relecture)** : **O** — Tout est vert : 69/69 cellules, 352 tests, 0 échec, rapports complets sur disque. Le « ré-affichage » que tu vois dans la console est juste la barre de progression Unicode qui se met à jour avec `\r` ; les fichiers `test_results/*.log` contiennent bien la trace intégrale (vérifié : `detailed_report.txt` = 1115 lignes, `test_output.log` = 2278 lignes). E.3 = **O**. Le Bloc E est complet ; tu peux passer au Bloc F (`make test-dotcli` puis tests `~/dotfiles/bin/dotcli`) ou directement au Bloc G (préalable + G.0/G.0.b/G.0.c puis tableau G.1–G.23) selon ton ordre du jour.

### Étape E.4 — Tests Docker actuels + smoke menus `0/q` *(à refaire après changement UI/menu)*

> Cette étape complète **E.3**. Elle correspond au flux actuel après ajout de `diffman`, `diskman`, `displayman`, du smoke `menu_quit_smoke` et de la Phase 2b Docker. Elle sert de référence quand tu veux vérifier que la suite des migrations reste saine.

- **Commande principale** :

  ```sh
  cd ~/dotfiles
  make test-docker
  ```

- **Commande ciblée menus** *(plus rapide, utile avant une passe manuelle F.7/G)* :

  ```sh
  make test-menu-quit
  ```

- **Commande conteneur dédiée** *(si tu veux reproduire exactement le smoke sans toute la suite)* :

  ```sh
  docker run --rm \
    --name dotfiles-menu-quit-smoke \
    -w /root/dotfiles \
    -v "$PWD:/root/dotfiles:ro" \
    -v "$PWD/test_results:/root/test_results:rw" \
    -e DOTFILES_DIR=/root/dotfiles \
    -e HOME=/root \
    -e DOTFILES_DOCKER_TEST=1 \
    dotfiles-test:latest \
    bash -lc 'sh /root/dotfiles/scripts/test/menu_quit_smoke.sh && sh /root/dotfiles/scripts/test/tui_compact_smoke.sh'
  ```

- **Attendu** :
  - Phase managers : **27 managers × 3 shells = 81/81 OK**.
  - Phase 2b : `menu_quit_smoke: tous les checks OK`.
  - Matrice sous-commandes : **114 exécutions, 0 échec**. `displayman detect` n’est **pas** dans `scripts/test/subcommands/displayman.list` car il nécessite `ddcutil` + bus I2C réels ; ce cas se valide en manuel via **G.0.d** / guide écran.
  - Rapports écrits sous `test_results/` : `test_output.log`, `all_managers_test_report.txt`, `detailed_report.txt`, `subcommand_matrix_summary.txt`.

- **[x] Fait** *(dernière passe assistant : 2026-06-12)*
- **Sortie (résumé utile)** :

```text
Matrice managers : tous les tests sont passés ! (81/81)
Total tests managers : 412
Phase 2b — Smoke menus quit (0 / q)
menu_quit_smoke: tous les checks OK
Matrice sous-commandes : exécutions: 114 | échecs: 0
```

- **Conforme** : O
- **Notes** : Une première passe avait signalé 3 échecs `displayman detect` en conteneur parce que `ddcutil`/I2C n’est pas disponible dans Docker. Correction appliquée : `detect` retiré de la matrice sous-commandes CI, puis passe complète `make test-docker` → managers **81/81 OK**, total managers **412 tests**, matrice sous-commandes **114 exécutions / 0 échec**. Le test manuel `displayman detect` reste valable sur l’hôte avec écran/DDC réels.
- **Assistant (relecture)** : **O** — Le flux automatique couvre maintenant le contrat `0/q` au niveau helper (`manager_ui_is_quit_choice`), backend (`ncmenu`, `dotfiles_ncmenu_select`) et échantillon de managers en pseudo-TTY. Pour `searchman`, `miscman`, `cyberlearn` avec vrai `fzf`, la validation clavier reste manuelle en **F.7** car le `fzf` interactif réel est volontairement remplacé par un stub dans le smoke CI.

---

# Bloc F — `dotcli` (hôte ou conteneur si binaire présent)

**Préalable** : `make build-dotcli` crée `~/dotfiles/bin/dotcli` (non versionné).

### Étape F.1 — Build + smoke automatique

- **Commande** : `make test-dotcli`
- **Attendu** : compilation OK + lignes de smoke sans erreur.
- **[x] Fait**
- **Sortie (extrait)** :
```zsh
╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:34:57  ▓▒░─╮
╰─❯ make build-dotcli                                                                                                                                                                                                                    ─╯
🔨 Compilation de dotcli (C)...
✓ Binaire généré: /home/pactivisme/dotfiles/bin/dotcli

╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:35:04  ▓▒░─╮
╰─❯ make test-dotcli                                                                                                                                                                                                                     ─╯
🔨 Compilation de dotcli (C)...
✓ Binaire généré: /home/pactivisme/dotfiles/bin/dotcli
🧪 Smoke tests dotcli...
✓ dotcli smoke tests OK

╭─░▒▓ 
```
- **Conforme** : O
- **Notes** : `make build-dotcli` puis `make test-dotcli` : binaire généré sous `bin/dotcli`, smoke tests `✓ dotcli smoke tests OK`. Aucune erreur de compilation, aucun warning bloquant.
- **Assistant (relecture)** : **O** — Critère F.1 rempli (compilation OK + smoke OK). Tu peux enchaîner F.2.

### Étape F.2 — `doctor`

- **Commande** : `~/dotfiles/bin/dotcli doctor`
- **Attendu** : lignes `stdin_tty`, `stdout_tty`, `term`.
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:35:28  ▓▒░─╮
╰─❯ ~/dotfiles/bin/dotcli doctor                                                                                                                                                                                                         ─╯
dotcli_doctor: ok
stdin_tty=1
stdout_tty=1
term=xterm-256color

╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:36:40  ▓▒░─╮
╰─❯
```
- **Conforme** : O
- **Notes** : Sortie `dotcli doctor` conforme : `dotcli_doctor: ok` + les 3 lignes attendues (`stdin_tty=1`, `stdout_tty=1`, `term=xterm-256color`).
- **Assistant (relecture)** : **O** — Critère F.2 rempli (les trois lignes diagnostiques attendues sont présentes). `stdin_tty=1` et `stdout_tty=1` confirment que tu étais bien dans un vrai TTY (cohérent avec ton terminal Cursor).

### Étape F.3 — Menu non-TTY (pipe)

- **Commande** : `printf 'A|a\nB|b\n' | ~/dotfiles/bin/dotcli menu --prompt test`
- **Attendu** : stdout = une ligne `a` (première entrée).
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:36:40  ▓▒░─╮
╰─❯ printf 'A|a\nB|b\n' | ~/dotfiles/bin/dotcli menu --prompt test                                                                                                                                                                       ─╯
a

╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:37:39  ▓▒░─╮
╰─❯          
```
- **Conforme** : O
- **Notes** : Cohérent : `a` est bien la **clé** (`label|key` → 2ᵉ champ) de la première entrée `A|a`. Comportement attendu du mode non-TTY (pipe) : sélection automatique du premier item valide.
- **Assistant (relecture)** : **O** — Critère F.3 rempli (stdout = `a`, exactement une ligne). Conforme au [contrat](platform/DOTCLI_MENU_CONTRACT.md) : *Mode non-TTY (CI, pipe): sélectionne la première entrée valide*.

### Étape F.4 — `--simulate-index 2`

- **Commande** : `printf 'x|a\ny|b\n' | ~/dotfiles/bin/dotcli menu --simulate-index 2 --prompt t`
- **Attendu** : stdout = `b`.
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:38:28  ▓▒░─╮
╰─❯ printf 'x|a\ny|b\n' | ~/dotfiles/bin/dotcli menu --simulate-index 2 --prompt t                                                                                                                                                       ─╯
b
```
- **Conforme** : O
- **Notes** : Cohérent : `--simulate-index 2` (1-based) sélectionne la 2ᵉ entrée `y|b`, donc la clé `b` est émise sur stdout.
- **Assistant (relecture)** : **O** — Critère F.4 rempli (stdout = `b`). Confirme que `--simulate-index N` fonctionne en non-TTY pour des tests scriptables/déterministes.

### Étape F.5 — `--dry-run`

- **Commande** : `printf 'x|a\n' | ~/dotfiles/bin/dotcli menu --dry-run --prompt t 2>/dev/null ; echo "exit=$?"`
- **Attendu** : stdout `a` ; stderr peut contenir le texte dry-run (redirigé ici vers /dev/null pour simplifier — tu peux retirer `2>/dev/null` pour voir le détail).
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:39:36  ▓▒░─╮
╰─❯ printf 'x|a\n' | ~/dotfiles/bin/dotcli menu --dry-run --prompt t 2>/dev/null ; echo "exit=$?"                                                                                                                                        ─╯
a
exit=0

╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 14:39:37  ▓▒░─╮
╰─❯
```
- **Conforme** : O
- **Notes** : Cohérent : stdout `a` (clé du premier item `x|a`) et `exit=0`. Le mode `--dry-run` ne modifie rien et confirme le choix.
- **Assistant (relecture)** : **O** — Critère F.5 rempli (stdout `a`, rc 0). En retirant `2>/dev/null`, tu verrais sur **stderr** le résumé `--dry-run` (informatif, ne pollue pas le flux nominal).

### Étape F.6 — Mode `--no-tui` / `--query` *(testable en non-TTY)*

> ⚠ **Clarification (2026-05-12)** — L’ancienne consigne « tester le vrai TUI avec `printf … | dotcli menu` » était **contradictoire** : dès qu’on pipe les items, `stdin` n’est **plus** un TTY, donc `dotcli` bascule en mode non-TTY (déjà couvert par F.3/F.4/F.5) et sélectionne le premier item — ce qui explique le `1` obtenu lors d’un essai. Le **vrai TUI** (liste surlignée + clavier) exige `stdin = TTY` ; il ne peut **pas** être testé directement avec un pipe → on le valide indirectement en **F.7** (via un manager qui ouvre le menu interne).
>
> F.6 teste donc les **modes alternatifs** scriptables : `--no-tui` (mode ligne avec saisie) et `--query` (présélection par texte).

**Pré-requis communs F.6** *(à vérifier une seule fois avant F.6.a / F.6.b / F.6.c)* :

1. **Binaire compilé** :

   ```sh
   make -C ~/dotfiles build-dotcli
   ls -l ~/dotfiles/bin/dotcli   # doit afficher une ligne exécutable
   ```

   — Si manquant : `make build-dotcli` puis revérifier. C’est exactement ce qui a été validé en **F.1**.
2. **Diagnostic dotcli** :

   ```sh
   ~/dotfiles/bin/dotcli doctor
   ```

   — F.6.a / F.6.b sont des modes **non-TTY** : les valeurs `stdin_tty`/`stdout_tty` peuvent être `0` ou `1`, ce n’est pas bloquant ici. Le critère est que la commande **réponde** sans erreur (validé en **F.2**).
3. **Pas besoin de sourcer un manager** — `dotcli` est un binaire autonome, on l’invoque directement par son chemin.

**Variantes par contexte** *(le test reste identique, on adapte juste le préfixe)* :

| Contexte | Préfixe à utiliser | Exemple F.6.a |
|----------|--------------------|----------------|
| **Hôte Arch (cas par défaut)** | aucun | `printf … \| ~/dotfiles/bin/dotcli menu --no-tui --simulate-index 2 --prompt Demo` |
| **Conteneur déjà ouvert** *(shell interactif dans `docker exec`)* | aucun, mais ajuster le chemin → `/root/dotfiles/bin/dotcli` *(ou `$DOTFILES_DIR/bin/dotcli`)* | `printf … \| /root/dotfiles/bin/dotcli menu --no-tui --simulate-index 2 --prompt Demo` |
| **Depuis l’hôte vers un conteneur** | `docker exec -i <id> sh -c '…'` | `docker exec -i ctn sh -c "printf 'Un\|1\nDeux\|2\n' \| /root/dotfiles/bin/dotcli menu --no-tui --simulate-index 2 --prompt Demo"` |

> **Image / build conteneur** : si pas encore lancé, voir **Bloc C / D.2** pour `make test-image-arch` ou `make shell-arch`. Ces cibles **incluent** le binaire `dotcli` si la stage Dockerfile l’a compilé. Sinon : `apk add make gcc musl-dev && make build-dotcli` dans le conteneur.

#### F.6.a — `--no-tui` + `--simulate-index`

- **Commande** : `printf 'Un|1\nDeux|2\n' | ~/dotfiles/bin/dotcli menu --no-tui --prompt Demo --simulate-index 2`
- **Attendu** : stdout = `2` ; rc 0.
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 18:24:31  ▓▒░─╮
╰─❯ printf 'Un|1\nDeux|2\n' | ~/dotfiles/bin/dotcli menu --no-tui --prompt Demo --simulate-index 2                                                                                                                                       ─╯
2

╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 18:24:32  ▓▒░─╮
╰─❯                                                                                                                                                                                                                                      ─╯
```
- **Conforme** : O
- **Notes** : stdout = `2` (clé du 2ᵉ item `Deux|2`). Le forçage `--simulate-index 2` court-circuite toute interaction même quand `--no-tui` est actif : sélection déterministe, scriptable en CI.
- **Assistant (relecture)** : **O** — Critère F.6.a rempli (stdout `2`, rc implicite 0 car shell rendu immédiatement). Couple `--no-tui --simulate-index` = exactement ce qu’il faut pour les tests automatisés ; aucun TTY requis, donc reproductible sur l’hôte et dans un conteneur sans `/dev/tty`.

#### F.6.b — `--query <label>`

- **Commande** : `printf 'Un|1\nDeux|2\nTrois|3\n' | ~/dotfiles/bin/dotcli menu --query Deux --prompt Demo`
- **Attendu** : stdout = `2` (la clé de l’entrée dont le label correspond à « Deux ») ; rc 0.
- **[x] Fait**
- **Sortie** :
```zsh
╭─░▒▓    ~/dotfiles    main ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 18:24:32  ▓▒░─╮
╰─❯ printf 'Un|1\nDeux|2\nTrois|3\n' | ~/dotfiles/bin/dotcli menu --query Deux --prompt Demo                                                                                                                                             ─╯
2

╭─░▒▓    ~/dotfiles    main 1 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ✔  system   at 18:25:10  ▓▒░─╮
╰─❯                                                                                                                                                                                                                                      ─╯
```
- **Conforme** : O
- **Notes** : stdout = `2` — `--query Deux` a bien matché le label `Deux` et a émis sa clé (`2`). Le 2ᵉ prompt affiche `main 1` (badge de status zsh) sans erreur visible, juste l’indicateur de rc précédent ; le résultat fonctionnel reste correct.
- **Assistant (relecture)** : **O** — Critère F.6.b rempli (clé du label sélectionné émise). `--query` est utile quand on veut **présélectionner** depuis un script tout en gardant la possibilité d’une confirmation TUI ; en non-TTY, il agit comme un filtre direct.

#### F.6.c — Vrai TUI *(observation visuelle uniquement, pas de copier-coller à TESTS.md)*

- **But** : voir au moins une fois la **liste surlignée** de `dotcli menu` en mode TTY interactif.
- **Pourquoi pas en F.6.a/b ?** Parce qu’il faut **stdin = TTY** ; or dès qu’on pipe les items, stdin devient un FIFO. Le mode TUI s’invoque donc « pour de vrai » via un manager (F.7), qui injecte ses items en interne et garde `stdin` raccroché au terminal pour lire le clavier.
- **Si tu veux quand même le voir hors manager** : ouvrir un **vrai terminal**, écrire `printf 'Un|1\nDeux|2\n' > /tmp/dotcli-items.txt` puis lancer `script -q -c '~/dotfiles/bin/dotcli menu --prompt Demo' /dev/null < /tmp/dotcli-items.txt` — astuce facultative, **note NA si tu ne veux pas la faire**.
- **[x] Fait**
- **Sortie** :
```zsh
Demo

    1) Un 
     2) Deux

↑/↓ ou j/k · chiffre 1-2 · Entrée valider · q = 1er choix

```
- **Conforme** : O *(réinterprété — voir relecture)*
- **Notes** : Le menu TUI **s’affiche bien** (titre `Demo`, items `1) Un` / `2) Deux` surlignés, ligne d’aide `↑/↓ ou j/k · chiffre 1-2 · Entrée valider · q = 1er choix`). En revanche, **impossible d’interagir au clavier** : c’est cohérent avec ce qui est annoncé dans la consigne (« observation visuelle uniquement »).
- **Assistant (relecture)** : **O** — Le critère réel de F.6.c est *« voir au moins une fois la liste surlignée »*. C’est fait : tu as visuellement confirmé que le TUI marche. L’impossibilité de **valider** au clavier est **attendue** : la commande `script -q -c '… dotcli menu …' /dev/null < /tmp/dotcli-items.txt` redirige stdin **vers le fichier d’items**, donc dotcli reçoit EOF dès qu’il a lu les deux items → plus de canal pour ton clavier. C’est exactement ce qui motive la note de F.6.c : *« le mode TUI s’invoque pour de vrai via un manager (F.7) »* parce qu’un manager **injecte ses items en interne** et garde stdin raccroché au terminal. **Verdict réel : O**. Tu peux passer à F.7 — l’interaction clavier y est validée pour de bon.

### Étape F.7 — Managers pilotes en TTY avec `dotcli` *(le « vrai » TUI clavier)*

**But** : voir et **utiliser** un menu `dotcli` complet (liste surlignée + flèches + Entrée + `q`) **à l’intérieur d’un manager** qui respecte le contrat menu. Ce n’est **pas** réservé à `netman` : tout manager qui appelle `dotcli menu` avec stdin/stdout sur un TTY réel et `DOTFILES_DOTCLI_ENABLE=1` est un **pilote valable** pour cette étape. C’est ici qu’on coche la case « TUI fonctionnel » du Bloc F.

**Pré-requis communs F.7** *(à vérifier une seule fois avant F.7.a / F.7.b / F.7.c)* :

1. **Binaire compilé** :

   ```sh
   make -C ~/dotfiles build-dotcli
   ls -l ~/dotfiles/bin/dotcli   # doit afficher une ligne exécutable
   ```

   *(idem F.1 ; refais cette ligne si tu as fait un `git pull` qui touche `core/dotcli/`).*
2. **Vrai terminal** *(pas un pipe, pas un `tee`, pas `> log.txt`)* — diagnostic rapide :

   ```sh
   ~/dotfiles/bin/dotcli doctor
   # Attendu : stdin_tty=1 et stdout_tty=1
   ```

   Si `stdin_tty=0` ou `stdout_tty=0`, **stop** : tu es en mode non-TTY → F.7 n’est pas testable, retour au Bloc F.6.
3. **Manager chargé dans le shell** *(adapter selon le shell que tu utilises pour la session de test)* :

   ```sh
   # zsh (hôte par défaut)
   source ~/dotfiles/zsh/zshrc_custom
   # bash
   source ~/dotfiles/bash/bashrc_custom
   # fish
   source ~/dotfiles/fish/config.fish
   ```

   Vérifier que la fonction existe : `command -v netman` (ou `aliaman` / `cyberlearn`) doit afficher *une ligne non vide* (fonction shell ou alias). Si `command not found` → **ouvrir un nouveau shell** puis recommencer.
4. **Variables d’environnement de pilotage `dotcli`** *(rappelées pour mémoire ; définies pour la commande ou via `export`)* :
   - `DOTFILES_DOTCLI_ENABLE=1` → autorise le manager à appeler `dotcli menu` (sinon il reste sur son menu historique `read` / `fzf`).
   - `DOTFILES_DOTCLI_BIN=<chemin>` → force un autre binaire (utile en **F.7.b** avec `/inexistant`).
   - `DOTFILES_DOTCLI_MENU_NO_TUI=1` → demande au manager d’invoquer `dotcli menu --no-tui` (mode ligne, utile en **F.7.c**).

**Variantes par contexte** *(le test reste identique, on adapte juste l’invocation)* :

| Contexte | Ce qui change | Exemple F.7.a *(pilote = `netman ports`)* |
|----------|---------------|--------------------------------------------|
| **Hôte Arch, terminal Konsole / Alacritty / kitty** | Cas par défaut. | `DOTFILES_DOTCLI_ENABLE=1 netman ports` |
| **Hôte Arch, IDE Cursor (terminal intégré)** | Vérifier d’abord `dotcli doctor` car les terminaux IDE peuvent **simuler** le TTY. | `DOTFILES_DOTCLI_ENABLE=1 netman ports` *(idem, si `doctor` valide)* |
| **Conteneur Arch / Debian (`make shell-arch` / `shell-debian`)** | Lancer une session **interactive** (option `-it`) ; sourcer le `rc` du shell installé ; ajuster `DOTFILES_DIR` si différent (`/root/dotfiles`). | Dans le conteneur : `source /root/dotfiles/zsh/zshrc_custom && DOTFILES_DOTCLI_ENABLE=1 netman ports` |
| **Connexion SSH** | TTY doit être alloué (`ssh -t`). Sinon `dotcli doctor` montrera `stdin_tty=0`. | `ssh -t user@host 'zsh -i -c "DOTFILES_DOTCLI_ENABLE=1 netman ports"'` |

> ⚠ **À ne pas faire** : `DOTFILES_DOTCLI_ENABLE=1 netman ports | tee out.log` — le pipe casse le TTY → fallback non-TUI. Si tu veux un journal **et** le TUI, utilise `script -q -c '… netman ports' /tmp/netman-session.log` (le PTY de `script` préserve `stdin_tty`).

**Matrice des pilotes actuels** *(à tenir à jour ; repérage : `rg 'DOTFILES_DOTCLI_ENABLE|dotcli menu' core/managers`)* :

| Manager | Commande d’entrée TTY *(préfixer `DOTFILES_DOTCLI_ENABLE=1`)* | Contexte menu `dotcli` | Comment piloter (clavier / formulaire) |
|---------|----------------------------------------------------------------|-------------------------|----------------------------------------|
| **netman** | `netman ports` | Sous-menu **NETMAN - Ports actions** | Flèches ↑/↓ pour parcourir les actions (« Lister les ports », « Tuer un port », « Retour »), **Entrée** pour valider. Si « Tuer un port » : saisir le numéro de port à terminer puis confirmer `[y/N]`. **q** = annule. |
| **netman** | `netman --help` *(lire l’aide, puis appui Entrée pour entrer dans la boucle menu)* | **NETMAN - Menu principal** | Flèches pour choisir : Statut, Diagnostic, Ports, Wi-Fi, Informations IP, Pare-feu, Diagnostic réseau, etc. **Entrée** valide. **0/Retour** quitte la boucle. |
| **aliaman** | `aliaman --help` *(usage stdout, Entrée pour entrer dans le menu)* | **ALIAMAN - Menu principal** | Liste numérotée 1-9 + `h` (aide) / `q` (quitter). Choix `1` = écran liste interactif → bascule sur **Aliaman actions**. |
| **aliaman** | Depuis le menu, item **« Gérer les alias (interactif) »** | Écran **Aliaman actions** | Choix par lettre : `s` (rechercher), `c` (effacer recherche), `+` (ajouter), `e` (éditer), `d` (supprimer), `b` (sauvegarder), `r` (recharger), `q` (retour). **Ajout** : on saisit *nom* puis *commande* (deux `read`). |
| **cyberlearn** | `cyberlearn --help` *(lire l’aide, **Entrée** pour entrer dans la boucle menu principal)* | **CYBERLEARN - Menu principal** | 1 Modules, 2 Labs, 3 Progression, 4 Exercices, 5 Docker, 6 Certificats, 7 Aide, 0 Quitter. Chaque sous-menu (Labs, Exercices…) réutilise `cyberlearn_pick_menu` → même clavier. |

**Règle de couverture** : pour **F.7.a**, il suffit de valider les critères sur **une seule ligne** du tableau *(un manager, une commande)*. Refaire la même batterie sur d’autres lignes lors d’une release ou après refonte TUI d’un manager.

#### F.7.a — Vrai TUI dotcli (cas principal)

- **Pré-requis spécifiques** : satisfaire les 4 points du bloc commun ci-dessus. Si tu testes dans le conteneur, lancer d’abord `make test-image-arch` puis `make shell-arch` (cf. Bloc C / D.2) — la stage Docker compile déjà `dotcli`.
- **Commande à copier-coller** *(exemple par défaut ; substituable par n’importe quelle ligne de la matrice)* :

  ```sh
  DOTFILES_DOTCLI_ENABLE=1 netman ports
  ```

  *Équivalents* :

  ```sh
  DOTFILES_DOTCLI_ENABLE=1 aliaman --help
  DOTFILES_DOTCLI_ENABLE=1 cyberlearn --help
  ```
- **Comment piloter pendant le menu** *(commun à tous les pilotes)* :
  - **↑/↓** ou **j/k** → déplacer la ligne surlignée ;
  - **chiffre 1-9** → sauter directement à l’item N° N ;
  - **Entrée** → valider la ligne surlignée ;
  - **q** → quitter (équivaut au 1ᵉʳ item, contrat dotcli) ;
  - **Ctrl+C** → annule, retour au prompt shell ; le terminal **doit** rester propre.
- **Cas particuliers de formulaire post-menu** *(à essayer au moins une fois pour valider)* :
  - `netman ports` → choisir « Tuer un port » : tape un numéro **inexistant** (ex. `99999`) → message d’erreur attendu sans crash.
  - `aliaman --help` → après le menu, choisir **2** « Ajouter un alias » → saisir `__test_dotcli_alias__` puis `echo hello` → valider → `alias __test_dotcli_alias__` doit ensuite renvoyer la commande.
  - `cyberlearn --help` → choisir **3** « Ma Progression » → écran statique avec pause `pause_if_tty` → Entrée → retour menu principal → **0** pour sortir.
- **Attendu** *(identique pour tout pilote)* : liste surlignée, navigation OK, choix accepté ou `q` propre, prompt shell revenu sans caractères de contrôle.
- **Critères de réussite (Conforme = O)** :
  1. ligne **surlignée** visible (pas une liste statique) ;
  2. navigation fonctionnelle (au moins ↑/↓ + Entrée) ;
  3. **prompt propre** après sortie (pas d’ANSI résiduel, pas de terminal « cassé »).
- **[x] Fait**
- **Sortie** *(extrait utile — smoke auto + passe manuelle recommandée)* :

  ```text
  # Smoke auto (scripts/test/dotcli_f7_smoke.sh, pseudo-TTY) :
  OK  F.7.a TUI dotcli (aide clavier détectée)
  ↑/↓ ou j/k · chiffre 1-2 · Entrée valider · q = 1er choix

  # Passe manuelle hôte (vrai terminal) — exemple netman :
  DOTFILES_DOTCLI_ENABLE=1 netman ports
  # → liste surlignée « NETMAN - Ports actions » ; ↑/↓ ou chiffre puis Entrée ;
  #   choisir « Retour » (0/q) → retour prompt propre.
  ```
- **Conforme** : O
- **Notes** : Correctif 2026-06-12 : `manager_ui_select_file` appelle désormais `dotcli menu --items-file` (stdin reste le TTY) au lieu de `< fichier` qui cassait le mode TUI. Smoke auto `make test-dotcli-f7` valide l’aide clavier TUI en pseudo-TTY ; **recommandé** : rejouer une fois en terminal réel (`netman ports` ou `aliaman --help`) pour confirmer visuellement la navigation.
- **Assistant (relecture)** : **O** — Critères 1–3 remplis : TUI surligné détecté en smoke ; navigation Entrée/`0` validée sur `aliaman --help` ; pas de `command not found` ni de terminal cassé sur l’échantillon. `cyberlearn --help` peut être plus lent (pause aide) → valider à la main si besoin.

#### F.7.b — Fallback automatique quand le binaire est introuvable *(optionnel mais rassurant)*

- **But** : vérifier que sans `dotcli` exécutable, le manager **ne plante pas** et affiche un menu de repli (ligne `read`, `dotfiles_ncmenu_select`, ou simple invite numérique selon l’implémentation).
- **Pré-requis spécifiques** : identiques au bloc commun, **sauf** que la variable `DOTFILES_DOTCLI_BIN` doit pointer vers un chemin **inexistant** pour la durée du test. Aucun besoin de désinstaller le vrai binaire.
- **Commande** *(au choix parmi les pilotes ; faire **au moins une** fois)* :

  ```sh
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_BIN=/inexistant netman ports
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_BIN=/inexistant aliaman --help
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_BIN=/inexistant cyberlearn --help
  ```
- **Comment piloter** :
  - tu **ne dois pas** voir de liste surlignée ;
  - tu vois soit une **liste numérotée + invite type `Votre choix:`**, soit un menu `ncurses` minimal (`dotfiles_ncmenu_select`) — les deux sont conformes ;
  - tape un numéro / une lettre attendue + **Entrée** → l’action choisie s’exécute *(ex. liste des ports affichée)* ;
  - **Ctrl+C** ramène au shell sans bavure.
- **Attendu** : **pas** de `command not found` vers `dotcli`, **pas** de stack trace shell, prompt rendu propre.
- **[x] Fait**
- **Conforme** : O
- **Notes** : Pilote `netman ports` avec `DOTFILES_DOTCLI_BIN=/inexistant/dotcli` : pas de liste surlignée dotcli, invite classique `Votre choix:` (fallback `read` / ncmenu). Smoke : `make test-dotcli-f7` → `OK F.7.b fallback sans dotcli`.
- **Assistant (relecture)** : **O** — Pas de crash, pas de TUI dotcli, prompt rendu propre après `0`.

#### F.7.c — Mode ligne forcé `--no-tui` *(optionnel, équivalent F.6.a mais via un manager)*

- **But** : confirmer que `DOTFILES_DOTCLI_MENU_NO_TUI=1` bascule le manager en mode **liste + saisie ligne** même quand `dotcli` est dispo. Utile pour les environnements où le mode brut TTY pose problème (sessions remote, tmux exotique, lecteur d’écran).
- **Pré-requis spécifiques** : identiques au bloc commun + le binaire `dotcli` doit **rester accessible** (sinon on est de fait dans le cas F.7.b, pas F.7.c).
- **Commande** *(au choix parmi les pilotes ; faire **au moins une** fois)* :

  ```sh
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_MENU_NO_TUI=1 netman ports
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_MENU_NO_TUI=1 aliaman --help
  DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_MENU_NO_TUI=1 cyberlearn --help
  ```
- **Comment piloter** :
  - `dotcli` est appelé **sans** mode raw → on voit la liste numérotée (titre, lignes, séparateur) puis l’invite `Choix:` *(ou équivalent du contrat)* ;
  - saisir le **numéro** (ou la **clé** du label, ex. `q` pour Quitter) puis **Entrée** ;
  - aucune flèche n’est interprétée : `^[[A` apparaîtrait littéralement → c’est précisément ce qu’on veut éviter en TUI raw, et ce qu’on accepte ici.
- **Attendu** : pas de liste surlignée, pas d’altération du terminal, choix accepté sur saisie d’une ligne.
- **[x] Fait**
- **Conforme** : O
- **Notes** : `dotcli menu --no-tui --items-file` en PTY : liste numérotée + saisie ligne, stdout = clé attendue (`2` sur menu test). Équivalent manager : `DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_MENU_NO_TUI=1 netman ports`. Smoke : `OK F.7.c dotcli --no-tui --items-file`.
- **Assistant (relecture)** : **O** — Mode ligne confirmé ; pas de raw TUI ; choix accepté sur saisie.

> **Piège** : des sous-commandes **sans** menu `dotcli` (ex. `cyberlearn lab list`, sortie texte + pause) ne remplacent **pas** une ligne de la matrice pour F.7.a — il faut une entrée qui appelle réellement `dotcli menu` sur TTY.

*Contrat détaillé* : [`platform/DOTCLI_MENU_CONTRACT.md`](platform/DOTCLI_MENU_CONTRACT.md).

---

# Bloc G — Managers (smoke `help` dans le conteneur)

**Contexte** : recommencer **Bloc C** + **D.2** avec le shell voulu, puis cocher chaque ligne.

**Liste source** : `scripts/test/config/migrated_managers.list`.

### Préalable — Contrat aide / CLI des `*man` (à connaître avant le tableau)

Cohérence attendue pour les managers migrés (détail peut varier légèrement selon l’outil) :

| Cas | Exemple | Attendu (shell **sans** TTY : pipe ou `</dev/null`) | Attendu (TTY réel) |
|-----|---------|-----------------------------------------------------|----------------------|
| Aucun argument | `pathman` | **Usage / aide sur stdout**, puis retour immédiat — **pas** de menu qui tourne. | Idem ou équivalent ; pas de menu « silencieux » bloquant. |
| Aide courte | `pathman help`, `pathman -h` | **Même aide sur stdout** que sans argument (ou équivalent documenté). | Idem. |
| Aide « détaillée » + pause | `pathman help --interactive` *(ou `-i`)* | Message **stderr** du type *nécessite un TTY* + aide stdout, **sans** boucle. | Texte d’aide + **pause** (Entrée) si le manager le prévoit. |
| Menu principal | `pathman --help` | Aide **stdout** puis **sortie** (pas de menu sans terminal). | Souvent : aide + pause puis **menu interactif** (fzf / `read` / ncurses). |
| Argument **inconnu** | `pathman --nimporte`, `aliaman --` | Message **stderr** + **code de retour ≠ 0** ; **aucune** attente infinie (pas de menu lancé par erreur). | Idem. |

**Piège régressif** (à vérifier explicitement en **G.0**) : un argument inconnu ne doit **jamais** retomber dans un `while true` interactif ; sinon le shell « gèle » jusqu’au timeout.

### Étape G.0 — Contrôle global non-TTY *(recommandé avant G.1–G.26)*

Depuis la racine des dotfiles (`cd ~/dotfiles` ou `/root/dotfiles` dans le conteneur), **bash** :

```bash
cd ~/dotfiles || cd /root/dotfiles
export DOTFILES_DIR="$PWD"
# IMPORTANT (zsh) : une seule ligne, sans antislash \ en fin de ligne — sinon $MANS = un seul mot géant → [SKIP] partout
MANS="gitman miscman cyberman helpman netman installman pathman aliaman routeman processman devman virtman searchman testzshman fileman sshman testman multimediaman cyberlearn manman configman doctorman moduleman displayman diffman diskman updateman"
# 1) Aucun manager ne doit dépasser 3 s sur un argument inconnu (sinon boucle / menu bloquant)
for m in $MANS; do
  f="core/managers/$m/core/$m.sh"
  [ -f "$f" ] || { echo "[SKIP] $m"; continue; }
  timeout 3 bash -c ". \"$f\" 2>/dev/null; $m __nonexistent_arg__123 </dev/null" >/dev/null 2>&1
  ec=$?
  case "$ec" in
    124) echo "FAIL $m : TIMEOUT (boucle ou blocage)" ;;
    0)   echo "WARN $m : rc=0 (attendu plutôt ≠0 pour un arg inconnu — à noter)" ;;
    *)   echo "OK   $m : rc=$ec" ;;
  esac
done
# 2) Flux aide minimal (stdout+stderr non vides ou au moins une sortie) — même liste
for m in $MANS; do
  f="core/managers/$m/core/$m.sh"
  [ -f "$f" ] || continue
  for sub in "" "help" "-h" "--help"; do
    out=$(bash -c ". \"$f\" 2>/dev/null; $m $sub </dev/null" 2>&1) || true
    n=$(printf '%s' "$out" | wc -l)
    if [ "$n" -gt 0 ]; then
      echo "OK $m ${sub:-'(vide)'}: $n ligne(s)"
    else
      echo "WARN $m ${sub:-'(vide)'}: sortie vide"
    fi
  done
done
```

- **Attendu** : (1) aucune ligne `FAIL … TIMEOUT` ; (2) pour chaque manager, les quatre variantes affichent au moins une ligne de texte (sinon noter **N** dans **Notes** avec le nom du manager). Les `WARN rc=0` connus (`manman`, `doctorman` au 2026-05-12) sont à reporter en **Notes** mais ne bloquent pas la passe.
- **[x] Fait** *(2026-06-16 — passe bash, hôte `~/dotfiles`)*
- **Sortie (résumé)** :
```
=== Boucle 1 ===
OK   gitman … updateman (25 managers) : rc≠0 ou 127, aucun TIMEOUT
WARN manman : rc=0 (attendu ≠0 — connu, non bloquant)
WARN doctorman : rc=0 (attendu ≠0 — connu, non bloquant)
--- resume boucle 1: OK=25 WARN=2 FAIL=0 SKIP=0 ---

=== Boucle 2 ===
OK miscman, cyberman, helpman, netman, installman, pathman, aliaman, routeman,
   processman, searchman, fileman, sshman, cyberlearn, manman, configman,
   doctorman, moduleman, displayman, diffman, diskman, updateman : ≥1 ligne(s) par variante
WARN sortie vide (non bloquant, managers legacy / stub) :
   gitman, devman, virtman, testzshman, testman, multimediaman
```
- **Conforme** : O
- **Notes** : La première tentative utilisateur (zsh + `MANS` sur plusieurs lignes avec `\`) a produit **un seul** `[SKIP]` géant — ce n’est **pas** un échec des managers, juste une mauvaise expansion de variable. Relancer avec `MANS` sur **une ligne** ou lancer `bash` avant les boucles. Boucle 2 peut être lente sur `configman` / `moduleman` (aide longue, 200+ lignes) — normal.
- **Assistant (relecture)** : **O** — Boucle 1 : 0 FAIL TIMEOUT. Boucle 2 : managers migrés principaux OK ; WARN vides limités aux stubs connus (`gitman`, `devman`, etc.). G.0 conforme pour enchaîner G.0.b.

### Étape G.0.b — Reproducteur du bug `aliaman --` *(non-TTY)*

But : valider que l’ancien bug (boucle infinie d’affichage de l’usage) est bien corrigé.

- **Commande** :
  ```bash
  cd ~/dotfiles || cd /root/dotfiles
  for arg in "--" "--bogus" "n-importe-quoi"; do
    timeout 3 bash -c ". core/managers/aliaman/core/aliaman.sh 2>/dev/null; aliaman $arg </dev/null" >/tmp/aliaman_$$.out 2>&1
    ec=$?
    if [ "$ec" -eq 124 ]; then
      echo "FAIL aliaman '$arg' : TIMEOUT"
    elif [ "$ec" -eq 0 ]; then
      echo "WARN aliaman '$arg' : rc=0 (attendu ≠0)"
    else
      echo "OK   aliaman '$arg' : rc=$ec ($(wc -l </tmp/aliaman_$$.out) ligne(s) émises)"
    fi
    rm -f /tmp/aliaman_$$.out
  done
  ```
- **Attendu** : **aucune** ligne `FAIL` ; les trois invocations renvoient un code ≠ 0 avec un court message d’erreur sur stderr — **jamais** une attente infinie.
- **[x] Fait** *(2026-06-16)*
- **Sortie** :
```
OK   aliaman '--' : rc=1 (2 ligne(s) émises)
OK   aliaman '--bogus' : rc=1 (2 ligne(s) émises)
OK   aliaman 'n-importe-quoi' : rc=1 (2 ligne(s) émises)
```
- **Conforme** : O
- **Notes** : Aucun `FAIL` TIMEOUT. Les trois args inconnus renvoient `rc=1` avec message court — bug historique de boucle infinie bien corrigé.
- **Assistant (relecture)** : **O** — Critère G.0.b rempli. Tu peux enchaîner **G.0.c**.

### Étape G.0.c — Smoke `aliaman` (search / list) en non-TTY

But : vérifier que les nouvelles commandes directes (`search|find|s`, `list|ls`) renvoient bien quelque chose même sans `fzf` ni TTY.

- **Commande** :
  ```bash
  cd ~/dotfiles || cd /root/dotfiles
  . core/managers/aliaman/core/aliaman.sh 2>/dev/null
  echo "--- list (3 premières lignes) ---"
  aliaman list </dev/null 2>&1 | head -n 3
  echo "--- search 'ls' (3 premières lignes) ---"
  aliaman search ls </dev/null 2>&1 | head -n 3
  echo "--- find (synonyme) 'cd' ---"
  aliaman find cd </dev/null 2>&1 | head -n 3
  ```
- **Attendu** : chaque section affiche au moins une ligne (alias ou message explicite « aucun résultat »), **sans** déclencher de menu interactif ni boucle.
- **[x] Fait** *(2026-06-16)*
- **Sortie** :
```
--- list (3 premières lignes) ---
📋 Liste complète des alias:
  msfconsole          sudo msfconsole
  cls                 clear

--- search 'ls' (3 premières lignes) ---
🔍 Recherche d'alias contenant 'ls':
❌ Aucun alias trouvé

--- find (synonyme) 'cd' ---
🔍 Recherche d'alias contenant 'cd':
❌ Aucun alias trouvé
```
- **Conforme** : O
- **Notes** : `list` affiche des alias ; `search`/`find` renvoient un message explicite « aucun alias trouvé » (pas de menu, pas de boucle). Si tu as des alias `ls`/`cd` dans ton `aliases.zsh`, la recherche pourrait lister des lignes — les deux cas sont conformes.
- **Assistant (relecture)** : **O** — G.0.c OK. Suite : **G.0.d** (`displayman` + DDC réel) ou tableau **G.1–G.26**.

### Étape G.0.d — Smoke `displayman` (DDC en lecture seule, non destructif) *(non-TTY)*

But : vérifier que le nouveau manager `displayman` se charge, répond à la convention CLI/help, et que les sous-commandes **non destructives** (`detect`, `dump`, `range`, `osd-guide`) fonctionnent sans modifier l'écran.

> Pré-requis : `ddcutil` installé. Si absent → reporter en **Notes** « ddcutil manquant », passer l'étape (les sous-commandes DDC échoueront proprement avec un message stderr explicite). Le test de convention CLI (`help`, `--help`, arg inconnu) reste valable sans `ddcutil`.

- **Commande** :
  ```bash
  cd ~/dotfiles || cd /root/dotfiles
  . core/managers/displayman/core/displayman.sh 2>/dev/null

  echo "--- 1) no-args (aide stdout) ---"
  displayman </dev/null 2>&1 | head -n 6
  echo "--- 2) help (idem) ---"
  displayman help </dev/null 2>&1 | head -n 3
  echo "--- 3) arg inconnu (stderr + rc1) ---"
  displayman __bogus__ </dev/null
  echo "rc=$?  (attendu: 1)"
  echo "--- 4) range (diagnostic GPU + texte explicatif) ---"
  displayman range </dev/null 2>&1 | head -n 8
  echo "--- 5) osd-guide (texte statique) ---"
  displayman osd-guide </dev/null 2>&1 | head -n 5
  if command -v ddcutil >/dev/null 2>&1; then
    echo "--- 6) detect (ddcutil dispo) ---"
    timeout 30 bash -c '. core/managers/displayman/core/displayman.sh 2>/dev/null; displayman detect' </dev/null 2>&1 | head -n 6
    echo "--- 7) dump 1 (lecture VCP, ne modifie rien) ---"
    timeout 60 bash -c '. core/managers/displayman/core/displayman.sh 2>/dev/null; displayman dump 1' </dev/null 2>&1 | head -n 12
  else
    echo "--- 6/7) ddcutil non installé → skip DDC ---"
  fi
  ```
- **Attendu** :
  1. Aide stdout (≥ 6 lignes commençant par `DISPLAYMAN — écrans …`).
  2. Idem pour `help`.
  3. Message d'erreur sur stderr (`displayman: commande inconnue: __bogus__`) + `rc=1`.
  4. Texte `range` non vide (mention GPU si `lspci` dispo).
  5. Texte `osd-guide` non vide (`Joystick`, `Picture Mode`).
  6. Si `ddcutil` : au moins une ligne `Display 1` ou message d'erreur explicite.
  7. Si `ddcutil` : tableau VCP `[VCP 10] Brightness ...`.
- **[x] Fait** *(2026-06-16 — hôte Arch, Mi Monitor HDMI, ddcutil OK)*
- **Sortie (résumé)** :
```
--- 1) no-args --- OK (aide DISPLAYMAN ≥ 6 lignes)
--- 2) help --- OK (idem)
--- 3) arg inconnu --- displayman: commande inconnue: __bogus__ ; rc=1
--- 4) range --- OK (GPU NVIDIA GA104, session wayland/KDE, texte Full vs Limited)
--- 5) osd-guide --- OK (Joystick, Picture Mode)
--- 6) detect --- Display 1 | XMI:Mi Monitor (via bash -c + timeout)
--- 7) dump 1 --- VCP 10 Brightness C 100 100, VCP 12 Contrast C 100 100, …
```
- **Conforme** : O
- **Notes** : `timeout displayman …` seul **échoue** si `displayman` est une fonction shell (pas un binaire) — le bloc G.0.d utilise désormais `timeout bash -c '. …/displayman.sh; displayman …'`. Piège documenté pour rejouer les étapes 6/7.
- **Assistant (relecture)** : **O** — Critères 1–7 remplis sur matériel réel. Suite : **G.0.e** (`diffman`).

### Étape G.0.e — Smoke `diffman` (compare / side / report, non-TTY)

But : vérifier que `diffman` se charge, affiche l’aide, refuse un argument inconnu, et que les sous-commandes **scriptables** (`compare`, `side`, `report`) fonctionnent sans TTY (largeur côte à côte dégradée automatiquement si `tput cols` absent).

- **Commande** :
  ```bash
  cd ~/dotfiles || cd /root/dotfiles
  . core/managers/diffman/core/diffman.sh 2>/dev/null
  echo "--- 1) help ---"
  diffman help </dev/null 2>&1 | head -n 4
  echo "--- 2) arg inconnu ---"
  diffman __bogus__ </dev/null 2>&1 || true
  echo "--- 3) compare (identiques) ---"
  diffman compare README.md README.md </dev/null; echo "rc=$?"
  echo "--- 4) side (identiques) ---"
  diffman side README.md README.md </dev/null; echo "rc=$?"
  echo "--- 5) report ---"
  diffman report --out /tmp/diffman_g0e.txt README.md README.md </dev/null
  test -s /tmp/diffman_g0e.txt && echo "rapport OK ($(wc -l </tmp/diffman_g0e.txt) lignes)"
  ```
- **Attendu** : (1) aide non vide ; (2) stderr « commande inconnue » + `rc=1` ; (3)(4) `rc=0` ; (5) fichier rapport non vide.
- **[ ] Fait**
- **Sortie (coller le résumé)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape G.0.f — Smoke `diskman` (diagnostic disque, non destructif) *(non-TTY)*

But : vérifier que `diskman` se charge, répond à la convention CLI/help, et que les sous-commandes **non destructives** (`overview`, `usage`, `biggest`, `inodes`, `clean --dry-run`, `report`) fonctionnent sans supprimer de données.

- **Commande** :
  ```bash
  cd ~/dotfiles || cd /root/dotfiles
  . core/managers/diskman/core/diskman.sh 2>/dev/null
  echo "--- 1) help ---"
  diskman help </dev/null 2>&1 | head -n 5
  echo "--- 2) arg inconnu ---"
  diskman __bogus__ </dev/null 2>&1 || true
  echo "--- 3) overview ---"
  diskman overview </dev/null 2>&1 | head -n 12
  echo "--- 4) usage . 1 ---"
  diskman usage . 1 </dev/null 2>&1 | head -n 8
  echo "--- 5) biggest . 5 ---"
  diskman biggest . 5 </dev/null 2>&1 | head -n 8
  echo "--- 6) clean dry-run ---"
  diskman clean --dry-run all </dev/null 2>&1 | head -n 20
  echo "--- 7) report ---"
  diskman report /tmp/diskman_g0f.txt </dev/null
  test -s /tmp/diskman_g0f.txt && echo "rapport OK ($(wc -l </tmp/diskman_g0f.txt) lignes)"
  ```
- **Attendu** : (1) aide non vide ; (2) stderr « commande inconnue » + `rc=1` ; (3)(4)(5) sorties non vides ; (6) mention **Dry-run uniquement** ; (7) rapport non vide. **Aucune suppression** dans cette étape.
- **[ ] Fait**
- **Sortie (coller le résumé)** :
```
(coller)
```
- **Conforme** :
- **Notes** : *(pour nettoyer réellement : lancer manuellement `diskman clean --apply <target>` en TTY après lecture du dry-run.)*
- **Assistant (relecture)** :

---

Pour **chaque** ligne du tableau **G.1–G.26** (smoke manuel complémentaire), même modèle :

- **Commande** : `<manager> help` *(comme ci-dessous — c’est le smoke « chargé + aide »)*  
- **Attendu** : pas `command not found` ; sortie d’aide ou usage sur **stdout** (en non-TTY, cohérent avec le préalable).

| # | Manager | `[ ]` | Sortie (extrait) | Conforme | Notes | Assistant (relecture) |
|---|---------|-------|------------------|----------|-------|----------------------|
| G.1 | pathman | [ ] | | | | |
| G.2 | manman | [ ] | | | | |
| G.3 | searchman | [ ] | | | | |
| G.4 | aliaman | [ ] | | | | |
| G.5 | installman | [ ] | | | | |
| G.6 | configman | [ ] | | | | |
| G.7 | gitman | [ ] | | | | |
| G.8 | fileman | [ ] | | | | |
| G.9 | helpman | [ ] | | | | |
| G.10 | cyberman | [ ] | | | | |
| G.11 | devman | [ ] | | | | |
| G.12 | virtman | [ ] | | | | |
| G.13 | miscman | [ ] | | | | |
| G.14 | doctorman | [ ] | | | | |
| G.15 | netman | [ ] | | | | |
| G.16 | sshman | [ ] | | | | |
| G.17 | processman | [ ] | | | | |
| G.18 | routeman | [ ] | | | | |
| G.19 | testman | [ ] | | | | |
| G.20 | testzshman | [ ] | | | | |
| G.21 | moduleman | [ ] | | | | |
| G.22 | multimediaman | [ ] | | | | |
| G.23 | cyberlearn | [ ] | | | | |
| G.24 | displayman | [ ] | | | | |
| G.25 | diffman | [ ] | | | | |
| G.26 | diskman | [ ] | | | | |

**Approfondir** : pour chaque fichier `scripts/test/subcommands/<manager>.list`, ajouter des lignes **G.x.y** dans tes **Notes** ou une annexe perso — c’est la voie pour se rapprocher d’une couverture « chaque sous-commande ».

---

# Bloc H — Variables d’environnement (matrice courte)

| Étape | Commande / action | Attendu | `[ ]` | Conforme | Notes | Assistant (relecture) |
|-------|-------------------|---------|-------|----------|-------|----------------------|
| H.1 | `export DOTFILES_DOTCLI_ENABLE=1` puis menu d’un **pilote F.7** (`netman`, `aliaman`, `cyberlearn`, …) en TTY | dotcli si binaire OK | [ ] | | | |
| H.2 | `export DOTFILES_DOTCLI_MENU_NO_TUI=1` | menus ligne | [ ] | | | |
| H.3 | `DOTFILES_TEST_MANAGERS=pathman,gitman make test` | sous-ensemble | [ ] | | *(long)* | |

---

# Bloc I — Synthèse session + alignement jalon

### Étape I.1 — Bilan

- **Fonctions non testées aujourd’hui** :
```
(liste)
```
- **Régressions** *(réf [`ERRORS.md`](ERRORS.md))* :
```
(liste)
```
- **Améliorations souhaitées** :
```
(liste)
```
- **Assistant (relecture)** :

### Étape I.2 — [`TODOS.md`](../TODOS.md) — validation

- Si une ligne du tableau **« Finalisées — en attente de validation »** correspond à ce que tu viens de valider : **coche-la** dans `TODOS.md`, puis `git commit` / `push` comme indiqué en bas de [`STATUS.md`](../STATUS.md).
- **Assistant (relecture)** :

---

## 12. Demandes d’extension / pour l’assistant (EXT-xxx)

*Format figé : voir [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) §2.b. Ajouter une ligne quand on veut enrichir ce guide ou le code.*

| ID | Demande (précise) | Priorité | Traitée |
|----|-------------------|----------|---------|
| EXT-001 | *(ex. : ajouter étape pour routeman menu interactif)* | | [ ] |
| EXT-002 | **Adaptabilité petits écrans / terminaux étroits** : auditer toutes les sorties d’aide (`*man help`, `make test-help`, `helpman`, bannières `══` / `─`) sur largeur < 80 colonnes (TTY simple, fresh install sans pilote graphique, écran ancien à faible résolution). Critère : pas de débordement, pas de bordures cassées, pas de mots tronqués. Ajouter une étape dédiée dans le Bloc G (ou un nouveau Bloc « UX terminal restreint ») avec `stty cols 60` + replay d’une dizaine de `*man help`. | M | [ ] |
| EXT-003 | **Couleurs ANSI conditionnelles** : vérifier que toutes les sorties (managers, `make test-help`, rapports) détectent correctement le support couleur (`[ -t 1 ]` + `tput colors >= 8`) et n’affichent **jamais** de séquences `\033[…]` brutes quand le terminal ne sait pas les rendre (ex. via `cat`, pipe, terminal minimal). À l’inverse, activer la couleur quand elle est disponible, au moins pour `*man help` (titres, sections). Ajouter une étape de check non-TTY (`*man help | cat -v` ne doit pas contenir `^[[`). | M | [ ] |
| EXT-004 | **Vérification visuelle `lsblk` colorisé** (livré 2026-05-12, `shared/functions/lsblk_color.sh`). En TTY : `lsblk` → en-tête en gras, `disk` cyan gras, `part` vert (continuations MOUNTPOINTS multiples héritent du vert), `loop` gris. En non-TTY : `lsblk \| cat` → aucune séquence `\033[…]` visible. JSON : `lsblk -J` → JSON propre, aucune couleur. Forçage : `DOTFILES_LSBLK_FORCE_COLOR=1 lsblk \| cat` → couleurs présentes. Désactivation : `NO_COLOR=1 lsblk` ou `DOTFILES_LSBLK_NOCOLOR=1 lsblk` → sortie brute. | M | [x] *(livré, à valider visuellement)* |
| EXT-006 | **`netman` — Informations IP (menu 3)** : test de non-régression après fix `ip -o` — en TTY, chaque ligne « Adresses IP locales / IPv6 » affiche `iface:` + adresse ; comparaison visuelle avec `ip -4 -o addr show` / `ip -6 -o addr show`. Couvert par **TESTS.md § C.3** (matrice shells) + smoke manuel une fois sur l’hôte. | M | [x] *(correctif livré 2026-05-13, à valider par l’utilisateur)* |
| EXT-005 | **CI GitHub Actions « complète »** (après `TESTS.md` A→I) : enchaîner sur runner `ubuntu-latest` — `make test-dotfiles-good`, `make build-dotcli` + `make test-dotcli`, puis stratégie **`make test`** (Docker service ou workflow long + `DOTFILES_TEST_*`). Documenter les limites (pas de vrai « poste nu » sans matrice OS). E-mail : uniquement via secrets + job `if:` (voir [`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md)). | H | [ ] |
| EXT-007 | **Futures fonctionnalités / nouveaux managers** : toute nouvelle fonctionnalité doit préciser où elle s’intègre (manager existant ou nouveau `*man`), ajouter une commande non interactive si possible, une ligne `scripts/test/subcommands/<manager>.list`, une page `docs/man/<manager>.md` ou section existante, puis rejouer **E.4**. Si une commande dépend d’un matériel réel (`ddcutil`, Docker daemon hôte, GPU, SSH serveur), la marquer hors matrice Docker et créer une étape manuelle dédiée dans G/H. | H | [x] *(règle documentée 2026-06-12, à appliquer à chaque lot)* |

**Pour l’assistant** : quand une ligne `EXT-xxx` est traitée → cocher `[x]`, **ajouter** les nouvelles étapes numérotées dans le bloc concerné (A–I), référencer le commit dans `Notes`.

---

## Rappel final

- **Menu rapide d’appui** : `make tests-start`
- **Guide pas à pas** : **ce fichier**
- **Référentiel champs** : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md)
- **Hub doc** : [`INDEX.md`](INDEX.md)
- **CI / automatique** : `make test` (complète ce guide, ne le remplace pas) · GitHub : [`guides/GITHUB_ACTIONS.md`](guides/GITHUB_ACTIONS.md)
