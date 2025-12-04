# Architecture des Dotfiles

## 📁 Structure des Fichiers de Configuration ZSH

### Fichiers ZSH : `zshrc`, `.zshrc`, et `zshrc_custom`

Le projet utilise trois fichiers différents pour la configuration ZSH :

#### 1. `~/dotfiles/zshrc` (Wrapper à la racine)
- **Rôle** : Wrapper intelligent qui détecte le shell actif (ZSH, Fish, Bash)
- **Emplacement** : `~/dotfiles/zshrc` (à la racine du projet)
- **Fonction** :
  - Détecte automatiquement le shell en cours d'exécution
  - Source la configuration appropriée selon le shell
  - Pour ZSH : source `zsh/zshrc_custom`
  - Pour Fish : affiche un message (config doit être dans `.config/fish/config.fish`)
  - Pour Bash : charge les variables d'environnement et alias compatibles

#### 2. `~/.zshrc` (Symlink dans le HOME)
- **Rôle** : Point d'entrée standard de ZSH (chargé automatiquement au démarrage)
- **Emplacement** : `~/.zshrc` (dans votre répertoire HOME)
- **Fonction** : Symlink vers `~/dotfiles/zshrc`
- **Création** : Automatique lors de l'installation via `create_symlinks.sh`

#### 3. `~/dotfiles/zsh/zshrc_custom` (Configuration principale)
- **Rôle** : Configuration ZSH complète et principale
- **Emplacement** : `~/dotfiles/zsh/zshrc_custom`
- **Contenu** :
  - Chargement des managers (installman, configman, etc.)
  - Variables d'environnement
  - Aliases
  - Fonctions
  - Configuration Powerlevel10k
  - Toute la logique de configuration ZSH

### Pourquoi cette architecture ?

1. **Flexibilité multi-shells** : Le wrapper `zshrc` permet de supporter ZSH, Fish et Bash avec un seul symlink
2. **Modularité** : La vraie configuration est dans `zshrc_custom`, facile à modifier
3. **Compatibilité** : ZSH charge automatiquement `~/.zshrc`, donc on utilise un symlink
4. **Centralisation** : Tout est dans `~/dotfiles/` pour faciliter la synchronisation

### Flux de chargement

```
ZSH démarre
    ↓
Charge ~/.zshrc (symlink)
    ↓
Pointe vers ~/dotfiles/zshrc (wrapper)
    ↓
Détecte ZSH_VERSION
    ↓
Source ~/dotfiles/zsh/zshrc_custom
    ↓
Configuration complète chargée ✅
```

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

### Managers disponibles (18 managers)

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

### Structure après installation

```
~/
├── .zshrc → ~/dotfiles/zshrc (symlink)
├── .gitconfig → ~/dotfiles/.gitconfig (symlink)
├── .p10k.zsh → ~/dotfiles/.p10k.zsh (symlink)
└── dotfiles/
    ├── zshrc (wrapper)
    ├── zsh/
    │   └── zshrc_custom (config principale)
    ├── test-docker.sh (tests Docker)
    └── ...
```

## 📝 Notes importantes

- **`test-docker.sh` à la racine** : Nécessaire car appelé directement par le Makefile
- **Wrapper `zshrc`** : Permet la compatibilité multi-shells
- **`zshrc_custom`** : Contient toute la vraie configuration ZSH
- **Symlinks** : Centralisent la configuration dans `~/dotfiles/`
- **Isolation Docker** : Préfixe `dotfiles-test-*` pour ne pas toucher vos autres conteneurs
