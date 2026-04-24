# `git help` / `man` : « Aucun fichier ou dossier de ce nom »

## Ce qui se passe

`git help <commande>` demande en général à **`man`** d’afficher la page du manuel Git correspondante. Si **`man` n’est pas installé**, n’est pas dans le `PATH`, ou si les pages `man` de Git manquent, Git affiche :

- *avertissement : échec de l'exécution de 'man'…*
- *fatal : aucun visualiseur de manuel n'a pris en charge la demande*

Cela **ne vient pas** des dotfiles ni d’`installman` : c’est l’**environnement système** (paquets + `PATH`).

## Correctifs rapides (Arch Linux)

```bash
sudo pacman -S man-db man-pages
```

Puis réessaie : `git help branch`.

## Alternatives sans `man`

- Aide texte dans le terminal : `git branch -h` ou `git help -a`
- Aide HTML dans le navigateur : `git help -w branch` (si un navigateur / `xdg-open` est dispo)
- Pager simple : `GIT_PAGER=less git help branch`

## Vérifications

```bash
command -v man
manpath   # ou echo "$MANPATH"
```

---

*Document court pour éviter de mélanger ce sujet avec la roadmap `installman`.*
