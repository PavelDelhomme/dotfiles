# updateman(1) — mises a jour locales

## Nom

**updateman** — pilote les mises a jour des outils installes via les dotfiles (registre partage avec **installman**).

## Synopsis

```text
updateman [help | -h | --help]
updateman status
updateman all [--tools-only]
updateman system [status | pending | refresh | update | help]
updateman arch [status | pending | update | keys librewolf | fix-cache | clean-hints | help]
updateman cursor [run | install | enable | status | logs | help]
```

## Description

`updateman` centralise les mises a jour. Les scripts internes (`scripts/update/...`) ne sont **pas** exposes comme commandes dans `~/.local/bin`.

Flux recommande :

1. **Installation** : `installman cursor` (ou autre outil du registre).
2. **Service auto** : apres install reussi, `installman` appelle `updateman cursor enable` si l'outil est dans le registre.
3. **Mise a jour systeme** : `updateman system refresh` puis `updateman system update` (ou `updateman all` pour systeme + registre).
4. **Mise a jour outils** : `updateman cursor` ou `updateman all --tools-only`.
5. **Vue d'ensemble** : `updateman status` (versions locales, disponibles, timers).

La couche **`updateman system`** detecte la distribution (Arch, Debian/Ubuntu, Fedora/RHEL/Rocky/Alma, Alpine, openSUSE, Gentoo, images immutables avec `rpm-ostree`) et pilote les backends disponibles : `pacman`, `yay`, `paru`, `apt`, `dnf`, `yum`, `tdnf`, `apk`, `zypper`, `emerge`, `flatpak`, `snap`.

Pour Arch/AUR, `updateman arch` fournit un helper prudent autour de `pacman` et `yay` :
diagnostic, mise a jour officielle + AUR, import de cles PGP connues, et rappels de nettoyage.

## Registre

Fichier : `core/managers/updateman/config/updatable-tools.list`

Format : `nom|fonction_check|timer_systemd|auto_service`

| Outil | Check | Timer | Auto apres install |
|-------|-------|-------|-------------------|
| cursor | check_cursor_installed | cursor-update.timer | oui |

Pour ajouter un outil : une ligne dans le registre + handler dans `updateman` + module `installman` si besoin.

## Commandes globales

| Commande | Effet |
|----------|-------|
| `updateman status` | Tableau des outils du registre : presence, versions, maj?, timer, emplacement. |
| `updateman all` | Refresh + upgrade des paquets systeme detectes, puis chaque outil **installe** du registre. |
| `updateman all --tools-only` | Met a jour uniquement les outils du registre (comportement historique). |

## Commandes systeme (multi-distro)

| Commande | Effet |
|----------|-------|
| `updateman system status` | Affiche la distro detectee, les backends disponibles et les mises a jour en attente. |
| `updateman system pending` | Liste les mises a jour par backend (`pacman`, `apt`, `dnf`, `apk`, `zypper`, `flatpak`, …). |
| `updateman system refresh` | Met a jour les index (`apt update`, `dnf makecache`, `apk update`, `zypper refresh`, …). |
| `updateman system update` | Applique les mises a jour sur tous les backends detectes. |

Backends pris en charge : pacman, yay, paru, apt, dnf, yum, tdnf, microdnf, apk, zypper, emerge, flatpak, snap, rpm-ostree (Flatcar/CoreOS).

**Limites** : TrueNAS Scale (Debian-based) est couvert via `apt` si present ; TrueNAS Core (FreeBSD) est hors scope Linux. Les tests Docker couvrent arch, debian, ubuntu, alpine, fedora, centos, opensuse.

## Commandes Arch/AUR

| Commande | Effet |
|----------|-------|
| `updateman arch status` | Affiche espace disque, verrou pacman, mises a jour pacman/AUR, tailles de caches. |
| `updateman arch pending` | Liste uniquement les mises a jour `pacman -Qu` et `yay -Qua`. |
| `updateman arch update` | Lance `sudo pacman -Syu`, puis `yay -Sua` si `yay` est disponible. |
| `updateman arch keys librewolf` | Importe la cle PGP LibreWolf Maintainers utile a `librewolf-bin`. |
| `updateman arch fix-cache` | Supprime les dossiers `download-*` orphelins qui cassent `pacman -Sc`. |
| `updateman arch clean-hints` | Affiche des commandes de nettoyage prudentes sans les executer. |

`updateman arch update` doit etre lance en utilisateur normal : **pas de `sudo yay`**.
`yay` demandera `sudo` seulement pour l'etape pacman.

## Commandes Cursor

| Commande | Effet |
|----------|-------|
| `updateman cursor` | Telecharge et installe l'AppImage (script interne). |
| `updateman cursor install` | Installe les unites systemd user ; supprime l'ancien `~/.local/bin/update-cursor-appimage`. |
| `updateman cursor enable` | Installe puis active `cursor-update.timer`. |
| `updateman cursor status` | Statut du timer. |
| `updateman cursor logs` | Logs du service. |

## Fermeture de Cursor

Si Cursor est ouvert, `updateman cursor` ne remplace plus l'AppImage en silence :

- en terminal interactif, il affiche les processus Cursor detectes et propose de les fermer proprement avant de continuer ;
- via `systemd --user` ou autre contexte sans TTY, il echoue proprement et note dans les logs qu'il faut fermer Cursor ou relancer avec confirmation explicite ;
- `CURSOR_UPDATE_CLOSE_RUNNING=1 updateman cursor` ferme Cursor automatiquement avec `SIGTERM` avant la mise a jour ;
- `CURSOR_UPDATE_FORCE_KILL=1` autorise un `SIGKILL` si Cursor refuse de se fermer apres `CURSOR_UPDATE_CLOSE_TIMEOUT` secondes ;
- `CURSOR_UPDATE_ALLOW_RUNNING=1` ignore volontairement le garde-fou, a eviter sauf diagnostic.

## Lien installman

- `installman update` / menu mise a jour : pour un outil du registre, delegation vers `updateman <outil>`.
- `installman <outil>` : apres succes, si `auto_service=1` dans le registre, active le timer via `updateman <outil> enable`.

Pour tout outil enregistre : `updateman <outil>`, `updateman <outil> enable`, `updateman <outil> status`, `updateman <outil> logs`.

## Fichiers

- Core : `core/managers/updateman/core/updateman.sh`
- Lib distro : `core/lib/distro.sh`
- Lib paquets : `core/lib/pkg_backend.sh`
- Registre : `core/managers/updateman/config/updatable-tools.list`
- Lib partagee : `core/managers/updateman/lib/updatable_tools.sh`
- Updater interne Cursor : `scripts/update/update-cursor-appimage`
- Timer : `systemd/user/cursor-update.{service,timer}`

## Notes

Le timer quotidien ne force pas la fermeture de Cursor. Il reessaiera au prochain declenchement si Cursor etait ouvert.
