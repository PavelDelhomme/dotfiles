# Dotfiles - PavelDelhomme

Configuration personnelle pour Manjaro Linux avec installation automatisée complète.

**Version :** 2.10.0

## 📑 Table des matières

- [🚀 Installation rapide (nouvelle machine)](#-installation-rapide-nouvelle-machine)
  - [Installation en une seule commande](#installation-en-une-seule-commande)
  - [Après l'installation](#après-linstallation)
  - [Commandes utiles après installation](#commandes-utiles-après-installation)
  - [Installation manuelle (alternative)](#installation-manuelle-alternative)
- [🔄 Réinstallation](#-réinstallation)
  - [Réinstallation complète (tout réinstaller)](#réinstallation-complète-tout-réinstaller)
  - [Réinstallation partielle (éléments spécifiques)](#réinstallation-partielle-éléments-spécifiques)
  - [Réinstallation automatique (détection et installation)](#réinstallation-automatique-détection-et-installation)
  - [Réinstallation après bootstrap (déjà installé)](#réinstallation-après-bootstrap-déjà-installé)
  - [Réinstallation d'un composant spécifique](#réinstallation-dun-composant-spécifique)
  - [Réinitialisation complète (cas extrême)](#réinitialisation-complète-cas-extrême)
  - [Vérifier l'état après réinstallation](#vérifier-létat-après-réinstallation)
- [📁 Structure du repository](#-structure-du-repository)
- [🔧 Fichiers de configuration](#-fichiers-de-configuration)
  - [`.env` - Variables d'environnement](#env---variables-denvironnement)
  - [`aliases.zsh` - Aliases](#aliaseszsh---aliases)
  - [`functions.zsh` - Fonctions](#functionszsh---fonctions)
- [🖥️ Installation complète du système](#️-installation-complète-du-système)
  - [Gestionnaires de paquets](#gestionnaires-de-paquets)
  - [Applications](#applications)
  - [Environnement de développement](#environnement-de-développement)
  - [Matériel](#matériel)
- [📝 Fonctionnalités intelligentes](#-fonctionnalités-intelligentes)
  - [Vérifications avant installation](#vérifications-avant-installation)
  - [Backup automatique](#backup-automatique)
  - [Mise à jour de Cursor](#mise-à-jour-de-cursor)
- [🎯 Usage quotidien](#-usage-quotidien)
  - [Commandes Makefile (recommandé)](#commandes-makefile-recommandé)
  - [Recharger la configuration](#recharger-la-configuration)
  - [Mettre à jour les dotfiles](#mettre-à-jour-les-dotfiles)
  - [Vérifications système](#vérifications-système)
- [🔐 Configuration GitHub SSH](#-configuration-github-ssh)
- [🐳 Docker](#-docker)
  - [Installation](#installation)
  - [Configuration BuildKit](#configuration-buildkit)
  - [Docker Desktop (optionnel)](#docker-desktop-optionnel)
  - [Login Docker Hub](#login-docker-hub)
  - [Commandes utiles](#commandes-utiles)
- [🔄 Auto-Synchronisation Git](#-auto-synchronisation-git)
  - [Installation](#installation-1)
  - [Fonctionnement](#fonctionnement)
  - [Commandes utiles](#commandes-utiles-1)
  - [Configuration](#configuration)
- [🌐 Brave Browser](#-brave-browser)
  - [Installation](#installation-2)
  - [Support](#support)
- [📊 Options principales du menu (setup.sh)](#-options-principales-du-menu-setupsh)
  - [Installation & Détection (50-53)](#installation--détection-50-53)
  - [Désinstallation individuelle (60-70)](#désinstallation-individuelle-60-70)
  - [Autres options importantes](#autres-options-importantes)
- [📝 Système de logs d'installation](#-système-de-logs-dinstallation)
- [📦 Scripts Modulaires](#-scripts-modulaires)
  - [Tableau des scripts](#tableau-des-scripts)
- [✅ Validation du Setup](#-validation-du-setup)
  - [Utilisation](#utilisation)
  - [Vérifications effectuées (117+ vérifications)](#vérifications-effectuées-117-vérifications)
  - [Rapport](#rapport)
- [📱 Flutter & Android](#-flutter--android)
  - [Variables d'environnement (dans `.env`)](#variables-denvironnement-dans-env)
  - [Première utilisation](#première-utilisation)
- [🎮 NVIDIA RTX 3060](#-nvidia-rtx-3060)
  - [Configuration automatique](#configuration-automatique)
  - [Vérifications](#vérifications)
  - [Important](#important)
- [🛠️ Maintenance](#️-maintenance)
  - [Mettre à jour le système](#mettre-à-jour-le-système)
  - [Nettoyer Docker](#nettoyer-docker)
  - [Mettre à jour Cursor](#mettre-à-jour-cursor)
- [📦 Structure recommandée après installation](#-structure-recommandée-après-installation)
- [🚨 Troubleshooting](#-troubleshooting)
  - [Flutter pas dans le PATH](#flutter-pas-dans-le-path)
  - [Docker : permission denied](#docker--permission-denied)
  - [NVIDIA : écran noir au boot](#nvidia--écran-noir-au-boot)
  - [Dotfiles non sourcés](#dotfiles-non-sourcés)
- [🔄 Workflow complet (nouvelle machine)](#-workflow-complet-nouvelle-machine)
  - [Méthode automatique (recommandée)](#méthode-automatique-recommandée)
  - [Dans le menu scripts/setup.sh](#dans-le-menu-scriptssetupsh)
  - [Après installation](#après-installation)
- [🔄 Rollback / Désinstallation](#-rollback--désinstallation)
  - [Rollback complet (tout désinstaller)](#rollback-complet-tout-désinstaller)
  - [Rollback Git uniquement](#rollback-git-uniquement)
  - [Rollback Git manuel](#rollback-git-manuel)
- [🖥️ Gestion des VM (Tests en environnement isolé)](#️-gestion-des-vm-tests-en-environnement-isolé)
  - [Installation QEMU/KVM](#installation-qemukvm)
  - [Utilisation rapide](#utilisation-rapide)
  - [Workflow de test recommandé](#workflow-de-test-recommandé)
  - [Commandes Makefile disponibles](#commandes-makefile-disponibles)
  - [Avantages](#avantages)
  - [Documentation complète](#documentation-complète)
- [📄 Licence](#-licence)
- [👤 Auteur](#-auteur)

---

<!-- =============================================================================
     INSTALLATION RAPIDE (NOUVELLE MACHINE)
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🚀 Installation rapide (nouvelle machine)

### Installation en une seule commande

**UNE SEULE LIGNE** pour tout installer et configurer :

Méthode 1 : Pipe (peut avoir des problèmes dans certains environnements)
```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Méthode 2 : Process substitution (recommandé si méthode 1 ne fonctionne pas)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
```

Méthode 3 : Téléchargement puis exécution (si les deux autres ne fonctionnent pas)
```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh
```

**📝 Note importante sur le fichier `.env` :**

Le fichier `.env` permet d'éviter de saisir vos informations Git à chaque installation. Cependant, **vous ne pouvez le créer qu'APRÈS avoir cloné le repository** (étape 4). 

Si vous voulez créer le fichier `.env` pour éviter les questions interactives lors des prochaines installations, vous pourrez le faire après le clonage :

```bash
cd ~/dotfiles
cp .env.example .env
nano .env  # ou votre éditeur préféré (vim, code, etc.)
```

Voir [Configuration Git via .env](#configuration-git-via-env) pour plus de détails.

**🔄 Processus d'installation automatique :**

Cette commande va automatiquement exécuter les étapes suivantes :

**1. Vérification et installation de Git**
- Détection automatique du gestionnaire de paquets (pacman/apt/dnf)
- Installation automatique si Git n'est pas présent

**2. Configuration Git (nom et email)** ⚠️ **INTERACTIF**
- **Si Git est déjà configuré** : Utilise la configuration existante (aucune demande)
- **Si le fichier `.env` existe** (après le clonage) : Charge `GIT_USER_NAME` et `GIT_USER_EMAIL` depuis `.env`
- **Sinon, le script vous demandera interactivement** :
  ```
  Configuration Git nécessaire
  Aucune information personnelle ne sera utilisée par défaut
  
  Nom Git (obligatoire): 
  ```
  ⚠️ **Explication : Nom Git**
  - C'est le **nom qui apparaîtra dans vos commits Git** (visible dans `git log`, GitHub, GitLab, etc.)
  - Exemples : `PavelDelhomme`, `Jean Dupont`, `John Doe`
  - Ce nom sera utilisé pour identifier l'auteur de vos commits
  - Vous pouvez utiliser votre vrai nom, un pseudonyme, ou votre nom d'utilisateur GitHub
  
  ```
  Email Git (obligatoire): 
  ```
  ⚠️ **Explication : Email Git**
  - C'est l'**adresse email associée à votre compte GitHub/GitLab**
  - Cette email doit correspondre à celle de votre compte GitHub/GitLab pour que vos commits soient liés à votre profil
  - Exemples : `dev@delhomme.ovh`, `votre.email@example.com`, `username@users.noreply.github.com`
  - ⚠️ **Important** : Si vous utilisez GitHub, vous pouvez utiliser l'email `username@users.noreply.github.com` pour garder votre email privé (visible dans les paramètres GitHub)
  - Validation automatique du format d'email
- Configuration du credential helper (cache pour 15 minutes)

**3. Génération clé SSH ED25519** (si absente) ⚠️ **INTERACTIF**
- Utilise l'email Git configuré précédemment pour la clé
- Copie la clé publique dans le presse-papier automatiquement
- **Ouvre GitHub dans le navigateur** pour que vous ajoutiez la clé SSH
- ⚠️ **Action requise** : Vous devez copier la clé SSH dans votre compte GitHub
  - Aller dans GitHub → Settings → SSH and GPG keys → New SSH key
  - Coller la clé publique
- Test de la connexion GitHub SSH (`ssh -T git@github.com`)

**4. Clonage ou mise à jour du repository dotfiles**
- Cloner dans `~/dotfiles` si inexistant
- Mettre à jour (`git pull`) si repo existe déjà
- Support des variables d'environnement `.env` (GITHUB_REPO_URL)
- Utilise l'URL par défaut si `.env` non configuré
- Si le dossier existe mais n'est pas un repo Git, demande confirmation pour le supprimer

**5. Choix du shell** (Zsh/Fish/Les deux) ⚠️ **INTERACTIF**
- Menu interactif :
  ```
  Quel shell souhaitez-vous configurer?
    1. Zsh (recommandé)
    2. Fish
    3. Les deux (Fish et Zsh)
    0. Passer cette étape
  ```
- Sélection du shell à configurer
- Support de plusieurs shells simultanés
- Passage de la sélection au menu `setup.sh`

**6. Création des symlinks** (si demandé) ⚠️ **INTERACTIF**
- Demande : `Créer les symlinks pour centraliser la configuration? (o/n)`
- Centralisation de la configuration
- Backup automatique des fichiers existants
- Création selon le shell sélectionné

**7. Lancement automatique du menu interactif d'installation**
- Menu `scripts/setup.sh` avec toutes les options
- État de l'installation affiché en haut du menu
- Variable `SELECTED_SHELL_FOR_SETUP` passée au menu

**📋 Ce que vous devez savoir avant de lancer la commande :**

1. ✅ **Nom Git** : Le nom qui apparaîtra dans vos commits Git
   - Exemples : `PavelDelhomme`, `Jean Dupont`, `John Doe`
   - Ce nom sera visible dans l'historique Git et sur GitHub/GitLab
   - Vous pouvez utiliser votre vrai nom, un pseudonyme, ou votre nom d'utilisateur GitHub

2. ✅ **Email Git** : L'email associé à votre compte GitHub/GitLab
   - Exemples : `dev@delhomme.ovh`, `votre.email@example.com`
   - ⚠️ **Important** : Cette email doit correspondre à celle de votre compte GitHub/GitLab
   - Pour GitHub, vous pouvez utiliser `username@users.noreply.github.com` pour garder votre email privé (visible dans GitHub → Settings → Emails)

3. ✅ **Accès GitHub** : Vous devrez ajouter la clé SSH manuellement sur GitHub
   - Le script ouvrira automatiquement GitHub dans votre navigateur
   - Vous devrez copier la clé SSH affichée et l'ajouter dans GitHub → Settings → SSH and GPG keys

4. ⚙️ **Optionnel** : Après le clonage, vous pourrez créer le fichier `.env` pour éviter les saisies lors des prochaines installations (voir [Configuration Git via .env](#configuration-git-via-env)).

Le menu interactif affiche :
- 📊 **L'état actuel de votre installation** (ce qui est installé, ce qui manque)
- 🎯 **Toutes les options disponibles** pour installer/configurer (50-70+ options)
- ✅ **Indications claires** sur quelle option choisir pour chaque composant
- 📋 **Logs d'installation** pour tracer toutes les actions

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Après l'installation

Une fois le menu lancé, vous pouvez :
- **Option 50** : Afficher ce qui manque (état détaillé, scrollable)
- **Option 51** : Installer éléments manquants un par un (menu interactif)
- **Option 52** : Installer tout ce qui manque automatiquement
- **Option 53** : Afficher logs d'installation (voir ce qui a été fait, quand, pourquoi)
- Choisir les options que vous voulez installer (1-27)
- Désinstaller individuellement (options 60-70)
- Utiliser l'option **23** pour valider complètement votre setup (validation exhaustive 117+ vérifications)
- Utiliser l'option **28** pour restaurer depuis Git (annuler modifications locales)
- Utiliser l'option **0** pour quitter (vous pouvez relancer `cd ~/dotfiles && bash scripts/setup.sh` plus tard)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Commandes utiles après installation

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Relancer le menu interactif :

```bash
bash scripts/setup.sh
```

Alternative avec Makefile :

```bash
make setup
```

Valider le setup complet :

```bash
make validate
```

Voir toutes les commandes disponibles :

```bash
make help
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Installation manuelle (alternative)

Installer git :

```bash
sudo pacman -S git
```

Cloner ce repo :

```bash
git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles
```

Aller dans le dossier dotfiles et lancer le setup :

```bash
cd ~/dotfiles
```

Lancer le setup :

```bash
bash scripts/setup.sh
```

Le script `scripts/setup.sh` propose un menu interactif avec toutes les options d'installation.

---

<!-- =============================================================================
     RÉINSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔄 Réinstallation

Différentes méthodes pour réinstaller les dotfiles selon votre situation.

### Réinstallation complète (tout réinstaller)

**Si vous voulez tout désinstaller puis tout réinstaller depuis zéro :**

```bash
bash ~/dotfiles/scripts/uninstall/reset_all.sh
```

Cette commande va :
1. Désinstaller tous les composants (Git config, paquets, applications, etc.)
2. Supprimer le dossier dotfiles (si confirmé)
3. Proposer de réinstaller automatiquement via bootstrap.sh

**Ou manuellement :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le rollback complet (option 98 du menu) :

```bash
bash scripts/setup.sh
# Choisir option 98
```

Puis réinstaller :

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Réinstallation partielle (éléments spécifiques)

**Si vous voulez réinstaller seulement certains éléments :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le menu interactif :

```bash
bash scripts/setup.sh
```

Puis choisir les options correspondantes :
- **Option 1** : Réinstaller configuration Git
- **Option 3** : Réinstaller paquets de base
- **Option 8** : Réinstaller Cursor
- **Option 15** : Réinstaller Docker
- **Option 17** : Réinstaller Brave Browser
- **Option 19** : Réinstaller Go
- **Option 24** : Recréer les symlinks

**Ou directement les scripts d'installation :**

```bash
# Réinstaller Cursor
bash scripts/install/apps/install_cursor.sh

# Réinstaller Docker
bash scripts/install/dev/install_docker.sh

# Réinstaller Brave
bash scripts/install/apps/install_brave.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Réinstallation automatique (détection et installation)

**Si vous voulez réinstaller automatiquement tout ce qui manque :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le menu interactif :

```bash
bash scripts/setup.sh
```

Choisir **Option 52** : Installer tout ce qui manque (automatique)

**Ou installer éléments manquants un par un (Option 51)** pour un contrôle plus précis.

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Réinstallation après bootstrap (déjà installé)

**Si vous avez déjà exécuté bootstrap.sh mais que le projet n'est pas complet :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Mettre à jour le repository :

```bash
git pull
```

Relancer le menu interactif :

```bash
bash scripts/setup.sh
```

Utiliser :
- **Option 50** : Voir ce qui manque
- **Option 51** : Installer éléments manquants un par un
- **Option 52** : Installer tout ce qui manque automatiquement
- **Option 23** : Valider complètement le setup (détecte les problèmes)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Réinstallation d'un composant spécifique

**Désinstaller puis réinstaller un composant :**

Exemple pour Docker :

Désinstaller Docker :

```bash
bash ~/dotfiles/scripts/uninstall/uninstall_docker.sh
```

Réinstaller Docker :

```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh
```

**Ou via le menu (Options 60-70 pour désinstaller, puis 1-27 pour installer).**

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Réinitialisation complète (cas extrême)

**Si vous avez des problèmes graves et voulez repartir de zéro :**

```bash
bash ~/dotfiles/scripts/uninstall/reset_all.sh
```

Cette commande va :
1. Tout désinstaller
2. Supprimer le dossier dotfiles
3. Nettoyer la configuration Git
4. Supprimer les clés SSH
5. Arrêter les services systemd
6. Supprimer les symlinks
7. Nettoyer `.zshrc` (si confirmé)

Puis proposer de réinstaller automatiquement.

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Vérifier l'état après réinstallation

Après une réinstallation, valider le setup :

```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

Ou via le menu (Option 23) pour un rapport détaillé.

---

<!-- =============================================================================
     STRUCTURE DU REPOSITORY
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📁 Structure du repository

Voir `STRUCTURE.md` pour la structure complète et détaillée.

Structure principale :
```
~/dotfiles/
├── bootstrap.sh                 # Installation en une ligne (curl)
├── zsh/
│   ├── zshrc_custom            # Configuration ZSH principale
│   ├── env.sh                  # Variables d'environnement
│   ├── aliases.zsh             # Aliases personnalisés
│   └── functions/              # Fonctions shell
│       ├── *man.zsh            # Gestionnaires (pathman, aliaman, etc.)
│       └── **/*.sh             # Fonctions individuelles
└── scripts/
    ├── config/                 # Configurations unitaires
    ├── install/                # Scripts d'installation
    ├── sync/                   # Auto-sync Git
    ├── test/                   # Validation & tests
    └── vm/                     # Gestion VM
```

---

<!-- =============================================================================
     FICHIERS DE CONFIGURATION
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔧 Fichiers de configuration

### Configuration Git via .env

**📝 IMPORTANT : Le fichier `.env` se crée APRÈS le clonage du repository**

Le fichier `.env` permet de stocker vos informations personnelles de manière sécurisée (jamais commité dans Git) pour éviter de les saisir à chaque installation.

**⚠️ Note :** Vous ne pouvez créer le fichier `.env` qu'**après avoir cloné le repository** (étape 4 du processus d'installation). Lors de la première installation avec `curl ... | bash`, le script vous demandera interactivement vos informations.

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### `functions.zsh` - Fonctions

Fonctions utiles :
- `mkcd` - Créer dossier et y aller
- `gclone` - Git clone et cd
- `docker-cleanup` - Nettoyage Docker
- `backup` - Backup rapide avec timestamp

---

<!-- =============================================================================
     INSTALLATION COMPLÈTE DU SYSTÈME
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🖥️ Installation complète du système

Le script `scripts/setup.sh` (menu interactif) permet d'installer et configurer automatiquement :

### Gestionnaires de paquets
- ✅ yay (AUR helper)
- ✅ snap
- ✅ flatpak + flathub

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Applications
- ✅ Brave Browser
- ✅ Cursor IDE (AppImage + .desktop)
- ✅ Discord
- ✅ KeePassXC
- ✅ Docker & Docker Compose (optimisé BuildKit)
- ✅ Proton Mail & Proton Pass
- ✅ PortProton (jeux Windows)
- ✅ Session Desktop

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Environnement de développement
- ✅ Flutter SDK
- ✅ Android Studio & SDK
- ✅ Node.js & npm
- ✅ Git & GitHub SSH
- ✅ Outils de build (make, cmake, gcc)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Matériel
- ✅ Pilotes NVIDIA RTX 3060
- ✅ Configuration Xorg pour GPU principal
- ✅ nvidia-prime pour gestion hybride

---

<!-- =============================================================================
     FONCTIONNALITÉS INTELLIGENTES
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📝 Fonctionnalités intelligentes

### Vérifications avant installation
Le script vérifie **toujours** si un paquet est déjà installé avant de l'installer :
- Évite les installations redondantes
- Messages clairs (installé/ignoré)
- Gère les conflits automatiquement

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Backup automatique
Lors du setup, les fichiers de config existants sont sauvegardés dans :
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Mise à jour de Cursor
Un script dédié est créé :
```bash
update-cursor.sh
```

---

<!-- =============================================================================
     USAGE QUOTIDIEN
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Recharger la configuration

Méthode 1 :

```bash
source ~/.zshrc
```

Méthode 2 :

```bash
exec zsh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Vérifications système
```bash
flutter doctor          # Flutter
docker --version        # Docker
nvidia-smi             # NVIDIA
android-studio         # Android Studio
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔐 Configuration GitHub SSH

Le script génère automatiquement une clé SSH ED25519 et :
1. Copie la clé publique dans le presse-papier
2. Attend que vous l'ajoutiez sur GitHub
3. Teste la connexion

Clé stockée dans : `~/.ssh/id_ed25519`

---

<!-- =============================================================================
     DOCKER
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🐳 Docker

### Installation

Installation complète via le menu scripts/setup.sh (option 15) :
- Docker Engine
- Docker Compose
- BuildKit activé par défaut
- Groupe docker configuré
- Login Docker Hub avec support 2FA

```bash
# Via le menu
bash ~/dotfiles/scripts/setup.sh
# Choisir option 15

# Ou directement
bash ~/dotfiles/scripts/install/dev/install_docker.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Configuration BuildKit

BuildKit est automatiquement activé dans `~/.docker/daemon.json` :
```json
{
  "features": {
    "buildkit": true
  }
}
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Docker Desktop (optionnel)

Installation via option 16 du menu ou :
```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh --desktop-only
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Login Docker Hub

Le script propose automatiquement de se connecter à Docker Hub :
- Support 2FA (utilisez un Personal Access Token)
- Génération de token : https://hub.docker.com/settings/security

```bash
docker login
# Test avec
docker run hello-world
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Commandes utiles

```bash
docker --version              # Vérifier la version
docker ps                     # Lister les conteneurs
docker-compose up             # Lancer avec docker-compose
docker compose up             # Lancer avec docker compose (plugin)
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔄 Auto-Synchronisation Git

Système de synchronisation automatique des dotfiles toutes les heures via systemd timer.

### Installation

Via le menu scripts/setup.sh (option 12) ou directement :
```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Fonctionnement

- **Timer systemd** : Exécution toutes les heures
- **Pull automatique** : Récupère les modifications distantes
- **Push automatique** : Envoie les modifications locales (si changements)
- **Logs** : Disponibles dans `~/dotfiles/logs/auto_sync.log`

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Commandes utiles

```bash
# Vérifier le statut
systemctl --user status dotfiles-sync.timer

# Voir tous les timers
systemctl --user list-timers

# Arrêter/Démarrer le timer
systemctl --user stop dotfiles-sync.timer
systemctl --user start dotfiles-sync.timer

# Voir les logs
journalctl --user -u dotfiles-sync.service

# Tester manuellement
bash ~/dotfiles/scripts/sync/git_auto_sync.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Configuration

Le timer est configuré pour :
- Démarrer 5 minutes après le boot
- S'exécuter toutes les heures
- Précision de 1 minute

---

<!-- =============================================================================
     BRAVE BROWSER
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🌐 Brave Browser

Installation optionnelle du navigateur Brave.

### Installation

Via le menu scripts/setup.sh (option 17) ou directement :
```bash
bash ~/dotfiles/scripts/install/apps/install_brave.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Support

- **Arch Linux** : Installation via yay (brave-bin)
- **Debian/Ubuntu** : Dépôt officiel Brave
- **Fedora** : Dépôt officiel Brave
- **Autres** : Installation manuelle ou Flatpak

---

<!-- =============================================================================
     OPTIONS PRINCIPALES DU MENU (SETUP.SH)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📊 Options principales du menu (setup.sh)

### Installation & Détection (50-53)
- **50** : Afficher ce qui manque (état, scrollable via less)
- **51** : Installer éléments manquants (un par un, menu interactif)
- **52** : Installer tout ce qui manque (automatique, avec logs)
- **53** : Afficher logs d'installation (filtres, statistiques, scrollable)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Désinstallation individuelle (60-70)
- **60** : Désinstaller configuration Git
- **61** : Désinstaller configuration remote Git
- **62** : Désinstaller paquets de base
- **63** : Désinstaller gestionnaires de paquets (yay, snap, flatpak)
- **64** : Désinstaller Brave Browser
- **65** : Désinstaller Cursor IDE
- **66** : Désinstaller Docker & Docker Compose
- **67** : Désinstaller Go (Golang)
- **68** : Désinstaller yay (AUR helper)
- **69** : Désinstaller auto-sync Git
- **70** : Désinstaller symlinks

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Autres options importantes
- **23** : Validation complète du setup (117+ vérifications exhaustives)
- **28** : Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés)
- **26-27** : Migration shell (Fish ↔ Zsh), Changer shell par défaut

---

<!-- =============================================================================
     SYSTÈME DE LOGS D'INSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📝 Système de logs d'installation

Toutes les installations et configurations sont automatiquement tracées dans `~/dotfiles/logs/install.log` :

- ✅ **Format** : `[timestamp] [action] [status] component | details`
- ✅ **Actions tracées** : install, config, uninstall, test, run
- ✅ **Statuts** : success, failed, skipped, info
- ✅ **Navigation** : Pagination via less, filtres par action/composant
- ✅ **Statistiques** : Total, réussies, échouées, ignorées

Consulter les logs via **Option 53** du menu ou directement :
```bash
less ~/dotfiles/logs/install.log
```

---

<!-- =============================================================================
     SCRIPTS MODULAIRES
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📦 Scripts Modulaires

Structure organisée des scripts dans `scripts/` :

```
scripts/
├── config/              # Configurations unitaires
│   ├── git_config.sh     # Config Git (nom, email)
│   ├── git_remote.sh     # Remote GitHub (SSH/HTTPS)
│   ├── qemu_packages.sh  # Installation paquets QEMU
│   ├── qemu_network.sh   # Configuration réseau NAT
│   └── qemu_libvirt.sh   # Configuration permissions libvirt
│
├── install/              # Scripts d'installation
│   ├── system/          # Paquets système
│   ├── apps/            # Applications utilisateur
│   │   ├── install_brave.sh         # Brave Browser
│   │   ├── install_cursor.sh         # Cursor IDE
│   │   └── install_portproton.sh     # PortProton
│   ├── dev/             # Outils de développement
│   │   ├── install_docker.sh         # Docker & Docker Compose
│   │   ├── install_docker_tools.sh   # Outils build (Arch)
│   │   └── install_go.sh             # Go (Golang)
│   └── tools/           # Outils système
│       └── install_yay.sh            # yay (AUR helper)
│
├── sync/                # Synchronisation Git
│   ├── git_auto_sync.sh         # Script de synchronisation
│   ├── install_auto_sync.sh     # Installation systemd timer
│   └── restore_from_git.sh      # Restaurer depuis Git (option 28)
│
├── test/                 # Validation & tests
│   └── validate_setup.sh         # Validation complète (117+ vérifications)
│
├── lib/                  # Bibliothèques communes
│   ├── common.sh                # Fonctions communes (logging, couleurs)
│   ├── install_logger.sh        # Système de logs d'installation
│   └── check_missing.sh         # Détection éléments manquants
│
├── uninstall/            # Désinstallation individuelle
│   ├── uninstall_git_config.sh  # Désinstaller config Git
│   ├── uninstall_brave.sh       # Désinstaller Brave
│   ├── uninstall_cursor.sh      # Désinstaller Cursor
│   ├── uninstall_docker.sh      # Désinstaller Docker
│   ├── uninstall_go.sh          # Désinstaller Go
│   ├── uninstall_yay.sh         # Désinstaller yay
│   ├── uninstall_auto_sync.sh   # Désinstaller auto-sync
│   └── uninstall_symlinks.sh    # Désinstaller symlinks
│
└── vm/                   # Gestion VM
    └── create_test_vm.sh          # Création VM de test
```

### Tableau des scripts

| Fichier | Description | Usage |
|---------|-------------|-------|
| `apps/install_brave.sh` | Installation Brave Browser | Option 17 du menu |
| `apps/install_cursor.sh` | Installation Cursor IDE | Option 8 du menu |
| `apps/install_portproton.sh` | Installation PortProton | Option 9 du menu |
| `dev/install_docker.sh` | Installation Docker complet | Option 15 du menu |
| `dev/install_docker_tools.sh` | Outils build (make, gcc, cmake) | Arch Linux uniquement |
| `dev/install_go.sh` | Installation Go (Golang) | Option 19 du menu |
| `tools/install_yay.sh` | Installation yay AUR helper | Option 18 du menu |
| `test/validate_setup.sh` | Validation complète | Option 22 du menu |

---

<!-- =============================================================================
     VALIDATION DU SETUP
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## ✅ Validation du Setup

Script de validation complète pour vérifier toutes les installations et configurations.

### Utilisation

Via le menu scripts/setup.sh (option 23) ou directement :
```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Vérifications effectuées (117+ vérifications)

**Structure dotfiles** :
- ✅ Fichiers racine (bootstrap.sh, Makefile, README.md, zshrc)
- ✅ Fichiers documentation (docs/STATUS.md, docs/STRUCTURE.md)
- ✅ Scripts (scripts/setup.sh, scripts/*)
- ✅ Bibliothèque commune (lib/common.sh, lib/install_logger.sh, lib/check_missing.sh)
- ✅ Structure ZSH/Fish complète (zshrc_custom, env.sh, aliases.zsh, path_log.txt, PATH_SAVE)

**Scripts** :
- ✅ Scripts d'installation (12 scripts : packages_base, install_docker, install_go, etc.)
- ✅ Scripts configuration (6 scripts : git_config, create_symlinks, qemu_*, etc.)
- ✅ Scripts synchronisation (3 scripts : git_auto_sync, install_auto_sync, restore_from_git)
- ✅ Scripts désinstallation (13 scripts : uninstall_*, rollback_*, reset_all)

**Fonctions ZSH** :
- ✅ Gestionnaires (6 : pathman, netman, aliaman, miscman, searchman, cyberman)
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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Rapport

Le script affiche un rapport avec :
- ✅ Réussis (vert)
- ❌ Échecs (rouge)
- ⚠️ Avertissements (jaune)

---

<!-- =============================================================================
     FLUTTER & ANDROID
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📱 Flutter & Android

### Variables d'environnement (dans `.env`)

Définir JAVA_HOME :

```bash
export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
```

Définir ANDROID_SDK_ROOT :

```bash
export ANDROID_SDK_ROOT='/opt/android-sdk'
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Première utilisation

Vérifier l'installation Flutter :

```bash
flutter doctor
```

Premier lancement d'Android Studio pour configurer le SDK :

```bash
android-studio
```

---

<!-- =============================================================================
     NVIDIA RTX 3060
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🎮 NVIDIA RTX 3060

### Configuration automatique
- Pilotes propriétaires installés
- Xorg configuré (PrimaryGPU)
- GRUB optimisé (nomodeset)
- nvidia-prime installé

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Vérifications

Vérifier l'état du GPU :

```bash
nvidia-smi
```

Forcer une application à utiliser NVIDIA :

```bash
prime-run <app>
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Important
1. Branchez l'écran sur la **carte NVIDIA** (pas carte mère)
2. Dans le BIOS : `Primary Display` = `PCI-E` ou `Discrete`
3. Redémarrez après installation

---

<!-- =============================================================================
     MAINTENANCE
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Nettoyer Docker

Nettoyer Docker :

```bash
docker-cleanup
```

---

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Mettre à jour Cursor

Mettre à jour Cursor :

```bash
update-cursor.sh
```

---

<!-- =============================================================================
     STRUCTURE RECOMMANDÉE APRÈS INSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🚨 Troubleshooting

### Flutter pas dans le PATH

Vérifiez que `~/dotfiles/.env` est sourcé dans `.zshrc` et contient :

```bash
export PATH=$PATH:/opt/flutter/bin
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Docker : permission denied

Ajouter votre utilisateur au groupe docker :

```bash
sudo usermod -aG docker $USER
```

Puis redémarrer la session.

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔄 Workflow complet (nouvelle machine)

### Méthode automatique (recommandée)

**Une seule commande** pour tout faire :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Cette commande fait automatiquement :
1. ✅ Installation Git (si nécessaire)
2. ✅ Configuration Git (nom, email, credential helper)
3. ✅ Génération clé SSH ED25519 (si absente)
4. ✅ Test connexion GitHub SSH (`ssh -T git@github.com`)
5. ✅ Clone repository dotfiles (ou `git pull` si existe déjà)
6. ✅ Choix du shell (Zsh/Fish/Les deux)
7. ✅ Création symlinks (optionnel)
8. ✅ Lancement menu interactif `scripts/setup.sh`

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Dans le menu scripts/setup.sh

1. **Voir ce qui manque** : Option 50
2. **Installer individuellement** : Option 51 (un par un) ou Option 52 (tout automatique)
3. **Suivre les logs** : Option 53 pour voir ce qui est fait
4. **Valider installation** : Option 23 (validation exhaustive)
5. **Configurer auto-sync** : Option 12 (synchronisation automatique Git)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Après installation

- **Redémarrer** pour appliquer toutes les configurations
- **Vérifications** : `flutter doctor`, `docker login`, `nvidia-smi`
- **Configuration apps** : Cursor login, Proton Pass
- **Consulter logs** : Option 53 ou `less ~/dotfiles/logs/install.log`

---

<!-- =============================================================================
     ROLLBACK / DÉSINSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🔄 Rollback / Désinstallation

### Rollback complet (tout désinstaller)

Pour désinstaller **TOUT** ce qui a été installé et configuré :

**Via le menu setup.sh :**

Lancer le menu :

```bash
bash ~/dotfiles/scripts/setup.sh
```

Choisir option 99.

**Ou directement :**

```bash
bash ~/dotfiles/scripts/uninstall/rollback_all.sh
```

Le script va :
- ✅ Arrêter et supprimer les services systemd (auto-sync)
- ✅ Désinstaller toutes les applications (Docker, Cursor, Brave, Go, yay, etc.)
- ✅ Supprimer la configuration Git
- ✅ Supprimer les clés SSH (avec confirmation)
- ✅ Nettoyer la configuration ZSH
- ✅ Supprimer le dossier dotfiles (avec confirmation)
- ✅ Nettoyer les logs et fichiers temporaires
- ✅ Option rollback Git vers version précédente

**⚠️ Double confirmation requise** : Taper "OUI" en majuscules pour confirmer.

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Rollback Git uniquement

Pour revenir à une version précédente des dotfiles (sans désinstaller les applications) :

```bash
bash ~/dotfiles/scripts/uninstall/rollback_git.sh
```

Options disponibles :
- Revenir au commit précédent (HEAD~1)
- Revenir à un commit spécifique (par hash)
- Revenir à origin/main (dernière version distante)

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Rollback Git manuel

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Voir les commits :

```bash
git log --oneline -10
```

Revenir à un commit :

```bash
git reset --hard <commit_hash>
```

Ou revenir à la version distante :

```bash
git reset --hard origin/main
```

---

<!-- =============================================================================
     GESTION DES VM (TESTS EN ENVIRONNEMENT ISOLÉ)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 🖥️ Gestion des VM (Tests en environnement isolé)

Système complet de gestion de VM en ligne de commande pour tester les dotfiles dans un environnement complètement isolé.

### Installation QEMU/KVM

Via le menu `scripts/setup.sh` (option 11) ou directement :
```bash
bash ~/dotfiles/scripts/install/tools/install_qemu_full.sh
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Utilisation rapide

**Via Makefile (recommandé) :**
```bash
# Menu interactif
make vm-menu

# Créer une VM de test
make vm-create VM=test-dotfiles MEMORY=2048 VCPUS=2 DISK=20

# Démarrer la VM
make vm-start VM=test-dotfiles

# Créer un snapshot avant test
make vm-snapshot VM=test-dotfiles NAME=clean DESC="Installation propre"

# Tester les dotfiles dans la VM
make vm-test VM=test-dotfiles

# Si problème, rollback
make vm-rollback VM=test-dotfiles SNAPSHOT=clean
```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Workflow de test recommandé

1. **Créer la VM :**
   ```bash
   make vm-create VM=test-dotfiles MEMORY=2048 VCPUS=2 DISK=20
   ```

2. **Démarrer et installer OS :**
   ```bash
   make vm-start VM=test-dotfiles
   virt-viewer test-dotfiles  # Installer une distribution Linux
   ```

3. **Créer snapshot "clean" après installation :**
   ```bash
   make vm-snapshot VM=test-dotfiles NAME=clean DESC="Installation propre"
   ```

4. **Tester les dotfiles :**
   ```bash
   make vm-test VM=test-dotfiles
   ```
   Dans la VM, exécutez :
   ```bash
   curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
   ```

5. **Si problème, rollback rapide :**
   ```bash
   make vm-rollback VM=test-dotfiles SNAPSHOT=clean
   ```

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Commandes Makefile disponibles

| Commande | Description |
|----------|-------------|
| `make vm-menu` | Menu interactif de gestion des VM |
| `make vm-list` | Lister toutes les VM |
| `make vm-create` | Créer une VM (VM=name MEMORY=2048 VCPUS=2 DISK=20 ISO=path) |
| `make vm-start` | Démarrer une VM (VM=name) |
| `make vm-stop` | Arrêter une VM (VM=name) |
| `make vm-info` | Afficher infos d'une VM (VM=name) |
| `make vm-snapshot` | Créer snapshot (VM=name NAME=snap DESC="desc") |
| `make vm-snapshots` | Lister snapshots (VM=name) |
| `make vm-rollback` | Restaurer snapshot (VM=name SNAPSHOT=name) |
| `make vm-test` | Tester dotfiles dans VM (VM=name) |
| `make vm-delete` | Supprimer une VM (VM=name) |

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Avantages

- ✅ **100% en ligne de commande** : Pas besoin de virt-manager GUI
- ✅ **Tests en environnement isolé** : Votre machine reste propre
- ✅ **Rollback rapide** : Snapshots pour revenir en arrière instantanément
- ✅ **Workflow automatisé** : `make vm-test` gère tout automatiquement
- ✅ **Intégration Makefile** : Commandes simples et mémorisables

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

### Documentation complète

Voir `scripts/vm/README.md` pour la documentation complète avec tous les exemples.

---

<!-- =============================================================================
     LICENCE & AUTEUR
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles---paveldelhomme)

## 📄 Licence

Configuration personnelle - libre d'utilisation et modification.

[🔝 Retour en haut](#dotfiles---paveldelhomme)

## 👤 Auteur

**PavelDelhomme**
- GitHub: [@PavelDelhomme](https://github.com/PavelDelhomme)

---

*Dernière mise à jour : Décembre 2024*
[🔝 Retour en haut](#dotfiles---paveldelhomme)