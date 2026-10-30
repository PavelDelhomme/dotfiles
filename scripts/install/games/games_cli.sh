#!/usr/bin/env bash
# CLI miroir jeux hors-git
set -euo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# shellcheck source=/dev/null
. "$DOTFILES_DIR/scripts/lib/games_mirror.sh"

usage() {
    cat <<EOF
dotfiles games — gros jeux hors dépôt git

  games status              état miroir + jeux installés
  games stage <fichier…>    copie archive(s) vers le miroir local
  games stage-known         stage Noita/Terraria s’ils sont trouvés
  games mirror              affiche le chemin du miroir
  games install <jeu>       noita | terraria | zomboid

Miroir local (défaut): /data/jeux/dotfiles-mirror
HTTP privé optionnel:  export DOTFILES_GAMES_MIRROR_URL=https://ton-nas/games

Les binaires ne vont JAMAIS dans git (trop lourds + licences).
EOF
}

cmd="${1:-status}"
[ "$#" -gt 0 ] && shift || true

case "$cmd" in
    help|-h|--help) usage ;;
    mirror|dir)
        printf '%s\n' "$(games_mirror_dir)"
        ;;
    status)
        m=$(games_mirror_dir)
        echo "Miroir: $m"
        mkdir -p "$m"
        echo "Contenu:"
        ls -lh "$m" 2>/dev/null | sed 's/^/  /' || echo "  (vide)"
        echo ""
        echo "Installé:"
        for j in noita terraria zomboid; do
            case "$j" in
                noita) [ -x /opt/Noita/start.sh ] && s=oui || s=non ;;
                terraria) [ -x "$HOME/GOG Games/Terraria/start.sh" ] && s=oui || s=non ;;
                zomboid) [ -x "$HOME/.local/bin/zomboid" ] && s=oui || s=non ;;
            esac
            printf "  %-10s %s\n" "$j" "$s"
        done
        echo ""
        echo "URL miroir: ${DOTFILES_GAMES_MIRROR_URL:-"(non défini)"}"
        ;;
    stage)
        [ "$#" -gt 0 ] || { echo "Usage: games stage <fichier…>" >&2; exit 1; }
        for f in "$@"; do
            [ -f "$f" ] || { echo "absent: $f" >&2; continue; }
            out=$(games_stage_archive "$f")
            echo "OK → $out"
        done
        ;;
    stage-known)
        for f in \
            "$HOME/Téléchargements/Noita_v08.04.24_Linux.tar.xz" \
            /data/jeux/Noita_v08.04.24_Linux.tar.xz \
            "$HOME/Téléchargements/terraria_v1_4_5_6_89299.sh" \
            /data/jeux/terraria_v1_4_5_6_89299.sh; do
            [ -f "$f" ] || continue
            echo "stage $f"
            games_stage_archive "$f" >/dev/null && echo "  → $(games_mirror_dir)/$(basename "$f")"
        done
        ;;
    install)
        g="${1:-}"
        case "$g" in
            noita) bash "$DOTFILES_DIR/scripts/install/games/install_noita.sh" ;;
            terraria) bash "$DOTFILES_DIR/scripts/install/games/install_terraria.sh" ;;
            zomboid|pz|projectzomboid) bash "$DOTFILES_DIR/scripts/install/games/install_zomboid.sh" ;;
            *) echo "jeux: noita|terraria|zomboid" >&2; exit 1 ;;
        esac
        ;;
    *)
        usage
        exit 1
        ;;
esac
