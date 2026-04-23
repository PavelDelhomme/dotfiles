# Architecture des Dotfiles

## Bac à sable `DOTFILES_GOOD/` (nouvelle structure, additif)

Un répertoire **`DOTFILES_GOOD/`** à la racine du dépôt prépare une arborescence plus claire (**`lib/`**, **`shared/env`**, **`shared/menus/`**, **`core/`**, **`run/`** pour sorties temporaires, etc.) **sans déplacer** les fichiers actuellement utilisés en production.

- **Bootstrap POSIX** : `DOTFILES_GOOD/lib/bootstrap_posix.sh` définit `DOTFILES_GOOD_ROOT`, assure `DOTFILES_DIR`, puis charge dans l’ordre `shared/env/*.sh`, `shared/functions/*.sh`, `shared/aliases.sh`. Lors d’un **`.` / `source`**, `$0` n’est pas fiable : exporter **`DOTFILES_DIR`** (ou garder le clone sous **`$HOME/dotfiles`**) avant de sourcer ce fichier.
- **Snippets** : `DOTFILES_GOOD/snippets/` documente des **fins de** `.zshrc` / `.bashrc` / `config.fish` **minces** (POSIX commun + couche shell), sans être branchés par défaut.
- **Test** : `make test-dotfiles-good` (smoke `sh -n` + sourcing).

Voir `DOTFILES_GOOD/README.md` pour le plan de migration progressive.

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

**Lecture rapide** : la **source de vérité métier** cible est le **core POSIX** ; les colonnes adapter et résidu sont la **colle** et l’**héritage** à faire maigrir (wrappers d’une ligne, puis suppression de logique dupliquée dans `zsh/functions/`).

Les adapters **Bash** et **Fish** vivent sous `shells/bash/adapters/` et `shells/fish/adapters/` (non détaillés ligne par ligne ici ; même principe).

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
