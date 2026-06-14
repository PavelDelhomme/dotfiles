#!/bin/sh
# =============================================================================
# DISKMAN — analyse et nettoyage disque (core POSIX)
# =============================================================================
# Convention : aide / CLI alignée Bloc G de docs/TESTS.md.
# =============================================================================

# DESC: Gestionnaire disque : usage, gros fichiers, inodes, nettoyage prudent.
# USAGE: diskman [commande] [args]

# Helpers au niveau fichier (évite les sous-fonctions zsh et les erreurs « diskman_print_help:1 »).
_diskman_safe_out() {
    if ! printf '%s\n' "$@" 2>/dev/null; then
        printf '%s\n' "$@" >&2 2>/dev/null || true
    fi
}

_diskman_status_compact() {
    _diskman_safe_out "État disque (df -hT) :"
    for _dm_mp in / "${HOME:-/home}" /data "$(pwd -P 2>/dev/null || pwd)"; do
        [ -e "$_dm_mp" ] || continue
        df -hT "$_dm_mp" 2>/dev/null | awk 'NR==1 {next} {print "  " $0}'
    done
    _diskman_safe_out ""
}

diskman_print_help() {
    _diskman_status_compact
    _diskman_safe_out "DISKMAN — diagnostic et nettoyage disque prudent"
    _diskman_safe_out ""
    _diskman_safe_out "Interface :"
    _diskman_safe_out "  diskman                           état + aide"
    _diskman_safe_out "  diskman help | -h | aide          idem"
    _diskman_safe_out "  diskman help --interactive        aide + pause (TTY)"
    _diskman_safe_out "  diskman --help                    idem (documentation, pas de menu)"
    _diskman_safe_out "  diskman menu                      menu interactif (TTY)"
    _diskman_safe_out ""
    _diskman_safe_out "Commandes :"
    _diskman_safe_out "  diskman overview                  vue df/lsblk + caches"
    _diskman_safe_out "  diskman analyze [PATH] [DEPTH]    analyse guidée"
    _diskman_safe_out "  diskman recommend [PATH]          plan de nettoyage (dry-run)"
    _diskman_safe_out "  diskman relocate candidates       candidats HOME -> /data"
    _diskman_safe_out "  diskman relocate --dry-run PATH   planifier déplacement"
    _diskman_safe_out "  diskman relocate --apply PATH     déplacer + symlink"
    _diskman_safe_out "  diskman archives [PATH] [DEPTH]   archives avec dossier extrait"
    _diskman_safe_out "  diskman archives clean [--dry-run|--apply] [PATH]"
    _diskman_safe_out "  diskman duplicates [PATH] [MIN_MB]"
    _diskman_safe_out "  diskman compress-candidates [PATH]"
    _diskman_safe_out "  diskman usage [PATH] [DEPTH]      dossiers lourds"
    _diskman_safe_out "  diskman biggest [PATH] [N]        plus gros fichiers"
    _diskman_safe_out "  diskman inodes [PATH]"
    _diskman_safe_out "  diskman mounts | health"
    _diskman_safe_out "  diskman clean [--dry-run|--apply] [target]"
    _diskman_safe_out "  diskman report [OUT]"
    _diskman_safe_out ""
    _diskman_safe_out "Exemples : diskman overview | analyze /data 2 | archives /data/jeux 2"
}

diskman() {
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; RESET=''
    if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
        RED=$(printf '\033[0;31m')
        GREEN=$(printf '\033[0;32m')
        YELLOW=$(printf '\033[1;33m')
        CYAN=$(printf '\033[0;36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read -r _diskman_dummy || true
        fi
    }

    diskman_header() {
        printf "%s%sDISKMAN%s — %s\n" "$CYAN" "$BOLD" "$RESET" "$1"
        printf "%s\n" "────────────────────────────────────────────────────────────"
    }

    diskman_human_path_size() {
        _dm_path="$1"
        if [ -e "$_dm_path" ]; then
            du -sh "$_dm_path" 2>/dev/null | awk '{print $1}'
        else
            printf "absent"
        fi
    }

    diskman_basename() {
        _dm_b="${1%/}"
        _dm_b="${_dm_b##*/}"
        printf '%s\n' "$_dm_b"
    }

    diskman_dirname() {
        _dm_d="${1%/}"
        case "$_dm_d" in
            */*) printf '%s\n' "${_dm_d%/*}" ;;
            *) printf '.\n' ;;
        esac
    }

    diskman_cmd_overview() {
        diskman_header "vue d'ensemble"
        printf "%sSystèmes de fichiers:%s\n" "$BOLD" "$RESET"
        df -hT 2>/dev/null | awk 'NR==1 || $0 ~ /^\/dev\// {print}'
        printf "\n%sDisques / partitions:%s\n" "$BOLD" "$RESET"
        if command -v lsblk >/dev/null 2>&1; then
            lsblk -o NAME,SIZE,TYPE,FSTYPE,FSUSED,FSAVAIL,FSUSE%,MOUNTPOINTS 2>/dev/null || lsblk
        else
            printf "lsblk indisponible\n"
        fi
        printf "\n%sPoints à surveiller:%s\n" "$BOLD" "$RESET"
        printf "  ~/.cache        %s\n" "$(diskman_human_path_size "$HOME/.cache")"
        printf "  ~/.local/share/Trash %s\n" "$(diskman_human_path_size "$HOME/.local/share/Trash")"
        printf "  /tmp            %s\n" "$(diskman_human_path_size /tmp)"
        if command -v docker >/dev/null 2>&1; then
            printf "\n%sDocker:%s\n" "$BOLD" "$RESET"
            if command -v timeout >/dev/null 2>&1; then
                timeout 3 docker system df 2>/dev/null || printf "  docker non accessible ou trop lent (daemon/permissions)\n"
            else
                docker system df 2>/dev/null || printf "  docker non accessible (daemon/permissions)\n"
            fi
        fi
        return 0
    }

    diskman_usage_block() {
        _dm_label="$1"
        _dm_path="$2"
        _dm_depth="${3:-1}"
        printf "\n%s%s%s\n" "$BOLD" "$_dm_label" "$RESET"
        if [ -e "$_dm_path" ]; then
            diskman_cmd_usage "$_dm_path" "$_dm_depth" | sed '1,2d'
        else
            printf "  absent: %s\n" "$_dm_path"
        fi
    }

    diskman_cmd_analyze() {
        _dm_path="${1:-/}"
        _dm_depth="${2:-1}"
        case "$_dm_depth" in ''|*[!0-9]*) _dm_depth=1 ;; esac
        diskman_header "analyse espace: $_dm_path"
        printf "%sRésumé:%s\n" "$BOLD" "$RESET"
        df -hT "$_dm_path" 2>/dev/null || df -h "$_dm_path" 2>/dev/null || true
        printf "\n%sGros points locaux:%s\n" "$BOLD" "$RESET"
        printf "  HOME cache            %s\n" "$(diskman_human_path_size "$HOME/.cache")"
        printf "  HOME trash            %s\n" "$(diskman_human_path_size "$HOME/.local/share/Trash")"
        printf "  /tmp                  %s\n" "$(diskman_human_path_size /tmp)"
        printf "  pacman cache          %s\n" "$(diskman_human_path_size /var/cache/pacman/pkg)"
        if command -v journalctl >/dev/null 2>&1; then
            printf "  journal systemd       "
            journalctl --disk-usage 2>/dev/null | sed 's/^/ /' || printf "non accessible\n"
        fi

        diskman_usage_block "Top dossiers: $_dm_path (depth=$_dm_depth)" "$_dm_path" "$_dm_depth"
        [ "$_dm_path" = "/" ] || diskman_usage_block "Top dossiers: / (depth=1)" "/" 1
        diskman_usage_block "Top dossiers: /var (depth=1)" /var 1
        diskman_usage_block "Top dossiers: $HOME (depth=1)" "$HOME" 1
        diskman_usage_block "Top cache utilisateur (depth=1)" "$HOME/.cache" 1

        printf "\n%sNettoyages possibles (dry-run):%s\n" "$BOLD" "$RESET"
        diskman_cmd_clean --dry-run all

        printf "\n%sConseil:%s commence par les commandes non destructives suivantes:\n" "$BOLD" "$RESET"
        printf "  diskman usage / 1\n"
        printf "  diskman usage /var 1\n"
        printf "  diskman biggest / 30\n"
        printf "  diskman clean --dry-run all\n"
        printf "  sudo diskman clean --dry-run all   # si shims root installés\n"
    }

    diskman_cmd_recommend() {
        _dm_path="${1:-/}"
        diskman_header "plan de nettoyage recommandé"
        printf "1. Voir ce qui prend la place:\n"
        printf "   diskman analyze %s 1\n" "$_dm_path"
        printf "   diskman usage /var 1\n"
        printf "   diskman usage ~/.cache 1\n"
        printf "\n2. Nettoyages généralement sûrs (dry-run d'abord):\n"
        printf "   diskman clean --dry-run user-cache\n"
        printf "   diskman clean --dry-run trash\n"
        printf "   sudo diskman clean --dry-run tmp\n"
        printf "   sudo diskman clean --dry-run journal\n"
        printf "   sudo diskman clean --dry-run pacman\n"
        printf "   sudo diskman clean --dry-run snap\n"
        printf "\n3. Appliquer par petites étapes après lecture:\n"
        printf "   diskman clean --apply trash\n"
        printf "   diskman clean --apply user-cache\n"
        printf "   sudo diskman clean --apply journal\n"
        printf "   sudo diskman clean --apply pacman\n"
        printf "\nNotes:\n"
        printf "  - user-cache exclut les dossiers *cursor* pour éviter de casser Cursor.\n"
        printf "  - docker peut libérer beaucoup mais supprime images/conteneurs inutilisés.\n"
        printf "  - snap supprime seulement les révisions désactivées.\n"
    }

    diskman_relocate_is_protected() {
        _dm_path="$1"
        case "$_dm_path" in
            "$HOME"|"$HOME/"|"/"|""|\
            "$HOME/.ssh"|"$HOME/.ssh/"*|\
            "$HOME/.gnupg"|"$HOME/.gnupg/"*|\
            "$HOME/.config"|"$HOME/.config/"*|\
            "$HOME/.local/share/keyrings"|"$HOME/.local/share/keyrings/"*|\
            "$HOME/dotfiles"|"$HOME/dotfiles/"*|\
            "$HOME/.zshrc"|"$HOME/.bashrc"|"$HOME/.profile"|"$HOME/.p10k.zsh")
                return 0
                ;;
        esac
        case "$_dm_path" in
            *[Cc]ursor*|*[Cc]ursor*/*)
                return 0
                ;;
        esac
        return 1
    }

    diskman_relocate_dest_for() {
        _dm_path="$1"
        _dm_data_root="${2:-/data}"
        _dm_user="${SUDO_USER:-$(id -un 2>/dev/null || printf user)}"
        case "$_dm_path" in
            "$HOME"/*) _dm_rel=${_dm_path#"$HOME"/} ;;
            *) _dm_rel=$(diskman_basename "$_dm_path") ;;
        esac
        printf '%s/%s/home-relocated/%s\n' "$_dm_data_root" "$_dm_user" "$_dm_rel"
    }

    diskman_relocate_show_candidate() {
        _dm_path="$1"
        _dm_data_root="${2:-/data}"
        [ -e "$_dm_path" ] || return 0
        [ -L "$_dm_path" ] && return 0
        diskman_relocate_is_protected "$_dm_path" && return 0
        _dm_size=$(diskman_human_path_size "$_dm_path")
        _dm_dest=$(diskman_relocate_dest_for "$_dm_path" "$_dm_data_root")
        printf "%8s  %-42s -> %s\n" "$_dm_size" "$_dm_path" "$_dm_dest"
    }

    diskman_cmd_relocate_candidates() {
        _dm_home="${1:-$HOME}"
        _dm_data_root="${2:-/data}"
        diskman_header "candidats déplacement HOME -> $_dm_data_root"

        if [ ! -d "$_dm_data_root" ]; then
            printf "%sAttention:%s %s n'existe pas ou n'est pas monté.\n\n" "$YELLOW" "$RESET" "$_dm_data_root"
        fi

        printf "%sCandidats connus:%s\n" "$BOLD" "$RESET"
        for p in \
            "$_dm_home/Downloads" \
            "$_dm_home/Téléchargements" \
            "$_dm_home/Videos" \
            "$_dm_home/Vidéos" \
            "$_dm_home/Music" \
            "$_dm_home/Musique" \
            "$_dm_home/Pictures" \
            "$_dm_home/Images" \
            "$_dm_home/Games" \
            "$_dm_home/Jeux" \
            "$_dm_home/VirtualBox VMs" \
            "$_dm_home/VMs" \
            "$_dm_home/ISO" \
            "$_dm_home/ISOs" \
            "$_dm_home/.local/share/Steam" \
            "$_dm_home/.local/share/containers" \
            "$_dm_home/.var/app" \
            "$_dm_home/.npm" \
            "$_dm_home/.cargo" \
            "$_dm_home/.gradle" \
            "$_dm_home/.m2" \
            "$_dm_home/.cache/yay"; do
            diskman_relocate_show_candidate "$p" "$_dm_data_root"
        done

        printf "\n%sTop HOME actuel (exclus: chemins sensibles/Cursor/symlinks):%s\n" "$BOLD" "$RESET"
        find "$_dm_home" -mindepth 1 -maxdepth 1 -exec du -sh {} + 2>/dev/null \
            | sort -hr \
            | while IFS="$(printf '\t')" read -r size path; do
                [ -n "$path" ] || continue
                [ -L "$path" ] && continue
                diskman_relocate_is_protected "$path" && continue
                dest=$(diskman_relocate_dest_for "$path" "$_dm_data_root")
                printf "%8s  %-42s -> %s\n" "$size" "$path" "$dest"
            done | head -30

        printf "\n%sPlanifier sans déplacer:%s diskman relocate --dry-run PATH %s\n" "$YELLOW" "$RESET" "$_dm_data_root"
        printf "%sAppliquer après vérification:%s diskman relocate --apply PATH %s\n" "$YELLOW" "$RESET" "$_dm_data_root"
    }

    diskman_cmd_relocate_path() {
        _dm_apply=0
        _dm_yes=0
        _dm_path=""
        _dm_data_root="/data"
        while [ $# -gt 0 ]; do
            case "$1" in
                candidates|candidate|list)
                    shift
                    diskman_cmd_relocate_candidates "${1:-$HOME}" "${2:-/data}"
                    return $?
                    ;;
                --dry-run) _dm_apply=0; shift ;;
                --apply) _dm_apply=1; shift ;;
                --yes|-y) _dm_yes=1; shift ;;
                --data-root)
                    shift
                    _dm_data_root="${1:-/data}"
                    shift || true
                    ;;
                *)
                    if [ -z "$_dm_path" ]; then
                        _dm_path="$1"
                    else
                        _dm_data_root="$1"
                    fi
                    shift
                    ;;
            esac
        done

        [ -n "$_dm_path" ] || { printf "Usage: diskman relocate --dry-run PATH [/data]\n" >&2; return 2; }
        case "$_dm_path" in "~"*) _dm_path="$HOME${_dm_path#\~}" ;; esac
        _dm_parent=$(diskman_dirname "$_dm_path")
        _dm_base=$(diskman_basename "$_dm_path")
        _dm_path=$(cd "$_dm_parent" 2>/dev/null && pwd -P)/$_dm_base || return 1
        _dm_dest=$(diskman_relocate_dest_for "$_dm_path" "$_dm_data_root")

        diskman_header "déplacement vers /data avec symlink"
        printf "Source:      %s\n" "$_dm_path"
        printf "Destination: %s\n" "$_dm_dest"
        printf "Mode:        %s\n\n" "$( [ "$_dm_apply" -eq 1 ] && printf apply || printf dry-run )"

        [ -e "$_dm_path" ] || { printf "%sSource absente.%s\n" "$RED" "$RESET" >&2; return 1; }
        [ -L "$_dm_path" ] && { printf "%sRefus:%s source déjà symlink.\n" "$RED" "$RESET" >&2; return 2; }
        diskman_relocate_is_protected "$_dm_path" && {
            printf "%sRefus:%s chemin protégé ou sensible (config, secrets, Cursor, dotfiles).\n" "$RED" "$RESET" >&2
            return 2
        }
        case "$_dm_path" in "$HOME"/*) ;; *) printf "%sRefus:%s seul un chemin sous HOME est accepté.\n" "$RED" "$RESET" >&2; return 2 ;; esac

        printf "Taille source: %s\n" "$(diskman_human_path_size "$_dm_path")"
        if [ -e "$_dm_dest" ]; then
            printf "%sRefus:%s destination existe déjà: %s\n" "$RED" "$RESET" "$_dm_dest" >&2
            return 2
        fi

        if [ "$_dm_apply" -ne 1 ]; then
            printf "\nDry-run. Commandes prévues:\n"
            printf "  mkdir -p %s\n" "$(diskman_dirname "$_dm_dest")"
            printf "  mv %s %s\n" "$_dm_path" "$_dm_dest"
            printf "  ln -s %s %s\n" "$_dm_dest" "$_dm_path"
            return 0
        fi

        if [ "$_dm_yes" -ne 1 ] && [ -t 0 ] && [ -t 1 ]; then
            printf "%sConfirmer déplacement + symlink ? [y/N] %s" "$RED" "$RESET"
            read -r ans || ans=n
            case "$ans" in [yY]|[oO]) ;; *) printf "Annulé.\n"; return 0 ;; esac
        elif [ "$_dm_yes" -ne 1 ]; then
            printf "%sRefus non-TTY sans --yes.%s\n" "$RED" "$RESET" >&2
            return 2
        fi

        mkdir -p "$(diskman_dirname "$_dm_dest")" || return 1
        mv "$_dm_path" "$_dm_dest" || return 1
        ln -s "$_dm_dest" "$_dm_path" || {
            printf "%sErreur symlink:%s restauration manuelle possible depuis %s\n" "$RED" "$RESET" "$_dm_dest" >&2
            return 1
        }
        printf "%sOK:%s %s -> %s\n" "$GREEN" "$RESET" "$_dm_path" "$_dm_dest"
    }

    diskman_cmd_duplicates() {
        _dm_path="${1:-/data}"
        _dm_min_mb="${2:-512}"
        case "$_dm_min_mb" in ''|*[!0-9]*) _dm_min_mb=512 ;; esac
        diskman_header "doublons probables: $_dm_path (min ${_dm_min_mb}M)"
        if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
            printf "python/python3 requis pour cette analyse.\n" >&2
            return 1
        fi
        _dm_py=python
        command -v python >/dev/null 2>&1 || _dm_py=python3
        "$_dm_py" - "$_dm_path" "$_dm_min_mb" <<'PY'
import os, sys
from collections import defaultdict
root=sys.argv[1]
min_size=int(sys.argv[2])*1024*1024
by_name_size=defaultdict(list)
by_size=defaultdict(list)
errors=0
for dirpath, dirnames, filenames in os.walk(root):
    for fn in filenames:
        p=os.path.join(dirpath, fn)
        try:
            st=os.stat(p, follow_symlinks=False)
        except OSError:
            errors += 1
            continue
        if st.st_size >= min_size:
            by_name_size[(fn.lower(), st.st_size)].append(p)
            by_size[st.st_size].append(p)

print("Même nom + même taille (à hasher avant suppression):")
shown=0
upper=0
for (name,size),paths in sorted(by_name_size.items(), key=lambda kv: kv[0][1], reverse=True):
    if len(paths) > 1:
        shown += 1
        upper += size*(len(paths)-1)
        print(f"\n{size/1024**3:.2f}G x{len(paths)} {name}")
        for p in paths[:10]:
            print("  " + p)
        if shown >= 80:
            break
print(f"\nGain maximal théorique nom+taille: {upper/1024**3:.1f}G")

print("\nMême taille >=10G (suspect, pas forcément doublon):")
shown=0
for size,paths in sorted(by_size.items(), reverse=True):
    if len(paths) > 1 and size >= 10*1024**3:
        shown += 1
        print(f"\n{size/1024**3:.2f}G x{len(paths)}")
        for p in paths[:10]:
            print("  " + p)
        if shown >= 30:
            break
print(f"\nErreurs lecture: {errors}")
PY
    }

    diskman_cmd_compress_candidates() {
        _dm_path="${1:-/data}"
        diskman_header "candidats compression: $_dm_path"
        if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
            printf "python/python3 requis pour cette analyse.\n" >&2
            return 1
        fi
        _dm_py=python
        command -v python >/dev/null 2>&1 || _dm_py=python3
        "$_dm_py" - "$_dm_path" <<'PY'
import os, sys
from collections import defaultdict
root=sys.argv[1]
already={'.zip','.zst','.xz','.gz','.tgz','.rar','.7z','.pak','.ucas','.iso','.jpg','.jpeg','.png','.mp4','.mkv','.webm','.ogg','.mp3','.flac'}
maybe={'.log','.txt','.csv','.json','.xml','.sql','.qcow2','.img','.raw','.vdi','.vmdk'}
stats=defaultdict(lambda:[0,0])
large=[]
for dirpath, dirnames, filenames in os.walk(root):
    for fn in filenames:
        p=os.path.join(dirpath, fn)
        try:
            s=os.path.getsize(p)
        except OSError:
            continue
        ext=os.path.splitext(fn.lower())[1] or '<noext>'
        stats[ext][0]+=s; stats[ext][1]+=1
        if s >= 1024**3 and (ext in maybe or ext not in already):
            large.append((s,p,ext))
print("Top extensions par taille:")
for ext,(total,count) in sorted(stats.items(), key=lambda kv: kv[1][0], reverse=True)[:30]:
    tag='déjà compressé' if ext in already else ('compressible possible' if ext in maybe else 'à vérifier')
    print(f"{total/1024**3:8.1f}G {count:7d} {ext:10s} {tag}")
print("\nGros fichiers potentiellement compressibles (à vérifier manuellement):")
for s,p,ext in sorted(large, reverse=True)[:50]:
    print(f"{s/1024**3:8.2f}G {p}")
print("\nNotes:")
print("  - Les jeux (.pak/.ucas/.dat) et médias sont souvent déjà compressés: faible gain.")
print("  - Pour .qcow2: préférer qemu-img convert -c vers un nouveau fichier, jamais in-place.")
print("  - Ne compresse pas automatiquement les dossiers utilisés par applications/jeux.")
PY
    }

    diskman_cmd_archives() {
        _dm_sub="${1:-}"
        case "$_dm_sub" in
            clean|nettoyer|remove)
                shift
                diskman_cmd_archives_clean "$@"
                return $?
                ;;
        esac
        _dm_path="${1:-.}"
        _dm_depth="${2:-3}"
        case "$_dm_depth" in ''|*[!0-9]*) _dm_depth=3 ;; esac
        diskman_header "archives déjà extraites: $_dm_path (depth=$_dm_depth)"
        if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
            printf "python/python3 requis pour cette analyse.\n" >&2
            return 1
        fi
        _dm_py=python
        command -v python >/dev/null 2>&1 || _dm_py=python3
        "$_dm_py" - "$_dm_path" "$_dm_depth" <<'PY'
import os, re, subprocess, sys

root, maxdepth = sys.argv[1], int(sys.argv[2])
root = os.path.abspath(root)
SUFFIXES = [
    '.tar.gz', '.tar.xz', '.tar.bz2', '.tar.zst', '.tar.lzma',
    '.tgz', '.txz', '.tbz2', '.zip', '.7z', '.rar', '.zst', '.iso',
]

def compact(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

def archive_stem(name):
    low = name.lower()
    for suf in sorted(SUFFIXES, key=len, reverse=True):
        if low.endswith(suf):
            return name[:-len(suf)].rstrip(' .-_')
    return None

def human(n):
    for u in ('B', 'K', 'M', 'G', 'T'):
        if n < 1024 or u == 'T':
            return f"{n:.1f}{u}" if u != 'B' else f"{int(n)}B"
        n /= 1024

def dir_size(path):
    try:
        out = subprocess.check_output(['du', '-sb', path], stderr=subprocess.DEVNULL, text=True)
        return int(out.split()[0])
    except Exception:
        return 0

def name_matches(stem, dirname):
    a, d = compact(stem), compact(dirname)
    if len(d) < 3:
        return False
    if a == d or a.startswith(d) or d.startswith(a):
        return True
    if d in a or a in d:
        return True
    return False

def best_dir_match(stem, parent):
    best = None
    try:
        entries = os.listdir(parent)
    except OSError:
        return None
    for ent in entries:
        ep = os.path.join(parent, ent)
        if not os.path.isdir(ep):
            continue
        if name_matches(stem, ent):
            score = len(compact(ent))
            if best is None or score > best[0]:
                best = (score, ent, ep)
    return best[1:] if best else None

rows = []
for dirpath, dirnames, filenames in os.walk(root):
    rel = os.path.relpath(dirpath, root)
    depth = 0 if rel == '.' else rel.count(os.sep) + 1
    if depth >= maxdepth:
        dirnames[:] = []
    for fn in filenames:
        stem = archive_stem(fn)
        if stem is None:
            continue
        ap = os.path.join(dirpath, fn)
        try:
            asz = os.path.getsize(ap)
        except OSError:
            continue
        if asz < 5 * 1024**2:
            continue
        match = best_dir_match(stem, dirpath)
        if not match:
            continue
        dname, dp = match
        dsz = dir_size(dp)
        if dsz < 10 * 1024**2:
            continue
        conf = 'forte' if compact(stem) == compact(dname) or compact(dname) in compact(stem) else 'probable'
        rows.append((asz, dsz, conf, ap, dp, dname))

rows.sort(reverse=True)
if not rows:
    print("Aucune paire archive + dossier extrait détectée.")
    print("Astuce: augmenter DEPTH ou vérifier manuellement avec diskman biggest PATH")
    sys.exit(0)

total_arch = sum(r[0] for r in rows)
print(f"Paires trouvées: {len(rows)} — archives récupérables ~{human(total_arch)} (dossiers conservés)\n")
for asz, dsz, conf, ap, dp, dname in rows[:80]:
    print(f"[{conf}] archive {human(asz):>8}  dossier {human(dsz):>8}  {dname}")
    print(f"         archive: {ap}")
    print(f"         extrait: {dp}\n")
if len(rows) > 80:
    print(f"... et {len(rows)-80} autres paires")
print("Nettoyage prudent (supprime uniquement l'archive, jamais le dossier) :")
print(f"  diskman archives clean --dry-run {root}")
PY
    }

    diskman_cmd_archives_clean() {
        _apply=0
        _yes=0
        _dm_path="."
        _dm_depth=3
        while [ $# -gt 0 ]; do
            case "$1" in
                --dry-run) _apply=0; shift ;;
                --apply) _apply=1; shift ;;
                --yes|-y) _yes=1; shift ;;
                --depth)
                    shift
                    _dm_depth="${1:-3}"
                    shift
                    ;;
                *)
                    _dm_path="$1"
                    shift
                    ;;
            esac
        done
        case "$_dm_depth" in ''|*[!0-9]*) _dm_depth=3 ;; esac
        diskman_header "nettoyage archives extraites (${_dm_path})"
        if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
            printf "python/python3 requis.\n" >&2
            return 1
        fi
        _dm_py=python
        command -v python >/dev/null 2>&1 || _dm_py=python3
        _dm_tmp="${TMPDIR:-/tmp}/diskman-archives-$$.lst"
        "$_dm_py" - "$_dm_path" "$_dm_depth" "$_dm_tmp" <<'PY'
import os, re, subprocess, sys
root, maxdepth, outf = sys.argv[1], int(sys.argv[2]), sys.argv[3]
root = os.path.abspath(root)
SUFFIXES = ['.tar.gz','.tar.xz','.tar.bz2','.tar.zst','.tgz','.txz','.tbz2','.zip','.7z','.rar','.zst','.iso']
def compact(s): return re.sub(r'[^a-z0-9]', '', s.lower())
def archive_stem(name):
    low = name.lower()
    for suf in sorted(SUFFIXES, key=len, reverse=True):
        if low.endswith(suf): return name[:-len(suf)].rstrip(' .-_')
    return None
def name_matches(stem, dirname):
    a, d = compact(stem), compact(dirname)
    if len(d) < 3: return False
    return a == d or a.startswith(d) or d.startswith(a) or d in a or a in d
def dir_size(path):
    try: return int(subprocess.check_output(['du','-sb',path], stderr=subprocess.DEVNULL, text=True).split()[0])
    except Exception: return 0
def best_dir_match(stem, parent):
    best = None
    try: entries = os.listdir(parent)
    except OSError: return None
    for ent in entries:
        ep = os.path.join(parent, ent)
        if os.path.isdir(ep) and name_matches(stem, ent):
            score = len(compact(ent))
            if best is None or score > best[0]: best = (score, ent, ep)
    return best[1:] if best else None
lines = []
for dirpath, dirnames, filenames in os.walk(root):
    rel = os.path.relpath(dirpath, root)
    depth = 0 if rel == '.' else rel.count(os.sep) + 1
    if depth >= maxdepth: dirnames[:] = []
    for fn in filenames:
        stem = archive_stem(fn)
        if not stem: continue
        ap = os.path.join(dirpath, fn)
        try: asz = os.path.getsize(ap)
        except OSError: continue
        if asz < 5*1024**2: continue
        match = best_dir_match(stem, dirpath)
        if not match: continue
        dname, dp = match
        if dir_size(dp) < 10*1024**2: continue
        conf = 'forte' if compact(stem)==compact(dname) or compact(dname) in compact(stem) else 'probable'
        lines.append(f"{asz}|{conf}|{ap}|{dp}")
with open(outf, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
PY
        if [ ! -s "$_dm_tmp" ]; then
            rm -f "$_dm_tmp"
            printf "Aucune archive à supprimer (aucune paire archive+dossier trouvée).\n"
            return 0
        fi
        printf "%sMode:%s %s\n\n" "$BOLD" "$RESET" "$( [ "$_apply" -eq 1 ] && printf apply || printf dry-run )"
        while IFS='|' read -r _dm_asz _dm_conf _dm_arch _dm_dir; do
            [ -n "$_dm_arch" ] || continue
            [ -f "$_dm_arch" ] && [ -d "$_dm_dir" ] || continue
            printf "[%s] supprimer archive (%s o)\n  %s\n  conserve: %s\n\n" "$_dm_conf" "$_dm_asz" "$_dm_arch" "$_dm_dir"
        done < "$_dm_tmp"
        if [ "$_apply" -ne 1 ]; then
            printf "%sDry-run.%s Relancer: diskman archives clean --apply %s\n" "$YELLOW" "$RESET" "$_dm_path"
            printf "Les dossiers extraits ne sont jamais supprimés.\n"
            rm -f "$_dm_tmp"
            return 0
        fi
        if [ "$_yes" -ne 1 ] && [ -t 0 ] && [ -t 1 ]; then
            printf "\n%sConfirmer suppression des archives listées ? [y/N] %s" "$RED" "$RESET"
            read -r _dm_ans || _dm_ans=n
            case "$_dm_ans" in [yY]|[oO]) ;; *) printf "Annulé.\n"; rm -f "$_dm_tmp"; return 0 ;; esac
        elif [ "$_yes" -ne 1 ]; then
            printf "%sRefus non-TTY sans --yes.%s\n" "$RED" "$RESET" >&2
            rm -f "$_dm_tmp"
            return 2
        fi
        while IFS='|' read -r _dm_asz _dm_conf _dm_arch _dm_dir; do
            [ -f "$_dm_arch" ] && [ -d "$_dm_dir" ] || continue
            if rm -f -- "$_dm_arch" 2>/dev/null; then
                printf "%ssupprimé:%s %s\n" "$GREEN" "$RESET" "$_dm_arch"
            else
                printf "%séchec:%s %s\n" "$RED" "$RESET" "$_dm_arch" >&2
            fi
        done < "$_dm_tmp"
        rm -f "$_dm_tmp"
    }

    diskman_cmd_usage() {
        _dm_path="${1:-.}"
        _dm_depth="${2:-1}"
        case "$_dm_depth" in ''|*[!0-9]*) _dm_depth=1 ;; esac
        diskman_header "dossiers lourds: $_dm_path (depth=$_dm_depth)"
        if du -xhd "$_dm_depth" "$_dm_path" >/dev/null 2>&1; then
            du -xhd "$_dm_depth" "$_dm_path" 2>/dev/null | sort -hr | head -40
        else
            find "$_dm_path" -mindepth 1 -maxdepth 1 -exec du -sh {} + 2>/dev/null | sort -hr | head -40
        fi
    }

    diskman_cmd_biggest() {
        _dm_path="${1:-.}"
        _dm_n="${2:-20}"
        case "$_dm_n" in ''|*[!0-9]*) _dm_n=20 ;; esac
        diskman_header "plus gros fichiers: $_dm_path (top $_dm_n)"
        if command -v find >/dev/null 2>&1; then
            find "$_dm_path" -xdev -type f -printf '%s\t%p\n' 2>/dev/null \
                | sort -nr | head -n "$_dm_n" \
                | awk '{size=$1; $1=""; cmd="numfmt --to=iec --suffix=B " size; cmd | getline human; close(cmd); sub(/^[ \t]+/,""); printf "%8s  %s\n", human, $0}'
        else
            printf "find indisponible\n" >&2
            return 1
        fi
    }

    diskman_cmd_inodes() {
        _dm_path="${1:-.}"
        diskman_header "inodes"
        df -ih "$_dm_path" 2>/dev/null || df -i "$_dm_path"
        printf "\n%sDossiers avec beaucoup d'entrées (top 30):%s\n" "$BOLD" "$RESET"
        find "$_dm_path" -xdev -type d -printf '%p\n' 2>/dev/null \
            | while IFS= read -r d; do
                c=$(find "$d" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l)
                printf '%s\t%s\n' "$c" "$d"
            done | sort -nr | head -30
    }

    diskman_cmd_mounts() {
        diskman_header "montages"
        findmnt -o TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,USE%,OPTIONS 2>/dev/null || mount
    }

    diskman_cmd_health() {
        diskman_header "santé disque"
        if ! command -v smartctl >/dev/null 2>&1; then
            printf "%ssmartctl absent%s (Arch: sudo pacman -S smartmontools ; Debian: sudo apt install smartmontools)\n" "$YELLOW" "$RESET"
            return 0
        fi
        if command -v lsblk >/dev/null 2>&1; then
            for d in $(lsblk -dn -o NAME,TYPE 2>/dev/null | awk '$2=="disk"{print "/dev/"$1}'); do
                printf "\n%s%s%s\n" "$BOLD" "$d" "$RESET"
                sudo smartctl -H "$d" 2>/dev/null || smartctl -H "$d" 2>/dev/null || true
            done
        else
            printf "lsblk indisponible\n"
        fi
    }

    diskman_clean_show() {
        _target="$1"
        case "$_target" in
            pacman)
                printf "pacman cache: %s\n" "$(diskman_human_path_size /var/cache/pacman/pkg)"
                ;;
            apt)
                printf "apt cache: %s\n" "$(diskman_human_path_size /var/cache/apt)"
                ;;
            journal)
                journalctl --disk-usage 2>/dev/null || printf "journalctl indisponible\n"
                ;;
            user-cache)
                printf "\$HOME/.cache: %s\n" "$(diskman_human_path_size "$HOME/.cache")"
                if [ -d "$HOME/.cache" ]; then
                    printf "Top cache utilisateur (Cursor exclu de l'apply):\n"
                    find "$HOME/.cache" -mindepth 1 -maxdepth 1 -exec du -sh {} + 2>/dev/null \
                        | sort -hr | head -20 \
                        | sed 's/^/  /'
                fi
                ;;
            trash)
                printf "Trash: %s\n" "$(diskman_human_path_size "$HOME/.local/share/Trash")"
                ;;
            tmp)
                printf "/tmp: %s\n" "$(diskman_human_path_size /tmp)"
                ;;
            docker)
                if command -v timeout >/dev/null 2>&1; then
                    timeout 3 docker system df 2>/dev/null || printf "docker non accessible ou trop lent\n"
                else
                    docker system df 2>/dev/null || printf "docker non accessible\n"
                fi
                ;;
            snap)
                if command -v snap >/dev/null 2>&1; then
                    snap list --all 2>/dev/null | awk 'NR==1 || /disabled|désactivé|desactivé/ {print}'
                else
                    printf "snap absent\n"
                fi
                ;;
        esac
    }

    diskman_clean_apply_one() {
        _target="$1"
        case "$_target" in
            pacman)
                command -v pacman >/dev/null 2>&1 || { printf "pacman absent\n"; return 0; }
                if command -v paccache >/dev/null 2>&1; then
                    sudo paccache -rk2
                    sudo paccache -ruk0
                else
                    sudo pacman -Sc
                fi
                ;;
            apt)
                command -v apt-get >/dev/null 2>&1 || { printf "apt absent\n"; return 0; }
                sudo apt-get clean
                sudo apt-get autoremove -y
                ;;
            journal)
                sudo journalctl --vacuum-time=14d
                ;;
            user-cache)
                find "$HOME/.cache" -mindepth 1 -maxdepth 1 -mtime +14 \
                    ! -iname '*cursor*' ! -iname '*Cursor*' \
                    -exec rm -rf {} + 2>/dev/null || true
                ;;
            trash)
                rm -rf "$HOME/.local/share/Trash/files"/* "$HOME/.local/share/Trash/info"/* 2>/dev/null || true
                ;;
            tmp)
                sudo find /tmp -mindepth 1 -xdev -mtime +7 -exec rm -rf {} + 2>/dev/null || true
                ;;
            docker)
                command -v docker >/dev/null 2>&1 || { printf "docker absent\n"; return 0; }
                docker system prune -af
                ;;
            snap)
                command -v snap >/dev/null 2>&1 || { printf "snap absent\n"; return 0; }
                snap list --all 2>/dev/null \
                    | awk '/disabled|désactivé|desactivé/ {print $1, $3}' \
                    | while read -r name rev; do
                        [ -n "$name" ] && [ -n "$rev" ] || continue
                        sudo snap remove "$name" --revision="$rev" || true
                    done
                ;;
        esac
    }

    diskman_cmd_clean() {
        _apply=0
        _yes=0
        _target=all
        while [ $# -gt 0 ]; do
            case "$1" in
                --dry-run) _apply=0; shift ;;
                --apply) _apply=1; shift ;;
                --yes|-y) _yes=1; shift ;;
                all|pacman|apt|journal|user-cache|trash|tmp|docker|snap) _target="$1"; shift ;;
                *) printf "%sdiskman clean: option/target inconnu: %s%s\n" "$RED" "$1" "$RESET" >&2; return 2 ;;
            esac
        done
        diskman_header "nettoyage (${_target})"
        _targets="$_target"
        if [ "$_target" = all ]; then
            _targets=$(printf '%s\n' pacman apt journal user-cache trash tmp docker snap)
        fi
        printf "%sMode:%s %s\n\n" "$BOLD" "$RESET" "$( [ "$_apply" -eq 1 ] && printf apply || printf dry-run )"
        printf '%s\n' "$_targets" | while IFS= read -r t; do
            [ -n "$t" ] || continue
            printf "%s[%s]%s\n" "$CYAN" "$t" "$RESET"
            diskman_clean_show "$t"
        done
        if [ "$_apply" -ne 1 ]; then
            printf "\n%sDry-run uniquement.%s Relancer avec: diskman clean --apply %s\n" "$YELLOW" "$RESET" "$_target"
            printf "Pour les opérations root: sudo diskman clean --dry-run %s\n" "$_target"
            return 0
        fi
        if [ "$_yes" -ne 1 ] && [ -t 0 ] && [ -t 1 ]; then
            printf "\n%sConfirmer le nettoyage réel (%s) ? [y/N] %s" "$RED" "$_target" "$RESET"
            read -r ans || ans=n
            case "$ans" in [yY]|[oO]) ;; *) printf "Annulé.\n"; return 0 ;; esac
        elif [ "$_yes" -ne 1 ]; then
            printf "%sRefus non-TTY sans --yes.%s\n" "$RED" "$RESET" >&2
            return 2
        fi
        printf '%s\n' "$_targets" | while IFS= read -r t; do
            [ -n "$t" ] || continue
            printf "\n%s[apply %s]%s\n" "$GREEN" "$t" "$RESET"
            diskman_clean_apply_one "$t"
        done
    }

    diskman_cmd_report() {
        _out="${1:-}"
        _root="${DISKMAN_REPORT_ROOT:-.}"
        _body() {
            date -u '+date_utc=%Y-%m-%dT%H:%M:%SZ'
            printf "\n== overview ==\n"
            diskman_cmd_overview
            printf "\n== usage %s ==\n" "$_root"
            diskman_cmd_usage "$_root" 1
            printf "\n== biggest %s ==\n" "$_root"
            diskman_cmd_biggest "$_root" 20
            printf "\n== clean dry-run ==\n"
            diskman_cmd_clean --dry-run all
        }
        if [ -n "$_out" ]; then
            _body > "$_out"
            printf "%sRapport écrit: %s%s\n" "$GREEN" "$_out" "$RESET"
        else
            _body
        fi
    }

    diskman_menu() {
        while true; do
            diskman_header "menu"
            printf "1) Vue d'ensemble\n"
            printf "2) Dossiers lourds (~)\n"
            printf "3) Plus gros fichiers (~)\n"
            printf "4) Analyse guidée (/)\n"
            printf "5) Candidats déplacement HOME -> /data\n"
            printf "6) Nettoyage dry-run\n"
            printf "7) Santé disque\n"
            printf "8) Archives déjà extraites (cwd)\n"
            printf "0) Quitter\n"
            printf "Choix: "
            read -r choice || return 0
            case "$choice" in
                1) diskman_cmd_overview; pause_if_tty ;;
                2) diskman_cmd_usage "$HOME" 2; pause_if_tty ;;
                3) diskman_cmd_biggest "$HOME" 30; pause_if_tty ;;
                4) diskman_cmd_analyze / 1; pause_if_tty ;;
                5) diskman_cmd_relocate_candidates "$HOME" /data; pause_if_tty ;;
                6) diskman_cmd_clean --dry-run all; pause_if_tty ;;
                7) diskman_cmd_health; pause_if_tty ;;
                8) diskman_cmd_archives "$(pwd)" 3; pause_if_tty ;;
                0|q|quit|exit) return 0 ;;
                *) printf "%sChoix invalide.%s\n" "$RED" "$RESET" ;;
            esac
        done
    }

    if [ -z "${1-}" ]; then
        diskman_print_help
        return 0
    fi
    if [ "$1" = help ] || [ "$1" = "-h" ] || [ "$1" = aide ]; then
        case "${2-}" in
            --interactive|-i)
                diskman_print_help
                pause_if_tty
                return 0
                ;;
            *)
                diskman_print_help
                return 0
                ;;
        esac
    fi
    if [ "$1" = "--help" ]; then
        diskman_print_help
        return 0
    fi
    if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then
        if ! { [ -t 0 ] && [ -t 1 ]; }; then
            printf '%s\n' "diskman: menu nécessite un terminal (TTY)." >&2
            return 2
        fi
        diskman_menu
        return 0
    fi

    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ]; then
        . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log diskman "$@"
    fi

    cmd=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    shift
    case "$cmd" in
        overview|status|df) diskman_cmd_overview "$@" ;;
        analyze|analyse|scan) diskman_cmd_analyze "$@" ;;
        recommend|reco|plan) diskman_cmd_recommend "$@" ;;
        relocate|move|data) diskman_cmd_relocate_path "$@" ;;
        duplicates|dupes|doublons) diskman_cmd_duplicates "$@" ;;
        compress-candidates|compressible|compression) diskman_cmd_compress_candidates "$@" ;;
        archives|archive|extracted|extraits) diskman_cmd_archives "$@" ;;
        usage|du) diskman_cmd_usage "$@" ;;
        biggest|big|large) diskman_cmd_biggest "$@" ;;
        inodes|inode) diskman_cmd_inodes "$@" ;;
        mounts|mount) diskman_cmd_mounts "$@" ;;
        health|smart) diskman_cmd_health "$@" ;;
        clean|cleanup) diskman_cmd_clean "$@" ;;
        report) diskman_cmd_report "$@" ;;
        *)
            printf "%sdiskman: commande inconnue: %s%s\n" "$RED" "$cmd" "$RESET" >&2
            printf "Voir : diskman help\n" >&2
            return 1
            ;;
    esac
}
