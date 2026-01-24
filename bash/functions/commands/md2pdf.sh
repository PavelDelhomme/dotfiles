#!/bin/bash
# =============================================================================
# MD2PDF - Conversion Markdown vers PDF avec style (Bash)
# =============================================================================
# Description: Convertit un fichier Markdown (.md) en PDF avec un style professionnel
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

md2pdf() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Variables
    local input_file=""
    local output_file=""
    local style="default"
    local open_after=false
    local show_help=false
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -s|--style)
                style="$2"
                shift 2
                ;;
            --open)
                open_after=true
                shift
                ;;
            -h|--help)
                show_help=true
                shift
                ;;
            -*)
                echo -e "${RED}✗ Option inconnue: $1${RESET}" >&2
                return 1
                ;;
            *)
                if [ -z "$input_file" ]; then
                    input_file="$1"
                else
                    echo -e "${RED}✗ Trop d'arguments. Utilisez --help pour voir l'aide.${RESET}" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # Afficher l'aide
    if [ "$show_help" = true ] || [ -z "$input_file" ]; then
        echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}${BOLD}║              MD2PDF - Conversion Markdown → PDF                ║${RESET}"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
        echo "Usage: md2pdf <fichier.md> [options]"
        echo "       convert <fichier.md> [options]"
        echo ""
        echo "Options:"
        echo "  -o, --output <fichier.pdf>  Spécifier le nom du fichier PDF de sortie"
        echo "  -s, --style <style>         Choisir le style (default, github, minimal, elegant)"
        echo "  --open                      Ouvrir le PDF après conversion"
        echo "  -h, --help                  Afficher cette aide"
        echo ""
        echo "Exemples:"
        echo "  md2pdf README.md"
        echo "  convert document.md --output mon_document.pdf"
        echo "  md2pdf README.md --style github --open"
        echo ""
        echo "Styles disponibles:"
        echo "  default  - Style par défaut avec mise en page professionnelle"
        echo "  github   - Style inspiré de GitHub"
        echo "  minimal  - Style minimaliste"
        echo "  elegant  - Style élégant avec typographie soignée"
        echo ""
        [ -z "$input_file" ] && return 1
        return 0
    fi
    
    # Vérifier que le fichier d'entrée existe
    if [ ! -f "$input_file" ]; then
        echo -e "${RED}✗ Fichier introuvable: $input_file${RESET}" >&2
        return 1
    fi
    
    # Vérifier l'extension .md
    if [[ ! "$input_file" =~ \.(md|markdown)$ ]]; then
        echo -e "${YELLOW}⚠️  Attention: Le fichier ne se termine pas par .md ou .markdown${RESET}" >&2
        read -p "Continuer quand même? (y/N): " -n 1 -r
        echo ""
        if [[ ! "$REPLY" =~ ^[yY]$ ]]; then
            return 1
        fi
    fi
    
    # Déterminer le nom du fichier de sortie
    if [ -z "$output_file" ]; then
        output_file="${input_file%.*}.pdf"
    fi
    
    # Vérifier que pandoc est installé
    if ! command -v pandoc &>/dev/null; then
        echo -e "${RED}✗ 'pandoc' n'est pas installé${RESET}" >&2
        echo -e "${YELLOW}💡 Installation:${RESET}"
        echo ""
        
        # Détecter la distribution
        if command -v pacman &>/dev/null; then
            echo -e "  ${CYAN}sudo pacman -S pandoc${RESET}"
        elif command -v apt &>/dev/null; then
            echo -e "  ${CYAN}sudo apt install pandoc${RESET}"
        elif command -v dnf &>/dev/null; then
            echo -e "  ${CYAN}sudo dnf install pandoc${RESET}"
        else
            echo -e "  ${CYAN}Installez pandoc pour votre distribution${RESET}"
        fi
        return 1
    fi
    
    # Vérifier que wkhtmltopdf est installé
    if ! command -v wkhtmltopdf &>/dev/null; then
        echo -e "${RED}✗ 'wkhtmltopdf' n'est pas installé${RESET}" >&2
        echo -e "${YELLOW}💡 Installation:${RESET}"
        echo ""
        
        # Détecter la distribution
        if command -v pacman &>/dev/null; then
            echo -e "  ${CYAN}sudo pacman -S wkhtmltopdf${RESET}"
            if command -v yay &>/dev/null; then
                echo -e "  ${CYAN}ou: yay -S wkhtmltopdf-static${RESET}"
            fi
        elif command -v apt &>/dev/null; then
            echo -e "  ${CYAN}sudo apt install wkhtmltopdf${RESET}"
        elif command -v dnf &>/dev/null; then
            echo -e "  ${CYAN}sudo dnf install wkhtmltopdf${RESET}"
        else
            echo -e "  ${CYAN}Installez wkhtmltopdf pour votre distribution${RESET}"
        fi
        return 1
    fi
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║              CONVERSION MARKDOWN → PDF                        ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    echo -e "${BLUE}📄 Fichier d'entrée:${RESET} $input_file"
    echo -e "${BLUE}📄 Fichier de sortie:${RESET} $output_file"
    echo -e "${BLUE}🎨 Style:${RESET} $style"
    echo ""
    
    # Créer le répertoire de sortie si nécessaire
    local output_dir=$(dirname "$output_file")
    if [ "$output_dir" != "." ] && [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
        echo -e "${GREEN}✓ Répertoire créé: $output_dir${RESET}"
    fi
    
    # Créer un fichier HTML temporaire
    local temp_html=$(mktemp --suffix=.html)
    
    # Étape 1: Conversion Markdown → HTML avec pandoc
    echo -e "${YELLOW}🔄 Étape 1/2: Conversion Markdown → HTML...${RESET}"
    if ! pandoc "$input_file" -o "$temp_html" --from markdown-smart --standalone --toc --toc-depth=3 --number-sections 2>&1; then
        echo -e "${RED}✗ Erreur lors de la conversion Markdown → HTML${RESET}" >&2
        rm -f "$temp_html"
        return 1
    fi
    
    # Étape 2: Conversion HTML → PDF avec wkhtmltopdf
    echo -e "${YELLOW}🔄 Étape 2/2: Conversion HTML → PDF...${RESET}"
    if ! wkhtmltopdf --encoding UTF-8 --enable-local-file-access "$temp_html" "$output_file" 2>&1; then
        echo -e "${RED}✗ Erreur lors de la conversion HTML → PDF${RESET}" >&2
        rm -f "$temp_html"
        return 1
    fi
    
    # Nettoyer le fichier HTML temporaire
    rm -f "$temp_html"
    
    echo ""
    echo -e "${GREEN}✅ Conversion réussie!${RESET}"
    echo -e "${GREEN}📄 PDF créé: $output_file${RESET}"
    
    # Afficher la taille du fichier
    if command -v du &>/dev/null; then
        local file_size=$(du -h "$output_file" | cut -f1)
        echo -e "${CYAN}📊 Taille: $file_size${RESET}"
    fi
    
    # Ouvrir le PDF si demandé
    if [ "$open_after" = true ]; then
        echo ""
        echo -e "${CYAN}🔓 Ouverture du PDF...${RESET}"
        if command -v xdg-open &>/dev/null; then
            xdg-open "$output_file" 2>/dev/null &
        elif command -v open &>/dev/null; then
            open "$output_file" 2>/dev/null &
        elif command -v evince &>/dev/null; then
            evince "$output_file" 2>/dev/null &
        else
            echo -e "${YELLOW}⚠️  Aucun visualiseur PDF trouvé${RESET}"
        fi
    fi
    
    return 0
}

# Alias (seulement si convert n'est pas déjà défini)
if ! command -v convert &>/dev/null || [[ "$(which convert 2>/dev/null)" == *"md2pdf"* ]]; then
    alias convert='md2pdf'
fi

