#!/usr/bin/env bash
# Vérifie l'intégration menu fzf-first + fallback tty.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOTFILES_DIR"

ok()   { printf "\033[0;32m✓\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m⚠\033[0m %s\n" "$1"; }
err()  { printf "\033[0;31m✗\033[0m %s\n" "$1"; }

failures=0

check_file_contains() {
    local file="$1" pattern="$2" msg="$3"
    if grep -qE "$pattern" "$file"; then
        ok "$msg"
    else
        err "$msg"
        failures=$((failures + 1))
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 Test menus (principal=fzf, fallback=secours)"
echo "═══════════════════════════════════════════════════════════════"

core_menu_lib="$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
check_file_contains "$core_menu_lib" "command -v fzf" "Helper central: chemin principal = fzf"
check_file_contains "$core_menu_lib" "DOTFILES_FZF_MENU_OPTS|_fzf_menu_opts" "Helper central: configuration UI fzf présente"
check_file_contains "$core_menu_lib" "ncmenu --title" "Helper central: fallback ncmenu (secours)"
check_file_contains "$core_menu_lib" "return 127" "Helper central: fallback final (secours) si aucun choix"

# Managers avec helper custom : ils doivent passer par le helper central,
# puis fallback /dev/tty uniquement en dernier recours.
for f in \
    "$DOTFILES_DIR/core/managers/searchman/core/searchman.sh" \
    "$DOTFILES_DIR/core/managers/miscman/core/miscman.sh" \
    "$DOTFILES_DIR/core/managers/cyberman/core/cyberman.sh" \
    "$DOTFILES_DIR/core/managers/cyberlearn/core/cyberlearn.sh" \
    "$DOTFILES_DIR/core/managers/testzshman/core/testzshman.sh"
do
    name=$(basename "$f")
    check_file_contains "$f" "dotfiles_ncmenu_select" "$name: passe par helper central (fzf principal)"
    check_file_contains "$f" "read _choice < /dev/tty" "$name: fallback /dev/tty présent (secours)"
done

# Vérification fonctionnelle non interactive minimale.
if bash -lc '. core/managers/searchman/core/searchman.sh; searchman ping >/dev/null'; then
    ok "searchman ping non interactif"
else
    err "searchman ping non interactif"
    failures=$((failures + 1))
fi

if bash -lc '. core/managers/aliaman/core/aliaman.sh; alias gst="git status"; aliaman search gst >/dev/null'; then
    ok "aliaman search non interactif"
else
    err "aliaman search non interactif"
    failures=$((failures + 1))
fi

echo ""
if [ "$failures" -gt 0 ]; then
    err "Test menus fzf: $failures échec(s)"
    exit 1
fi
ok "Test menus: OK (fzf principal, fallbacks de secours présents)"
exit 0
