# =============================================================================
# PATHMAN ADAPTER - Adapter Fish pour pathman
# =============================================================================
# Description: Délègue au core POSIX (bash). Après clean/invalid, met à jour
#              fish_user_paths / PATH dans le shell courant (--export-path).
# Author: Paul Delhomme
# Version: 2.1
# =============================================================================

if not set -q DOTFILES_DIR
    set -gx DOTFILES_DIR "$HOME/dotfiles"
else if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end
set -g PATHMAN_CORE "$DOTFILES_DIR/core/managers/pathman/core/pathman.sh"

if not test -f "$PATHMAN_CORE"
    echo "❌ Erreur: pathman core non trouvé: $PATHMAN_CORE"
    return 1
end

function pathman
    if test (count $argv) -ge 1
        if test "$argv[1]" = clean; or test "$argv[1]" = invalid
            if test (count $argv) -eq 1
                set -l sub $argv[1]
                set -l np (env PATH="$PATH" PATHMAN_QUIET=1 bash -c 'source "$1"; pathman "$2" --export-path' bash "$PATHMAN_CORE" "$sub")
                if test -n "$np"
                    set -gx PATH "$np"
                    echo "✅ PATH fish synchronisé après pathman $sub (doublons / entrées invalides traités côté POSIX)."
                end
                return 0
            end
        end
    end
    bash -c 'source "$1"; shift; pathman "$@"' _ "$PATHMAN_CORE" $argv
end

alias pm='pathman'
alias path-manager='pathman'
