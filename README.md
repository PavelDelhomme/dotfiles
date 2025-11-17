# Dotfiles - Paul Delhomme

Configuration personnelle pour Manjaro Linux avec installation automatisée complète.

## 🚀 Installation rapide (nouvelle machine)

**UNE SEULE LIGNE** pour installer et configurer tous les dotfiles :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Cette commande va :
- Installer Git si nécessaire
- Configurer Git automatiquement (identité auto-détectée)
- Générer une clé SSH et l'ajouter à GitHub
- Cloner le repo dotfiles
- Lancer le menu interactif d'installation

### Installation manuelle (alternative)

```bash
# 1. Installer git
sudo pacman -S git

# 2. Cloner ce repo
git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles

# 3. Lancer le setup
cd ~/dotfiles
bash setup.sh
```

Le script `setup.sh` propose un menu interactif avec toutes les options d'installation.

## 📁 Structure du repository

Voir `STRUCTURE.md` pour la structure complète et détaillée.

Structure principale :
```
~/dotfiles/
├── bootstrap.sh                 # Installation en une ligne (curl)
├── setup.sh                     # Menu interactif modulaire
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

## 🔧 Fichiers de configuration

### `.env` - Variables d'environnement

Contient toutes les variables PATH nécessaires :
- Java (pour Flutter/Android)
- Android SDK
- Flutter
- Node.js global packages
- Cargo (Rust)
- Binaires locaux

### `aliases.zsh` - Aliases

Raccourcis pratiques pour :
- Navigation (`..`, `...`)
- Git (`gs`, `ga`, `gc`, `gp`)
- Docker (`dc`, `dps`)
- Système (`update`, `install`)
- Flutter (`fl`, `fld`, `flr`)

### `functions.zsh` - Fonctions

Fonctions utiles :
- `mkcd` - Créer dossier et y aller
- `gclone` - Git clone et cd
- `docker-cleanup` - Nettoyage Docker
- `backup` - Backup rapide avec timestamp

## 🖥️ Installation complète du système

Le script `setup.sh` (menu interactif) permet d'installer et configurer automatiquement :

### Gestionnaires de paquets
- ✅ yay (AUR helper)
- ✅ snap
- ✅ flatpak + flathub

### Applications
- ✅ Brave Browser
- ✅ Cursor IDE (AppImage + .desktop)
- ✅ Discord
- ✅ KeePassXC
- ✅ Docker & Docker Compose (optimisé BuildKit)
- ✅ Proton Mail & Proton Pass
- ✅ PortProton (jeux Windows)
- ✅ BlueMail
- ✅ Session Desktop

### Environnement de développement
- ✅ Flutter SDK
- ✅ Android Studio & SDK
- ✅ Node.js & npm
- ✅ Git & GitHub SSH
- ✅ Outils de build (make, cmake, gcc)

### Matériel
- ✅ Pilotes NVIDIA RTX 3060
- ✅ Configuration Xorg pour GPU principal
- ✅ nvidia-prime pour gestion hybride

## 📝 Fonctionnalités intelligentes

### Vérifications avant installation
Le script vérifie **toujours** si un paquet est déjà installé avant de l'installer :
- Évite les installations redondantes
- Messages clairs (installé/ignoré)
- Gère les conflits automatiquement

### Backup automatique
Lors du setup, les fichiers de config existants sont sauvegardés dans :
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

### Mise à jour de Cursor
Un script dédié est créé :
```bash
update-cursor.sh
```

## 🎯 Usage quotidien

### Recharger la configuration
```bash
source ~/.zshrc
# ou
exec zsh
```

### Mettre à jour les dotfiles
```bash
cd ~/dotfiles
git pull
bash setup.sh
```

### Vérifications système
```bash
flutter doctor          # Flutter
docker --version        # Docker
nvidia-smi             # NVIDIA
android-studio         # Android Studio
```

## 🔐 Configuration GitHub SSH

Le script génère automatiquement une clé SSH ED25519 et :
1. Copie la clé publique dans le presse-papier
2. Attend que vous l'ajoutiez sur GitHub
3. Teste la connexion

Clé stockée dans : `~/.ssh/id_ed25519`

## 🐳 Docker

### Installation

Installation complète via le menu setup.sh (option 15) :
- Docker Engine
- Docker Compose
- BuildKit activé par défaut
- Groupe docker configuré
- Login Docker Hub avec support 2FA

```bash
# Via le menu
bash ~/dotfiles/setup.sh
# Choisir option 15

# Ou directement
bash ~/dotfiles/scripts/install/dev/install_docker.sh
```

### Configuration BuildKit

BuildKit est automatiquement activé dans `~/.docker/daemon.json` :
```json
{
  "features": {
    "buildkit": true
  }
}
```

### Docker Desktop (optionnel)

Installation via option 16 du menu ou :
```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh --desktop-only
```

### Login Docker Hub

Le script propose automatiquement de se connecter à Docker Hub :
- Support 2FA (utilisez un Personal Access Token)
- Génération de token : https://hub.docker.com/settings/security

```bash
docker login
# Test avec
docker run hello-world
```

### Commandes utiles

```bash
docker --version              # Vérifier la version
docker ps                     # Lister les conteneurs
docker-compose up             # Lancer avec docker-compose
docker compose up             # Lancer avec docker compose (plugin)
```

## 🔄 Auto-Synchronisation Git

Système de synchronisation automatique des dotfiles toutes les heures via systemd timer.

### Installation

Via le menu setup.sh (option 12) ou directement :
```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

### Fonctionnement

- **Timer systemd** : Exécution toutes les heures
- **Pull automatique** : Récupère les modifications distantes
- **Push automatique** : Envoie les modifications locales (si changements)
- **Logs** : Disponibles dans `~/dotfiles/auto_sync.log`

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

### Configuration

Le timer est configuré pour :
- Démarrer 5 minutes après le boot
- S'exécuter toutes les heures
- Précision de 1 minute

## 🌐 Brave Browser

Installation optionnelle du navigateur Brave.

### Installation

Via le menu setup.sh (option 17) ou directement :
```bash
bash ~/dotfiles/scripts/install/apps/install_brave.sh
```

### Support

- **Arch Linux** : Installation via yay (brave-bin)
- **Debian/Ubuntu** : Dépôt officiel Brave
- **Fedora** : Dépôt officiel Brave
- **Autres** : Installation manuelle ou Flatpak

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
│   └── install_auto_sync.sh     # Installation systemd timer
│
├── test/                 # Validation & tests
│   └── validate_setup.sh         # Validation complète du setup
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

## ✅ Validation du Setup

Script de validation complète pour vérifier toutes les installations et configurations.

### Utilisation

Via le menu setup.sh (option 22) ou directement :
```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

### Vérifications effectuées

- ✅ **Fonctions ZSH** : add_alias, add_to_path, clean_path
- ✅ **PATH** : Go, Flutter, Android SDK, Dart
- ✅ **Services** : systemd timer, Docker, SSH agent
- ✅ **Git** : user.name, user.email, credential.helper, SSH key
- ✅ **Outils** : Go, Docker, Cursor, yay, make, gcc, cmake
- ✅ **Fichiers** : zshrc_custom, env.sh, aliases.zsh, etc.

### Rapport

Le script affiche un rapport avec :
- ✅ Réussis (vert)
- ❌ Échecs (rouge)
- ⚠️ Avertissements (jaune)

## 📱 Flutter & Android

### Variables d'environnement (dans `.env`)
```bash
export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
export ANDROID_SDK_ROOT='/opt/android-sdk'
```

### Première utilisation
```bash
flutter doctor
android-studio  # Premier lancement pour config SDK
```

## 🎮 NVIDIA RTX 3060

### Configuration automatique
- Pilotes propriétaires installés
- Xorg configuré (PrimaryGPU)
- GRUB optimisé (nomodeset)
- nvidia-prime installé

### Vérifications
```bash
nvidia-smi              # État GPU
prime-run <app>         # Forcer app sur NVIDIA
```

### Important
1. Branchez l'écran sur la **carte NVIDIA** (pas carte mère)
2. Dans le BIOS : `Primary Display` = `PCI-E` ou `Discrete`
3. Redémarrez après installation

## 📧 BlueMail - Configuration

Comptes email à configurer :
- `paul@delhomme.ovh`
- `dumb@delhomme.ovh`

Paramètres serveur :
- **IMAP** : `mail.delhomme.ovh:993` (SSL/TLS)
- **SMTP** : `mail.delhomme.ovh:465 ou 587` (SSL/TLS)

## 🛠️ Maintenance

### Mettre à jour le système
```bash
update          # alias pour sudo pacman -Syu
yayup           # alias pour yay -Syu
```

### Nettoyer Docker
```bash
docker-cleanup  # fonction custom
```

### Mettre à jour Cursor
```bash
update-cursor.sh
```

## 📦 Structure recommandée après installation

```
~/
├── dotfiles/                   # Ce repo
│   ├── .zshrc
│   ├── .env
│   ├── aliases.zsh
│   ├── functions.zsh
│   ├── setup.sh
│   └── archive_manjaro_setup_final.sh (ancien script, archivé)
├── .zshrc -> ~/dotfiles/.zshrc    # Symlink
├── .gitconfig -> ~/dotfiles/.gitconfig
└── .ssh/
    ├── id_ed25519              # Clé SSH GitHub
    └── config                  # Config SSH
```

## 🚨 Troubleshooting

### Flutter pas dans le PATH
Vérifiez que `~/dotfiles/.env` est sourcé dans `.zshrc` et contient :
```bash
export PATH=$PATH:/opt/flutter/bin
```

### Docker : permission denied
```bash
sudo usermod -aG docker $USER
# Puis redémarrer la session
```

### NVIDIA : écran noir au boot
Vérifiez GRUB :
```bash
sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset"
sudo update-grub
```

### Dotfiles non sourcés
```bash
grep "source ~/dotfiles" ~/.zshrc
# Si absent, relancez setup.sh
```

## 🔄 Workflow complet (nouvelle machine)

1. **Installer Manjaro**
2. **Installer Git** : `sudo pacman -S git`
3. **Cloner dotfiles** : `git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles`
4. **Lancer setup** : `bash ~/dotfiles/setup.sh`
5. **Répondre aux prompts** (nom, email, installation système)
6. **Redémarrer**
7. **Vérifications** : `flutter doctor`, `docker login`, `nvidia-smi`
8. **Configuration apps** : Cursor login, Proton Pass, BlueMail

## 📄 Licence

Configuration personnelle - libre d'utilisation et modification.

## 👤 Auteur

**Paul Pavel Théo Delhomme**
- Email: paul@delhomme.ovh
- GitHub: [@PavelDelhomme](https://github.com/PavelDelhomme)

---

*Dernière mise à jour : Novembre 2025*
