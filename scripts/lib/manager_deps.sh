#!/bin/sh
# =============================================================================
# manager_deps — vérif légère des binaires requis par les *man (POSIX)
# =============================================================================
# Règles:
#   - JAMAIS au login shell (trop lent / interactif) : uniquement à l'appel *man
#   - Pas d'install auto ici (éviter sudo surprise) : warn + pointeur install
#   - Une seule alerte par session shell (variable d'environnement)
#
# Usage:
#   . scripts/lib/manager_deps.sh
#   manager_deps_check netman          # deps du manager
#   manager_deps_check_base            # dig jq git (socle commun)
# =============================================================================

# Fichier optionnel: une ligne « manager:bin1 bin2 … »
# DOTFILES_DIR/share/deps/managers.deps

manager_deps_bins_for() {
	_mgr="$1"
	case "$_mgr" in
	netman) printf '%s\n' "dig jq ip" ;;
	sshman) printf '%s\n' "ssh ssh-keygen" ;;
	dockerman) printf '%s\n' "docker" ;;
	gitman) printf '%s\n' "git" ;;
	virtman) printf '%s\n' "virsh" ;;
	pathman | aliaman | helpman | manman | doctorman) printf '%s\n' "jq" ;;
	installman | updateman | configman) printf '%s\n' "jq" ;;
	base | '*' | '') printf '%s\n' "dig jq git curl" ;;
	*)
		# Fichier déclaratif
		_df="${DOTFILES_DIR:-$HOME/dotfiles}"
		_f="${_df}/share/deps/managers.deps"
		if [ -f "$_f" ]; then
			_line=$(grep -E "^${_mgr}:" "$_f" 2>/dev/null | head -1 | cut -d: -f2-)
			if [ -n "$_line" ]; then
				printf '%s\n' "$_line"
				return 0
			fi
		fi
		printf '%s\n' ""
		;;
	esac
}

# HINT install selon distro (sans installer)
manager_deps_hint_dig() {
	if [ -f /etc/arch-release ]; then
		printf '%s\n' "sudo pacman -S --needed bind   # fournit dig"
	elif [ -f /etc/debian_version ]; then
		printf '%s\n' "sudo apt install dnsutils"
	elif [ -f /etc/fedora-release ]; then
		printf '%s\n' "sudo dnf install bind-utils"
	else
		printf '%s\n' "installman network-tools  OU  bash ~/dotfiles/scripts/install/system/packages_base.sh"
	fi
}

manager_deps_check() {
	_mgr="${1:-base}"
	_quiet="${2:-}"
	_missing=""
	_bins=$(manager_deps_bins_for "$_mgr")
	[ -z "$_bins" ] && return 0

	for _b in $_bins; do
		command -v "$_b" >/dev/null 2>&1 || _missing="${_missing} ${_b}"
	done
	_missing=$(printf '%s' "$_missing" | sed 's/^ //')
	[ -z "$_missing" ] && return 0

	if [ -z "$_quiet" ]; then
		printf '%s\n' "[!] $_mgr: binaire(s) manquant(s):$_missing" >&2
		case " $_missing " in
		*' dig '*)
			printf '%s\n' "    → $(manager_deps_hint_dig)" >&2
			printf '%s\n' "    → ou: bash \"\${DOTFILES_DIR:-\$HOME/dotfiles}/scripts/install/system/packages_base.sh\"" >&2
			;;
		esac
		printf '%s\n' "    → installman network-tools | make install-menu (deps managers)" >&2
	fi
	return 1
}

# Socle commun une fois par session (appelé depuis manager_ui)
manager_deps_check_base() {
	[ -n "${_DOTFILES_MANAGER_DEPS_BASE_DONE:-}" ] && return 0
	_DOTFILES_MANAGER_DEPS_BASE_DONE=1
	export _DOTFILES_MANAGER_DEPS_BASE_DONE
	manager_deps_check base || true
	return 0
}

# Check nommé une fois par manager / session
manager_deps_check_once() {
	_mgr="$1"
	case "$_mgr" in
	netman) [ -n "${_DOTFILES_DEPS_DONE_netman:-}" ] && return 0; _DOTFILES_DEPS_DONE_netman=1; export _DOTFILES_DEPS_DONE_netman ;;
	sshman) [ -n "${_DOTFILES_DEPS_DONE_sshman:-}" ] && return 0; _DOTFILES_DEPS_DONE_sshman=1; export _DOTFILES_DEPS_DONE_sshman ;;
	dockerman) [ -n "${_DOTFILES_DEPS_DONE_dockerman:-}" ] && return 0; _DOTFILES_DEPS_DONE_dockerman=1; export _DOTFILES_DEPS_DONE_dockerman ;;
	*) manager_deps_check_base; return 0 ;;
	esac
	manager_deps_check "$_mgr" || true
	return 0
}
