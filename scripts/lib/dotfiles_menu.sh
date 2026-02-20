# =============================================================================
# dotfiles-menu - Helpers pour exécuter le menu dans le shell courant
# =============================================================================
# Sourcer ce fichier puis appeler dotfiles_menu_run <fichier.menu> [header]
# Pour que les commandes (pathman, installman, etc.) s'exécutent dans le
# shell courant, on lit la sortie de dotfiles-menu et on eval.
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_MENU_BIN="${DOTFILES_MENU_BIN:-$DOTFILES_DIR/bin/dotfiles-menu}"

# Exécute le menu et lance la commande sélectionnée. En mode boucle, revient au menu après chaque action (sauf Quitter).
# Usage: dotfiles_menu_run pathman   ou   dotfiles_menu_run --file x.menu
#        dotfiles_menu_run pathman --no-loop   pour une seule action puis sortie
dotfiles_menu_run() {
    local file="" header="" loop=1
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --file)    file="$2"; shift 2 ;;
            --header) header="$2"; shift 2 ;;
            --no-loop) loop=0; shift ;;
            *) break ;;
        esac
    done
    if [[ -z "$file" ]] && [[ $# -gt 0 ]]; then
        file="$1"
        shift
        if [[ "$file" != */* ]] && [[ "$file" != *.menu ]]; then
            file="${DOTFILES_DIR}/share/menus/${file}.menu"
        fi
    fi
    if [[ -z "$header" ]] && [[ $# -gt 0 ]]; then
        header="$1"
    fi
    [[ -z "$header" ]] && header="Menu"

    if [[ -z "$file" ]]; then
        echo "Usage: dfm <menu>   ex: dfm pathman" >&2
        local menus_dir="${DOTFILES_DIR}/share/menus"
        if [[ -d "$menus_dir" ]]; then
            echo "Menus disponibles:" >&2
            for m in "$menus_dir"/*.menu; do
                [[ -f "$m" ]] && echo "  - $(basename "$m" .menu)" >&2
            done
        fi
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "Fichier menu introuvable: $file" >&2
        return 1
    fi
    [[ -z "$header" ]] && header=$(basename "$file" .menu | tr '[:lower:]' '[:upper:]')
    [[ -z "$header" ]] && header="Menu"
    if [[ ! -f "$DOTFILES_MENU_BIN" ]]; then
        echo "Erreur: dotfiles-menu introuvable: $DOTFILES_MENU_BIN" >&2
        return 1
    fi

    local out
    out=$(mktemp 2>/dev/null) || out="/tmp/dfm-$$.out"
    while true; do
        bash "$DOTFILES_MENU_BIN" --file "$file" --header "$header" --output-file "$out"
        local ret=$?
        local cmd
        [[ -f "$out" ]] && cmd=$(cat "$out" 2>/dev/null)
        rm -f "$out" 2>/dev/null
        if [[ $ret -ne 0 ]] || [[ -z "$cmd" ]]; then
            break
        fi
        # Quitter = commande "true" (ne rien faire et sortir)
        if [[ "$cmd" == "true" ]]; then
            break
        fi
        # Désactiver xtrace pour ne pas afficher "cmd='...'" avant l'exécution
        set +x 2>/dev/null
        unsetopt xtrace 2>/dev/null
        eval "$cmd"
        # Une seule action puis sortie si --no-loop
        [[ $loop -eq 0 ]] && break
    done
}
