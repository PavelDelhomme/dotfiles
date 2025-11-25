#!/bin/zsh
# =============================================================================
# XSS SCANNER MODULE - Module pour scanners XSS (XSStrike, Dalfox)
# =============================================================================
# Description: Intégration de XSStrike et Dalfox pour scans XSS
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
XSS_SCANS_DIR="${HOME}/.cyberman/scans/xss"
mkdir -p "$XSS_SCANS_DIR"

# DESC: Scan XSS avec XSStrike
# USAGE: xsstrike_scan <target>
# EXAMPLE: xsstrike_scan https://example.com
xsstrike_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan XSStrike: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    # Vérifier et installer XSStrike
    if ! command -v xsstrike >/dev/null 2>&1 && ! [ -f "/usr/lib/xsstrike/xsstrike.py" ]; then
        echo "📦 Installation de XSStrike..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm xsstrike
        else
            echo "⚠️  XSStrike non disponible. Installez-le: yay -S xsstrike"
            return 1
        fi
    fi
    
    local output_file="$XSS_SCANS_DIR/xsstrike-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan XSStrike sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    # Détecter le chemin de XSStrike
    local xsstrike_cmd=""
    if command -v xsstrike >/dev/null 2>&1; then
        xsstrike_cmd="xsstrike"
    elif [ -f "/usr/lib/xsstrike/xsstrike.py" ]; then
        xsstrike_cmd="python3 /usr/lib/xsstrike/xsstrike.py"
    elif [ -f "/usr/bin/xsstrike" ]; then
        xsstrike_cmd="/usr/bin/xsstrike"
    else
        echo "❌ XSStrike non trouvé"
        return 1
    fi
    
    eval "$xsstrike_cmd -u \"$target\" --fuzzer --crawl -t 20 -o \"$output_file\" 2>&1"
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "xsstrike" "XSStrike scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité XSS trouvée"
    fi
    
    return 0
}

# DESC: Scan XSS avec Dalfox
# USAGE: dalfox_scan <target>
# EXAMPLE: dalfox_scan https://example.com
dalfox_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Dalfox: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    # Vérifier et installer Dalfox
    if ! command -v dalfox >/dev/null 2>&1; then
        echo "📦 Installation de Dalfox..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm dalfox
        else
            echo "⚠️  Dalfox non disponible. Installez-le: yay -S dalfox"
            return 1
        fi
    fi
    
    local output_file="$XSS_SCANS_DIR/dalfox-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Dalfox sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    dalfox url "$target" \
        --deep-domxss \
        --mining-dict \
        --silence \
        --output "$output_file" 2>&1
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "dalfox" "Dalfox scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité XSS trouvée"
    fi
    
    return 0
}

# DESC: Affiche le menu XSS Scanner
# USAGE: show_xss_menu
show_xss_menu() {
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
        echo "║                    XSS SCANNER - CYBERMAN                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        echo "1.  🔍 XSStrike (Scanner XSS avancé avec fuzzer)"
        echo "2.  🔍 Dalfox (Scanner XSS rapide et moderne)"
        echo "3.  🔍 Scan XSS avec Nuclei (via module Nuclei)"
        echo "4.  🔍 Scan XSS sur toutes les cibles"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                xsstrike_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                dalfox_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                if [ -f "$HOME/dotfiles/zsh/functions/cyberman/modules/security/nuclei_module.sh" ]; then
                    source "$HOME/dotfiles/zsh/functions/cyberman/modules/security/nuclei_module.sh"
                    nuclei_xss_scan
                else
                    echo "❌ Module Nuclei non disponible"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                if has_targets 2>/dev/null; then
                    echo "🔄 Scan XSS sur toutes les cibles..."
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        xsstrike_scan "$target"
                        dalfox_scan "$target"
                    done
                    echo ""
                    echo "✅ Scan XSS terminé sur toutes les cibles"
                else
                    echo "❌ Aucune cible configurée"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

