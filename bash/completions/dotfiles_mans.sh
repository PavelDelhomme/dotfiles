#!/usr/bin/env bash
# Complétion Bash pour les *man (share/completions/mans.conf)
# Sourcé depuis bash/bashrc_custom

_dotfiles_mans_conf() {
	echo "${DOTFILES_DIR:-$HOME/dotfiles}/share/completions/mans.conf"
}

_dotfiles_mans_subs() {
	local cmd="$1" conf line
	conf="$(_dotfiles_mans_conf)"
	[ -f "$conf" ] || return 0
	line=$(grep -E "^${cmd}:" "$conf" 2>/dev/null | head -1 | cut -d: -f2-)
	# shellcheck disable=SC2086
	echo help -h --help menu --interactive $line
}

_dotfiles_mans_complete() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local cmd="${COMP_WORDS[0]}"
	local prev="${COMP_WORDS[1]}"

	if [ "$COMP_CWORD" -eq 1 ]; then
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "$(_dotfiles_mans_subs "$cmd")" -- "$cur"))
		return 0
	fi

	case "$cmd-$prev" in
	netman-dig)
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "help -h A AAAA MX NS TXT SOA CNAME ANY +trace -x --raw @1.1.1.1 @8.8.8.8" -- "$cur"))
		;;
	helpman-*)
		if [ "$COMP_CWORD" -eq 1 ]; then
			local mans=""
			local d="${DOTFILES_DIR:-$HOME/dotfiles}/core/managers"
			[ -d "$d" ] && mans=$(find "$d" -mindepth 1 -maxdepth 1 -type d -printf '%f ' 2>/dev/null)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "$mans" -- "$cur"))
		elif [ "$COMP_CWORD" -eq 2 ]; then
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "$(_dotfiles_mans_subs "$prev")" -- "$cur"))
		fi
		;;
	dfm-*|dfmenu-*)
		local menus="" mdir="${DOTFILES_DIR:-$HOME/dotfiles}/share/menus"
		if [ -d "$mdir" ]; then
			menus=$(find "$mdir" -maxdepth 1 -name '*.menu' -printf '%f\n' 2>/dev/null | sed 's/\.menu$//' | tr '\n' ' ')
		fi
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "$menus" -- "$cur"))
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

# Enregistrer pour chaque commande listée dans mans.conf
if [ -f "$(_dotfiles_mans_conf)" ]; then
	while IFS= read -r _line || [ -n "$_line" ]; do
		case "$_line" in
		''|\#*) continue ;;
		esac
		_cmd="${_line%%:*}"
		[ -n "$_cmd" ] || continue
		complete -F _dotfiles_mans_complete "$_cmd" 2>/dev/null || true
	done <"$(_dotfiles_mans_conf)"
fi
