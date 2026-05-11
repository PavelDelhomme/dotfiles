# Docker — utilisateur, BuildKit, sandbox isolé

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte doc** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Carte code** : [`../CODEMAP.md`](../CODEMAP.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`../../STATUS.md`](../../STATUS.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md)

---

> Bac à sable Docker pour les **tests** : [`../../scripts/test/SANDBOX.md`](../../scripts/test/SANDBOX.md). Procédure pas à pas dans [`../TESTS.md`](../TESTS.md) (Blocs B, C, E).

---

## 🐳 Docker

### Installation

Installation complète via le menu scripts/setup.sh (option 15) :
- Docker Engine
- Docker Compose
- BuildKit activé par défaut
- Groupe docker configuré
- Login Docker Hub avec support 2FA

```bash
# Via le menu
bash ~/dotfiles/scripts/setup.sh
# Choisir option 15

# Ou directement
bash ~/dotfiles/scripts/install/dev/install_docker.sh
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Configuration BuildKit

BuildKit est automatiquement activé dans `~/.docker/daemon.json` :
```json
{
  "features": {
    "buildkit": true
  }
}
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Docker Desktop (optionnel)

Installation via option 16 du menu ou :
```bash
bash ~/dotfiles/scripts/install/dev/install_docker.sh --desktop-only
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Login Docker Hub

Le script propose automatiquement de se connecter à Docker Hub :
- Support 2FA (utilisez un Personal Access Token)
- Génération de token : https://hub.docker.com/settings/security

```bash
docker login
# Test avec
docker run hello-world
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Commandes utiles

```bash
docker --version              # Vérifier la version
docker ps                     # Lister les conteneurs
docker-compose up             # Lancer avec docker-compose
docker compose up             # Lancer avec docker compose (plugin)
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

### Tests dans environnement Docker isolé

**🔒 Isolation complète :** Les conteneurs de test utilisent le préfixe `dotfiles-test-*` et ne touchent **JAMAIS** vos autres conteneurs Docker existants.

**Entrer dans l'environnement de test (recommandé) :**

```bash
# Entrer dans le conteneur (construit l'image si besoin). Dotfiles montés en lecture seule.
make docker-in

# Avec un autre shell : zsh (défaut), bash, fish, sh
make docker-in SHELL=bash
make docker-in SHELL=fish

# Reconstruire l'image après modification du Dockerfile
make docker-rebuild
make docker-in
```

**Autres commandes Docker :**

```bash
# Construire l'image
make docker-build

# Lancer un conteneur interactif (zsh)
make docker-run

# Tester rapidement les dotfiles (une commande)
make docker-test

# Installation automatique complète (image Dockerfile.test)
make docker-build-test
make docker-start

# Nettoyer UNIQUEMENT les conteneurs dotfiles-test
make docker-clean
```

**Environnement de test :**
- ✅ **Arch Linux minimal** : Environnement propre et isolé
- ✅ **Installation automatique** : Configuration complète sans intervention
- ✅ **Tests intégrés** : Vérification automatique de tous les managers
- ✅ **Isolation totale** : Préfixe unique `dotfiles-test-*` pour ne pas toucher vos autres conteneurs

**Fichiers créés :**
- `Dockerfile.test` : Dockerfile pour installation automatique complète
- `test-docker.sh` : Script de test automatique
- `docker-compose.yml` : Orchestration (projet isolé avec préfixe)

**Sécurité :**
- ✅ Tous les conteneurs/images/volumes utilisent le préfixe `dotfiles-test-*`
- ✅ Nettoyage sélectif avec filtres Docker
- ✅ Vos autres conteneurs Docker ne seront **JAMAIS** touchés

**Choix du shell de test :**

Lors de `make docker-test-auto`, vous pouvez choisir le shell de test :
- **ZSH** (recommandé) : Toutes les fonctionnalités disponibles (18 managers)
- **Bash** : Test de compatibilité basique (variables d'env, alias simples)
- **Fish** : Test de compatibilité basique (variables d'env, alias)

```bash
# Tester avec ZSH (par défaut, toutes les fonctionnalités)
make docker-test-auto
# Choisir option 1 pour zsh

# Tester avec Bash (compatibilité basique)
make docker-test-auto
# Choisir option 2 pour bash

# Tester avec Fish (compatibilité basique)
make docker-test-auto
# Choisir option 3 pour fish

# Tester manuellement avec le shell de votre choix
make docker-start
# Choisir le shell (zsh/bash/fish) au démarrage
```

**Exemple d'utilisation :**
```bash
# Tester l'installation complète automatique
make docker-test-auto

# Cela va :
# 1. Demander quels managers activer
# 2. Demander quel shell utiliser (zsh/bash/fish)
# 3. Construire l'image Docker avec installation automatique
# 4. Lancer l'installation complète des dotfiles
# 5. Vérifier que tous les managers fonctionnent (ZSH seulement)
# 6. Afficher un rapport de test
```

  [🔝 Retour en haut](#dotfiles-paveldelhomme)

