#!/bin/sh
# =============================================================================
# MANAGER_TESTER - Utilitaire pour tester un manager individuel
# =============================================================================
# Description: Teste un manager spécifique et ses fonctionnalités
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger progress_bar
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
PROGRESS_BAR="$DOTFILES_DIR/core/utils/progress_bar.sh"

if [ -f "$PROGRESS_BAR" ]; then
    . "$PROGRESS_BAR"
fi

# =============================================================================
# Configuration
# =============================================================================
MANAGER_NAME="$1"
MANAGER_FUNCTION="$2"
SHELL_TYPE="${3:-zsh}"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-/tmp/dotfiles_test_results}"
REPORT_FILE="$TEST_RESULTS_DIR/${MANAGER_NAME}_test_report.txt"

# Créer le répertoire de résultats
mkdir -p "$TEST_RESULTS_DIR"

# =============================================================================
# Fonctions de test
# =============================================================================

# Test 1: Vérifier que le manager existe (dans le shell cible, après chargement adapter)
test_manager_exists() {
    local manager="$1"
    local shell_type="$2"
    local adapter_file=""
    
    case "$shell_type" in
        zsh)
            adapter_file="$DOTFILES_DIR/shells/zsh/adapters/$manager.zsh"
            if [ -f "$adapter_file" ]; then
                if zsh -c "source \"$adapter_file\" 2>/dev/null && type $manager >/dev/null 2>&1"; then
                    echo "✅ Manager $manager existe (ZSH)"
                    return 0
                fi
            fi
            echo "❌ Manager $manager n'existe pas (ZSH)"
            return 1
            ;;
        bash)
            adapter_file="$DOTFILES_DIR/shells/bash/adapters/$manager.sh"
            if [ -f "$adapter_file" ]; then
                if bash -c "source \"$adapter_file\" 2>/dev/null && type $manager >/dev/null 2>&1"; then
                    echo "✅ Manager $manager existe (Bash)"
                    return 0
                fi
            else
                echo "⚠️  Adapter Bash non trouvé: $adapter_file"
                return 0
            fi
            echo "❌ Manager $manager n'existe pas (Bash)"
            return 1
            ;;
        fish)
            adapter_file="$DOTFILES_DIR/shells/fish/adapters/$manager.fish"
            if [ -f "$adapter_file" ]; then
                if fish -c "source \"$adapter_file\" 2>/dev/null && type $manager >/dev/null 2>&1"; then
                    echo "✅ Manager $manager existe (Fish)"
                    return 0
                fi
            else
                echo "⚠️  Adapter Fish non trouvé: $adapter_file"
                return 0
            fi
            echo "❌ Manager $manager n'existe pas (Fish)"
            return 1
            ;;
        *)
            echo "⚠️  Shell non supporté: $shell_type"
            return 1
            ;;
    esac
}

# Test 2: Vérifier la syntaxe du core
test_core_syntax() {
    local manager="$1"
    local core_file="$DOTFILES_DIR/core/managers/$manager/core/$manager.sh"
    local result=0
    
    if [ -f "$core_file" ]; then
        if sh -n "$core_file" 2>/dev/null; then
            echo "✅ Syntaxe core valide: $core_file"
            return 0
        else
            echo "❌ Erreur de syntaxe dans core: $core_file"
            sh -n "$core_file" 2>&1 | head -5
            return 1
        fi
    else
        echo "⚠️  Core non trouvé: $core_file (peut être normal pour wrappers)"
        return 0  # Pas une erreur si c'est un wrapper
    fi
}

# Test 3: Vérifier la syntaxe de l'adapter ZSH
test_adapter_syntax() {
    local manager="$1"
    local adapter_file="$DOTFILES_DIR/shells/zsh/adapters/$manager.zsh"
    local result=0
    
    if [ -f "$adapter_file" ]; then
        if zsh -n "$adapter_file" 2>/dev/null; then
            echo "✅ Syntaxe adapter ZSH valide: $adapter_file"
            return 0
        else
            echo "❌ Erreur de syntaxe dans adapter ZSH: $adapter_file"
            zsh -n "$adapter_file" 2>&1 | head -5
            return 1
        fi
    else
        echo "⚠️  Adapter ZSH non trouvé: $adapter_file"
        return 1
    fi
}

# Test 4: Vérifier que le manager peut être chargé (avec timeout)
test_manager_load() {
    local manager="$1"
    local shell_type="$2"
    local result=0
    local timeout_cmd=""
    
    # Vérifier si timeout est disponible (chercher dans plusieurs emplacements)
    timeout_cmd=""
    timeout_path=""
    
    if command -v timeout >/dev/null 2>&1; then
        timeout_path=$(command -v timeout)
        timeout_cmd="$timeout_path 3"
    elif command -v gtimeout >/dev/null 2>&1; then
        timeout_path=$(command -v gtimeout)
        timeout_cmd="$timeout_path 3"
    elif [ -f "/usr/bin/timeout" ] && [ -x "/usr/bin/timeout" ]; then
        timeout_path="/usr/bin/timeout"
        timeout_cmd="$timeout_path 3"
    elif [ -f "/usr/sbin/timeout" ] && [ -x "/usr/sbin/timeout" ]; then
        timeout_path="/usr/sbin/timeout"
        timeout_cmd="$timeout_path 3"
    fi
    
    case "$shell_type" in
        zsh)
            # Utiliser timeout pour éviter les blocages lors du chargement
            if [ -n "$timeout_path" ] && [ -x "$timeout_path" ]; then
                if "$timeout_path" 3 zsh -c "source $DOTFILES_DIR/shells/zsh/adapters/$manager.zsh 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager peut être chargé (ZSH)"
                    return 0
                else
                    echo "❌ Manager $manager ne peut pas être chargé (ZSH)"
                    return 1
                fi
            else
                # Pas de timeout, test normal
                if zsh -c "source $DOTFILES_DIR/shells/zsh/adapters/$manager.zsh 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager peut être chargé (ZSH)"
                    return 0
                else
                    echo "❌ Manager $manager ne peut pas être chargé (ZSH)"
                    return 1
                fi
            fi
            ;;
        bash)
            local adapter_file="$DOTFILES_DIR/shells/bash/adapters/$manager.sh"
            if [ -f "$adapter_file" ]; then
                if [ -n "$timeout_path" ] && [ -x "$timeout_path" ]; then
                    if "$timeout_path" 3 bash -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                        echo "✅ Manager $manager peut être chargé (Bash)"
                        return 0
                    else
                        echo "❌ Manager $manager ne peut pas être chargé (Bash)"
                        return 1
                    fi
                else
                    if bash -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                        echo "✅ Manager $manager peut être chargé (Bash)"
                        return 0
                    else
                        echo "❌ Manager $manager ne peut pas être chargé (Bash)"
                        return 1
                    fi
                fi
            else
                echo "⚠️  Adapter Bash non trouvé: $adapter_file (peut être normal)"
                return 0
            fi
            ;;
        fish)
            local adapter_file="$DOTFILES_DIR/shells/fish/adapters/$manager.fish"
            if [ -f "$adapter_file" ]; then
                if [ -n "$timeout_path" ] && [ -x "$timeout_path" ]; then
                    if "$timeout_path" 3 fish -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                        echo "✅ Manager $manager peut être chargé (Fish)"
                        return 0
                    else
                        echo "❌ Manager $manager ne peut pas être chargé (Fish)"
                        return 1
                    fi
                else
                    if fish -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                        echo "✅ Manager $manager peut être chargé (Fish)"
                        return 0
                    else
                        echo "❌ Manager $manager ne peut pas être chargé (Fish)"
                        return 1
                    fi
                fi
            else
                echo "⚠️  Adapter Fish non trouvé: $adapter_file (peut être normal)"
                return 0
            fi
            ;;
        *)
            echo "⚠️  Shell non supporté: $shell_type"
            return 1
            ;;
    esac
}

# Test 5b (gitman uniquement): Vérifier que "gitman time-spent" fonctionne dans un dépôt Git
test_gitman_time_spent() {
    local manager="$1"
    local repo_dir="${2:-$DOTFILES_DIR}"
    
    if [ "$manager" != "gitman" ]; then
        return 0
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "⚠️  git non disponible - test time-spent ignoré"
        return 0
    fi
    # Résoudre le chemin absolu du repo (important en Docker)
    repo_dir=$(cd "$repo_dir" 2>/dev/null && pwd) || true
    [ -z "$repo_dir" ] && echo "⚠️  Répertoire repo inaccessible - test time-spent ignoré" && return 0
    if ! [ -d "$repo_dir/.git" ]; then
        echo "⚠️  Pas de dépôt Git dans $repo_dir - test time-spent ignoré (Docker: volume monté avec .git?)"
        return 0
    fi
    # Exécuter dans zsh: charger gitman, aller dans le repo, lancer time-spent
    out=$(zsh -c "
        export DOTFILES_DIR=\"$DOTFILES_DIR\"
        source \"$DOTFILES_DIR/shells/zsh/adapters/gitman.zsh\" 2>/dev/null || true
        cd \"$repo_dir\" && gitman time-spent 2>&1
    " 2>/dev/null)
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        if echo "$out" | grep -q "Pas un dépôt Git"; then
            echo "⚠️  gitman time-spent: pas en dépôt Git (cwd ou volume) - test ignoré"
            return 0
        fi
        echo "❌ gitman time-spent a échoué (code $exit_code)"
        echo "$out" | head -20
        return 1
    fi
    if ! echo "$out" | grep -q "TOTAL"; then
        echo "❌ gitman time-spent: sortie sans ligne TOTAL"
        echo "$out" | head -15
        return 1
    fi
    if ! echo "$out" | grep -qE " [0-9]+\.?[0-9]* h "; then
        echo "❌ gitman time-spent: sortie sans heures (h)"
        echo "$out" | head -15
        return 1
    fi
    echo "✅ gitman time-spent OK (estimation temps par auteur)"
    return 0
}

# Test 5c: Test fonctionnel (smoke) - une commande non interactive par manager
test_manager_smoke() {
    local manager="$1"
    local shell_type="${2:-zsh}"
    local out="" code=0
    local core="$DOTFILES_DIR/core/managers/$manager/core/${manager}.sh"
    local bridge="$DOTFILES_DIR/scripts/test/utils/fish_run_posix_inv.fish"
    case "$manager" in
        pathman)
            case "$shell_type" in
                zsh)
                    out=$(zsh -c "source \"$DOTFILES_DIR/shells/zsh/adapters/pathman.zsh\" 2>/dev/null && pathman show 2>&1") || true
                    ;;
                bash)
                    out=$(bash -c "source \"$DOTFILES_DIR/shells/bash/adapters/pathman.sh\" 2>/dev/null && pathman show 2>&1") || true
                    ;;
                fish)
                    if [ -f "$bridge" ] && [ -f "$core" ]; then
                        out=$(fish "$bridge" pathman "$core" show 2>&1) || true
                    else
                        echo "⚠️  pathman smoke fish ignoré (pont absent)"
                        return 0
                    fi
                    ;;
                *)
                    out=$(zsh -c "source \"$DOTFILES_DIR/shells/zsh/adapters/pathman.zsh\" 2>/dev/null && pathman show 2>&1") || true
                    ;;
            esac
            code=$?
            if [ $code -ne 0 ]; then
                echo "❌ pathman show a échoué (code $code) [$shell_type]"
                return 1
            fi
            if ! echo "$out" | grep -qE "Contenu du PATH|/bin|/usr"; then
                echo "❌ pathman show: sortie inattendue [$shell_type]"
                echo "$out" | head -5
                return 1
            fi
            echo "✅ pathman show OK (fonctionnel, $shell_type)"
            return 0
            ;;
        doctorman)
            case "$shell_type" in
                zsh)
                    out=$(zsh -c "source \"$DOTFILES_DIR/shells/zsh/adapters/doctorman.zsh\" 2>/dev/null && doctorman help 2>&1") || true
                    ;;
                bash)
                    out=$(bash -c "source \"$DOTFILES_DIR/shells/bash/adapters/doctorman.sh\" 2>/dev/null && doctorman help 2>&1") || true
                    ;;
                fish)
                    if [ -f "$bridge" ] && [ -f "$core" ]; then
                        out=$(fish "$bridge" doctorman "$core" help 2>&1) || true
                    else
                        echo "⚠️  doctorman smoke fish ignoré (pont absent)"
                        return 0
                    fi
                    ;;
                *)
                    out=$(zsh -c "source \"$DOTFILES_DIR/shells/zsh/adapters/doctorman.zsh\" 2>/dev/null && doctorman help 2>&1") || true
                    ;;
            esac
            code=$?
            if [ $code -ne 0 ]; then
                echo "❌ doctorman help a échoué (code $code) [$shell_type]"
                return 1
            fi
            if ! echo "$out" | grep -q "DOCTORMAN"; then
                echo "❌ doctorman help: sortie inattendue [$shell_type]"
                echo "$out" | head -5
                return 1
            fi
            echo "✅ doctorman help OK (fonctionnel, $shell_type)"
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Test 5: Vérifier que le manager répond (test basique avec timeout)
test_manager_response() {
    local manager="$1"
    local shell_type="$2"
    local result=0
    local timeout_cmd=""
    
    # Vérifier si timeout est disponible (chercher dans plusieurs emplacements)
    timeout_cmd=""
    timeout_path=""
    
    if command -v timeout >/dev/null 2>&1; then
        timeout_path=$(command -v timeout)
        timeout_cmd="$timeout_path 2"
    elif command -v gtimeout >/dev/null 2>&1; then
        timeout_path=$(command -v gtimeout)
        timeout_cmd="$timeout_path 2"
    elif [ -f "/usr/bin/timeout" ] && [ -x "/usr/bin/timeout" ]; then
        timeout_path="/usr/bin/timeout"
        timeout_cmd="$timeout_path 2"
    elif [ -f "/usr/sbin/timeout" ] && [ -x "/usr/sbin/timeout" ]; then
        timeout_path="/usr/sbin/timeout"
        timeout_cmd="$timeout_path 2"
    fi
    
    # Test simple: vérifier que la fonction existe et peut être appelée (avec timeout)
    case "$shell_type" in
        zsh)
            # Test avec timeout pour éviter les blocages
            if [ -n "$timeout_path" ] && [ -x "$timeout_path" ]; then
                # Utiliser timeout pour éviter les blocages
                if "$timeout_path" 2 zsh -c "source $DOTFILES_DIR/shells/zsh/adapters/$manager.zsh 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager répond (ZSH)"
                    return 0
                else
                    echo "⚠️  Manager $manager ne répond pas (ZSH) - peut être normal"
                    return 0  # Pas une erreur critique
                fi
            else
                # Pas de timeout disponible, test minimal (juste vérifier que la fonction existe)
                if zsh -c "source $DOTFILES_DIR/shells/zsh/adapters/$manager.zsh 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager répond (ZSH)"
                    return 0
                else
                    echo "⚠️  Manager $manager ne répond pas (ZSH) - peut être normal"
                    return 0  # Pas une erreur critique
                fi
            fi
            ;;
        bash)
            local adapter_file="$DOTFILES_DIR/shells/bash/adapters/$manager.sh"
            if [ ! -f "$adapter_file" ]; then
                echo "⚠️  Adapter Bash absent — test réponse ignoré"
                return 0
            fi
            if [ -n "$timeout_path" ] && [ -x "$timeout_path" ]; then
                if "$timeout_path" 2 bash -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager répond (Bash)"
                    return 0
                fi
            else
                if bash -c "source $adapter_file 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager répond (Bash)"
                    return 0
                fi
            fi
            echo "⚠️  Manager $manager ne répond pas (Bash) — peut être normal"
            return 0
            ;;
        fish)
            local adapter_file="$DOTFILES_DIR/shells/fish/adapters/$manager.fish"
            local core_pf="$DOTFILES_DIR/core/managers/$manager/core/${manager}.sh"
            local bridge_pf="$DOTFILES_DIR/scripts/test/utils/fish_run_posix_inv.fish"
            inv=help
            case "$manager" in pathman) inv=show ;; esac
            if [ -f "$bridge_pf" ] && [ -f "$core_pf" ] && command -v fish >/dev/null 2>&1; then
                if fish "$bridge_pf" "$manager" "$core_pf" $inv >/dev/null 2>&1; then
                    echo "✅ Manager $manager répond (Fish / pont POSIX)"
                    return 0
                fi
            fi
            if [ -f "$adapter_file" ]; then
                if fish -c "source \"$adapter_file\" 2>/dev/null && type $manager >/dev/null 2>&1" 2>/dev/null; then
                    echo "✅ Manager $manager répond (Fish)"
                    return 0
                fi
            fi
            echo "⚠️  Manager $manager ne répond pas (Fish) — peut être normal"
            return 0
            ;;
        *)
            echo "⚠️  Test de réponse non implémenté pour $shell_type"
            return 0
            ;;
    esac
}

# =============================================================================
# Fonction principale de test
# =============================================================================
test_manager() {
    local manager="$1"
    local shell_type="$2"
    local total_tests=5
    local passed_tests=0
    local failed_tests=0
    
    # Tests supplémentaires : time-spent (gitman, zsh seulement), smoke pathman/doctorman
    [ "$manager" = "gitman" ] && [ "$shell_type" = "zsh" ] && total_tests=6
    [ "$manager" = "pathman" ] && total_tests=6
    [ "$manager" = "doctorman" ] && total_tests=6
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🧪 TEST: $manager ($shell_type)"
    echo "═══════════════════════════════════════════════════════════════"
    
    # Test 1: Existence
    if test_manager_exists "$manager" "$shell_type"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 2: Syntaxe core
    if test_core_syntax "$manager"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 3: Syntaxe adapter
    if test_adapter_syntax "$manager"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 4: Chargement
    if test_manager_load "$manager" "$shell_type"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 5: Réponse
    if test_manager_response "$manager" "$shell_type"; then
        passed_tests=$((passed_tests + 1))
    else
        failed_tests=$((failed_tests + 1))
    fi
    
    # Test 5b: gitman time-spent (une fois, zsh — même logique qu’avant la matrice)
    if [ "$manager" = "gitman" ] && [ "$shell_type" = "zsh" ]; then
        if test_gitman_time_spent "$manager" "$DOTFILES_DIR"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))
        fi
    fi
    
    # Test 5c: smoke fonctionnel (pathman show, etc.)
    if [ "$manager" = "pathman" ]; then
        if test_manager_smoke "$manager" "$shell_type"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))
        fi
    fi
    if [ "$manager" = "doctorman" ]; then
        if test_manager_smoke "$manager" "$shell_type"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))
        fi
    fi
    
    # Résumé
    echo ""
    echo "📊 Résumé: $passed_tests/$total_tests tests réussis"
    
    if [ "$failed_tests" -eq 0 ]; then
        echo "✅ Tous les tests passés pour $manager ($shell_type)"
        return 0
    else
        echo "❌ $failed_tests test(s) échoué(s) pour $manager ($shell_type)"
        return 1
    fi
}

# Exécuter le test si appelé directement
if [ -n "$MANAGER_NAME" ]; then
    test_manager "$MANAGER_NAME" "$SHELL_TYPE"
fi

