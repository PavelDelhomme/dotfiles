# Dotfiles - PavelDelhomme

Configuration personnelle pour Manjaro Linux avec installation automatisée complète.

**Version :** 2.10.0

## 📑 Table des matières

- [🚀 Installation rapide (nouvelle machine)](#installation-rapide-nouvelle-machine)
  - [Installation en une seule commande](#installation-en-une-seule-commande)
  - [Après l'installation](#aprs-linstallation)
  - [Commandes utiles après installation](#commandes-utiles-aprs-installation)
  - [Installation manuelle (alternative)](#installation-manuelle-alternative)
- [🔄 Réinstallation](#rinstallation)
  - [Réinstallation complète (tout réinstaller)](#rinstallation-complte-tout-rinstaller)
  - [Réinstallation partielle (éléments spécifiques)](#rinstallation-partielle-lments-spcifiques)
  - [Réinstallation automatique (détection et installation)](#rinstallation-automatique-dtection-et-installation)
  - [Réinstallation après bootstrap (déjà installé)](#rinstallation-aprs-bootstrap-dj-install)
  - [Réinstallation d'un composant spécifique](#rinstallation-dun-composant-spcifique)
  - [Réinitialisation complète (cas extrême)](#rinitialisation-complte-cas-extrme)
  - [Vérifier l'état après réinstallation](#vrifier-ltat-aprs-rinstallation)
- [📁 Structure du repository](#structure-du-repository)
- [🔧 Fichiers de configuration](#fichiers-de-configuration)
  - [`.env` - Variables d'environnement](#variables-denvironnement-dans-env)
  - [`aliases.zsh` - Aliases](#aliaseszsh-aliases)
  - [`functions.zsh` - Fonctions](#functionszsh-fonctions)
- [🖥️ Installation complète du système](#installation-complte-du-systme)
  - [Gestionnaires de paquets](#gestionnaires-de-paquets)
  - [Applications](#applications)
  - [Environnement de développement](#environnement-de-dveloppement)
  - [Matériel](#matriel)
- [📝 Fonctionnalités intelligentes](#fonctionnalits-intelligentes)
  - [Vérifications avant installation](#vrifications-avant-installation)
  - [Backup automatique](#backup-automatique)
  - [Mise à jour de Cursor](#mise-jour-de-cursor)
- [🎯 Usage quotidien](#usage-quotidien)
  - [Commandes Makefile (recommandé)](#commandes-makefile-recommand)
  - [Recharger la configuration](#recharger-la-configuration)
  - [Mettre à jour les dotfiles](#mettre-jour-les-dotfiles)
  - [Vérifications système](#vrifications-systme)
- [📚 Système d'aide et documentation](#systme-daide-et-documentation)
  - [Aide pour les fonctions](#aide-pour-les-fonctions)
  - [Pages man pour les fonctions](#pages-man-pour-les-fonctions)
  - [Génération automatique de documentation](#gnration-automatique-de-documentation)
  - [Format de documentation](#format-de-documentation)
- [🎯 Managers - Gestionnaires Interactifs](#-managers---gestionnaires-interactifs)
  - [Structure Modulaire](#structure-modulaire)
  - [Cyberman - Gestionnaire Cybersécurité](#-cyberman---gestionnaire-cyberscurit)
  - [Devman - Gestionnaire Développement](#-devman---gestionnaire-dveloppement)
  - [Gitman - Gestionnaire Git](#-gitman---gestionnaire-git)
  - [Configman - Gestionnaire de Configurations](#%EF%B8%8F-configman---gestionnaire-de-configurations)
  - [Installman - Gestionnaire d'Installations](#-installman---gestionnaire-dinstallations)
  - [Manman - Manager of Managers](#-manman---manager-of-managers)
  - [Miscman - Gestionnaire Outils Divers](#%EF%B8%8F-miscman---gestionnaire-outils-divers)
  - [Pathman - Gestionnaire PATH](#-pathman---gestionnaire-path)
  - [Netman - Gestionnaire Réseau](#-netman---gestionnaire-rseau)
  - [Sshman - Gestionnaire SSH](#-sshman---gestionnaire-ssh)
  - [Helpman - Gestionnaire Documentation](#-helpman---gestionnaire-documentation)
  - [Fileman - Gestionnaire Fichiers](#-fileman---gestionnaire-fichiers)
  - [Virtman - Gestionnaire Environnements Virtuels](#-virtman---gestionnaire-environnements-virtuels)
  - [Multimediaman - Gestionnaire Multimédia](#-multimediaman---gestionnaire-multimdia)
- [🔐 Configuration GitHub SSH](#configuration-github-ssh)
- [🐳 Docker](#docker)
  - [Installation](#installation)
  - [Configuration BuildKit](#configuration-buildkit)
  - [Docker Desktop (optionnel)](#docker-desktop-optionnel)
  - [Login Docker Hub](#login-docker-hub)
  - [Commandes utiles](#commandes-utiles)
- [🔄 Auto-Synchronisation Git](#auto-synchronisation-git)
  - [Installation](#installation)
  - [Fonctionnement](#fonctionnement)
  - [Commandes utiles](#commandes-utiles)
  - [Configuration](#configuration)
- [🌐 Brave Browser](#brave-browser)
  - [Installation](#installation)
  - [Support](#support)
- [📊 Options principales du menu (setup.sh)](#options-principales-du-menu-setupsh)
  - [Installation & Détection (50-53)](#installation-dtection-50-53)
  - [Désinstallation individuelle (60-70)](#dsinstallation-individuelle-60-70)
  - [Autres options importantes](#autres-options-importantes)
- [📝 Système de logs d'installation](#systme-de-logs-dinstallation)
- [📦 Scripts Modulaires](#scripts-modulaires)
  - [Tableau des scripts](#tableau-des-scripts)
- [✅ Validation du Setup](#validation-du-setup)
  - [Utilisation](#utilisation)
  - [Vérifications effectuées (117+ vérifications)](#vrifications-effectues-117-vrifications)
  - [Rapport](#rapport)
- [📱 Flutter & Android](#flutter-android)
  - [Variables d'environnement (dans `.env`)](#variables-denvironnement-dans-env)
  - [Première utilisation](#premire-utilisation)
- [🎮 NVIDIA RTX 3060](#nvidia-rtx-3060)
  - [Configuration automatique](#configuration-automatique)
  - [Vérifications](#vrifications)
  - [Important](#important)
- [🛠️ Maintenance](#maintenance)
  - [Mettre à jour le système](#mettre-jour-le-systme)
  - [Nettoyer Docker](#nettoyer-docker)
  - [Mettre à jour Cursor](#mettre-jour-cursor)
- [📦 Structure recommandée après installation](#structure-recommande-aprs-installation)
- [🚨 Troubleshooting](#troubleshooting)
  - [Flutter pas dans le PATH](#flutter-pas-dans-le-path)
  - [Docker : permission denied](#docker-permission-denied)
  - [NVIDIA : écran noir au boot](#nvidia-cran-noir-au-boot)
  - [Dotfiles non sourcés](#dotfiles-non-sourcs)
- [🔄 Workflow complet (nouvelle machine)](#workflow-complet-nouvelle-machine)
  - [Méthode automatique (recommandée)](#mthode-automatique-recommande)
  - [Dans le menu scripts/setup.sh](#dans-le-menu-scriptssetupsh)
  - [Après installation](#aprs-installation)
- [🔄 Rollback / Désinstallation](#rollback-dsinstallation)
  - [Rollback complet (tout désinstaller)](#rollback-complet-tout-dsinstaller)
  - [Rollback Git uniquement](#rollback-git-uniquement)
  - [Rollback Git manuel](#rollback-git-manuel)
- [🖥️ Gestion des VM (Tests en environnement isolé)](#gestion-des-vm-tests-en-environnement-isol)
  - [Installation QEMU/KVM](#installation-qemukvm)
  - [Utilisation rapide](#utilisation-rapide)
  - [Workflow de test recommandé](#workflow-de-test-recommand)
  - [Commandes Makefile disponibles](#commandes-makefile-disponibles)
  - [Avantages](#avantages)
  - [Documentation complète](#documentation-complte)
- [📄 Licence](#licence)
- [👤 Auteur](#auteur)

---

<!-- =============================================================================
     INSTALLATION RAPIDE (NOUVELLE MACHINE)
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles-paveldelhomme)

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
  - Exemples : `votre.email@example.com`, `username@users.noreply.github.com`
  - ⚠️ **Important** : Si vous utilisez GitHub, vous pouvez utiliser l'email `username@users.noreply.github.com` pour garder votre email privé (visible dans les paramètres GitHub)
  - Validation automatique du format d'email
- Configuration du credential helper (cache pour 15 minutes)

**3. Configuration SSH pour GitHub** ⚠️ **OPTIONNEL - PEUT ÊTRE BYPASSÉE**

**⚠️ IMPORTANT : Cette étape est optionnelle ! Vous pouvez choisir de la passer.**

Le script vous propose un menu interactif avec 3 options :

```
Souhaitez-vous configurer SSH pour GitHub ?
Cela permet de cloner/pusher sans saisir vos identifiants.

  1. Oui, configurer SSH (recommandé)
  2. Non, passer cette étape (vous pourrez cloner via HTTPS)  ⚠️ BYPASS
  0. Vérifier si SSH est déjà configuré et fonctionne
```

**Option 1 : Oui, configurer SSH (recommandé)**
- Génération automatique de la clé SSH ED25519 (si absente)
- Utilise l'email Git configuré précédemment pour la clé
- **Si environnement graphique disponible** :
  - Copie la clé publique dans le presse-papier automatiquement
  - Ouvre GitHub dans le navigateur pour ajouter la clé SSH
- **Si ligne de commande uniquement (pas d'interface graphique)** :
  - Affiche la clé SSH publique à l'écran
  - Donne les instructions pour l'ajouter manuellement sur GitHub
  - Instructions pour utiliser GitHub CLI si disponible
- ⚠️ **Action requise** : Vous devez ajouter la clé SSH dans votre compte GitHub
  - **Avec navigateur** : Aller dans GitHub → Settings → SSH and GPG keys → New SSH key → Coller la clé
  - **Sans navigateur** : Utiliser une autre machine ou GitHub CLI (`gh ssh-key add`)
- Le script attend que vous appuyiez sur Entrée après avoir ajouté la clé
- Test de la connexion GitHub SSH (`ssh -T git@github.com`)

**Option 2 : Non, passer cette étape (BYPASS)** ⚠️ **VOUS POUVEZ CHOISIR ÇA**
- ⚠️ **Passe complètement la configuration SSH**
- Vous devrez utiliser HTTPS pour cloner (avec authentification GitHub lors du clonage)
- Utile si vous voulez juste installer rapidement sans configurer SSH
- Vous pourrez configurer SSH plus tard si nécessaire

**Option 0 : Vérifier si SSH est déjà configuré**
- Vérifie automatiquement si une clé SSH existe
- Teste la connexion GitHub SSH
- Si SSH fonctionne déjà : propose automatiquement de passer cette étape
- Si SSH ne fonctionne pas : vous pouvez choisir de reconfigurer ou bypasser

**4. Clonage ou mise à jour du repository dotfiles**
- **Si SSH configuré (option 1)** : Clone depuis GitHub via SSH (méthode recommandée, pas besoin de saisir identifiants)
- **Si SSH bypassé (option 2)** : Clone depuis GitHub via HTTPS (vous devrez vous authentifier avec votre token GitHub lors du clonage)
- Cloner dans `~/dotfiles` si inexistant
- Mettre à jour (`git pull`) si repo existe déjà
- Support des variables d'environnement `.env` (GITHUB_REPO_URL)
- Utilise l'URL par défaut si `.env` non configuré
- Si le dossier existe mais n'est pas un repo Git, demande confirmation pour le supprimer
- ✅ **Création automatique du fichier `.env`** avec les informations fournies (Nom Git, Email Git, URL repository)
  - Le fichier `.env` est créé automatiquement après le clonage
  - Contient vos informations pour éviter de les redemander lors des prochaines installations
  - Vous pouvez le modifier plus tard si nécessaire

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
- **Symlinks créés** :
  - `.zshrc` → `~/dotfiles/zshrc` (wrapper avec détection shell)
  - `.gitconfig` → `~/dotfiles/.gitconfig`
  - `.p10k.zsh` → `~/dotfiles/.p10k.zsh` (configuration Powerlevel10k avec Git)
  - `.ssh/id_ed25519` → `~/dotfiles/.ssh/id_ed25519` (optionnel)
  - `.ssh/config` → `~/dotfiles/.ssh/config` (optionnel)
- **Symlinks créés** :
  - `.zshrc` → `~/dotfiles/zshrc` (wrapper avec détection shell)
  - `.gitconfig` → `~/dotfiles/.gitconfig`
  - `.p10k.zsh` → `~/dotfiles/.p10k.zsh` (configuration Powerlevel10k avec Git)
  - `.ssh/id_ed25519` → `~/dotfiles/.ssh/id_ed25519` (optionnel)
  - `.ssh/config` → `~/dotfiles/.ssh/config` (optionnel)

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
   - Exemples : `github@email.com`, `votre.email@example.com`
   - ⚠️ **Important** : Cette email doit correspondre à celle de votre compte GitHub/GitLab
   - Pour GitHub, vous pouvez utiliser `username@users.noreply.github.com` pour garder votre email privé (visible dans GitHub → Settings → Emails)

3. ✅ **Configuration SSH GitHub** (⚠️ **OPTIONNEL - PEUT ÊTRE BYPASSÉE**)
   - **Option 1 (recommandé)** : Le script génère une clé SSH, ouvre GitHub dans le navigateur, vous ajoutez la clé
   - **Option 2 (BYPASS)** : ⚠️ **Vous pouvez choisir de passer cette étape** et utiliser HTTPS pour cloner
   - **Option 0** : Vérifie si SSH fonctionne déjà et propose de passer si OK
   - Si vous choisissez de bypasser SSH, vous devrez utiliser HTTPS pour cloner (avec authentification GitHub/token)

4. ⚙️ **Optionnel** : Après le clonage, vous pourrez créer le fichier `.env` pour éviter les saisies lors des prochaines installations (voir [Configuration Git via .env](#configuration-git-via-env)).

Le menu interactif affiche :
- 📊 **L'état actuel de votre installation** (ce qui est installé, ce qui manque)
- 🎯 **Toutes les options disponibles** pour installer/configurer (50-70+ options)
- ✅ **Indications claires** sur quelle option choisir pour chaque composant
- 📋 **Logs d'installation** pour tracer toutes les actions

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📁 Structure du repository

Voir `docs/STRUCTURE.md` pour la structure complète et détaillée.

Voir `docs/ARCHITECTURE.md` pour comprendre l'architecture des fichiers ZSH (zshrc, .zshrc, zshrc_custom) et Docker (test-docker.sh, Dockerfile.test).

Structure principale :
```
~/dotfiles/
├── bootstrap.sh                 # Installation en une ligne (curl)
├── zshrc                        # Wrapper qui détecte le shell (ZSH/Fish/Bash)
├── test-docker.sh               # Script de test Docker (appelé par make docker-test-auto)
├── Dockerfile.test              # Dockerfile pour tests automatiques
├── docker-compose.yml           # Orchestration Docker (isolé avec préfixe)
├── zsh/
│   ├── zshrc_custom            # Configuration ZSH principale (source par zshrc)
│   ├── env.sh                  # Variables d'environnement
│   ├── aliases.zsh             # Aliases personnalisés
│   └── functions/              # Fonctions shell
│       ├── *man.zsh            # Gestionnaires (18 managers: voir section Managers)
│       ├── cyberman/           # Cyberman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules organisés (security, legacy, etc.)
│       │   └── install/        # Scripts d'installation
│       ├── devman/             # Devman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   └── modules/        # Modules (legacy, etc.)
│       ├── gitman/             # Gitman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules (legacy, etc.)
│       │   └── utils/          # Utilitaires (git_wrapper)
│       ├── miscman/            # Miscman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   └── modules/        # Modules (legacy, etc.)
│       ├── pathman/            # Pathman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules
│       │   └── utils/          # Utilitaires
│       ├── netman/             # Netman - Structure modulaire
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules
│       │   └── utils/          # Utilitaires
│       ├── configman/          # Configman - Gestionnaire de configurations
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules (git, qemu, symlinks, shell)
│       │   └── utils/          # Utilitaires
│       ├── installman/         # Installman - Gestionnaire d'installations
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules (flutter, dotnet, emacs, java, android)
│       │   └── utils/          # Utilitaires (logger, path_utils, distro_detect)
│       ├── helpman/            # Helpman - Gestionnaire d'aide/documentation
│       │   ├── core/           # Script principal
│       │   └── utils/          # Utilitaires (list_functions, markdown_viewer)
│       ├── fileman/            # Fileman - Gestionnaire de fichiers
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules (archive, backup, search, permissions, files)
│       │   └── config/        # Configuration
│       ├── virtman/            # Virtman - Gestionnaire environnements virtuels
│       │   ├── core/           # Script principal
│       │   ├── modules/        # Modules (docker, qemu, libvirt, lxc, vagrant)
│       │   └── config/        # Configuration
│       ├── sshman/             # Sshman - Gestionnaire SSH
│       │   ├── core/           # Script principal
│       │   └── modules/        # Modules (ssh_auto_setup)
│       ├── testman/            # Testman - Gestionnaire tests applications
│       │   └── core/           # Script principal
│       ├── testzshman/         # Testzshman - Gestionnaire tests ZSH/dotfiles
│       │   └── core/           # Script principal
│       ├── moduleman/          # Moduleman - Gestionnaire modules (activation/désactivation)
│       │   └── core/           # Script principal
│       └── manman.zsh          # Manager of Managers (menu central)
│       └── **/*.sh             # Fonctions individuelles
└── scripts/
    ├── config/                 # Configurations unitaires (migré vers configman/modules/)
    ├── install/                # Scripts d'installation (utilisés par installman)
    ├── sync/                   # Auto-sync Git
    ├── test/                   # Validation & tests
    └── vm/                     # Gestion VM
```

---

<!-- =============================================================================
     FICHIERS DE CONFIGURATION
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

Voir aussi `docs/ARCHITECTURE.md` pour plus de détails.

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

## 🖥️ Installation complète du système

Le script `scripts/setup.sh` (menu interactif) permet d'installer et configurer automatiquement :

### Gestionnaires de paquets
- ✅ yay (AUR helper)
- ✅ snap
- ✅ flatpak + flathub

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Applications
- ✅ Brave Browser
- ✅ Cursor IDE (AppImage + .desktop)
- ✅ Discord
- ✅ KeePassXC
- ✅ Docker & Docker Compose (optimisé BuildKit)
- ✅ Proton Mail & Proton Pass
- ✅ PortProton (jeux Windows)
- ✅ Session Desktop

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Environnement de développement
- ✅ Flutter SDK
- ✅ Android Studio & SDK
- ✅ Node.js & npm
- ✅ Git & GitHub SSH
- ✅ Outils de build (make, cmake, gcc)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Matériel
- ✅ Pilotes NVIDIA RTX 3060
- ✅ Configuration Xorg pour GPU principal
- ✅ nvidia-prime pour gestion hybride

---

<!-- =============================================================================
     FONCTIONNALITÉS INTELLIGENTES
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📝 Fonctionnalités intelligentes

### Vérifications avant installation
Le script vérifie **toujours** si un paquet est déjà installé avant de l'installer :
- Évite les installations redondantes
- Messages clairs (installé/ignoré)
- Gère les conflits automatiquement

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Backup automatique
Lors du setup, les fichiers de config existants sont sauvegardés dans :
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Mise à jour de Cursor
Un script dédié est créé :
```bash
update-cursor.sh
```

---

<!-- =============================================================================
     USAGE QUOTIDIEN
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

## 🎯 Managers - Gestionnaires Interactifs

Le projet inclut plusieurs gestionnaires interactifs organisés en structure modulaire pour faciliter l'utilisation et l'extension.

### Structure Modulaire

Tous les managers suivent la même structure :
```
zsh/functions/
├── <manager>.zsh          # Wrapper de compatibilité
└── <manager>/             # Répertoire du manager
    ├── core/              # Script principal
    │   └── <manager>.zsh
    ├── modules/           # Modules organisés
    │   ├── legacy/        # Anciens fichiers
    │   └── ...            # Nouveaux modules
    ├── utils/             # Utilitaires
    ├── config/            # Configuration
    └── install/           # Scripts d'installation
```

### 🔐 Cyberman - Gestionnaire Cybersécurité

Gestionnaire complet pour les outils de cybersécurité et tests de sécurité.

**Utilisation :**
```bash
cyberman                    # Menu interactif
cyberman recon             # Reconnaissance
cyberman scan              # Scanning
cyberman web               # Web Security
```

**Fonctionnalités :**
- Gestion des cibles et environnements
- Workflows et rapports
- Reconnaissance & Information Gathering
- Scanning & Enumeration
- Vulnerability Assessment
- Network Analysis & Monitoring
- Web Security (Nuclei, XSS, SQLMap, Fuzzer)
- IoT Devices & Embedded Systems
- Network Devices & Infrastructure
- Advanced Tools (Metasploit, Custom Scripts)
- Utilitaires (hash, encode/decode, etc.)

**Installation :**
```bash
# Via menu d'installation
make install-menu          # Option 11: Outils cybersécurité complets

# Ou directement
bash zsh/functions/cyberman/install/install_security_tools.sh
```

**Documentation :** `help cyberman` ou `man cyberman`

### 💻 Devman - Gestionnaire Développement

Gestionnaire pour les outils de développement.

**Utilisation :**
```bash
devman                     # Menu interactif
devman docker              # Gestion Docker
devman go                  # Gestion Go
devman make               # Gestion Make
devman c                  # Compilation C/C++
```

**Fonctionnalités :**
- Docker (gestion conteneurs)
- Go (langage Go)
- Make (gestion builds)
- C/C++ (compilation)
- Projets (gestion projets personnalisés)
- Utilitaires dev

**Documentation :** `help devman` ou `man devman`

### 🔧 Gitman - Gestionnaire Git

Gestionnaire complet pour les opérations Git.

**Utilisation :**
```bash
gitman                     # Menu interactif
gitman whoami              # Affiche l'identité Git (remplace whoami-git)
gitman switch-identity     # Change l'identité Git (remplace switch-git-identity)
gitman status              # Statut Git
gitman commit 'message'    # Commit avec message
gitman help                # Liste toutes les commandes
```

**Fonctionnalités :**
- Identité Git (whoami, switch-identity, config)
- État & Informations (status, log, branches, remotes)
- Opérations (pull, push, commit, add-commit, diff)
- Branches (create, checkout, list, delete)
- Merge & Rebase
- Nettoyage (clean, reset, stash)

**Transformations :**
- `whoami-git` → `gitman whoami`
- `switch-git-identity` → `gitman switch-identity`

**Documentation :** `help gitman` ou `man gitman`

### ⚙️ Configman - Gestionnaire de Configurations

Gestionnaire complet pour configurer le système (Git, QEMU, symlinks, shells, Powerlevel10k).

**Utilisation :**
```bash
configman                    # Menu interactif
configman git                # Configuration Git globale
configman git-remote         # Configuration remote GitHub
configman symlinks           # Création des symlinks dotfiles
configman shell              # Gestion des shells (zsh, fish, bash)
configman p10k               # Configuration Powerlevel10k (prompt avec Git)
configman qemu-libvirt       # Configuration permissions libvirt
configman qemu-network       # Configuration réseau NAT QEMU
configman qemu-packages      # Installation paquets QEMU uniquement
```

**Fonctionnalités :**
- **Git** : Configuration globale (nom, email, editor, etc.)
- **Git Remote** : Configuration remote GitHub (SSH/HTTPS)
- **Symlinks** : Création automatique des symlinks pour centraliser la config
- **Shell** : Installation, configuration et changement de shell par défaut
- **Powerlevel10k** : Configuration du prompt avec support Git (statut Git dans le prompt)
- **QEMU Libvirt** : Configuration permissions et groupes libvirt
- **QEMU Network** : Configuration réseau NAT pour VMs
- **QEMU Packages** : Installation modulaire des paquets QEMU

**Exemples :**
```bash
# Configurer Git globalement
configman git

# Créer les symlinks dotfiles
configman symlinks

# Changer le shell par défaut vers zsh
configman shell

# Configurer Powerlevel10k (prompt avec statut Git)
configman p10k
configman powerlevel10k      # Alias
configman prompt             # Alias

# Configurer QEMU (modulaire)
configman qemu-libvirt
configman qemu-network
configman qemu-packages
```

**Module Powerlevel10k :**
Le module `p10k` permet de gérer la configuration du prompt Powerlevel10k (utilisé par Manjaro) avec support Git :
- **Option 1** : Configurer Powerlevel10k (`p10k configure`) - Assistant interactif
- **Option 2** : Copier la configuration depuis dotfiles vers `~/.p10k.zsh`
- **Option 3** : Créer un symlink de `~/.p10k.zsh` vers dotfiles (recommandé pour synchronisation)
- **Option 4** : Vérifier la configuration actuelle

La configuration Powerlevel10k est automatiquement chargée au démarrage du shell si elle existe dans `~/dotfiles/.p10k.zsh`. Un symlink est créé automatiquement vers `~/.p10k.zsh` pour la synchronisation.

**Documentation :** `help configman` ou `man configman`

### 📦 Installman - Gestionnaire d'Installations

Gestionnaire complet pour installer et configurer automatiquement des outils de développement.

**Utilisation :**
```bash
installman                   # Menu interactif
install-tool                 # Alias pour installman
installman flutter           # Installation Flutter SDK
installman dotnet            # Installation .NET SDK
installman emacs             # Installation Emacs + Doom Emacs + config de base
installman java17            # Installation Java 17 OpenJDK
installman android-studio    # Installation Android Studio
installman android-tools     # Installation outils Android (ADB, SDK, etc.)
installman handbrake         # Installation HandBrake CLI + GUI (si GUI disponible)
installman ssh-config        # Configuration SSH automatique (avec mot de passe .env)
```

**Fonctionnalités :**
- **Flutter SDK** : Installation dans `/opt/flutter/bin` avec configuration automatique
- **.NET SDK** : Installation avec ajout automatique au PATH
- **Emacs** : Installation + Doom Emacs + configuration de base (mode sombre, numéros de ligne, outils dev)
- **Java** : Installation OpenJDK (versions 8, 11, 17, 21, 25) avec configuration automatique
- **Android Studio** : Installation selon la distribution (Arch, Debian, Fedora)
- **Outils Android** : ADB, SDK, build-tools avec configuration automatique
- **Licences Android** : Acceptation automatique des licences Android SDK
- **Docker** : Installation Docker & Docker Compose
- **Brave Browser** : Installation Brave Browser
- **Cursor IDE** : Installation Cursor IDE
- **HandBrake** : Installation HandBrake CLI et GUI (si interface graphique disponible)
- **QEMU/KVM** : Installation outils de virtualisation
- **SSH Config** : Configuration automatique SSH avec mot de passe depuis `.env`

**Configuration automatique :**
- ✅ Ajout automatique au PATH dans `env.sh` (configuration définitive)
- ✅ Vérification si déjà installé (évite les réinstallations)
- ✅ Configuration adaptée à la distribution (Arch, Debian, Fedora)
- ✅ Support multi-distributions

**Exemples :**
```bash
# Installer Flutter (menu interactif)
installman

# Installer Flutter directement
installman flutter

# Installer Android Studio et outils
installman android-studio
installman android-tools

# Installer Emacs avec configuration complète
installman emacs
# → Installe Emacs
# → Configure mode sombre, numéros de ligne, outils dev
# → Installe Doom Emacs
```

**Documentation :** `help installman` ou `man installman`

### 🎯 Manman - Manager of Managers

Gestionnaire centralisé pour accéder à tous les autres gestionnaires.

**Utilisation :**
```bash
manman                       # Menu interactif de tous les managers
mmg                         # Alias pour manman
managers                    # Alias pour manman
```

**Managers disponibles (19 managers) :**
- 📁 **pathman** : Gestionnaire PATH
- 🌐 **netman** : Gestionnaire réseau
- 📝 **aliaman** : Gestionnaire alias
- 🔧 **miscman** : Gestionnaire divers
- 🔍 **searchman** : Gestionnaire recherche
- 🛡️ **cyberman** : Gestionnaire cybersécurité
- 💻 **devman** : Gestionnaire développement
- 📦 **gitman** : Gestionnaire Git
- 📚 **helpman** : Gestionnaire aide/documentation
- ⚙️ **configman** : Gestionnaire configurations
- 📦 **installman** : Gestionnaire installations
- 🔐 **sshman** : Gestionnaire SSH
- 📁 **fileman** : Gestionnaire fichiers
- 🖥️ **virtman** : Gestionnaire virtualisation
- 🧪 **testman** : Gestionnaire tests applications
- 🧪 **testzshman** : Gestionnaire tests ZSH/dotfiles
- 🎬 **multimediaman** : Gestionnaire multimédia (ripping DVD, encodage)
- ⚙️ **moduleman** : Gestionnaire modules (activation/désactivation)

**Documentation :** `help manman` ou `man manman`

### 🎬 Multimediaman - Gestionnaire Multimédia

Gestionnaire complet pour les opérations multimédias (ripping DVD, encodage vidéo).

**Utilisation :**
```bash
multimediaman                  # Menu interactif
multimediaman rip-dvd "Film"   # Ripping DVD avec encodage MP4
mm                             # Alias pour multimediaman
mm-rip                         # Alias pour multimediaman rip-dvd
```

**Fonctionnalités :**
- **Ripping DVD** : Pipeline automatique pour ripper des DVD
  - Copie du DVD brut avec `dvdbackup`
  - Encodage MP4 H.264 avec `HandBrakeCLI`
  - Qualité RF 20 par défaut (configurable)
  - Toutes les pistes audio (VF+VO) et sous-titres conservés
  - Optimisation "fast start" pour streaming web
  - Chapitres conservés

**Pré-requis :**
- HandBrake CLI installé (via `installman handbrake`)
- `dvdbackup` installé (installé automatiquement avec HandBrake)
- `libdvdcss` pour DVD chiffrés (Arch/Manjaro uniquement, via AUR)

**Exemple :**
```bash
# 1. Installer HandBrake
installman handbrake

# 2. Insérer le DVD

# 3. Ripper le DVD
multimediaman rip-dvd "Mon_Film"

# 4. Le fichier sera dans ~/DVD_RIPS/Mon_Film.mp4
```

**Fichier de sortie :** `~/DVD_RIPS/[nom_du_film].mp4`

**Documentation :** `help multimediaman` ou voir `zsh/functions/multimediaman/modules/dvd/README.md`

### 🛠️ Miscman - Gestionnaire Outils Divers

Gestionnaire pour les outils divers et utilitaires système.

**Utilisation :**
```bash
miscman                    # Menu interactif
miscman genpass 20         # Génère un mot de passe
miscman sysinfo            # Informations système
```

**Fonctionnalités :**
- Génération de mots de passe
- Informations système
- Sauvegardes
- Extraction d'archives
- Chiffrement
- Nettoyage

**Documentation :** `help miscman` ou `man miscman`

### 📁 Pathman - Gestionnaire PATH

Gestionnaire interactif du PATH système.

**Utilisation :**
```bash
pathman                    # Menu interactif
pathman add /usr/local/bin # Ajouter un répertoire
pathman clean              # Nettoyer le PATH
```

**Fonctionnalités :**
- Ajouter/retirer des répertoires
- Nettoyer le PATH
- Sauvegarder/restaurer
- Logs et statistiques

**Documentation :** `help pathman` ou `man pathman`

### 🌐 Netman - Gestionnaire Réseau

Gestionnaire complet pour les ports, connexions, interfaces réseau, DNS, routage et analyse du trafic.

**Utilisation :**
```bash
netman                     # Menu interactif
netman ports               # Gestion des ports (interactif)
netman kill <port>         # Kill rapide d'un port
netman scan <host>         # Scan rapide d'un host
netman stats               # Statistiques réseau
```

**Fonctionnalités :**
- **Gestion des ports** : Liste interactive, kill, informations détaillées
- **Connexions réseau** : Visualisation des connexions actives (ESTABLISHED, TIME_WAIT, etc.)
- **Informations IP** : IP publique, géolocalisation, IPs locales, IPv6
- **Configuration DNS** : Serveurs DNS, test de résolution, cache DNS
- **Table de routage** : Routes IPv4/IPv6, passerelles, métriques
- **Interfaces réseau** : État, MAC, IPs, statistiques (RX/TX)
- **Scan de ports** : Port unique ou plage de ports
- **Kill rapide** : Termination de processus par port
- **Statistiques réseau** : Statistiques globales, top connexions, bande passante
- **Test de connectivité** : Ping et traceroute
- **Test de vitesse** : Vitesse de téléchargement et latence
- **Monitoring bande passante** : Surveillance en temps réel avec graphiques
- **Analyse du trafic** : Top IPs, ports, répartition par protocole
- **Export de configuration** : Export complet (interfaces, routes, DNS, ports, firewall)

**Documentation :** `help netman` ou `man netman`

### 🔐 Sshman - Gestionnaire SSH

Gestionnaire complet pour les connexions SSH, clés SSH et configurations automatiques.

**Utilisation :**
```bash
sshman                     # Menu interactif
sshman auto-setup          # Configuration automatique SSH (avec mot de passe .env)
sshman list                # Liste des connexions SSH configurées
sshman test                # Test de connexion SSH
sshman keys                # Gestion des clés SSH
sshman stats               # Statistiques SSH
```

**Fonctionnalités :**
- **Configuration automatique** : Configuration SSH avec mot de passe depuis `.env`
- **Liste des connexions** : Affiche toutes les connexions SSH configurées dans `~/.ssh/config`
- **Test de connexion** : Teste une connexion SSH configurée
- **Gestion des clés SSH** : Génération, affichage, copie dans presse-papiers, suppression
- **Statistiques SSH** : Nombre de hosts configurés, clés, vérification des permissions

**Configuration via `.env` :**
```bash
SSH_HOST_NAME="pavel-server"
SSH_HOST="95.111.227.204"
SSH_USER="pavel"
SSH_PORT="22"
SSH_PASSWORD="votre_mot_de_passe"
```

**Utilisation manuelle :**
```bash
# Fonction directe (compatible avec configman)
ssh_auto_setup [host_name] [host_ip] [user] [port]

# Exemple
ssh_auto_setup pavel-server 95.111.227.204 pavel 22
```

**Documentation :** `help sshman` ou `man sshman`

### Installation des Managers

**Vérification :**
```bash
make install-menu          # Option 13: Vérifier/Configurer tous les managers
```

**Dépendances :**
```bash
make install-menu          # Option 14: Installer dépendances managers
```

Les managers sont automatiquement chargés via `zshrc_custom` et disponibles dans votre shell.

### 📚 Helpman - Gestionnaire Documentation

Gestionnaire complet pour le système d'aide et documentation.

**Utilisation :**
```bash
helpman                    # Menu interactif du guide d'aide
help <fonction>           # Aide rapide sur une fonction
man <fonction>            # Documentation complète
help --list               # Liste toutes les fonctions
help --search <mot>        # Rechercher des fonctions
```

**Fonctionnalités :**
- Guide interactif pour comprendre `man` et `help`
- Système d'aide unifié pour toutes les fonctions
- Génération automatique de pages man (Markdown)
- Recherche de fonctions
- Liste organisée par catégories

**Documentation :** `help helpman` ou `man helpman`

### 📁 Fileman - Gestionnaire Fichiers

Gestionnaire complet pour les opérations sur fichiers et répertoires.

**Utilisation :**
```bash
fileman                    # Menu interactif
fileman archive            # Gestion des archives
fileman backup             # Gestion des sauvegardes
fileman search             # Recherche de fichiers
fileman permissions        # Gestion des permissions
fileman files              # Opérations sur fichiers
```

**Fonctionnalités :**
- **Archive** : Création et extraction d'archives (tar, zip, rar, 7z, etc.)
- **Backup** : Création, liste, restauration et suppression de sauvegardes
- **Recherche** : Recherche de fichiers par nom, contenu, taille ou date
- **Permissions** : Gestion des permissions de fichiers/répertoires
- **Fichiers** : Copier, déplacer, supprimer, renommer, créer des répertoires

**Exemples :**
```bash
# Menu interactif complet
fileman

# Gestion des archives
fileman archive
# Options: Extraire, créer, lister, vérifier

# Gestion des sauvegardes
fileman backup
# Options: Créer, lister, restaurer, supprimer

# Recherche de fichiers
fileman search
# Options: Par nom, contenu, taille, date

# Gestion des permissions
fileman permissions
# Options: Changer, afficher, appliquer par défaut, rechercher

# Opérations sur fichiers
fileman files
# Options: Copier, déplacer, supprimer, renommer, créer, infos
```

**Documentation :** `help fileman` ou `man fileman`

**Alias :** `fm` → `fileman`

### 🖥️ Virtman - Gestionnaire Environnements Virtuels

Gestionnaire complet pour les environnements virtuels (VMs, conteneurs).

**Utilisation :**
```bash
virtman                    # Menu interactif
virtman docker             # Gestion Docker
virtman qemu               # Gestion QEMU/KVM
virtman libvirt            # Gestion libvirt/virsh
virtman lxc                # Gestion LXC
virtman vagrant            # Gestion Vagrant
virtman overview           # Vue d'ensemble
```

**Fonctionnalités :**
- **Docker** : Gestion complète des conteneurs (créer, démarrer, arrêter, logs, images, volumes, réseaux)
- **QEMU/KVM** : Gestion des machines virtuelles (créer, démarrer, arrêter, disques, réseau)
- **libvirt/virsh** : Gestion via libvirt (domaines, réseaux, console)
- **LXC** : Gestion des conteneurs LXC (créer, démarrer, arrêter, shell)
- **Vagrant** : Gestion des VMs Vagrant (init, up, down, ssh, provision)
- **Vue d'ensemble** : Résumé de tous les environnements virtuels

**Exemples :**
```bash
# Menu interactif complet
virtman

# Gestion Docker
virtman docker
# Options: Lister, créer, démarrer, arrêter, logs, images, volumes, réseaux

# Gestion QEMU/KVM
virtman qemu
# Options: Lister, créer, démarrer, arrêter, disques, réseau

# Gestion libvirt
virtman libvirt
# Options: Lister, démarrer, arrêter, suspendre, console, réseaux

# Vue d'ensemble
virtman overview
# Affiche un résumé de tous les environnements (Docker, QEMU, libvirt, LXC, Vagrant)
```

**Documentation :** `help virtman` ou `man virtman`

**Alias :** `vm` → `virtman`, `virt` → `virtman`

### ⚙️ Moduleman - Gestionnaire Modules

Gestionnaire qui contrôle l'activation/désactivation des autres managers.

**⚠️ IMPORTANT : Moduleman doit toujours être activé** car il contrôle le chargement des autres managers.

**Utilisation :**
```bash
moduleman                    # Menu interactif
moduleman enable <manager>  # Activer un manager
moduleman disable <manager> # Désactiver un manager
moduleman status            # Voir le statut de tous les managers
moduleman list              # Lister tous les managers
```

**Fonctionnalités :**
- **Contrôle centralisé** : Active/désactive les autres managers
- **Configuration persistante** : Sauvegarde dans `~/.config/moduleman/modules.conf`
- **Interface interactive** : Menu pour gérer tous les managers
- **Démarrage optimisé** : Charge seulement les managers activés

**Pourquoi Moduleman est essentiel :**
- Contrôle quels managers sont chargés au démarrage
- Permet de désactiver des managers non utilisés
- Accélère le démarrage du shell
- Configuration centralisée dans un fichier

**Documentation :** `help moduleman`, `man moduleman` ou voir `docs/MODULEMAN_EXPLICATION.md`

**Alias :** `mm` → `moduleman`

### 🧪 Testzshman - Gestionnaire Tests ZSH/Dotfiles

Gestionnaire complet pour tester la configuration ZSH et les dotfiles.

**Utilisation :**
```bash
testzshman                   # Menu interactif
testzshman managers          # Tester tous les managers
testzshman functions         # Tester toutes les fonctions
testzshman structure         # Vérifier la structure des dotfiles
testzshman config            # Tester la configuration
testzshman symlinks          # Vérifier les symlinks
testzshman syntax            # Vérifier la syntaxe des fichiers
```

**Fonctionnalités :**
- **Tests des managers** : Vérifie que tous les managers sont disponibles
- **Tests des fonctions** : Vérifie que les fonctions sont chargées
- **Vérification structure** : Vérifie la structure des dotfiles
- **Tests de configuration** : Vérifie les fichiers de configuration
- **Vérification symlinks** : Vérifie que les symlinks sont corrects
- **Tests de syntaxe** : Vérifie la syntaxe ZSH des fichiers

**Documentation :** `help testzshman` ou `man testzshman`

### 🧪 Testman - Gestionnaire Tests Applications

Gestionnaire complet pour tester des applications dans différents langages.

**Utilisation :**
```bash
testman                      # Menu interactif
testman python               # Tester projet Python
testman node                 # Tester projet Node.js
testman rust                 # Tester projet Rust
testman go                   # Tester projet Go
testman java                 # Tester projet Java
testman flutter              # Tester projet Flutter
testman lisp                 # Tester projet Lisp
testman auto                 # Détection automatique du langage
```

**Fonctionnalités :**
- **Multi-langages** : Support Python, Node.js, Rust, Go, Java, Flutter, Ruby, PHP, Lisp
- **Détection automatique** : Détecte automatiquement le langage du projet
- **Tests depuis répertoire courant** : Lance les tests depuis le répertoire actuel
- **Support Docker Compose** : Gère les tests complexes avec Docker
- **Input direct** : Permet de lancer des tests directement (`testman python`)

**Exemples :**
```bash
# Détection automatique du langage
testman auto

# Tester un projet Python depuis le répertoire courant
cd ~/mon-projet-python
testman python

# Tester un projet Node.js
testman node

# Tester avec Docker Compose
testman docker
```

**Documentation :** `help testman` ou `man testman`

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🔄 Compatibilité Multi-Shells

Le projet supporte **ZSH**, **Bash** et **Fish**, mais avec des niveaux de compatibilité différents.

### ✅ Ce qui est compatible avec tous les shells

#### Variables d'environnement (`env.sh`)
- ✅ **ZSH** : Chargé via `zshrc_custom`
- ✅ **Bash** : Chargé via wrapper `zshrc`
- ✅ **Fish** : Version Fish (`env.fish`) disponible

#### Aliases
- ✅ **ZSH** : Chargé via `aliases.zsh`
- ✅ **Bash** : Chargé via wrapper `zshrc` (alias simples compatibles)
- ✅ **Fish** : Version Fish (`aliases.fish`) disponible

#### Scripts d'installation et configuration
- ✅ **Tous les shells** : Scripts dans `scripts/install/` et `scripts/config/` sont en bash

### ⚠️ Ce qui est ZSH-only

**Tous les managers interactifs** (*man) sont **ZSH-only** car ils utilisent :
- Syntaxe ZSH spécifique (`typeset`, `declare -A`, etc.)
- Fonctions ZSH interactives
- Caractéristiques avancées de ZSH

**Managers ZSH-only (18 managers) :**
- `installman`, `configman`, `pathman`, `netman`, `gitman`, `cyberman`, `devman`, `miscman`, `aliaman`, `searchman`, `helpman`, `fileman`, `virtman`, `sshman`, `testman`, `testzshman`, `moduleman`, `manman`

### 🐟 Support Fish

Fish a ses propres implémentations dans `fish/` :
- `fish/config_custom.fish` - Configuration principale
- `fish/aliases.fish` - Aliases Fish
- `fish/env.fish` - Variables d'environnement
- `fish/functions/` - Quelques fonctions Fish

**Note :** Fish a une syntaxe très différente, donc les managers ZSH ne sont pas compatibles.

### 🐚 Support Bash

Bash peut utiliser :
- Variables d'environnement via `env.sh`
- Alias simples via `aliases.zsh` (avec limitations)
- Scripts d'installation et configuration (tous en bash)

**Limitations Bash :**
- ❌ Pas de managers interactifs
- ⚠️ Alias complexes peuvent ne pas fonctionner
- ❌ Pas de fonctions ZSH avancées

### 🔄 Wrapper `zshrc` multi-shells

Le fichier `~/dotfiles/zshrc` est un wrapper intelligent qui :

1. **Détecte le shell actif** (ZSH, Fish, Bash)
2. **Source la configuration appropriée** :
   - **ZSH** → `zsh/zshrc_custom` (tout est chargé, toutes les fonctionnalités)
   - **Bash** → `env.sh` et `aliases.zsh` (limité, compatibilité basique)
   - **Fish** → Affiche un message (config doit être dans `.config/fish/config.fish`)

### 📝 Recommandation

**Pour une compatibilité maximale :**
- ✅ **Utilisez ZSH** : Toutes les fonctionnalités sont disponibles (18 managers, toutes les fonctions)
- ⚠️ **Utilisez Fish** : Fonctionnalités limitées, syntaxe différente
- ⚠️ **Utilisez Bash** : Seulement variables d'env et alias simples

Voir `docs/COMPATIBILITY.md` pour plus de détails.

### Installation des Managers

**Vérification :**
```bash
make install-menu          # Option 13: Vérifier/Configurer tous les managers
```

**Dépendances :**
```bash
make install-menu          # Option 14: Installer dépendances managers
```

Les managers sont automatiquement chargés via `zshrc_custom` et disponibles dans votre shell.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🔐 Configuration GitHub SSH

### ⚠️ IMPORTANT : Cette étape est optionnelle !

Lors de l'installation via `bootstrap.sh`, vous pouvez **choisir de bypasser complètement la configuration SSH**.

**Menu proposé par bootstrap.sh :**
```
Souhaitez-vous configurer SSH pour GitHub ?
Cela permet de cloner/pusher sans saisir vos identifiants.

  1. Oui, configurer SSH (recommandé)
  2. Non, passer cette étape (vous pourrez cloner via HTTPS)  ⚠️ BYPASS
  0. Vérifier si SSH est déjà configuré et fonctionne
```

### Option 1 : Configuration SSH (recommandé)

Le script génère automatiquement une clé SSH ED25519 et :
1. Copie la clé publique dans le presse-papier
2. Attend que vous l'ajoutiez sur GitHub
3. Teste la connexion

Clé stockée dans : `~/.ssh/id_ed25519`

**Avantages :**
- Clonage/push sans saisir identifiants
- Plus sécurisé
- Plus rapide pour les opérations Git

### Option 2 : Bypasser la configuration SSH ⚠️

Si vous choisissez cette option :
- ✅ Le script passe directement au clonage
- ✅ Vous utiliserez HTTPS pour cloner (avec authentification GitHub)
- ✅ Utile si vous voulez installer rapidement
- ✅ Vous pourrez configurer SSH plus tard si nécessaire

**Note :** Pour cloner via HTTPS, GitHub peut vous demander un Personal Access Token au lieu d'un mot de passe.

### Option 0 : Vérification automatique

Le script vérifie automatiquement :
- Si une clé SSH existe déjà
- Si la connexion GitHub SSH fonctionne
- Si tout fonctionne : propose automatiquement de passer cette étape

### Quand bypasser la configuration SSH ?

Bypasser la configuration SSH est recommandé si :
- ✅ Vous avez déjà SSH configuré et fonctionnel
- ✅ Vous préférez utiliser HTTPS pour Git
- ✅ Vous voulez installer rapidement sans configuration supplémentaire
- ✅ Vous configurez SSH manuellement plus tard

**Après avoir bypassé :**
- Vous pouvez toujours configurer SSH manuellement plus tard avec :
  ```bash
  ssh-keygen -t ed25519 -C "votre.email@example.com"
  # Ajouter la clé sur GitHub : https://github.com/settings/keys
  ```

---

<!-- =============================================================================
     DOCKER
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Configuration BuildKit

BuildKit est automatiquement activé dans `~/.docker/daemon.json` :
```json
{
  "features": {
    "buildkit": true
  }
}
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Docker Desktop (optionnel)

Installation via option 16 du menu ou :
```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh --desktop-only
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Login Docker Hub

Le script propose automatiquement de se connecter à Docker Hub :
- Support 2FA (utilisez un Personal Access Token)
- Génération de token : https://hub.docker.com/settings/security

```bash
docker login
# Test avec
docker run hello-world
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Commandes utiles

```bash
docker --version              # Vérifier la version
docker ps                     # Lister les conteneurs
docker-compose up             # Lancer avec docker-compose
docker compose up             # Lancer avec docker compose (plugin)
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Tests dans environnement Docker isolé

**🔒 Isolation complète :** Les conteneurs de test utilisent le préfixe `dotfiles-test-*` et ne touchent **JAMAIS** vos autres conteneurs Docker existants.

**Entrer dans l'environnement de test (recommandé) :**

```bash
# Entrer dans le conteneur (construit l'image si besoin). Dotfiles montés en lecture seule.
make docker-in

# Avec un autre shell : zsh (défaut), bash, fish, sh
make docker-in SHELL=bash
make docker-in SHELL=fish

# Reconstruire l'image après modification du Dockerfile
make docker-rebuild
make docker-in
```

**Autres commandes Docker :**

```bash
# Construire l'image
make docker-build

# Lancer un conteneur interactif (zsh)
make docker-run

# Tester rapidement les dotfiles (une commande)
make docker-test

# Installation automatique complète (image Dockerfile.test)
make docker-build-test
make docker-start

# Nettoyer UNIQUEMENT les conteneurs dotfiles-test
make docker-clean
```

**Environnement de test :**
- ✅ **Arch Linux minimal** : Environnement propre et isolé
- ✅ **Installation automatique** : Configuration complète sans intervention
- ✅ **Tests intégrés** : Vérification automatique de tous les managers
- ✅ **Isolation totale** : Préfixe unique `dotfiles-test-*` pour ne pas toucher vos autres conteneurs

**Fichiers créés :**
- `Dockerfile.test` : Dockerfile pour installation automatique complète
- `test-docker.sh` : Script de test automatique
- `docker-compose.yml` : Orchestration (projet isolé avec préfixe)

**Sécurité :**
- ✅ Tous les conteneurs/images/volumes utilisent le préfixe `dotfiles-test-*`
- ✅ Nettoyage sélectif avec filtres Docker
- ✅ Vos autres conteneurs Docker ne seront **JAMAIS** touchés

**Choix du shell de test :**

Lors de `make docker-test-auto`, vous pouvez choisir le shell de test :
- **ZSH** (recommandé) : Toutes les fonctionnalités disponibles (18 managers)
- **Bash** : Test de compatibilité basique (variables d'env, alias simples)
- **Fish** : Test de compatibilité basique (variables d'env, alias)

```bash
# Tester avec ZSH (par défaut, toutes les fonctionnalités)
make docker-test-auto
# Choisir option 1 pour zsh

# Tester avec Bash (compatibilité basique)
make docker-test-auto
# Choisir option 2 pour bash

# Tester avec Fish (compatibilité basique)
make docker-test-auto
# Choisir option 3 pour fish

# Tester manuellement avec le shell de votre choix
make docker-start
# Choisir le shell (zsh/bash/fish) au démarrage
```

**Exemple d'utilisation :**
```bash
# Tester l'installation complète automatique
make docker-test-auto

# Cela va :
# 1. Demander quels managers activer
# 2. Demander quel shell utiliser (zsh/bash/fish)
# 3. Construire l'image Docker avec installation automatique
# 4. Lancer l'installation complète des dotfiles
# 5. Vérifier que tous les managers fonctionnent (ZSH seulement)
# 6. Afficher un rapport de test
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🔄 Auto-Synchronisation Git

Système de synchronisation automatique des dotfiles toutes les heures via systemd timer.

### Installation

Via le menu scripts/setup.sh (option 12) ou directement :
```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Fonctionnement

- **Timer systemd** : Exécution toutes les heures
- **Pull automatique** : Récupère les modifications distantes
- **Push automatique** : Envoie les modifications locales (si changements)
- **Logs** : Disponibles dans `~/dotfiles/logs/auto_sync.log`

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Configuration

Le timer est configuré pour :
- Démarrer 5 minutes après le boot
- S'exécuter toutes les heures
- Précision de 1 minute

---

<!-- =============================================================================
     BRAVE BROWSER
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🌐 Brave Browser

Installation optionnelle du navigateur Brave.

### Installation

Via le menu scripts/setup.sh (option 17) ou directement :
```bash
bash ~/dotfiles/scripts/install/apps/install_brave.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Support

- **Arch Linux** : Installation via yay (brave-bin)
- **Debian/Ubuntu** : Dépôt officiel Brave
- **Fedora** : Dépôt officiel Brave
- **Autres** : Installation manuelle ou Flatpak

---

<!-- =============================================================================
     OPTIONS PRINCIPALES DU MENU (SETUP.SH)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📊 Options principales du menu (setup.sh)

### Installation & Détection (50-53)
- **50** : Afficher ce qui manque (état, scrollable via less)
- **51** : Installer éléments manquants (un par un, menu interactif)
- **52** : Installer tout ce qui manque (automatique, avec logs)
- **53** : Afficher logs d'installation (filtres, statistiques, scrollable)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Autres options importantes
- **23** : Validation complète du setup (117+ vérifications exhaustives)
- **28** : Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés)
- **26-27** : Migration shell (Fish ↔ Zsh), Changer shell par défaut

---

<!-- =============================================================================
     SYSTÈME DE LOGS D'INSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

[🔝 Retour en haut](#dotfiles-paveldelhomme)

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
- ✅ Fichiers documentation (`STATUS.md`, `TODOS.md`, `docs/REFACTOR_HISTORY.md`, `docs/STRUCTURE.md`)
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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🎮 NVIDIA RTX 3060

### Configuration automatique
- Pilotes propriétaires installés
- Xorg configuré (PrimaryGPU)
- GRUB optimisé (nomodeset)
- nvidia-prime installé

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Vérifications

Vérifier l'état du GPU :

```bash
nvidia-smi
```

Forcer une application à utiliser NVIDIA :

```bash
prime-run <app>
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Important
1. Branchez l'écran sur la **carte NVIDIA** (pas carte mère)
2. Dans le BIOS : `Primary Display` = `PCI-E` ou `Discrete`
3. Redémarrez après installation

---

<!-- =============================================================================
     MAINTENANCE
     ============================================================================= -->

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Dans le menu scripts/setup.sh

1. **Voir ce qui manque** : Option 50
2. **Installer individuellement** : Option 51 (un par un) ou Option 52 (tout automatique)
3. **Suivre les logs** : Option 53 pour voir ce qui est fait
4. **Valider installation** : Option 23 (validation exhaustive)
5. **Configurer auto-sync** : Option 12 (synchronisation automatique Git)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Après installation

- **Redémarrer** pour appliquer toutes les configurations
- **Vérifications** : `flutter doctor`, `docker login`, `nvidia-smi`
- **Configuration apps** : Cursor login, Proton Pass
- **Consulter logs** : Option 53 ou `less ~/dotfiles/logs/install.log`

---

<!-- =============================================================================
     ROLLBACK / DÉSINSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Rollback Git uniquement

Pour revenir à une version précédente des dotfiles (sans désinstaller les applications) :

```bash
bash ~/dotfiles/scripts/uninstall/rollback_git.sh
```

Options disponibles :
- Revenir au commit précédent (HEAD~1)
- Revenir à un commit spécifique (par hash)
- Revenir à origin/main (dernière version distante)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🖥️ Gestion des VM (Tests en environnement isolé)

Système complet de gestion de VM en ligne de commande pour tester les dotfiles dans un environnement complètement isolé.

### Installation QEMU/KVM

Via le menu `scripts/setup.sh` (option 11) ou directement :
```bash
bash ~/dotfiles/scripts/install/tools/install_qemu_full.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

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

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Avantages

- ✅ **100% en ligne de commande** : Pas besoin de virt-manager GUI
- ✅ **Tests en environnement isolé** : Votre machine reste propre
- ✅ **Rollback rapide** : Snapshots pour revenir en arrière instantanément
- ✅ **Workflow automatisé** : `make vm-test` gère tout automatiquement
- ✅ **Intégration Makefile** : Commandes simples et mémorisables

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Documentation complète

Voir `scripts/vm/README.md` pour la documentation complète avec tous les exemples.

---

<!-- =============================================================================
     LICENCE & AUTEUR
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📄 Licence

Configuration personnelle - libre d'utilisation et modification.

[🔝 Retour en haut](#dotfiles-paveldelhomme)

## 👤 Auteur

**PavelDelhomme**
- GitHub: [@PavelDelhomme](https://github.com/PavelDelhomme)

---

*Dernière mise à jour : Décembre 2024*
[🔝 Retour en haut](#dotfiles-paveldelhomme)