# 📋 Résumé de Compatibilité Multi-Shells

## 🎯 Réponse Rapide

**Non, toutes les fonctions ZSH ne sont PAS disponibles pour Bash et Fish.**

### ✅ Ce qui fonctionne partout

1. **Variables d'environnement** (`env.sh`)
   - ✅ ZSH, Bash, Fish

2. **Aliases simples**
   - ✅ ZSH, Bash (avec limitations), Fish

3. **Scripts d'installation** (`scripts/install/`)
   - ✅ Tous (écrits en bash)

4. **Scripts de configuration** (`scripts/config/`)
   - ✅ Tous (écrits en bash)

### ⚠️ ZSH-only

**Tous les managers interactifs (*man)** sont **ZSH-only** :
- Utilisent la syntaxe ZSH (`typeset`, `declare -A`, etc.)
- Fonctions interactives ZSH
- 18 managers au total

**Fonctions ZSH avancées** ne sont pas disponibles dans Bash/Fish.

## 🔄 Comment ça fonctionne

### Wrapper `zshrc`

Le fichier `~/dotfiles/zshrc` détecte le shell et charge la config appropriée :

- **ZSH** → Charge `zsh/zshrc_custom` (tout est disponible)
- **Bash** → Charge `env.sh` et `aliases.zsh` (limité)
- **Fish** → Affiche un message (config dans `.config/fish/config.fish`)

### Fish

Fish a sa propre configuration dans `fish/` :
- Syntaxe très différente
- Pas de managers ZSH
- Version Fish des fonctions disponibles

### Bash

Bash peut utiliser :
- Variables d'environnement
- Alias simples
- Scripts bash
- **PAS** de managers interactifs

## 🐳 Tests Docker

Vous pouvez choisir le shell de test :
- `make docker-test-auto` → Demande le shell (zsh/bash/fish)
- `make docker-start` → Permet de choisir le shell interactivement

## 📝 Recommandation

**Utilisez ZSH pour toutes les fonctionnalités !**

Voir `docs/COMPATIBILITY.md` pour plus de détails.
