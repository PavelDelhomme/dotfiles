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
- **Séparateur de section** : `manager_ui_section_line "${BLUE}" "${RESET}\n"` (ou `manager_ui_section_rule` seul).
- **Quitter un menu racine** : `0`, `q`, `quit`, `exit` → `return 1` dans `show_main_menu`, boucle `while true; do show_main_menu || break; done` (voir `manager_ui_is_quit_choice`).
- **Tableaux / listes** : `tui_is_compact`, `tui_truncate`, `tui_menu_height` depuis `scripts/lib/tui_core.sh`.

## Sélection De Menu

- **Depuis un fichier** : `manager_ui_select_file "Titre" "$menu_file"` avec des lignes `Label|valeur`.
- **Depuis stdin** : `printf 'Label|valeur\n' | manager_ui_select "Titre"`.
- Ordre cible : `dotcli menu` si `DOTFILES_DOTCLI_ENABLE=1`, puis `dotfiles_ncmenu_select` (`fzf`/`ncmenu`), puis retour `127` pour laisser le manager faire son `read` manuel.
- **Convention quit** : chaque menu doit exposer `Quitter|0` et accepter aussi `q` si le backend le permet. Les actions historiques utilisant `0` doivent être déplacées (`x` pour export, par exemple).
- **Automatisation** : `make test-menu-quit` vérifie `manager_ui_is_quit_choice`, `ncmenu`, `dotfiles_ncmenu_select` et un échantillon de managers `--help` en pseudo-TTY. `make test-docker` lance ce smoke en Phase 2b.
- **Longues listes** : si un manager passe beaucoup d’items à `dotcli`, utiliser `manager_ui_select_file` / `--items-file` et laisser `dotcli` gérer le viewport. Si le manager imprime lui-même une table avant le menu (ex. `netman ports`), il doit paginer cette table avec `tui_menu_height` avant d’appeler le menu d’action.

Les wrappers locaux (`netman_dotcli_menu_pick`, `aliaman_dotcli_menu_pick`, `cyberlearn_pick_menu`, etc.) doivent disparaître progressivement ou devenir de simples ponts vers `manager_ui_select_file`.

## Backends De Menu

- `ncmenu` doit lire les items depuis stdin mais lire les touches via `/dev/tty`, sinon `ncmenu < menu_file` n’est pas interactif.
- `fzf` est pratique en vrai terminal mais doit rester remplaçable en CI ; les tests utilisent un stub qui sélectionne `Quitter|0`.
- Les menus `dotcli` réels se valident en manuel avec `DOTFILES_DOTCLI_ENABLE=1` (voir `docs/TESTS.md` F.7).

## Menus Déclaratifs `dfm`

`dfm` / `dfmenu` est reserve a `share/menus/*.menu` avec le format `Label|commande shell`.

- Utiliser `dfm` pour des lanceurs stables : `dfm doctorman`, `dfm gitman`, `dfm displayman`.
- Garder `manager_ui_select_file` pour les menus internes qui retournent une valeur de `case`.
- Ne pas dupliquer durablement un menu : si un menu racine devient declaratif, le core doit rester fallback ou reutiliser la meme source.

## Pilotes branchés (2026-05-22)

Affichage (`manager_ui_print_banner`) : `manman`, `updateman`, `fileman`, `netman`, `installman`, `testman`, `devman`, `virtman`, `sshman`, `displayman`, `helpman`, `processman`, `routeman`, `configman`, `gitman`, `moduleman`, `multimediaman`, `cyberman`, `aliaman`, `searchman`, `miscman`, `testzshman`, `cyberlearn`.

Sélection commune : `netman`, `aliaman`, `cyberlearn`, `searchman`, `miscman`, `testzshman`, `cyberman`.

Bootstrap / legacy : `scripts/bootstrap_menu.sh` (→ `setup.sh`), `scripts/menu/README.md` (`make menu` = legacy).

## Suite P3b-a

Restructurer les menus avant la suite adaptative : clarifier `shared/` vs `share/`, garder `shells/*/adapters` minces, centraliser la sélection dans `manager_ui.sh`, puis documenter/marquer legacy `scripts/menu/*.sh`.

Voir [`docs/architecture/UI_MENU_RESTRUCTURE.md`](../../docs/architecture/UI_MENU_RESTRUCTURE.md).

## Suite P3b-b

- **Fait** : bannières ; `manager_ui_section_line` ; `pathman` / `doctorman` ; `processman` + `tui_menu_height` ; sortie **0/q** + boucle `show_main_menu || break` ; `ncmenu` avec sélection directe `0/q/1…` ; smoke `make test-tui-compact` (COLUMNS 60/69) + `make test-menu-quit`.
- **En pause** : `tui_truncate`, pagination menus longs, aligner cyberman/installman et menus inline ; validation manuelle EXT-002.

## Suite P1

Réduire la logique dupliquée dans `zsh/functions/<nom>/` ; un seul core POSIX + adapters minces.
