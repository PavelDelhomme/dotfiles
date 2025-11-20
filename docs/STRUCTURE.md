# Structure complète des dotfiles

## Fichiers principaux à la racine

- `Makefile` - **Interface standardisée** avec `make` pour toutes les opérations (recommandé)
- `bootstrap.sh` - Script principal pour installer depuis zéro (curl) - **Configuration Git automatique + Test SSH GitHub + Clone repo + Lancement menu**
- `README.md` - Documentation complète du projet
- `zshrc` - Configuration shell principale (détection Zsh/Fish)

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
│       ├── install_yay.sh    # yay AUR helper
│       ├── install_qemu_full.sh  # Installation complète QEMU/KVM
│       └── verify_network.sh     # Vérification réseau QEMU/KVM
│
├── sync/                       # Synchronisation Git
│   ├── git_auto_sync.sh        # Script de synchronisation (pull/push)
│   ├── install_auto_sync.sh    # Installation systemd timer
│   └── restore_from_git.sh     # Restaurer depuis Git (option 28)
│
├── test/                       # Validation & tests
│   └── validate_setup.sh       # Validation complète du setup (117+ vérifications)
│
├── lib/                        # Bibliothèques communes
│   ├── common.sh               # Fonctions communes (logging, couleurs)
│   ├── install_logger.sh       # Système de logs d'installation
│   ├── check_missing.sh        # Détection éléments manquants
│   ├── actions_logger.sh       # Système de logs centralisé (actions utilisateur)
│   ├── function_doc.sh         # Documentation automatique des fonctions
│   └── dotfiles_doc.sh         # Documentation interactive complète (menu interactif)
│
├── uninstall/                  # Désinstallation et rollback
│   ├── rollback_all.sh         # Rollback complet (désinstaller tout) - Option 99
│   ├── rollback_git.sh         # Rollback Git uniquement
│   ├── reset_all.sh            # Réinitialisation complète (rollback + suppression + réinstallation) - Option 98
│   ├── uninstall_git_config.sh # Désinstaller config Git - Option 60
│   ├── uninstall_git_remote.sh # Désinstaller remote Git - Option 61
│   ├── uninstall_base_packages.sh # Désinstaller paquets de base - Option 62
│   ├── uninstall_package_managers.sh # Désinstaller gestionnaires - Option 63
│   ├── uninstall_brave.sh      # Désinstaller Brave - Option 64
│   ├── uninstall_cursor.sh     # Désinstaller Cursor - Option 65
│   ├── uninstall_docker.sh     # Désinstaller Docker - Option 66
│   ├── uninstall_go.sh         # Désinstaller Go - Option 67
│   ├── uninstall_yay.sh        # Désinstaller yay - Option 68
│   ├── uninstall_auto_sync.sh  # Désinstaller auto-sync - Option 69
│   └── uninstall_symlinks.sh   # Désinstaller symlinks - Option 70
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
| `tools/install_qemu_full.sh` | Installation complète QEMU/KVM avec virt-manager, snapshots, etc. | Option 11 (via scripts/config/) |
| `tools/verify_network.sh` | Vérification configuration réseau QEMU/KVM (NAT, libvirt, etc.) | - |

### Scripts de gestion VM (scripts/vm/)

| Script | Description | Usage |
|--------|-------------|-------|
| `vm/vm_manager.sh` | Gestionnaire complet de VM en ligne de commande. Création, démarrage, arrêt, snapshots, rollback, tests. Fonctions: `create_vm()`, `start_vm()`, `stop_vm()`, `create_snapshot()`, `restore_snapshot()`, `test_dotfiles_in_vm()`. Menu interactif disponible. | Via Makefile ou directement |
| `vm/create_test_vm.sh` | Création VM de test (ancien, utilise virt-manager GUI) | - |
| `vm/README.md` | Documentation complète de gestion des VM | - |

### Scripts de gestion VM (scripts/vm/)

| Script | Description | Usage |
|--------|-------------|-------|
| `vm/vm_manager.sh` | Gestionnaire complet de VM en ligne de commande. Création, démarrage, arrêt, snapshots, rollback, tests. Fonctions: `create_vm()`, `start_vm()`, `stop_vm()`, `create_snapshot()`, `restore_snapshot()`, `test_dotfiles_in_vm()`. Menu interactif disponible. | Via Makefile ou directement |
| `vm/create_test_vm.sh` | Création VM de test (ancien, utilise virt-manager GUI) | - |
| `vm/README.md` | Documentation complète de gestion des VM | - |

### Scripts de synchronisation (scripts/sync/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `sync/git_auto_sync.sh` | Synchronisation automatique Git (pull/push). Gestion des conflits. | Option 14 |
| `sync/install_auto_sync.sh` | Installation systemd timer pour auto-sync toutes les heures | Option 12 |
| `sync/restore_from_git.sh` | Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés) | Option 28 |

### Scripts de test (scripts/test/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `test/validate_setup.sh` | Validation complète du setup (117+ vérifications exhaustives). Vérifie structure, scripts, fonctions, PATH, services, Git, outils, symlinks, NVIDIA. | Option 23 |

### Bibliothèques communes (scripts/lib/)

| Script | Description | Usage |
|--------|-------------|-------|
| `lib/common.sh` | Fonctions communes (logging, couleurs). Source par tous les scripts. | Source automatique |
| `lib/install_logger.sh` | Système de logs d'installation. Logger toutes les actions (install/config/uninstall/test) avec timestamp, statut, détails. Fichier: `~/dotfiles/install.log` | Source par setup.sh |
| `lib/check_missing.sh` | Détection éléments manquants. Vérifie tous les composants installables et retourne ce qui manque. Groupement par catégories. | Source par setup.sh |

### Scripts de désinstallation (scripts/uninstall/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `uninstall/rollback_all.sh` | Rollback complet - Désinstalle tout ce qui a été installé et configuré | Option 99 |
| `uninstall/rollback_git.sh` | Rollback Git uniquement - Revenir à une version précédente | - |
| `uninstall/reset_all.sh` | Réinitialisation complète - Rollback + suppression dotfiles + réinstallation | Option 98 |
| `uninstall/uninstall_git_config.sh` | Désinstaller configuration Git (user.name, user.email, credential.helper) | Option 60 |
| `uninstall/uninstall_git_remote.sh` | Désinstaller ou réinitialiser remote Git (origin) | Option 61 |
| `uninstall/uninstall_base_packages.sh` | Désinstaller paquets de base (xclip, curl, wget, make, cmake, gcc, git, base-devel, zsh, btop) | Option 62 |
| `uninstall/uninstall_package_managers.sh` | Désinstaller gestionnaires de paquets (yay, snapd, flatpak) | Option 63 |
| `uninstall/uninstall_brave.sh` | Désinstaller Brave Browser (+ dépôt optionnel) | Option 64 |
| `uninstall/uninstall_cursor.sh` | Désinstaller Cursor IDE (AppImage, config, cache, alias) | Option 65 |
| `uninstall/uninstall_docker.sh` | Désinstaller Docker & Docker Compose (+ conteneurs/images optionnels) | Option 66 |
| `uninstall/uninstall_go.sh` | Désinstaller Go (Golang) (+ GOPATH/GOROOT optionnels) | Option 67 |
| `uninstall/uninstall_yay.sh` | Désinstaller yay AUR helper (Arch Linux uniquement) | Option 68 |
| `uninstall/uninstall_auto_sync.sh` | Désinstaller auto-sync Git (systemd timer/service) | Option 69 |
| `uninstall/uninstall_symlinks.sh` | Désinstaller symlinks (.zshrc, .gitconfig, .ssh, etc.) | Option 70 |

### Scripts de configuration (scripts/config/)

| Script | Description | Options menu |
|--------|-------------|--------------|
| `config/create_symlinks.sh` | Créer symlinks pour centraliser la configuration (.zshrc, .gitconfig, .ssh/) | Option 24 |
| `migrate_existing_user.sh` | Migrer configuration existante vers structure dotfiles centralisée | - |

## Interface Makefile (recommandé)

Le Makefile fournit une interface standardisée et simple pour toutes les opérations :

```bash
cd ~/dotfiles
make help             # Voir toutes les commandes disponibles
make install          # Installation complète
make setup            # Menu interactif
make validate         # Valider le setup
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

**Avantages :**
- Interface standardisée et universelle
- Commandes plus simples et mémorisables
- Documentation intégrée (`make help`)
- Compatible avec tous les scripts bash existants

## Workflow d'utilisation

### 1. Installation complète (nouvelle machine)

**Méthode 1 : Makefile (recommandé)**
```bash
# Installation initiale
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash

# Puis utiliser le Makefile
cd ~/dotfiles
make install          # Installation complète
make setup            # Menu interactif
make validate         # Valider le setup
```

**Méthode 2 : Scripts bash (alternative)**
Une seule ligne :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

**Ce que fait bootstrap.sh :**
1. ✅ Vérifie et installe Git si nécessaire (pacman/apt/dnf)
2. ✅ Configure Git (nom et email) avec valeurs par défaut ou interactif
3. ✅ Configure credential helper (cache pour 15 minutes)
4. ✅ Génère clé SSH ED25519 si absente (avec email configuré)
5. ✅ Copie clé publique dans presse-papier automatiquement
6. ✅ Ouvre GitHub pour ajouter la clé SSH
7. ✅ **Teste connexion GitHub SSH** (`ssh -T git@github.com`) - Vérifie que GitHub est accessible
8. ✅ Clone le repo dotfiles dans `~/dotfiles` si inexistant
9. ✅ Met à jour si repo existe déjà (`git pull`)
10. ✅ Demande choix du shell (Zsh/Fish/Les deux)
11. ✅ Crée symlinks si demandé
12. ✅ Lance automatiquement scripts/setup.sh (menu interactif)

### 2. Menu interactif (scripts/setup.sh)

**Options principales (70+ options) :**
- 1-2 : Configuration Git
- 3-4 : Installation paquets de base et gestionnaires
- 5-7 : Configuration QEMU/KVM
- 8-9 : Installation Cursor et PortProton
- 10 : Installation complète système (avec prompts optionnels)
- 11 : Configuration complète QEMU
- 12-15 : Auto-sync Git (installation, activer/désactiver, test, statut)
- 16-19 : Installations Docker, Brave, yay, Go
- 20-22 : Recharger configuration ZSH, Installer fonctions USB test, Créer symlinks
- 23 : Validation complète du setup (117+ vérifications exhaustives)
- 24 : Créer symlinks (centraliser configuration)
- 25 : Sauvegarde manuelle (commit + push Git)
- 26-27 : Migration shell (Fish ↔ Zsh), Changer shell par défaut
- 28 : Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés)
- 50 : Afficher ce qui manque (état détaillé, scrollable via less)
- 51 : Installer éléments manquants un par un (menu interactif)
- 52 : Installer tout ce qui manque automatiquement (avec logs)
- 53 : Afficher logs d'installation (voir ce qui a été fait, quand, pourquoi) - `logs/install.log`
- 60-70 : Désinstallation individuelle (config Git, remote Git, paquets base, gestionnaires, Brave, Cursor, Docker, Go, yay, auto-sync, symlinks)
- 98-99 : RÉINITIALISATION complète, ROLLBACK complet

**Utilisation:**
- `bash scripts/setup.sh` - Lancer le menu interactif
- `make setup` - Alternative via Makefile

### 3. Cas d'usage

#### Nouvelle machine
Lancer le bootstrap :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Répondre aux prompts → Choisir option 10 pour installation complète.

#### Mise à jour dotfiles
```bash
cd ~/dotfiles
git pull
bash setup.sh
# Choisir les options nécessaires
```

#### Validation setup
Lancer la validation :

```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

Ou via menu : option 23.

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

1. **bootstrap.sh** → Installation Git + Configuration Git + Test SSH GitHub + Clone repo + Lancement menu
2. **scripts/setup.sh option 50** → Voir ce qui manque (état détaillé)
3. **scripts/setup.sh option 52** → Installer tout ce qui manque automatiquement (OU option 51 pour installer un par un)
4. **scripts/setup.sh option 23** → Valider le setup complet (117+ vérifications)
5. **scripts/setup.sh option 53** → Consulter les logs d'installation (`logs/install.log`)

**Ou manuellement :**
1. **bootstrap.sh** → Configuration Git + Clone repo + Lancement menu
2. **scripts/setup.sh option 3-4** → Paquets de base + Gestionnaires
3. **scripts/setup.sh option 18** → Installer yay (si Arch)
4. **scripts/setup.sh option 16** → Installer Docker
5. **scripts/setup.sh option 8-9** → Installer Cursor + PortProton
6. **scripts/setup.sh option 19** → Installer Go
7. **scripts/setup.sh option 12** → Configurer auto-sync Git
8. **scripts/setup.sh option 23** → Valider le setup

## Structure zsh/functions/

### Gestionnaires (*man.zsh)

| Gestionnaire | Description | Fichier |
|--------------|-------------|---------|
| `pathman` | Gestionnaire PATH | `pathman.zsh` |
| `netman` | Gestionnaire réseau | `netman.zsh` |
| `aliaman` | Gestionnaire alias (interactif) | `aliaman.zsh` |
| `miscman` | Gestionnaire divers | `miscman.zsh` |
| `searchman` | Gestionnaire recherche | `searchman.zsh` |
| `cyberman` | Gestionnaire cybersécurité | `cyberman.zsh` |
| `manman` | Gestionnaire centralisé (menu pour tous les *man) | `manman.zsh` |

**Utilisation:**
- `manman` (ou `mmg`, `managers`) - Menu interactif pour accéder à tous les gestionnaires
- Chaque gestionnaire a son propre menu interactif

### Utilitaires (utils/)

| Utilitaire | Description | Fichier |
|------------|-------------|---------|
| `ensure_tool.sh` | Vérification et installation automatique d'outils | `utils/ensure_tool.sh` |
| `alias_utils.zsh` | Fonctions standalone pour gestion des alias | `utils/alias_utils.zsh` |

**Fonctions alias_utils:**
- `add_alias()` - Ajouter un alias avec documentation
- `remove_alias()` - Supprimer un alias
- `change_alias()` - Modifier un alias
- `list_alias()` - Lister tous les alias avec descriptions
- `search_alias()` - Rechercher un alias
- `get_alias_doc()` - Documentation complète d'un alias
- `browse_alias_doc()` - Navigation interactive dans la documentation

## Structure zsh/functions/ (détaillée)

```
zsh/functions/
├── *man.zsh                 # Gestionnaires interactifs
│   ├── pathman.zsh         # Gestionnaire PATH
│   ├── netman.zsh          # Gestionnaire réseau
│   ├── aliaman.zsh         # Gestionnaire alias
│   ├── miscman.zsh         # Gestionnaire divers
│   ├── searchman.zsh       # Gestionnaire recherche
│   └── cyberman.zsh        # Gestionnaire cybersécurité (NOUVEAU)
│
├── cyber/                   # Fonctions cybersécurité (réorganisé en sous-dossiers)
│   ├── reconnaissance/     # Information gathering
│   │   ├── domain_whois.sh, dns_lookup.sh, dnsenum_scan.sh
│   │   ├── find_subdomains.sh, recon_domain.sh, enhanced_traceroute.sh
│   │   ├── network_map.sh, get_http_headers.sh, analyze_headers.sh
│   │   └── get_robots_txt.sh
│   ├── scanning/           # Port scanning & enumeration
│   │   ├── port_scan.sh, scan_ports.sh, web_port_scan.sh, scan_web_ports.sh
│   │   ├── enum_dirs.sh, enum_shares.sh, enumerate_users.sh
│   │   └── web_dir_enum.sh
│   ├── vulnerability/      # Vulnerability assessment
│   │   ├── nmap_vuln_scan.sh, vuln_scan.sh, scan_vulns.sh
│   │   ├── nikto_scan.sh, web_vuln_scan.sh
│   │   └── check_ssl.sh, check_ssl_cert.sh, check_heartbleed.sh
│   ├── attacks/            # Network attacks & exploitation
│   │   ├── arp_spoof.sh, brute_ssh.sh, password_crack.sh
│   │   ├── deauth_attack.sh, web_traceroute.sh
│   ├── analysis/           # Network analysis & monitoring
│   │   ├── sniff_traffic.sh, wifi_scan.sh
│   └── privacy/            # Privacy & anonymity
│       ├── start_tor.sh, stop_tor.sh, proxycmd.sh
│
├── utils/                   # Utilitaires partagés
│   └── ensure_tool.sh      # Vérification/installation outils
│
├── git/                     # Fonctions Git
│   └── git_functions.sh
│
├── dev/                     # Fonctions développement & DevOps
│   ├── go.sh                # Go: build, test, run, mod, fmt, vet, clean, bench
│   ├── c.sh                 # C/C++: compile, debug, clean, check
│   ├── docker.sh            # Docker: build, push, cleanup, logs, exec, stats
│   ├── make.sh              # Make: targets, clean, help, build, test, install
│   └── projects/            # Projets spécifiques
│       ├── cyna.sh          # Fonctions spécifiques projet CYNA
│       └── weedlyweb.sh     # Fonctions spécifiques projet WeedlyWeb
│
├── misc/                    # Fonctions diverses (organisées en sous-dossiers)
│   ├── clipboard/           # Copie presse-papier
│   │   ├── file.sh          # copy_file
│   │   ├── command_output.sh # copy_last_command_output
│   │   ├── tree.sh          # copy_tree
│   │   ├── path.sh          # copy_path, copy_filename, copy_parent
│   │   └── text.sh          # copy_text, copy_pwd, copy_cmd
│   │
│   ├── security/            # Sécurité & chiffrement
│   │   ├── encrypt_file.sh  # encrypt_file
│   │   ├── decrypt_file.sh  # decrypt_file
│   │   ├── password.sh      # gen_password
│   │   └── colorpasswd.sh   # colorpasswd
│   │
│   ├── files/               # Gestion fichiers & archives
│   │   └── archive.sh       # extract, archive, file_size, find_large_files, find_duplicates
│   │
│   ├── system/              # Système & processus
│   │   ├── system_info.sh   # system_info
│   │   ├── disk.sh          # disk_usage, system_clean, top_processes, disk_space, watch_directory
│   │   ├── process.sh       # kill_process, kill_port, port_process, watch_process
│   │   ├── reload_shell.sh  # reload_shell
│   │   └── usb.sh           # usb_test_functions
│   │
│   └── backup/              # Sauvegardes
│       └── create_backup.sh # create_backup
└── network/                 # Fonctions réseau (utiliser netman)
```

### Gestionnaires (*man.zsh)

| Gestionnaire | Description | Fonctions |
|--------------|-------------|-----------|
| `pathman` | Gestion du PATH | Ajout, retrait, nettoyage, sauvegarde |
| `netman` | Gestion réseau | Ports, connexions, DNS, routing |
| `aliaman` | Gestion alias | Ajout, modification, suppression, recherche |
| `miscman` | Outils divers | Backup, cryptage, génération mots de passe |
| `searchman` | Recherche | Historique, fonctions, fichiers |
| `cyberman` | Cybersécurité | 36+ fonctions organisées par catégories |

### CYBERMAN - Gestionnaire cybersécurité

**Organisation par catégories :**

1. **🔍 Reconnaissance & Information Gathering**
   - WHOIS, DNS lookup, DNSEnum, subdomains, reconnaissance domaine
   - HTTP headers, robots.txt, network mapping

2. **🔎 Scanning & Enumeration**
   - Port scanning (nmap), énumération répertoires (dirb, gobuster)
   - Énumération partages, utilisateurs, web directories

3. **🛡️ Vulnerability Assessment**
   - Scans de vulnérabilités (nmap, nikto)
   - Vérification SSL/TLS, Heartbleed

4. **⚔️ Network Attacks & Exploitation**
   - ARP spoofing, brute force SSH
   - Désauthentification Wi-Fi, password cracking

5. **📡 Network Analysis & Monitoring**
   - Capture trafic (tcpdump), scan Wi-Fi

6. **🔒 Privacy & Anonymity**
   - Tor, proxychains

**Utilisation :**
```bash
cyberman              # Menu interactif complet
cyberman recon        # Menu reconnaissance
cyberman scan         # Menu scanning
cyberman vuln         # Menu vulnérabilités
cyberman attack       # Menu attaques
cyberman analysis     # Menu analyse
cyberman privacy      # Menu anonymat
cyberman help         # Aide
cm                    # Alias court
```

### Gestionnaire centralisé (manman.zsh)

**Description:** Gestionnaire centralisé pour tous les gestionnaires (*man.zsh).

**Utilisation:**
```bash
manman          # Menu interactif pour accéder à tous les gestionnaires
mmg            # Alias pour manman
managers       # Alias pour manman
```

**Fonctionnalités:**
- Détection automatique des gestionnaires disponibles
- Menu interactif avec numérotation
- Lance directement le gestionnaire sélectionné

**Gestionnaires disponibles:**
- pathman (📁 Gestionnaire PATH)
- netman (🌐 Gestionnaire réseau)
- aliaman (📝 Gestionnaire alias)
- miscman (🔧 Gestionnaire divers)
- searchman (🔍 Gestionnaire recherche)
- cyberman (🛡️ Gestionnaire cybersécurité)

### Utilitaires alias (alias_utils.zsh)

**Description:** Fonctions standalone pour gestion des alias avec documentation complète.

**Utilisation:**
```bash
# Ajouter un alias avec documentation
add_alias ll "ls -lah" "Liste détaillée" "ll" "ll -R"

# Lister tous les alias avec descriptions
list_alias

# Rechercher un alias
search_alias "git"

# Voir documentation complète
get_alias_doc ll

# Navigation interactive dans la documentation
browse_alias_doc
```

**Format documentation dans aliases.zsh:**
```bash
# DESC: Description de l'alias
# USAGE: Usage de l'alias
# EXAMPLES: Exemples d'utilisation
alias name="command"
```

**Fonctions disponibles:**
- `add_alias()` - Ajouter un alias avec documentation
- `remove_alias()` - Supprimer un alias
- `change_alias()` - Modifier un alias existant
- `list_alias()` - Lister tous les alias avec descriptions
- `search_alias()` - Rechercher un alias par nom/commande/description
- `get_alias_doc()` - Afficher documentation complète d'un alias
- `browse_alias_doc()` - Navigation interactive dans la documentation (less)

**Intégration logs:**
- Toutes les actions sont automatiquement loggées dans `actions.log` via `actions_logger.sh`

### Documentation interactive (dotfiles_doc.sh)

**Description:** Système de documentation interactive complète des dotfiles.

**Utilisation:**
```bash
dotfiles_doc    # Menu interactif complet
ddoc           # Alias pour dotfiles_doc
doc-dotfiles   # Alias pour dotfiles_doc
```

**Menu principal (12 options):**

1. **📖 Documentation des fonctions**
   - Lister toutes les fonctions
   - Rechercher une fonction
   - Voir documentation complète
   - Fonctions par catégorie

2. **📝 Documentation des alias**
   - Lister tous les alias
   - Rechercher un alias
   - Voir documentation complète
   - Statistiques des alias

3. **🔧 Documentation des scripts**
   - Lister tous les scripts
   - Rechercher un script
   - Voir documentation d'un script
   - Scripts par catégorie

4. **📁 Structure du projet**
   - Affichage de la structure complète

5. **📋 Fichiers de documentation**
   - README.md
   - STATUS.md
   - STRUCTURE.md
   - scripts/README.md

6. **🔎 Recherche globale**
   - Recherche dans toute la documentation

7. **📊 Statistiques du projet**
   - Total de fichiers, scripts, fonctions, alias
   - Structure par catégorie

8. **📜 Logs d'actions**
   - Voir `actions.log`

9. **📝 Logs d'installation**
   - Voir `install.log`

10. **🔄 Générer/Actualiser documentation**
    - Génère `functions_doc.json`

11. **📤 Exporter documentation**
    - Exporte `DOCUMENTATION_COMPLETE.md`

12. **🗂️ Voir structure complète**
    - Affiche `STRUCTURE.md`

**Fichiers générés:**
- `~/dotfiles/zsh/functions_doc.json` - Documentation JSON des fonctions
- `~/dotfiles/DOCUMENTATION_COMPLETE.md` - Export Markdown complet

### Fonction utilitaire ensure_tool

**Description :** Vérifie si un outil est installé et propose de l'installer automatiquement si nécessaire.

**Fonctionnalités :**
- ✅ Détection automatique distribution (Arch, Debian, Fedora, Gentoo)
- ✅ Mapping outils → paquets pour chaque distribution
- ✅ Installation automatique via gestionnaire approprié
- ✅ Support AUR (yay) pour Arch Linux
- ✅ Proposition interactive avant installation

**Utilisation :**
```bash
# Dans un script
source "$HOME/dotfiles/zsh/functions/utils/ensure_tool.sh"
ensure_tool nmap           # Vérifie/installe nmap
ensure_tool hydra          # Vérifie/installe hydra
ensure_tool arpspoof       # Vérifie/installe dsniff (package pour arpspoof)

# Vérifier plusieurs outils
ensure_tools nmap nikto hydra
```

**Mapping outils → paquets :**
- `arpspoof` → `dsniff` (Arch/Debian/Fedora)
- `hydra` → `hydra`
- `nmap` → `nmap`
- `nikto` → `nikto`
- `gobuster` → `gobuster`
- `aireplay-ng` → `aircrack-ng`
- Et bien d'autres...

**Détection distribution :**
- Arch Linux : `/etc/arch-release`
- Debian/Ubuntu : `/etc/debian_version`
- Fedora : `/etc/fedora-release`
- Gentoo : `/etc/gentoo-release` ou `/etc/portage/make.conf`

## Notes importantes

- **auto_sync_dotfiles.sh** (racine) a été supprimé → Utiliser `scripts/sync/git_auto_sync.sh`
- **install_go.sh** (racine) a été déplacé → Utiliser `scripts/install/dev/install_go.sh`
- Les scripts sont organisés par catégorie : `apps/`, `dev/`, `tools/`, `system/`
- Les scripts utilisent `add_alias` et `add_to_path` si disponibles
- Les scripts cyber utilisent maintenant `ensure_tool` pour vérification automatique d'outils
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

