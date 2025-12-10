# Commandes Standalone

Ce répertoire contient les commandes et fonctions qui ne sont **pas** des managers (*man).

## Structure

Les commandes standalone sont des fonctions utilitaires simples qui peuvent être utilisées directement en ligne de commande, sans interface interactive.

## Commandes disponibles

### Réseau
- **ipinfo** - Affiche les informations IP (privée, publique, DNS, gateway, etc.)
- **whatismyip** - Affiche l'adresse IP publique
- **network_scanner** - Scanner réseau en temps réel

## Ajout d'une nouvelle commande

Pour ajouter une nouvelle commande standalone :

1. Créez le fichier dans le répertoire approprié :
   - `zsh/functions/commands/ma_commande.zsh` (pour ZSH)
   - `bash/functions/commands/ma_commande.sh` (pour Bash)
   - `fish/functions/commands/ma_commande.fish` (pour Fish)

2. Le fichier sera automatiquement chargé par `load_commands.sh` / `load_commands.fish`

## Différence avec les Managers

- **Managers (*man)** : Interfaces interactives avec menus, gestion de configuration, etc.
  - Exemples : `installman`, `configman`, `virtman`, `cyberman`
  - Structure : `core/`, `modules/`, `utils/`, etc.

- **Commandes Standalone** : Fonctions simples utilisables directement
  - Exemples : `ipinfo`, `whatismyip`, `network_scanner`
  - Structure : Fichier unique ou simple

## Chargement automatique

Les commandes sont chargées automatiquement via :
- `zsh/zshrc_custom` → `load_commands.sh`
- `bash/bashrc_custom` → `load_commands.sh`
- `fish/config_custom.fish` → `load_commands.fish`

