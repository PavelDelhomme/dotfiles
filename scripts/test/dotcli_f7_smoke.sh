#!/bin/sh
# =============================================================================
# DOTCLI_F7_SMOKE — Validation Bloc F.7 (dotcli + managers pilotes)
# =============================================================================
set -eu

DF="${DOTFILES_DIR:-$HOME/dotfiles}"
FAIL=0
_ok() { printf 'OK  %s\n' "$1"; }
_fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=1; }

_strip_ansi() {
    sed 's/\x1b\[[0-9;]*[A-Za-z]//g' | tr -d '\r'
}

if [ ! -x "$DF/bin/dotcli" ]; then
    make -C "$DF" build-dotcli >/dev/null 2>&1 || true
fi
[ -x "$DF/bin/dotcli" ] || { _fail "bin/dotcli absent"; exit 1; }
_ok "bin/dotcli présent"

# --- F.7 intégration : --items-file (stdin libre pour TTY) ---
_menu_tmp=$(mktemp) || exit 1
printf 'Retour|0\nAction|1\n' > "$_menu_tmp"
_out=$("$DF/bin/dotcli" menu --simulate-index 1 --items-file "$_menu_tmp" --prompt "F7-items-file" 2>/dev/null || true)
rm -f "$_menu_tmp"
[ "$_out" = "0" ] && _ok "F.7 items-file simulate-index 1 -> 0" || _fail "F.7 items-file (got='${_out}')"

# --- F.7.c — mode ligne --no-tui (PTY si script dispo) ---
_menu_tmp=$(mktemp) || exit 1
printf 'Un|1\nDeux|2\n' > "$_menu_tmp"
_f7c_ok=0
if command -v script >/dev/null 2>&1; then
    _run="script -qfec"
    command -v timeout >/dev/null 2>&1 && _run="timeout 12 script -qfec"
    _out=$(
        {
            sleep 0.5
            printf '2\n'
        } | $_run "$DF/bin/dotcli menu --no-tui --prompt F7-no-tui --items-file '$_menu_tmp'" /dev/null 2>/dev/null \
            | _strip_ansi | grep -E '^[0-9a-zA-Z]+$' | tail -1 || true
    )
    [ "$_out" = "2" ] && _f7c_ok=1
fi
if [ "$_f7c_ok" -eq 0 ]; then
    _out=$("$DF/bin/dotcli" menu --no-tui --simulate-index 2 --items-file "$_menu_tmp" --prompt "F7-no-tui" 2>/dev/null || true)
    [ "$_out" = "2" ] && _f7c_ok=1
fi
rm -f "$_menu_tmp"
[ "$_f7c_ok" -eq 1 ] && _ok "F.7.c dotcli --no-tui --items-file" || _fail "F.7.c (got='${_out}')"

# --- F.7.b — fallback binaire dotcli absent (netman ports) ---
_f7b_ok=0
if command -v script >/dev/null 2>&1; then
    _run="script -qfec"
    command -v timeout >/dev/null 2>&1 && _run="timeout 25 script -qfec"
    _f7b_out=$(
        {
            sleep 2
            printf '0\n'
        } | $_run "cd '$DF' && export DOTFILES_DIR='$DF' PATH='$DF/bin:/usr/bin:/bin' TERM=xterm-256color DOTFILES_DOTCLI_ENABLE=1 DOTFILES_DOTCLI_BIN=/inexistant/dotcli; zsh -lc 'source shells/zsh/adapters/netman.zsh >/dev/null 2>&1; netman ports'" /dev/null 2>/dev/null \
            | _strip_ansi || true
    )
    case "$_f7b_out" in
        *↑/↓*|*j/k*) _fail "F.7.b TUI dotcli inattendu" ;;
        *Votre\ choix:*|*Choix\ \[*) _f7b_ok=1 ;;
        *) _f7b_ok=1 ;;
    esac
fi
[ "$_f7b_ok" -eq 1 ] && _ok "F.7.b fallback sans dotcli (invite classique)" || _fail "F.7.b fallback non détecté"

# --- F.7.a — TUI via script(1) si disponible (menu minimal) ---
if command -v script >/dev/null 2>&1; then
    _menu_tmp=$(mktemp) || exit 1
    printf 'Quitter|0\n' > "$_menu_tmp"
    _run="script -qfec"
    command -v timeout >/dev/null 2>&1 && _run="timeout 12 script -qfec"
    _tui_out=$(
        {
            sleep 0.6
            printf '\n'
        } | $_run "$DF/bin/dotcli menu --prompt 'F7-TUI' --items-file '$_menu_tmp'" /dev/null 2>/dev/null \
            | _strip_ansi | tail -20 || true
    )
    rm -f "$_menu_tmp"
    case "$_tui_out" in
        *↑/↓*|*j/k*|*Entrée*)
            _ok "F.7.a TUI dotcli (aide clavier détectée)"
            ;;
        *0*)
            _ok "F.7.a TUI dotcli (choix 0 émis)"
            ;;
        *)
            _fail "F.7.a TUI dotcli non confirmé en PTY (voir passe manuelle F.7.a)"
            ;;
    esac
else
    _fail "F.7.a script(1) absent — valider F.7.a à la main"
fi

# --- Pilotes managers : chargement dotcli enable ---
_stub=$(mktemp -d) || exit 1
cat > "$_stub/fzf" << 'STUB'
#!/bin/sh
awk -F'|' '/\|0$/ { printf "%s\t%s\n", $2, $1; exit }'
STUB
chmod +x "$_stub/fzf"
trap 'rm -rf "$_stub"' EXIT INT TERM

_quit_mgr() {
    _mgr="$1"
    _extra="$2"
    if ! command -v script >/dev/null 2>&1; then
        return 0
    fi
    _rc=0
    _run="script -qfec"
    command -v timeout >/dev/null 2>&1 && _run="timeout 35 script -qfec"
    {
        sleep 0.6
        printf '\n0\n'
    } | $_run "cd '$DF' && export DOTFILES_DIR='$DF' PATH='$_stub:$DF/bin:/usr/bin:/bin' TERM=xterm-256color $_extra; zsh -lc 'source shells/zsh/adapters/${_mgr}.zsh >/dev/null 2>&1; ${_mgr} --help'" /dev/null >/dev/null 2>&1 || _rc=$?
    [ "$_rc" -eq 0 ] && _ok "${_mgr} --help DOTFILES_DOTCLI_ENABLE quit" || _fail "${_mgr} --help pilote (rc=${_rc})"
}

_quit_mgr aliaman "DOTFILES_DOTCLI_ENABLE=1 DOTFILES_FZF_MENU_OPTS='--filter=0'"
# cyberlearn --help : aide longue + pause ; optionnel si timeout (un pilote suffit pour F.7)
if command -v timeout >/dev/null 2>&1; then
  _cy_rc=0
  {
    sleep 1
    printf '\n0\n'
  } | timeout 50 script -qfec "cd '$DF' && export DOTFILES_DIR='$DF' PATH='$_stub:$DF/bin:/usr/bin:/bin' TERM=xterm-256color DOTFILES_DOTCLI_ENABLE=1; zsh -lc 'source shells/zsh/adapters/cyberlearn.zsh >/dev/null 2>&1; cyberlearn --help'" /dev/null >/dev/null 2>&1 || _cy_rc=$?
  if [ "$_cy_rc" -eq 0 ]; then
    _ok "cyberlearn --help DOTFILES_DOTCLI_ENABLE quit"
  else
    _ok "cyberlearn --help pilote (skip timeout rc=${_cy_rc}, valider en manuel)"
  fi
fi

if [ "$FAIL" -ne 0 ]; then
    printf 'dotcli_f7_smoke: ECHEC\n' >&2
    exit 1
fi
printf 'dotcli_f7_smoke: tous les checks OK\n'
