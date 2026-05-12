#!/bin/sh
################################################################################
# lsblk_color — wrapper colorisant la sortie de `lsblk` pour la rendre plus
# lisible (disk / part / loop / etc. différenciés par couleur ANSI).
#
# Compatibilité : sh / bash / zsh. Aucune dépendance hors `awk` (déjà partout).
#
# Désactivation automatique (passe-plat sur le binaire) :
#   - stdout n'est pas un terminal (pipe, redirection, log)
#   - variable d'env. NO_COLOR définie (https://no-color.org/)
#   - variable d'env. DOTFILES_LSBLK_NOCOLOR=1
#   - une option de format machine est utilisée :
#       -J / --json, -P / --pairs, -r / --raw, -n / --noheadings,
#       -o / -O / --output / --output-all
#
# Forçage des couleurs : DOTFILES_LSBLK_FORCE_COLOR=1 (utile en pipe maîtrisé).
#
# Légende des couleurs :
#   - en-tête    : gras
#   - disk       : gras + cyan
#   - part       : vert
#   - loop       : gris (peu intéressant en général)
#   - raid*      : jaune
#   - crypt/lvm  : magenta
#   - rom/tape   : rouge
#   - continuation MOUNTPOINTS multiples : hérite de la couleur précédente
################################################################################

lsblk() {
    # 1) format machine demandé → pas de couleur (sortie parsée par d'autres)
    for _arg in "$@"; do
        case "$_arg" in
            -J|--json|-P|--pairs|-r|--raw|-n|--noheadings|\
            -o|--output|-O|--output-all|--list-columns|-H|\
            --tree=*|-Q|--filter|--version|-V)
                command lsblk "$@"
                return $?
                ;;
            -o*|--output=*)
                command lsblk "$@"
                return $?
                ;;
        esac
    done

    # 2) sortie non-TTY / NO_COLOR / désactivation explicite → passe-plat
    _force="${DOTFILES_LSBLK_FORCE_COLOR:-0}"
    if [ "$_force" != "1" ]; then
        if [ ! -t 1 ] \
            || [ -n "${NO_COLOR-}" ] \
            || [ "${DOTFILES_LSBLK_NOCOLOR:-0}" = "1" ]; then
            command lsblk "$@"
            return $?
        fi
    fi

    # 3) sinon : colorisation via awk (POSIX)
    command lsblk "$@" 2>&1 | awk '
        BEGIN {
            bold    = "\033[1m"
            reset   = "\033[0m"
            cyan    = "\033[36m"
            green   = "\033[32m"
            yellow  = "\033[33m"
            magenta = "\033[35m"
            red     = "\033[31m"
            gray    = "\033[90m"
            current = ""   # couleur de la dernière ligne TYPE rencontrée
        }
        NR == 1 {
            # en-tête (NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS)
            print bold $0 reset
            current = ""
            next
        }
        {
            line = $0
            # Détection du mot TYPE entouré d espaces (évite de matcher dans un chemin)
            if (match(line, /[[:space:]](disk|part|loop|crypt|lvm[0-9]*|raid[0-9]*|rom|md|tape|dm)[[:space:]]/) > 0) {
                word = substr(line, RSTART + 1, RLENGTH - 2)
                col  = cyan
                if      (word == "loop")               col = gray
                else if (word == "part")               col = green
                else if (word == "disk")               col = bold cyan
                else if (word ~ /^raid/)               col = yellow
                else if (word == "crypt" || word ~ /^lvm/) col = magenta
                else if (word == "rom"   || word == "tape") col = red
                else if (word == "md"    || word == "dm")   col = magenta
                current = col
                print col line reset
                next
            }
            # Ligne de continuation MOUNTPOINTS multiples (lsblk récent affiche
            # plusieurs chemins sur des lignes consécutives) → hérite de la
            # couleur de la dernière ligne TYPE.
            if (current != "") {
                print current line reset
            } else {
                print line
            }
        }
    '
}
