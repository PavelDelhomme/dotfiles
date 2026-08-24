> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# NETMAN(1) - Gestionnaire réseau

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

## NOM

netman - Gestionnaire interactif complet pour la gestion réseau

## SYNOPSIS

**netman** [*command* …]

## DESCRIPTION

NETMAN gère le réseau local : ports, DNS (**dig**), lookup, diagnostic, firewall, etc.

Sans argument : **aide stdout** (liste des sous-commandes).  
`netman <cmd>` sans les args requis : **aide de la sous-commande**.  
Menu TUI : `netman menu` ou `netman --interactive`.

## OPTIONS / SOUS-COMMANDES

- **dig** — requêtes DNS (`netman dig`, `netman dig example.com`, `MX`, `@1.1.1.1`, `-x`)
- **lookup** *cible* — dig + reverse + whois
- **dns** / **dns-bench** — config locale / benchmark résolveurs
- **ports** / **connections** / **interfaces** / **ip** / **routing** / **routeman**
- **scan** / **kill** / **stats** / **diagnose** / **firewall**
- **trace** / **mtr** / **whois** / **connectivity** / **speed** / **monitor** / **analyze** / **export**
- **tor** / **i2p** — délègue à anonyman
- **help** [*sous-cmd*] — aide générale ou ciblée ; `help --interactive` (TTY)
- **menu** — menu interactif

## EXEMPLES

```
$ netman
$ netman dig
$ netman dig example.com
$ netman dig MX example.com
$ netman dig @1.1.1.1 google.com
$ netman help dig
$ helpman netman dig
$ netman lookup example.com
$ netman menu
```

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **kill_port**(1) - Tuer un processus par port
- **port_process**(1) - Afficher les processus par port

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

