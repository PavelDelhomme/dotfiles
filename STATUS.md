# 📊 STATUS - Migration Multi-Shells vers Structure Hybride

## 🎯 Objectif

Migrer **toutes** les fonctionnalités ZSH vers Fish et Bash, avec synchronisation automatique.

**Parité fonctionnelle** : **21** managers dans la liste migrée Docker (`migrated_managers.list`) pour Zsh / Bash / Fish ; le dépôt peut encore mentionner « 19 » ailleurs par historique — **référence** : ce fichier + `docs/ARCHITECTURE.md`.

**Architecture choisie** : **Structure Hybride** avec code commun POSIX dans `core/` et adapters shell-spécifiques dans `shells/{zsh,bash,fish}/adapters/`

### Où lire la doc (tests, multi-shell, migrations)

| Sujet | Emplacement |
|--------|-------------|
| **Tests Docker, `DOTFILES_TEST_MANAGERS`, bac à sable** | `make test-help`, `make sandbox-guide`, `scripts/test/SANDBOX.md` |
| **Multi-shell / installman** | `docs/MULTISHELL_REPORT.md`, `shells/README.md` |
| **Plan TUI / logs / modules** | `docs/ACTION_PLAN_ARCHITECTURE.md` |
| **Entrées shell, wrapper, bac à sable DOTFILES_GOOD** | `docs/ARCHITECTURE.md`, `DOTFILES_GOOD/README.md` |
| **Guides de migration historiques** | `docs/migrations/` |
| **Actions, phases A→B→C, bascule future** | **`TODOS.md`** (racine) |
| **Journal historique des refactors** | `docs/REFACTOR_HISTORY.md` (ex-`docs/STATUS.md`) |
| **Analyse longue de l’arborescence** | `STRUCTURE_ANALYSIS.md` (référence, pas la checklist du jour) |
| **Vision installman trans-distro** | `docs/INSTALLMAN_VISION.md` |
| **`git help` / `man` introuvable** | `docs/TROUBLESHOOTING_MAN_GIT.md` |
| **`searchman` vs `infosman`** | `docs/MANAGERS_SEARCH_VS_INFO.md` |

Ce fichier **STATUS** reste la vue d’ensemble (objectifs + tests) ; le détail des commandes de test est dans **`make test-help`**. Le suivi des tâches est dans **`TODOS.md`**.

### État des tests Docker (`make test`, 2026-04)

- **`make test`** enchaîne **deux phases dans le même conteneur** : (1) matrice **managers × shells** (63 cellules typiques : 21 managers × zsh/bash/fish) ; (2) **matrice sous-commandes** (`scripts/test/manager_subcommand_matrix.sh`, ~57 invocations en tier `full`).
- **Flux terminal** : sortie du conteneur en **direct** + copie dans `test_results/test_output.log` (`tee`).
- **Vérifier la phase 2** : `grep -E 'Matrice sous-commandes|échec:' test_results/test_output.log | tail -20` — attendu : `échecs: 0` et `✅ Matrice sous-commandes : OK`.
- **Bac à sable** : dotfiles montés **lecture seule** dans l’image de test ; écritures ciblées sur `test_results/` et volume config test. Détail : `scripts/test/SANDBOX.md`, `make sandbox-guide`.
- **`multimediaman` / `cyberlearn`** : la phase 2 exécute au minimum **`help`** (non bloquant hors TTY). Les menus sans argument restent interactifs ; **`@skip`** dans d’autres `.list` = encore volontaire pour certains parcours.

---

## Prochaines étapes

**Checklist et priorités (1–4 + roadmap)** : voir **`TODOS.md`** à la racine du dépôt.

---

### Carte des répertoires et rationalisation (roadmap architecture)

**Constat (pourquoi c’est « bruité » aujourd’hui)**  
- **`core/managers/<nom>/core/*.sh`** : cœur POSIX **canonique** pour la logique d’un manager.  
- **`shells/{zsh,bash,fish}/adapters/`** : colle mince pour charger ce cœur — **c’est la cible** pour tout nouveau code.  
- **`zsh/functions/…`**, **`bash/`**, **`fish/`** à la racine : **historique** (installman modules volumineux, anciens chemins, configs générées). On y trouve encore des *man* ou modules **avant** migration complète vers `core/`.  
- **Fichiers dot à la racine** (`.zshrc`, `.bashrc`, `.env.example`, etc.) : **modèle « dépôt = dotfiles »** — prêts à être **symlinkés** vers `$HOME` par bootstrap / install ; cohérents tant que la doc dit « copier ou lier depuis la racine du clone ».

**Cible (sans big-bang immédiat)**  
1. **Une seule vérité par manager** : logique métier dans `core/managers/<nom>/` ; **aucun** doublon de logique dans `zsh/functions/<nom>/` sauf transition documentée.  
2. **Shells = glue uniquement** : `shells/*` + `shared/` ; `zsh/functions` devient **archive / modules lourds** (ex. installman) puis seulement **réexport** ou chemins réécrits vers `core/`.  
3. **Arborescence idéale documentée** : `scripts/`, `docs/`, `core/`, `shared/`, `shells/`, `bin/` (optionnel), `logs/` (runtime, gitignored), éventuellement **`config/`** pour exemples — les dotfiles à la racine restent des **entrées d’installation**, pas du code métier.  
4. **Bootstrap unifié** : un seul chemin documenté (`install_zsh_complete.sh` / Makefile / script unique) qui pose `DOTFILES_DIR`, symlinks, et charge **uniquement** les adapters `shells/`.

**Suivi des tâches** : **`TODOS.md`** (racine).

---

## 📋 État actuel

### ✅ ZSH (Complet)
- 21 managers couverts par la liste migrée Docker (`TODOS.md`, `docs/ARCHITECTURE.md`)
- Structure modulaire complète
- ~35 fichiers de code
- Architecture bien définie

### ✅ Fish et Bash (adapters hybrides — CI verte)
- **Adapters** `shells/{fish,bash}/adapters/*` pour les managers migrés : chargement du **core POSIX** sous `core/managers/*/core/*.sh` (souvent via bash pour Fish).
- **`make test`** : matrice managers **63/63 OK** quand la liste migrée par défaut est utilisée ; phase 2 sous-commandes à surveiller via le log (voir ci-dessus).
- **Travail restant** : poursuivre la **parité UX** (menus, prompts) et le durcissement POSIX là où du code historique Zsh subsiste hors `core/` — pas un blocage pour les tests Docker actuels.

### ⚠️ Bash (même ligne directrice que Fish)
- Même architecture ; différences mineures de chargement dans `bash/bashrc_custom`.

---

## 🏗️ Architecture Hybride (Choix réalisé)

### Structure choisie

```
dotfiles/
├── core/
│   └── managers/
│       ├── pathman/
│       │   └── core/
│       │       └── pathman.sh          # Code POSIX commun
│       ├── manman/
│       │   └── core/
│       │       └── manman.sh           # Code POSIX commun
│       ├── searchman/
│       │   └── core/
│       │       └── searchman.sh        # Wrapper temporaire (charge ZSH)
│       └── aliaman/
│           └── core/
│               └── aliaman.sh          # Wrapper temporaire (charge ZSH)
│
└── shells/
    ├── zsh/
    │   └── adapters/
    │       ├── pathman.zsh             # Adapter ZSH (charge core)
    │       ├── manman.zsh
    │       ├── searchman.zsh
    │       └── aliaman.zsh
    ├── bash/
    │   └── adapters/
    │       ├── pathman.sh              # Adapter Bash (charge core)
    │       └── manman.sh
    └── fish/
        └── adapters/
            ├── pathman.fish            # Adapter Fish (charge core)
            └── manman.fish
```

### Avantages de cette architecture

1. **Code commun POSIX** : Un seul fichier core par manager (évite duplication)
2. **Adapters légers** : Chaque shell charge simplement le core
3. **Maintenance simplifiée** : Modifications dans core/ propagées automatiquement
4. **Migration progressive** : Wrappers temporaires pour managers complexes
5. **Compatibilité maximale** : Code POSIX fonctionne partout

### Choix techniques

- **Core en POSIX sh** : Compatible avec tous les shells
- **Adapters shell-spécifiques** : Gèrent les différences de syntaxe mineures
- **Wrappers temporaires** : Pour managers complexes (searchman, aliaman) qui nécessitent encore ZSH
- **Migration progressive** : Managers simples d'abord, complexes ensuite

---

## 🗺️ Plan de migration complet

### Phase 0 : Structure Hybride ✅ (TERMINÉE)

**Objectif** : Créer la nouvelle architecture hybride avec code commun POSIX.

**Tâches :**
- [x] Créer structure `core/managers/` pour code commun POSIX
- [x] Créer structure `shells/{zsh,bash,fish}/adapters/` pour adapters shell
- [x] Migrer **pathman** comme POC (migration complète POSIX)
  - [x] Core POSIX créé : `core/managers/pathman/core/pathman.sh`
  - [x] Adapters créés : `shells/{zsh,bash,fish}/adapters/pathman.*`
  - [x] Tests passés dans les 3 shells
- [x] Migrer **manman** (migration complète POSIX)
  - [x] Core POSIX créé : `core/managers/manman/core/manman.sh`
  - [x] Adapters créés : `shells/{zsh,bash,fish}/adapters/manman.*`
- [x] Migrer **searchman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/searchman/core/searchman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/searchman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **aliaman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/aliaman/core/aliaman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/aliaman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **installman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/installman/core/installman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/installman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **configman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/configman/core/configman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/configman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **gitman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/gitman/core/gitman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/gitman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **fileman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/fileman/core/fileman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/fileman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Migrer **helpman** (wrapper temporaire)
  - [x] Core wrapper créé : `core/managers/helpman/core/helpman.sh`
  - [x] Adapter ZSH créé : `shells/zsh/adapters/helpman.zsh`
  - [ ] Migration complète POSIX à venir
- [x] Mettre à jour `zshrc_custom` pour charger depuis adapters

**Durée estimée :** 2-3 jours
**Progression :** 100% ✅ TERMINÉE
**État :** ✅ TERMINÉE - Tous les 19 managers ont des wrappers dans core/ et des adapters zsh/bash/fish complets

**Managers migrés :**
- ✅ pathman, manman (core POSIX complet)
- ⚠️ searchman, aliaman, installman, configman, gitman, fileman, helpman, cyberman, devman, virtman, miscman (wrappers temporaires + adapters complets)
- ⚠️ netman, sshman, testman, testzshman, moduleman, multimediaman, cyberlearn (wrappers temporaires + adapters complets)

---

### Phase 1 : Infrastructure de base ✅ (TERMINÉE)

**Objectif** : Créer la structure et les outils nécessaires.

**Tâches :**
- [x] Documentation complète créée
  - [x] `docs/migrations/MIGRATION_COMPLETE_GUIDE.md` - Guide complet
  - [x] `docs/migrations/MIGRATION_PLAN.md` - Plan détaillé
  - [x] `docs/migrations/MIGRATION_MULTI_SHELLS.md` - Explications
  - [x] `docs/migrations/COMPLETE_MIGRATION_LIST.md` - Liste précise
  - [x] `STATUS.md` - Ce fichier (suivi de progression)

- [x] Créer structure de base
  - [x] `bash/functions/` avec structure complète
  - [x] `bash/utils/` créé
  - [x] `fish/config_custom.fish` amélioré avec système de chargement
  - [x] Système de chargement multi-shells

- [x] Créer convertisseur de base
  - [x] Script de conversion ZSH → Fish (`convert_zsh_to_fish.sh`)
  - [x] Script de conversion ZSH → Bash (`convert_zsh_to_bash.sh`)
  - [x] Script de synchronisation amélioré (`sync_managers_multi_shell.sh`)
  - [ ] Adaptation syntaxe complète (à améliorer progressivement)
  - [ ] Gestion des patterns complexes (à améliorer progressivement)

- [x] Créer système de détection et chargement
  - [x] `fish/config_custom.fish` - Chargement managers Fish avec `load_manager`
  - [x] `bash/bashrc_custom` - Chargement managers Bash avec `load_manager`
  - [x] `zshrc` - Détection Bash améliorée
  - [x] Makefile targets (`sync-all-shells`, `sync-manager`, `convert-manager`)

**Durée estimée :** 1-2 jours
**Progression :** ~80% (structure et scripts de base créés, améliorations progressives à venir)

---

### Phase 2 : Migration pilote (`installman`) 🔄 (EN COURS - ~80%)

**Objectif** : Valider l'approche avec un manager complet.

**Structure à migrer :**
```
installman/
├── core/
│   ├── installman.zsh (350 lignes) → installman.fish + installman.sh
│   └── [Logique principale]
├── modules/
│   ├── flutter/install_flutter.sh (→ adapté pour Fish/Bash si nécessaire)
│   ├── docker/install_docker.sh
│   ├── android/install_android_tools.sh
│   ├── android/install_android_studio.sh
│   ├── android/accept_android_licenses.sh
│   ├── dotnet/install_dotnet.sh
│   ├── emacs/install_emacs.sh
│   ├── java/install_java.sh
│   ├── brave/install_brave.sh
│   ├── cursor/install_cursor.sh
│   ├── qemu/install_qemu.sh
│   └── ssh/install_ssh_config.sh
└── utils/
    ├── check_installed.sh (→ adapté pour Fish/Bash)
    ├── logger.sh
    ├── distro_detect.sh
    └── path_utils.sh
```

**Tâches détaillées :**

1. **Analyser installman.zsh**
   - [x] Lister toutes les fonctions
   - [x] Identifier les patterns ZSH spécifiques
   - [x] Documenter la logique métier

2. **Convertir installman.zsh → installman.fish**
   - [x] Adapter les variables locales
   - [x] Convertir les fonctions
   - [x] Adapter les arrays (listes Fish)
   - [x] Convertir les conditionnelles et boucles
   - [x] Adapter les couleurs (Fish utilise `set_color`)
   - [x] Conversion complète effectuée

3. **Convertir installman.zsh → installman.sh**
   - [x] Adapter les variables (local → local)
   - [x] Convertir les patterns ZSH spécifiques (${(@s/:/)} → IFS read)
   - [x] Adapter les arrays (declare -a)
   - [x] Conversion complète effectuée

4. **Adapter les modules**
   - [x] Vérifier si les modules `.sh` fonctionnent directement
   - [x] Modules peuvent être partagés depuis zsh/functions/installman/
   - [x] Compatibles Bash/Fish (utilisés via bash pour Fish)

5. **Adapter les utilitaires**
   - [x] Utilitaires peuvent être partagés (déjà en .sh)
   - [x] Compatibles Bash/Fish

6. **Tester**
   - [x] Matrice Docker `make test` (zsh / bash / fish + phase sous-commandes)
   - [ ] Scénarios manuels lourds (installations réelles, matériel, réseau) — hors CI

**Durée estimée :** 2-3 jours

---

### Phase 3 : Migration complète des autres managers ⏳

**Ordre de migration recommandé :**

#### Priorité 1 (Essentiels)
- [x] **configman** - Configuration système ✅
  - Core : `configman.zsh` → `configman.sh` + `configman.fish` ✅
  - Modules : Git, SSH, Shell, Symlinks, Prompt, QEMU
  - Utils : divers

- [x] **pathman** - Gestion PATH (utilisé par d'autres) ✅
  - Core : `pathman.zsh` → `pathman.sh` + `pathman.fish` ✅
  - Modules : divers

#### Priorité 2 (Utilitaires de base)
- [ ] **netman** - Réseau
  - Core : `netman.zsh`
  - Modules : réseau

- [ ] **gitman** - Git
  - Core : `gitman.zsh`
  - Modules : fonctions Git

- [x] **aliaman** - Alias ⚠️ **MIGRÉ (Wrapper temporaire)**
  - Core wrapper : `core/managers/aliaman/core/aliaman.sh` ✅
  - Adapter ZSH : `shells/zsh/adapters/aliaman.zsh` ✅
  - **Migration complète POSIX à venir**

- [x] **searchman** - Recherche ⚠️ **MIGRÉ (Wrapper temporaire)**
  - Core wrapper : `core/managers/searchman/core/searchman.sh` ✅
  - Adapter ZSH : `shells/zsh/adapters/searchman.zsh` ✅
  - **Migration complète POSIX à venir**

- [ ] **helpman** - Aide
  - Core : `helpman.zsh`
  - Modules : système d'aide

#### Priorité 3 (Fonctionnalités avancées)
- [ ] **fileman** - Fichiers
  - Core : `fileman.zsh`
  - Modules : fichiers, permissions, backup, archive

- [ ] **miscman** - Divers
  - Core : `miscman.zsh`
  - Modules : divers

- [ ] **devman** - Développement
  - Core : `devman.zsh`
  - Modules : projets, langages

- [ ] **virtman** - Virtualisation
  - Core : `virtman.zsh`
  - Modules : Docker, QEMU, Libvirt, LXC, Vagrant

- [ ] **sshman** - SSH
  - Core : `sshman.zsh`
  - Modules : auto-setup SSH

#### Priorité 4 (Spécialisés)
- [ ] **cyberman** - Cybersécurité (complexe)
  - Core : `cyberman.zsh`
  - Modules : sécurité, IoT, scanning, vulnérabilités
  - Utils : nombreux

- [ ] **testman** - Tests
  - Core : `testman.zsh`
  - Modules : tests multi-langages

- [ ] **testzshman** - Tests ZSH
  - Core : `testzshman.zsh`
  - Tests ZSH/dotfiles

#### Priorité 5 (Infrastructure)
- [ ] **moduleman** - Gestion modules
  - Core : `moduleman.zsh`
  - Gestion des modules

- [x] **manman** - Manager of Managers ✅ **MIGRÉ (Structure Hybride)**
  - Core POSIX : `core/managers/manman/core/manman.sh` ✅
  - Adapters : `shells/{zsh,bash,fish}/adapters/manman.*` ✅
  - Migration complète POSIX

**Durée estimée :** 5-7 jours

---

### Phase 4 : Système de synchronisation automatique ✅ (TERMINÉE)

**Objectif** : Automatiser la propagation des mises à jour.

**Composants :**

1. **Script de synchronisation principal**
   - [x] `scripts/tools/sync_managers.sh` ✅
   - [x] Détecte les modifications ZSH ✅
   - [x] Convertit automatiquement ✅
   - [x] Met à jour Fish et Bash ✅
   - [x] Validation automatique ✅

2. **Hook Git pre-commit**
   - [x] `.git/hooks/pre-commit` ✅
   - [x] Détecte les fichiers ZSH modifiés ✅
   - [x] Synchronise automatiquement ✅
   - [x] Validation avant commit ✅

3. **Makefile targets**
   - [x] `make sync-managers` - Synchronise tous les managers ✅
   - [x] `make sync-manager MANAGER=installman` - Synchronise un manager ✅
   - [x] `make test-sync` - Teste la synchronisation ✅

4. **Scripts utilitaires**
   - [x] Détection des changements ✅
   - [x] Logging des synchronisations ✅
   - [x] Tests de synchronisation ✅

**Durée estimée :** 1-2 jours
**Progression :** 100% ✅ TERMINÉE

---

### Phase 5 : Tests et validation ✅ (TERMINÉE)

**Objectif** : Valider que tout fonctionne correctement.

**Tests (référence) :**

1. **Tests fonctionnels par manager**
   - [x] Scripts de test créés ✅
   - [x] Tests syntaxe pour tous les managers ✅
   - [x] Tests de chargement pour tous les managers ✅
   - [ ] Tests fonctionnels complets (à exécuter manuellement)

2. **Tests multi-shells**
   - [x] Script `test_multi_shells.sh` créé ✅
   - [x] Tests ZSH : Tous les managers testés ✅
   - [x] Tests Bash : Tous les managers testés ✅
   - [x] Tests Fish : Tous les managers testés ✅
   - [x] Rapport généré automatiquement ✅

3. **Tests dans Docker**
   - [x] `make docker-test-auto` avec ZSH ✅
   - [x] `make docker-test-auto` avec Fish ✅
   - [x] `make docker-test-auto` avec Bash ✅
   - [x] Tests multi-distributions fonctionnels ✅

4. **Tests de synchronisation**
   - [x] Script `test_sync.sh` créé ✅
   - [x] Hook Git fonctionnel ✅
   - [x] Script de sync fonctionnel ✅
   - [x] Tests de synchronisation automatisés ✅

5. **Tests complets**
   - [x] Script `test_all_complete.sh` créé ✅
   - [x] Combine tous les tests ✅
   - [x] Génère un rapport complet ✅

**Durée estimée :** 2-3 jours
**Progression :** ✅ CI `make test` couvre chargement, smoke et sous-commandes listées ; scénarios manuels « complets » restent hors automatisme.

---

## 📊 Progression globale

### Infrastructure
- [x] Documentation complète (100%)
- [x] Structure de base (80%)
- [x] Convertisseur de base (80%)
- [x] Système de chargement (80%)

### Migration des managers (Structure Hybride)

#### ✅ Migrés complètement (Core POSIX + Adapters)
- [x] **pathman** (100%) ✅
  - Core POSIX : `core/managers/pathman/core/pathman.sh`
  - Adapters : `shells/{zsh,bash,fish}/adapters/pathman.*`
  - Tests passés dans les 3 shells

- [x] **manman** (100%) ✅
  - Core POSIX : `core/managers/manman/core/manman.sh`
  - Adapters : `shells/{zsh,bash,fish}/adapters/manman.*`

#### ⚠️ Migrés partiellement (Wrappers temporaires)
- [x] **searchman** (50%) ⚠️
  - Core wrapper : `core/managers/searchman/core/searchman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/searchman.zsh`
  - **Migration complète POSIX à venir**

- [x] **aliaman** (50%) ⚠️
  - Core wrapper : `core/managers/aliaman/core/aliaman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/aliaman.zsh`
  - **Migration complète POSIX à venir**

- [x] **installman** (50%) ⚠️
  - Core wrapper : `core/managers/installman/core/installman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/installman.zsh`
  - **Migration complète POSIX à venir**

- [x] **configman** (50%) ⚠️
  - Core wrapper : `core/managers/configman/core/configman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/configman.zsh`
  - **Migration complète POSIX à venir**

- [x] **gitman** (50%) ⚠️
  - Core wrapper : `core/managers/gitman/core/gitman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/gitman.zsh`
  - **Migration complète POSIX à venir**

- [x] **fileman** (50%) ⚠️
  - Core wrapper : `core/managers/fileman/core/fileman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/fileman.zsh`
  - **Migration complète POSIX à venir**

- [x] **helpman** (50%) ⚠️
  - Core wrapper : `core/managers/helpman/core/helpman.sh` (charge ZSH original)
  - Adapter ZSH : `shells/zsh/adapters/helpman.zsh`
  - **Migration complète POSIX à venir**

#### Note sur ce bloc (plan historique)

Les anciennes listes **« À migrer » / synchronisation 0 % / tests 0 % »** (supprimées ici) étaient un **plan initial** ; elles ne reflètent plus l’état du dépôt. Faire confiance à : **section « État des Managers » en bas de fichier**, **`make test`**, et **`docs/migrations/`** pour le détail.

---

## 📝 Liste complète des fichiers à migrer

### Managers (19)
1. installman
2. configman
3. pathman
4. netman
5. gitman
6. cyberman
7. devman
8. miscman
9. aliaman
10. searchman
11. helpman
12. fileman
13. virtman
14. sshman
15. testman
16. testzshman
17. moduleman
18. manman
19. multimediaman

### Utilitaires globaux
- `zsh/functions/utils/alias_utils.zsh`
- `zsh/functions/utils/ensure_tool.sh`
- `zsh/functions/utils/fix_ghostscript_alias.sh`

### Fichiers de configuration
- `zsh/zshrc_custom` → adapter pour Fish et Bash
- Système de chargement des managers

---

## 🔧 Outils et scripts (réalisés)

Les scripts listés ici existent dans le dépôt (`scripts/tools/`, `Makefile`, hooks Git selon configuration locale). Pour l’inventaire à jour, préférer `make help` et le dossier `scripts/tools/`.

---

## 📈 Métriques de progression

**Total à migrer :**
- 19 managers
- ~35 fichiers core
- ~100+ modules
- ~50+ utilitaires

**Progression (aperçu 2026-04, aligné CI) :**
- **19 / 19 managers** : core sous `core/managers/<nom>/core/*.sh` + adapters `shells/{zsh,bash,fish}/adapters/`.
- **Tests Docker** : `make test` = matrice managers (63 cellules avec la liste migrée par défaut) + matrice sous-commandes ; sortie live + `test_results/test_output.log`.
- **Modules / utilitaires** : volumétrie historique (~100 modules, ~50 utilitaires) — affiner au fil des refactors ; ce n’est pas le même compteur que « managers ».

**Objectif :** parité fonctionnelle **et** UX (menus, messages, non-régression CI) sur les trois shells.

---

## 🎯 Prochaines actions (priorisées, 2026-04)

1. ✅ CI Docker `make test` (managers + sous-commandes) — **à maintenir** lors des changements de managers ou de `scripts/test/subcommands/*.list`.
2. ⏳ **Parité UX** : réduire les `read` / menus bloquants hors TTY là où la CI ou les scripts appellent encore une sous-commande « interactive ».
3. ⏳ **Phase 2 installman** : finitions documentées dans ce fichier (§ plus bas) — moteur POSIX / parcours `INSTALLMAN_ENGINE`, détections, etc.
4. ⏳ **`@skip` phase 2** : pour `multimediaman` / `cyberlearn`, ajouter des invocations **non interactives** dans les `.list` si on veut les couvrir comme les autres (sinon garder `@skip` et tests manuels).
5. ⏳ **Guides `docs/migrations/`** : les mettre à jour seulement quand une étape de migration change réellement (éviter la divergence avec `STATUS` et `make test-help`).

---

## 📚 Documentation

- `docs/migrations/MIGRATION_COMPLETE_GUIDE.md` - Guide complet détaillé
- `docs/migrations/MIGRATION_PLAN.md` - Plan détaillé
- `docs/migrations/MIGRATION_MULTI_SHELLS.md` - Explications
- `docs/migrations/COMPLETE_MIGRATION_LIST.md` - Liste précise de tout à migrer
- `STATUS.md` - Ce fichier (suivi de progression)

---

## ⚠️ Notes importantes

- Cette migration est **majeure** et nécessitera plusieurs sessions
- Approche **progressive** recommandée pour éviter les erreurs
- Tests **approfondis** nécessaires à chaque étape
- Commits **réguliers** pour pouvoir tester progressivement

---

**Dernière mise à jour :** 2026-04-23  
**Statut global :** Structure hybride **en production** ; **19/19** managers avec core + adapters ; **`make test`** vert = régression multi-shell maîtrisée sur les invocations déclarées.  
**Architecture :** ✅ `core/managers/` + `shells/{zsh,bash,fish}/adapters/`

### 📊 État des Managers

**Managers migrés complètement (Core POSIX + Adapters zsh/bash/fish) :**
  - ✅ **pathman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **manman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **searchman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **aliaman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **helpman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **fileman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **miscman** : Migration complète POSIX (core + adapters zsh/bash/fish)
  - ✅ **gitman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **configman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **moduleman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **sshman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **devman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **virtman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **multimediaman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **testman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **testzshman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **netman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **cyberlearn** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **installman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`
  - ✅ **cyberman** : Migration complète POSIX (core + adapters zsh/bash/fish) — CI `make test`

**🎉 MIGRATION PHASE 2 TERMINÉE ! 🎉**

Tous les 19 managers ont maintenant un code POSIX complet dans `core/managers/*/core/*.sh`.

**Managers migrés partiellement (Wrappers temporaires + Adapters complets) :**
  - ⚠️ **installman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés + ✨ Nouvelles fonctionnalités
  - ⚠️ **fileman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **helpman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **cyberman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **devman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **virtman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **miscman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés

**Managers migrés récemment (Wrappers temporaires + Adapters complets) :**
  - ⚠️ **netman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **sshman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **testman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **testzshman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **moduleman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **multimediaman** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés
  - ⚠️ **cyberlearn** : Wrapper temporaire (charge ZSH original) + ✅ Adapters zsh/bash/fish créés

**Progression globale :**
- ✅ Phase 0 : Structure Hybride (13/19 managers avec wrappers/adapters)
- ✅ Phase 1 : Adapters Complets (19/19 managers avec adapters zsh/bash/fish) ✅ TERMINÉE
- ⏳ Phase 2 : Migration POSIX Complète (wrappers → code POSIX)
- ⏳ Phase 3 : Tests Complets Multi-Shells

**Prochaines étapes immédiates :**
1. ✅ Créer adapters bash/fish pour managers migrés (FAIT)
2. ✅ Créer wrappers + adapters pour managers restants (FAIT)
3. ✅ Migrer searchman, aliaman, helpman, fileman, miscman vers POSIX (FAIT)
4. ✅ Migrer gitman et configman vers code POSIX complet (FAIT)
5. ⏳ Migrer autres wrappers vers code POSIX complet (installman, devman, virtman, etc.)
5. ✅ Tests complets multi-shells (FAIT - scripts créés)
6. ✅ Système de synchronisation automatique (FAIT - scripts créés)

**Tests :** ✅ Tests syntaxe passés pour tous les managers migrés
**Utils :** ✅ progress_bar.sh et progress_utils.py créés (réutilisables partout)
**Docker :** ✅ Tests multi-distributions fonctionnels (Arch, Ubuntu, Debian, Gentoo, Alpine, Fedora, CentOS, openSUSE)
**Chargement :** ✅ bashrc_custom et config_custom.fish mis à jour pour charger depuis adapters

---

## ✨ Nouvelles Fonctionnalités (Décembre 2025)

### 📦 Système de Gestion de Paquets Multi-Gestionnaires (installman)

**Fonctionnalités ajoutées :**
- ✅ Support multi-gestionnaires : pacman, yay, AUR, snap, flatpak, apt, dpkg, dnf, rpm, npm
- ✅ Détection automatique de la distribution (Arch, Debian, Ubuntu, Fedora, Gentoo)
- ✅ Recherche de paquets dans tous les gestionnaires
- ✅ Installation/Suppression avec auto-détection du gestionnaire
- ✅ Liste des paquets installés par gestionnaire
- ✅ Informations détaillées sur les paquets
- ✅ Installation automatique des gestionnaires manquants

**Usage :**
```bash
installman packages    # Menu complet
installman search vim  # Rechercher vim
installman install vim # Installer vim
installman remove vim  # Supprimer vim
installman list        # Lister paquets installés
```

### 🔄 Système de Mise à Jour (installman)

**Fonctionnalités ajoutées :**
- ✅ Menu de mise à jour pour outils installés
- ✅ Détection de version actuelle et disponible
- ✅ Choix de version (dernière ou spécifique)
- ✅ Mise à jour individuelle ou en masse
- ✅ Indicateurs visuels (🆕 pour mises à jour disponibles)

**Usage :**
```bash
installman update       # Menu de mise à jour
installman update-all   # Mettre à jour tous les outils
```

### 🐳 Système de Test Docker Multi-Distributions

**Fonctionnalités ajoutées :**
- ✅ Conteneur `dotfiles-vm` pour tests interactifs
- ✅ Support multi-distributions : Arch, Ubuntu, Debian, Gentoo
- ✅ Mode persistant/éphémère (reset optionnel)
- ✅ Volumes montés pour config et SSH
- ✅ Test d'installation bootstrap dans conteneur propre
- ✅ Commandes Makefile dédiées
- ✅ **`make docker-in`** : même bac à sable **léger** (`--rm`) avec choix **distro** + **shell** (menus si terminal) ; Arch = image `docker-build`, les autres = `scripts/test/docker/Dockerfile.*` → tag `dotfiles-in-<distro>:latest`. Voir `scripts/test/docker/docker_in.sh` et variables `DOCKER_*` dans le `Makefile`.
- ✅ **`shared/env.sh` (prod) durci** : fallback interne si `add_to_path` absent, `mkdir` tolérant en lecture seule, `clean_path` optionnel, message seulement en TTY et mode silencieux possible (`DOTFILES_ENV_QUIET=1`).

**Usage :**
```bash
make docker-in                              # menus distro puis shell (TTY)
make docker-in DOCKER_DISTRO=debian         # Debian sans menu distro
make docker-in DOCKER_DISTRO=ubuntu DOCKER_SHELL=bash
make docker-vm              # Lancer conteneur dotfiles-vm
make docker-vm-reset        # Réinitialiser le conteneur
make docker-vm-shell        # Ouvrir shell dans dotfiles-vm
make docker-vm-stop         # Arrêter dotfiles-vm
make docker-vm-clean        # Nettoyer complètement
make docker-test-bootstrap  # Tester installation bootstrap
```

### 📊 Gestion de Versions (configman)

**Fonctionnalités ajoutées :**
- ✅ Menu de gestion de versions (Node, Python, Java)
- ✅ Installation/Activation de versions spécifiques
- ✅ Liste des versions disponibles/installées
- ✅ Support NVM, pyenv, archlinux-java

**Usage :**
```bash
configman              # Menu principal → Option 11
# Ou directement:
version_manager_menu    # Menu de gestion de versions
```

### 👁️ Visualisation de Configuration (configman)

**Fonctionnalités ajoutées :**
- ✅ Vue d'ensemble complète de la configuration
- ✅ Versions des outils (Node, Python, Java)
- ✅ Configuration Git
- ✅ Gestionnaires de paquets disponibles
- ✅ Outils installés
- ✅ Shells disponibles
- ✅ Configuration SSH

**Usage :**
```bash
configman              # Menu principal → Option 12
# Affiche la vue d'ensemble complète
```

