#!/bin/sh
# =============================================================================
# DOCKERMAN — aide et vue Docker quotidienne (core POSIX)
# =============================================================================
# Lecture seule par défaut. prune / cmd --run sont les seuls chemins d'écriture.
# Convention G.x : help / -h / aide / --help ; arg inconnu -> stderr + rc 1
# =============================================================================

# DESC: Vue et aide Docker (ps, images, compose, cheat sheet)
# USAGE: dockerman [commande] [args]

dockerman() {
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m'); GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m'); CYAN=$(printf '\033[0;36m')
        BOLD=$(printf '\033[1m'); RESET=$(printf '\033[0m')
    else
        RED=; GREEN=; YELLOW=; CYAN=; BOLD=; RESET=
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    DOTFILES_PREFIX="${DOTFILES_DOCKER_PREFIX:-dotfiles-test}"
    DOCKERMAN_TIMEOUT="${DOCKERMAN_TIMEOUT:-8}"

    if [ -f "$DOTFILES_DIR/scripts/lib/manager_ui.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/manager_ui.sh"
        command -v dotfiles_manager_load_ui_libs >/dev/null 2>&1 && dotfiles_manager_load_ui_libs
    fi

    _dockerman_pause() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            # shellcheck disable=SC2034
            read _dummy || true
        fi
    }

    _dockerman_header() {
        printf "%s%sDOCKERMAN%s — %s\n" "$CYAN" "$BOLD" "$RESET" "$1"
        printf "%s\n" "────────────────────────────────────────────────────────────"
    }

    _dockerman_has_docker() {
        command -v docker >/dev/null 2>&1
    }

    _dockerman_docker() {
        if ! _dockerman_has_docker; then
            printf "${RED}docker introuvable${RESET} — installe : installman docker  ou  make install-docker\n" >&2
            return 127
        fi
        if command -v timeout >/dev/null 2>&1; then
            timeout "$DOCKERMAN_TIMEOUT" docker "$@"
        else
            docker "$@"
        fi
    }

    dockerman_print_help() {
        printf "${CYAN}${BOLD}DOCKERMAN${RESET} — vue et aide des commandes Docker\n\n"
        printf "Interface :\n"
        printf "  dockerman                      cette aide (stdout)\n"
        printf "  dockerman help | -h | aide     idem\n"
        printf "  dockerman help --interactive   aide + pause (TTY)\n"
        printf "  dockerman --help               aide + pause (TTY)\n"
        printf "  dockerman menu                 menu (TTY)\n\n"
        printf "Voir (lecture, timeout ${DOCKERMAN_TIMEOUT}s) :\n"
        printf "  ${BOLD}dockerman status${RESET} | doctor | version | context\n"
        printf "  ${BOLD}dockerman ps${RESET} [all]             conteneurs (all = -a)\n"
        printf "  ${BOLD}dockerman images${RESET}               images locales\n"
        printf "  ${BOLD}dockerman networks${RESET} | volumes | df | stats\n"
        printf "  ${BOLD}dockerman logs${RESET} <id> [N]        derniers logs (N=100)\n"
        printf "  ${BOLD}dockerman inspect${RESET} <id>         inspect JSON (head)\n"
        printf "  ${BOLD}dockerman compose${RESET} [ps|ls|config|file]\n"
        printf "  ${BOLD}dockerman prefix${RESET} | sandbox     isolation dotfiles-test\n\n"
        printf "Apprendre / retrouver une commande :\n"
        printf "  ${BOLD}dockerman cheat${RESET} [groupe]       aide-memoire (all|ps|run|images|compose|net|vol|build|sys)\n"
        printf "  ${BOLD}dockerman search${RESET} <mot>         cherche dans l'aide-memoire\n"
        printf "  ${BOLD}dockerman explain${RESET} <cmd>        explique une commande docker\n"
        printf "  ${BOLD}dockerman cmd${RESET} [--run] -- docker ...   affiche (et optionnellement lance)\n\n"
        printf "Nettoyage (dry-run par defaut) :\n"
        printf "  ${BOLD}dockerman prune --dry-run${RESET}      liste ce qui serait supprime\n"
        printf "  ${BOLD}dockerman prune --apply${RESET}        docker system prune (TTY + confirmation)\n\n"
        printf "Exemples :\n"
        printf "  dockerman cheat run\n"
        printf "  dockerman search compose\n"
        printf "  dockerman ps all\n"
        printf "  dockerman cmd -- docker ps -a\n"
        printf "  dockerman cmd --run -- docker ps\n\n"
        printf "Lies : virtman docker · diskman (df docker) · make docker-in · bash test-docker.sh --help\n"
        printf "Man : docs/man/dockerman.md · Tests : make tests-smoke-manager MANAGER=dockerman\n"
    }

    _dockerman_cheat_text() {
        cat <<'EOF'
# DOCKERMAN cheat — commandes Docker du quotidien
# Groupes: ps run images compose net vol build sys exec logs inspect

## ps  — lister / etat
docker ps                         # conteneurs en cours
docker ps -a                      # tous (stopped inclus)
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker container ls -a            # alias de ps -a
docker stats --no-stream          # CPU/RAM un coup
docker top CONTAINER              # processus dans le conteneur
docker port CONTAINER             # ports publies

## run  — lancer (lecture: expliquer avant d'executer)
docker run --rm -it alpine sh     # interactif, se supprime a la sortie
docker run -d --name NAME IMAGE   # detache
docker run -p 8080:80 IMAGE       # publier un port
docker run -v $PWD:/data IMAGE    # monter le cwd
docker run --rm hello-world       # smoke daemon
docker start|stop|restart NAME
docker rm NAME                    # supprimer un conteneur arrete
docker rm -f NAME                 # forcer (en cours aussi)
docker rename OLD NEW
docker kill NAME                  # SIGKILL
docker pause|unpause NAME
docker wait NAME                  # attendre exit code

## exec / logs / inspect / cp
docker exec -it NAME sh           # ou bash
docker logs NAME
docker logs -f --tail 100 NAME
docker inspect NAME
docker inspect -f '{{.State.Status}}' NAME
docker diff NAME                  # fichiers modifies
docker cp NAME:/path ./local
docker cp ./local NAME:/path
docker attach NAME                # stdin du process PID 1 (prudent)
docker commit NAME NEWIMAGE       # snapshot filesystem

## images
docker images                     # images locales
docker image ls
docker pull IMAGE[:tag]
docker push IMAGE[:tag]
docker rmi IMAGE                  # supprimer une image
docker tag SRC DST
docker history IMAGE
docker inspect IMAGE
docker save IMAGE -o file.tar
docker load -i file.tar
docker image prune                # images dangling
docker builder prune              # cache build

## build
docker build -t NAME:tag .
docker build --no-cache -t NAME .
docker build --load -t NAME .     # BuildKit -> daemon local
docker build -f Dockerfile.test -t NAME .
DOCKER_BUILDKIT=1 docker build .

## compose  (plugin v2 : docker compose)
docker compose ps
docker compose ls
docker compose config             # valider le YAML
docker compose up -d
docker compose up --build
docker compose down
docker compose down -v            # + volumes du compose (destructif)
docker compose logs -f [SERVICE]
docker compose exec SERVICE sh
docker compose pull
docker compose restart [SERVICE]
docker compose stop
# ancien binaire : docker-compose (v1) — preferer « docker compose »

## net
docker network ls
docker network inspect NET
docker network create NET
docker network rm NET
docker network connect NET CONTAINER
docker network disconnect NET CONTAINER
docker network prune              # reseaux non utilises

## vol
docker volume ls
docker volume inspect VOL
docker volume create VOL
docker volume rm VOL
docker volume prune               # volumes orphelins (destructif)

## sys  — daemon / menage
docker version
docker info
docker system df                  # espace images/conteneurs/volumes
docker system info
docker context ls
docker context use default
docker login                      # registry (token 2FA)
docker logout
docker events --since 10m         # flux evenements
docker system prune               # stopped + dangling (demande confirm)
docker system prune -a            # + images non utilisees
docker system prune -a --volumes  # + volumes (tres destructif)

## sandbox dotfiles (ne touche pas tes autres images)
# Prefixe isole : dotfiles-test
make docker-in                    # bac distro x shell
make test                         # CI managers dans le conteneur
bash test-docker.sh --help
bash test-docker.sh --yes
dockerman prefix                  # lister ressources du prefixe
virtman docker                    # menu virtman (legacy)
installman docker                 # installer le moteur
EOF
    }

    dockerman_cheat() {
        _grp="${1:-all}"
        _dockerman_header "aide-memoire Docker"
        case "$_grp" in
            all|"")
                _dockerman_cheat_text
                ;;
            ps|run|images|image|compose|net|network|vol|volume|build|sys|system|exec|logs|inspect|sandbox)
                case "$_grp" in
                    image) _grp=images ;;
                    network) _grp=net ;;
                    volume) _grp=vol ;;
                    system) _grp=sys ;;
                esac
                _dockerman_cheat_text | awk -v g="$_grp" '
                    BEGIN { show=0 }
                    /^## / {
                        key=$2
                        show=(key==g)
                    }
                    show { print }
                '
                ;;
            *)
                printf "${RED}Groupe inconnu:${RESET} %s\n" "$_grp" >&2
                printf "Groupes : all ps run images compose net vol build sys exec logs inspect sandbox\n" >&2
                return 1
                ;;
        esac
    }

    dockerman_search() {
        _q="${1:-}"
        if [ -z "$_q" ]; then
            printf "${RED}Usage:${RESET} dockerman search <mot>\n" >&2
            return 1
        fi
        _dockerman_header "recherche: $_q"
        _dockerman_cheat_text | grep -i -- "$_q" || {
            printf "${YELLOW}Aucun match.${RESET} Essaie: ps, compose, prune, volume, exec\n"
            return 1
        }
    }

    dockerman_explain() {
        _c="${1:-}"
        if [ -z "$_c" ]; then
            printf "${RED}Usage:${RESET} dockerman explain <commande>\n" >&2
            printf "Ex. : dockerman explain run | ps | compose | prune | exec | build\n" >&2
            return 1
        fi
        _c="${_c#docker}"
        _c="${_c# }"
        case "$_c" in
            compose*) _g=compose ;;
            ps|container*) _g=ps ;;
            run|start|stop|rm|kill) _g=run ;;
            exec|logs|inspect|cp|attach|commit) _g=exec ;;
            image*|pull|push|rmi|tag) _g=images ;;
            build|builder) _g=build ;;
            network*|net) _g=net ;;
            volume*|vol) _g=vol ;;
            system*|prune|info|version|context|login) _g=sys ;;
            *) _g="" ;;
        esac
        if [ -n "$_g" ]; then
            dockerman_cheat "$_g"
        else
            printf "${YELLOW}Pas de fiche dediee.${RESET} Recherche brute :\n\n"
            dockerman_search "$_c"
        fi
        if _dockerman_has_docker; then
            printf "\n%sAide native docker:%s\n" "$BOLD" "$RESET"
            docker "$_c" --help 2>/dev/null | head -n 18 || docker help "$_c" 2>/dev/null | head -n 18 || true
        fi
    }

    dockerman_doctor() {
        _dockerman_header "doctor"
        if _dockerman_has_docker; then
            printf "  ${GREEN}OK${RESET}  docker -> %s\n" "$(command -v docker)"
        else
            printf "  ${YELLOW}--${RESET}  docker absent\n"
            printf "       installman docker   ou  make install-docker\n"
        fi
        if command -v docker-compose >/dev/null 2>&1; then
            printf "  ${GREEN}OK${RESET}  docker-compose (v1) -> %s\n" "$(command -v docker-compose)"
        else
            printf "  ${YELLOW}--${RESET}  docker-compose v1 (optionnel, preferer plugin v2)\n"
        fi
        if _dockerman_has_docker && docker compose version >/dev/null 2>&1; then
            printf "  ${GREEN}OK${RESET}  docker compose (plugin v2)\n"
            docker compose version 2>/dev/null | sed 's/^/       /'
        else
            printf "  ${YELLOW}--${RESET}  plugin « docker compose » indisponible\n"
        fi
        if [ -S /var/run/docker.sock ]; then
            printf "  ${GREEN}OK${RESET}  socket /var/run/docker.sock\n"
        else
            printf "  ${YELLOW}--${RESET}  socket /var/run/docker.sock absent (daemon eteint ?)\n"
        fi
        if _dockerman_has_docker; then
            if _dockerman_docker info >/dev/null 2>&1; then
                printf "  ${GREEN}OK${RESET}  daemon joignable\n"
                _dockerman_docker version --format '       client={{.Client.Version}} server={{.Server.Version}}' 2>/dev/null \
                    || _dockerman_docker version 2>/dev/null | head -n 6 | sed 's/^/       /'
            else
                printf "  ${YELLOW}--${RESET}  daemon injoignable (permissions groupe docker, ou service down)\n"
                printf "       sudo usermod -aG docker \"$USER\"  puis relog\n"
                printf "       sudo systemctl start docker\n"
            fi
        fi
        printf "\n  Prefixe tests dotfiles : ${BOLD}%s${RESET}\n" "$DOTFILES_PREFIX"
        printf "  Voir : dockerman prefix | sandbox | cheat sys\n"
        return 0
    }

    dockerman_status() {
        _dockerman_header "statut"
        if ! _dockerman_has_docker; then
            printf "${YELLOW}docker non installe${RESET}\n"
            dockerman_doctor
            return 0
        fi
        _dockerman_docker version 2>/dev/null | head -n 8 || true
        printf "\n"
        if _dockerman_docker info >/dev/null 2>&1; then
            printf "${BOLD}Conteneurs${RESET} (ps -a, 15 max) :\n"
            _dockerman_docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null | head -n 16 || true
            printf "\n${BOLD}Espace${RESET} :\n"
            _dockerman_docker system df 2>/dev/null || true
        else
            printf "${YELLOW}Daemon injoignable${RESET} — dockerman doctor\n"
        fi
        return 0
    }

    dockerman_ps() {
        _mode="${1:-}"
        _dockerman_header "conteneurs"
        case "$_mode" in
            all|-a|--all) _dockerman_docker ps -a ;;
            *) _dockerman_docker ps ;;
        esac
    }

    dockerman_images() {
        _dockerman_header "images"
        _dockerman_docker images
    }

    dockerman_networks() {
        _dockerman_header "reseaux"
        _dockerman_docker network ls
    }

    dockerman_volumes() {
        _dockerman_header "volumes"
        _dockerman_docker volume ls
    }

    dockerman_df() {
        _dockerman_header "espace Docker"
        _dockerman_docker system df -v 2>/dev/null || _dockerman_docker system df
    }

    dockerman_stats() {
        _dockerman_header "stats (un coup)"
        _dockerman_docker stats --no-stream
    }

    dockerman_logs() {
        _id="${1:-}"
        _n="${2:-100}"
        if [ -z "$_id" ]; then
            printf "${RED}Usage:${RESET} dockerman logs <conteneur> [lignes]\n" >&2
            return 1
        fi
        _dockerman_header "logs $_id (tail $_n)"
        _dockerman_docker logs --tail "$_n" "$_id"
    }

    dockerman_inspect() {
        _id="${1:-}"
        if [ -z "$_id" ]; then
            printf "${RED}Usage:${RESET} dockerman inspect <id|nom>\n" >&2
            return 1
        fi
        _dockerman_header "inspect $_id"
        _dockerman_docker inspect "$_id" | head -n 80
    }

    dockerman_compose() {
        _sub="${1:-ps}"
        _file=""
        for _c in \
            "${DOTFILES_DIR}/docker-compose.yml" \
            "${DOTFILES_DIR}/docker/docker-compose.yml" \
            "${DOTFILES_DIR}/scripts/test/docker/docker-compose.yml" \
            "./docker-compose.yml"
        do
            if [ -f "$_c" ]; then
                _file="$_c"
                break
            fi
        done
        case "$_sub" in
            file|which)
                printf "Compose detecte : %s\n" "${_file:-aucun}"
                return 0
                ;;
            ls)
                _dockerman_header "compose ls"
                _dockerman_docker compose ls
                return $?
                ;;
            config)
                _dockerman_header "compose config"
                if [ -n "$_file" ]; then
                    _dockerman_docker compose -f "$_file" config
                else
                    _dockerman_docker compose config
                fi
                return $?
                ;;
            ps|"")
                _dockerman_header "compose ps"
                if [ -n "$_file" ]; then
                    printf "(fichier %s)\n" "$_file"
                    _dockerman_docker compose -f "$_file" ps -a
                else
                    _dockerman_docker compose ps -a
                fi
                return $?
                ;;
            *)
                printf "${RED}Sous-commande compose inconnue:${RESET} %s\n" "$_sub" >&2
                printf "Usage: dockerman compose [ps|ls|config|file]\n" >&2
                printf "Destructif (up/down) : voir dockerman cheat compose — pas enveloppe ici.\n" >&2
                return 1
                ;;
        esac
    }

    dockerman_prefix() {
        _dockerman_header "prefixe $DOTFILES_PREFIX"
        if ! _dockerman_has_docker; then
            printf "docker absent\n"
            return 0
        fi
        printf "${BOLD}Conteneurs${RESET} :\n"
        _dockerman_docker ps -a --filter "name=${DOTFILES_PREFIX}" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null || true
        printf "\n${BOLD}Images${RESET} :\n"
        _dockerman_docker images --filter "reference=${DOTFILES_PREFIX}*" --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}' 2>/dev/null || true
        printf "\nNettoyage cible : bash test-docker.sh --clean\n"
        printf "Bac a sable     : make docker-in\n"
    }

    dockerman_sandbox() {
        _dockerman_header "sandbox tests (sans polluer l'hote)"
        cat <<EOF
Commandes Make / scripts (prefexe ${DOTFILES_PREFIX}) :

  make docker-in                 bac distro x shell
  make test                      CI managers + matrice
  make tests                     menu tests
  bash test-docker.sh --help     CLI image de test (aucune interaction)
  bash test-docker.sh --yes      build+run non interactif
  make sandbox-guide             scripts/test/SANDBOX.md

Voir aussi : docs/guides/DOCKER.md · dockerman prefix · virtman
EOF
    }

    dockerman_version() {
        _dockerman_header "version"
        _dockerman_docker version
    }

    dockerman_context() {
        _dockerman_header "contextes"
        _dockerman_docker context ls
    }

    dockerman_prune() {
        _mode="dry"
        _yes=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --dry-run|--dry) _mode="dry" ;;
                --apply|--force) _mode="apply" ;;
                --yes|-y) _yes=1 ;;
                *)
                    printf "${RED}Option prune inconnue:${RESET} %s\n" "$1" >&2
                    return 1
                    ;;
            esac
            shift
        done
        if [ "$_mode" = "dry" ]; then
            _dockerman_header "prune (dry-run — rien n'est supprime)"
            if ! _dockerman_has_docker; then
                printf "docker absent — rien a lister\n"
                return 0
            fi
            printf "${BOLD}Conteneurs arretes${RESET} :\n"
            _dockerman_docker ps -a --filter status=exited --format '  {{.Names}}\t{{.Status}}\t{{.Image}}' 2>/dev/null || true
            printf "\n${BOLD}Images dangling${RESET} :\n"
            _dockerman_docker images -f dangling=true --format '  {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' 2>/dev/null || true
            printf "\n${BOLD}Espace actuel${RESET} :\n"
            _dockerman_docker system df 2>/dev/null || true
            printf "\n${YELLOW}Pour appliquer:${RESET} dockerman prune --apply   (TTY + confirmation)\n"
            printf "Cible prefixe tests : bash test-docker.sh --clean\n"
            return 0
        fi
        if [ ! -t 0 ] || [ ! -t 1 ]; then
            if [ "$_yes" -ne 1 ]; then
                printf "${RED}prune --apply refuse hors TTY sans --yes${RESET}\n" >&2
                return 2
            fi
        else
            printf "${YELLOW}Cela lance : docker system prune${RESET} (conteneurs arretes, reseaux, dangling).\n"
            printf "Pas de -a / --volumes ici (trop destructif). Confirmer : OUI\n"
            printf "> "
            read _ans || _ans=""
            if [ "$_ans" != "OUI" ]; then
                printf "Annule.\n"
                return 0
            fi
        fi
        _dockerman_header "prune apply"
        docker system prune -f
    }

    dockerman_cmd() {
        _run=0
        while [ $# -gt 0 ]; do
            case "$1" in
                --run) _run=1; shift ;;
                --) shift; break ;;
                docker)
                    break
                    ;;
                *)
                    break
                    ;;
            esac
        done
        if [ $# -eq 0 ]; then
            printf "${RED}Usage:${RESET} dockerman cmd [--run] -- docker <args>\n" >&2
            printf "Sans --run : affiche seulement. Avec --run : execute (toi qui choisis).\n" >&2
            return 1
        fi
        if [ "$1" = docker ]; then
            :
        else
            set -- docker "$@"
        fi
        printf "${CYAN}commande:${RESET} "
        printf '%s ' "$@"
        printf "\n"
        if [ "$_run" -ne 1 ]; then
            printf "${YELLOW}(non execute — ajoute --run pour lancer)${RESET}\n"
            return 0
        fi
        "$@"
    }

    dockerman_menu() {
        if [ ! -t 0 ] || [ ! -t 1 ]; then
            dockerman_print_help
            return 0
        fi
        while true; do
            _dockerman_header "menu"
            printf "1) Doctor / daemon\n"
            printf "2) Statut (ps + df)\n"
            printf "3) Conteneurs (ps -a)\n"
            printf "4) Images\n"
            printf "5) Aide-memoire complet\n"
            printf "6) Prefixe tests (%s)\n" "$DOTFILES_PREFIX"
            printf "7) Prune dry-run\n"
            printf "8) Sandbox make docker-in\n"
            printf "0) Quitter\n"
            printf "Choix: "
            read -r choice || return 0
            if command -v manager_ui_is_quit_choice >/dev/null 2>&1; then
                manager_ui_is_quit_choice "$choice" && return 0
            fi
            case "$choice" in
                1) dockerman_doctor; _dockerman_pause ;;
                2) dockerman_status; _dockerman_pause ;;
                3) dockerman_ps all; _dockerman_pause ;;
                4) dockerman_images; _dockerman_pause ;;
                5) dockerman_cheat all; _dockerman_pause ;;
                6) dockerman_prefix; _dockerman_pause ;;
                7) dockerman_prune --dry-run; _dockerman_pause ;;
                8) dockerman_sandbox; _dockerman_pause ;;
                0|q|quit|exit) return 0 ;;
                *) printf "%sChoix invalide.%s\n" "$RED" "$RESET" ;;
            esac
        done
    }

    cmd="${1:-help}"
    case "$cmd" in
        help|-h|aide)
            if [ "${2:-}" = "--interactive" ] || [ "${2:-}" = "-i" ]; then
                dockerman_print_help
                _dockerman_pause
            else
                dockerman_print_help
            fi
            ;;
        --help)
            dockerman_print_help
            _dockerman_pause
            ;;
        menu) dockerman_menu ;;
        status|st) dockerman_status ;;
        doctor|diag) dockerman_doctor ;;
        version) dockerman_version ;;
        context|contexts) dockerman_context ;;
        ps|containers)
            shift
            dockerman_ps "$@"
            ;;
        images|image) dockerman_images ;;
        networks|network|net) dockerman_networks ;;
        volumes|volume|vol) dockerman_volumes ;;
        df) dockerman_df ;;
        stats) dockerman_stats ;;
        logs)
            shift
            dockerman_logs "$@"
            ;;
        inspect)
            shift
            dockerman_inspect "$@"
            ;;
        compose)
            shift
            dockerman_compose "$@"
            ;;
        prefix|dotfiles-test) dockerman_prefix ;;
        sandbox|howto-test) dockerman_sandbox ;;
        cheat|cheatsheet|cmds|commands)
            shift
            dockerman_cheat "${1:-all}"
            ;;
        search|find|grep)
            shift
            dockerman_search "$@"
            ;;
        explain|how|howto)
            shift
            dockerman_explain "$@"
            ;;
        prune|clean)
            shift
            dockerman_prune "$@"
            ;;
        cmd|run-cmd)
            shift
            dockerman_cmd "$@"
            ;;
        "")
            dockerman_print_help
            ;;
        *)
            printf "${RED}Commande inconnue:${RESET} %s\n\n" "$cmd" >&2
            dockerman_print_help
            return 1
            ;;
    esac
}
