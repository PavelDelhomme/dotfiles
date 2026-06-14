#!/usr/bin/env bash
################################################################################
# Install executable shims for POSIX managers.
#
# Shell functions disappear under sudo. These shims make commands such as
# `sudo diskman overview` work by loading the POSIX manager core explicitly.
################################################################################

set -u

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
DEST_DIR="${DOTFILES_MANAGER_SHIM_DIR:-/usr/local/bin}"
MANAGERS="${DOTFILES_MANAGER_SHIMS:-diskman}"
APPLY=0
ASSUME_YES=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --dry-run) APPLY=0 ;;
        --yes|-y) ASSUME_YES=1 ;;
        --all) MANAGERS=$(awk 'NF && $1 !~ /^#/ {print $1}' "$DOTFILES_DIR/scripts/test/config/migrated_managers.list" 2>/dev/null) ;;
        --manager)
            shift
            [ "$#" -gt 0 ] || { echo "Argument manquant après --manager" >&2; exit 1; }
            MANAGERS="$1"
            ;;
        --help|-h)
            sed -n '1,20p' "$0"
            exit 0
            ;;
        *) echo "Argument inconnu: $1" >&2; exit 1 ;;
    esac
    shift
done

need_sudo() {
    [ "$(id -u)" -ne 0 ] && [ ! -w "$DEST_DIR" ] && [ "$DEST_DIR" != "${HOME:-}/.local/bin" ]
}

run_or_print() {
    if [ "$APPLY" -eq 1 ]; then
        echo "+ $*"
        "$@"
    else
        echo "[dry-run] $*"
    fi
}

install_one() {
    manager="$1"
    core="$DOTFILES_DIR/core/managers/$manager/core/$manager.sh"
    [ -f "$core" ] || {
        echo "skip $manager: core absent ($core)" >&2
        return 0
    }

    tmp=$(mktemp) || exit 1
    cat > "$tmp" <<EOF
#!/bin/sh
# Managed by dotfiles install_manager_shims.sh
DOTFILES_DIR="\${DOTFILES_DIR:-$DOTFILES_DIR}"
core="\$DOTFILES_DIR/core/managers/$manager/core/$manager.sh"
if [ ! -f "\$core" ]; then
    echo "$manager: core introuvable: \$core" >&2
    exit 127
fi
. "\$core"
$manager "\$@"
EOF
    chmod 0755 "$tmp"

    if need_sudo; then
        run_or_print sudo install -m 0755 "$tmp" "$DEST_DIR/$manager"
    else
        run_or_print mkdir -p "$DEST_DIR"
        run_or_print install -m 0755 "$tmp" "$DEST_DIR/$manager"
    fi
    rm -f "$tmp"
}

if [ "$APPLY" -eq 1 ] && [ "$ASSUME_YES" -ne 1 ]; then
    printf 'Installer les shims managers dans %s ? [y/N] ' "$DEST_DIR"
    read -r answer
    case "$answer" in
        y|Y|yes|YES|o|O|oui|OUI) ;;
        *) echo "Annulé"; exit 1 ;;
    esac
fi

echo "DOTFILES_DIR=$DOTFILES_DIR"
echo "DEST_DIR=$DEST_DIR"
echo "MANAGERS=$(printf '%s ' $MANAGERS)"
echo "Mode=$([ "$APPLY" -eq 1 ] && echo apply || echo dry-run)"
echo ""

for manager in $MANAGERS; do
    install_one "$manager"
done
