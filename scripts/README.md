# Scripts Dotfiles - Documentation

Cette structure organise tous les scripts d'installation, de synchronisation et de gestion de VM.

## Structure

```
scripts/
├── install/          # Scripts d'installation des outils
│   ├── apps/                      # Applications utilisateur
│   │   ├── install_brave.sh       # Brave Browser
│   │   ├── install_cursor.sh      # Cursor IDE
│   │   └── install_portproton.sh  # PortProton
│   ├── dev/                       # Outils de développement
│   │   ├── install_docker.sh      # Docker & Docker Compose
│   │   ├── install_docker_tools.sh # Outils build (Arch)
│   │   └── install_go.sh          # Go (Golang)
│   ├── tools/                     # Outils système
│   │   └── install_yay.sh         # yay (AUR helper)
│   ├── system/                    # Paquets système
│   │   ├── packages_base.sh       # Paquets de base
│   │   └── package_managers.sh    # Gestionnaires (yay, snap, flatpak)
│   ├── install_all.sh             # Installation complète
│   └── install_qemu_simple.sh     # Installation QEMU/KVM
│
├── sync/            # Scripts de synchronisation Git
│   ├── git_auto_sync.sh            # Script de synchronisation automatique
│   └── install_auto_sync.sh        # Installation du système de sync automatique
│
└── vm/              # Scripts pour gestion de VM de test
    └── create_test_vm.sh           # Création d'une VM de test pour tester dotfiles
```

## Installation complète

Pour installer tous les outils automatiquement :

```bash
bash ~/dotfiles/scripts/install/install_all.sh
```

Ou installer individuellement :

```bash
# Git (déjà installé normalement)

# Applications
bash ~/dotfiles/scripts/install/apps/install_cursor.sh
bash ~/dotfiles/scripts/install/apps/install_brave.sh
bash ~/dotfiles/scripts/install/apps/install_portproton.sh

# Outils de développement
bash ~/dotfiles/scripts/install/dev/install_go.sh
bash ~/dotfiles/scripts/install/dev/install_docker.sh

# Outils système
bash ~/dotfiles/scripts/install/tools/install_yay.sh

# QEMU/KVM
bash ~/dotfiles/scripts/install/install_qemu_simple.sh
```

## Synchronisation automatique Git

Le système de synchronisation automatique permet de :
- Pull les modifications distantes toutes les heures
- Push automatiquement les modifications locales (si modifications détectées)
- Éviter les conflits en gérant proprement les erreurs

### Installation

```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

Cela configure un timer systemd qui s'exécute toutes les heures.

### Commandes utiles

```bash
# Vérifier le statut
systemctl --user status dotfiles-sync.timer

# Voir tous les timers
systemctl --user list-timers

# Arrêter/démarrer
systemctl --user stop dotfiles-sync.timer
systemctl --user start dotfiles-sync.timer

# Voir les logs
journalctl --user -u dotfiles-sync.service -f
```

### Logs

Les logs sont disponibles dans : `~/dotfiles/auto_sync.log`

## VM de test

Pour créer une VM de test pour tester le bootstrap :

```bash
bash ~/dotfiles/scripts/vm/create_test_vm.sh
```

Cela va :
1. Vérifier/installer QEMU/KVM si nécessaire
2. Télécharger une ISO Linux
3. Lancer virt-manager pour créer la VM
4. Créer un script helper `test-dotfiles-vm`

Dans la VM, testez le bootstrap :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

## Bootstrap complet

Pour installer tout depuis zéro sur une nouvelle machine :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Le bootstrap va :
1. Installer Git si nécessaire
2. Configurer Git globalement
3. Cloner le repo dotfiles
4. Lancer setup.sh
5. Proposer d'installer tous les outils (Cursor, PortProton, QEMU)
6. Proposer d'installer la synchronisation automatique

