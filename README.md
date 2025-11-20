# Dotfiles - PavelDelhomme

Configuration personnelle pour Manjaro Linux avec installation automatisée complète.

**Version :** 2.10.0

## 📑 Table des matières

- [🚀 Installation rapide (nouvelle machine)](#installation-rapide-nouvelle-machine)
  - [Installation en une seule commande](#installation-en-une-seule-commande)
  - [Après l'installation](#après-linstallation)
  - [Commandes utiles après installation](#commandes-utiles-après-installation)
  - [Installation manuelle (alternative)](#installation-manuelle-alternative)
- [🔄 Réinstallation](#réinstallation)
  - [Réinstallation complète (tout réinstaller)](#réinstallation-complète-tout-réinstaller)
  - [Réinstallation partielle (éléments spécifiques)](#réinstallation-partielle-éléments-spécifiques)
  - [Réinstallation automatique (détection et installation)](#réinstallation-automatique-détection-et-installation)
  - [Réinstallation après bootstrap (déjà installé)](#réinstallation-après-bootstrap-déjà-installé)
  - [Réinstallation d'un composant spécifique](#réinstallation-dun-composant-spécifique)
  - [Réinitialisation complète (cas extrême)](#réinitialisation-complète-cas-extrême)
  - [Vérifier l'état après réinstallation](#vérifier-létat-après-réinstallation)
- [📁 Structure du repository](#structure-du-repository)
- [🔧 Fichiers de configuration](#fichiers-de-configuration)
  - [`.env` - Variables d'environnement](#env---variables-denvironnement)
  - [`aliases.zsh` - Aliases](#aliaseszsh---aliases)
  - [`functions.zsh` - Fonctions](#functionszsh---fonctions)
- [🖥️ Installation complète du système](#installation-complète-du-système)
  - [Gestionnaires de paquets](#gestionnaires-de-paquets)
  - [Applications](#applications)
  - [Environnement de développement](#environnement-de-développement)
  - [Matériel](#matériel)
- [📝 Fonctionnalités intelligentes](#fonctionnalités-intelligentes)
  - [Vérifications avant installation](#vérifications-avant-installation)
  - [Backup automatique](#backup-automatique)
  - [Mise à jour de Cursor](#mise-à-jour-de-cursor)
- [🎯 Usage quotidien](#usage-quotidien)
  - [Commandes Makefile (recommandé)](#commandes-makefile-recommandé)
  - [Recharger la configuration](#recharger-la-configuration)
  - [Mettre à jour les dotfiles](#mettre-à-jour-les-dotfiles)
  - [Vérifications système](#vérifications-système)
- [🔐 Configuration GitHub SSH](#configuration-github-ssh)
- [🐳 Docker](#docker)
  - [Installation](#installation)
  - [Configuration BuildKit](#configuration-buildkit)
  - [Docker Desktop (optionnel)](#docker-desktop-optionnel)
  - [Login Docker Hub](#login-docker-hub)
  - [Commandes utiles](#commandes-utiles)
- [🔄 Auto-Synchronisation Git](#auto-synchronisation-git)
  - [Installation](#installation-1)
  - [Fonctionnement](#fonctionnement)
  - [Commandes utiles](#commandes-utiles-1)
  - [Configuration](#configuration)
- [🌐 Brave Browser](#brave-browser)
  - [Installation](#installation-2)
  - [Support](#support)
- [📊 Options principales du menu (setup.sh)](#options-principales-du-menu-setupsh)
  - [Installation & Détection (50-53)](#installation--détection-50-53)
  - [Désinstallation individuelle (60-70)](#désinstallation-individuelle-60-70)
  - [Autres options importantes](#autres-options-importantes)
- [📝 Système de logs d'installation](#système-de-logs-dinstallation)
- [📦 Scripts Modulaires](#scripts-modulaires)
  - [Tableau des scripts](#tableau-des-scripts)
- [✅ Validation du Setup](#validation-du-setup)
  - [Utilisation](#utilisation)
  - [Vérifications effectuées (117+ vérifications)](#vérifications-effectuées-117-vérifications)
  - [Rapport](#rapport)
- [📱 Flutter & Android](#flutter--android)
  - [Variables d'environnement (dans `.env`)](#variables-denvironnement-dans-env)
  - [Première utilisation](#première-utilisation)
- [🎮 NVIDIA RTX 3060](#nvidia-rtx-3060)
  - [Configuration automatique](#configuration-automatique)
  - [Vérifications](#vérifications)
  - [Important](#important)
- [🛠️ Maintenance](#maintenance)
  - [Mettre à jour le système](#mettre-à-jour-le-système)
  - [Nettoyer Docker](#nettoyer-docker)
  - [Mettre à jour Cursor](#mettre-à-jour-cursor)
- [📦 Structure recommandée après installation](#structure-recommandée-après-installation)
- [🚨 Troubleshooting](#troubleshooting)
  - [Flutter pas dans le PATH](#flutter-pas-dans-le-path)
  - [Docker : permission denied](#docker--permission-denied)
  - [NVIDIA : écran noir au boot](#nvidia--écran-noir-au-boot)
  - [Dotfiles non sourcés](#dotfiles-non-sourcés)
- [🔄 Workflow complet (nouvelle machine)](#workflow-complet-nouvelle-machine)
  - [Méthode automatique (recommandée)](#méthode-automatique-recommandée)
  - [Dans le menu scripts/setup.sh](#dans-le-menu-scriptssetupsh)
  - [Après installation](#après-installation)
- [🔄 Rollback / Désinstallation](#rollback--désinstallation)
  - [Rollback complet (tout désinstaller)](#rollback-complet-tout-désinstaller)
  - [Rollback Git uniquement](#rollback-git-uniquement)
  - [Rollback Git manuel](#rollback-git-manuel)
- [🖥️ Gestion des VM (Tests en environnement isolé)](#gestion-des-vm-tests-en-environnement-isolé)
  - [Installation QEMU/KVM](#installation-qemukvm)
  - [Utilisation rapide](#utilisation-rapide)
  - [Workflow de test recommandé](#workflow-de-test-recommandé)
  - [Commandes Makefile disponibles](#commandes-makefile-disponibles)
  - [Avantages](#avantages)
  - [Documentation complète](#documentation-complète)
- [📄 Licence](#licence)
- [👤 Auteur](#auteur)

---

<!-- =============================================================================
     INSTALLATION RAPIDE (NOUVELLE MACHINE)
     ============================================================================= -->

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

Cette commande va automatiquement exécuter les étapes suivantes :

**1. Vérification et installation de Git**
- Détection automatique du gestionnaire de paquets (pacman/apt/dnf)
- Installation automatique si Git n'est pas présent

**2. Configuration Git (nom et email)**
- Utilise la configuration existante si déjà configurée
- Sinon, demande interactivement avec valeurs par défaut
- Support des variables d'environnement `.env` (GIT_USER_NAME, GIT_USER_EMAIL)
- Configuration du credential helper (cache pour 15 minutes)

**3. Génération clé SSH ED25519** (si absente)
- Utilise l'email Git configuré pour la clé
- Copie la clé publique dans le presse-papier automatiquement
- Ouvre GitHub dans le navigateur pour ajouter la clé SSH
- Test de la connexion GitHub SSH (`ssh -T git@github.com`)

**4. Clonage ou mise à jour du repository dotfiles**
- Cloner dans `~/dotfiles` si inexistant
- Mettre à jour (`git pull`) si repo existe déjà
- Support des variables d'environnement `.env` (GITHUB_REPO_URL)
- Utilise l'URL par défaut si `.env` non configuré
- Si le dossier existe mais n'est pas un repo Git, demande confirmation pour le supprimer

**5. Choix du shell** (Zsh/Fish/Les deux)
- Sélection interactive du shell à configurer
- Support de plusieurs shells simultanés
- Passage de la sélection au menu `setup.sh`

**6. Création des symlinks** (si demandé)
- Centralisation de la configuration
- Backup automatique des fichiers existants
- Création selon le shell sélectionné

**7. Lancement automatique du menu interactif d'installation**
- Menu `scripts/setup.sh` avec toutes les options
- État de l'installation affiché en haut du menu
- Variable `SELECTED_SHELL_FOR_SETUP` passée au menu

Le menu interactif affiche :
- 📊 **L'état actuel de votre installation** (ce qui est installé, ce qui manque)
- 🎯 **Toutes les options disponibles** pour installer/configurer (50-70+ options)
- ✅ **Indications claires** sur quelle option choisir pour chaque composant
- 📋 **Logs d'installation** pour tracer toutes les actions

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

Différentes méthodes pour réinstaller les dotfiles selon votre situation.

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

Après une réinstallation, valider le setup :

```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

Ou via le menu (Option 23) pour un rapport détaillé.

---

<!-- =============================================================================
     STRUCTURE DU REPOSITORY
     ============================================================================= -->

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

Contient toutes les variables PATH nécessaires :
- Java (pour Flutter/Android)
- Android SDK
- Flutter
- Node.js global packages
- Cargo (Rust)
- Binaires locaux

Raccourcis pratiques pour :
- Navigation (`..`, `...`)
- Git (`gs`, `ga`, `gc`, `gp`)
- Docker (`dc`, `dps`)
- Système (`update`, `install`)
- Flutter (`fl`, `fld`, `flr`)

Fonctions utiles :
- `mkcd` - Créer dossier et y aller
- `gclone` - Git clone et cd
- `docker-cleanup` - Nettoyage Docker
- `backup` - Backup rapide avec timestamp

---

<!-- =============================================================================
     INSTALLATION COMPLÈTE DU SYSTÈME
     ============================================================================= -->

Le script `scripts/setup.sh` (menu interactif) permet d'installer et configurer automatiquement :

- ✅ yay (AUR helper)
- ✅ snap
- ✅ flatpak + flathub

- ✅ Brave Browser
- ✅ Cursor IDE (AppImage + .desktop)
- ✅ Discord
- ✅ KeePassXC
- ✅ Docker & Docker Compose (optimisé BuildKit)
- ✅ Proton Mail & Proton Pass
- ✅ PortProton (jeux Windows)
- ✅ Session Desktop

- ✅ Flutter SDK
- ✅ Android Studio & SDK
- ✅ Node.js & npm
- ✅ Git & GitHub SSH
- ✅ Outils de build (make, cmake, gcc)

- ✅ Pilotes NVIDIA RTX 3060
- ✅ Configuration Xorg pour GPU principal
- ✅ nvidia-prime pour gestion hybride

---

<!-- =============================================================================
     FONCTIONNALITÉS INTELLIGENTES
     ============================================================================= -->

Le script vérifie **toujours** si un paquet est déjà installé avant de l'installer :
- Évite les installations redondantes
- Messages clairs (installé/ignoré)
- Gère les conflits automatiquement

Lors du setup, les fichiers de config existants sont sauvegardés dans :
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

Un script dédié est créé :
```bash
update-cursor.sh
```

---

<!-- =============================================================================
     USAGE QUOTIDIEN
     ============================================================================= -->

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

Méthode 1 :

```bash
source ~/.zshrc
```

Méthode 2 :

```bash
exec zsh
```

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

```bash
flutter doctor          # Flutter
docker --version        # Docker
nvidia-smi             # NVIDIA
android-studio         # Android Studio
```

Le script génère automatiquement une clé SSH ED25519 et :
1. Copie la clé publique dans le presse-papier
2. Attend que vous l'ajoutiez sur GitHub
3. Teste la connexion

Clé stockée dans : `~/.ssh/id_ed25519`

---

<!-- =============================================================================
     DOCKER
     ============================================================================= -->

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

BuildKit est automatiquement activé dans `~/.docker/daemon.json` :
```json
{
  "features": {
    "buildkit": true
  }
}
```

Installation via option 16 du menu ou :
```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh --desktop-only
```

Le script propose automatiquement de se connecter à Docker Hub :
- Support 2FA (utilisez un Personal Access Token)
- Génération de token : https://hub.docker.com/settings/security

```bash
docker login
# Test avec
docker run hello-world
```

```bash
docker --version              # Vérifier la version
docker ps                     # Lister les conteneurs
docker-compose up             # Lancer avec docker-compose
docker compose up             # Lancer avec docker compose (plugin)
```

Système de synchronisation automatique des dotfiles toutes les heures via systemd timer.

Via le menu scripts/setup.sh (option 12) ou directement :
```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

- **Timer systemd** : Exécution toutes les heures
- **Pull automatique** : Récupère les modifications distantes
- **Push automatique** : Envoie les modifications locales (si changements)
- **Logs** : Disponibles dans `~/dotfiles/logs/auto_sync.log`

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

Le timer est configuré pour :
- Démarrer 5 minutes après le boot
- S'exécuter toutes les heures
- Précision de 1 minute

---

<!-- =============================================================================
     BRAVE BROWSER
     ============================================================================= -->

Installation optionnelle du navigateur Brave.

Via le menu scripts/setup.sh (option 17) ou directement :
```bash
bash ~/dotfiles/scripts/install/apps/install_brave.sh
```

- **Arch Linux** : Installation via yay (brave-bin)
- **Debian/Ubuntu** : Dépôt officiel Brave
- **Fedora** : Dépôt officiel Brave
- **Autres** : Installation manuelle ou Flatpak

---

<!-- =============================================================================
     OPTIONS PRINCIPALES DU MENU (SETUP.SH)
     ============================================================================= -->

- **50** : Afficher ce qui manque (état, scrollable via less)
- **51** : Installer éléments manquants (un par un, menu interactif)
- **52** : Installer tout ce qui manque (automatique, avec logs)
- **53** : Afficher logs d'installation (filtres, statistiques, scrollable)

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

- **23** : Validation complète du setup (117+ vérifications exhaustives)
- **28** : Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés)
- **26-27** : Migration shell (Fish ↔ Zsh), Changer shell par défaut

---

<!-- =============================================================================
     SYSTÈME DE LOGS D'INSTALLATION
     ============================================================================= -->

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

Script de validation complète pour vérifier toutes les installations et configurations.

Via le menu scripts/setup.sh (option 23) ou directement :
```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

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

Le script affiche un rapport avec :
- ✅ Réussis (vert)
- ❌ Échecs (rouge)
- ⚠️ Avertissements (jaune)

---

<!-- =============================================================================
     FLUTTER & ANDROID
     ============================================================================= -->

Définir JAVA_HOME :

```bash
export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
```

Définir ANDROID_SDK_ROOT :

```bash
export ANDROID_SDK_ROOT='/opt/android-sdk'
```

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

- Pilotes propriétaires installés
- Xorg configuré (PrimaryGPU)
- GRUB optimisé (nomodeset)
- nvidia-prime installé

Vérifier l'état du GPU :

```bash
nvidia-smi
```

Forcer une application à utiliser NVIDIA :

```bash
prime-run <app>
```

1. Branchez l'écran sur la **carte NVIDIA** (pas carte mère)
2. Dans le BIOS : `Primary Display` = `PCI-E` ou `Discrete`
3. Redémarrez après installation

---

<!-- =============================================================================
     MAINTENANCE
     ============================================================================= -->

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

Nettoyer Docker :

```bash
docker-cleanup
```

---

Mettre à jour Cursor :

```bash
update-cursor.sh
```

---

<!-- =============================================================================
     STRUCTURE RECOMMANDÉE APRÈS INSTALLATION
     ============================================================================= -->

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

Vérifiez que `~/dotfiles/.env` est sourcé dans `.zshrc` et contient :

```bash
export PATH=$PATH:/opt/flutter/bin
```

Ajouter votre utilisateur au groupe docker :

```bash
sudo usermod -aG docker $USER
```

Puis redémarrer la session.

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

Vérifier si dotfiles est sourcé dans `.zshrc` :

```bash
grep "source ~/dotfiles" ~/.zshrc
```

Si absent, relancez `scripts/setup.sh`.

---

<!-- =============================================================================
     WORKFLOW COMPLET (NOUVELLE MACHINE)
     ============================================================================= -->

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

1. **Voir ce qui manque** : Option 50
2. **Installer individuellement** : Option 51 (un par un) ou Option 52 (tout automatique)
3. **Suivre les logs** : Option 53 pour voir ce qui est fait
4. **Valider installation** : Option 23 (validation exhaustive)
5. **Configurer auto-sync** : Option 12 (synchronisation automatique Git)

- **Redémarrer** pour appliquer toutes les configurations
- **Vérifications** : `flutter doctor`, `docker login`, `nvidia-smi`
- **Configuration apps** : Cursor login, Proton Pass
- **Consulter logs** : Option 53 ou `less ~/dotfiles/logs/install.log`

---

<!-- =============================================================================
     ROLLBACK / DÉSINSTALLATION
     ============================================================================= -->

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

Pour revenir à une version précédente des dotfiles (sans désinstaller les applications) :

```bash
bash ~/dotfiles/scripts/uninstall/rollback_git.sh
```

Options disponibles :
- Revenir au commit précédent (HEAD~1)
- Revenir à un commit spécifique (par hash)
- Revenir à origin/main (dernière version distante)

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

Système complet de gestion de VM en ligne de commande pour tester les dotfiles dans un environnement complètement isolé.

Via le menu `scripts/setup.sh` (option 11) ou directement :
```bash
bash ~/dotfiles/scripts/install/tools/install_qemu_full.sh
```

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

- ✅ **100% en ligne de commande** : Pas besoin de virt-manager GUI
- ✅ **Tests en environnement isolé** : Votre machine reste propre
- ✅ **Rollback rapide** : Snapshots pour revenir en arrière instantanément
- ✅ **Workflow automatisé** : `make vm-test` gère tout automatiquement
- ✅ **Intégration Makefile** : Commandes simples et mémorisables

Voir `scripts/vm/README.md` pour la documentation complète avec tous les exemples.

---

<!-- =============================================================================
     LICENCE & AUTEUR
     ============================================================================= -->

Configuration personnelle - libre d'utilisation et modification.

**PavelDelhomme**
- GitHub: [@PavelDelhomme](https://github.com/PavelDelhomme)

---

*Dernière mise à jour : Décembre 2024*
[🔝 Retour en haut](#dotfiles---paveldelhomme)