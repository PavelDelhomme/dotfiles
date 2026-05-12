# Tests manuels — procédure à suivre à la lettre

> **Index général** : [`INDEX.md`](INDEX.md) · **Carte technique** : [`STRUCTURE.md`](STRUCTURE.md) · **Statut** : [`../STATUS.md`](../STATUS.md) · **Tâches** : [`../TODOS.md`](../TODOS.md) · **Bac à sable** : [`../scripts/test/SANDBOX.md`](../scripts/test/SANDBOX.md)
>
> **Format des étapes** (Commande / Attendu / Conforme `O·N·NA` / Notes / Assistant relecture) : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md). **Ne pas redéfinir** les champs ici — toute nouvelle étape réutilise le bloc de la légende.

## Comment utiliser ce fichier

1. Ouvrir **uniquement** ce fichier et descendre **dans l’ordre** (Bloc A → I).
2. Pour chaque étape : exécuter la commande, **cocher** `[ ]`, **coller** la sortie utile, choisir **Conforme** `O / N / NA` (sémantique exacte : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md) §3). Laisser **`Assistant (relecture)`** vide tant qu’une relecture externe n’a pas été faite.
3. Menu d’appui (sur l’hôte) : **`make tests-start`** — mêmes blocs (prérequis, `docker-build`, `docker-in`, `test-dotcli`, …). Ne remplace pas ce document : les cases sont **ici**.
4. **Limite honnête** : couvrir chaque ligne de code dans un seul fichier est **impossible**. Ce guide couvre le **parcours 0 → bac à sable → smoke → `dotcli` → managers**. Le détail automatique est dans `scripts/test/subcommands/*.list` + CI (`make test`). Pour étendre, voir **§ 12 — EXT-xxx**.
5. **Reprise après évolutions code (managers / aide)** : lire le **journal doc** ci-dessous, exécuter le **préalable Bloc G** (contrôle non-TTY + convention), puis enchaîner le **tableau G.1–G.23** comme d’habitude.

### Journal doc (reprise `TESTS.md`)

| Date | Sujet | Action pour toi |
|------|--------|-----------------|
| **2026-05-11** | Convention **aide / CLI** unifiée sur les `*man` (stdout vs interactif), correction **boucles** sur argument inconnu (`aliaman`, `cyberman`, `pathman`, …), **`helpman`**, **`aliaman`** (recherche / synonymes), **`multimediaman`** et **`cyberlearn`** alignés sur le même contrat. | Refaire **Bloc G — préalable + G.0** (ci-dessous), puis cocher **G.1–G.23**. Les étapes **D.3** (`pathman help`) restent valides : l’aide doit toujours s’afficher sur stdout. |
| **2026-05-12** | **G.0** étendu à **tous** les managers de `migrated_managers.list` (ajout `manman`, `configman`, `doctorman`, `moduleman`). Ajout **G.0.b** (reproducteur du bug historique `aliaman --` → ne doit plus boucler) et **G.0.c** (smoke des nouvelles commandes `aliaman search` / `aliaman list`, avec ou sans `fzf`). Note : `manman` et `doctorman` peuvent encore renvoyer `rc=0` sur argument inconnu — c’est un **WARN** acceptable à reporter en `Notes` (pas un `FAIL`). | Refaire **G.0**, puis cocher **G.0.b** et **G.0.c** avant de retourner sur **G.1–G.23**. |

---

## Correspondance avec `TODOS.md`

| Zone `../TODOS.md` | Sections ici |
|--------------------|--------------|
| Phase A — prérequis / `make test` / docker-in | **A**, **B**, **C**, **D**, **E** |
| P1 architecture / managers | **G** (préalable + **G.0** avant le tableau), **H** |
| P3 dotcli / TUI | **F** |
| Jalon B — validation perso | **I** (+ cases « Conforme » cumulées) |
| Phase C (bascule racine) | **Hors scope** — ne pas mélanger avec les tests ci-dessous |

Ne pas ouvrir [`../TODOS.md`](../TODOS.md) pour exécuter les commandes : on l’ouvre uniquement pour **formaliser** un écart vu en `Notes` (en y ajoutant une ligne).

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

---

# Bloc F — `dotcli` (hôte ou conteneur si binaire présent)

**Préalable** : `make build-dotcli` crée `~/dotfiles/bin/dotcli` (non versionné).

### Étape F.1 — Build + smoke automatique

- **Commande** : `make test-dotcli`
- **Attendu** : compilation OK + lignes de smoke sans erreur.
- **[ ] Fait**
- **Sortie (extrait)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.2 — `doctor`

- **Commande** : `~/dotfiles/bin/dotcli doctor`
- **Attendu** : lignes `stdin_tty`, `stdout_tty`, `term`.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.3 — Menu non-TTY (pipe)

- **Commande** : `printf 'A|a\nB|b\n' | ~/dotfiles/bin/dotcli menu --prompt test`
- **Attendu** : stdout = une ligne `a` (première entrée).
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.4 — `--simulate-index 2`

- **Commande** : `printf 'x|a\ny|b\n' | ~/dotfiles/bin/dotcli menu --simulate-index 2 --prompt t`
- **Attendu** : stdout = `b`.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.5 — `--dry-run`

- **Commande** : `printf 'x|a\n' | ~/dotfiles/bin/dotcli menu --dry-run --prompt t 2>/dev/null ; echo "exit=$?"`
- **Attendu** : stdout `a` ; stderr peut contenir le texte dry-run (redirigé ici vers /dev/null pour simplifier — tu peux retirer `2>/dev/null` pour voir le détail).
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.6 — Menu TUI réel *(TTY uniquement)*

- **Commande** : lancer dans un **vrai terminal** (pas via pipe) :  
  `printf 'Un|1\nDeux|2\n' | …` **ne marche pas** pour le TUI. Utilise plutôt :  
  `(cd ~/dotfiles && printf 'Un|1\nDeux|2\n' | ./bin/dotcli menu --prompt Demo)` **seulement en TTY** ; sinon note **NA**.
- **Attendu** : liste surlignée ; flèches / `j` `k` ; Entrée valide ; terminal pas cassé après `q` ou choix.
- **[ ] Fait**
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape F.7 — Managers avec `dotcli` *(TTY)*

- **Commande** : dans un TTY, avec `export DOTFILES_DOTCLI_ENABLE=1` et binaire présent : ouvrir par ex. `netman` menu — procédure manuelle.
- **Attendu** : menu dotcli ou fallback `ncmenu`/`read` si binaire absent.
- **[ ] Fait** *(NA si pas de TTY)*
- **Notes** :
- **Assistant (relecture)** :

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

### Étape G.0 — Contrôle global non-TTY *(recommandé avant G.1–G.23)*

Depuis la racine des dotfiles (`cd ~/dotfiles` ou `/root/dotfiles` dans le conteneur), **bash** :

```bash
cd ~/dotfiles || cd /root/dotfiles
export DOTFILES_DIR="$PWD"
MANS="gitman miscman cyberman helpman netman installman pathman aliaman routeman \
processman devman virtman searchman testzshman fileman sshman testman \
multimediaman cyberlearn manman configman doctorman moduleman"
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
- **[ ] Fait**
- **Sortie (coller le résumé)** :
```
(coller)
```
- **Conforme** :
- **Notes** : *(les managers hors boucle G.0 sont signalés dans `scripts/test/config/migrated_managers.list` si besoin.)*
- **Assistant (relecture)** :

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
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

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
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** : *(si `fzf` est installé en TTY, la commande **interactive** sera testée plus tard via le menu de `aliaman --help` — ne pas tenter ici.)*
- **Assistant (relecture)** :

---

Pour **chaque** ligne du tableau **G.1–G.23** (smoke manuel complémentaire), même modèle :

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

**Approfondir** : pour chaque fichier `scripts/test/subcommands/<manager>.list`, ajouter des lignes **G.x.y** dans tes **Notes** ou une annexe perso — c’est la voie pour se rapprocher d’une couverture « chaque sous-commande ».

---

# Bloc H — Variables d’environnement (matrice courte)

| Étape | Commande / action | Attendu | `[ ]` | Conforme | Notes | Assistant (relecture) |
|-------|-------------------|---------|-------|----------|-------|----------------------|
| H.1 | `export DOTFILES_DOTCLI_ENABLE=1` puis menu `netman` en TTY | dotcli si binaire OK | [ ] | | | |
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
| EXT-004 | | | [ ] |

**Pour l’assistant** : quand une ligne `EXT-xxx` est traitée → cocher `[x]`, **ajouter** les nouvelles étapes numérotées dans le bloc concerné (A–I), référencer le commit dans `Notes`.

---

## Rappel final

- **Menu rapide d’appui** : `make tests-start`
- **Guide pas à pas** : **ce fichier**
- **Référentiel champs** : [`LEGENDE_CHAMPS.md`](LEGENDE_CHAMPS.md)
- **Hub doc** : [`INDEX.md`](INDEX.md)
- **CI / automatique** : `make test` (complète ce guide, ne le remplace pas)
