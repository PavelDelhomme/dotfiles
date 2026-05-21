# updateman(1) — mises a jour locales

## Nom

**updateman** — installe et pilote les mises a jour locales gerees par les dotfiles.

## Synopsis

```text
updateman [help | -h | --help]
updateman cursor [run | install | enable | status | logs | help]
```

## Description

`updateman` regroupe les updateurs reutilisables du depot. Le premier module gere Cursor sur Linux AppImage :

- telechargement depuis l'URL officielle `api2.cursor.sh` ;
- detection du Cursor deja installe via `.desktop`, processus en cours, commande `cursor`, `/opt`, puis `~/Applications` ;
- installation vers un chemin stable `Cursor.AppImage` ;
- backup de l'ancien binaire dans `.cursor-backups` ;
- creation optionnelle du lanceur desktop et du shim `~/.local/bin/cursor` ;
- timer `systemd --user` quotidien.

## Commandes Cursor

| Commande | Effet |
|----------|-------|
| `updateman cursor` | Lance la mise a jour maintenant. |
| `updateman cursor install` | Copie `scripts/update/update-cursor-appimage` dans `~/.local/bin` et installe les unites systemd user. |
| `updateman cursor enable` | Installe puis active `cursor-update.timer`. |
| `updateman cursor status` | Affiche l'etat du timer. |
| `updateman cursor logs` | Affiche les derniers logs du service. |
| `updateman cursor help` | Affiche l'aide detaillee. |

## Variables d'environnement

| Variable | Effet |
|----------|-------|
| `APP_PATH` | Force le chemin final exact de `Cursor.AppImage`. |
| `APP_DIR` / `CURSOR_APP_DIR` | Force le dossier final si `APP_PATH` est absent. |
| `CURRENT_APPIMAGE` | Force l'ancien chemin a sauvegarder puis rediriger vers le chemin stable. |
| `DOWNLOAD_URL` | Remplace l'URL de telechargement. |
| `CURSOR_UPDATE_VERSION` | Remplace le suffixe de version utilise dans l'URL par defaut. |
| `BACKUP_DIR` | Force le dossier de backups. |
| `BACKUP_KEEP` | Nombre de backups `.bak` a conserver, `5` par defaut. |
| `CREATE_DESKTOP=0` | Desactive l'ecriture de `~/.local/share/applications/cursor.desktop`. |
| `CREATE_SHIM=0` | Desactive l'ecriture de `~/.local/bin/cursor`. |

## Fichiers

- Core : `core/managers/updateman/core/updateman.sh`
- Updater Cursor : `scripts/update/update-cursor-appimage`
- Timer : `systemd/user/cursor-update.{service,timer}`
- Adaptateurs : `shells/{zsh,bash,fish}/adapters/updateman.*`

## Notes

Fermer Cursor avant la mise a jour reste preferable : le script avertit si Cursor semble lance, mais ne tue aucun processus.
