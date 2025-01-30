# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
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
if [ -f ~/dotfiles/zsh/zshrc_custom ]; then
	source ~/dotfiles/zsh/zshrc_custom
	echo "Fichier ~/dotfiles/.zsh/zshrc_custom sourcé"
else
	echo "⚠️  Fichier ~/dotfiles/.zsh/zshrc_custom introuvable."
fi

# Load function files
for func_file in ~/dotfiles/zsh/functions/**/*.sh; do
	source "$func_file"
done

# Source aliases and environment variables
[ -f ~/dotfiles/zsh/aliases.zsh ] && source ~/dotfiles/zsh/aliases.zsh
[ -f ~/dotfiles/zsh/env.sh ] && source ~/dotfiles/zsh/env.sh

neofetch
