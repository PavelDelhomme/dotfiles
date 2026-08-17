# DOCKERMAN adapter — Fish
function dockerman -d "Aide et vue Docker (conteneurs, images, compose)"
    set -l df $DOTFILES_DIR
    if test -z "$df"
        set df "$HOME/dotfiles"
    end
    env DOTFILES_DIR="$df" bash -c '
        . "$DOTFILES_DIR/core/managers/dockerman/core/dockerman.sh" || exit 1
        dockerman "$@"
    ' bash $argv
end
