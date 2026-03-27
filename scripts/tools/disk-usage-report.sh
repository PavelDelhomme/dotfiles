#!/usr/bin/env bash
# =============================================================================
# disk-usage-report.sh - Analyse espace disque et doublons
# =============================================================================
# Usage:
#   ./disk-usage-report.sh                    # Résumé disques + top répertoires
#   ./disk-usage-report.sh /data             # Top répertoires sous /data
#   ./disk-usage-report.sh --duplicates /home # Fichiers en double (même contenu)
#   ./disk-usage-report.sh --top 50 /         # Top 50 répertoires sous /
# Utilisable en live (dépendances: du, find, sort, awk; md5sum/sha256sum pour doublons)
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TOP_N=25
MIN_DUP_BYTES=1024
DUPLICATES_ONLY=false
PATHS=()

usage() {
    echo -e "${CYAN}Usage:${NC} $0 [options] [chemin...]"
    echo ""
    echo "  --top N         Afficher les N plus gros répertoires (défaut: 25)"
    echo "  --duplicates    Chercher les fichiers en double (même contenu)"
    echo "  --min-size N    Taille min (octets) pour doublons (défaut: 1024)"
    echo "  --help          Aide"
    echo ""
    echo "Exemples:"
    echo "  $0                     # Espace disque / et montages"
    echo "  $0 /data               # Top répertoires sous /data"
    echo "  $0 --duplicates /home   # Doublons dans /home"
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --top) TOP_N="$2"; shift 2 ;;
        --duplicates) DUPLICATES_ONLY=true; shift ;;
        --min-size) MIN_DUP_BYTES="$2"; shift 2 ;;
        --help|-h) usage ;;
        *) PATHS+=("$1"); shift ;;
    esac
done

[ ${#PATHS[@]} -eq 0 ] && PATHS=(/ /home /var /tmp /usr /data /run/media /mnt)
VALID_PATHS=()
for p in "${PATHS[@]}"; do [ -d "$p" ] && VALID_PATHS+=("$p"); done
[ ${#VALID_PATHS[@]} -eq 0 ] && VALID_PATHS=(/)

human() {
    local s="$1"
    if command -v numfmt &>/dev/null; then
        numfmt --to=iec "$s" 2>/dev/null || echo "${s}"
    elif [ "$s" -ge 1073741824 ] 2>/dev/null; then
        echo "$(( s / 1073741824 ))G"
    elif [ "$s" -ge 1048576 ] 2>/dev/null; then
        echo "$(( s / 1048576 ))M"
    elif [ "$s" -ge 1024 ] 2>/dev/null; then
        echo "$(( s / 1024 ))K"
    else
        echo "${s}"
    fi
}

disk_summary() {
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  RÉSUMÉ DISQUES${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    df -h 2>/dev/null | grep -E '^/dev|Filesystem' || df -h 2>/dev/null
    echo ""
}

top_dirs() {
    local path="$1"
    local n="${2:-$TOP_N}"
    echo -e "${BOLD}  TOP ${n} sous ${path}${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    du -x --max-depth=2 "$path" 2>/dev/null | sort -rn | head -n "$((n+2))" | while read -r size dir; do
        [ "$dir" = "$path" ] && continue
        h=$(human "$((size*1024))" 2>/dev/null || echo "${size}K")
        printf "  %10s  %s\n" "$h" "$dir"
    done
    echo ""
}

find_duplicates() {
    local path="$1"
    echo -e "${BOLD}  DOUBLONS (contenu identique) sous ${path} (fichiers >= $(human "$MIN_DUP_BYTES"))${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    local hasher=""
    command -v sha256sum &>/dev/null && hasher="sha256sum"
    command -v md5sum &>/dev/null && [ -z "$hasher" ] && hasher="md5sum"
    if [ -z "$hasher" ]; then
        echo "  (sha256sum/md5sum absents: affichage des candidats par taille uniquement)"
    fi
    local tmp="${TMPDIR:-/tmp}/diskdup_$$"
    mkdir -p "$tmp"
    if find "$path" -xdev -type f -size "+${MIN_DUP_BYTES}c" -printf "%s\n" 2>/dev/null | sort -n | uniq -c | awk '$1>1 {print $2}' > "$tmp/sizes"; then
        :
    else
        find "$path" -xdev -type f -size "+${MIN_DUP_BYTES}c" 2>/dev/null | while read -r f; do
            [ -f "$f" ] && stat -c "%s" "$f" 2>/dev/null
        done | sort -n | uniq -c | awk '$1>1 {print $2}' > "$tmp/sizes"
    fi
    local count_sizes=0
    while read -r size; do
        [ -z "$size" ] && continue
        find "$path" -xdev -type f -size "${size}c" 2>/dev/null > "$tmp/fl"
        local num
        num=$(wc -l < "$tmp/fl")
        [ "$num" -lt 2 ] && continue
        count_sizes=$((count_sizes+1))
        if [ -n "$hasher" ]; then
            while read -r f; do
                [ -f "$f" ] && $hasher "$f" 2>/dev/null | awk -v f="$f" '{print $1, f}'
            done < "$tmp/fl" > "$tmp/h"
            awk '{print $1}' "$tmp/h" | sort | uniq -c | awk '$1>1 {print $2}' > "$tmp/dh"
            while read -r hash; do
                [ -z "$hash" ] && continue
                echo -e "  ${YELLOW}Taille $(human "$size") - même contenu:${NC}"
                grep "^$hash " "$tmp/h" | awk '{print "    "$2}' | head -15
                local c; c=$(grep -c "^$hash " "$tmp/h" 2>/dev/null || echo 0)
                [ "$c" -gt 15 ] && echo "    ... +$((c-15)) autres"
            done < "$tmp/dh" 2>/dev/null
        else
            echo -e "  ${YELLOW}Taille $(human "$size") - $num fichiers (candidats):${NC}"
            head -5 "$tmp/fl" | while read -r f; do echo "    $f"; done
            [ "$num" -gt 5 ] && echo "    ... +$((num-5)) autres"
        fi
    done < "$tmp/sizes"
    rm -rf "$tmp"
    [ "$count_sizes" -eq 0 ] && echo "  Aucun doublon trouvé pour cette taille min."
    echo ""
}

main() {
    echo ""
    disk_summary
    if [ "$DUPLICATES_ONLY" = true ]; then
        for p in "${VALID_PATHS[@]}"; do find_duplicates "$p"; done
    else
        for p in "${VALID_PATHS[@]}"; do top_dirs "$p" "$TOP_N"; done
        echo -e "${CYAN}Doublons: $0 --duplicates [chemin]${NC}"
        echo ""
    fi
}

main "$@"
