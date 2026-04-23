#!/bin/sh
# =============================================================================
# INSTALLMAN ENTRY - Point d'entrée unique multi-shell
# =============================================================================
# Tous les shells (bash, fish, etc.) peuvent exécuter ce script.
#
# Moteurs :
#   - zsh (défaut) : core complet (pagination, logs, liste d’outils à jour).
#   - posix        : core POSIX seul (menus/help sans dépendre de zsh).
#                   Utile pour CI, conteneurs minimalistes, « sandbox » lecture seule.
#
# Choisir le moteur POSIX :
#   INSTALLMAN_ENGINE=posix sh installman_entry.sh help
#   sh installman_entry.sh --posix help
#
# Vérifier la syntaxe du core POSIX (sortie vide = OK, comme sh -n) :
#   sh -n "$DOTFILES_DIR/core/managers/installman/core/installman.sh" && echo OK
#   ou : bash scripts/test/installman_check.sh
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export DOTFILES_DIR

POSIX_CORE="$DOTFILES_DIR/core/managers/installman/core/installman.sh"
ZSH_CORE="$DOTFILES_DIR/zsh/functions/installman/core/installman.zsh"

case "$1" in
    --posix|--engine=posix)
        INSTALLMAN_ENGINE=posix
        shift
        ;;
esac

if [ "$INSTALLMAN_ENGINE" = "posix" ]; then
    if [ ! -f "$POSIX_CORE" ]; then
        printf '%s\n' "installman: core POSIX introuvable: $POSIX_CORE" >&2
        exit 1
    fi
    # shellcheck source=core/managers/installman/core/installman.sh
    . "$POSIX_CORE"
    installman "$@"
    exit $?
fi

if [ ! -f "$ZSH_CORE" ]; then
    if [ -f "$POSIX_CORE" ]; then
        printf '%s\n' "installman: zsh absent ou core Zsh manquant, repli sur POSIX: $ZSH_CORE" >&2
        INSTALLMAN_ENGINE=posix
        export INSTALLMAN_ENGINE
        # shellcheck source=core/managers/installman/core/installman.sh
        . "$POSIX_CORE"
        installman "$@"
        exit $?
    fi
    printf '%s\n' "installman: aucun core trouvable (zsh: $ZSH_CORE, posix: $POSIX_CORE)" >&2
    exit 1
fi

if ! command -v zsh >/dev/null 2>&1; then
    if [ -f "$POSIX_CORE" ]; then
        printf '%s\n' "installman: zsh non disponible, repli sur POSIX." >&2
        # shellcheck source=core/managers/installman/core/installman.sh
        . "$POSIX_CORE"
        installman "$@"
        exit $?
    fi
    printf '%s\n' "installman: zsh requis ou définir INSTALLMAN_ENGINE=posix avec core présent." >&2
    exit 1
fi

# Core Zsh (implémentation complète)
# Sous zsh -c, le 1er argument après la chaîne devient $0 (pas $1) ; le reste va dans "$@".
exec zsh -c '
source "${0}/zsh/functions/installman/core/installman.zsh"
installman "$@"
' "$DOTFILES_DIR" "$@"
