# Root variant for Powerlevel10k.
#
# This file intentionally reuses the normal user prompt layout from .p10k.zsh,
# then overrides a small set of colors/icons so root is visually obvious.

if [[ -n "${DOTFILES_DIR:-}" && -f "$DOTFILES_DIR/.p10k.zsh" ]]; then
  source "$DOTFILES_DIR/.p10k.zsh"
elif [[ -f "$HOME/dotfiles/.p10k.zsh" ]]; then
  source "$HOME/dotfiles/.p10k.zsh"
else
  print -r -- "p10k root: base config .p10k.zsh introuvable" >&2
  return 1
fi

() {
  emulate -L zsh

  # Keep the same structure as the user prompt, but make root unmistakable.
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=196
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=202
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=208
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=196
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=214
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=214
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=196
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=196
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=202
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
}
