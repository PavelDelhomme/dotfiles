# WhereGoesMyDatas — intégration vision dans les dotfiles
>
> **Hub** : [`../INDEX.md`](../INDEX.md) · **Tâches** : [`../../TODOS.md`](../../TODOS.md) · **Cyber** : [`../managers/CYBERMAN_KALI_MATRIX.md`](../managers/CYBERMAN_KALI_MATRIX.md)

# WhereGoesMyDatas (projet externe)

Dépôt source (hors monorepo) :

`~/Documents/Dev/Perso/WhereGoesMyDatas`

## Rôle

Application web légère (cible Raspberry Pi / mini-PC) pour **observer** où vont les données des appareils choisis : proxy DNS, métadonnées de flux IP, inventaire LAN (`nmap -sn`), carte geo, page Monitoring.

> « Fonctionne sans mettre le Raspberry Pi en passerelle par défaut. » — README du projet

## Topologie cible (chez toi)

```text
Internet → box FAI → mini-PC (WhereGoesMyDatas + pare-feu) → LAN (Wi‑Fi / Ethernet)
```

Aujourd’hui le MVP est en mode **observer** (DNS forcé sur un appareil de test).  
Demain : mode **gateway** derrière la box — le mini-PC devient passerelle par défaut pour tout le trafic local.

## Frontière avec les managers dotfiles

| Outil | Rôle |
|-------|------|
| **netman** | Host : interfaces, routes, DNS clients, ports, diagnostic |
| **cyberman** | Posture sécu, inventaire outils Kali, workflows défensifs |
| **cyberlearn** | Parcours d’apprentissage (labs) |
| **anonyman** | Tor / I2P / proxies labo |
| **WhereGoesMyDatas** | Service Docker d’observation + UI web (ports 8080/53 ou 7070/5353) |

## Make / ports (rappel)

| Mode | Make | Web | DNS |
|------|------|-----|-----|
| Local PC | `make up-local` | 7070 | 5353 |
| Pi / full | `make up-full` | 8080 | 53/udp |

`make init-config` · `make doctor` · `make health` · `make test-dns-local`

## Docs à lire dans le dépôt WGMD

- `docs/portable-installation-and-low-resource-mode.md`
- `docs/defense-spoofing-and-indirect-scans.md` (angle **défensif** uniquement)
- `docs/tuya-local-iot-control-plan.md`
- `docs/deception-honeynet-plan.md`

## Sécurité (non négociable)

- Pas d’exposition IP publique / pas de port-forward box vers 8080 ou 53
- `ENABLE_FIREWALL_APPLY=false` tant que ce n’est pas volontairement la passerelle
- Capture = métadonnées, **pas** de déchiffrement HTTPS
- Geo distant (`ip-api.com`) optionnel — préférer GeoIP locale plus tard

## TODO d’intégration (dotfiles)

Voir **P16** / **P17** dans [`TODOS.md`](../../TODOS.md) : helpers `wgmd-*`, liens cyberman/netman, smoke Docker, checklist avant mode gateway.
