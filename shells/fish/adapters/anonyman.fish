# ANONYMAN adapter — Fish (délègue au core POSIX via bash)
function anonyman -d "Anonymisation Tor/I2P/proxies"
    set -l df $DOTFILES_DIR
    if test -z "$df"
        set df "$HOME/dotfiles"
    end
    env DOTFILES_DIR="$df" bash -c '
        . "$DOTFILES_DIR/core/managers/anonyman/core/anonyman.sh" || exit 1
        anonyman "$@"
    ' bash $argv
end

function anonymman -d "Alias anonyman"
    anonyman $argv
end
