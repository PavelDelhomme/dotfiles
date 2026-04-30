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
- Table de routage
- Gestion avancée des routes via routeman
- Tests de connectivité (ping/traceroute)
- Diagnostic réseau complet (interface, gateway, DNS, HTTP)
- Benchmark DNS multi-resolveurs
- Statut firewall (ufw/nftables/iptables)
- Lookup IP/domaine (DNS + whois)
- Test de vitesse réseau
- Monitoring de bande passante en temps réel
- Analyse du trafic réseau
- Export de configuration complète
- Informations réseau détaillées

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **ports** - Gérer les ports
- **connections** - Gérer les connexions
- **interfaces** - Gérer les interfaces réseau
- **dns** - Configuration DNS
- **routing** - Table de routage
- **routeman** - Ouvre le gestionnaire dédié des routes IP
- **diagnose** - Diagnostic réseau complet
- **diagnose-deep** - Diagnostic perf approfondi (RX/TX, drops, processus)
- **dns-bench** - Benchmark DNS
- **firewall** - Statut firewall
- **lookup** *cible* - Lookup IP/domaine
- **info** - Informations réseau
- **test** - Test de connectivité (ping/traceroute)
- **speed** - Test de vitesse réseau
- **monitor** - Monitoring bande passante temps réel
- **analyze** - Analyse du trafic réseau
- **export** - Export de configuration réseau

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

Lancer le gestionnaire des routes :
```
$ netman routeman
```

Diagnostic réseau complet :
```
$ netman diagnose
```

Diagnostic réseau approfondi :
```
$ netman diagnose-deep
```

Benchmark DNS :
```
$ netman dns-bench
```

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **kill_port**(1) - Tuer un processus par port
- **port_process**(1) - Afficher les processus par port

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

