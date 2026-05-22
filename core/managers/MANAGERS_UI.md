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

## Pilotes branchés (2026-05-22)

`manman`, `updateman`, `fileman`, `netman`, `installman`, `testman`.

## Suite P3b

Généraliser aux autres `*man` avec bannières fixes (`grep '╔════'` dans `core/managers/`).

## Suite P1

Réduire la logique dupliquée dans `zsh/functions/<nom>/` ; un seul core POSIX + adapters minces.
