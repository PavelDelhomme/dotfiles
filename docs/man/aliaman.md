# ALIAMAN(1) - Gestionnaire d'alias ZSH

## NOM

aliaman - Gestionnaire interactif complet pour gérer les alias ZSH

## SYNOPSIS

**aliaman** [*command*]

## DESCRIPTION

ALIAMAN est un gestionnaire interactif complet pour gérer les alias ZSH. Il permet
d'ajouter, modifier, supprimer, rechercher et organiser les alias avec une interface
utilisateur conviviale.

Le gestionnaire offre les fonctionnalités suivantes :
- Ajout d'alias avec documentation
- Modification d'alias existants
- Suppression d'alias
- Recherche dans les alias
- Liste paginée des alias
- Sauvegarde automatique
- Export/Import d'alias

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **add** - Ajouter un nouvel alias
- **search** - Rechercher un alias
- **list** - Lister tous les alias
- **help** - Afficher l'aide

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ aliaman
```

Ajouter un alias directement :
```
$ aliaman add
```

Rechercher un alias :
```
$ aliaman search git
```

## FICHIERS

- `~/dotfiles/zsh/aliases.zsh` - Fichier de stockage des alias
- `~/dotfiles/zsh/backups/` - Répertoire des sauvegardes

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **add_alias**(1) - Ajouter un alias en ligne de commande
- **list_alias**(1) - Lister les alias

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

