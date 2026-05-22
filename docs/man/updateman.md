# updateman(1) — mises a jour locales

## Nom

**updateman** — pilote les mises a jour des outils installes via les dotfiles (registre partage avec **installman**).

## Synopsis

```text
updateman [help | -h | --help]
updateman status
updateman all
updateman cursor [run | install | enable | status | logs | help]
```

## Description

`updateman` centralise les mises a jour. Les scripts internes (`scripts/update/...`) ne sont **pas** exposes comme commandes dans `~/.local/bin`.

Flux recommande :

1. **Installation** : `installman cursor` (ou autre outil du registre).
2. **Service auto** : apres install reussi, `installman` appelle `updateman cursor enable` si l'outil est dans le registre.
3. **Mise a jour** : `updateman cursor` ou `updateman all`.
4. **Vue d'ensemble** : `updateman status` (versions locales, disponibles, timers).

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
| `updateman all` | Met a jour chaque outil **installe** du registre, un par un. |

## Commandes Cursor

| Commande | Effet |
|----------|-------|
| `updateman cursor` | Telecharge et installe l'AppImage (script interne). |
| `updateman cursor install` | Installe les unites systemd user ; supprime l'ancien `~/.local/bin/update-cursor-appimage`. |
| `updateman cursor enable` | Installe puis active `cursor-update.timer`. |
| `updateman cursor status` | Statut du timer. |
| `updateman cursor logs` | Logs du service. |

## Lien installman

- `installman update` / menu mise a jour : pour **cursor**, delegation vers `updateman cursor`.
- `installman cursor` : apres succes, active le timer via `updateman cursor enable`.

## Fichiers

- Core : `core/managers/updateman/core/updateman.sh`
- Registre : `core/managers/updateman/config/updatable-tools.list`
- Lib partagee : `core/managers/updateman/lib/updatable_tools.sh`
- Updater interne Cursor : `scripts/update/update-cursor-appimage`
- Timer : `systemd/user/cursor-update.{service,timer}`

## Notes

Fermer Cursor avant une mise a jour manuelle reste recommande.
