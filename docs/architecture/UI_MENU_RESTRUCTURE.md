# Restructuration UI / menus (P3b-a)

Objectif : sortir du mélange actuel avant de généraliser les interfaces adaptatives.

## Constat

Le dépôt a plusieurs couches de menus qui se chevauchent :

- `scripts/menu/*.sh` : anciens menus shell globaux, encore utiles comme bootstrap/legacy, mais pas comme socle des managers.
- `scripts/lib/ncurses_menu.sh` : sélecteur actuel `Label|valeur` utilisé par beaucoup de `*man` ; malgré son nom il essaie surtout `fzf`, puis `ncmenu`.
- `scripts/lib/dotfiles_menu.sh` + `bin/dotfiles-menu` + `share/menus/*.menu` : menus déclaratifs `Label|commande`, utilisés par les raccourcis `dfm`/`dfmenu` et quelques chemins comme `pathman`.
- `tools/dotcli` / `bin/dotcli` : cible future plus propre, activée prudemment via `DOTFILES_DOTCLI_ENABLE=1`.
- Wrappers locaux par manager (`netman_dotcli_menu_pick`, `aliaman_dotcli_menu_pick`, `cyberlearn_pick_menu`, etc.) : duplication à supprimer progressivement.

## Rôles cibles

| Chemin | Rôle cible |
| --- | --- |
| `core/managers/<nom>/core/<nom>.sh` | logique canonique du manager |
| `shells/{zsh,bash,fish}/adapters/` | adapters minces : charger/déléguer, pas de logique métier |
| `scripts/lib/tui_core.sh` | primitives terminal POSIX : colonnes, lignes, compact, troncature, pagination |
| `scripts/lib/manager_ui.sh` | API commune managers : chargement UI, bannière, séparateurs, sélection de menu |
| `scripts/lib/ncurses_menu.sh` | backend legacy de sélection `Label|valeur` |
| `share/menus/*.menu` | données de menus déclaratifs pour `dotfiles-menu` / futurs menus déclaratifs |
| `shared/` | config/env/aliases/helpers communs sourçables hors UI manager |
| `scripts/menu/*.sh` | legacy/bootstrap, à ne pas étendre pour les managers |

## Différence `shared/` et `share/`

- `shared/` = code/config commun à sourcer (`shared/env.sh`, `shared/config.sh`, `shared/functions/*`).
- `share/` = données non sourçables, par exemple des menus déclaratifs (`share/menus/pathman.menu`).

Ne pas fusionner brutalement les deux : ils ne portent pas le même type de contenu.

## Plan P3b-a

- [x] Introduire `scripts/lib/manager_ui.sh` comme point commun UI managers.
- [x] Ajouter `manager_ui_select_file` / `manager_ui_select` : `dotcli` si activé, puis `dotfiles_ncmenu_select`, puis fallback appelant.
- [x] Brancher des pilotes : `netman`, `aliaman`, `cyberlearn` pour la sélection ; `manman`, `updateman`, `fileman`, `netman`, `installman`, `testman` pour les bannières.
- [x] Remplacer les wrappers locaux `*_pick_menu` / `*_dotcli_menu_pick` : `netman`, `aliaman`, `cyberlearn`, `searchman`, `miscman`, `testzshman`, `cyberman`.
- [x] Documenter / marquer legacy `scripts/menu/*.sh` (`scripts/menu/README.md`, en-têtes LEGACY, `make bootstrap-menu`).
- [x] Pont bootstrap : `scripts/bootstrap_menu.sh` → `scripts/setup.sh` (même chemin que `bootstrap.sh`).
- [ ] Décider manager par manager si le menu doit rester codé dans le core ou devenir déclaratif dans `share/menus`.
- [ ] Vérifier que les adapters shell restent minces et ne réintroduisent pas de logique UI.

## Plan P3b-b

Une fois P3b-a stabilisé :

- généraliser `manager_ui_print_banner` aux `*man` restants ;
- remplacer les séparateurs fixes par `manager_ui_section_rule` ;
- appliquer `tui_is_compact`, `tui_truncate`, `tui_menu_height` aux tableaux/listes longues ;
- tester `COLUMNS=60`, TTY réel, non-TTY, bash/zsh/fish, avec et sans `DOTFILES_DOTCLI_ENABLE=1`.

## Risques

- Ne pas rendre `dotcli` obligatoire tant que le contrat n’est pas validé partout.
- Ne pas déplacer `share/menus` sans corriger `dotfiles_menu_run`, `dfm`, docs et Makefile.
- Garder des fallbacks non-TTY pour les tests et les pipes.
- Éviter deux sources de vérité pour un même menu.
