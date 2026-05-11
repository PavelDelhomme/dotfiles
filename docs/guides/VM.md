# Gestion des VM — Dotfiles

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte doc** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Carte code** : [`../CODEMAP.md`](../CODEMAP.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`../../STATUS.md`](../../STATUS.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md)

---


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

