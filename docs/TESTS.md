# Tests manuels — procédure à suivre à la lettre

> **Index** : [`STRUCTURE.md`](STRUCTURE.md) · **Statut** : [`../STATUS.md`](../STATUS.md) · **Tâches** : [`../TODOS.md`](../TODOS.md) · **Bac à sable** : [`../scripts/test/SANDBOX.md`](../scripts/test/SANDBOX.md)

## Comment utiliser ce fichier (obligatoire)

1. **Tu ouvres uniquement ce fichier** et tu descends **dans l’ordre** (A, puis B, puis C…).
2. Pour chaque **étape numérotée** : exécute la commande indiquée, **coche** `[ ]` quand c’est fait, **colle** la sortie utile dans l’encadré, indique **Conforme O/N/NA**. Remplis **`Assistant (relecture)`** toi-même après discussion avec un relecteur / l’IA, ou laisse vide jusqu’à validation.
3. **Menu d’aide** (sur ton ordinateur) : `make tests-start` — il propose les mêmes blocs (prérequis, `docker-build`, `docker-in`, `test-dotcli`, etc.). **Il ne remplace pas** ce document : les cases à cocher et les résultats sont **ici**.
4. **Validation « comme un humain »** : tu juges O/N. Si tu utilises l’assistant IA, colle la sortie dans le chat et demande « conforme à l’attendu de l’étape X.Y ? » — mets la réponse dans **Notes**.
5. **Limite honnête** : couvrir **chaque ligne de code / chaque variable** du dépôt dans ce seul fichier est **impossible**. Ce guide couvre le **parcours 0 → bac à sable → smoke → dotcli → managers**. Le détail automatique des sous-commandes est dans `scripts/test/subcommands/*.list` et la CI (`make test`). Pour aller plus loin, utilise **§ 12 — Demandes d’extension** en bas.

---

## Légende des champs (chaque étape)

| Champ | Tu remplis |
|--------|------------|
| **Étape** | Identifiant fixe (ex. `A.2`) — ne pas renommer (pour les échanges avec l’assistant). |
| **Commande** | À copier-coller tel quel (adapter `~/dotfiles` si ton clone est ailleurs). |
| **Attendu** | Comportement ou extrait **minimal** à vérifier. |
| **`[ ] Fait`** | Coche quand la commande est exécutée. |
| **Sortie (coller)** | Fragment réel (pas tout le roman si c’est énorme). |
| **Conforme** | `O` = oui · `N` = non · `NA` = non applicable. |
| **Notes** | Écart, bug, ou action pour [`../TODOS.md`](../TODOS.md) / [`ERRORS.md`](ERRORS.md). |
| **Assistant (relecture)** | Réservé à la **validation externe** (humain ou IA) : verdict court, précisions, « à refaire sur l’hôte », etc. Tu peux y **copier-coller** la réponse du chat. |

---

## Correspondance avec `TODOS.md` (lecture transversale)

| Zone `TODOS.md` | Sections ici |
|-----------------|--------------|
| Phase A — prérequis / `make test` / docker-in | **A**, **B**, **C**, **D**, **E** |
| P1 architecture / managers | **G**, **H** |
| P3 dotcli / TUI | **F** |
| Jalon B — validation perso | **I** + cases « Conforme » cumulées |
| Phase C (bascule racine) | Hors scope de ce guide ; ne pas confondre avec les tests ci-dessous |

Tu **ne dois pas** ouvrir `TODOS.md` pour exécuter les commandes ; tu l’ouvres pour **recopier** une tâche en **Notes** si un écart doit devenir une action formalisée.

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
- **[ ] Fait**
- **Sortie (dernières lignes)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

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
- **[ ] Fait**
- **Sortie** : note ce que **tu as choisi** :
```
Distro choisie : 
Shell choisi   : 
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape C.2 — Sans menu (reproductibilité)

- **Commande (exemple Debian + bash)** : `make docker-in DOCKER_DISTRO=debian DOCKER_SHELL=bash`
- **Attendu** : shell bash dans conteneur basé Debian ; pas d’échec Docker immédiat.
- **[ ] Fait** *(NA si tu ne fais que l’interactif)*
- **Sortie** :
```
(coller ou NA)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

*Référence variables* : [`../TODOS.md`](../TODOS.md) (section Docker) et `scripts/test/docker/docker_in.sh`.

---

# Bloc D — Dans le conteneur : chargement des dotfiles

**Tu es maintenant DANS le conteneur** (invite différente, `pwd` souvent `/root`).

### Étape D.1 — Vérifier le montage

- **Commande** : `echo "$DOTFILES_DIR" && ls -la "$DOTFILES_DIR/Makefile" 2>&1 | head -5`
- **Attendu** : `DOTFILES_DIR` = `/root/dotfiles` (sauf si tu as changé `DOCKER_DOTFILES_DIR`) ; `Makefile` lisible.
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape D.2 — Charger la config shell (selon le shell choisi en C.1)

Choisis **une** ligne correspondant à ton shell :

| Shell | Commande |
|-------|----------|
| **zsh** | `source /root/dotfiles/zsh/zshrc_custom` *(si les managers ne sont pas déjà là)* |
| **bash** | normalement déjà chargé via `docker_in` ; sinon `source /root/dotfiles/bash/bashrc_custom` |
| **fish** | normalement déjà chargé ; sinon `source /root/dotfiles/fish/config_custom.fish` |

- **Commande** : *(copie la ligne de ton shell)*  
- **Attendu** : pas d’erreur **fatale** ; tu peux taper `pathman help` ensuite sans « command not found ».
- **[ ] Fait**
- **Sortie** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape D.3 — Smoke manager minimal

- **Commande** : `pathman help`
- **Attendu** : aide ou usage ; pas `command not found`.
- **[ ] Fait**
- **Sortie (extrait)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape D.4 — Quitter le conteneur

- **Commande** : `exit` (ou Ctrl+D)
- **Attendu** : retour sur le shell **hôte**.
- **[ ] Fait**
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

---

# Bloc E — Cibles Make utiles (hôte, après retour du conteneur)

### Étape E.1 — Aide tests

- **Commande** : `make test-help`
- **Attendu** : texte d’aide sur les variables (`DOTFILES_TEST_MANAGERS`, etc.).
- **[ ] Fait**
- **Sortie (extrait)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape E.2 — Smoke dotfiles-good

- **Commande** : `make test-dotfiles-good`
- **Attendu** : succès **ou** échec documenté dans **Notes** + [`ERRORS.md`](ERRORS.md).
- **[ ] Fait**
- **Sortie (extrait)** :
```
(coller)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

### Étape E.3 — Tests Docker complets *(long)*

- **Commande** : `make test` *(ou via `make tests-start` option 8 avec confirmation)*
- **Attendu** : fin avec résumé OK **ou** liste d’échecs ; rapports sous `TEST_RESULTS_DIR` (souvent sous le home ou `/tmp` selon environnement — voir log).
- **[ ] Fait** *(NA si tu ne lances pas la suite complète aujourd’hui)*
- **Sortie (résumé final)** :
```
(coller ou NA)
```
- **Conforme** :
- **Notes** :
- **Assistant (relecture)** :

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

Pour **chaque** manager, même modèle :

- **Commande** : `<manager> help` *(ou ce que la matrice utilise — ici `help`)*  
- **Attendu** : pas `command not found` ; sortie d’aide ou usage.

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

## 12. Demandes d’extension / pour l’assistant

*Ajoute des lignes ici quand tu veux qu’on enrichisse ce guide ou le code.*

| ID | Demande (précise) | Priorité | Traitée |
|----|-------------------|----------|---------|
| EXT-001 | *(ex. : ajouter étape pour routeman menu interactif)* | | [ ] |
| EXT-002 | | | [ ] |

**Pour l’assistant** : quand tu traites une ligne `EXT-xxx`, mets **Traitée** à `[x]`, ajoute les **nouvelles étapes numérotées** dans le bon bloc ci-dessus, et référence le commit.

---

## Rappel final

- **Menu rapide** : `make tests-start`
- **Guide unique à suivre pas à pas** : **ce fichier**
- **CI / automatique** : `make test` (complète ce guide mais ne remplace pas les vérifications TUI / œil humain)
