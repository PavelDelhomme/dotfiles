#!/usr/bin/env bash
################################################################################
# Audit Git des dépôts sous ~/Documents/Dev/Perso (dirty / ahead / no remote)
################################################################################
set -euo pipefail

BASE="${PERSO_GIT_BASE:-$HOME/Documents/Dev/Perso}"
DEPTH="${PERSO_GIT_DEPTH:-3}"

if [ ! -d "$BASE" ]; then
    echo "Dossier absent: $BASE" >&2
    exit 1
fi

printf 'Base: %s (depth≤%s)\n' "$BASE" "$DEPTH"
printf '%-6s %5s %5s %5s %-24s %s\n' "STATE" "dirty" "ahead" "behind" "branch" "repo"
printf '%s\n' "--------------------------------------------------------------------------------"

dirty_n=0
ahead_n=0
ok_n=0
norepo_n=0

while IFS= read -r -d '' g; do
    repo=$(dirname "$g")
    name=${repo#"$BASE"/}
    (
        cd "$repo" || exit 0
        branch=$(git branch --show-current 2>/dev/null || echo '?')
        dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        remote=$(git remote get-url origin 2>/dev/null || echo '')
        if [ -z "$remote" ]; then
            printf 'NO_REM %5s %5s %5s %-24s %s\n' "$dirty" "-" "-" "$branch" "$name"
            exit 0
        fi
        ahead=0
        behind=0
        if git rev-parse '@{u}' >/dev/null 2>&1; then
            ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
            behind=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
        else
            ahead='?'
            behind='?'
        fi
        state=OK
        if [ "$dirty" != 0 ] || { [ "$ahead" != 0 ] && [ "$ahead" != '?' ]; }; then
            state=DIRTY
        fi
        printf '%-6s %5s %5s %5s %-24s %s\n' "$state" "$dirty" "$ahead" "$behind" "$branch" "$name"
    )
done < <(find "$BASE" -maxdepth "$DEPTH" -type d -name .git -print0 2>/dev/null)

echo ""
echo "Légende: DIRTY = modifs locales et/ou commits non poussés. Aucun commit auto."
echo "Pour pousser un dépôt: cd … && git status && git push"
echo "Backup home (hors secrets): bash \$DOTFILES_DIR/scripts/sync/perso_backup_home.sh"
