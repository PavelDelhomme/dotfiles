#!/bin/sh
# =============================================================================
# Hook login — pull silencieux du dépôt (zsh/bash/sh)
# Source depuis zshrc_custom / bashrc / etc.
# Fish : voir fish/config_custom.fish
#
# Désactiver : DOTFILES_AUTO_UPDATE=0
# Intervalle minutes : DOTFILES_UPDATE_INTERVAL_MIN=60 (défaut)
# Mode : DOTFILES_SYNC_MODE=pull|full (défaut pull)
# =============================================================================

# Uniquement shell interactif
case "$-" in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac

[ "${DOTFILES_AUTO_UPDATE:-1}" = "0" ] && return 0 2>/dev/null || true

_df_root="${DOTFILES_DIR:-${DOTFILES_PATH:-$HOME/dotfiles}}"
_df_script="$_df_root/scripts/sync/dotfiles_update.sh"
[ -x "$_df_script" ] || [ -f "$_df_script" ] || return 0 2>/dev/null || true

_df_stamp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
_df_stamp="$_df_stamp_dir/last_update"
_df_interval_min="${DOTFILES_UPDATE_INTERVAL_MIN:-60}"

_df_need=1
if [ -f "$_df_stamp" ]; then
    _df_now=$(date +%s 2>/dev/null || echo 0)
    _df_then=$(date -r "$_df_stamp" +%s 2>/dev/null || echo 0)
    if [ "$_df_now" -gt 0 ] && [ "$_df_then" -gt 0 ]; then
        _df_age=$(( (_df_now - _df_then) / 60 ))
        [ "$_df_age" -lt "$_df_interval_min" ] && _df_need=0
    fi
fi

if [ "$_df_need" = "1" ]; then
    # Background : ne bloque pas l'ouverture du terminal
    (
        DOTFILES_DIR="$_df_root" \
        DOTFILES_UPDATE_QUIET=1 \
        DOTFILES_SYNC_MODE="${DOTFILES_SYNC_MODE:-pull}" \
        bash "$_df_script" "${DOTFILES_SYNC_MODE:-pull}" >/dev/null 2>&1
    ) &
fi

unset _df_root _df_script _df_stamp_dir _df_stamp _df_interval_min _df_need _df_now _df_then _df_age
return 0 2>/dev/null || true
