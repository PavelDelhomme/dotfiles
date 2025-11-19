# STATUS.md - Historique des modifications

Ce fichier documente toutes les modifications apportées aux dotfiles depuis le début de la refactorisation complète.

**Version :** 2.2.0  
**Date de création :** Décembre 2024  
**Dernière mise à jour :** Décembre 2024

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
```bash
make help             # Aide complète
make install          # Installation complète
make setup            # Menu interactif
make validate         # Validation setup
make symlinks         # Créer symlinks
make migrate          # Migrer config existante
make install-docker   # Installer Docker
make install-go       # Installer Go
make install-cursor   # Installer Cursor
make install-brave    # Installer Brave
make install-yay      # Installer yay
make git-config       # Config Git
make git-remote       # Config remote Git
make auto-sync        # Config auto-sync
make rollback         # Rollback complet
make reset            # Réinitialisation complète
make clean            # Nettoyer fichiers temporaires
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
curl | bash bootstrap.sh
# → Questions multiples
# → Choix entre make install / make setup / bash setup.sh
# → Confusion sur quelle méthode utiliser
```

**Maintenant :**
```bash
curl | bash bootstrap.sh
# → Configuration Git automatique
# → Clonage dotfiles
# → Menu interactif lancé automatiquement
# → État d'installation affiché en haut du menu
# → Choix clair des options à installer
```

### Avantages
- ✅ **Workflow linéaire** : Une seule commande, tout est automatique
- ✅ **Visibilité immédiate** : L'utilisateur voit directement l'état de son installation
- ✅ **Guidage clair** : Chaque élément manquant indique quelle option choisir
- ✅ **Pas de confusion** : Plus de questions intermédiaires, le menu gère tout

---

**Dernière mise à jour :** Décembre 2024  
**Version :** 2.4.0 (Refactorisation complète + Centralisation symlinks + Makefile + Workflow simplifié + Migration shell + CYBERMAN + ensure_tool + Réorganisation cyber/ + Simplification zshrc)

