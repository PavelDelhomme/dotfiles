# Managers (utilisation) — Dotfiles

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte doc** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Carte code** : [`../CODEMAP.md`](../CODEMAP.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`../../STATUS.md`](../../STATUS.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md)

---

> Vue d’usage complémentaire à [`../managers/`](../managers/) (docs métier par manager) et [`../man/`](../man/) (pages man Markdown). Pour le smoke test, voir [`../TESTS.md`](../TESTS.md) (Bloc G).

---

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
- 🖥  **displayman** : Gestionnaire écran / luminosité / DDC (preset couleur, range HDMI, OSD)
- 📑 **diffman** : Comparateur de fichiers (diff coloré, côte à côte, rapports multi-fichiers)
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

### 🖥  Displayman - Gestionnaire Écran / Luminosité / DDC

Gestionnaire des écrans externes : luminosité, contraste, preset couleur,
diagnostic Full vs Limited range HDMI, et guide OSD physique (joystick) pour
les moniteurs dont le firmware DDC refuse certaines écritures (Mi Monitor).

**Utilisation :**
```bash
displayman                          # aide rapide (stdout, non interactif)
displayman detect                   # liste les écrans détectés (ddcutil)
displayman dump 1                   # dump des VCP utiles écran 1
displayman brightness 1 80          # règle la luminosité (VCP 10) à 80 %
displayman contrast 1 75            # règle le contraste (VCP 12)
displayman preset 1 srgb            # tente bascule preset couleur (VCP 14)
displayman reset 1                  # reset usine couleur (avec confirmation TTY)
displayman range                    # diagnostic Full / Limited HDMI + GPU
displayman osd-guide                # guide OSD physique (joystick au dos)
displayman --help                   # menu interactif (TTY requis)
```

**Pré-requis :**
- `ddcutil` (Arch : `sudo pacman -S ddcutil` · Debian/Ubuntu : `sudo apt install ddcutil`)
- Accès aux `/dev/i2c-*` (groupe `i2c` ou ACL automatique sur Arch récent)
- Optionnel : `kscreen-doctor` (Plasma) pour le complément KDE

**Documentation :** [`../man/displayman.md`](../man/displayman.md) + guide complet
[`SCREEN_DISPLAY.md`](SCREEN_DISPLAY.md) (étape A diagnostic DDC, étape B OSD physique,
étape C Full Range HDMI NVIDIA).

### 📑 Diffman — comparateur de fichiers

Wrapper autour de `git diff --no-index` (couleurs) ou `diff` GNU : diff **unifié** avec surlignage vert/rouge, vue **côte à côte** (`diff -y`), **rapport** concaténé pour plusieurs fichiers (référence unique ou toutes les paires), et **`diff3`** si l’outil est présent.

**Utilisation :**
```bash
diffman help
diffman compare .env .env.production.example    # unifié coloré (rc 0 = identiques, 1 = diff)
diffman side .env .env.production.example       # deux colonnes + couleurs si GNU diff
diffman report -o /tmp/rapport.txt a b c        # a vs b, a vs c (1er fichier = référence)
diffman report --all-pairs -o /tmp/tout.txt a b c   # paires a|b, a|c, b|c (max 8 fichiers)
diffman diff3 mine.txt parent.txt theirs.txt   # fusion 3 voies (nécessite diff3)
```

**Variables :** `NO_COLOR`, `FORCE_COLOR=1` (sortie colorée même hors TTY).

**Documentation :** [`../man/diffman.md`](../man/diffman.md)

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
- **Informations IP** : IP publique, géolocalisation, IPv4/IPv6 locales (via `ip -4|-6 -o addr show` : une ligne par adresse avec **nom d’interface** aligné sur `ip addr`)
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

**Documentation :** `help moduleman`, `man moduleman` ou voir `docs/managers/MODULEMAN_EXPLICATION.md`

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

Voir `docs/compatibility/COMPATIBILITY.md` pour plus de détails.

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

