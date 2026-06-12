#!/bin/sh
# =============================================================================
# MENU_QUIT_SMOKE — Sortie 0/q des menus *man (conteneur Docker ou hôte)
# =============================================================================
# Vérifie : manager_ui_is_quit_choice, ncmenu (touche directe 0/q), et échantillon
# de managers --help quittant avec 0 dans un pseudo-TTY (script(1)).
# =============================================================================
set -eu

DF="${DOTFILES_DIR:-$HOME/dotfiles}"
FAIL=0
_ok() { printf 'OK  %s\n' "$1"; }
_fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=1; }

_nc_parse_choice() {
    tr -d '\r' | sed 's/\x1b\[[0-9;]*[A-Za-z]//g' | grep -E '^[0-9a-zA-Z]$' | tail -1
}

# fzf réel peut bloquer en pseudo-TTY automatisé : stub qui choisit Quitter|0
_stub_bin=""
_setup_fzf_stub() {
    _stub_bin=$(mktemp -d) || return 1
    cat > "$_stub_bin/fzf" << 'STUB'
#!/bin/sh
awk -F'|' '/\|0$/ { printf "%s\t%s\n", $2, $1; exit } /\|q$/ { printf "%s\t%s\n", $2, $1; exit }'
STUB
    chmod +x "$_stub_bin/fzf"
}
_cleanup_fzf_stub() {
    [ -n "$_stub_bin" ] && rm -rf "$_stub_bin"
}

# --- Helpers UI (tui_compact partiel) ---
if [ -f "$DF/scripts/lib/manager_ui.sh" ]; then
    # shellcheck source=scripts/lib/manager_ui.sh
    . "$DF/scripts/lib/manager_ui.sh"
    dotfiles_load_manager_ui
    for _c in 0 q Q quit exit quitter; do
        if manager_ui_is_quit_choice "$_c"; then
            _ok "manager_ui_is_quit_choice ${_c}"
        else
            _fail "manager_ui_is_quit_choice ${_c}"
        fi
    done
    if manager_ui_is_quit_choice "1"; then
        _fail "manager_ui_is_quit_choice 1 (faux positif)"
    else
        _ok "manager_ui_is_quit_choice refuse 1"
    fi
else
    _fail "manager_ui.sh introuvable"
fi

# --- ncmenu : sélection directe par touche ---
_ncmenu_bin=""
for _cand in "$DF/bin/ncmenu" /usr/local/bin/ncmenu ncmenu; do
    if [ -x "$_cand" ]; then
        _ncmenu_bin="$_cand"
        break
    fi
done

if [ -z "$_ncmenu_bin" ]; then
    _fail "ncmenu binaire introuvable (make build-ncmenu)"
else
    _menu_tmp=$(mktemp) || exit 1
    printf 'Action un|1\nQuitter|0\n' > "$_menu_tmp"
    for _key in 0 q; do
        _out=$(printf '%s' "$_key" | script -qfec "$_ncmenu_bin --title menu_quit_smoke < $_menu_tmp" /dev/null 2>/dev/null | _nc_parse_choice || true)
        if [ "$_out" = "$_key" ] || { [ "$_key" = "q" ] && [ "$_out" = "0" ]; }; then
            _ok "ncmenu touche ${_key} -> ${_out}"
        else
            _fail "ncmenu touche ${_key} (sortie='${_out}')"
        fi
    done
    rm -f "$_menu_tmp"
fi

# --- dotfiles_ncmenu_select via fichier menu ---
if [ -f "$DF/scripts/lib/ncurses_menu.sh" ]; then
    # shellcheck source=scripts/lib/ncurses_menu.sh
    . "$DF/scripts/lib/ncurses_menu.sh"
    _sel_tmp=$(mktemp) || exit 1
    printf 'Quitter|0\n' > "$_sel_tmp"
    if command -v script >/dev/null 2>&1; then
        _nc_choice=$(printf '0' | script -qfec ". '$DF/scripts/lib/ncurses_menu.sh'; export DOTFILES_DIR='$DF' PATH='$DF/bin:/usr/bin:/bin'; DOTFILES_FZF_MENU_OPTS='--filter=0'; dotfiles_ncmenu_select smoke < '$_sel_tmp'" /dev/null 2>/dev/null | _nc_parse_choice || true)
        rm -f "$_sel_tmp"
        case "$_nc_choice" in
            0) _ok "dotfiles_ncmenu_select filtre 0" ;;
            *) _fail "dotfiles_ncmenu_select (got='${_nc_choice}')" ;;
        esac
    else
        rm -f "$_sel_tmp"
        _fail "script(1) absent pour dotfiles_ncmenu_select"
    fi
else
    _fail "ncurses_menu.sh introuvable"
fi

# --- Managers : --help puis 0 dans pseudo-TTY ---
_setup_fzf_stub || _fail "stub fzf"
trap '_cleanup_fzf_stub' EXIT INT TERM

_quit_manager() {
    _mgr="$1"
    _adapter="$DF/shells/zsh/adapters/${_mgr}.zsh"
    [ -f "$_adapter" ] || { _fail "${_mgr}: adapter zsh absent"; return 0; }
    if ! command -v script >/dev/null 2>&1; then
        _fail "script(1) absent — skip managers TTY"
        return 0
    fi
    _rc=0
    if command -v timeout >/dev/null 2>&1; then
        _run="timeout 25 script -qfec"
    else
        _run="script -qfec"
    fi
    {
        printf '\n'
        sleep 0.8
        printf '0\n'
    } | $_run "cd '$DF' && export DOTFILES_DIR='$DF' DOTFILES_DOTCLI_ENABLE=0 PATH='$_stub_bin:$DF/bin:/usr/bin:/bin' TERM=xterm-256color; zsh -lc 'source shells/zsh/adapters/${_mgr}.zsh >/dev/null 2>&1; ${_mgr} --help'" /dev/null >/tmp/menu_quit_${_mgr}.out 2>&1 || _rc=$?

    if [ "$_rc" -eq 0 ]; then
        _ok "${_mgr} --help quit 0 (rc=0)"
    else
        _tail=$(tail -3 "/tmp/menu_quit_${_mgr}.out" 2>/dev/null | tr '\n' ' ')
        _fail "${_mgr} --help quit 0 (rc=${_rc}) ${_tail}"
    fi
}

# searchman/miscman : menus pick_menu + pause ; validés via ncmenu + aliaman/netman
for _m in aliaman netman gitman pathman processman sshman devman; do
    _quit_manager "$_m"
done

if [ "$FAIL" -ne 0 ]; then
    printf 'menu_quit_smoke: ECHEC\n' >&2
    exit 1
fi
printf 'menu_quit_smoke: tous les checks OK\n'
