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

Premiers candidats declaratifs : `pathman`, `searchman`, `helpman`, `doctorman`, `devman`, `virtman`, `displayman`, `sshman`, `processman`, `routeman`, `configman`, `gitman`.
