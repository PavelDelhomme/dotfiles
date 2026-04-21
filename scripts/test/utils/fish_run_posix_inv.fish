#!/usr/bin/env fish
# Pont Fish → core POSIX (même idée que doctorman.fish).
# Usage : fish_run_posix_inv.fish <manager> <chemin_core.sh> [args...]
# Exemple : fish_run_posix_inv.fish pathman /root/dotfiles/core/managers/pathman/core/pathman.sh help

if test (count $argv) -lt 2
    echo "usage: fish_run_posix_inv.fish <manager> <core.sh> [args...]" >&2
    exit 2
end

set -l mgr $argv[1]
set -l core $argv[2]
set -l rest $argv[3..-1]

if test -z "$DOTFILES_DIR"
    set -gx DOTFILES_DIR "$HOME/dotfiles"
end

bash -c 'export DOTFILES_DIR="$1"; cd "$1" || exit 1; . "$2"; m="$3"; shift 3; "$m" "$@"' \
    _ "$DOTFILES_DIR" "$core" "$mgr" $rest
