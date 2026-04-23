#!/bin/sh
# shellcheck shell=sh
# Charge les listes de managers pour tests (une source de vérité).
# Prérequis : DOTFILES_DIR exporté et pointant vers la racine des dotfiles.

_dotfiles_cfg_root="${DOTFILES_DIR:-$HOME/dotfiles}"
_dotfiles_cfg_dir="$_dotfiles_cfg_root/scripts/test/config"

# Lit un fichier liste → une ligne shell (mots séparés par espace).
dotfiles_managers_from_file() {
    _f="$1"
    if [ ! -f "$_f" ]; then
        printf '%s\n' "$2"
        return 0
    fi
    grep -v '^#' "$_f" | grep -v '^$' | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

dotfiles_migrated_managers_space() {
    dotfiles_managers_from_file "$_dotfiles_cfg_dir/migrated_managers.list" \
        "pathman manman searchman aliaman installman configman gitman fileman helpman cyberman devman virtman miscman doctorman netman sshman testman testzshman moduleman multimediaman cyberlearn"
}

dotfiles_unmigrated_managers_space() {
    dotfiles_managers_from_file "$_dotfiles_cfg_dir/unmigrated_managers.list" ""
}

dotfiles_matrix_managers_space() {
    printf '%s %s\n' "$(dotfiles_migrated_managers_space)" "$(dotfiles_unmigrated_managers_space)" | sed 's/[[:space:]]*$//'
}
