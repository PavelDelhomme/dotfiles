# SHELLMAN adapter — Fish
function shellman -d "Bascule et configuration des shells"
    set -l df $DOTFILES_DIR
    if test -z "$df"
        set df "$HOME/dotfiles"
    end
    env DOTFILES_DIR="$df" bash -c '
        . "$DOTFILES_DIR/core/managers/shellman/core/shellman.sh" || exit 1
        shellman "$@"
    ' bash $argv
end
