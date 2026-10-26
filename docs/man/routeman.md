> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# ROUTEMAN(1) - Gestionnaire de Routes IP

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

## NOM

routeman - Gestionnaire interactif de routes IP (visualisation, ajout, suppression, modification)

## SYNOPSIS

**routeman** [*command*]

## DESCRIPTION

ROUTEMAN gère les routes IP (visualiser, ajouter, supprimer, remplacer).

Sans argument : **aide stdout**.  
Menu TUI : `routeman menu` ou `routeman --interactive`.  
Aussi via netman : `netman routeman show|add|del|…`.

## OPTIONS

**command** peut être :
- **show** | **list** — Affiche les routes IPv4/IPv6
- **add** *reseau/cidr* [gateway] [interface] [metric] — Ajoute une route
- **del** | **delete** *reseau/cidr|default* — Supprime une route
- **replace** | **mod** *reseau/cidr* [gateway] [interface] [metric] — Modifie une route
- **menu** | **--interactive** — Menu TUI (TTY)
- **help** | **-h** — Aide

## EXEMPLES

```
$ routeman
$ routeman menu
$ routeman show
$ netman routeman show
```

Menu interactif :
```
$ routeman menu
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

