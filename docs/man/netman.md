# NETMAN(1) - Gestionnaire réseau

## NOM

netman - Gestionnaire interactif complet pour la gestion réseau

## SYNOPSIS

**netman** [*command*]

## DESCRIPTION

NETMAN est un gestionnaire interactif complet pour la gestion réseau. Il permet de
gérer les ports, connexions, interfaces réseau, DNS, et d'obtenir des informations
détaillées sur le réseau.

Le gestionnaire offre les fonctionnalités suivantes :
- Gestion des ports (liste, kill, monitoring)
- Gestion des connexions réseau
- Informations sur les interfaces réseau
- Configuration DNS
- Tests de connectivité
- Informations réseau détaillées

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **ports** - Gérer les ports
- **connections** - Gérer les connexions
- **interfaces** - Gérer les interfaces réseau
- **dns** - Configuration DNS
- **info** - Informations réseau

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ netman
```

Gérer les ports :
```
$ netman ports
```

Voir les connexions :
```
$ netman connections
```

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **kill_port**(1) - Tuer un processus par port
- **port_process**(1) - Afficher les processus par port

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

