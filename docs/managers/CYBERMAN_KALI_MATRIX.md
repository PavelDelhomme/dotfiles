# Cyberman — matrice outils type Kali (roadmap)

> Source de catégories : [Kali Tools](https://www.kali.org/tools/) (Reconnaissance → Forensics → Services).

Ce document **ne remplace pas** Kali Linux. Il cadre comment **cyberman** / **cyberlearn** / **installman** / **WhereGoesMyDatas** s’articulent pour une gestion **défensive** et d’apprentissage sur **ton** labo / réseau.

## Principes

1. **Défense & labo uniquement** — pas de procédures d’attaque sur tiers.
2. Installation via **installman** / paquets distro / Flatpak quand possible.
3. Inventaire + help unifiés : `cyberman help`, `helpman cyberman`, `make help`.
4. Monitoring réseau profond = **WhereGoesMyDatas** (UI web) + **netman** (CLI hôte).
5. Anonymisation labo = **anonyman** (Tor / I2P / proxies), pas mélangée au monitoring LAN.

## Catégories (alignement kali.org/tools)

| Catégorie Kali | Dotfiles (cible) | État |
|----------------|------------------|------|
| Reconnaissance | cyberman recon / OSINT modules | partiel |
| Resource Development | cyberlearn + tooling install | stub |
| Initial Access | labs isolés seulement | stub |
| Execution | labs | stub |
| Persistence | docs défensives | stub |
| Privilege Escalation | peass/linpeas via install (lab) | partiel |
| Defense Evasion | docs défense / WGMD | stub |
| Credential Access | hashcat/john install optionnel | partiel |
| Discovery | nmap / netman / WGMD | partiel |
| Lateral Movement | hors scope prod ; lab | stub |
| Collection | mitmproxy lab | stub |
| C2 | hors scope sauf détection | stub |
| Exfiltration | détection via WGMD | stub |
| Impact | hors scope | — |
| Forensics | modules forensics futurs | stub |
| Services / Other | reporting, labs DVWA/juice | partiel cyberlearn |

## Interfaces

- **CLI / TUI** : `cyberman`, `cyberlearn`, `netman`, `anonyman`, `dotcli`
- **Web** : WhereGoesMyDatas uniquement pour monitoring observation (pas d’exposer WAN)

## Prochaines étapes (P17)

1. Inventaire des binaires déjà installables via `installman` / `scripts/install/cyber/`
2. Menu cyberman par catégorie Kali (liens help + check installed)
3. Bridge `cyberman monitor` → health WGMD si configuré
4. Modules cyberlearn manquants (au-delà de basics/network/web)
