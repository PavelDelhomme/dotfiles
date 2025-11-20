# Gestion des VM - Tests en environnement isolé

Système complet de gestion de VM en ligne de commande pour tester les dotfiles dans un environnement isolé.

## 🎯 Objectif

Permettre de tester les dotfiles directement sur votre machine mais dans un environnement complètement isolé (VM), avec possibilité de rollback rapide via snapshots.

## 📋 Prérequis

- QEMU/KVM installé et configuré
- Support de virtualisation matérielle activé dans le BIOS
- Permissions libvirt configurées

**Installation automatique:**
```bash
bash scripts/install/tools/install_qemu_full.sh
```

## 🚀 Utilisation rapide

### Via Makefile (recommandé)

Menu interactif :

```bash
make vm-menu
```

Créer une VM de test :

```bash
make vm-create VM=test-dotfiles MEMORY=2048 VCPUS=2 DISK=20
```

Démarrer la VM :

```bash
make vm-start VM=test-dotfiles
```

Créer un snapshot avant test :

```bash
make vm-snapshot VM=test-dotfiles NAME=clean DESC="Installation propre"
```

Tester les dotfiles dans la VM :

```bash
make vm-test VM=test-dotfiles
```

Si problème, rollback :

```bash
make vm-rollback VM=test-dotfiles SNAPSHOT=clean
```

Lister les VM :

```bash
make vm-list
```

Lister les snapshots :

```bash
make vm-snapshots VM=test-dotfiles
```

Arrêter la VM :

```bash
make vm-stop VM=test-dotfiles
```

### Via script directement

Menu interactif :

```bash
bash scripts/vm/vm_manager.sh
```

Ou utiliser les fonctions directement :

```bash
source scripts/vm/vm_manager.sh
```

Créer une VM :

```bash
create_vm "test-dotfiles" 2048 2 20
```

Démarrer la VM :

```bash
start_vm "test-dotfiles"
```

Créer un snapshot :

```bash
create_snapshot "test-dotfiles" "clean" "Installation propre"
```

Tester les dotfiles dans la VM :

```bash
test_dotfiles_in_vm "test-dotfiles"
```

Restaurer un snapshot :

```bash
restore_snapshot "test-dotfiles" "clean"
```

## 🔄 Workflow de test recommandé

1. **Créer la VM:**
   ```bash
   make vm-create VM=test-dotfiles MEMORY=2048 VCPUS=2 DISK=20
   ```

2. **Démarrer la VM:**
   ```bash
   make vm-start VM=test-dotfiles
   ```

3. **Installer un OS dans la VM:**
   - Connectez-vous: `virt-viewer test-dotfiles`
   - Installez une distribution Linux (Arch, Manjaro, etc.)

4. **Créer un snapshot "clean" après installation:**
   ```bash
   make vm-snapshot VM=test-dotfiles NAME=clean DESC="Installation propre"
   ```

5. **Tester les dotfiles:**
   ```bash
   make vm-test VM=test-dotfiles
   ```
   - Dans la VM, exécutez:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
     ```

6. **Si problème, rollback:**
   ```bash
   make vm-rollback VM=test-dotfiles SNAPSHOT=clean
   ```

7. **Créer des snapshots intermédiaires:**
   Créer snapshot après bootstrap :

   ```bash
   make vm-snapshot VM=test-dotfiles NAME=after-bootstrap DESC="Après bootstrap"
   ```

   Créer snapshot après setup.sh :

   ```bash
   make vm-snapshot VM=test-dotfiles NAME=after-setup DESC="Après setup.sh"
   ```

## 📝 Fonctions disponibles

### Gestion des VM
- `list_vms [--all]` - Lister les VM (--all pour inclure arrêtées)
- `create_vm [name] [memory] [vcpus] [disk_size] [iso_path]` - Créer une VM
- `start_vm <vm_name>` - Démarrer une VM
- `stop_vm <vm_name> [--force]` - Arrêter une VM
- `show_vm_info <vm_name>` - Afficher les infos d'une VM
- `delete_vm <vm_name>` - Supprimer une VM complètement

### Gestion des snapshots
- `create_snapshot <vm_name> <snapshot_name> [description]` - Créer un snapshot
- `list_snapshots <vm_name>` - Lister les snapshots
- `restore_snapshot <vm_name> <snapshot_name>` - Restaurer un snapshot (rollback)
- `delete_snapshot <vm_name> <snapshot_name>` - Supprimer un snapshot

### Tests
- `test_dotfiles_in_vm <vm_name>` - Workflow complet de test des dotfiles

## 🎯 Exemples d'utilisation

### Créer et tester rapidement

Créer la VM :

```bash
make vm-create VM=test-dotfiles
```

Démarrer et installer OS (via virt-viewer) :

```bash
make vm-start VM=test-dotfiles
```

```bash
virt-viewer test-dotfiles
```

Après installation, créer snapshot :

```bash
make vm-snapshot VM=test-dotfiles NAME=clean
```

Tester dotfiles :

```bash
make vm-test VM=test-dotfiles
```

Si erreur, rollback :

```bash
make vm-rollback VM=test-dotfiles SNAPSHOT=clean
```

### Workflow avec plusieurs snapshots

Snapshot initial :

```bash
make vm-snapshot VM=test-dotfiles NAME=clean
```

Test bootstrap :

```bash
make vm-test VM=test-dotfiles
```

... tester dans la VM ...

Snapshot après bootstrap :

```bash
make vm-snapshot VM=test-dotfiles NAME=after-bootstrap
```

Test setup.sh :

... tester dans la VM ...

Snapshot après setup.sh :

```bash
make vm-snapshot VM=test-dotfiles NAME=after-setup
```

Si problème à une étape, rollback :

```bash
make vm-rollback VM=test-dotfiles SNAPSHOT=after-bootstrap
```

## 📁 Emplacements

- **VM** : `$HOME/VMs/`
- **ISOs** : `$HOME/ISOs/`
- **Scripts** : `scripts/vm/`

## ⚠️ Notes importantes

1. **Format QCOW2** : Les disques sont créés en QCOW2 pour supporter les snapshots
2. **Snapshots** : Les snapshots sont stockés dans l'image QCOW2 de la VM
3. **Arrêt pour snapshots** : Les snapshots sont créés avec la VM arrêtée pour cohérence
4. **Rollback** : Le rollback restaure l'état complet de la VM au moment du snapshot

## 🔧 Dépannage

### VM ne démarre pas
Vérifier le service libvirtd :

```bash
sudo systemctl status libvirtd
```

Démarrer le service libvirtd :

```bash
sudo systemctl start libvirtd
```

Vérifier les permissions :

```bash
groups | grep libvirt
```

### Snapshots ne fonctionnent pas
- Vérifiez que le disque est en format QCOW2
- Les snapshots nécessitent que la VM soit arrêtée

### Accès à la VM
Console graphique :

```bash
virt-viewer test-dotfiles
```

Console texte :

```bash
virsh console test-dotfiles
```

