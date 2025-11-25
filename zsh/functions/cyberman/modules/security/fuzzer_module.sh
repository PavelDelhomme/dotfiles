#!/bin/zsh
# =============================================================================
# FUZZER MODULE - Module pour fuzzers web (ffuf, wfuzz)
# =============================================================================
# Description: Intégration de ffuf et wfuzz pour fuzzing web
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
FUZZER_SCANS_DIR="${HOME}/.cyberman/scans/fuzzer"
mkdir -p "$FUZZER_SCANS_DIR"

# DESC: Fuzzing avec ffuf
# USAGE: ffuf_scan <target_url> [wordlist]
# EXAMPLE: ffuf_scan "https://example.com/FUZZ"
ffuf_scan() {
    local target="$1"
    local wordlist="$2"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 URL cible (utilisez FUZZ pour le point d'injection): ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    if [ -z "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
        if [ ! -f "$wordlist" ]; then
            wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
            if [ ! -f "$wordlist" ]; then
                printf "📝 Chemin du wordlist: "
                read -r wordlist
                if [ -z "$wordlist" ] || [ ! -f "$wordlist" ]; then
                    echo "❌ Wordlist introuvable"
                    return 1
                fi
            fi
        fi
    fi
    
    # Vérifier et installer ffuf
    if ! command -v ffuf >/dev/null 2>&1; then
        echo "📦 Installation de ffuf..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm ffuf
        else
            echo "⚠️  ffuf non disponible. Installez-le: yay -S ffuf"
            return 1
        fi
    fi
    
    local output_file="$FUZZER_SCANS_DIR/ffuf-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Fuzzing avec ffuf sur: $target"
    echo "📁 Wordlist: $wordlist"
    echo "📁 Résultats: $output_file"
    echo ""
    
    ffuf -u "$target" \
        -w "$wordlist" \
        -mc 200,301,302,403 \
        -c \
        -v \
        -o "$output_file" \
        -of json
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Fuzzing terminé. Résultats:"
        cat "$output_file" | head -50
        echo ""
        echo "📁 Fichier complet: $output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "ffuf" "ffuf fuzzing sur $target" "Résultats dans: $output_file" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucun résultat trouvé"
    fi
    
    return 0
}

# DESC: Fuzzing avec wfuzz
# USAGE: wfuzz_scan <target_url> [wordlist]
# EXAMPLE: wfuzz_scan "https://example.com/FUZZ"
wfuzz_scan() {
    local target="$1"
    local wordlist="$2"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 URL cible (utilisez FUZZ pour le point d'injection): ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    if [ -z "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
        if [ ! -f "$wordlist" ]; then
            wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
            if [ ! -f "$wordlist" ]; then
                printf "📝 Chemin du wordlist: "
                read -r wordlist
                if [ -z "$wordlist" ] || [ ! -f "$wordlist" ]; then
                    echo "❌ Wordlist introuvable"
                    return 1
                fi
            fi
        fi
    fi
    
    # Vérifier et installer wfuzz
    if ! command -v wfuzz >/dev/null 2>&1; then
        echo "📦 Installation de wfuzz..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm wfuzz
        else
            echo "⚠️  wfuzz non disponible. Installez-le: yay -S wfuzz"
            return 1
        fi
    fi
    
    local output_file="$FUZZER_SCANS_DIR/wfuzz-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Fuzzing avec wfuzz sur: $target"
    echo "📁 Wordlist: $wordlist"
    echo "📁 Résultats: $output_file"
    echo ""
    
    wfuzz -c \
        -z file,"$wordlist" \
        --hc 404 \
        "$target" \
        > "$output_file" 2>&1
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Fuzzing terminé. Résultats:"
        cat "$output_file" | head -50
        echo ""
        echo "📁 Fichier complet: $output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "wfuzz" "wfuzz fuzzing sur $target" "Résultats dans: $output_file" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucun résultat trouvé"
    fi
    
    return 0
}

# DESC: Affiche le menu Fuzzer
# USAGE: show_fuzzer_menu
show_fuzzer_menu() {
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
        echo "║                    WEB FUZZER - CYBERMAN                       ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        echo "1.  🔍 Fuzzing avec ffuf (rapide, Go)"
        echo "2.  🔍 Fuzzing avec wfuzz (Python)"
        echo "3.  🔍 Fuzzing de paramètres (ffuf)"
        echo "4.  🔍 Fuzzing de headers (ffuf)"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                ffuf_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                wfuzz_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                printf "🎯 URL de base: "
                read -r base_url
                printf "📝 Paramètre à fuzzer (ex: id): "
                read -r param
                if [ -n "$base_url" ] && [ -n "$param" ]; then
                    local target="${base_url}?${param}=FUZZ"
                    ffuf_scan "$target"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                printf "🎯 URL cible: "
                read -r target
                printf "📝 Header à fuzzer (ex: User-Agent): "
                read -r header
                if [ -n "$target" ] && [ -n "$header" ]; then
                    printf "📝 Wordlist pour header: "
                    read -r wordlist
                    wordlist="${wordlist:-/usr/share/wordlists/dirb/common.txt}"
                    if [ -f "$wordlist" ]; then
                        local output_file="$FUZZER_SCANS_DIR/ffuf-header-$(date +%Y%m%d-%H%M%S).txt"
                        ffuf -u "$target" \
                            -H "$header: FUZZ" \
                            -w "$wordlist" \
                            -mc 200,301,302 \
                            -c \
                            -o "$output_file" \
                            -of json
                        echo "✅ Résultats: $output_file"
                    fi
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

