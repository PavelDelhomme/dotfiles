# UI commune des managers (P1 / P3b)

Les managers interactifs POSIX sous `core/managers/<nom>/core/<nom>.sh` doivent charger l’UI partagée au début de la fonction principale :

```sh
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
    # shellcheck source=scripts/lib/manager_ui.sh
    . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
    dotfiles_manager_load_ui_libs   # ncurses_menu + tui_core
fi
```

## Affichage

- **Bannière** : `manager_ui_print_banner "TITRE" ["sous-titre"]` (après `clear` et couleurs du manager).
- **Séparateur de section** : `manager_ui_section_rule` (remplace les lignes `════…` fixes).
- **Tableaux / listes** : `tui_is_compact`, `tui_truncate`, `tui_menu_height` depuis `scripts/lib/tui_core.sh`.

## Sélection De Menu

- **Depuis un fichier** : `manager_ui_select_file "Titre" "$menu_file"` avec des lignes `Label|valeur`.
- **Depuis stdin** : `printf 'Label|valeur\n' | manager_ui_select "Titre"`.
- Ordre cible : `dotcli menu` si `DOTFILES_DOTCLI_ENABLE=1`, puis `dotfiles_ncmenu_select` (`fzf`/`ncmenu`), puis retour `127` pour laisser le manager faire son `read` manuel.

Les wrappers locaux (`netman_dotcli_menu_pick`, `aliaman_dotcli_menu_pick`, `cyberlearn_pick_menu`, etc.) doivent disparaître progressivement ou devenir de simples ponts vers `manager_ui_select_file`.

## Pilotes branchés (2026-05-22)

Affichage : `manman`, `updateman`, `fileman`, `netman`, `installman`, `testman`.

Sélection commune : `netman`, `aliaman`, `cyberlearn`, `searchman`, `miscman`, `testzshman`, `cyberman`.

Bootstrap / legacy : `scripts/bootstrap_menu.sh` (→ `setup.sh`), `scripts/menu/README.md` (`make menu` = legacy).

## Suite P3b-a

Restructurer les menus avant la suite adaptative : clarifier `shared/` vs `share/`, garder `shells/*/adapters` minces, centraliser la sélection dans `manager_ui.sh`, puis documenter/marquer legacy `scripts/menu/*.sh`.

Voir [`docs/architecture/UI_MENU_RESTRUCTURE.md`](../../docs/architecture/UI_MENU_RESTRUCTURE.md).

## Suite P3b-b

Généraliser aux autres `*man` avec bannières fixes (`grep '╔════'` dans `core/managers/`) une fois P3b-a stabilisé.

## Suite P1

Réduire la logique dupliquée dans `zsh/functions/<nom>/` ; un seul core POSIX + adapters minces.
