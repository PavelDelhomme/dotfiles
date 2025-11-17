# Dotfiles - Paul Delhomme

Configuration personnelle pour Manjaro Linux avec installation automatisée complète.

## 🚀 Installation rapide (nouvelle machine)

Sur une **nouvelle installation Manjaro**, il suffit de :

```bash
# 1. Installer git
sudo pacman -S git

# 2. Cloner ce repo
git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles

# 3. Lancer le setup
cd ~/dotfiles
bash setup.sh
```

Le script `setup.sh` va :
- Créer tous les symlinks nécessaires
- Configurer le sourcing dans `.zshrc`
- Créer les fichiers manquants (`.env`, `aliases.zsh`, `functions.zsh`)
- Proposer de lancer l'installation complète du système

## 📁 Structure du repository

```
~/dotfiles/
├── setup.sh                    # Script d'initialisation des dotfiles
├── manjaro_setup_final.sh      # Installation complète du système
├── .zshrc                       # Configuration ZSH principale
├── .env                         # Variables d'environnement (PATH, etc.)
├── aliases.zsh                  # Aliases personnalisés
├── functions.zsh                # Fonctions shell personnalisées
├── .gitconfig                   # Configuration Git
├── .vimrc                       # Configuration Vim (optionnel)
└── README.md                    # Ce fichier
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

Le script `manjaro_setup_final.sh` installe et configure automatiquement :

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

Configuration optimisée avec :
- BuildKit activé (builds plus rapides)
- Groupe docker configuré
- Login Docker Hub requis après installation

```bash
docker login
# ou
docker login -u votre_username
```

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
│   └── manjaro_setup_final.sh
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
