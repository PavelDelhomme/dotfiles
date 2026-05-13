# displayman

Gestionnaire d'écran / luminosité / preset couleur via DDC/CI (`ddcutil`) +
guide OSD physique et diagnostic Full vs Limited range HDMI.

## Synopsis

```
displayman [command] [args]
```

## Convention CLI (alignée Bloc G de `docs/TESTS.md`)

| Invocation                          | Comportement                                             |
|-------------------------------------|----------------------------------------------------------|
| `displayman`                        | Aide rapide sur stdout, `rc=0` (non interactif).         |
| `displayman help` \| `-h` \| `aide` | Idem.                                                    |
| `displayman help --interactive`     | Aide rapide + pause si TTY ; sinon stderr + aide stdout. |
| `displayman --help`                 | Aide rapide + pause TTY + menu interactif (TTY requis).  |
| `displayman <arg-inconnu>`          | Message d'erreur sur stderr, `rc=1`.                     |

## Commandes

| Commande                              | Description                                                          |
|---------------------------------------|----------------------------------------------------------------------|
| `displayman detect`                   | Lister les écrans détectés (`ddcutil detect --brief` + KDE si dispo). |
| `displayman info [n]`                 | Détail de l'écran `n` (défaut `1`).                                  |
| `displayman dump [n]`                 | Dump des VCP utiles (brightness, contraste, preset, gains, niveaux). |
| `displayman brightness [n] [0..100]`  | Lit (sans valeur) ou règle la luminosité (VCP `10`).                 |
| `displayman contrast   [n] [0..100]`  | Lit ou règle le contraste (VCP `12`).                                |
| `displayman preset     [n] [name]`    | Lit ou tente la bascule preset (VCP `14`). Noms : `srgb`, `6500k`, `7500k`, `9300k`, `user`, ou hex (`01`, `0b`…). |
| `displayman reset      [n] [--yes]`   | Restore couleur (VCP `08`) + factory defaults (VCP `04`). Confirmation TTY ou `--yes`. |
| `displayman range`                    | Diagnostic Full / Limited range HDMI + procédure de fix selon GPU.   |
| `displayman osd-guide`                | Guide pas-à-pas pour l'OSD physique (joystick au dos).               |

## Variables d'environnement

| Variable                  | Défaut | Rôle                                                       |
|---------------------------|--------|------------------------------------------------------------|
| `DISPLAYMAN_DDC_TIMEOUT`  | `15`   | Timeout (s) pour chaque appel `ddcutil`.                   |
| `NO_COLOR`                | —      | Désactive les couleurs ANSI si défini (standard).          |

## Pré-requis

- `ddcutil` (Arch : `sudo pacman -S ddcutil` ; Debian/Ubuntu : `sudo apt install ddcutil`).
- Accès lecture/écriture aux `/dev/i2c-*` du moniteur ciblé (groupe `i2c` ou ACL).
- Optionnel : `kscreen-doctor` pour le complément KDE.

## Bug firmware Xiaomi (preset couleur non modifiable via DDC)

Sur certains Mi Monitor (MCCS 2.1), le firmware accuse réception de l'écriture
sur `VCP 14` (color preset) mais ignore silencieusement le changement. Symptôme :
`ddcutil ... setvcp 14 0x01` réussit (`rc=0`) mais `getvcp 14` renvoie toujours
la valeur précédente (souvent `0x0b = User 1`).

→ Voir `displayman osd-guide` pour la procédure OSD physique de contournement.
Détaillé dans `docs/ERRORS.md` et `docs/guides/SCREEN_DISPLAY.md`.

## Exemples

```sh
displayman                          # aide stdout (rc=0)
displayman detect                   # lister les écrans détectés
displayman dump 1                   # diagnostic complet écran 1
displayman brightness 1 80          # luminosité 80 % sur écran 1
displayman preset 1 srgb            # tente bascule preset sRGB
displayman reset 1 --yes            # reset usine couleur sans prompt
displayman range                    # explique Full vs Limited HDMI
displayman --help                   # menu interactif (TTY requis)
```

## Voir aussi

- `docs/guides/SCREEN_DISPLAY.md` — diagnostic complet (DDC, OSD, Full Range NVIDIA).
- `docs/ERRORS.md` — entrée sur le firmware Xiaomi.
- `docs/TESTS.md` Bloc G — convention CLI/help unifiée pour les `*man`.
