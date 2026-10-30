# Adapter Fish — versionman
set -l DOTFILES_DIR (test -n "$DOTFILES_DIR"; and echo $DOTFILES_DIR; or echo $HOME/dotfiles)
set -l _core "$DOTFILES_DIR/core/managers/versionman/core/versionman.sh"
if test -f $_core
    # Fish: exposer via fonction qui appelle bash/sh
    function versionman --description 'Inventaire versions Java & logiciels'
        bash -c 'DOTFILES_DIR="$0" . "$1"; versionman "${@:2}"' $DOTFILES_DIR $_core $argv
    end
    function vm --wraps versionman --description 'alias versionman'
        versionman $argv
    end
else
    echo "versionman core introuvable: $_core" >&2
end
