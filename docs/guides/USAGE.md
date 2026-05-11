# Usage quotidien — Dotfiles

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte doc** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Carte code** : [`../CODEMAP.md`](../CODEMAP.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`../../STATUS.md`](../../STATUS.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md)

---

## Sommaire

1. [Usage quotidien (Make, recharger, mettre à jour)](#usage-quotidien-make-recharger-mettre-a-jour)
2. [Système d’aide et documentation (`help`, `man`)](#systeme-daide-et-documentation-help-man)
3. [Validation du setup](#validation-du-setup)
4. [Configuration Powerlevel10k](#configuration-powerlevel10k)
5. [Maintenance (update, upgrade, Docker cleanup…)](#maintenance)
6. [Structure recommandée après installation](#structure-recommandee-apres-installation)
7. [Fichiers de configuration (.env, aliases, zshrc, …)](#fichiers-de-configuration)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Usage quotidien

### Commandes Makefile (recommandé)

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Voir toutes les commandes disponibles :

```bash
make help
```

Installation complète :

```bash
make install
```

Menu interactif :

```bash
make setup
```

Créer symlinks :

```bash
make symlinks
```

Migrer config existante :

```bash
make migrate
```

Valider le setup :

```bash
make validate
```

Installer Docker :

```bash
make install-docker
```

Installer Go :

```bash
make install-go
```

Installer Cursor :

```bash
make install-cursor
```

Installer Brave :

```bash
make install-brave
```

Installer yay (Arch Linux) :

```bash
make install-yay
```

Configurer Git :

```bash
make git-config
```

Configurer remote Git :

```bash
make git-remote
```

Configurer auto-sync :

```bash
make auto-sync
```

Rollback complet :

```bash
make rollback
```

Réinitialisation complète :

```bash
make reset
```

Nettoyer fichiers temporaires :

```bash
make clean
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Recharger la configuration

Méthode 1 :

```bash
source ~/.zshrc
```

Méthode 2 :

```bash
exec zsh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Mettre à jour les dotfiles

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Récupérer les modifications :

```bash
git pull
```

Relancer le setup :

```bash
make setup
```

Ou :

```bash
bash scripts/setup.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Vérifications système
```bash
flutter doctor          # Flutter
docker --version        # Docker
nvidia-smi             # NVIDIA
android-studio         # Android Studio
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📚 Système d'aide et documentation

Ce système de dotfiles inclut un **système d'aide complet et unifié** pour toutes les fonctions personnalisées. Chaque fonction est documentée avec une description détaillée, la syntaxe d'utilisation et des exemples concrets.

### Aide pour les fonctions

**Liste toutes les fonctions disponibles :**
```bash
help
```

**Aide détaillée pour une fonction spécifique :**
```bash
help extract
help docker_build
help kill_process
```

La commande `help` affiche :
- 📝 **Description** : Explication détaillée de ce que fait la fonction
- 💻 **Usage** : Syntaxe complète avec tous les arguments
- 📚 **Exemples** : Exemples concrets d'utilisation
- 💡 **Astuces** : Conseils et informations supplémentaires

**Exemple de sortie :**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 AIDE: extract
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Description:
   Extrait automatiquement n'importe quel type d'archive dans le répertoire
   courant. La fonction détecte automatiquement le format et utilise l'outil
   approprié pour l'extraction.

💻 Usage:
   extract <fichier_archive>
   extract                    # Affiche cette aide
   extract --help            # Affiche cette aide

📚 Exemples:
   extract mon_archive.zip
   extract backup.tar.gz
   extract fichier.rar
```

### Pages man pour les fonctions

**Afficher la documentation complète (page man) :**
```bash
man extract
man docker_build
```

Les pages man sont au format Markdown et contiennent :
- Description complète de la fonction
- Tous les formats/options supportés
- Exemples détaillés
- Codes de retour
- Prérequis et dépendances
- Voir aussi (liens vers fonctions connexes)

**Générer toutes les pages man :**
```bash
make generate-man
```

Cette commande génère automatiquement les pages man pour toutes les fonctions à partir des commentaires de documentation dans le code.

### Génération automatique de documentation

Le système extrait automatiquement la documentation depuis les commentaires dans les fichiers de fonctions :

**Format standardisé :**
```bash
# DESC: Description détaillée de la fonction
# USAGE: nom_fonction <arg1> [arg2]
# EXAMPLE: nom_fonction exemple1
# EXAMPLE: nom_fonction exemple2
```

**Scripts disponibles :**
- `scripts/tools/generate_man_pages.sh` - Génère les pages man pour toutes les fonctions
- `scripts/tools/add_missing_examples.sh` - Ajoute automatiquement des exemples manquants

### Format de documentation

Toutes les fonctions personnalisées suivent le même format de documentation :

1. **DESC** : Description détaillée de ce que fait la fonction
2. **USAGE** : Syntaxe complète avec tous les arguments (obligatoires `<>` et optionnels `[]`)
3. **EXAMPLE** : Un ou plusieurs exemples concrets d'utilisation

**Exemple dans le code :**
```bash
# DESC: Extrait automatiquement des fichiers d'archive dans le répertoire courant
#       Supporte: tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm, etc.
# USAGE: extract [<file_path>] [--help|-h|help]
# EXAMPLE: extract archive.zip
# EXAMPLE: extract archive.tar.gz
# EXAMPLE: extract  # Affiche l'aide si aucun argument
extract() {
    # ... code de la fonction
}
```

**Fonctions documentées :**
- ✅ **100+ fonctions** avec documentation complète
- ✅ **misc/** : process, disk, clipboard, files, backup, security, system
- ✅ **dev/** : go, docker, c, make
- ✅ **cyber/** : reconnaissance, scanning, vulnerability, attacks, analysis, privacy
- ✅ **git/** : toutes les fonctions Git personnalisées

**Avantages :**
- 📖 Documentation accessible directement depuis le terminal
- 🔍 Recherche facile avec `help` pour lister toutes les fonctions
- 📚 Pages man complètes pour chaque fonction
- 🎯 Exemples concrets pour chaque fonction
- 🔄 Génération automatique de documentation

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## ✅ Validation du Setup

Script de validation complète pour vérifier toutes les installations et configurations.

### Utilisation

Via le menu scripts/setup.sh (option 23) ou directement :
```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Vérifications effectuées (117+ vérifications)

**Structure dotfiles** :
- ✅ Fichiers racine (bootstrap.sh, Makefile, README.md, zshrc)
- ✅ Fichiers documentation (`STATUS.md`, `TODOS.md`, `docs/architecture/REFACTOR_HISTORY.md`, `docs/STRUCTURE.md`)
- ✅ Scripts (scripts/setup.sh, scripts/*)
- ✅ Bibliothèque commune (lib/common.sh, lib/install_logger.sh, lib/check_missing.sh)
- ✅ Structure ZSH/Fish complète (zshrc_custom, env.sh, aliases.zsh, path_log.txt, PATH_SAVE)

**Scripts** :
- ✅ Scripts d'installation (12 scripts : packages_base, install_docker, install_go, etc.)
- ✅ Scripts configuration (6 scripts : git_config, create_symlinks, qemu_*, etc.)
- ✅ Scripts synchronisation (3 scripts : git_auto_sync, install_auto_sync, restore_from_git)
- ✅ Scripts désinstallation (13 scripts : uninstall_*, rollback_*, reset_all)

**Fonctions ZSH** :
- ✅ Gestionnaires (14 : cyberman, devman, gitman, miscman, pathman, netman, helpman, aliaman, searchman, configman, installman, fileman, virtman, multimediaman)
- ✅ Fonctions dev (6 : go.sh, c.sh, docker.sh, make.sh, projects/*)
- ✅ Fonctions misc (9+ : clipboard/, security/, files/, system/, backup/)
- ✅ Fonctions cyber (structure complète : reconnaissance, scanning, vulnerability, attacks, analysis, privacy)

**Installations** :
- ✅ Fonctions ZSH (add_alias, add_to_path, clean_path)
- ✅ PATH (Go, Flutter, Android SDK, Dart)
- ✅ Services (systemd timer, Docker, SSH agent)
- ✅ Git (user.name, user.email, credential.helper, SSH key)
- ✅ Outils (Go, Docker, Cursor, yay, make, gcc, cmake)
- ✅ Répertoires (zsh/functions, dev/, misc/, cyber/, scripts/*)
- ✅ Symlinks (.zshrc, .gitconfig)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Rapport

Le script affiche un rapport avec :
- ✅ Réussis (vert)
- ❌ Échecs (rouge)
- ⚠️ Avertissements (jaune)

---

<!-- =============================================================================
     FLUTTER & ANDROID
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🎨 Configuration Powerlevel10k (Prompt avec Git)

Le prompt Manjaro utilise **Powerlevel10k** pour afficher le statut Git dans le terminal. La configuration est automatiquement gérée par les dotfiles.

### Installation automatique

Lors de l'installation via `bootstrap.sh` ou `create_symlinks.sh`, la configuration Powerlevel10k est automatiquement synchronisée :
- Si `~/dotfiles/.p10k.zsh` existe, un symlink est créé vers `~/.p10k.zsh`
- La configuration est chargée automatiquement au démarrage du shell

### Configuration manuelle

Si vous n'avez pas encore configuré Powerlevel10k :

```bash
# Via configman (recommandé)
configman p10k
# Choisir option 1 : Configurer Powerlevel10k

# Ou directement
p10k configure
```

Après configuration, copiez la configuration vers dotfiles :
```bash
configman p10k
# Choisir option 3 : Créer un symlink (recommandé pour synchronisation)
```

### Gestion via configman

```bash
# Menu interactif
configman p10k

# Options disponibles :
# 1. Configurer Powerlevel10k (p10k configure)
# 2. Copier la configuration depuis dotfiles vers ~/.p10k.zsh
# 3. Créer un symlink de ~/.p10k.zsh vers dotfiles (recommandé)
# 4. Vérifier la configuration actuelle
```

### Fonctionnement

1. **Configuration dans dotfiles** : `~/dotfiles/.p10k.zsh` (versionnée dans Git)
2. **Symlink automatique** : `~/.p10k.zsh` → `~/dotfiles/.p10k.zsh`
3. **Chargement automatique** : Le prompt charge la configuration au démarrage
4. **Statut Git** : Affiché automatiquement dans le prompt si vous êtes dans un dépôt Git

### Vérification

```bash
# Vérifier si la configuration existe
ls -la ~/.p10k.zsh

# Vérifier si le symlink pointe vers dotfiles
readlink ~/.p10k.zsh

# Vérifier la configuration via configman
configman p10k
# Choisir option 4 : Vérifier la configuration actuelle
```

### Dépannage

**Le statut Git n'apparaît pas :**
1. Vérifier que `~/.p10k.zsh` existe : `ls -la ~/.p10k.zsh`
2. Si absent, configurer : `configman p10k` (option 1)
3. Vérifier que Powerlevel10k est installé : `pacman -Q zsh-theme-powerlevel10k`
4. Recharger le shell : `exec zsh`

**La configuration n'est pas synchronisée :**
1. Créer le symlink : `configman p10k` (option 3)
2. Vérifier : `readlink ~/.p10k.zsh` doit pointer vers `~/dotfiles/.p10k.zsh`

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🛠️ Maintenance

### Mettre à jour le système

**Mise à jour intelligente (détection automatique) :**

La commande `update` détecte automatiquement votre distribution Linux et utilise le bon gestionnaire de paquets :

Mettre à jour les paquets :

```bash
update
```

Mettre à jour les paquets sans confirmation :

```bash
update --nc
```

Ou :

```bash
update --no-confirm
```

Mettre à jour complètement le système :

```bash
upgrade
```

Mettre à jour complètement le système sans confirmation :

```bash
upgrade --nc
```

Ou :

```bash
upgrade --no-confirm
```

**Distributions supportées :**
- **Arch-based** (Arch, Manjaro, EndeavourOS) → `pacman`
- **Debian-based** (Debian, Ubuntu, Mint, Kali, Parrot) → `apt`
- **Fedora-based** (Fedora) → `dnf`
- **Gentoo** → `emerge`
- **NixOS** → `nix-channel` / `nixos-rebuild`
- **openSUSE** → `zypper`
- **Alpine** → `apk`
- **RHEL/CentOS** → `yum`

**Mise à jour avec yay (AUR helper - Arch uniquement) :**

```bash
yayup
```

---

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Nettoyer Docker

Nettoyer Docker :

```bash
docker-cleanup
```

---

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Mettre à jour Cursor

Mettre à jour Cursor :

```bash
update-cursor.sh
```

---

<!-- =============================================================================
     STRUCTURE RECOMMANDÉE APRÈS INSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 📦 Structure recommandée après installation

Les symlinks sont créés automatiquement lors de l'installation pour centraliser la configuration :

```
~/
├── dotfiles/                   # Ce repo
│   ├── .zshrc                 # Configuration ZSH principale
│   ├── .gitconfig             # Configuration Git
│   └── .ssh/                  # Clés SSH et config
│       ├── id_ed25519
│       └── config
├── .zshrc -> ~/dotfiles/.zshrc              # Symlink
├── .gitconfig -> ~/dotfiles/.gitconfig       # Symlink
└── .ssh/
    ├── id_ed25519 -> ~/dotfiles/.ssh/id_ed25519      # Symlink
    └── config -> ~/dotfiles/.ssh/config              # Symlink
```

**Note :** Les symlinks sont proposés automatiquement lors de l'installation via `bootstrap.sh` ou `scripts/setup.sh`.

---

<!-- =============================================================================
     TROUBLESHOOTING
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🔧 Fichiers de configuration

### Configuration Git via .env

**📝 IMPORTANT : Le fichier `.env` est créé AUTOMATIQUEMENT après le clonage**

Le fichier `.env` permet de stocker vos informations personnelles de manière sécurisée (jamais commité dans Git) pour éviter de les saisir à chaque installation.

**✅ Création automatique :** Lors de l'installation avec `curl ... | bash`, le script :
1. Vous demande interactivement vos informations (Nom Git, Email Git)
2. Clone le repository
3. **Crée automatiquement le fichier `.env`** avec les informations que vous avez fournies
4. Vous n'avez plus besoin de créer `.env` manuellement !

**⚠️ Note :** Si vous voulez modifier le fichier `.env` après l'installation, vous pouvez le faire manuellement.

**Créer le fichier `.env` (après le clonage) :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Copier le template :

```bash
cp .env.example .env
```

Éditer avec vos valeurs (en ligne de commande, sans interface graphique) :

```bash
nano .env
```

Ou avec vim :

```bash
vim .env
```

**Variables à remplir :**

```bash
# Nom Git : Le nom qui apparaîtra dans vos commits Git
# Exemples : PavelDelhomme, Jean Dupont, John Doe
GIT_USER_NAME="VotreNomGit"

# Email Git : L'email associé à votre compte GitHub/GitLab
# Doit correspondre à l'email de votre compte GitHub/GitLab
# Pour GitHub, vous pouvez utiliser username@users.noreply.github.com pour garder votre email privé
# Exemples : dev@delhomme.ovh, votre.email@example.com
GIT_USER_EMAIL="votre.email@example.com"

# URL du repository GitHub (optionnel)
# Format HTTPS : https://github.com/USERNAME/dotfiles.git
# Format SSH : git@github.com:USERNAME/dotfiles.git
GITHUB_REPO_URL="https://github.com/VotreNom/dotfiles.git"
```

**Exemples de valeurs :**
- `GIT_USER_NAME="PavelDelhomme"` - Le nom qui apparaîtra dans vos commits
- `GIT_USER_EMAIL="dev@delhomme.ovh"` - L'email de votre compte GitHub/GitLab
- `GITHUB_REPO_URL="https://github.com/PavelDelhomme/dotfiles.git"` - URL de votre repository

**✅ Avantages :**
- Pas de saisie interactive lors des prochaines installations
- Vos valeurs sont chargées automatiquement depuis `.env`
- Sécurisé : `.env` est dans `.gitignore` et n'est jamais commité dans Git

**⚠️ Sans `.env` (première installation) :**
- Le script vous demandera interactivement votre nom et email Git
- Vous devrez répondre aux questions pendant l'installation
- Les explications seront affichées pour chaque champ demandé

### `.env` - Variables d'environnement (autres)

Le fichier `.env` peut aussi contenir d'autres variables PATH nécessaires :
- Java (pour Flutter/Android)
- Android SDK
- Flutter
- Node.js global packages
- Cargo (Rust)
- Binaires locaux

---

### `aliases.zsh` - Aliases

Raccourcis pratiques pour :
- Navigation (`..`, `...`)
- Git (`gs`, `ga`, `gc`, `gp`)
- Docker (`dc`, `dps`)
- Système (`update`, `install`)
- Flutter (`fl`, `fld`, `flr`)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### `functions.zsh` - Fonctions

Fonctions utiles :
- `mkcd` - Créer dossier et y aller
- `gclone` - Git clone et cd
- `docker-cleanup` - Nettoyage Docker
- `backup` - Backup rapide avec timestamp

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Configuration ZSH : `zshrc`, `.zshrc` et `zshrc_custom`

Le projet utilise trois fichiers différents pour la configuration ZSH :

#### 1. `~/dotfiles/zshrc` (Wrapper à la racine)
- **Rôle** : Wrapper intelligent qui détecte le shell actif (ZSH, Fish, Bash)
- **Fonction** :
  - Détecte automatiquement le shell en cours d'exécution
  - Source la configuration appropriée selon le shell
  - Pour ZSH : source `zsh/zshrc_custom`
  - Pour Fish : affiche un message (config doit être dans `.config/fish/config.fish`)
  - Pour Bash : charge les variables d'environnement et alias compatibles

#### 2. `~/.zshrc` (Symlink dans le HOME)
- **Rôle** : Point d'entrée standard de ZSH (chargé automatiquement au démarrage)
- **Fonction** : Symlink vers `~/dotfiles/zshrc`
- **Création** : Automatique lors de l'installation via `create_symlinks.sh`

#### 3. `~/dotfiles/zsh/zshrc_custom` (Configuration principale)
- **Rôle** : Configuration ZSH complète et principale
- **Contenu** :
  - Chargement des managers (installman, configman, etc.)
  - Variables d'environnement
  - Aliases
  - Fonctions
  - Configuration Powerlevel10k
  - Toute la logique de configuration ZSH

**Flux de chargement :**
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

**Pourquoi cette architecture ?**
1. **Flexibilité multi-shells** : Le wrapper `zshrc` permet de supporter ZSH, Fish et Bash avec un seul symlink
2. **Modularité** : La vraie configuration est dans `zshrc_custom`, facile à modifier
3. **Compatibilité** : ZSH charge automatiquement `~/.zshrc`, donc on utilise un symlink
4. **Centralisation** : Tout est dans `~/dotfiles/` pour faciliter la synchronisation

Voir aussi `docs/architecture/ARCHITECTURE.md` pour plus de détails.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Scripts Docker de test

#### `test-docker.sh` (à la racine)
- **Emplacement** : `~/dotfiles/test-docker.sh` (à la racine du projet)
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

Voir la section [🐳 Docker - Tests dans environnement Docker isolé](#tests-dans-environnement-docker-isolé) pour plus de détails.

---

<!-- =============================================================================
     INSTALLATION COMPLÈTE DU SYSTÈME
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🚨 Troubleshooting

### Flutter pas dans le PATH

Vérifiez que `~/dotfiles/.env` est sourcé dans `.zshrc` et contient :

```bash
export PATH=$PATH:/opt/flutter/bin
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Docker : permission denied

Ajouter votre utilisateur au groupe docker :

```bash
sudo usermod -aG docker $USER
```

Puis redémarrer la session.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### NVIDIA : écran noir au boot

Éditer le fichier GRUB :

```bash
sudo nano /etc/default/grub
```

Ajouter `nomodeset` dans `GRUB_CMDLINE_LINUX_DEFAULT` :

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset"
```

Mettre à jour GRUB :

```bash
sudo update-grub
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Dotfiles non sourcés

Vérifier si dotfiles est sourcé dans `.zshrc` :

```bash
grep "source ~/dotfiles" ~/.zshrc
```

Si absent, relancez `scripts/setup.sh`.

---

<!-- =============================================================================
     WORKFLOW COMPLET (NOUVELLE MACHINE)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

