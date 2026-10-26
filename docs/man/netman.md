> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# NETMAN(1) - Gestionnaire réseau

> Mise à jour 2026-10 : lookup URL/PTR, aide par sous-commande, pont routeman,
> soft recon (`probe` / `neigh` / `lan`).

## NOM

netman - Couteau suisse réseau (local, DNS, soft recon)

## SYNOPSIS

**netman** [*command* …]

## DESCRIPTION

NETMAN centralise l’analyse et le diagnostic réseau : DNS (dig/lookup),
chemin (trace/mtr), ports, firewall, découverte LAN soft, et pont vers
**routeman** / **anonyman**.

Sans argument : **aide stdout** (carte des sous-commandes).  
`netman help <cmd>` : aide ciblée.  
`netman <cmd>` sans les args requis : **aide de la sous-commande**.  
Menu TUI : `netman menu` ou `netman --interactive`.

Les cibles acceptent aussi les **URL collées** (`https://host/path` → `host`)
pour dig, lookup, whois, trace, mtr, probe, scan.

## SOUS-COMMANDES

### DNS / identité

| Commande | Rôle |
|----------|------|
| **dig** | Requêtes dig (A/AAAA/MX/NS/TXT, `@résolveur`, `-x`, `+trace`, `--raw`) |
| **lookup** | Fiche dig-like + **PTR par IP** + whois (URL OK) |
| **probe** | Soft recon one-shot (DNS+ping+trace+ports courants) |
| **dns** / **dns-bench** | Config locale / latence multi-résolveurs |
| **whois** | Fiche whois |

### Hôte / chemin

| Commande | Rôle |
|----------|------|
| **ip** / **interfaces** / **connections** / **ports** / **stats** | État local |
| **routing** | Table de routage (lecture) |
| **routeman** [*args*] | Pont vers routeman (`show`/`add`/`del`/menu) |
| **trace** / **mtr** / **connectivity** / **speed** | Chemin & perf |
| **scan** / **kill** | Port TCP rapide / kill process |

### Soft recon / LAN

| Commande | Rôle |
|----------|------|
| **neigh** / **arp** | Table voisins L2 (ARP/NDP) |
| **lan** | Découverte locale (neigh + arp-scan/nmap `-sn` si dispo) |
| **diagnose** / **diagnose-deep** / **diag-report** / **firewall** | Santé |
| **monitor** / **analyze** / **export** | Trafic / snapshot |

### Anonymat

| Commande | Rôle |
|----------|------|
| **tor** / **i2p** | Délègue à **anonyman** |

## EXEMPLES

```
$ netman
$ netman help lookup
$ netman lookup https://example.com/path
$ netman lookup 1.1.1.1
$ netman dig example.com
$ netman dig -x 8.8.8.8
$ netman probe example.com
$ netman neigh
$ netman lan
$ netman routeman show
$ netman menu
```

## VOIR AUSSI

- **routeman**(1) — édition des routes IP
- **anonyman**(1) — Tor / I2P
- **helpman**(1) — `helpman netman dig`
- [`docs/guides`](../guides/) · [`docs/ERRORS.md`](../ERRORS.md)

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé
