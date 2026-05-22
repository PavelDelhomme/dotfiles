# Menus legacy (`scripts/menu/`)

> **Ne pas étendre** ces scripts pour de nouveaux managers. Les `*man` vivent sous `core/managers/` et utilisent `scripts/lib/manager_ui.sh`.

## Rôles

| Entrée | Fichier / commande | Usage |
| --- | --- | --- |
| **Bootstrap première install** | `bootstrap.sh` → `scripts/setup.sh` | Chemin canonique après clone (curl / VM). **Pas** `scripts/menu/`. |
| **Menu post-install unifié** | `scripts/bootstrap_menu.sh` | Alias documenté vers `setup.sh` (même comportement que le bootstrap). |
| **Hub scripts legacy** | `make menu` → `main_menu.sh` | Installation/config VM via anciens scripts bash. Conservé pour compatibilité Makefile. |
| **Managers modernes** | `installman`, `manman`, `netman`, … | Socle `core/managers/*/core/*.sh` + `manager_ui_select_file`. |
| **Menus déclaratifs** | `make dfmenu MENU=pathman` | `share/menus/*.menu` + `bin/dotfiles-menu` + `dotfiles_menu_run`. |

## Fichiers ici

- `main_menu.sh` — hub vers install/config/shell/VM/validate/fix.
- `install_menu.sh` — lance des scripts `scripts/install/*` (liste figée).
- `config_menu.sh` — configuration Git, shell, symlinks.

## Migration recommandée

- Nouvelle installation d’outil → **`installman <outil>`** (pas une nouvelle entrée dans `install_menu.sh`).
- Nouveau menu interactif manager → **`core/managers/<nom>/`** + `manager_ui.sh`.
- Menu déclaratif réutilisable → **`share/menus/<nom>.menu`** + `dfm` / `make dfmenu`.

Voir [`docs/architecture/UI_MENU_RESTRUCTURE.md`](../../docs/architecture/UI_MENU_RESTRUCTURE.md).
