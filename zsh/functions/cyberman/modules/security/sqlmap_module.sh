#!/bin/zsh
# =============================================================================
# SQLMAP MODULE - Module pour SQLMap
# =============================================================================
# Description: Intégration de SQLMap pour tests SQL injection
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les dépendances
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyber}"

if [ -f "$CYBER_DIR/target_manager.sh" ]; then
    source "$CYBER_DIR/target_manager.sh"
fi
if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
    source "$CYBER_DIR/environment_manager.sh"
fi
if [ -f "$CYBER_DIR/utils/ensure_tool.sh" ]; then
    source "$CYBER_DIR/utils/ensure_tool.sh"
fi

# Répertoires
SQLMAP_SCANS_DIR="${HOME}/.cyberman/scans/sqlmap"
mkdir -p "$SQLMAP_SCANS_DIR"

# DESC: Scan SQL injection avec SQLMap
# USAGE: sqlmap_scan <target_url> [options]
# EXAMPLE: sqlmap_scan "https://example.com?id=1"
sqlmap_scan() {
    local target="$1"
    local level="${2:-3}"
    local risk="${3:-2}"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 URL cible avec paramètre (ex: https://example.com?id=1): ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    # Vérifier et installer SQLMap
    if ! command -v sqlmap >/dev/null 2>&1; then
        echo "📦 Installation de SQLMap..."
        ensure_tool sqlmap sqlmap || return 1
    fi
    
    local output_dir="$SQLMAP_SCANS_DIR/sqlmap-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$output_dir"
    
    echo "🔍 Test SQL injection sur: $target"
    echo "📁 Résultats: $output_dir"
    echo "⚙️  Level: $level, Risk: $risk"
    echo ""
    
    sqlmap -u "$target" \
        --batch \
        --random-agent \
        --level="$level" \
        --risk="$risk" \
        --output-dir="$output_dir" \
        --threads=10
    
    if [ -d "$output_dir" ] && [ -n "$(ls -A "$output_dir" 2>/dev/null)" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats dans: $output_dir"
        ls -lh "$output_dir"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "sqlmap" "SQLMap scan sur $target" "Résultats dans: $output_dir" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune injection SQL détectée"
    fi
    
    return 0
}

# DESC: Affiche le menu SQLMap
# USAGE: show_sqlmap_menu
show_sqlmap_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    SQLMAP - CYBERMAN                           ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        echo "1.  🔍 Test SQL injection (niveau standard)"
        echo "2.  🔍 Test SQL injection (niveau élevé)"
        echo "3.  🔍 Test SQL injection (niveau maximum)"
        echo "4.  🔍 Test SQL injection (personnalisé)"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                printf "🎯 URL avec paramètre: "
                read -r target
                if [ -n "$target" ]; then
                    sqlmap_scan "$target" 3 2
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                printf "🎯 URL avec paramètre: "
                read -r target
                if [ -n "$target" ]; then
                    sqlmap_scan "$target" 4 3
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                printf "🎯 URL avec paramètre: "
                read -r target
                if [ -n "$target" ]; then
                    sqlmap_scan "$target" 5 3
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                printf "🎯 URL avec paramètre: "
                read -r target
                printf "⚙️  Level (1-5, défaut: 3): "
                read -r level
                level="${level:-3}"
                printf "⚙️  Risk (1-3, défaut: 2): "
                read -r risk
                risk="${risk:-2}"
                if [ -n "$target" ]; then
                    sqlmap_scan "$target" "$level" "$risk"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

