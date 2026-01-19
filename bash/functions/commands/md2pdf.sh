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
            echo -e "  ${CYAN}sudo pacman -S pandoc texlive-core texlive-bin${RESET}"
        elif command -v apt &>/dev/null; then
            echo -e "  ${CYAN}sudo apt install pandoc texlive-latex-base texlive-latex-extra${RESET}"
        elif command -v dnf &>/dev/null; then
            echo -e "  ${CYAN}sudo dnf install pandoc texlive-scheme-basic${RESET}"
        else
            echo -e "  ${CYAN}Installez pandoc et un moteur LaTeX pour votre distribution${RESET}"
        fi
        return 1
    fi
    
    # Vérifier qu'un moteur LaTeX est disponible
    if ! command -v pdflatex &>/dev/null && ! command -v xelatex &>/dev/null && ! command -v lualatex &>/dev/null; then
        echo -e "${YELLOW}⚠️  Aucun moteur LaTeX trouvé (pdflatex, xelatex, lualatex)${RESET}" >&2
        echo -e "${YELLOW}💡 Installation recommandée:${RESET}"
        echo ""
        
        if command -v pacman &>/dev/null; then
            echo -e "  ${CYAN}sudo pacman -S texlive-core texlive-bin${RESET}"
        elif command -v apt &>/dev/null; then
            echo -e "  ${CYAN}sudo apt install texlive-latex-base texlive-latex-extra${RESET}"
        elif command -v dnf &>/dev/null; then
            echo -e "  ${CYAN}sudo dnf install texlive-scheme-basic${RESET}"
        fi
        echo ""
        echo -e "${YELLOW}⚠️  Tentative de conversion sans LaTeX (peut échouer)...${RESET}"
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
    
    # Construire la commande pandoc selon le style
    local pandoc_cmd="pandoc"
    local pandoc_args=()
    
    # Options de base
    pandoc_args+=("$input_file")
    pandoc_args+=("-o" "$output_file")
    pandoc_args+=("--pdf-engine=pdflatex")
    
    # Options de style selon le choix
    case "$style" in
        github)
            pandoc_args+=("--variable=geometry:margin=2cm")
            pandoc_args+=("--variable=fontsize:11pt")
            pandoc_args+=("--variable=colorlinks:true")
            pandoc_args+=("--variable=linkcolor:blue")
            pandoc_args+=("--variable=urlcolor:blue")
            pandoc_args+=("--highlight-style=github")
            ;;
        minimal)
            pandoc_args+=("--variable=geometry:margin=3cm")
            pandoc_args+=("--variable=fontsize:12pt")
            pandoc_args+=("--variable=colorlinks:false")
            pandoc_args+=("--variable=fontfamily:times")
            pandoc_args+=("--highlight-style=tango")
            ;;
        elegant)
            pandoc_args+=("--variable=geometry:margin=2.5cm")
            pandoc_args+=("--variable=fontsize:11pt")
            pandoc_args+=("--variable=colorlinks:true")
            pandoc_args+=("--variable=linkcolor:blue")
            pandoc_args+=("--variable=fontfamily:palatino")
            pandoc_args+=("--variable=linestretch:1.2")
            pandoc_args+=("--highlight-style=pygments")
            ;;
        default|*)
            pandoc_args+=("--variable=geometry:margin=2.5cm")
            pandoc_args+=("--variable=fontsize:11pt")
            pandoc_args+=("--variable=colorlinks:true")
            pandoc_args+=("--variable=linkcolor:blue")
            pandoc_args+=("--variable=urlcolor:blue")
            pandoc_args+=("--variable=citecolor:blue")
            pandoc_args+=("--highlight-style=tango")
            pandoc_args+=("--variable=linestretch:1.1")
            ;;
    esac
    
    # Options supplémentaires pour un meilleur rendu
    pandoc_args+=("--standalone")
    pandoc_args+=("--toc")
    pandoc_args+=("--toc-depth=3")
    pandoc_args+=("--number-sections")
    
    # Afficher la commande (mode debug)
    if [ "${MD2PDF_DEBUG:-false}" = "true" ]; then
        echo -e "${CYAN}🔧 Commande:${RESET} $pandoc_cmd ${pandoc_args[*]}"
        echo ""
    fi
    
    # Exécuter la conversion
    echo -e "${YELLOW}🔄 Conversion en cours...${RESET}"
    if $pandoc_cmd "${pandoc_args[@]}" 2>&1; then
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
    else
        echo ""
        echo -e "${RED}✗ Erreur lors de la conversion${RESET}" >&2
        echo -e "${YELLOW}💡 Vérifiez que pandoc et un moteur LaTeX sont correctement installés${RESET}" >&2
        return 1
    fi
}

# Alias
alias convert='md2pdf'

