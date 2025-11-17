# Scripts de Configuration - Documentation

Scripts modulaires pour configurer unitairement chaque composant.

## Structure

```
scripts/config/
├── git_config.sh      # Configuration Git globale (nom, email, etc.)
├── git_remote.sh      # Configuration remote GitHub (SSH/HTTPS)
├── qemu_packages.sh   # Installation paquets QEMU/KVM uniquement
├── qemu_network.sh    # Configuration réseau NAT pour VMs
└── qemu_libvirt.sh    # Configuration permissions libvirt
```

## Utilisation

### Configuration Git

```bash
# Configurer Git globalement
bash ~/dotfiles/scripts/config/git_config.sh

# Configurer remote GitHub
bash ~/dotfiles/scripts/config/git_remote.sh
```

### Configuration QEMU (unitaire)

Si QEMU est déjà installé mais mal configuré, vous pouvez configurer chaque partie séparément :

```bash
# 1. Installer uniquement les paquets (si pas installé)
bash ~/dotfiles/scripts/config/qemu_packages.sh

# 2. Configurer le réseau NAT (si réseau non fonctionnel)
bash ~/dotfiles/scripts/config/qemu_network.sh

# 3. Configurer libvirt (si permissions manquantes)
bash ~/dotfiles/scripts/config/qemu_libvirt.sh
```

## Avantages

- **Modulaire** : Configurez uniquement ce qui est nécessaire
- **Unitaire** : Chaque script fait une seule chose
- **Réutilisable** : Peut être exécuté plusieurs fois sans problème
- **Idempotent** : Vérifie l'état avant de modifier

