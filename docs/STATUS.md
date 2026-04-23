# STATUS.md - Historique des modifications

Ce fichier documente toutes les modifications apportées aux dotfiles depuis le début de la refactorisation complète.

**Version :** 2.12.0  
**Date de création :** Décembre 2024  
**Dernière mise à jour :** Février 2025

> **2026-04 — Pointeur** : le suivi **migration + tests Docker** vivant est **`STATUS.md`** à la racine du dépôt (section *État des tests Docker*, `make test` en deux phases). Ce fichier `docs/STATUS.md` reste un **journal historique** des refactors ; ne pas le confondre avec le STATUS racine.

---

## 📋 INSTALLMAN TUI + LOGGING (Fév. 2025)

### Modifications
- ✅ **TUI core** (`scripts/lib/tui_core.sh`) : adaptation à la taille du terminal (tui_lines, tui_cols, tui_menu_height), pagination des menus.
- ✅ **Menu installman paginé** : en terminal petit ou non scrollable, affichage par pages avec `n` (suivant) / `p` (précédant) ; numérotation globale (1 à N) inchangée.
- ✅ **Logging installman** (`scripts/lib/installman_log.sh`) : chaque action (install, check-urls, etc.) est enregistrée dans `dotfiles/logs/installman.log` avec timestamp, cible, statut (success/failed) et détail d’erreur.
- ✅ Option **logs** dans le menu installman pour afficher les derniers logs.
- ✅ Vérification des URLs (check-urls) et installations loggées pour reprise / diagnostic.

### Fichiers concernés
- `scripts/lib/tui_core.sh` (nouveau)
- `scripts/lib/installman_log.sh` (nouveau)
- `zsh/functions/installman/core/installman.zsh` (menu paginé, intégration TUI + log)

---

## 📋 BASE UNIQUE MULTI-SHELL + DOCKER + LOG MANAGERS (Fév. 2025)

### Modifications
- ✅ **Entrée unique installman** (`core/managers/installman/installman_entry.sh`) : un seul script exécutable par sh/bash/zsh/fish, qui lance le core Zsh avec les arguments.
- ✅ **Adapters par shell** : Zsh charge directement le core ; Bash et Fish définissent la commande `installman` qui appelle l’entry script (pas de doublon de logique).
- ✅ **Log générique managers** (`scripts/lib/managers_log.sh`) : `log_manager_action manager action target status details` → `logs/managers.log` ; réutilisable par configman et autres *man.
- ✅ **Test Docker bootstrap** (`scripts/test/docker/run_dotfiles_bootstrap.sh`) : bootstrap + vérification installman + vérification multi-shell dans le conteneur.
- ✅ **Vérification multi-shell** (`scripts/test/verify_multishell.sh`) : teste `installman help` depuis zsh, bash, sh.
- ✅ **Docs** : `docs/MULTISHELL_REPORT.md` et `docs/STATUS.md` mis à jour (entry, adapters, Docker, logs).

### Fichiers concernés
- `core/managers/installman/installman_entry.sh` (nouveau)
- `shells/zsh/adapters/installman.zsh`, `shells/bash/adapters/installman.sh`, `shells/fish/adapters/installman.fish`
- `scripts/lib/managers_log.sh` (nouveau)
- `scripts/test/docker/run_dotfiles_bootstrap.sh` (nouveau)
- `scripts/test/verify_multishell.sh` (nouveau)
- `docs/MULTISHELL_REPORT.md`, `docs/STATUS.md`

---

## 📋 RÉSUMÉ GÉNÉRAL

Refactorisation complète du système de dotfiles avec :
- Réorganisation complète de la structure
- Ajout de nouveaux scripts d'installation modulaires
- Amélioration de la configuration Git automatique
- Nettoyage et suppression des doublons
- Documentation complète mise à jour

---

## 🎯 PHASE 1 : Réorganisation ZSH (zshrc_custom)

### Modifications
- ✅ Réorganisation de l'ordre de chargement dans `zsh/zshrc_custom`
- ✅ Chargement des gestionnaires (*man.zsh) en premier
- ✅ Puis chargement des variables d'environnement (env.sh)
- ✅ Puis chargement des fonctions individuelles
- ✅ Enfin chargement des alias
- ✅ Ajout de messages colorés pour chaque étape
- ✅ Chargement automatique des fonctions utilitaires (add_alias, add_to_path, clean_path)

### Fichiers modifiés
- `zsh/zshrc_custom` - Réorganisation complète avec 4 étapes clairement définies

---

## 🐳 PHASE 2 : Scripts Docker

### Nouveaux fichiers créés
- ✅ `scripts/install/dev/install_docker.sh`
  - Installation Docker & Docker Compose (Arch/Debian/Fedora)
  - Activation BuildKit automatique
  - Login Docker Hub avec support 2FA
  - Installation Docker Desktop optionnelle
  - Configuration du service et groupe docker

- ✅ `scripts/install/dev/install_docker_tools.sh`
  - Installation outils de build pour Arch Linux
  - base-devel, make, gcc, pkg-config, cmake
  - Vérification de tous les outils

### Intégration
- ✅ Ajouté au menu setup.sh (options 15 et 16)

---

## 🌐 PHASE 3 : Scripts Brave & yay

### Nouveaux fichiers créés
- ✅ `scripts/install/apps/install_brave.sh`
  - Installation Brave Browser
  - Support Arch (via yay), Debian, Fedora
  - Installation manuelle pour autres distros

- ✅ `scripts/install/tools/install_yay.sh`
  - Installation yay AUR helper depuis source
  - Configuration automatique (pas de confirmation)
  - Mise à jour AUR automatique

### Intégration
- ✅ Ajouté au menu setup.sh (options 17 et 18)

---

## 🔧 PHASE 4 : Amélioration scripts existants

### Fichiers déplacés et améliorés
- ✅ `install_go.sh` (racine) → `scripts/install/dev/install_go.sh`
  - Détection de version actuelle
  - Proposition de mise à jour si version différente
  - Utilisation de `add_to_path` si disponible
  - Fallback manuel vers env.sh

- ✅ `scripts/install/apps/install_cursor.sh` (amélioré)
  - Détection de version actuelle
  - Création alias via `add_alias` si disponible
  - Fallback manuel vers aliases.zsh
  - Vérification finale de l'installation

- ✅ `scripts/install/apps/install_portproton.sh` (amélioré)
  - Utilisation de `add_alias` pour créer les alias
  - Fallback manuel si fonction non disponible
  - Ajout des fonctions helper

### Intégration
- ✅ Tous les scripts utilisent maintenant `add_alias` et `add_to_path` avec fallback

---

## 📝 PHASE 5 : Menu setup.sh complet

### Nouvelles options ajoutées
- ✅ Option 12 : Configuration auto-sync Git (systemd timer)
- ✅ Option 13 : Tester synchronisation manuellement
- ✅ Option 14 : Afficher statut auto-sync
- ✅ Option 15 : Installation Docker & Docker Compose
- ✅ Option 16 : Installation Docker Desktop (optionnel)
- ✅ Option 17 : Installation Brave Browser (optionnel)
- ✅ Option 18 : Installation yay (AUR - Arch Linux)
- ✅ Option 19 : Installation Go
- ✅ Option 20 : Recharger configuration ZSH
- ✅ Option 21 : Installer fonctions USB test
- ✅ Option 22 : Validation complète du setup

### Améliorations
- ✅ Option 10 (installation complète) améliorée avec prompts pour :
  - Docker
  - Docker Desktop
  - Brave
  - Auto-sync Git
- ✅ Résumé final des installations effectuées

### Fichiers modifiés
- `setup.sh` - Menu étendu à 22 options

---

## 🔄 PHASE 6 : Auto-Sync Git

### Nettoyage
- ✅ Suppression de `auto_sync_dotfiles.sh` (doublon à la racine)
- ✅ Conservation uniquement de `scripts/sync/git_auto_sync.sh`

### Intégration
- ✅ Options 12, 13, 14 dans setup.sh
- ✅ Intégration dans option 10 (installation complète)

---

## 🔐 PHASE 7 : Configuration Git automatique (bootstrap.sh)

### Améliorations majeures
- ✅ **Auto-détection identité Git** (supprimée - compte perso uniquement maintenant)
- ✅ **Configuration credential helper automatique** (cache)
- ✅ **Génération clé SSH ED25519** si absente
- ✅ **Copie clé publique dans presse-papier** (xclip/wl-copy)
- ✅ **Ouverture automatique GitHub** pour ajouter la clé
- ✅ **Test connexion SSH** automatique
- ✅ Configuration Git complète (user.name, user.email, editor, etc.)

### Fichiers modifiés
- `bootstrap.sh` - Configuration Git automatique complète

---

## ✅ PHASE 8 : Validation & Tests

### Nouveau fichier créé
- ✅ `scripts/test/validate_setup.sh`
  - Vérification fonctions ZSH (add_alias, add_to_path, clean_path)
  - Vérification PATH (Go, Flutter, Android SDK, Dart)
  - Vérification services (systemd timer, Docker, SSH agent)
  - Vérification Git (user.name, user.email, credential.helper, SSH key)
  - Vérification outils (Go, Docker, Cursor, yay, make, gcc, cmake)
  - Vérification fichiers dotfiles
  - Rapport final avec compteurs (✅/❌/⚠️)

### Intégration
- ✅ Option 22 du menu setup.sh

---

## 📚 PHASE 9 : Documentation

### README.md
- ✅ Section installation rapide (une seule ligne)
- ✅ Section Auto-Sync Git (nouvelle)
- ✅ Section Docker (nouvelle)
- ✅ Section Brave (nouvelle)
- ✅ Section Scripts Modulaires (nouvelle)
- ✅ Section Validation (nouvelle)
- ✅ Tableau des scripts avec chemins mis à jour

### STRUCTURE.md
- ✅ Arborescence complète mise à jour
- ✅ Descriptions de tous les nouveaux scripts
- ✅ Workflow d'utilisation
- ✅ Cas d'usage (nouvelle machine, mise à jour, validation)
- ✅ Ordre d'exécution recommandé
- ✅ Notes importantes

### scripts/README.md
- ✅ Structure mise à jour avec apps/, dev/, tools/
- ✅ Exemples d'utilisation mis à jour

### Fichiers modifiés
- `README.md` - Documentation complète
- `STRUCTURE.md` - Structure détaillée
- `scripts/README.md` - Documentation scripts

---

## 🗂️ PHASE 10 : Réorganisation structure

### Déplacement fonctions Git
- ✅ Fonctions Git déplacées de `zshrc_custom` vers `zsh/functions/git/git_functions.sh`
- ✅ Fonctions : `whoami-git()`, `switch-git-identity()`
- ✅ Chargement automatique via étape 3 (fonctions individuelles)

### Réorganisation scripts/install/
- ✅ Création structure par catégories :
  - `apps/` : Applications utilisateur (Brave, Cursor, PortProton)
  - `dev/` : Outils de développement (Docker, Go)
  - `tools/` : Outils système (yay, QEMU)
  - `system/` : Paquets système (déjà existant)

### Fichiers déplacés
- `install_cursor.sh` → `scripts/install/apps/install_cursor.sh`
- `install_portproton.sh` → `scripts/install/apps/install_portproton.sh`
- `install_brave.sh` → `scripts/install/apps/install_brave.sh`
- `install_docker.sh` → `scripts/install/dev/install_docker.sh`
- `install_docker_tools.sh` → `scripts/install/dev/install_docker_tools.sh`
- `install_go.sh` → `scripts/install/dev/install_go.sh`
- `install_yay.sh` → `scripts/install/tools/install_yay.sh`
- `install_qemu.sh` → `scripts/install/tools/install_qemu_full.sh`

---

## 🧹 PHASE 11 : Nettoyage

### Fichiers supprimés
- ✅ `auto_sync_dotfiles.sh` (doublon à la racine)
- ✅ `install_cursor.sh` (doublon à la racine)
- ✅ `install_go.sh` (doublon à la racine)
- ✅ `scripts/install/install_qemu_simple_ancient.sh` (obsolète)
- ✅ `scripts/install/tools/install_qemu_simple.sh` (redondant avec install_qemu_full.sh)

### Fichiers déplacés/archivés
- ✅ `install_qemu.sh` → `scripts/install/tools/install_qemu_full.sh`
- ✅ `scripts/install/verify_network.sh` → `scripts/install/tools/verify_network.sh`
- ✅ `manjaro_setup_final.sh` → `scripts/install/archive_manjaro_setup_final.sh`

### Références mises à jour
- ✅ Tous les chemins dans `setup.sh`
- ✅ Tous les chemins dans `README.md`
- ✅ Tous les chemins dans `STRUCTURE.md`
- ✅ Tous les chemins dans `scripts/README.md`
- ✅ Tous les chemins dans `scripts/install/install_all.sh`
- ✅ Référence dans `scripts/vm/create_test_vm.sh`

---

## 🔄 PHASE 12 : Simplification identité Git

### Modifications
- ✅ Suppression auto-détection identité Piter
- ✅ Configuration uniquement compte perso (Paul Delhomme)
- ✅ Fonction `switch-git-identity()` simplifiée (perso uniquement)
- ✅ `bootstrap.sh` utilise uniquement compte perso par défaut

### Fichiers modifiés
- `bootstrap.sh` - Suppression auto-détection Piter
- `zsh/functions/git/git_functions.sh` - Simplification switch-git-identity
- `STRUCTURE.md` - Description mise à jour

---

## 📊 STATISTIQUES

### Fichiers créés
- 7 nouveaux scripts d'installation
- 1 script de validation
- 1 fichier de fonctions Git
- **Total : 9 nouveaux fichiers**

### Fichiers modifiés
- 8 fichiers principaux modifiés
- **Total : 8 fichiers modifiés**

### Fichiers supprimés
- 4 fichiers doublons/obsolètes
- **Total : 4 fichiers supprimés**

### Fichiers déplacés
- 8 fichiers réorganisés
- **Total : 8 fichiers déplacés**

### Lignes de code
- **+1863 insertions**
- **-156 suppressions**
- **Net : +1707 lignes**

---

## 🎯 RÉSULTAT FINAL

### Structure finale
```
dotfiles/
├── bootstrap.sh              # Installation en une ligne
├── setup.sh                  # Menu interactif (22 options)
├── README.md                 # Documentation complète
├── STRUCTURE.md              # Structure détaillée
├── STATUS.md                 # Ce fichier
│
├── scripts/
│   ├── config/              # Configurations unitaires
│   ├── install/
│   │   ├── apps/           # Applications utilisateur
│   │   ├── dev/            # Outils de développement
│   │   ├── tools/          # Outils système
│   │   └── system/         # Paquets système
│   ├── sync/               # Auto-sync Git
│   ├── test/               # Validation & tests
│   └── vm/                 # Gestion VM
│
└── zsh/
    ├── zshrc_custom        # Configuration ZSH (4 étapes)
    ├── env.sh              # Variables d'environnement
    ├── aliases.zsh         # Alias
    └── functions/
        ├── *man.zsh       # Gestionnaires
        ├── git/           # Fonctions Git
        └── **/*.sh        # Fonctions individuelles
```

### Fonctionnalités principales
- ✅ Installation complète en **une seule ligne** : `curl ... | bash`
- ✅ Menu interactif avec **22 options**
- ✅ Scripts modulaires organisés par catégories
- ✅ Auto-sync Git toutes les heures (systemd timer)
- ✅ Configuration Git automatique (SSH, credential helper)
- ✅ Validation complète du setup
- ✅ Documentation complète et à jour

---

## 🔗 PHASE 12 : Centralisation avec symlinks et améliorations

### Modifications
- ✅ Création script `scripts/config/create_symlinks.sh` pour centraliser la configuration
- ✅ Symlinks automatiques pour `.zshrc`, `.gitconfig`, `.ssh/id_ed25519`, `.ssh/config`
- ✅ Intégration dans `bootstrap.sh` et `setup.sh` (option 23)
- ✅ Script de migration `scripts/migrate_existing_user.sh` pour utilisateurs existants
- ✅ Amélioration `validate_setup.sh` avec vérifications supplémentaires :
  - Flutter dans PATH
  - Permissions Docker
  - Configuration NVIDIA (GPU, Xorg, nvidia-prime)
  - Vérification symlinks
  - Dotfiles sourcés
- ✅ Suppression informations sensibles du README.md (emails, serveurs)
- ✅ Correction auteur README (PavelDelhomme uniquement)

### Nouveaux fichiers créés
- ✅ `scripts/config/create_symlinks.sh` - Création symlinks centralisés
- ✅ `scripts/migrate_existing_user.sh` - Migration utilisateurs existants

### Fichiers modifiés
- ✅ `bootstrap.sh` - Ajout étape création symlinks
- ✅ `setup.sh` - Ajout option 23 (création symlinks)
- ✅ `scripts/test/validate_setup.sh` - Vérifications étendues
- ✅ `README.md` - Suppression infos sensibles, ajout section symlinks
- ✅ `STATUS.md` - Documentation des nouvelles modifications

### Structure recommandée
```
~/
├── dotfiles/                   # Configuration centralisée
│   ├── .zshrc
│   ├── .gitconfig
│   └── .ssh/
│       ├── id_ed25519
│       └── config
├── .zshrc -> ~/dotfiles/.zshrc              # Symlink
├── .gitconfig -> ~/dotfiles/.gitconfig       # Symlink
└── .ssh/
    ├── id_ed25519 -> ~/dotfiles/.ssh/id_ed25519
    └── config -> ~/dotfiles/.ssh/config
```

---

## 🔧 PHASE 13 : Makefile et corrections menu

### Modifications
- ✅ Création `Makefile` complet avec toutes les commandes principales
- ✅ Interface standardisée avec `make` pour toutes les opérations
- ✅ Correction bug menu `setup.sh` (gestion input améliorée)
- ✅ Script `scripts/uninstall/reset_all.sh` pour réinitialisation complète
- ✅ Option 98 ajoutée dans `setup.sh` (réinitialisation complète)
- ✅ Documentation Makefile dans `README.md`

### Nouveaux fichiers créés
- ✅ `Makefile` - Interface standardisée avec make
- ✅ `scripts/uninstall/reset_all.sh` - Réinitialisation complète (rollback + suppression + réinstallation)

### Fichiers modifiés
- ✅ `setup.sh` - Correction gestion input menu (extraction nombre uniquement)
- ✅ `setup.sh` - Ajout option 98 (réinitialisation complète)
- ✅ `README.md` - Section Makefile ajoutée avec toutes les commandes
- ✅ `STATUS.md` - Documentation des nouvelles modifications

### Commandes Makefile disponibles

Aide complète :

```bash
make help
```

Installation complète :

```bash
make install
```

Menu interactif :

```bash
make setup
```

Validation setup :

```bash
make validate
```

Créer symlinks :

```bash
make symlinks
```

Migrer config existante :

```bash
make migrate
```

Installer Docker :

```bash
make install-docker
```

Installer Go :

```bash
make install-go
```

Installer Cursor :

```bash
make install-cursor
```

Installer Brave :

```bash
make install-brave
```

Installer yay :

```bash
make install-yay
```

Config Git :

```bash
make git-config
```

Config remote Git :

```bash
make git-remote
```

Config auto-sync :

```bash
make auto-sync
```

Rollback complet :

```bash
make rollback
```

Réinitialisation complète :

```bash
make reset
```

Nettoyer fichiers temporaires :

```bash
make clean
```

### Corrections techniques
- **Bug menu setup.sh** : L'input capturait du texte indésirable (ex: `'log_warn"Menuignoré"'`)
  - Solution : Extraction uniquement des chiffres avec `sed 's/^[^0-9]*//' | sed 's/[^0-9].*$//'`
  - Validation : Vérification que le choix est un nombre avant le `case`
  - Utilisation de `IFS= read -r` pour une lecture plus robuste

### Avantages du Makefile
- ✅ Interface standardisée et universelle
- ✅ Commandes plus simples et mémorisables
- ✅ Documentation intégrée (`make help`)
- ✅ Compatibilité avec scripts bash existants
- ✅ Extensible facilement

---

## 🚀 PHASE 15 : Nettoyage structure et migration shell

### Nettoyage des dossiers obsolètes
- ✅ Suppression des dossiers obsolètes (`path_manager/`, `alias_manager/`, `network/`, `search_manager/`, `dot_files_manager/`)
- ✅ Suppression des backups obsolètes (`zsh/backup/` et `zsh/functions/_backups/`)
- ✅ Mise à jour de `zshrc_custom` pour retirer les références aux anciens chemins

### Migration Fish ↔ Zsh
- ✅ Création script `scripts/migrate_shell.sh` pour migration entre Fish et Zsh
- ✅ Migration automatique des alias, variables d'environnement et sauvegardes PATH
- ✅ Configuration automatique des symlinks selon le shell choisi

### Améliorations Bootstrap et Setup
- ✅ `bootstrap.sh` : Menu de choix du shell (Zsh, Fish, ou les deux)
- ✅ `setup.sh` : Option 24 (migration shell) et option 25 (changer shell par défaut)
- ✅ Passage du choix shell via variable d'environnement

### Fichiers modifiés
- ✅ `bootstrap.sh` - Ajout menu choix shell
- ✅ `setup.sh` - Ajout options migration et changement shell
- ✅ `zsh/zshrc_custom` - Nettoyage références obsolètes

---

## 🔒 PHASE 16 : CYBERMAN et vérification automatique d'outils

### Nouveau gestionnaire cyberman.zsh
- ✅ Création `zsh/functions/cyberman.zsh` pour regrouper toutes les fonctions cyber
- ✅ Organisation par catégories : Reconnaissance, Scanning, Vulnerability Assessment, Attacks, Analysis, Privacy
- ✅ Menu interactif avec sous-menus pour chaque catégorie
- ✅ Support arguments rapides : `cyberman recon`, `cyberman scan`, etc.
- ✅ Intégration dans `zshrc_custom` (chargement automatique)

### Fonction utilitaire ensure_tool
- ✅ Création `zsh/functions/utils/ensure_tool.sh` pour vérification/installation automatique d'outils
- ✅ Détection automatique de la distribution (Arch, Debian, Fedora, Gentoo)
- ✅ Mapping outils → paquets pour chaque distribution
- ✅ Installation automatique via le gestionnaire de paquets approprié
- ✅ Support AUR (yay) pour Arch Linux
- ✅ Proposition interactive à l'utilisateur avant installation

### Modification scripts cyber
- ✅ `arp_spoof.sh` - Vérification/installation arpspoof (dsniff)
- ✅ `brute_ssh.sh` - Vérification/installation hydra
- ✅ `nmap_vuln_scan.sh` - Vérification/installation nmap
- ✅ `nikto_scan.sh` - Vérification/installation nikto
- ✅ `sniff_traffic.sh` - Vérification/installation tcpdump
- ✅ `deauth_attack.sh` - Vérification/installation aircrack-ng
- ✅ Tous les autres scripts cyber utilisent maintenant `ensure_tool` via cyberman

### Fonctionnalités ensure_tool
- ✅ Détection distribution : Arch, Debian, Fedora, Gentoo
- ✅ Mapping complet outils → paquets (dsniff, hydra, nmap, nikto, gobuster, etc.)
- ✅ Installation via pacman, apt, dnf, emerge
- ✅ Support AUR avec yay automatique
- ✅ Proposition interactive avant installation
- ✅ Fonction `ensure_tools()` pour vérifier plusieurs outils en une fois

### Nouveaux fichiers créés
- ✅ `zsh/functions/cyberman.zsh` - Gestionnaire cyber complet
- ✅ `zsh/functions/utils/ensure_tool.sh` - Utilitaire vérification/installation outils

### Fichiers modifiés
- ✅ `zsh/zshrc_custom` - Ajout chargement cyberman
- ✅ `zsh/functions/cyber/*.sh` - Ajout vérification outils (6 fichiers modifiés)

---

## 🚀 PHASE 17 : Réorganisation structure cyber/ et simplification zshrc

### Réorganisation cyber/
- ✅ **Réorganisation complète** : `zsh/functions/cyber/` organisé en 6 sous-dossiers logiques
  - `reconnaissance/` - Information gathering (10 scripts)
  - `scanning/` - Port scanning & enumeration (8 scripts)
  - `vulnerability/` - Vulnerability assessment (8 scripts)
  - `attacks/` - Network attacks & exploitation (5 scripts)
  - `analysis/` - Network analysis & monitoring (2 scripts)
  - `privacy/` - Privacy & anonymity (3 scripts)
- ✅ **cyberman.zsh mis à jour** : Tous les chemins mis à jour pour les nouveaux sous-dossiers
- ✅ **Navigation améliorée** : Structure claire et compréhensible, plus facile à naviguer

### Simplification zshrc
- ✅ **Wrapper intelligent** : `zshrc` à la racine détecte le shell actif (ZSH/Fish) et source la bonne config
- ✅ **Ordre de chargement clarifié** : Commentaires ajoutés expliquant pourquoi les gestionnaires doivent être chargés AVANT env.sh
- ✅ **Dépendances documentées** : env.sh utilise `add_to_path()` de pathman.zsh, ordre de chargement vérifié

### Fichiers modifiés
- ✅ `zsh/functions/cyber/` - Réorganisation en 6 sous-dossiers (39 scripts réorganisés)
- ✅ `zsh/functions/cyberman.zsh` - Chemins mis à jour pour nouveaux sous-dossiers
- ✅ `zsh/zshrc_custom` - Ordre de chargement clarifié avec commentaires explicatifs
- ✅ `zshrc` - Wrapper intelligent avec détection shell
- ✅ `scripts/config/create_symlinks.sh` - Support du nouveau wrapper zshrc

---

## 🚀 PROCHAINES ÉTAPES POSSIBLES

### Améliorations futures
- [ ] Ajouter support pour d'autres identités Git (si besoin)
- [ ] Ajouter plus de scripts d'installation (selon besoins)
- [ ] Tests automatisés
- [ ] Étendre ensure_tool à d'autres catégories d'outils

---

## 📝 NOTES

- Tous les scripts utilisent `add_alias` et `add_to_path` avec fallback manuel
- Les scripts cyber utilisent maintenant `ensure_tool` pour vérification automatique
- La structure est maintenant modulaire et extensible
- La documentation est complète et à jour
- Tous les chemins ont été mis à jour après réorganisation

---

## 🚀 PHASE 14 : Simplification du workflow d'installation

### Modifications
- ✅ **bootstrap.sh simplifié** : Lance automatiquement le menu interactif après le clonage
- ✅ **Plus de questions intermédiaires** : Le workflow est maintenant linéaire et automatique
- ✅ **Menu setup.sh amélioré** : Affiche l'état d'installation au premier lancement
- ✅ **Fonction show_status()** : Affiche clairement ce qui est installé et ce qui manque
- ✅ **Indications claires** : Chaque élément manquant indique quelle option du menu choisir

### Nouveaux fichiers créés
- Aucun (améliorations uniquement)

### Fichiers modifiés
- ✅ `bootstrap.sh` - Simplification : lance automatiquement setup.sh après clonage
- ✅ `setup.sh` - Ajout fonction `show_status()` pour afficher l'état d'installation
- ✅ `README.md` - Documentation mise à jour avec workflow simplifié
- ✅ `STATUS.md` - Documentation des nouvelles modifications

### Workflow simplifié

**Avant :**

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

→ Questions multiples → Choix entre make install / make setup / bash setup.sh → Confusion sur quelle méthode utiliser

**Maintenant :**

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

→ Configuration Git automatique → Clonage dotfiles → Menu interactif lancé automatiquement → État d'installation affiché en haut du menu → Choix clair des options à installer

### Avantages
- ✅ **Workflow linéaire** : Une seule commande, tout est automatique
- ✅ **Visibilité immédiate** : L'utilisateur voit directement l'état de son installation
- ✅ **Guidage clair** : Chaque élément manquant indique quelle option choisir
- ✅ **Pas de confusion** : Plus de questions intermédiaires, le menu gère tout

---

**Dernière mise à jour :** Décembre 2024  
**Version :** 2.10.0 (Refactorisation complète + Centralisation symlinks + Makefile + Workflow simplifié + Migration shell + CYBERMAN + ensure_tool + Réorganisation cyber/ + Simplification zshrc + Réorganisation dev/ & misc/ + Système de logs + Désinstallation individuelle + Détection éléments manquants + Restaurer depuis Git + Système de gestion des *man + Système d'alias avec documentation + Documentation interactive complète + Réorganisation structure fichiers + Système complet de gestion de VM + Fonctions update/upgrade intelligentes avec détection automatique de distribution)

---

## 🚀 PHASE 18 : Réorganisation dev/ et misc/ avec nouvelles fonctions

### Réorganisation dev/
- ✅ **Projets spécifiques déplacés** : `dev/projects/` pour cyna.sh et weedlyweb.sh
- ✅ **Nouvelles fonctions génériques** :
  - `go.sh` - Build, test, run, mod, fmt, vet, clean, bench, release (10 fonctions)
  - `c.sh` - Compile C/C++, debug, clean, check (6 fonctions)
  - `docker.sh` - Build, push, cleanup, logs, exec, stats, compose (14 fonctions)
  - `make.sh` - Targets, clean, help, build, test, install (6 fonctions)
- ✅ **Structure claire** : Projets spécifiques séparés des fonctions génériques

### Réorganisation misc/
- ✅ **Organisation en sous-dossiers logiques** :
  - `clipboard/` - Copie presse-papier (5 fonctions: file, command_output, tree, path, text)
  - `security/` - Sécurité & chiffrement (4 fonctions: encrypt, decrypt, password, colorpasswd)
  - `files/` - Gestion fichiers & archives (5 fonctions: extract, archive, file_size, find_large_files, find_duplicates)
  - `system/` - Système & processus (8 fonctions: system_info, disk_usage, system_clean, top_processes, disk_space, watch_directory, kill_process, kill_port, port_process, watch_process)
  - `backup/` - Sauvegardes (1 fonction: create_backup)
- ✅ **Fichiers renommés** : Noms plus cohérents (file.sh au lieu de copy_file.sh, etc.)
- ✅ **Nouvelles fonctions ajoutées** :
  - `clipboard/path.sh` - copy_path, copy_filename, copy_parent
  - `clipboard/text.sh` - copy_text, copy_pwd, copy_cmd
  - `files/archive.sh` - archive, file_size, find_large_files, find_duplicates
  - `system/disk.sh` - disk_usage, system_clean, top_processes, disk_space, watch_directory
  - `system/process.sh` - kill_process, kill_port, port_process, watch_process

### Fichiers créés/modifiés
- ✅ `dev/go.sh` - 10 fonctions Go
- ✅ `dev/c.sh` - 6 fonctions C/C++
- ✅ `dev/docker.sh` - 14 fonctions Docker
- ✅ `dev/make.sh` - 6 fonctions Make
- ✅ `dev/projects/cyna.sh` - Déplacé depuis dev/
- ✅ `dev/projects/weedlyweb.sh` - Déplacé depuis dev/
- ✅ `misc/clipboard/*.sh` - 5 fichiers réorganisés
- ✅ `misc/security/*.sh` - 4 fichiers réorganisés
- ✅ `misc/files/archive.sh` - Nouveau (extract + nouvelles fonctions)
- ✅ `misc/system/disk.sh` - Nouveau (system_info + nouvelles fonctions)
- ✅ `misc/system/process.sh` - Nouveau
- ✅ `misc/clipboard/path.sh` - Nouveau
- ✅ `misc/clipboard/text.sh` - Nouveau
- ✅ `STRUCTURE.md` - Documentation mise à jour

---

## 🚀 PHASE 19 : Système de logs complet et désinstallation individuelle

### Système de logs d'installation
- ✅ **Nouveau fichier** : `scripts/lib/install_logger.sh`
  - `log_install_action()` - Logger toutes les actions (install/config/uninstall/test) avec timestamp, statut, détails
  - `show_install_logs()` - Afficher logs avec pagination (less)
  - `get_install_summary()` - Statistiques (réussies/échouées/ignorées)
  - `get_recent_actions()` - Dernières actions effectuées
- ✅ **Fichier de log** : `~/dotfiles/install.log`
  - Format: `[timestamp] [action] [status] component | details`
  - Trace: QUOI, QUAND, POURQUOI, RÉSULTAT
  - Toutes les installations via setup.sh sont automatiquement loggées

### Système de détection des éléments manquants
- ✅ **Nouveau fichier** : `scripts/lib/check_missing.sh`
  - `detect_missing_components()` - Détecte tous les éléments manquants
  - `show_missing_components()` - Affiche de manière organisée (scrollable via less)
  - `get_missing_list()` - Liste pour scripts
- ✅ **Vérifications complètes** : paquets base, gestionnaires, applications, outils, config Git, remote, auto-sync, symlinks
- ✅ **Groupement par catégorie** : commandes, configs, services, symlinks

### Réorganisation options 50-53 dans setup.sh
- ✅ **Option 50** : Afficher ce qui manque (état uniquement, scrollable via less)
  * Utilise `show_missing_components()` pour affichage organisé
  * Groupement par catégories claires
  * Pagination automatique via less
- ✅ **Option 51** : Installer éléments manquants (un par un)
  * Liste interactive de tous les éléments manquants
  * Choix numéroté pour installer individuellement
  * Logging automatique de chaque action
- ✅ **Option 52** : Installer tout ce qui manque (automatique)
  * Installation automatique de TOUS les composants manquants
  * Détection intelligente de ce qui est déjà installé
  * Logging complet de chaque étape (success/failed/skipped)
- ✅ **Option 53** : Afficher logs d'installation (NOUVEAU)
  * Menu interactif pour consulter les logs
  * Options: dernières 50/100 lignes, toutes, filtrer par action/composant, résumé
  * Pagination via less pour navigation facile
  * Statistiques complètes (total, réussies, échouées, ignorées)

### Désinstallation individuelle (options 60-70)
- ✅ **13 nouveaux scripts** dans `scripts/uninstall/` :
  * `uninstall_git_config.sh` - Supprime user.name, user.email, credential.helper
  * `uninstall_git_remote.sh` - Supprime ou réinitialise remote origin
  * `uninstall_base_packages.sh` - Supprime paquets de base
  * `uninstall_package_managers.sh` - Supprime yay, snapd, flatpak
  * `uninstall_brave.sh` - Supprime Brave Browser + dépôt optionnel
  * `uninstall_cursor.sh` - Supprime Cursor IDE (AppImage, config, cache, alias)
  * `uninstall_docker.sh` - Supprime Docker & Docker Compose (+ conteneurs/images optionnels)
  * `uninstall_go.sh` - Supprime Go (+ GOPATH/GOROOT optionnels)
  * `uninstall_yay.sh` - Supprime yay AUR helper (Arch Linux uniquement)
  * `uninstall_auto_sync.sh` - Supprime auto-sync Git (systemd timer/service)
  * `uninstall_symlinks.sh` - Supprime symlinks (.zshrc, .gitconfig, .ssh, etc.)
- ✅ **Intégration dans setup.sh** : Options 60-70 dans le menu
- ✅ **Fonctionnalités** :
  * Confirmation obligatoire avant désinstallation (tapez 'OUI')
  * Options interactives (supprimer dépôts, cache, config, etc.)
  * Support multi-distributions (Arch, Debian, Fedora)
  * Détection automatique des installations
  * Messages clairs avec solutions suggérées

### Restaurer depuis Git (option 28)
- ✅ **Nouveau script** : `scripts/sync/restore_from_git.sh`
  - Restaure l'état du repo depuis origin/main
  - Annule toutes les modifications locales
  - Peut restaurer un fichier spécifique ou tous les fichiers
  - Options: restauration fichiers modifiés, reset hard complet
- ✅ **Intégration dans setup.sh** : Option 28 avec sous-menu (restaurer tous fichiers, fichier spécifique, reset hard)
- ✅ **Via Makefile** : Commande `make restore`

### Validation exhaustive (validate_setup.sh)
- ✅ **117+ vérifications au total** :
  * Structure dotfiles (7 fichiers racine, bibliothèque commune)
  * Scripts d'installation (12 scripts)
  * Scripts configuration (6 scripts)
  * Scripts synchronisation (3 scripts)
  * Scripts désinstallation (13 scripts)
  * Scripts migration (2 scripts)
  * Fonctions ZSH - Gestionnaires (6)
  * Fonctions ZSH - Dev (6)
  * Fonctions ZSH - Misc (9)
  * Fonctions ZSH - Cyber (structure complète + fonctions clés)
  * Fonctions ZSH - Autres (git, utils)
  * Répertoires essentiels (10)
  * Variables d'environnement
  * Symlinks
  * + toutes les vérifications précédentes (PATH, services, Git, outils, NVIDIA)
- ✅ **Rapport détaillé** : Total vérifications, réussies, échecs, avertissements
- ✅ **Solutions suggérées** : Pour chaque problème détecté

### Fichiers créés/modifiés
- ✅ `scripts/lib/install_logger.sh` - Système de logs complet
- ✅ `scripts/lib/check_missing.sh` - Détection éléments manquants
- ✅ `scripts/sync/restore_from_git.sh` - Restaurer depuis Git
- ✅ `scripts/uninstall/uninstall_*.sh` - 11 nouveaux scripts de désinstallation individuelle
- ✅ `setup.sh` - Réorganisation options 50-53, ajout 60-70, 28
- ✅ `scripts/test/validate_setup.sh` - Validation exhaustive (117+ vérifications)
- ✅ `.gitignore` - Ajout install.log
- ✅ `README.md` - Documentation mise à jour

---

## 🚀 PHASE 20 : Système de gestion des *man, alias avec documentation et documentation interactive

### Système de gestion des *man (manman.zsh)
- ✅ **Nouveau fichier** : `zsh/functions/manman.zsh`
  - Gestionnaire centralisé pour tous les gestionnaires (*man.zsh)
  - Menu interactif pour accéder à tous les gestionnaires
  - Détection automatique des gestionnaires disponibles
  - Alias: `mmg`, `managers`
- ✅ **Gestionnaires disponibles** : pathman, netman, aliaman, miscman, searchman, cyberman
- ✅ **Intégration** : Chargé dans `zshrc_custom` après les autres gestionnaires

### Système d'alias avec documentation (alias_utils.zsh)
- ✅ **Nouveau fichier** : `zsh/functions/utils/alias_utils.zsh`
  - Fonctions standalone pour gestion des alias :
    - `add_alias()` - Ajouter un alias avec documentation (description, usage, exemples)
    - `remove_alias()` - Supprimer un alias
    - `change_alias()` - Modifier un alias existant
    - `list_alias()` - Lister tous les alias avec descriptions
    - `search_alias()` - Rechercher un alias par nom/commande/description
    - `get_alias_doc()` - Afficher documentation complète d'un alias
    - `browse_alias_doc()` - Navigation interactive dans la documentation (less)
- ✅ **Système de documentation** :
  - Format: `# DESC:`, `# USAGE:`, `# EXAMPLES:` dans `aliases.zsh`
  - Extraction automatique de la documentation
  - Navigation via less pour listes longues
- ✅ **Intégration** : Chargé dans `zshrc_custom` (Étape 4/5)

### Système de logs centralisé (actions_logger.sh)
- ✅ **Nouveau fichier** : `scripts/lib/actions_logger.sh`
  - Log toutes les actions utilisateur (alias, fonctions, PATH, config)
  - Format: `[timestamp] [type] [action] [status] component | details`
  - Fonctions :
    - `log_action()` - Logger toutes les actions
    - `log_alias_action()` - Logger actions d'alias
    - `log_function_action()` - Logger actions de fonctions
    - `log_path_action()` - Logger actions PATH
    - `log_config_action()` - Logger actions de configuration
    - `show_actions_log()` - Afficher logs avec filtres (pagination via less)
    - `get_actions_summary()` - Statistiques (réussies/échouées/ignorées)
    - `search_actions_log()` - Rechercher dans les logs
    - `get_recent_actions()` - Dernières actions
    - `get_actions_stats()` - Statistiques par type d'action
- ✅ **Fichier de log** : `~/dotfiles/actions.log`
- ✅ **Intégration** : Utilisé par `alias_utils.zsh` pour logger toutes les actions

### Système de documentation automatique (function_doc.sh)
- ✅ **Nouveau fichier** : `scripts/lib/function_doc.sh`
  - Extrait automatiquement la documentation depuis les fichiers
  - Format standard: `# DESC:`, `# USAGE:`, `# EXAMPLES:`, `# RETURNS:`
  - Fonctions :
    - `extract_function_doc()` - Extraire documentation depuis fichiers
    - `generate_all_function_docs()` - Génère `functions_doc.json` avec toute la documentation
    - `show_function_doc()` - Affiche documentation d'une fonction
    - `search_function_doc()` - Recherche dans la documentation
    - `list_all_functions()` - Liste toutes les fonctions documentées
- ✅ **Fichier JSON** : `~/dotfiles/zsh/functions_doc.json` (généré automatiquement)

### Système de documentation interactive complète (dotfiles_doc.sh)
- ✅ **Nouveau fichier** : `scripts/lib/dotfiles_doc.sh`
  - Menu interactif complet avec 12 options
  - Navigation dans toute la documentation des dotfiles
  - Fonctionnalités :
    1. Documentation des fonctions (liste, recherche, voir doc, par catégorie)
    2. Documentation des alias (liste, recherche, voir doc, statistiques)
    3. Documentation des scripts (liste, recherche, voir doc, par catégorie)
    4. Structure du projet (affichage complet via tree/find)
    5. Fichiers de documentation (README, STATUS, STRUCTURE, scripts/README)
    6. Recherche globale dans toute la documentation
    7. Statistiques du projet (totaux, par catégorie)
    8. Logs d'actions (`actions.log`)
    9. Logs d'installation (`install.log`)
    10. Générer/Actualiser documentation
    11. Exporter documentation (Markdown → `DOCUMENTATION_COMPLETE.md`)
    12. Voir structure complète (`STRUCTURE.md`)
- ✅ **Intégration** :
  - Fonction `dotfiles_doc()` dans `zshrc_custom`
  - Alias: `ddoc`, `doc-dotfiles`
- ✅ **Interface** :
  - Menus interactifs clairs
  - Navigation via less pour listes longues
  - Recherche dans toute la documentation
  - Export Markdown pour partage

### Fichiers créés/modifiés
- ✅ `zsh/functions/manman.zsh` - Gestionnaire centralisé des *man
- ✅ `zsh/functions/utils/alias_utils.zsh` - Fonctions standalone pour alias
- ✅ `scripts/lib/actions_logger.sh` - Système de logs centralisé
- ✅ `scripts/lib/function_doc.sh` - Documentation automatique des fonctions
- ✅ `scripts/lib/dotfiles_doc.sh` - Documentation interactive complète
- ✅ `zsh/zshrc_custom` - Chargement de manman et alias_utils
- ✅ `.gitignore` - Exclusion de `actions.log`, `functions_doc.json`, `aliases_doc.json`
- ✅ `STATUS.md` - Documentation mise à jour
- ✅ `STRUCTURE.md` - Documentation mise à jour

### Améliorations système
- ✅ **Documentation standardisée** : Toutes les fonctions utilisent le format `# DESC:`, `# USAGE:`, `# EXAMPLES:`, `# RETURNS:`
- ✅ **Logs centralisés** : Toutes les actions sont automatiquement loggées dans `logs/actions.log`
- ✅ **Navigation interactive** : Interface claire pour naviguer dans toute la documentation
- ✅ **Export disponible** : Export Markdown de toute la documentation

---

## 🚀 PHASE 21 : Réorganisation complète de la structure des fichiers

### Nouvelle organisation
- ✅ **Racine épurée** : Seuls les fichiers essentiels à la racine
  - `Makefile` - Interface standardisée
  - `bootstrap.sh` - Installation depuis zéro
  - `README.md` - Documentation principale
  - `zshrc` - Configuration shell
- ✅ **Dossier `docs/`** : Toute la documentation
  - `STATUS.md` - Historique des modifications
  - `STRUCTURE.md` - Structure complète
- ✅ **Dossier `logs/`** : Tous les logs centralisés
  - `install.log` - Logs d'installation
  - `actions.log` - Logs d'actions utilisateur
  - `auto_backup.log` - Logs de sauvegarde
  - `auto_sync.log` - Logs de synchronisation Git
- ✅ **Dossier `scripts/`** : Tous les scripts organisés
  - `setup.sh` - Menu interactif (déplacé depuis la racine)
  - `install/` - Scripts d'installation
  - `config/` - Scripts de configuration
  - `sync/` - Scripts de synchronisation
  - `test/` - Scripts de validation
  - `uninstall/` - Scripts de désinstallation
  - `lib/` - Bibliothèques communes
  - `vm/` - Scripts de gestion VM

### Fichiers déplacés
- ✅ `STATUS.md` → `docs/STATUS.md`
- ✅ `STRUCTURE.md` → `docs/STRUCTURE.md`
- ✅ `setup.sh` → `scripts/setup.sh`
- ✅ `install.log` → `logs/install.log`
- ✅ `auto_backup.log` → `logs/auto_backup.log`

### Chemins mis à jour
- ✅ **bootstrap.sh** : Références vers `scripts/setup.sh`
- ✅ **Makefile** : Références vers `scripts/setup.sh`
- ✅ **install_logger.sh** : Chemin vers `logs/install.log`
- ✅ **actions_logger.sh** : Chemin vers `logs/actions.log`
- ✅ **git_auto_sync.sh** : Chemin vers `logs/auto_sync.log`
- ✅ **dotfiles_doc.sh** : Chemins vers `docs/`, `logs/`
- ✅ **validate_setup.sh** : Chemins vers `docs/`, `scripts/`
- ✅ **alias_utils.zsh** : Chemin vers `logs/actions.log`
- ✅ **fish/config_custom.fish** : Chemin vers `logs/auto_backup.log`
- ✅ **README.md** : Toutes les références mises à jour
- ✅ **.gitignore** : Exclusion de `logs/` complet

### Avantages de la nouvelle structure
- ✅ **Racine propre** : Seuls les fichiers essentiels
- ✅ **Organisation claire** : Documentation, logs, scripts séparés
- ✅ **Maintenabilité** : Plus facile de trouver et organiser les fichiers
- ✅ **Évolutivité** : Structure extensible pour futurs ajouts

---

## 🚀 PHASE 22 : Système complet de gestion de VM en ligne de commande

### Système de gestion de VM (vm_manager.sh)
- ✅ **Nouveau fichier** : `scripts/vm/vm_manager.sh`
  - Gestionnaire complet de VM en ligne de commande
  - 100% en CLI (pas besoin de virt-manager GUI)
  - Toutes les opérations via fonctions ou menu interactif
- ✅ **Fonctionnalités principales** :
  - `create_vm()` - Créer une VM complètement en CLI (avec ou sans ISO)
  - `start_vm()` - Démarrer une VM
  - `stop_vm()` - Arrêter une VM (normal ou forcé)
  - `show_vm_info()` - Afficher infos complètes d'une VM
  - `delete_vm()` - Supprimer complètement une VM
  - `list_vms()` - Lister toutes les VM (actives ou toutes)
- ✅ **Gestion des snapshots** :
  - `create_snapshot()` - Créer un snapshot avec description
  - `list_snapshots()` - Lister tous les snapshots d'une VM
  - `restore_snapshot()` - Restaurer un snapshot (rollback rapide)
  - `delete_snapshot()` - Supprimer un snapshot
- ✅ **Tests automatisés** :
  - `test_dotfiles_in_vm()` - Workflow complet de test des dotfiles
    * Démarre la VM si nécessaire
    * Crée snapshot 'before-test' automatiquement
    * Donne instructions pour tester dans la VM
    * Permet rollback rapide en cas d'erreur
- ✅ **Menu interactif** :
  - `vm_manager_menu()` - Menu complet avec toutes les options
  - Navigation intuitive pour toutes les opérations

### Intégration Makefile
- ✅ **Nouvelles commandes Makefile** :
  - `make vm-menu` - Menu interactif de gestion des VM
  - `make vm-list` - Lister toutes les VM
  - `make vm-create` - Créer une VM (VM=name MEMORY=2048 VCPUS=2 DISK=20 ISO=path)
  - `make vm-start` - Démarrer une VM (VM=name)
  - `make vm-stop` - Arrêter une VM (VM=name)
  - `make vm-info` - Afficher infos d'une VM (VM=name)
  - `make vm-snapshot` - Créer snapshot (VM=name NAME=snap DESC="desc")
  - `make vm-snapshots` - Lister snapshots (VM=name)
  - `make vm-rollback` - Restaurer snapshot (VM=name SNAPSHOT=name)
  - `make vm-test` - Tester dotfiles dans VM (VM=name)
  - `make vm-delete` - Supprimer une VM (VM=name)
- ✅ **Documentation Makefile** : Section "Gestion des VM" ajoutée dans `make help`

### Documentation
- ✅ **Nouveau fichier** : `scripts/vm/README.md`
  - Documentation complète du système de gestion de VM
  - Workflow de test recommandé
  - Exemples d'utilisation
  - Dépannage et notes importantes

### Fichiers créés/modifiés
- ✅ `scripts/vm/vm_manager.sh` - Gestionnaire complet de VM
- ✅ `scripts/vm/README.md` - Documentation complète
- ✅ `Makefile` - Commandes VM ajoutées
- ✅ `README.md` - Section VM ajoutée
- ✅ `docs/STATUS.md` - PHASE 22 documentée

### Avantages du système
- ✅ **Tests en environnement isolé** : Votre machine reste propre
- ✅ **Rollback rapide** : Snapshots pour revenir en arrière instantanément
- ✅ **100% en ligne de commande** : Pas besoin d'interface graphique
- ✅ **Workflow automatisé** : `make vm-test` gère tout automatiquement
- ✅ **Intégration Makefile** : Commandes simples et mémorisables
- ✅ **Snapshots automatiques** : Création automatique avant chaque test

---

## 🚀 PHASE 23 : Fonctions update/upgrade intelligentes avec détection automatique

### Système de détection de distribution (update_system.sh)
- ✅ **Nouveau fichier** : `zsh/functions/misc/system/update_system.sh`
  - Fonction `detect_distro()` - Détection automatique de la distribution Linux
  - Fonction `update()` - Mise à jour intelligente des paquets
  - Fonction `upgrade()` - Mise à jour complète du système
- ✅ **Nouveau fichier** : `fish/functions/update_system.fish`
  - Version Fish de la détection et mise à jour intelligente

### Distributions supportées
- ✅ **Arch-based** : Arch, Manjaro, EndeavourOS → `pacman`
- ✅ **Debian-based** : Debian, Ubuntu, Mint, Kali, Parrot → `apt`
- ✅ **Fedora-based** : Fedora → `dnf`
- ✅ **Gentoo** → `emerge`
- ✅ **NixOS** → `nix-channel` / `nixos-rebuild`
- ✅ **openSUSE** → `zypper`
- ✅ **Alpine** → `apk`
- ✅ **RHEL/CentOS** → `yum`

### Fonctionnalités
- ✅ **Détection automatique** : Détecte la distribution via `/etc/os-release`, `/etc/*-release`, etc.
- ✅ **Adaptation automatique** : Utilise le bon gestionnaire selon la distribution
- ✅ **Mise à jour des paquets** : `update` synchronise les dépôts sans installer
- ✅ **Mise à jour complète** : `upgrade` met à jour tous les paquets
- ✅ **Mode sans confirmation** : Paramètre `--nc` ou `--no-confirm` pour éviter les prompts
- ✅ **Messages clairs** : Affiche la distribution détectée et la commande utilisée
- ✅ **Logs automatiques** : Enregistre les actions dans `logs/actions.log`

### Utilisation avec paramètres
- `update` ou `update --nc` : Mise à jour des paquets (avec ou sans confirmation)
- `upgrade` ou `upgrade --nc` : Mise à jour complète (avec ou sans confirmation)

### Intégration
- ✅ **zshrc_custom** : Chargement prioritaire de `update_system.sh`
  * Suppression des alias `update`/`upgrade` avant chargement
  * Fonctions remplacent les alias
- ✅ **zsh/aliases.zsh** : Alias `update`/`upgrade` supprimés
  * Commentaires expliquant l'utilisation des fonctions
- ✅ **fish/aliases.fish** : Alias `update`/`upgrade` supprimés
  * Commentaires expliquant l'utilisation des fonctions
- ✅ **fish/config_custom.fish** : Chargement prioritaire de `update_system.fish`

### Fichiers créés/modifiés
- ✅ `zsh/functions/misc/system/update_system.sh` - Fonction ZSH
- ✅ `fish/functions/update_system.fish` - Fonction Fish
- ✅ `zsh/aliases.zsh` - Alias supprimés, commentaires ajoutés
- ✅ `fish/aliases.fish` - Alias supprimés, commentaires ajoutés
- ✅ `zsh/zshrc_custom` - Chargement prioritaire de update_system.sh
- ✅ `fish/config_custom.fish` - Chargement prioritaire de update_system.fish
- ✅ `README.md` - Section mise à jour avec détails

### Avantages
- ✅ **Universalité** : Fonctionne sur toutes les distributions majeures
- ✅ **Simplicité** : Une seule commande `update` ou `upgrade` pour toutes les distros
- ✅ **Intelligence** : Détection et adaptation automatiques
- ✅ **Maintenabilité** : Plus besoin de modifier les alias selon la distribution
- ✅ **Cohérence** : Même interface sur toutes les machines, quelle que soit la distribution
- ✅ `STATUS.md` - Documentation mise à jour

### Intégration système de logs
- ✅ `run_script()` modifié pour logger automatiquement :
  * Log début d'exécution (info)
  * Log succès/échec après exécution
- ✅ Toutes les installations via setup.sh sont loggées
- ✅ Format clair permettant de tracer: QUOI, QUAND, POURQUOI, RÉSULTAT

---

## 🎯 PHASE 25 : Gestion Ctrl+C et améliorations bootstrap

### Modifications
- ✅ Gestion complète de Ctrl+C (SIGINT) dans `bootstrap.sh` et `setup.sh`
- ✅ Messages informatifs lors de l'interruption
- ✅ Instructions pour reprendre l'installation
- ✅ Gestion dans `run_script()` pour tous les sous-scripts
- ✅ Retour propre au menu après interruption

### Fichiers créés/modifiés
- ✅ `bootstrap.sh` - Gestionnaire trap pour SIGINT/SIGTERM
- ✅ `scripts/setup.sh` - Gestionnaire trap et gestion dans run_script()
- ✅ Messages informatifs avec état actuel affiché

### Avantages
- ✅ Arrêt propre et informatif lors de Ctrl+C
- ✅ Pas de messages d'erreur confus
- ✅ Instructions claires pour reprendre
- ✅ Expérience utilisateur fluide

---

## 🎯 PHASE 26 : Amélioration documentation et .env automatique

### Modifications
- ✅ Documentation README.md complètement réécrite pour utilisateurs ligne de commande uniquement
- ✅ Explications détaillées de chaque étape interactive
- ✅ Création automatique du fichier `.env` après le clonage
- ✅ Gestion environnement sans interface graphique pour clé SSH
- ✅ Instructions manuelles pour ajout clé SSH si pas de navigateur

### Fichiers créés/modifiés
- ✅ `README.md` - Documentation complètement améliorée
- ✅ `bootstrap.sh` - Création automatique .env, gestion ligne de commande uniquement
- ✅ `.env.example` - Template mis à jour
- ✅ Messages interactifs améliorés avec exemples

### Avantages
- ✅ Documentation réaliste et complète
- ✅ Fonctionne sur Arch Linux fresh install (ligne de commande uniquement)
- ✅ .env créé automatiquement - plus besoin de le créer manuellement
- ✅ Instructions claires pour tous les environnements

---

## 🎯 PHASE 27 : Résolution conflit ghostscript/gs

### Modifications
- ✅ Script automatique de détection ghostscript
- ✅ Création automatique alias `ghs` pour ghostscript
- ✅ Alias `gs` reste pour `git status` (priorité)
- ✅ Détection à chaque ouverture de terminal

### Fichiers créés/modifiés
- ✅ `zsh/functions/utils/fix_ghostscript_alias.sh` - Script de détection et correction
- ✅ `zsh/zshrc_custom` - Intégration script (étape 6)
- ✅ `zsh/aliases.zsh` - Alias ghs ajouté

### Avantages
- ✅ Résout automatiquement le conflit sur toutes les machines
- ✅ Fonctionne dès l'ouverture du terminal
- ✅ Informe l'utilisateur de la configuration
- ✅ Solution permanente et automatique

