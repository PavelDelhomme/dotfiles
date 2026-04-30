# ROUTEMAN(1) - Gestionnaire de Routes IP

## NOM

routeman - Gestionnaire interactif de routes IP (visualisation, ajout, suppression, modification)

## SYNOPSIS

**routeman** [*command*]

## DESCRIPTION

ROUTEMAN permet de gerer les routes IP du systeme depuis une interface interactive
ou via des sous-commandes CLI.

Fonctions principales:
- visualiser les routes IPv4/IPv6
- ajouter une route
- supprimer une route
- modifier (replace) une route existante

## OPTIONS

**command** peut etre :
- **show** | **list** - Affiche les routes
- **add** *reseau/cidr* [gateway] [interface] [metric] - Ajoute une route
- **del** | **delete** *reseau/cidr|default* - Supprime une route
- **replace** | **mod** *reseau/cidr* [gateway] [interface] [metric] - Modifie une route
- **help** - Affiche l'aide

## EXEMPLES

Lancer le menu interactif :
```
$ routeman
```

Afficher les routes :
```
$ routeman show
```

Ajouter une route :
```
$ routeman add 10.10.0.0/24 192.168.1.1 eth0 100
```

Modifier une route :
```
$ routeman replace default 192.168.1.254 eth0 50
```

Supprimer une route :
```
$ routeman del 10.10.0.0/24
```

## VOIR AUSSI

- **netman**(1) - Gestionnaire reseau global
- **ip**(8) - Outil de configuration reseau Linux
- **route**(8) - Gestion des routes (legacy)

## AUTEUR

Paul Delhomme - Systeme de dotfiles personnalise

