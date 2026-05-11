# Installation & déploiement — Dotfiles

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte doc** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Carte code** : [`../CODEMAP.md`](../CODEMAP.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`../../STATUS.md`](../../STATUS.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md)

---

## Sommaire

1. [Installation rapide (nouvelle machine)](#installation-rapide-nouvelle-machine)
2. [Réinstallation](#reinstallation)
3. [Configuration GitHub SSH](#configuration-github-ssh)
4. [Workflow complet — nouvelle machine](#workflow-complet--nouvelle-machine)
5. [Rollback / désinstallation](#rollback--desinstallation)
6. [Installation complète du système (setup.sh)](#installation-complete-du-systeme-setupsh)
7. [Auto-synchronisation Git](#auto-synchronisation-git)
8. [Brave Browser](#brave-browser)
9. [Options du menu `setup.sh` + logs d’installation](#options-du-menu-setupsh--logs-dinstallation)
10. [Scripts modulaires](#scripts-modulaires)
11. [Flutter & Android](#flutter--android)
12. [NVIDIA RTX 3060](#nvidia-rtx-3060)

---

## 🚀 Installation rapide (nouvelle machine)

### Installation en une seule commande

**UNE SEULE LIGNE** pour tout installer et configurer :

Méthode 1 : Pipe (peut avoir des problèmes dans certains environnements)
```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Méthode 2 : Process substitution (recommandé si méthode 1 ne fonctionne pas)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
```

Méthode 3 : Téléchargement puis exécution (si les deux autres ne fonctionnent pas)
```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh -o /tmp/bootstrap.sh && bash /tmp/bootstrap.sh
```

**📝 Note importante sur le fichier `.env` :**

Le fichier `.env` permet d'éviter de saisir vos informations Git à chaque installation. Cependant, **vous ne pouvez le créer qu'APRÈS avoir cloné le repository** (étape 4). 

Si vous voulez créer le fichier `.env` pour éviter les questions interactives lors des prochaines installations, vous pourrez le faire après le clonage :

```bash
cd ~/dotfiles
cp .env.example .env
nano .env  # ou votre éditeur préféré (vim, code, etc.)
```

Voir [Configuration Git via .env](#configuration-git-via-env) pour plus de détails.

**🔄 Processus d'installation automatique :**

Cette commande va automatiquement exécuter les étapes suivantes :

**1. Vérification et installation de Git**
- Détection automatique du gestionnaire de paquets (pacman/apt/dnf)
- Installation automatique si Git n'est pas présent

**2. Configuration Git (nom et email)** ⚠️ **INTERACTIF**
- **Si Git est déjà configuré** : Utilise la configuration existante (aucune demande)
- **Si le fichier `.env` existe** (après le clonage) : Charge `GIT_USER_NAME` et `GIT_USER_EMAIL` depuis `.env`
- **Sinon, le script vous demandera interactivement** :
  ```
  Configuration Git nécessaire
  Aucune information personnelle ne sera utilisée par défaut
  
  Nom Git (obligatoire): 
  ```
  ⚠️ **Explication : Nom Git**
  - C'est le **nom qui apparaîtra dans vos commits Git** (visible dans `git log`, GitHub, GitLab, etc.)
  - Exemples : `PavelDelhomme`, `Jean Dupont`, `John Doe`
  - Ce nom sera utilisé pour identifier l'auteur de vos commits
  - Vous pouvez utiliser votre vrai nom, un pseudonyme, ou votre nom d'utilisateur GitHub
  
  ```
  Email Git (obligatoire): 
  ```
  ⚠️ **Explication : Email Git**
  - C'est l'**adresse email associée à votre compte GitHub/GitLab**
  - Cette email doit correspondre à celle de votre compte GitHub/GitLab pour que vos commits soient liés à votre profil
  - Exemples : `votre.email@example.com`, `username@users.noreply.github.com`
  - ⚠️ **Important** : Si vous utilisez GitHub, vous pouvez utiliser l'email `username@users.noreply.github.com` pour garder votre email privé (visible dans les paramètres GitHub)
  - Validation automatique du format d'email
- Configuration du credential helper (cache pour 15 minutes)

**3. Configuration SSH pour GitHub** ⚠️ **OPTIONNEL - PEUT ÊTRE BYPASSÉE**

**⚠️ IMPORTANT : Cette étape est optionnelle ! Vous pouvez choisir de la passer.**

Le script vous propose un menu interactif avec 3 options :

```
Souhaitez-vous configurer SSH pour GitHub ?
Cela permet de cloner/pusher sans saisir vos identifiants.

  1. Oui, configurer SSH (recommandé)
  2. Non, passer cette étape (vous pourrez cloner via HTTPS)  ⚠️ BYPASS
  0. Vérifier si SSH est déjà configuré et fonctionne
```

**Option 1 : Oui, configurer SSH (recommandé)**
- Génération automatique de la clé SSH ED25519 (si absente)
- Utilise l'email Git configuré précédemment pour la clé
- **Si environnement graphique disponible** :
  - Copie la clé publique dans le presse-papier automatiquement
  - Ouvre GitHub dans le navigateur pour ajouter la clé SSH
- **Si ligne de commande uniquement (pas d'interface graphique)** :
  - Affiche la clé SSH publique à l'écran
  - Donne les instructions pour l'ajouter manuellement sur GitHub
  - Instructions pour utiliser GitHub CLI si disponible
- ⚠️ **Action requise** : Vous devez ajouter la clé SSH dans votre compte GitHub
  - **Avec navigateur** : Aller dans GitHub → Settings → SSH and GPG keys → New SSH key → Coller la clé
  - **Sans navigateur** : Utiliser une autre machine ou GitHub CLI (`gh ssh-key add`)
- Le script attend que vous appuyiez sur Entrée après avoir ajouté la clé
- Test de la connexion GitHub SSH (`ssh -T git@github.com`)

**Option 2 : Non, passer cette étape (BYPASS)** ⚠️ **VOUS POUVEZ CHOISIR ÇA**
- ⚠️ **Passe complètement la configuration SSH**
- Vous devrez utiliser HTTPS pour cloner (avec authentification GitHub lors du clonage)
- Utile si vous voulez juste installer rapidement sans configurer SSH
- Vous pourrez configurer SSH plus tard si nécessaire

**Option 0 : Vérifier si SSH est déjà configuré**
- Vérifie automatiquement si une clé SSH existe
- Teste la connexion GitHub SSH
- Si SSH fonctionne déjà : propose automatiquement de passer cette étape
- Si SSH ne fonctionne pas : vous pouvez choisir de reconfigurer ou bypasser

**4. Clonage ou mise à jour du repository dotfiles**
- **Si SSH configuré (option 1)** : Clone depuis GitHub via SSH (méthode recommandée, pas besoin de saisir identifiants)
- **Si SSH bypassé (option 2)** : Clone depuis GitHub via HTTPS (vous devrez vous authentifier avec votre token GitHub lors du clonage)
- Cloner dans `~/dotfiles` si inexistant
- Mettre à jour (`git pull`) si repo existe déjà
- Support des variables d'environnement `.env` (GITHUB_REPO_URL)
- Utilise l'URL par défaut si `.env` non configuré
- Si le dossier existe mais n'est pas un repo Git, demande confirmation pour le supprimer
- ✅ **Création automatique du fichier `.env`** avec les informations fournies (Nom Git, Email Git, URL repository)
  - Le fichier `.env` est créé automatiquement après le clonage
  - Contient vos informations pour éviter de les redemander lors des prochaines installations
  - Vous pouvez le modifier plus tard si nécessaire

**5. Choix du shell** (Zsh/Fish/Les deux) ⚠️ **INTERACTIF**
- Menu interactif :
  ```
  Quel shell souhaitez-vous configurer?
    1. Zsh (recommandé)
    2. Fish
    3. Les deux (Fish et Zsh)
    0. Passer cette étape
  ```
- Sélection du shell à configurer
- Support de plusieurs shells simultanés
- Passage de la sélection au menu `setup.sh`

**6. Création des symlinks** (si demandé) ⚠️ **INTERACTIF**
- Demande : `Créer les symlinks pour centraliser la configuration? (o/n)`
- Centralisation de la configuration
- Backup automatique des fichiers existants
- Création selon le shell sélectionné
- **Symlinks créés** :
  - `.zshrc` → `~/dotfiles/zshrc` (wrapper avec détection shell)
  - `.gitconfig` → `~/dotfiles/.gitconfig`
  - `.p10k.zsh` → `~/dotfiles/.p10k.zsh` (configuration Powerlevel10k avec Git)
  - `.ssh/id_ed25519` → `~/dotfiles/.ssh/id_ed25519` (optionnel)
  - `.ssh/config` → `~/dotfiles/.ssh/config` (optionnel)
- **Symlinks créés** :
  - `.zshrc` → `~/dotfiles/zshrc` (wrapper avec détection shell)
  - `.gitconfig` → `~/dotfiles/.gitconfig`
  - `.p10k.zsh` → `~/dotfiles/.p10k.zsh` (configuration Powerlevel10k avec Git)
  - `.ssh/id_ed25519` → `~/dotfiles/.ssh/id_ed25519` (optionnel)
  - `.ssh/config` → `~/dotfiles/.ssh/config` (optionnel)

**7. Lancement automatique du menu interactif d'installation**
- Menu `scripts/setup.sh` avec toutes les options
- État de l'installation affiché en haut du menu
- Variable `SELECTED_SHELL_FOR_SETUP` passée au menu

**📋 Ce que vous devez savoir avant de lancer la commande :**

1. ✅ **Nom Git** : Le nom qui apparaîtra dans vos commits Git
   - Exemples : `PavelDelhomme`, `Jean Dupont`, `John Doe`
   - Ce nom sera visible dans l'historique Git et sur GitHub/GitLab
   - Vous pouvez utiliser votre vrai nom, un pseudonyme, ou votre nom d'utilisateur GitHub

2. ✅ **Email Git** : L'email associé à votre compte GitHub/GitLab
   - Exemples : `github@email.com`, `votre.email@example.com`
   - ⚠️ **Important** : Cette email doit correspondre à celle de votre compte GitHub/GitLab
   - Pour GitHub, vous pouvez utiliser `username@users.noreply.github.com` pour garder votre email privé (visible dans GitHub → Settings → Emails)

3. ✅ **Configuration SSH GitHub** (⚠️ **OPTIONNEL - PEUT ÊTRE BYPASSÉE**)
   - **Option 1 (recommandé)** : Le script génère une clé SSH, ouvre GitHub dans le navigateur, vous ajoutez la clé
   - **Option 2 (BYPASS)** : ⚠️ **Vous pouvez choisir de passer cette étape** et utiliser HTTPS pour cloner
   - **Option 0** : Vérifie si SSH fonctionne déjà et propose de passer si OK
   - Si vous choisissez de bypasser SSH, vous devrez utiliser HTTPS pour cloner (avec authentification GitHub/token)

4. ⚙️ **Optionnel** : Après le clonage, vous pourrez créer le fichier `.env` pour éviter les saisies lors des prochaines installations (voir [Configuration Git via .env](#configuration-git-via-env)).

Le menu interactif affiche :
- 📊 **L'état actuel de votre installation** (ce qui est installé, ce qui manque)
- 🎯 **Toutes les options disponibles** pour installer/configurer (50-70+ options)
- ✅ **Indications claires** sur quelle option choisir pour chaque composant
- 📋 **Logs d'installation** pour tracer toutes les actions

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Après l'installation

Une fois le menu lancé, vous pouvez :
- **Option 50** : Afficher ce qui manque (état détaillé, scrollable)
- **Option 51** : Installer éléments manquants un par un (menu interactif)
- **Option 52** : Installer tout ce qui manque automatiquement
- **Option 53** : Afficher logs d'installation (voir ce qui a été fait, quand, pourquoi)
- Choisir les options que vous voulez installer (1-27)
- Désinstaller individuellement (options 60-70)
- Utiliser l'option **23** pour valider complètement votre setup (validation exhaustive 117+ vérifications)
- Utiliser l'option **28** pour restaurer depuis Git (annuler modifications locales)
- Utiliser l'option **0** pour quitter (vous pouvez relancer `cd ~/dotfiles && bash scripts/setup.sh` plus tard)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Commandes utiles après installation

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Relancer le menu interactif :

```bash
bash scripts/setup.sh
```

Alternative avec Makefile :

```bash
make setup
```

Valider le setup complet :

```bash
make validate
```

Voir toutes les commandes disponibles :

```bash
make help
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Installation manuelle (alternative)

Installer git :

```bash
sudo pacman -S git
```

Cloner ce repo :

```bash
git clone git@github.com:PavelDelhomme/dotfiles.git ~/dotfiles
```

Aller dans le dossier dotfiles et lancer le setup :

```bash
cd ~/dotfiles
```

Lancer le setup :

```bash
bash scripts/setup.sh
```

Le script `scripts/setup.sh` propose un menu interactif avec toutes les options d'installation.

---

<!-- =============================================================================
     RÉINSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 🔄 Réinstallation

Différentes méthodes pour réinstaller les dotfiles selon votre situation.

### Réinstallation complète (tout réinstaller)

**Si vous voulez tout désinstaller puis tout réinstaller depuis zéro :**

```bash
bash ~/dotfiles/scripts/uninstall/reset_all.sh
```

Cette commande va :
1. Désinstaller tous les composants (Git config, paquets, applications, etc.)
2. Supprimer le dossier dotfiles (si confirmé)
3. Proposer de réinstaller automatiquement via bootstrap.sh

**Ou manuellement :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le rollback complet (option 98 du menu) :

```bash
bash scripts/setup.sh
# Choisir option 98
```

Puis réinstaller :

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
```

### Réinstallation partielle (éléments spécifiques)

**Si vous voulez réinstaller seulement certains éléments :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le menu interactif :

```bash
bash scripts/setup.sh
```

Puis choisir les options correspondantes :
- **Option 1** : Réinstaller configuration Git
- **Option 3** : Réinstaller paquets de base
- **Option 8** : Réinstaller Cursor
- **Option 15** : Réinstaller Docker
- **Option 17** : Réinstaller Brave Browser
- **Option 19** : Réinstaller Go
- **Option 24** : Recréer les symlinks

**Ou directement les scripts d'installation :**

```bash
# Réinstaller Cursor
bash scripts/install/apps/install_cursor.sh

# Réinstaller Docker
bash scripts/install/dev/install_docker.sh

# Réinstaller Brave
bash scripts/install/apps/install_brave.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Réinstallation automatique (détection et installation)

**Si vous voulez réinstaller automatiquement tout ce qui manque :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Lancer le menu interactif :

```bash
bash scripts/setup.sh
```

Choisir **Option 52** : Installer tout ce qui manque (automatique)

**Ou installer éléments manquants un par un (Option 51)** pour un contrôle plus précis.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Réinstallation après bootstrap (déjà installé)

**Si vous avez déjà exécuté bootstrap.sh mais que le projet n'est pas complet :**

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Mettre à jour le repository :

```bash
git pull
```

Relancer le menu interactif :

```bash
bash scripts/setup.sh
```

Utiliser :
- **Option 50** : Voir ce qui manque
- **Option 51** : Installer éléments manquants un par un
- **Option 52** : Installer tout ce qui manque automatiquement
- **Option 23** : Valider complètement le setup (détecte les problèmes)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Réinstallation d'un composant spécifique

**Désinstaller puis réinstaller un composant :**

Exemple pour Docker :

Désinstaller Docker :

```bash
bash ~/dotfiles/scripts/uninstall/uninstall_docker.sh
```

Réinstaller Docker :

```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh
```

**Ou via le menu (Options 60-70 pour désinstaller, puis 1-27 pour installer).**

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Réinitialisation complète (cas extrême)

**Si vous avez des problèmes graves et voulez repartir de zéro :**

```bash
bash ~/dotfiles/scripts/uninstall/reset_all.sh
```

Cette commande va :
1. Tout désinstaller
2. Supprimer le dossier dotfiles
3. Nettoyer la configuration Git
4. Supprimer les clés SSH
5. Arrêter les services systemd
6. Supprimer les symlinks
7. Nettoyer `.zshrc` (si confirmé)

Puis proposer de réinstaller automatiquement.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Vérifier l'état après réinstallation

Après une réinstallation, valider le setup :

```bash
bash ~/dotfiles/scripts/test/validate_setup.sh
```

Ou via le menu (Option 23) pour un rapport détaillé.

---

<!-- =============================================================================
     STRUCTURE DU REPOSITORY
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🔐 Configuration GitHub SSH

### ⚠️ IMPORTANT : Cette étape est optionnelle !

Lors de l'installation via `bootstrap.sh`, vous pouvez **choisir de bypasser complètement la configuration SSH**.

**Menu proposé par bootstrap.sh :**
```
Souhaitez-vous configurer SSH pour GitHub ?
Cela permet de cloner/pusher sans saisir vos identifiants.

  1. Oui, configurer SSH (recommandé)
  2. Non, passer cette étape (vous pourrez cloner via HTTPS)  ⚠️ BYPASS
  0. Vérifier si SSH est déjà configuré et fonctionne
```

### Option 1 : Configuration SSH (recommandé)

Le script génère automatiquement une clé SSH ED25519 et :
1. Copie la clé publique dans le presse-papier
2. Attend que vous l'ajoutiez sur GitHub
3. Teste la connexion

Clé stockée dans : `~/.ssh/id_ed25519`

**Avantages :**
- Clonage/push sans saisir identifiants
- Plus sécurisé
- Plus rapide pour les opérations Git

### Option 2 : Bypasser la configuration SSH ⚠️

Si vous choisissez cette option :
- ✅ Le script passe directement au clonage
- ✅ Vous utiliserez HTTPS pour cloner (avec authentification GitHub)
- ✅ Utile si vous voulez installer rapidement
- ✅ Vous pourrez configurer SSH plus tard si nécessaire

**Note :** Pour cloner via HTTPS, GitHub peut vous demander un Personal Access Token au lieu d'un mot de passe.

### Option 0 : Vérification automatique

Le script vérifie automatiquement :
- Si une clé SSH existe déjà
- Si la connexion GitHub SSH fonctionne
- Si tout fonctionne : propose automatiquement de passer cette étape

### Quand bypasser la configuration SSH ?

Bypasser la configuration SSH est recommandé si :
- ✅ Vous avez déjà SSH configuré et fonctionnel
- ✅ Vous préférez utiliser HTTPS pour Git
- ✅ Vous voulez installer rapidement sans configuration supplémentaire
- ✅ Vous configurez SSH manuellement plus tard

**Après avoir bypassé :**
- Vous pouvez toujours configurer SSH manuellement plus tard avec :
  ```bash
  ssh-keygen -t ed25519 -C "votre.email@example.com"
  # Ajouter la clé sur GitHub : https://github.com/settings/keys
  ```

---

<!-- =============================================================================
     DOCKER
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🔄 Workflow complet (nouvelle machine)

### Méthode automatique (recommandée)

**Une seule commande** pour tout faire :

```bash
curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
```

Cette commande fait automatiquement :
1. ✅ Installation Git (si nécessaire)
2. ✅ Configuration Git (nom, email, credential helper)
3. ✅ Génération clé SSH ED25519 (si absente)
4. ✅ Test connexion GitHub SSH (`ssh -T git@github.com`)
5. ✅ Clone repository dotfiles (ou `git pull` si existe déjà)
6. ✅ Choix du shell (Zsh/Fish/Les deux)
7. ✅ Création symlinks (optionnel)
8. ✅ Lancement menu interactif `scripts/setup.sh`

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Dans le menu scripts/setup.sh

1. **Voir ce qui manque** : Option 50
2. **Installer individuellement** : Option 51 (un par un) ou Option 52 (tout automatique)
3. **Suivre les logs** : Option 53 pour voir ce qui est fait
4. **Valider installation** : Option 23 (validation exhaustive)
5. **Configurer auto-sync** : Option 12 (synchronisation automatique Git)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Après installation

- **Redémarrer** pour appliquer toutes les configurations
- **Vérifications** : `flutter doctor`, `docker login`, `nvidia-smi`
- **Configuration apps** : Cursor login, Proton Pass
- **Consulter logs** : Option 53 ou `less ~/dotfiles/logs/install.log`

---

<!-- =============================================================================
     ROLLBACK / DÉSINSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🔄 Rollback / Désinstallation

### Rollback complet (tout désinstaller)

Pour désinstaller **TOUT** ce qui a été installé et configuré :

**Via le menu setup.sh :**

Lancer le menu :

```bash
bash ~/dotfiles/scripts/setup.sh
```

Choisir option 99.

**Ou directement :**

```bash
bash ~/dotfiles/scripts/uninstall/rollback_all.sh
```

Le script va :
- ✅ Arrêter et supprimer les services systemd (auto-sync)
- ✅ Désinstaller toutes les applications (Docker, Cursor, Brave, Go, yay, etc.)
- ✅ Supprimer la configuration Git
- ✅ Supprimer les clés SSH (avec confirmation)
- ✅ Nettoyer la configuration ZSH
- ✅ Supprimer le dossier dotfiles (avec confirmation)
- ✅ Nettoyer les logs et fichiers temporaires
- ✅ Option rollback Git vers version précédente

**⚠️ Double confirmation requise** : Taper "OUI" en majuscules pour confirmer.

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Rollback Git uniquement

Pour revenir à une version précédente des dotfiles (sans désinstaller les applications) :

```bash
bash ~/dotfiles/scripts/uninstall/rollback_git.sh
```

Options disponibles :
- Revenir au commit précédent (HEAD~1)
- Revenir à un commit spécifique (par hash)
- Revenir à origin/main (dernière version distante)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Rollback Git manuel

Aller dans le dossier dotfiles :

```bash
cd ~/dotfiles
```

Voir les commits :

```bash
git log --oneline -10
```

Revenir à un commit :

```bash
git reset --hard <commit_hash>
```

Ou revenir à la version distante :

```bash
git reset --hard origin/main
```

---

<!-- =============================================================================
     GESTION DES VM (TESTS EN ENVIRONNEMENT ISOLÉ)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🖥️ Installation complète du système

Le script `scripts/setup.sh` (menu interactif) permet d'installer et configurer automatiquement :

### Gestionnaires de paquets
- ✅ yay (AUR helper)
- ✅ snap
- ✅ flatpak + flathub

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Applications
- ✅ Brave Browser
- ✅ Cursor IDE (AppImage + .desktop)
- ✅ Discord
- ✅ KeePassXC
- ✅ Docker & Docker Compose (optimisé BuildKit)
- ✅ Proton Mail & Proton Pass
- ✅ PortProton (jeux Windows)
- ✅ Session Desktop

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Environnement de développement
- ✅ Flutter SDK
- ✅ Android Studio & SDK
- ✅ Node.js & npm
- ✅ Git & GitHub SSH
- ✅ Outils de build (make, cmake, gcc)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Matériel
- ✅ Pilotes NVIDIA RTX 3060
- ✅ Configuration Xorg pour GPU principal
- ✅ nvidia-prime pour gestion hybride

---

<!-- =============================================================================
     FONCTIONNALITÉS INTELLIGENTES
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📝 Fonctionnalités intelligentes

### Vérifications avant installation
Le script vérifie **toujours** si un paquet est déjà installé avant de l'installer :
- Évite les installations redondantes
- Messages clairs (installé/ignoré)
- Gère les conflits automatiquement

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Backup automatique
Lors du setup, les fichiers de config existants sont sauvegardés dans :
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Mise à jour de Cursor
Un script dédié est créé :
```bash
update-cursor.sh
```

---

<!-- =============================================================================
     USAGE QUOTIDIEN
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🔄 Auto-Synchronisation Git

Système de synchronisation automatique des dotfiles toutes les heures via systemd timer.

### Installation

Via le menu scripts/setup.sh (option 12) ou directement :
```bash
bash ~/dotfiles/scripts/sync/install_auto_sync.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Fonctionnement

- **Timer systemd** : Exécution toutes les heures
- **Pull automatique** : Récupère les modifications distantes
- **Push automatique** : Envoie les modifications locales (si changements)
- **Logs** : Disponibles dans `~/dotfiles/logs/auto_sync.log`

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Commandes utiles

```bash
# Vérifier le statut
systemctl --user status dotfiles-sync.timer

# Voir tous les timers
systemctl --user list-timers

# Arrêter/Démarrer le timer
systemctl --user stop dotfiles-sync.timer
systemctl --user start dotfiles-sync.timer

# Voir les logs
journalctl --user -u dotfiles-sync.service

# Tester manuellement
bash ~/dotfiles/scripts/sync/git_auto_sync.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Configuration

Le timer est configuré pour :
- Démarrer 5 minutes après le boot
- S'exécuter toutes les heures
- Précision de 1 minute

---

<!-- =============================================================================
     BRAVE BROWSER
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🌐 Brave Browser

Installation optionnelle du navigateur Brave.

### Installation

Via le menu scripts/setup.sh (option 17) ou directement :
```bash
bash ~/dotfiles/scripts/install/apps/install_brave.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Support

- **Arch Linux** : Installation via yay (brave-bin)
- **Debian/Ubuntu** : Dépôt officiel Brave
- **Fedora** : Dépôt officiel Brave
- **Autres** : Installation manuelle ou Flatpak

---

<!-- =============================================================================
     OPTIONS PRINCIPALES DU MENU (SETUP.SH)
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 📊 Options principales du menu (setup.sh)

### Installation & Détection (50-53)
- **50** : Afficher ce qui manque (état, scrollable via less)
- **51** : Installer éléments manquants (un par un, menu interactif)
- **52** : Installer tout ce qui manque (automatique, avec logs)
- **53** : Afficher logs d'installation (filtres, statistiques, scrollable)

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Désinstallation individuelle (60-70)
- **60** : Désinstaller configuration Git
- **61** : Désinstaller configuration remote Git
- **62** : Désinstaller paquets de base
- **63** : Désinstaller gestionnaires de paquets (yay, snap, flatpak)
- **64** : Désinstaller Brave Browser
- **65** : Désinstaller Cursor IDE
- **66** : Désinstaller Docker & Docker Compose
- **67** : Désinstaller Go (Golang)
- **68** : Désinstaller yay (AUR helper)
- **69** : Désinstaller auto-sync Git
- **70** : Désinstaller symlinks

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Autres options importantes
- **23** : Validation complète du setup (117+ vérifications exhaustives)
- **28** : Restaurer depuis Git (annuler modifications locales, restaurer fichiers supprimés)
- **26-27** : Migration shell (Fish ↔ Zsh), Changer shell par défaut

---

<!-- =============================================================================
     SYSTÈME DE LOGS D'INSTALLATION
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

## 📝 Système de logs d'installation

Toutes les installations et configurations sont automatiquement tracées dans `~/dotfiles/logs/install.log` :

- ✅ **Format** : `[timestamp] [action] [status] component | details`
- ✅ **Actions tracées** : install, config, uninstall, test, run
- ✅ **Statuts** : success, failed, skipped, info
- ✅ **Navigation** : Pagination via less, filtres par action/composant
- ✅ **Statistiques** : Total, réussies, échouées, ignorées

Consulter les logs via **Option 53** du menu ou directement :
```bash
less ~/dotfiles/logs/install.log
```

---

<!-- =============================================================================
     SCRIPTS MODULAIRES
     ============================================================================= -->

[🔝 Retour en haut](#dotfiles-paveldelhomme)


## 📦 Scripts Modulaires

Structure organisée des scripts dans `scripts/` :

```
scripts/
├── config/              # Configurations unitaires
│   ├── git_config.sh     # Config Git (nom, email)
│   ├── git_remote.sh     # Remote GitHub (SSH/HTTPS)
│   ├── qemu_packages.sh  # Installation paquets QEMU
│   ├── qemu_network.sh   # Configuration réseau NAT
│   └── qemu_libvirt.sh   # Configuration permissions libvirt
│
├── install/              # Scripts d'installation
│   ├── system/          # Paquets système
│   ├── apps/            # Applications utilisateur
│   │   ├── install_brave.sh         # Brave Browser
│   │   ├── install_cursor.sh         # Cursor IDE
│   │   └── install_portproton.sh     # PortProton
│   ├── dev/             # Outils de développement
│   │   ├── install_docker.sh         # Docker & Docker Compose
│   │   ├── install_docker_tools.sh   # Outils build (Arch)
│   │   └── install_go.sh             # Go (Golang)
│   └── tools/           # Outils système
│       └── install_yay.sh            # yay (AUR helper)
│
├── sync/                # Synchronisation Git
│   ├── git_auto_sync.sh         # Script de synchronisation
│   ├── install_auto_sync.sh     # Installation systemd timer
│   └── restore_from_git.sh      # Restaurer depuis Git (option 28)
│
├── test/                 # Validation & tests
│   └── validate_setup.sh         # Validation complète (117+ vérifications)
│
├── lib/                  # Bibliothèques communes
│   ├── common.sh                # Fonctions communes (logging, couleurs)
│   ├── install_logger.sh        # Système de logs d'installation
│   └── check_missing.sh         # Détection éléments manquants
│
├── uninstall/            # Désinstallation individuelle
│   ├── uninstall_git_config.sh  # Désinstaller config Git
│   ├── uninstall_brave.sh       # Désinstaller Brave
│   ├── uninstall_cursor.sh      # Désinstaller Cursor
│   ├── uninstall_docker.sh      # Désinstaller Docker
│   ├── uninstall_go.sh          # Désinstaller Go
│   ├── uninstall_yay.sh         # Désinstaller yay
│   ├── uninstall_auto_sync.sh   # Désinstaller auto-sync
│   └── uninstall_symlinks.sh    # Désinstaller symlinks
│
└── vm/                   # Gestion VM
    └── create_test_vm.sh          # Création VM de test
```

### Tableau des scripts

| Fichier | Description | Usage |
|---------|-------------|-------|
| `apps/install_brave.sh` | Installation Brave Browser | Option 17 du menu |
| `apps/install_cursor.sh` | Installation Cursor IDE | Option 8 du menu |
| `apps/install_portproton.sh` | Installation PortProton | Option 9 du menu |
| `dev/install_docker.sh` | Installation Docker complet | Option 15 du menu |
| `dev/install_docker_tools.sh` | Outils build (make, gcc, cmake) | Arch Linux uniquement |
| `dev/install_go.sh` | Installation Go (Golang) | Option 19 du menu |
| `tools/install_yay.sh` | Installation yay AUR helper | Option 18 du menu |
| `test/validate_setup.sh` | Validation complète | Option 22 du menu |

---

<!-- =============================================================================
     VALIDATION DU SETUP
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 📱 Flutter & Android

### Variables d'environnement (dans `.env`)

Définir JAVA_HOME :

```bash
export JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
```

Définir ANDROID_SDK_ROOT :

```bash
export ANDROID_SDK_ROOT='/opt/android-sdk'
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Première utilisation

Vérifier l'installation Flutter :

```bash
flutter doctor
```

Premier lancement d'Android Studio pour configurer le SDK :

```bash
android-studio
```

---

<!-- =============================================================================
     NVIDIA RTX 3060
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)


## 🎮 NVIDIA RTX 3060

### Configuration automatique
- Pilotes propriétaires installés
- Xorg configuré (PrimaryGPU)
- GRUB optimisé (nomodeset)
- nvidia-prime installé

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Vérifications

Vérifier l'état du GPU :

```bash
nvidia-smi
```

Forcer une application à utiliser NVIDIA :

```bash
prime-run <app>
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Important
1. Branchez l'écran sur la **carte NVIDIA** (pas carte mère)
2. Dans le BIOS : `Primary Display` = `PCI-E` ou `Discrete`
3. Redémarrez après installation

---

<!-- =============================================================================
     MAINTENANCE
     ============================================================================= -->

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

