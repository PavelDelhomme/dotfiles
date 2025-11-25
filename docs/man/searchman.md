# SEARCHMAN(1) - Gestionnaire de recherche

## NOM

searchman - Gestionnaire interactif complet pour la recherche et l'exploration

## SYNOPSIS

**searchman** [*command*]

## DESCRIPTION

SEARCHMAN est un gestionnaire interactif complet pour la recherche et l'exploration.
Il permet de rechercher dans l'historique, les fichiers, le code source, et d'explorer
le système de fichiers avec des filtres avancés.

Le gestionnaire offre les fonctionnalités suivantes :
- Recherche avancée dans l'historique ZSH
- Recherche dans les fichiers
- Recherche dans le code source
- Exploration du système de fichiers
- Filtres avancés et options de recherche

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **history** [*pattern*] - Rechercher dans l'historique
- **files** [*pattern*] - Rechercher dans les fichiers
- **code** [*pattern*] - Rechercher dans le code source
- **explore** [*directory*] - Explorer un répertoire

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ searchman
```

Rechercher dans l'historique :
```
$ searchman history git
```

Rechercher des fichiers Python :
```
$ searchman files "*.py"
```

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **grep**(1) - Recherche dans les fichiers

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

