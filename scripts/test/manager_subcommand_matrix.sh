#!/usr/bin/env bash
# =============================================================================
# Matrice : managers × shells × lignes d'invocation (sous-commandes non interactives)
# =============================================================================
# Variables :
#   DOTFILES_DIR      racine dotfiles
#   TEST_MANAGERS     liste d'espaces (défaut = migrés depuis config)
#   TEST_SHELLS       défaut : zsh bash fish
#   SUBCOMMAND_TIER   quick = seulement « help » si présent, sinon 1re ligne ;
#                       full = toutes les lignes des fichiers subcommands/
#   TEST_SUBCOMMAND_TIMEOUT  secondes (défaut 45)
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-$DOTFILES_DIR/test_results}"
mkdir -p "$TEST_RESULTS_DIR" 2>/dev/null || true
# En Docker (dotfiles en RO), run_subcommand_matrix_docker.sh définit TEST_RESULTS_DIR + MANAGERS_LOG_FILE.
export MANAGERS_LOG_FILE="${MANAGERS_LOG_FILE:-$TEST_RESULTS_DIR/managers_subcommand_matrix.log}"

# shellcheck source=/dev/null
. "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_config.sh"

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_test_host_env.sh"
    dotfiles_test_apply_manager_filter
fi

if [ -f "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh" ]; then
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/scripts/test/lib/dotfiles_docker_git_safe.sh"
    dotfiles_docker_git_trust_repo 2>/dev/null || true
fi

SUBCOMMAND_TIER="${SUBCOMMAND_TIER:-full}"
# sh = cœurs POSIX sans adapter (cohérence avec scripts POSIX)
TEST_SHELLS="${TEST_SHELLS:-zsh bash fish sh}"
TEST_SUBCOMMAND_TIMEOUT="${TEST_SUBCOMMAND_TIMEOUT:-45}"
TIMEOUT_BIN=""
command -v timeout >/dev/null 2>&1 && TIMEOUT_BIN=$(command -v timeout)
command -v gtimeout >/dev/null 2>&1 && TIMEOUT_BIN=$(command -v gtimeout)

MANAGERS="${TEST_MANAGERS:-$(dotfiles_migrated_managers_space)}"
SUBCMD_DIR="$DOTFILES_DIR/scripts/test/subcommands"
FISH_BRIDGE="$DOTFILES_DIR/scripts/test/utils/fish_run_posix_inv.fish"

failures=0
runs=0

run_with_timeout() {
    if [ -n "$TIMEOUT_BIN" ] && [ -x "$TIMEOUT_BIN" ]; then
        "$TIMEOUT_BIN" "${TEST_SUBCOMMAND_TIMEOUT}" "$@"
    else
        "$@"
    fi
}

run_zsh_inv() {
    local mgr=$1
    shift
    run_with_timeout zsh -c "
      export DOTFILES_DIR=\"$DOTFILES_DIR\" HOME=\"${HOME:-$HOME}\" MANAGERS_LOG_FILE=\"${MANAGERS_LOG_FILE}\"
      cd \"$DOTFILES_DIR\" || exit 1
      source \"$DOTFILES_DIR/shells/zsh/adapters/${mgr}.zsh\" 2>/dev/null || exit 127
      $mgr \"\$@\"
    " _ "$@"
}

run_bash_inv() {
    local mgr=$1
    shift
    local ad="$DOTFILES_DIR/shells/bash/adapters/${mgr}.sh"
    if [ ! -f "$ad" ]; then
        echo "SKIP bash: pas d'adapter $ad"
        return 0
    fi
    run_with_timeout bash -c "
      export DOTFILES_DIR=\"$DOTFILES_DIR\" HOME=\"${HOME:-$HOME}\" MANAGERS_LOG_FILE=\"${MANAGERS_LOG_FILE}\"
      cd \"$DOTFILES_DIR\" || exit 1
      # shellcheck source=/dev/null
      source \"$ad\" 2>/dev/null || exit 127
      $mgr \"\$@\"
    " _ "$@"
}

run_fish_inv() {
    local mgr=$1
    shift
    local core="$DOTFILES_DIR/core/managers/$mgr/core/${mgr}.sh"
    if [ ! -f "$core" ]; then
        echo "SKIP fish: pas de core $core"
        return 0
    fi
    if [ ! -f "$FISH_BRIDGE" ]; then
        echo "SKIP fish: $FISH_BRIDGE absent"
        return 0
    fi
    run_with_timeout env DOTFILES_DIR="$DOTFILES_DIR" HOME="${HOME:-$HOME}" MANAGERS_LOG_FILE="${MANAGERS_LOG_FILE}" \
        fish "$FISH_BRIDGE" "$mgr" "$core" "$@"
}

run_sh_inv() {
    local mgr=$1
    shift
    local core="$DOTFILES_DIR/core/managers/$mgr/core/${mgr}.sh"
    if [ ! -f "$core" ]; then
        echo "SKIP sh: pas de core $core"
        return 0
    fi
    run_with_timeout sh -c "
      export DOTFILES_DIR=\"$DOTFILES_DIR\" HOME=\"${HOME:-$HOME}\" MANAGERS_LOG_FILE=\"${MANAGERS_LOG_FILE}\"
      cd \"$DOTFILES_DIR\" || exit 1
      # shellcheck source=/dev/null
      . \"$core\" 2>/dev/null || exit 127
      $mgr \"\$@\"
    " _ "$@"
}

run_in_shell() {
    local shell=$1 mgr=$2
    shift 2
    case "$shell" in
        zsh) run_zsh_inv "$mgr" "$@" ;;
        bash) run_bash_inv "$mgr" "$@" ;;
        fish) run_fish_inv "$mgr" "$@" ;;
        sh) run_sh_inv "$mgr" "$@" ;;
        *) echo "shell inconnu: $shell"; return 2 ;;
    esac
}

read_subcommand_lines() {
    local mgr=$1
    local f="$SUBCMD_DIR/${mgr}.list"
    if [ ! -f "$f" ]; then
        return 1
    fi
    if grep -q '^@skip' "$f" 2>/dev/null; then
        return 1
    fi
    if [ "$SUBCOMMAND_TIER" = "quick" ]; then
        if grep -v '^#' "$f" | grep -v '^$' | grep -v '^@' | grep -qx 'help'; then
            printf '%s\n' "help"
            return 0
        fi
        grep -v '^#' "$f" | grep -v '^$' | grep -v '^@' | head -n1
        return 0
    fi
    grep -v '^#' "$f" | grep -v '^$' | grep -v '^@'
}

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 Matrice sous-commandes (tier=$SUBCOMMAND_TIER)"
echo "   DOTFILES_DIR=$DOTFILES_DIR"
echo "   Shells: $TEST_SHELLS"
echo "   Managers: $MANAGERS"
echo "═══════════════════════════════════════════════════════════════"

for mgr in $MANAGERS; do
    if [ ! -f "$SUBCMD_DIR/${mgr}.list" ]; then
        echo "⏭  $mgr — pas de scripts/test/subcommands/${mgr}.list"
        continue
    fi
    if grep -q '^@skip' "$SUBCMD_DIR/${mgr}.list" 2>/dev/null; then
        echo "⏭  $mgr — @skip dans scripts/test/subcommands/${mgr}.list (volontaire : trop interactif pour la matrice CI ; tester à la main ou make test-docker-manager MANAGER=$mgr)"
        continue
    fi
    lines_file=$(mktemp)
    if ! read_subcommand_lines "$mgr" >"$lines_file"; then
        echo "⏭  $mgr — spec vide"
        rm -f "$lines_file"
        continue
    fi
    if [ ! -s "$lines_file" ]; then
        echo "⏭  $mgr — aucune invocation"
        rm -f "$lines_file"
        continue
    fi
    while IFS= read -r inv || [ -n "$inv" ]; do
        [ -z "$inv" ] && continue
        for shell in $TEST_SHELLS; do
            runs=$((runs + 1))
            printf '🧪 [%s] %s %s\n' "$shell" "$mgr" "$inv"
            if run_in_shell "$shell" "$mgr" $inv; then
                printf '   ✓ ok (code 0)\n'
            else
                echo "❌ échec: $shell $mgr $inv"
                failures=$((failures + 1))
            fi
        done
    done <"$lines_file"
    rm -f "$lines_file"
done

echo ""
echo "📊 Matrice sous-commandes — exécutions: $runs | échecs: $failures"
if [ "$failures" -gt 0 ]; then
    echo "⚠️  Corriger les lignes « ❌ échec: … » ci-dessus ou adapter scripts/test/subcommands/*.list (invocations non interactives uniquement)."
    exit 1
fi
echo "✅ Matrice sous-commandes : OK"
exit 0
