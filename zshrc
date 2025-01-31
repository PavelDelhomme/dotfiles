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
