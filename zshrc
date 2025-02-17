USE_POWERLINE="true"
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# Source custom configurations
if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
	source "$HOME/dotfiles/zsh/zshrc_custom"
	echo "File $HOME/dotfiles/zsh/zshrc_custom sourced"
else
	echo "⚠️  File '$HOME'/dotfiles/zsh/zshrc_custom not found."
fi

# Load function files
#for func_file in ~/dotfiles/zsh/functions/**/*.sh; do
#	source "$func_file"
#done

# Source aliases and environment variables
#[ -f ~/dotfiles/zsh/aliases.zsh ] && source ~/dotfiles/zsh/aliases.zsh
#[ -f ~/dotfiles/zsh/env.sh ] && source ~/dotfiles/zsh/env.sh
# Test modification

# Historique optimisé
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000   # Nombre de commandes chargées en mémoire
SAVEHIST=10000000   # Nombre de commandes sauvegardées dans le fichier d'historique
# Options pour optimiser l'historique
setopt HIST_EXPIRE_DUPS_FIRST    # Supprime les doublons en premier lors de l'élagage
setopt HIST_IGNORE_DUPS          # Ne sauvegarde pas les commandes dupliquées consécutives
setopt HIST_IGNORE_SPACE         # Ignore les commandes commençant par un espace
setopt HIST_VERIFY               # Affiche la commande étendue avant de l'exécuter
setopt SHARE_HISTORY             # Partage l'historique entre les sessions
setopt EXTENDED_HISTORY          # Enregistre le timestamp pour chaque entrée

# Compression de l'historique
zshaddhistory() {
    print -sr -- ${1%%$'\n'}
    fc -p
}

# Fonction pour nettoyer l'historique des doublons
clean_history() {
    local HISTFILE_TMP=$(mktemp)
    fc -W $HISTFILE_TMP
    awk '!seen[$0]++' $HISTFILE_TMP > $HISTFILE
    fc -R $HISTFILE
    rm $HISTFILE_TMP
}

# Nettoyage automatique de l'historique à chaque 1000 commandes
#if (( $HISTCMD % $SAVEHIST == 0 )); then
#    clean_history
#fi
