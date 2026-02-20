# PATHMAN(1) - Gestionnaire du PATH

## NOM

pathman - Gestionnaire interactif complet pour gérer le PATH système

## SYNOPSIS

**pathman** [*command*] [*args*]

## DESCRIPTION

PATHMAN est un gestionnaire interactif complet pour gérer le PATH système. Il permet
d'ajouter, retirer, nettoyer et sauvegarder les répertoires du PATH avec une interface
utilisateur conviviale.

Le gestionnaire offre les fonctionnalités suivantes :
- Visualisation du PATH complet
- Ajout de répertoires au PATH
- Retrait de répertoires du PATH
- Nettoyage des doublons
- Suppression des chemins invalides
- Sauvegarde et restauration du PATH
- Logs des modifications
- Statistiques d'utilisation

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **add** *directory* - Ajouter un répertoire au PATH
- **remove** *directory* - Retirer un répertoire du PATH
- **show** - Afficher le PATH complet
- **clean** - Nettoyer les doublons
- **invalid** - Supprimer les chemins invalides
- **save** - Sauvegarder le PATH actuel
- **restore** - Restaurer le PATH sauvegardé
- **logs** - Afficher les logs
- **stats** - Afficher les statistiques
- **export** - Exporter le PATH en texte
- **help** - Afficher l'aide

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ pathman
```

Ajouter un répertoire au PATH :
```
$ pathman add /usr/local/bin
```

Nettoyer le PATH :
```
$ pathman clean
```

Afficher le PATH :
```
$ pathman show
```

## FICHIERS

- `~/dotfiles/zsh/PATH_SAVE` - Fichier de sauvegarde du PATH
- `~/.config/dotfiles/pathman/path_log.txt` - Logs des modifications (répertoire inscriptible, compatible Docker/RO)

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **add_to_path**(1) - Ajouter un répertoire au PATH (fonction globale)

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

