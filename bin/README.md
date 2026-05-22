# bin/ - Exécutables dotfiles

## dotfiles-menu

Menu générique basé sur **fzf** (cross-shell). Lit des lignes `label|command`, affiche un menu, imprime la commande sélectionnée.

### Usage

```bash
# Avec un fichier menu (lignes label|command)
dotfiles-menu --file share/menus/pathman.menu --header "PATHMAN"

# Lister / lancer via le helper shell
dfm --list
dfm doctorman

# Depuis stdin
echo "Voir PATH|pathman show" | dotfiles-menu --header "Pathman"

# Fallback si fzf absent (menu numéroté paginé)
dotfiles-menu --file share/menus/pathman.menu --no-fzf
```

**Pour avoir le menu fzf (au lieu du menu numéroté)** : il faut que `fzf` soit installé. En Docker, si tu vois le menu 1) 2) 3)... au lieu de fzf, refais l’image : `make docker-rebuild` puis `make docker-in`.

### Exécuter la commande dans le shell courant

Les commandes comme `pathman` sont des **fonctions** du shell. Pour exécuter le choix dans le shell courant (et non en sous-processus), utiliser le helper :

```bash
# Depuis zsh/bash (après avoir sourcé scripts/lib/dotfiles_menu.sh)
source "$DOTFILES_DIR/scripts/lib/dotfiles_menu.sh"
dotfiles_menu_run pathman   # ou dotfiles_menu_run --file share/menus/pathman.menu --header "PATHMAN"
```

En zsh, on peut définir un alias :

```zsh
alias dfmenu='dotfiles_menu_run'
# Puis: dfmenu pathman
```

### Fichiers de menu

- Format : une ligne = `label|command` (le premier `|` sépare label et commande).
- Lignes vides et commentaires (`#`) sont ignorés.
- Fichiers fournis : voir `share/menus/README.md`.

### Options

- `--file FILE` : fichier menu.
- `--header "Titre"` : en-tête fzf.
- `--no-fzf` : menu numéroté paginé si fzf absent.
- Cote helper shell : `dfm --list` liste les menus declaratifs disponibles.
- Variables : `DOTFILES_MENU_FZF_HEIGHT=90%` ajuste la hauteur fzf ; `DOTFILES_MENU_PAUSE_AFTER_ACTION=0` désactive la pause après action dans `dfm`.

## ncmenu

Sélecteur interactif en **Go** (navigation flèches, validation Entrée).
Conçu pour servir de brique UI pour les managers `*man`.

### Build

```bash
make build-ncmenu
```

### Install système (optionnel)

```bash
make install-ncmenu
```

### Usage

Entrée via stdin, format `label|value` :

```bash
printf "Option A|a\nOption B|b\n" | ncmenu --title "Mon menu"
```

Le programme affiche le menu TUI et imprime la `value` sélectionnée sur stdout.
