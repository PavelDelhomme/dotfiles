# 📋 Liste Complète de Migration Multi-Shells

## 🎯 Objectif

Documenter **absolument tout** ce qui doit être migré pour avoir la parité complète ZSH/Fish/Bash.

---

## 📊 Vue d'ensemble

### Managers à migrer : 18

1. installman
2. configman
3. pathman
4. netman
5. gitman
6. cyberman
7. devman
8. miscman
9. aliaman
10. searchman
11. helpman
12. fileman
13. virtman
14. sshman
15. testman
16. testzshman
17. moduleman
18. manman

---

## 📝 Liste détaillée par manager

### 1. INSTALLMAN ✅

**Fichiers core :**
- [x] `zsh/functions/installman.zsh` (wrapper)
- [x] `zsh/functions/installman/core/installman.zsh` (350 lignes) → `bash/functions/installman/core/installman.sh` + `fish/functions/installman/core/installman.fish` ✅

**Modules (11 fichiers) :**
- [ ] `zsh/functions/installman/modules/flutter/install_flutter.sh`
- [ ] `zsh/functions/installman/modules/dotnet/install_dotnet.sh`
- [ ] `zsh/functions/installman/modules/emacs/install_emacs.sh`
- [ ] `zsh/functions/installman/modules/java/install_java.sh`
- [ ] `zsh/functions/installman/modules/android/install_android_studio.sh`
- [ ] `zsh/functions/installman/modules/android/install_android_tools.sh`
- [ ] `zsh/functions/installman/modules/android/accept_android_licenses.sh`
- [ ] `zsh/functions/installman/modules/docker/install_docker.sh`
- [ ] `zsh/functions/installman/modules/brave/install_brave.sh`
- [ ] `zsh/functions/installman/modules/cursor/install_cursor.sh`
- [ ] `zsh/functions/installman/modules/qemu/install_qemu.sh`
- [ ] `zsh/functions/installman/modules/ssh/install_ssh_config.sh`

**Utilitaires (4 fichiers) :**
- [ ] `zsh/functions/installman/utils/check_installed.sh`
- [ ] `zsh/functions/installman/utils/logger.sh`
- [ ] `zsh/functions/installman/utils/distro_detect.sh`
- [ ] `zsh/functions/installman/utils/path_utils.sh`

**Total installman :** 1 core + 11 modules + 4 utils = **16 fichiers**

---

### 2. CONFIGMAN ✅

**Fichiers core :**
- [x] `zsh/functions/configman.zsh` (wrapper)
- [x] `zsh/functions/configman/core/configman.zsh` → `bash/functions/configman/core/configman.sh` + `fish/functions/configman/core/configman.fish` ✅

**Modules (8 fichiers) :**
- [ ] `zsh/functions/configman/modules/git/git_config.sh`
- [ ] `zsh/functions/configman/modules/git/git_remote.sh`
- [ ] `zsh/functions/configman/modules/ssh/ssh_auto_setup.sh`
- [ ] `zsh/functions/configman/modules/ssh/ssh_config.sh`
- [ ] `zsh/functions/configman/modules/shell/shell_manager.sh`
- [ ] `zsh/functions/configman/modules/symlinks/create_symlinks.sh`
- [ ] `zsh/functions/configman/modules/prompt/p10k_config.sh`
- [ ] `zsh/functions/configman/modules/qemu/qemu_packages.sh`
- [ ] `zsh/functions/configman/modules/qemu/qemu_network.sh`
- [ ] `zsh/functions/configman/modules/qemu/qemu_libvirt.sh`

**Install :**
- [ ] `zsh/functions/configman/install/install_configman_tools.sh`

**Total configman :** 2 core + 10 modules + 1 install = **13 fichiers**

---

### 3. PATHMAN ✅

**Fichiers core :**
- [x] `zsh/functions/pathman.zsh` (wrapper)
- [x] `zsh/functions/pathman/core/pathman.zsh` → `bash/functions/pathman/core/pathman.sh` + `fish/functions/pathman/core/pathman.fish` ✅

**Total pathman :** 2 core = **2 fichiers** (convertis ✅)

---

### 4. NETMAN

**Fichiers core :**
- [ ] `zsh/functions/netman.zsh` (wrapper)
- [ ] `zsh/functions/netman/core/netman.zsh`

**Total netman :** 2 core = **2 fichiers**

---

### 5. GITMAN

**Fichiers core :**
- [ ] `zsh/functions/gitman.zsh` (wrapper)
- [ ] `zsh/functions/gitman/core/gitman.zsh`

**Modules :**
- [ ] `zsh/functions/gitman/modules/legacy/git_functions.sh`

**Utils :**
- [ ] `zsh/functions/gitman/utils/git_wrapper.sh`

**Total gitman :** 2 core + 1 module + 1 util = **4 fichiers**

---

### 6. CYBERMAN

**Fichiers core :**
- [ ] `zsh/functions/cyberman.zsh` (wrapper)
- [ ] `zsh/functions/cyberman/core/cyberman.zsh`

**Modules (nombreux) :**
- [ ] `zsh/functions/cyberman/modules/security/fuzzer_module.sh`
- [ ] `zsh/functions/cyberman/modules/security/nuclei_module.sh`
- [ ] `zsh/functions/cyberman/modules/security/sqlmap_module.sh`
- [ ] `zsh/functions/cyberman/modules/security/xss_scanner.sh`
- [ ] ... (tous les modules legacy et autres)

**Install :**
- [ ] `zsh/functions/cyberman/install/install_iot_tools.sh`
- [ ] `zsh/functions/cyberman/install/install_security_tools.sh`

**Total cyberman :** 2 core + nombreux modules + 2 install = **~30+ fichiers**

---

### 7. DEVMAN

**Fichiers core :**
- [ ] `zsh/functions/devman.zsh` (wrapper)
- [ ] `zsh/functions/devman/core/devman.zsh`

**Modules :**
- [ ] `zsh/functions/devman/modules/legacy/c.sh`
- [ ] `zsh/functions/devman/modules/legacy/docker.sh`
- [ ] `zsh/functions/devman/modules/legacy/go.sh`
- [ ] `zsh/functions/devman/modules/legacy/make.sh`
- [ ] `zsh/functions/devman/modules/legacy/projects/weedlyweb.sh`
- [ ] `zsh/functions/devman/modules/legacy/projects/cyna.sh`

**Total devman :** 2 core + 6 modules = **8 fichiers**

---

### 8. MISCMAN

**Fichiers core :**
- [ ] `zsh/functions/miscman.zsh` (wrapper)
- [ ] `zsh/functions/miscman/core/miscman.zsh`

**Modules :**
- [ ] `zsh/functions/miscman/modules/legacy/backup/create_backup.sh`
- [ ] `zsh/functions/miscman/modules/legacy/clipboard/text.sh`
- [ ] `zsh/functions/miscman/modules/legacy/clipboard/path.sh`
- [ ] `zsh/functions/miscman/modules/legacy/files/archive.sh`
- [ ] `zsh/functions/miscman/modules/legacy/system/disk.sh`
- [ ] `zsh/functions/miscman/modules/legacy/system/process.sh`
- [ ] `zsh/functions/miscman/modules/legacy/system/reload_shell.sh`
- [ ] `zsh/functions/miscman/modules/legacy/system/update_system.sh`
- [ ] ... (autres modules)

**Total miscman :** 2 core + nombreux modules = **~15 fichiers**

---

### 9. ALIAMAN

**Fichiers core :**
- [ ] `zsh/functions/aliaman.zsh` (monolithique, pas de core séparé)

**Total aliaman :** 1 fichier = **1 fichier**

---

### 10. SEARCHMAN

**Fichiers core :**
- [ ] `zsh/functions/searchman.zsh` (monolithique, pas de core séparé)

**Total searchman :** 1 fichier = **1 fichier**

---

### 11. HELPMAN

**Fichiers core :**
- [ ] `zsh/functions/helpman.zsh` (wrapper)
- [ ] `zsh/functions/helpman/core/helpman.zsh`

**Modules :**
- [ ] `zsh/functions/helpman/modules/help_system.sh`

**Utils :**
- [ ] `zsh/functions/helpman/utils/list_functions.py`
- [ ] `zsh/functions/helpman/utils/markdown_viewer.py`

**Total helpman :** 2 core + 1 module + 2 utils = **5 fichiers**

---

### 12. FILEMAN

**Fichiers core :**
- [ ] `zsh/functions/fileman.zsh` (wrapper)
- [ ] `zsh/functions/fileman/core/fileman.zsh`

**Modules :**
- [ ] `zsh/functions/fileman/modules/files/files_manager.sh`
- [ ] `zsh/functions/fileman/modules/permissions/permissions_manager.sh`
- [ ] `zsh/functions/fileman/modules/backup/backup_manager.sh`
- [ ] `zsh/functions/fileman/modules/archive/archive_manager.sh`
- [ ] `zsh/functions/fileman/modules/search/search_manager.sh`

**Total fileman :** 2 core + 5 modules = **7 fichiers**

---

### 13. VIRTMAN

**Fichiers core :**
- [ ] `zsh/functions/virtman.zsh` (wrapper)
- [ ] `zsh/functions/virtman/core/virtman.zsh`

**Modules :**
- [ ] `zsh/functions/virtman/modules/docker/docker_manager.sh`
- [ ] `zsh/functions/virtman/modules/qemu/qemu_manager.sh`
- [ ] `zsh/functions/virtman/modules/libvirt/libvirt_manager.sh`
- [ ] `zsh/functions/virtman/modules/lxc/lxc_manager.sh`
- [ ] `zsh/functions/virtman/modules/vagrant/vagrant_manager.sh`
- [ ] `zsh/functions/virtman/modules/overview.sh`
- [ ] `zsh/functions/virtman/modules/search.sh`

**Total virtman :** 2 core + 7 modules = **9 fichiers**

---

### 14. SSHMAN

**Fichiers core :**
- [ ] `zsh/functions/sshman.zsh` (wrapper)
- [ ] `zsh/functions/sshman/core/sshman.zsh`

**Modules :**
- [ ] `zsh/functions/sshman/modules/ssh_auto_setup.sh`

**Total sshman :** 2 core + 1 module = **3 fichiers**

---

### 15. TESTMAN

**Fichiers core :**
- [ ] `zsh/functions/testman.zsh` (wrapper)
- [ ] `zsh/functions/testman/core/testman.zsh`

**Total testman :** 2 core = **2 fichiers**

---

### 16. TESTZSHMAN

**Fichiers core :**
- [ ] `zsh/functions/testzshman.zsh` (wrapper)
- [ ] `zsh/functions/testzshman/core/testzshman.zsh`

**Total testzshman :** 2 core = **2 fichiers**

---

### 17. MODULEMAN

**Fichiers core :**
- [ ] `zsh/functions/moduleman.zsh` (wrapper)
- [ ] `zsh/functions/moduleman/core/moduleman.zsh`

**Total moduleman :** 2 core = **2 fichiers**

---

### 18. MANMAN ✅

**Fichiers core :**
- [x] `zsh/functions/manman.zsh` (monolithique) → `bash/functions/manman.sh` + `fish/functions/manman.fish` ✅

**Total manman :** 1 fichier = **1 fichier** (converti ✅)

---

## 🔧 Utilitaires globaux

**Fichiers utils :**
- [ ] `zsh/functions/utils/alias_utils.zsh`
- [ ] `zsh/functions/utils/ensure_tool.sh`
- [ ] `zsh/functions/utils/fix_ghostscript_alias.sh`

**Total utils :** 3 fichiers

---

## 📁 Fichiers de configuration et chargement

### Configuration ZSH (source)
- [x] `zsh/zshrc_custom` (existe, reste comme source)

### Configuration Fish (à créer/adapter)
- [ ] `fish/config_custom.fish` (adapter pour charger les managers)
- [ ] Système de chargement des managers Fish

### Configuration Bash (à créer)
- [ ] `bash/bashrc_custom` (créer pour charger les managers)
- [ ] Système de chargement des managers Bash

---

## 📊 Récapitulatif complet

### Par catégorie

**Core/Wrapper :**
- 18 wrappers `.zsh`
- 15 cores `.zsh` (3 sont monolithiques)
- **Total : 33 fichiers core**

**Modules :**
- ~50+ modules à migrer
- **Total : ~50 fichiers modules**

**Utilitaires :**
- ~20+ utilitaires dans les managers
- 3 utilitaires globaux
- **Total : ~23 fichiers utils**

**Configuration :**
- 2 fichiers de configuration à créer/adapter
- **Total : 2 fichiers config**

### Total général

**Fichiers à migrer :**
- Core/Wrapper : 33 fichiers
- Modules : ~50 fichiers
- Utilitaires : ~23 fichiers
- Configuration : 2 fichiers

**TOTAL : ~108 fichiers à migrer**

---

## 🎯 Ordre de migration recommandé

### Phase 1 : Infrastructure
1. Structure de base
2. Convertisseur
3. Système de chargement

### Phase 2 : Pilote
1. **installman** (16 fichiers) - Manager essentiel

### Phase 3 : Essentiels
2. **configman** (13 fichiers) - Configuration
3. **pathman** (2 fichiers) - Utilisé par d'autres

### Phase 4 : Utilitaires de base
4. **netman** (2 fichiers)
5. **gitman** (4 fichiers)
6. **aliaman** (1 fichier)
7. **searchman** (1 fichier)
8. **helpman** (5 fichiers)

### Phase 5 : Fonctionnalités avancées
9. **fileman** (7 fichiers)
10. **miscman** (~15 fichiers)
11. **devman** (8 fichiers)
12. **virtman** (9 fichiers)
13. **sshman** (3 fichiers)

### Phase 6 : Spécialisés
14. **cyberman** (~30 fichiers) - Le plus complexe
15. **testman** (2 fichiers)
16. **testzshman** (2 fichiers)

### Phase 7 : Infrastructure
17. **moduleman** (2 fichiers)
18. **manman** (1 fichier)

---

## ✅ Checklist globale

### Infrastructure
- [ ] Structure `fish/functions/` complète
- [ ] Structure `bash/functions/` complète
- [ ] Convertisseur ZSH → Fish
- [ ] Convertisseur ZSH → Bash
- [ ] Système de chargement Fish
- [ ] Système de chargement Bash
- [ ] Script de synchronisation
- [ ] Hook Git pre-commit

### Managers (18)
- [x] installman (16 fichiers) ✅ - Core converti
- [x] configman (13 fichiers) ✅ - Core converti
- [x] pathman (2 fichiers) ✅ - Core converti
- [ ] netman (2 fichiers)
- [ ] gitman (4 fichiers)
- [ ] cyberman (~30 fichiers)
- [ ] devman (8 fichiers)
- [ ] miscman (~15 fichiers)
- [ ] aliaman (1 fichier)
- [ ] searchman (1 fichier)
- [ ] helpman (5 fichiers)
- [ ] fileman (7 fichiers)
- [ ] virtman (9 fichiers)
- [ ] sshman (3 fichiers)
- [ ] testman (2 fichiers)
- [ ] testzshman (2 fichiers)
- [ ] moduleman (2 fichiers)
- [x] manman (1 fichier) ✅ - Core converti

### Utilitaires globaux
- [ ] alias_utils.zsh
- [ ] ensure_tool.sh
- [ ] fix_ghostscript_alias.sh

### Configuration
- [ ] fish/config_custom.fish (adaptation)
- [ ] bash/bashrc_custom (création)

---

## 📈 Métriques

**Total fichiers à migrer :** ~108 fichiers
**Total lignes de code estimées :** ~15-20k lignes
**Durée estimée totale :** 11-17 jours de travail

---

**Dernière mise à jour :** 2024-12-04
**Progression actuelle :** 4/18 managers convertis (22%) - installman, configman, pathman, manman ✅

