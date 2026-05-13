> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# Architecture des Dotfiles

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

## Bac à sable `DOTFILES_GOOD/` (nouvelle structure, additif)

Un répertoire **`DOTFILES_GOOD/`** à la racine du dépôt prépare une arborescence plus claire (**`lib/`**, **`shared/env`**, **`shared/menus/`**, **`core/`**, **`run/`** pour sorties temporaires, etc.) **sans déplacer** les fichiers actuellement utilisés en production.

- **Bootstrap POSIX** : `DOTFILES_GOOD/lib/bootstrap_posix.sh` définit `DOTFILES_GOOD_ROOT`, assure `DOTFILES_DIR`, puis charge dans l’ordre `shared/env/*.sh`, `shared/functions/*.sh`, `shared/aliases.sh`. Lors d’un **`.` / `source`**, `$0` n’est pas fiable : exporter **`DOTFILES_DIR`** (ou garder le clone sous **`$HOME/dotfiles`**) avant de sourcer ce fichier.
- **Snippets** : `DOTFILES_GOOD/snippets/` documente des **fins de** `.zshrc` / `.bashrc` / `config.fish` **minces** (POSIX commun + couche shell), sans être branchés par défaut.
- **Test** : `make test-dotfiles-good` (smoke `sh -n` + sourcing).

Voir `DOTFILES_GOOD/README.md` pour le plan de migration progressive.

Roadmap globale unifiée (structure + TUI + install + migration): `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`.

---

## Fichiers d’entrée shell : ce qui est vrai aujourd’hui

### Important : pas de « symlink unique pour tous les shells »

- **`~/.zshrc`** ne peut être lu **que par Zsh**. Un symlink vers un fichier du dépôt ne configure **pas** Fish ni Bash.
- **Fish** lit `~/.config/fish/config.fish` (ou l’équivalent XDG), pas `.zshrc`.
- **Bash** lit `~/.bashrc` (selon mode login/interactif).

Toute doc qui suggère qu’un seul fichier « wrapper » à la racine du dépôt suffit à **tout** les shells est **incorrecte** : au mieux ce fichier peut **détecter** le shell et charger des morceaux adaptés, mais **Fish ne passera jamais** par un fichier Zsh nommé `~/.zshrc`.

### Deux patterns coexistent dans le dépôt

#### A) Fichiers **`.zshrc`** et **`.bashrc`** à la racine du dépôt (recommandé, cohérent multi-shell)

- Rôle : point d’entrée **versionné**, prêt à être symlinké vers `$HOME` **pour ce shell uniquement** (`~/.zshrc` → `dotfiles/.zshrc`, `~/.bashrc` → `dotfiles/.bashrc`).
- Ordre typique :
  1. Sourcer **`shared/config.sh`** (POSIX / sh-bash-zsh : `DOTFILES_DIR`, `env.sh`, `aliases.sh`, fonctions `shared/functions/*.sh`).
  2. Sourcer la couche **spécifique** : `zsh/zshrc_custom` ou `bash/bashrc_custom`.

La logique **réutilisable** est donc dans **`shared/config.sh`** (+ `shared/env.sh`, etc.), pas dans le fichier Zsh « géant » seul.

#### B) Fichier **`zshrc`** (sans point) à la racine — historique

- Ancien script qui teste `ZSH_VERSION` / `BASH_VERSION` / `FISH_VERSION` et branche des chemins différents.
- **Limites** : mélange Zsh/Bash, messages pour Fish au lieu d’un vrai chargement ; ne remplace pas `config.fish`.
- Si `~/.zshrc` pointe encore vers **`~/dotfiles/zshrc`**, c’est un choix d’installation **Zsh seulement** ; ce n’est pas un modèle universel.

### Flux cible (documentation)

```
Zsh : ~/.zshrc  →  dotfiles/.zshrc  →  shared/config.sh (POSIX)  →  zsh/zshrc_custom (Zsh)
Bash: ~/.bashrc → dotfiles/.bashrc →  shared/config.sh (POSIX)  →  bash/bashrc_custom
Fish: ~/.config/fish/config.fish  →  adapters fish + éventuellement bash pour blocs POSIX
```

À terme, le bloc POSIX pourra être **`DOTFILES_GOOD/lib/bootstrap_posix.sh`** ou l’équivalent fusionné avec `shared/config.sh`, **après** validation dans les conteneurs (`make test`).

---

## Cartographie managers (core / adapters / résidu Zsh)

Liste alignée sur **`scripts/test/config/migrated_managers.list`** (managers couverts par `make test` Docker par défaut). À **mettre à jour** si un manager entre ou sort de cette liste.

| Manager | Core POSIX `core/managers/…/core/*.sh` | Adapter `shells/zsh/adapters/` | Résidu typique sous `zsh/functions/` |
|---------|----------------------------------------|----------------------------------|--------------------------------------|
| pathman | oui | oui | dossier `pathman/` (core Zsh historique, etc.) |
| manman | oui | oui | `manman.zsh` seul |
| searchman | oui | oui | `searchman.zsh` seul |
| aliaman | oui | oui | `aliaman.zsh` seul |
| installman | oui | oui | dossier **`installman/`** (volumineux : modules, utils) |
| configman | oui | oui | dossier `configman/` |
| gitman | oui | oui | dossier `gitman/` |
| fileman | oui | oui | dossier `fileman/` |
| helpman | oui | oui | dossier `helpman/` |
| cyberman | oui | oui | dossier `cyberman/` |
| devman | oui | oui | dossier `devman/` |
| virtman | oui | oui | dossier `virtman/` |
| miscman | oui | oui | dossier `miscman/` |
| doctorman | oui | oui | `doctorman.zsh` seul |
| netman | oui | oui | dossier `netman/` |
| sshman | oui | oui | dossier `sshman/` |
| testman | oui | oui | dossier `testman/` |
| testzshman | oui | oui | dossier `testzshman/` |
| moduleman | oui | oui | dossier `moduleman/` |
| multimediaman | oui | oui | dossier `multimediaman/` |
| cyberlearn | oui | oui | dossier **`cyberlearn/`** (modules) |
| displayman | oui | oui | — *(pas de résidu Zsh, créé directement sous `core/managers/displayman/`)* |

**Lecture rapide** : la **source de vérité métier** cible est le **core POSIX** ; les colonnes adapter et résidu sont la **colle** et l’**héritage** à faire maigrir (wrappers d’une ligne, puis suppression de logique dupliquée dans `zsh/functions/`).

Les adapters **Bash** et **Fish** vivent sous `shells/bash/adapters/` et `shells/fish/adapters/` (non détaillés ligne par ligne ici ; même principe).

---

## Refonte modulaire prioritaire (proposition validable pas-à-pas)

### Pourquoi maintenant

Le dépôt mélange encore plusieurs patterns historiques :

- managers "plats" (`zsh/functions/aliaman.zsh`) ;
- managers en dossier (`zsh/functions/cyberlearn/`, `zsh/functions/netman/`) ;
- commandes réseau éparses sous `zsh/functions/commands/network/` (`ipinfo`, `network_scanner`, `whatismyip`, `ssh_auto_setup`, etc.) ;
- wrappers parfois encore branchés vers l'ancien arbre Zsh.

La cible reste inchangée : **core POSIX canonique** + **adapters shell minces** + **legacy Zsh réduit à des wrappers de compatibilité**.

### Règles d'architecture (source de vérité)

- **Métier manager** : `core/managers/<manager>/core/<manager>.sh`
- **Glue shell** : `shells/{zsh,bash,fish}/adapters/<manager>.*`
- **Legacy Zsh** : `zsh/functions/<manager>.zsh` ou `zsh/functions/<manager>/` = wrapper de transition uniquement
- **Commandes transverses** (ex. réseau hors manager) :
  - cible `core/commands/<domain>/<command>.sh` (POSIX), puis adapters shell
  - ou intégration explicite dans `core/managers/netman/` si la commande est du ressort netman

### Plan d'exécution (ordre prioritaire)

1. **Normaliser la forme de chaque manager**  
   Pour chaque `*man`, avoir les 3 couches (core POSIX, adapters, wrapper legacy minimal).  
   Critère: aucun code métier dupliqué entre `core/` et `zsh/functions/`.

2. **Cartographier et reclasser le domaine réseau**  
   Inventaire des commandes sous `zsh/functions/commands/network/` et décision par commande:  
   - reste commande transverse ; ou
   - migre dans netman (sous-commandes/modules).  
   Objectif: éviter le "double monde" netman vs commandes réseau isolées.

3. **Modulariser les managers monolithiques encore plats**  
   Exemple attendu pour `aliaman`/`cyberlearn` : `modules/`, `utils/`, `config/` (si utile) sous `core/managers/<manager>/`.

4. **Réduire l'historique Zsh**  
   Les fichiers sous `zsh/functions/` doivent devenir lisibles comme "compat layer", pas comme source métier.

5. **Préparer la bascule `DOTFILES_GOOD`**  
   Une fois la structure stabilisée et testée, converger le bac `DOTFILES_GOOD/` vers l'arborescence de référence.

### Politique de migration sans perte fonctionnelle

- Pas de big bang.
- Une fonctionnalité à la fois.
- Chaque migration garde un wrapper de compatibilité.
- Aucun changement de comportement utilisateur non documenté.

### Protocole de test obligatoire (après chaque fonctionnalité)

À lancer dans ton terminal à chaque étape :

1. **Syntaxe et chargement**
   - `make test`
2. **Menus/fzf/fallbacks**
   - `make test-menu-fzf`
3. **Fonction concernée (smoke ciblé)**
   - Exemple réseau: `netman help`, `netman interfaces`, `netman ports`, `netman connectivity 1.1.1.1`
4. **Validation shell utilisateur**
   - test rapide dans `zsh`, `bash`, `fish` pour la commande modifiée
5. **Contrat non-interactif**
   - vérifier qu'une invocation non-TTY ne bloque pas (CI/docker/pipes)

### Définition de "done" pour une brique migrée

- code métier dans `core/` ;
- adapters shell opérationnels ;
- wrapper legacy minimal ;
- tests verts (`make test` + smoke ciblés) ;
- doc mise à jour (`ARCHITECTURE.md`, `TODOS.md`, `STATUS.md`).

---

## Socle commun ultra-réutilisable (incluant option C)

### Position pragmatique

Oui, un socle compilé (C) peut résoudre une grosse partie de la duplication multi-shell.  
Mais un basculement "tout en C d'un coup" serait risqué. La stratégie recommandée :

1. **stabiliser l'architecture modulaire actuelle** (source de vérité claire) ;
2. **introduire un binaire commun progressivement** pour les briques à forte valeur ;
3. garder les shells comme **orchestrateurs minces**.

### Cible technique

- Un binaire unique `dotcli` (écrit en C) pour les primitives communes :
  - TUI (menu, sélection, preview, pagination, recherche) ;
  - rendu (couleurs/icônes/fallback ASCII) ;
  - I/O robustes (TTY/non-TTY, logs, timeouts) ;
  - utilitaires communs (tableaux, filtres, parse léger).
- Les managers shell appellent `dotcli` au lieu de réimplémenter :
  - `dotcli menu ...`
  - `dotcli pick ...`
  - `dotcli render ...`
  - `dotcli net ...` (à terme, pour certains diagnostics réseau standardisés)
- Les scripts shell gardent la logique métier de haut niveau au début, puis migrent progressivement vers des sous-commandes du binaire.

### Pourquoi C (et limites)

**Avantages**
- même comportement sous zsh/bash/fish/sh ;
- performances et robustesse TUI ;
- packaging simple via `installman` (binaire précompilé ou build local) ;
- réduction nette de la dette "même feature recodée 4 fois".

**Limites**
- coût de maintenance natif ;
- gestion multi-plateforme plus stricte ;
- nécessité de test ABI/comportement plus rigoureux.

### Roadmap proposée (sans régression)

#### Étape 0 — Maintenant (obligatoire)
- Finir la normalisation modulaire `core + adapters + wrappers`.
- Définir des interfaces stables "backend command" pour chaque manager.

#### Étape 1 — Prototype C minimal
- Créer `tools/dotcli/` avec:
  - `dotcli doctor`
  - `dotcli menu` (TUI/fallback non-TTY)
  - `dotcli render` (thème/fallback icônes/couleurs)
- Intégrer uniquement dans 1 manager pilote (`netman` ou `aliaman`), derrière feature flag.

#### Étape 2 — TUI mutualisée
- Remplacer progressivement les menus shell/fzf/ncmenu par `dotcli menu`.
- Garder fzf en fallback tant que la parité n'est pas atteinte.

#### Étape 3 — Extensions métier ciblées
- Ajouter des sous-commandes C pour opérations communes à forte duplication (par ex. rendu de listes, sélection interactive, formatting réseau).

#### Étape 4 — Généralisation
- Les shells deviennent surtout "wrappers UX" + compatibilité historique.
- La logique partagée vit majoritairement dans le socle compilé + core POSIX.

### Contrat de compatibilité shell

Le projet doit rester utilisable sans friction sous `zsh`, `bash`, `fish`, `sh` :

- aucun manager ne dépend d'une syntaxe shell non encapsulée ;
- détection TTY systématique ;
- fallback sans blocage en non-interactif ;
- tests multi-shell obligatoires à chaque migration.

### Protocole de test pour la piste C

À chaque étape d'intégration `dotcli` :

1. `make test`
2. `make test-menu-fzf` (jusqu'au remplacement complet)
3. tests manuels de la feature pilote en `zsh`, `bash`, `fish`, `sh`
4. test non-TTY (`... | cat`, CI/docker)
5. validation rollback (désactivation flag -> comportement précédent)

---

## Fichiers ZSH détaillés (référence)

### `~/dotfiles/zsh/zshrc_custom`

- **Rôle** : configuration Zsh « lourde » (prompt, complétion, chargement des fonctions `zsh/functions/`, etc.).
- **Ne doit pas** contenir toute la logique d’environnement réutilisable par Bash : celle-ci appartient à **`shared/config.sh`** (ou au futur bootstrap `DOTFILES_GOOD`).

### Symlinks dans `$HOME`

- **`~/.zshrc` → `~/dotfiles/.zshrc`** (ou vers `~/dotfiles/zshrc` si ancien bootstrap) : uniquement Zsh.
- Autres dotfiles : voir scripts de symlinks / install.

---

## 🐳 Structure Docker pour Tests

### Fichiers Docker à la racine

#### `test-docker.sh`
- **Emplacement** : `~/dotfiles/test-docker.sh` (à la racine)
- **Pourquoi à la racine ?** :
  - Appelé directement par `make docker-test-auto` depuis le Makefile
  - Doit être accessible facilement depuis la racine du projet
  - Script principal d'orchestration des tests Docker
  - Permet de sélectionner interactivement les managers à tester

#### `Dockerfile.test`
- **Emplacement** : `~/dotfiles/Dockerfile.test` (à la racine)
- **Fonction** : Dockerfile pour créer l'image de test avec installation automatique
- **Contenu** :
  - Installation automatique des dotfiles
  - Tests de vérification
  - Tests fonctionnels des managers

#### `docker-compose.yml`
- **Emplacement** : `~/dotfiles/docker-compose.yml` (à la racine)
- **Fonction** : Orchestration Docker avec préfixe isolé `dotfiles-test-*`
- **Isolation** : Ne touche jamais vos autres conteneurs Docker

## 📦 Structure des Managers

### Managers disponibles (liste migrée Docker : 21 entrées)

1. **aliaman** - Gestionnaire alias
2. **configman** - Gestionnaire configuration
3. **cyberman** - Gestionnaire cybersécurité
4. **devman** - Gestionnaire développement
5. **fileman** - Gestionnaire fichiers
6. **gitman** - Gestionnaire Git
7. **helpman** - Gestionnaire aide/documentation
8. **installman** - Gestionnaire installation
9. **manman** - Manager of Managers
10. **miscman** - Gestionnaire divers
11. **moduleman** - Gestionnaire modules (activation/désactivation)
12. **netman** - Gestionnaire réseau
13. **pathman** - Gestionnaire PATH
14. **searchman** - Gestionnaire recherche
15. **sshman** - Gestionnaire SSH
16. **testman** - Gestionnaire tests applications
17. **testzshman** - Gestionnaire tests ZSH/dotfiles
18. **virtman** - Gestionnaire virtualisation
19. **doctorman** - Gestionnaire documentation
20. **multimediaman** - Gestionnaire multimédia
21. **cyberlearn** - Parcours apprentissage / cyber
22. **displayman** - Gestionnaire écran / luminosité / DDC (preset couleur, range HDMI, OSD)

### Structure modulaire

Tous les managers suivent la même structure :

```
zsh/functions/
├── <manager>.zsh          # Wrapper de compatibilité
└── <manager>/             # Répertoire du manager
    ├── core/              # Script principal
    │   └── <manager>.zsh
    ├── modules/           # Modules organisés
    ├── utils/             # Utilitaires
    ├── config/            # Configuration
    └── install/           # Scripts d'installation
```

La cible hybride documentée dans **`STATUS.md`** est que la logique POSIX vive sous **`core/managers/<nom>/core/*.sh`** avec des adapters dans **`shells/{zsh,bash,fish}/`**.

## 🔄 Flux d'Installation

### Installation automatique

```
bootstrap.sh
    ↓
Configuration Git
    ↓
Configuration SSH (optionnel)
    ↓
Clonage dotfiles
    ↓
Choix du shell
    ↓
Création symlinks (optionnel)
    ↓
Lancement setup.sh (menu interactif)
```

### Structure après installation (schéma simplifié)

```
~/
├── .zshrc → ~/dotfiles/.zshrc   (recommandé)  OU  ~/dotfiles/zshrc (historique)
├── .bashrc → ~/dotfiles/.bashrc
├── .gitconfig → ~/dotfiles/.gitconfig (symlink)
├── .p10k.zsh → ~/dotfiles/.p10k.zsh (symlink)
└── dotfiles/
    ├── shared/config.sh      # POSIX commun (env, alias, fonctions)
    ├── zsh/zshrc_custom      # Zsh spécifique
    ├── DOTFILES_GOOD/        # Bac à sable futur (additif)
    └── ...
```

## 📝 Notes importantes

- **`test-docker.sh` à la racine** : Nécessaire car appelé directement par le Makefile
- **Entrées shell** : une par shell (`.zshrc`, `.bashrc`, `config.fish`) ; le cœur réutilisable est **`shared/config.sh`** (et/ou `DOTFILES_GOOD/lib/bootstrap_posix.sh` en expérimentation)
- **`zshrc_custom`** : Zsh spécifique ; pas le seul endroit pour variables d’environnement partagées
- **Symlinks** : Centralisent la configuration dans `~/dotfiles/`
- **Isolation Docker** : Préfixe `dotfiles-test-*` pour ne pas toucher vos autres conteneurs
