# Menus declaratifs `dfm`

Ces fichiers alimentent `dfm` / `dfmenu` / `dotfiles_menu_run`.

Format :

```text
Libelle affiche|commande shell
```

Regles :

- `dfm` est reserve aux menus declaratifs dans `share/menus`.
- `manager_ui_select_file` reste le moteur des menus internes `*man` (`Label|valeur`).
- Mettre ici seulement des lanceurs stables ou des raccourcis CLI. Les menus dynamiques, avec etat runtime, sous-menus complexes ou saisies sensibles restent dans le core du manager.
- Eviter deux sources de verite : si un menu racine devient declaratif ici, le core doit idealement le reutiliser ou rester un simple fallback.

Usage :

```sh
dfm --list
dfm pathman
dfm doctorman
make dfmenu MENU=helpman
```

Confort terminal :

- avec `fzf`, le menu occupe `85%` de la hauteur par defaut et reste scrollable ;
- sans `fzf`, `dotfiles-menu --no-fzf` affiche une liste paginee (`n` / `p`) ;
- `dfm` fait une pause apres chaque action en boucle pour laisser lire les sorties longues (`DOTFILES_MENU_PAUSE_AFTER_ACTION=0` pour desactiver).

Premiers candidats declaratifs : `pathman`, `searchman`, `helpman`, `doctorman`, `devman`, `virtman`, `displayman`, `sshman`, `processman`, `routeman`, `configman`, `gitman`.
