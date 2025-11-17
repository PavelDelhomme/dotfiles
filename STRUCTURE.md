# Structure complète des dotfiles

## Fichiers principaux à la racine

- `bootstrap.sh` - Script principal pour installer depuis zéro (curl) - **Configuration Git automatique**
- `setup.sh` - Menu interactif modulaire pour installer/configurer - **22 options disponibles**

## Structure scripts/

```
scripts/
├── config/                    # Configurations unitaires
│   ├── git_config.sh          # Config Git (nom, email)
│   ├── git_remote.sh          # Remote GitHub (SSH/HTTPS)
│   ├── qemu_packages.sh       # Installation paquets QEMU uniquement
│   ├── qemu_network.sh         # Configuration réseau NAT
│   ├── qemu_libvirt.sh         # Configuration permissions libvirt
│   └── README.md
│
├── install/                    # Scripts d'installation
│   ├── system/
│   │   ├── packages_base.sh   # Paquets de base (btop inclus)
│   │   └── package_managers.sh # yay, snap, flatpak
│   ├── apps/                  # Applications utilisateur
│   │   ├── install_brave.sh   # Brave Browser
│   │   ├── install_cursor.sh  # Cursor IDE
│   │   └── install_portproton.sh # PortProton
│   ├── dev/                   # Outils de développement
│   │   ├── install_docker.sh  # Docker & Docker Compose
│   │   ├── install_docker_tools.sh # Outils build (make, gcc, cmake)
│   │   └── install_go.sh      # Go (Golang)
│   └── tools/                 # Outils système
│       └── install_yay.sh    # yay AUR helper
│
├── sync/                       # Synchronisation Git
│   ├── git_auto_sync.sh        # Script de synchronisation (pull/push)
│   └── install_auto_sync.sh    # Installation systemd timer
│
├── test/                       # Validation & tests (NOUVEAU)
│   └── validate_setup.sh       # Validation complète du setup
│
└── vm/                         # Gestion VM
    └── create_test_vm.sh       # Création VM de test
```

## Descriptions des scripts

### Scripts d'installation (scripts/install/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `apps/install_brave.sh` | Installation Brave Browser. Support Arch (yay), Debian, Fedora. | Option 17 |
| `apps/install_cursor.sh` | Installation Cursor IDE (AppImage). Création alias via add_alias. | Option 8 |
| `apps/install_portproton.sh` | Installation PortProton via Flatpak. Création alias via add_alias. | Option 9 |
| `dev/install_docker.sh` | Installation complète Docker & Docker Compose. Support Arch/Debian/Fedora. BuildKit activé. Login Docker Hub avec 2FA. | Option 15 |
| `dev/install_docker.sh --desktop-only` | Installation Docker Desktop uniquement | Option 16 |
| `dev/install_docker_tools.sh` | Installation outils de build (base-devel, make, gcc, pkg-config, cmake) pour Arch Linux | - |
| `dev/install_go.sh` | Installation Go (Golang). Détection version actuelle. Utilise add_to_path si disponible. | Option 19 |
| `tools/install_yay.sh` | Installation yay AUR helper depuis source. Configuration automatique. | Option 18 |

### Scripts de synchronisation (scripts/sync/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `git_auto_sync.sh` | Synchronisation automatique Git (pull/push). Gestion des conflits. | Option 13 |
| `install_auto_sync.sh` | Installation systemd timer pour auto-sync toutes les heures | Option 12 |

### Scripts de test (scripts/test/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `validate_setup.sh` | Validation complète du setup. Vérifie fonctions, PATH, services, Git, outils. | Option 22 |

## Workflow d'utilisation

### 1. Installation complète (nouvelle machine)

```bash
# Une seule ligne
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

**Ce que fait bootstrap.sh :**
1. Installe Git si nécessaire
2. Configure l'identité Git (compte perso par défaut)
3. Configure credential helper (cache)
4. Génère clé SSH ED25519 si absente
5. Copie clé publique dans presse-papier
6. Ouvre GitHub pour ajouter la clé
7. Teste la connexion SSH
8. Clone le repo dotfiles
9. Lance setup.sh (menu interactif)

### 2. Menu interactif (setup.sh)

**Options principales :**
- 1-2 : Configuration Git
- 3-4 : Installation paquets de base et gestionnaires
- 5-7 : Configuration QEMU/KVM
- 8-9 : Installation Cursor et PortProton
- 10 : Installation complète système (avec prompts optionnels)
- 11 : Configuration complète QEMU
- 12-14 : Auto-sync Git (installation, test, statut)
- 15-19 : Installations Docker, Brave, yay, Go
- 20 : Recharger configuration ZSH
- 21 : Installer fonctions USB test
- 22 : Validation complète du setup

### 3. Cas d'usage

#### Nouvelle machine
```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
# Répondre aux prompts
# Choisir option 10 pour installation complète
```

#### Mise à jour dotfiles
```bash
cd ~/dotfiles
git pull
bash setup.sh
# Choisir les options nécessaires
```

#### Validation setup
```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
# Ou via menu : option 22
```

#### Installation spécifique
```bash
# Applications
bash ~/dotfiles/scripts/install/apps/install_brave.sh
bash ~/dotfiles/scripts/install/apps/install_cursor.sh
bash ~/dotfiles/scripts/install/apps/install_portproton.sh

# Outils de développement
bash ~/dotfiles/scripts/install/dev/install_docker.sh
bash ~/dotfiles/scripts/install/dev/install_go.sh

# Outils système
bash ~/dotfiles/scripts/install/tools/install_yay.sh
```

## Ordre d'exécution recommandé

1. **bootstrap.sh** → Configuration Git + Clone repo
2. **setup.sh option 3-4** → Paquets de base + Gestionnaires
3. **setup.sh option 18** → Installer yay (si Arch)
4. **setup.sh option 15** → Installer Docker
5. **setup.sh option 8-9** → Installer Cursor + PortProton
6. **setup.sh option 19** → Installer Go
7. **setup.sh option 12** → Configurer auto-sync Git
8. **setup.sh option 22** → Valider le setup

## Notes importantes

- **auto_sync_dotfiles.sh** (racine) a été supprimé → Utiliser `scripts/sync/git_auto_sync.sh`
- **install_go.sh** (racine) a été déplacé → Utiliser `scripts/install/dev/install_go.sh`
- Les scripts sont organisés par catégorie : `apps/`, `dev/`, `tools/`, `system/`
- Les scripts utilisent `add_alias` et `add_to_path` si disponibles
- Fallback manuel si les fonctions ne sont pas chargées

## Utilisation rapide

### Configuration unitaire QEMU (si déjà installé)

```bash
# Juste le réseau
bash ~/dotfiles/scripts/config/qemu_network.sh

# Juste les permissions
bash ~/dotfiles/scripts/config/qemu_libvirt.sh

# Juste installer paquets
bash ~/dotfiles/scripts/config/qemu_packages.sh
```

### Menu interactif

```bash
bash ~/dotfiles/setup.sh
```

### Bootstrap complet

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

