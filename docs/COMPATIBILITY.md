> **Réf. doc** : [`DOCUMENTATION_REFERENCE.md`](DOCUMENTATION_REFERENCE.md) · [`STATUS.md`](STATUS.md) · [`TESTS.md`](TESTS.md) · [`ERRORS.md`](ERRORS.md)

# 🔄 Compatibilité Multi-Shells

> Mise à jour 2026-05 : ce document est aligné avec la trajectoire plateforme unifiée (`docs/UNIFIED_PLATFORM_ROADMAP.md`) et la convergence TUI (`docs/DOTCLI_MENU_CONTRACT.md`).

## 📋 Vue d'ensemble

Les dotfiles supportent **ZSH**, **Bash** et **Fish**, mais avec des niveaux de compatibilité différents.

## ✅ Ce qui est compatible

### 1. **Variables d'environnement** (`env.sh`)
- ✅ **ZSH** : Chargé via `zshrc_custom`
- ✅ **Bash** : Chargé via wrapper `zshrc` (compatible)
- ✅ **Fish** : Version Fish (`env.fish`) disponible

### 2. **Aliases**
- ✅ **ZSH** : Chargé via `aliases.zsh`
- ✅ **Bash** : Chargé via wrapper `zshrc` (alias simples compatibles)
- ✅ **Fish** : Version Fish (`aliases.fish`) disponible

### 3. **Scripts d'installation**
- ✅ **Tous les shells** : Scripts dans `scripts/install/` sont en bash, donc compatibles partout

### 4. **Scripts de configuration**
- ✅ **Tous les shells** : Scripts dans `scripts/config/` sont en bash

## ⚠️ Ce qui est ZSH-only

### 1. **Managers interactifs** (*man)
Tous les managers (`installman`, `configman`, `pathman`, etc.) sont **ZSH-only** car ils utilisent :
- Syntaxe ZSH spécifique (`typeset`, `declare -A`, etc.)
- Fonctions ZSH interactives
- Caractéristiques avancées de ZSH

**Managers ZSH-only (18 managers) :**
- `installman` - Gestionnaire d'installations
- `configman` - Gestionnaire de configurations
- `pathman` - Gestionnaire PATH
- `netman` - Gestionnaire réseau
- `gitman` - Gestionnaire Git
- `cyberman` - Gestionnaire cybersécurité
- `devman` - Gestionnaire développement
- `miscman` - Gestionnaire divers
- `aliaman` - Gestionnaire alias
- `searchman` - Gestionnaire recherche
- `helpman` - Gestionnaire aide
- `fileman` - Gestionnaire fichiers
- `virtman` - Gestionnaire virtualisation
- `sshman` - Gestionnaire SSH
- `testman` - Gestionnaire tests
- `testzshman` - Gestionnaire tests ZSH
- `moduleman` - Gestionnaire modules
- `manman` - Manager of Managers

### 2. **Fonctions individuelles**
La plupart des fonctions dans `zsh/functions/` utilisent des syntaxes ZSH spécifiques.

## 🐟 Support Fish

Fish a ses propres implémentations dans `fish/` :
- `fish/config_custom.fish` - Configuration principale
- `fish/aliases.fish` - Aliases Fish
- `fish/env.fish` - Variables d'environnement
- `fish/functions/` - Fonctions Fish (quelques-unes)

**Note :** Fish a une syntaxe très différente, donc les fonctions ne sont pas directement compatibles.

## 🐚 Support Bash

Bash peut utiliser :
- Variables d'environnement via `env.sh`
- Alias simples via `aliases.zsh` (avec limitations)
- Scripts d'installation et configuration (tous en bash)

**Limitations Bash :**
- Pas de managers interactifs
- Alias complexes peuvent ne pas fonctionner
- Pas de fonctions ZSH avancées

## 🔄 Wrapper `zshrc`

Le fichier `~/dotfiles/zshrc` est un wrapper intelligent qui :

1. **Détecte le shell actif** (ZSH, Fish, Bash)
2. **Source la configuration appropriée** :
   - ZSH → `zsh/zshrc_custom` (tout est chargé)
   - Bash → `env.sh` et `aliases.zsh` (limité)
   - Fish → Affiche un message (config doit être dans `.config/fish/config.fish`)

## 📝 Recommandation

**Pour une compatibilité maximale :**
- ✅ Utilisez **ZSH** : Toutes les fonctionnalités sont disponibles
- ⚠️ Utilisez **Fish** : Fonctionnalités limitées, syntaxe différente
- ⚠️ Utilisez **Bash** : Seulement variables d'env et alias simples

## 🐳 Tests Docker Multi-Shells

L'environnement Docker peut être configuré pour tester avec différents shells :
- **ZSH** (par défaut, toutes les fonctionnalités)
- **Bash** (test de compatibilité basique)
- **Fish** (test de compatibilité basique)

Voir la section Docker dans le README pour plus de détails.