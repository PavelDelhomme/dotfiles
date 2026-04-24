# TODOS — Roadmap et actions (dotfiles)

Suivi **opérationnel** : cocher au fil de l’eau.  
**Vue d’ensemble** : `STATUS.md` · **Architecture** : `docs/ARCHITECTURE.md` · **Bac à sable** : `DOTFILES_GOOD/README.md`

---

## Phases (d’où tu es → bascule racine)

| Phase | Nom | Contenu |
|-------|-----|--------|
| **A** | Préparatif | Remplir `DOTFILES_GOOD/` (env, scripts, doc), **`make test-dotfiles-good`**, **`make test`**, usage manuel sans brancher `shared/config.sh` tant que tu n’es pas prêt. **Inclut** l’inventaire de la **couverture des tests** (voir § *Phase A — tests*) et les décisions produit mineures documentées. |
| **B** | **Jalon validation** | Tu considères le bac à sable **validé** (tests + ta manip quotidienne). Décision explicite : brancher ou non le bootstrap `DOTFILES_GOOD` dans la chaîne prod (`shared/config.sh` / `.zshrc`). |
| **C** | Bascule racine *(optionnelle, après B)* | **Backup intégral** du dépôt actuel ailleurs, puis fusion du contenu prévu de `DOTFILES_GOOD/` vers la **racine** du projet (remplacer / réorganiser le clone). **Rollback** = restaurer le backup. **Ne pas lancer C** tant que B n’est pas rempli consciencieusement. |

---

## Priorités (ordre recommandé — une piste à la fois)

| Prio | Tâche | Détail |
|------|--------|--------|
| **P1** | Extraits **`shared/env.sh` → `DOTFILES_GOOD/shared/env/`** | Fichiers `NN_*.sh` neutres (pas `add_to_path` / pas d’`echo` de succès bruyant dans le bac à sable). Doc : `DOTFILES_GOOD/shared/env/README.md`. **`make test-dotfiles-good`**. Reste dans prod : `mkdir`, `add_to_path`, `clean_path`, concat `PATH`, `echo` final → migration ultérieure ou fichier dédié **après** validation. |
| **P2** | Scripts **`DOTFILES_GOOD/scripts/`** | Outils (ex. `print_roots.sh`). Smoke : `make test-dotfiles-good`. |
| **P3** | **Jalon phase B** | Cocher la checklist § *Jalon « DOTFILES_GOOD validé »* ci-dessous quand c’est vrai pour toi. |
| **P4** | Hors bac à sable | **installman** vers `core/managers/installman/`, **`read`/`clear` hors TTY**, CI verte. |
| **P5** | **Phase C** (bascule racine) | Uniquement après **P3** + backup documenté + plan écrit (voir § *Phase C — bascule*). |
| **P6** | **Épic installman trans-distro** | Spécification et phasage : **`docs/INSTALLMAN_VISION.md`**. Implémentation **par étapes** (recherche → menus → backends → `.desktop`). Dépend partiellement de la consolidation **installman** dans `core/` (voir roadmap). |

---

## Phase A — tests : que couvre `make test` aujourd’hui ?

**Oui, en gros** : présence des fichiers, **syntaxe** (core / adapters selon scripts), **chargement** du manager dans le shell, **invocation** des lignes listées dans `scripts/test/subcommands/<manager>.list` (souvent `help` ou commandes non interactives), **code de sortie** / absence de hang (timeout).

**Non (ou partiel)** : pour la plupart des managers, **pas** de vérification automatique que la **sortie** ou le **comportement métier** correspond à un **résultat attendu** (golden file, `grep` d’une chaîne obligatoire, test d’intégration par sous-commande). La matrice sous-commandes valide surtout « ça tourne sans planter » dans la limite du timeout, pas « la bonne action a été faite ».

**À faire (toujours phase A / qualité)** — cases :

- [ ] Définir un **niveau 2** de tests : pour N managers pilotes, 1–2 sous-commandes avec **assertion** (stdout / stderr / fichier produit).
- [ ] Documenter dans `scripts/test/SANDBOX.md` ou `make test-help` la **différence** smoke vs assertions métier.
- [ ] (Optionnel) Fichiers **`scripts/test/expected/<manager>/...`** ou snapshots légers — à décider pour ne pas alourdir le dépôt.

## Phase A — produit : **`infosman`** ?

- **`searchman`** : recherche / exploration — voir **`docs/MANAGERS_SEARCH_VS_INFO.md`**.
- Décision à cocher quand actée :
  - [ ] Choisir **extension `searchman info …`** *ou* nouveau manager **`infosman`** (justifier dans `docs/ARCHITECTURE.md`).

---

## Jalon « DOTFILES_GOOD validé » (phase **B**)

Cocher quand **toi** tu es satisfait — pas de pression calendaire imposée.

- [ ] `make test-dotfiles-good` : OK sur ta machine (et idéalement après tes derniers changements).
- [ ] `make test` (Docker) : OK sur la branche concernée.
- [ ] Tu as **sourcé / testé** le bootstrap `DOTFILES_GOOD` en session réelle (shell de dev) sans casse bloquante.
- [ ] Décision notée ici ou dans un commit : **brancher** le bootstrap dans `shared/config.sh` / entrées shell **oui / non / plus tard**.

---

## Phase **C** — Bascule « tout dans la racine du clone » (après validation)

**Objectif** : que l’arborescence **cible** (aujourd’hui expérimentée sous `DOTFILES_GOOD/`) devienne **le** dépôt à la racine (`core/`, `shared/`, `lib/`, etc.), tout en gardant une **copie de secours** du dépôt actuel pour rollback.

- [ ] **Backup** : copie complète du répertoire dotfiles (ex. `rsync -a ~/dotfiles/ /chemin/backup/dotfiles-YYYYMMDD/` ou archive `tar` sur **autre** volume / machine). Vérifier la taille et un `ls` sur le backup.
- [ ] **Plan écrit** : liste des déplacements (fichiers/dossiers à fusionner, symlinks à recréer, `STATUS.md` / `TODOS.md` à mettre à jour).
- [ ] **Exécution** : fusion (gros commit ou série de commits) + `make test` + test manuel login shell.
- [ ] **Rollback** : procédure testée une fois « à froid » (restaurer le backup par-dessus le clone ou recloner + copier).

> Tant que les cases **Jalon B** ne sont pas cochées, la phase C reste **documentation / préparation** uniquement.

---

## Roadmap technique (cases courantes)

- [x] Bac à sable **`DOTFILES_GOOD/`** + `make test-dotfiles-good`.
- [x] Tableau managers **`docs/ARCHITECTURE.md`** (`migrated_managers.list`).
- [x] Extraits env **`DOTFILES_GOOD/shared/env/`** depuis `shared/env.sh` : `05`, `10`, `11`, `12`, `13`, `14` (+ README, bootstrap tolérant).
- [x] Script **`DOTFILES_GOOD/scripts/print_roots.sh`**.
- [ ] **Reste `shared/env.sh` (prod)** : `mkdir`, bloc `add_to_path` / `clean_path`, concat `PATH`, `echo` — à migrer **après** jalon B ou dans des fichiers séparés **explicitement** non chargés en CI si besoin.
- [ ] Déplacer progressivement **installman** → `core/managers/installman/` + wrappers une ligne.
- [ ] Réduire **`read` / `clear`** hors TTY (menus / CI).
- [ ] Garder **`make test`** vert à chaque étape.
- [ ] **Épic installman** (détail : `docs/INSTALLMAN_VISION.md`) : matrice capacités machine → `search` unifié → install piloté (ex. Chrome / AUR) → préférences Flatpak/Snap/AppImage → `.desktop` / menu applications → extension autres familles (dnf, zypper, …).
- [ ] **`git help` / `man`** : sur postes sans `man` — paquet `man-db` (voir `docs/TROUBLESHOOTING_MAN_GIT.md`).

---

## Fichiers doc — rôle rapide

| Fichier | Rôle |
|---------|------|
| `STATUS.md` | Objectif, état des tests, liens. |
| `TODOS.md` | Ce fichier — phases, priorités, jalon B, phase C. |
| `docs/MULTISHELL_REPORT.md` | Multi-shell, `make test`. |
| `docs/ARCHITECTURE.md` | Entrées shell, managers, `DOTFILES_GOOD`. |
| `docs/REFACTOR_HISTORY.md` | Journal historique des refactors. |
| `STRUCTURE_ANALYSIS.md` | Analyse longue / arbre. |
| `docs/INSTALLMAN_VISION.md` | Épic installman trans-distro (cadrage). |
| `docs/TROUBLESHOOTING_MAN_GIT.md` | `git help` quand `man` est absent. |
| `docs/MANAGERS_SEARCH_VS_INFO.md` | `searchman` vs futur `infosman`. |

---

## Suivi `tail -f` (logs)

Pour suivre un test ou un conteneur : **`tail -f test_results/test_output.log`** (ou le fichier indiqué par le script) est **normal** ; tu vois les lignes au fil de l’eau. `Ctrl+C` arrête seulement le `tail`, pas le test déjà terminé.
