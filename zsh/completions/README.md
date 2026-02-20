# Complétions Zsh (dotfiles)

Ce répertoire est ajouté au `fpath` dans `zshrc_custom` pour fournir des complétions personnalisées.

## Contenu

- **`_make`** : complétion des **cibles Makefile** pour `make` et `gmake`.  
  En projet (répertoire contenant un Makefile), `make <TAB>` propose les cibles.

## Chargement

Après `make install` (bootstrap) ou mise en place des symlinks, le shell charge `~/.zshrc` → `shared/config.sh` → `zsh/zshrc_custom`.  
`zshrc_custom` ajoute `$DOTFILES_DIR/zsh/completions` au `fpath` puis lance `compinit`.  
Aucune action supplémentaire : les complétions sont actives dès l’ouverture d’un nouveau zsh.

## Ajouter une complétion

1. Créer un fichier `_commande` dans ce répertoire.
2. Première ligne : `#compdef commande` (ou `#compdef cmd1 cmd2`).
3. Implémenter la fonction de complétion (ex. `compadd`, `_describe`, etc.).
4. Recharger : `exec zsh` ou `compinit` pour prendre en compte un nouveau fichier.

## Référence

- [Zsh Completion System](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)
- Complétions supplémentaires : `~/.zsh/zsh-completions/src` (installé via scripts/config/install_zsh_plugins.sh).
