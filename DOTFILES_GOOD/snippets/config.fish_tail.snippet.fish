# --- Exemple fin de ~/.config/fish/config.fish — Fish ne source pas les .zsh ---
# Option A : variables dérivées d’un fichier clé=valeur généré depuis shared/env (à définir plus tard).
# Option B : POSIX via bash, uniquement si nécessaire :
# if test -r "$HOME/dotfiles/DOTFILES_GOOD/lib/bootstrap_posix.sh"
#   bash -c 'source "$HOME/dotfiles/DOTFILES_GOOD/lib/bootstrap_posix.sh" && env -0' | while read -z line
#     # parser line — à soigner ; préférer Option A à terme
#   end
# end
# Puis : source des adapters fish sous $HOME/dotfiles/shells/fish/...
