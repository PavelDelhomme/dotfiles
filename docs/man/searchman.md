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
- **ping** — test non interactif (CI)
- **help** — aide des sous-commandes CLI
- **cmd** | **in-path** | **which-path** *nom* — la commande est-elle dans le PATH ? (`command -v`, entrées PATH, `which -a`)
- **locate** | **outside** | **find-bin** *nom* — `whereis` puis recherche d’exécutables du même nom sous des répertoires usuels (`SEARCHMAN_FIND_ROOTS` pour en ajouter)
- **resolve** | **where** *nom* — **cmd** puis **locate** (ex. vérifier *flutter*)
- **history**, **files**, **process**, **logs**, **functions**, **stats** — modes interactifs (menus)

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

