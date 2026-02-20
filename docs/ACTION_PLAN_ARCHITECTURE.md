# Plan d’action – Architecture modulaire dotfiles

Document de référence pour unifier TUI, modules, shared, et multi-shell (zsh, bash, fish, sh). Objectif : une base unique, réutilisable, adaptée au terminal.

---

## 1. État actuel (résumé)

| Domaine | Actuel | Cible |
|--------|--------|--------|
| **TUI** | Seul installman utilise `scripts/lib/tui_core.sh` | Tous les *man avec menus (pathman, configman, fileman, etc.) utilisent tui_core + pattern paginé |
| **Logs** | installman → installman_log.sh ; configman → managers_log.sh | Tous les *man qui font des actions loggent via managers_log.sh |
| **Modules** | Chaque *man a son propre `modules/` ; chargement ad hoc | Convention unique : core + modules/ ; chargement via liste déclarative (comme installman TOOLS) |
| **Core / adapters** | Zsh core par manager ; core POSIX souvent non utilisé ; adapters shells/ incohérents | Une base par manager : soit core Zsh (comme installman) + entry script, soit core POSIX ; adapters appellent toujours la même base |
| **Shared** | shared/config.sh, env.sh, aliases.sh ; pas de shared/functions utilisées partout | Enrichir shared (helpers TUI, log, détection shell) ; shared/functions pour code vraiment commun |
| **Complétion** | zsh-completions (plugin) ; pas de complétion make dans dotfiles | Complétion make (cibles Makefile) dans dotfiles + chargée à l’init (fait : zsh/completions/_make) |
| **Init / install** | bootstrap.sh ; make install ; setup.sh | Completions et fpath pris en compte dès que zshrc_custom est chargé (déjà le cas après install) |

---

## 2. Plan d’action détaillé

### Phase A – Complétion et init (prioritaire)

- [x] **A1** Complétion Makefile (zsh)  
  - Fichier `zsh/completions/_make` qui complète les cibles via `make -qp`.  
  - `zshrc_custom` : ajout de `$DOTFILES_DIR/zsh/completions` au `fpath` avant `compinit` ; zstyle pour make (tag-order, call-command).  
- [ ] **A2** Vérifier après install  
  - Après `make install` / bootstrap : symlinks OK, `source ~/.zshrc` ou nouveau shell → complétion make disponible dans un projet avec Makefile.  
- [ ] **A3** (Optionnel) Complétion make pour bash  
  - Fichier ou bloc dans shared ou bash pour compléter les cibles make (bash-completion).

---

### Phase B – TUI commune pour tous les *man

- [ ] **B1** Documenter le pattern menu paginé  
  - Déjà en commentaire dans `scripts/lib/tui_core.sh`. Option : court README `scripts/lib/README_TUI.md` avec exemple (liste d’items + n/p/0).  
- [ ] **B2** Utiliser tui_core dans pathman  
  - Source `tui_core.sh` dans pathman (zsh core) ; menu avec `tui_menu_height` ; pagination si beaucoup d’entrées (ex. liste PATH).  
- [ ] **B3** Utiliser tui_core dans configman  
  - Idem : tui_core + pagination pour la liste des modules.  
- [ ] **B4** Étendre aux autres *man avec menu  
  - fileman, virtman, devman, gitman, helpman, miscman, etc. : même pattern (source tui_core, per_page = tui_menu_height(N), boucle n/p + choix).  
- [ ] **B5** TUI côté POSIX (core/*.sh)  
  - Les core en sh qui ont un menu : appeler tui_core.sh (déjà en sh) pour lignes/colonnes et pagination si besoin.

---

### Phase C – Logging unifié

- [x] **C1** managers_log.sh utilisé par configman (déjà fait).  
- [ ] **C2** Chaque *man qui exécute une action appelle `log_manager_action` (après action réussie/échouée).  
- [ ] **C3** Option “logs” dans les menus des *man (comme installman) : afficher les derniers `managers.log` ou un filtre par manager.

---

### Phase D – Modules et base unique par manager

- [ ] **D1** Convention “core + modules”  
  - Un seul core par manager (zsh ou sh) ; les modules sont des scripts/fichiers appelés par le core (liste déclarative ou scan de `modules/`).  
- [ ] **D2** Adapters shells (zsh, bash, fish)  
  - Chaque adapter charge ou invoque uniquement ce core (comme installman_entry.sh pour bash/fish). Pas de duplication de logique.  
- [ ] **D3** Dépouiller les core POSIX inutilisés  
  - Si un manager est en pratique toujours utilisé via le core Zsh, documenter ou supprimer le core sh inutilisé pour éviter la confusion.  
- [ ] **D4** Liste des managers et rôles  
  - Tableau (dans ce doc ou STATUS.md) : manager, core canonique (zsh ou sh), entry si présent, utilise TUI, utilise managers_log.

---

### Phase E – Shared

- [ ] **E1** shared/functions  
  - Créer si besoin ; y mettre des helpers vraiment communs (ex. wrapper pour tui_menu_height depuis sh).  
- [ ] **E2** shared/config.sh  
  - S’assurer que DOTFILES_DIR, et si utile SCRIPTS_DIR, sont exportés ; optionnel : détection du shell (SH_TYPE=zsh|bash|fish|sh).  
- [ ] **E3** Alias / env  
  - Garder shared/aliases.sh et shared/env.sh comme base ; éviter de dupliquer dans zsh/ et bash/ ce qui peut rester dans shared.

---

### Phase F – Multi-shell (zsh, bash, fish, sh)

- [ ] **F1** Bash  
  - Adapters bash qui appellent le même core (entry script ou source) ; complétion make si ajoutée ; chargement depuis ~/.bashrc ou config bash des dotfiles.  
- [ ] **F2** Fish  
  - Adapters fish idem ; pas de TUI sh dans fish (soit wrapper qui lance zsh/sh pour le menu).  
- [ ] **F3** Scripts de vérification  
  - `scripts/test/verify_multishell.sh` étendu si besoin (installman déjà ; optionnel : configman, pathman).  
- [ ] **F4** Doc  
  - MULTISHELL_REPORT.md à jour avec conventions et liste des entry/adapters.

---

### Phase G – Documentation et maintenance

- [ ] **G1** README `zsh/completions/` (ou dans docs)  
  - Décrire les complétions dotfiles (make), comment en ajouter, et que l’init les charge via fpath.  
- [ ] **G2** STATUS.md  
  - Section “Architecture modulaire” avec lien vers ce plan et résumé des phases faites/en cours.  
- [ ] **G3** Mise à jour régulière  
  - À chaque grosse évolution (TUI partout, logging partout, refonte shared), mettre à jour ce plan et cocher les tâches.

---

## 3. Ordre de priorité suggéré

1. **A** (complétion make + init) – immédiat.  
2. **B** (TUI pour tous les *man) – par manager, en commençant par pathman et configman.  
3. **C** (logging) – en parallèle de B.  
4. **D** (modules / base unique) – après B/C pour ne pas tout casser.  
5. **E** (shared) – léger, peut être fait tôt.  
6. **F** (multi-shell) – renforcement des adapters et tests.  
7. **G** (doc) – en continu.

---

## 4. Tests : Docker vs VM

- **Docker** (`make docker-in`, `scripts/test/docker/`) : pratique pour tester les dotfiles sans toucher à l’hôte, démarrage rapide, même base (ex. Arch) que tu choisis dans le Dockerfile. Idéal pour vérifier pathman, dfm, installman, multi-shell. Les dotfiles sont montés en lecture seule, donc pas besoin de rebuild pour les changements de code.
- **VM** (`scripts/vm/`, QEMU/KVM) : plus proche d’une vraie machine (graphique, noyau, services). Utile pour tester l’install complète (bootstrap, symlinks) ou des distros différentes. Plus lourd à lancer.
- **Conclusion** : Docker suffit pour la plupart des tests (menus, managers, shells). Utiliser la VM si tu veux valider le bootstrap sur une machine “propre” ou une autre distro. Les deux sont documentés dans STATUS.md et scripts/test / scripts/vm.
- **Multi-shell** : `scripts/test/verify_multishell.sh` et tests Docker utilisent la même logique (entry script + adapters) ; pas besoin de tout refaire en VM pour ça.

## 5. Tests Docker (entrée simple)

Pour tester les dotfiles sans impacter le PC :

- **`make docker-in`** : entre dans un conteneur avec les dotfiles montés (image construite si besoin). Shell par défaut : zsh.
- **`make docker-in SHELL=bash`** (ou `fish`, `sh`) : même chose avec un autre shell.
- **`make docker-rebuild`** : reconstruit l’image (sans cache).
- Voir `scripts/test/README.md` pour les tests automatisés.

## 6. Menu générique (dotfiles-menu)

- **`bin/dotfiles-menu`** : script Bash, lit des lignes `label|command` (fichier ou stdin), affiche un menu **fzf**, imprime la commande sélectionnée. Fallback sans fzf (menu numéroté).
- **`scripts/lib/dotfiles_menu.sh`** : définit `dotfiles_menu_run` pour exécuter le choix dans le shell courant (eval).
- **`share/menus/*.menu`** : fichiers menu (ex. `pathman.menu`). En zsh : `dfmenu pathman` ou `dotfiles_menu_run pathman`.
- **Make** : `make dfmenu MENU=pathman` (lance zsh + dotfiles_menu_run).

## 7. Fichiers clés (référence)

| Fichier | Rôle |
|---------|------|
| `scripts/lib/tui_core.sh` | TUI commune (lignes, colonnes, pagination). |
| `scripts/lib/managers_log.sh` | Log unifié des *man. |
| `scripts/lib/installman_log.sh` | Log spécifique installman. |
| `zsh/completions/_make` | Complétion des cibles make. |
| `zsh/zshrc_custom` | fpath completions, compinit, zstyle make. |
| `shared/config.sh` | DOTFILES_DIR, chargement env/aliases. |
| `core/managers/installman/installman_entry.sh` | Entrée unique installman (bash/fish). |
| `docs/MULTISHELL_REPORT.md` | Rapport multi-shell. |
| `docs/STATUS.md` | Historique et état. |
| `bin/dotfiles-menu` | Menu fzf générique (label\|command). |
| `share/menus/*.menu` | Fichiers menu (pathman, etc.). |

---

*Dernière mise à jour : Février 2025*
