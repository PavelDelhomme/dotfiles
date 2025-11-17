# Structure complète des dotfiles

## Fichiers principaux à la racine

- `bootstrap.sh` - Script principal pour installer depuis zéro (curl)
- `setup.sh` - Menu interactif modulaire pour installer/configurer

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
│   ├── install_cursor.sh
│   ├── install_portproton.sh
│   ├── install_qemu_simple.sh
│   └── install_all.sh
│
├── sync/                       # Synchronisation Git
│   ├── git_auto_sync.sh
│   └── install_auto_sync.sh
│
└── vm/                         # Gestion VM
    └── create_test_vm.sh
```

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

