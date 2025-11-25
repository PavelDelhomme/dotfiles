# CYBERMAN(1) - Gestionnaire de cybersécurité

## NOM

cyberman - Gestionnaire interactif complet pour les outils de cybersécurité

## SYNOPSIS

**cyberman** [*category*]

## DESCRIPTION

CYBERMAN est un gestionnaire interactif complet pour les outils de cybersécurité.
Il organise les outils en catégories : reconnaissance, scanning, vulnérabilités,
attaques, analyse et privacy. Le gestionnaire installe automatiquement les outils
manquants si nécessaire.

Le gestionnaire offre les fonctionnalités suivantes :
- **Reconnaissance** : WHOIS, DNS lookup, énumération, sous-domaines
- **Scanning** : Scan de ports, énumération de répertoires, utilisateurs
- **Vulnérabilités** : Scan de vulnérabilités, SSL, Heartbleed
- **Attaques** : ARP spoofing, brute force SSH, password cracking
- **Analyse** : Sniffing de trafic, scan WiFi
- **Privacy** : Tor, proxy, anonymisation

## OPTIONS

Sans argument, lance le menu interactif principal.

**category** peut être :
- **recon** - Menu de reconnaissance
- **scan** - Menu de scanning
- **vuln** - Menu de vulnérabilités
- **attack** - Menu d'attaques
- **analysis** - Menu d'analyse
- **privacy** - Menu de privacy

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ cyberman
```

Accéder au menu de reconnaissance :
```
$ cyberman recon
```

Accéder au menu de scanning :
```
$ cyberman scan
```

## PRÉREQUIS

Certains outils nécessitent des paquets supplémentaires qui seront installés
automatiquement si nécessaire :
- nmap, nikto, dnsenum, gobuster, dirb
- sqlmap, metasploit-framework
- tcpdump, wireshark-cli
- aircrack-ng, hashcat, john
- tor, proxychains

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **domain_whois**(1) - Recherche WHOIS
- **port_scan**(1) - Scan de ports

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

## AVERTISSEMENT

Les outils de cybersécurité doivent être utilisés uniquement sur des systèmes
dont vous avez l'autorisation de tester. L'utilisation non autorisée est illégale.

