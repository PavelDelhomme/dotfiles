#!/usr/bin/env bash
# Retire le menu interactif de « manager --help » (documentation seule).
# Ajoute « manager menu » là où un while show_main_menu existait après --help.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
LIST="${DOTFILES_DIR}/scripts/test/config/migrated_managers.list"

patch_file() {
    local f="$1"
    local mgr base
    base=$(basename "$f" .sh)
    mgr="$base"

    # Bloc standard : aide + pause + boucle menu
    if grep -q 'if \[ "\$1" = "--help" \]; then' "$f" && grep -q 'show_main_menu' "$f"; then
        python3 - "$f" "$mgr" <<'PY'
import re, sys
path, mgr = sys.argv[1], sys.argv[2]
text = open(path, encoding='utf-8').read()
orig = text

# Remplacer bloc --help + menu par doc seule
pat = re.compile(
    r'(\s*)if \[ "\$1" = "--help" \]; then\n'
    r'\1\s+(\w+)\([^)]*\)\n'
    r'(?:\1\s+if ! \{ \[ -t 0 \] && \[ -t 1 \]; \}; then\n'
    r'\1\s+return 0\n'
    r'\1\s+fi\n)?'
    r'(?:\1\s+\w+_pause_if_tty\(\)|\1\s+pause_if_tty)\n?'
    r'\1\s+while true; do\n'
    r'\1\s+show_main_menu \|\| break\n'
    r'\1\s+done\n'
    r'\1\s+return 0\n'
    r'\1fi',
    re.MULTILINE,
)
def repl(m):
    indent = m.group(1)
    help_fn = m.group(2)
    return (
        f'{indent}if [ "$1" = "--help" ]; then\n'
        f'{indent}    {help_fn}\n'
        f'{indent}    return 0\n'
        f'{indent}fi\n'
        f'{indent}if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then\n'
        f'{indent}    if ! {{ [ -t 0 ] && [ -t 1 ]; }}; then\n'
        f'{indent}        printf \'%s: menu nécessite un terminal (TTY).\\n\' \'{mgr}\' >&2\n'
        f'{indent}        return 2\n'
        f'{indent}    fi\n'
        f'{indent}    while true; do\n'
        f'{indent}        show_main_menu || break\n'
        f'{indent}    done\n'
        f'{indent}    return 0\n'
        f'{indent}fi'
    )
text, n = pat.subn(repl, text, count=1)
if n == 0:
    # variante diskman_menu
    pat2 = re.compile(
        r'(\s*)if \[ "\$1" = "--help" \]; then\n'
        r'\1\s+(\w+)\([^)]*\)\n'
        r'\1\s+if \[ -t 0 \] && \[ -t 1 \]; then\n'
        r'\1\s+pause_if_tty\n'
        r'\1\s+diskman_menu\n'
        r'\1\s+fi\n'
        r'\1\s+return 0\n'
        r'\1fi',
        re.MULTILINE,
    )
    def repl2(m):
        indent = m.group(1)
        help_fn = m.group(2)
        return (
            f'{indent}if [ "$1" = "--help" ]; then\n'
            f'{indent}    {help_fn}\n'
            f'{indent}    return 0\n'
            f'{indent}fi\n'
            f'{indent}if [ "$1" = menu ] || [ "$1" = "--interactive" ]; then\n'
            f'{indent}    if ! {{ [ -t 0 ] && [ -t 1 ]; }}; then\n'
            f'{indent}        printf \'%s: menu nécessite un terminal (TTY).\\n\' \'diskman\' >&2\n'
            f'{indent}        return 2\n'
            f'{indent}    fi\n'
            f'{indent}    diskman_menu\n'
            f'{indent}    return 0\n'
            f'{indent}fi'
        )
    text, n = pat2.subn(repl2, text, count=1)

if text != orig:
    open(path, 'w', encoding='utf-8').write(text)
    print(f"patched: {path}")
else:
    print(f"skip (no match): {path}")
PY
    fi
}

while IFS= read -r mgr || [ -n "${mgr:-}" ]; do
    case "$mgr" in ''|\#*) continue ;; esac
    core="$DOTFILES_DIR/core/managers/$mgr/core/$mgr.sh"
    [ -f "$core" ] && patch_file "$core"
done < "$LIST"

echo "done"
