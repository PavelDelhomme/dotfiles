# Scripts de Configuration - Documentation

⚠️ **MIGRATION VERS CONFIGMAN**

Les scripts de configuration ont été migrés vers `configman` (gestionnaire modulaire).

## Nouvelle utilisation (recommandé)

Utilisez `configman` pour accéder à toutes les configurations :

```bash
# Menu interactif
configman

# Configuration directe
configman git
configman git-remote
configman symlinks
configman shell
configman qemu-libvirt
configman qemu-network
configman qemu-packages
```

## Structure

Les scripts sont maintenant dans :
```
zsh/functions/configman/
├── core/configman.zsh
└── modules/
    ├── git/              # git_config.sh, git_remote.sh
    ├── qemu/             # qemu_libvirt.sh, qemu_network.sh, qemu_packages.sh
    ├── symlinks/         # create_symlinks.sh
    └── shell/            # shell_manager.sh
```

## Utilisation directe (ancienne méthode)

Si vous préférez utiliser les scripts directement :

```bash
# Configuration Git
bash ~/dotfiles/zsh/functions/configman/modules/git/git_config.sh
bash ~/dotfiles/zsh/functions/configman/modules/git/git_remote.sh

# Configuration QEMU (unitaire)
bash ~/dotfiles/zsh/functions/configman/modules/qemu/qemu_packages.sh
bash ~/dotfiles/zsh/functions/configman/modules/qemu/qemu_network.sh
bash ~/dotfiles/zsh/functions/configman/modules/qemu/qemu_libvirt.sh

# Symlinks
bash ~/dotfiles/zsh/functions/configman/modules/symlinks/create_symlinks.sh

# Shell
bash ~/dotfiles/zsh/functions/configman/modules/shell/shell_manager.sh
```

## Avantages de configman

- **Menu interactif** : Accès facile à toutes les configurations
- **Structure modulaire** : Organisation claire et extensible
- **Unitaire** : Chaque module fait une seule chose
- **Réutilisable** : Peut être exécuté plusieurs fois sans problème
- **Idempotent** : Vérifie l'état avant de modifier

## Documentation complète

Voir la section [Configman - Gestionnaire de Configurations](#%EF%B8%8F-configman---gestionnaire-de-configurations) dans le README.md principal.
