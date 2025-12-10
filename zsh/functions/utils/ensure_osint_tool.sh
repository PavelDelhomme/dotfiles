#!/bin/bash
################################################################################
# UTILITAIRE: ensure_osint_tool - Vérifie et installe des outils OSINT depuis GitHub
# Usage: source ensure_osint_tool.sh
#        ensure_osint_tool <tool_name> [github_repo] [install_dir]
#
# Description:
#   Vérifie si un outil OSINT est installé et propose de l'installer depuis GitHub.
#   Gère les installations Python, Go, et autres depuis GitHub.
################################################################################

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Mapping des outils OSINT vers leurs repos GitHub
# DESC: Retourne le repo GitHub pour un outil OSINT
# USAGE: get_osint_github_repo <tool_name>
# EXAMPLE: get_osint_github_repo sherlock
get_osint_github_repo() {
    local tool="$1"
    
    case "$tool" in
        sherlock|sherlock-project)
            echo "sherlock-project/sherlock"
            ;;
        theharvester|theHarvester)
            echo "laramies/theHarvester"
            ;;
        recon-ng|recon_ng)
            echo "lanmaster53/recon-ng"
            ;;
        spiderfoot|spiderFoot)
            echo "smicallef/spiderfoot"
            ;;
        taranis-ai|taranis_ai|taranis)
            echo "taranis-ai/taranis-ai"
            ;;
        gosearch|go-search)
            echo "GoSearch-OSINT/GoSearch"
            ;;
        darkgpt|dark_gpt|DarkGPT)
            echo "luijait/DarkGPT"
            ;;
        robin)
            echo "apurvsinghgautam/robin"
            ;;
        osint-llm|osint_llm|osintllm)
            echo "mouna23/OSINT-with-LLM"
            ;;
        ollama)
            echo "ollama/ollama"
            ;;
        *)
            echo ""
            ;;
    esac
}

# DESC: Vérifie si un outil OSINT est installé
# USAGE: check_osint_tool_installed <tool_name> [install_dir]
# EXAMPLE: check_osint_tool_installed sherlock
check_osint_tool_installed() {
    local tool="$1"
    local install_dir="${2:-$HOME/.local/share}"
    
    # Vérifier si la commande existe
    if command -v "$tool" &>/dev/null; then
        return 0
    fi
    
    # Vérifier les emplacements communs
    case "$tool" in
        sherlock|sherlock-project)
            if [ -d "$install_dir/sherlock" ] && [ -f "$install_dir/sherlock/sherlock.py" ]; then
                return 0
            fi
            ;;
        theharvester|theHarvester)
            if [ -d "$install_dir/theHarvester" ] && [ -f "$install_dir/theHarvester/theHarvester.py" ]; then
                return 0
            fi
            ;;
        recon-ng|recon_ng)
            if [ -d "$install_dir/recon-ng" ] && [ -f "$install_dir/recon-ng/recon-ng" ]; then
                return 0
            fi
            ;;
        spiderfoot|spiderFoot)
            if [ -d "$install_dir/spiderfoot" ] && [ -f "$install_dir/spiderfoot/sf.py" ]; then
                return 0
            fi
            ;;
        taranis-ai|taranis_ai|taranis)
            if [ -d "$install_dir/taranis-ai" ]; then
                return 0
            fi
            ;;
        gosearch|go-search)
            if [ -d "$install_dir/gosearch" ] || command -v gosearch &>/dev/null; then
                return 0
            fi
            ;;
        darkgpt|dark_gpt|DarkGPT)
            if [ -d "$install_dir/darkgpt" ] || [ -d "$install_dir/DarkGPT" ]; then
                return 0
            fi
            ;;
        robin)
            if [ -d "$install_dir/robin" ]; then
                return 0
            fi
            ;;
        osint-llm|osint_llm|osintllm)
            if [ -d "$install_dir/osint-llm" ] || [ -d "$install_dir/OSINT-with-LLM" ]; then
                return 0
            fi
            ;;
        ollama)
            if command -v ollama &>/dev/null; then
                return 0
            fi
            ;;
    esac
    
    return 1
}

# DESC: Installe un outil OSINT depuis GitHub
# USAGE: install_osint_tool_from_github <tool_name> <github_repo> [install_dir]
# EXAMPLE: install_osint_tool_from_github sherlock sherlock-project/sherlock
install_osint_tool_from_github() {
    local tool="$1"
    local github_repo="$2"
    local install_dir="${3:-$HOME/.local/share}"
    local tool_dir="$install_dir/$(basename "$github_repo")"
    
    # Vérifier les prérequis
    if ! command -v git &>/dev/null; then
        echo -e "${RED}❌ git n'est pas installé${NC}"
        echo -e "${YELLOW}💡 Installez git d'abord${NC}"
        return 1
    fi
    
    # Créer le répertoire d'installation
    mkdir -p "$install_dir"
    
    # Cloner ou mettre à jour le repo
    if [ -d "$tool_dir" ]; then
        echo -e "${CYAN}📦 Mise à jour de $tool...${NC}"
        cd "$tool_dir" || return 1
        git pull --quiet 2>/dev/null || true
    else
        echo -e "${CYAN}📦 Clonage de $github_repo...${NC}"
        git clone "https://github.com/$github_repo.git" "$tool_dir" 2>/dev/null || {
            echo -e "${RED}❌ Échec du clonage${NC}"
            return 1
        }
    fi
    
    cd "$tool_dir" || return 1
    
    # Installer les dépendances selon le type d'outil
    if [ -f "requirements.txt" ]; then
        echo -e "${CYAN}📦 Installation des dépendances Python...${NC}"
        if command -v pip3 &>/dev/null; then
            pip3 install -r requirements.txt --user --quiet 2>/dev/null || {
                echo -e "${YELLOW}⚠️  Certaines dépendances ont peut-être échoué${NC}"
            }
        elif command -v pip &>/dev/null; then
            pip install -r requirements.txt --user --quiet 2>/dev/null || {
                echo -e "${YELLOW}⚠️  Certaines dépendances ont peut-être échoué${NC}"
            }
        else
            echo -e "${YELLOW}⚠️  pip/pip3 non disponible, dépendances non installées${NC}"
        fi
    fi
    
    # Compilation Go si nécessaire
    if [ -f "go.mod" ] || [ -f "main.go" ] || [ -f "*.go" ]; then
        if command -v go &>/dev/null; then
            echo -e "${CYAN}📦 Compilation Go...${NC}"
            go build -o "$(basename "$tool_dir")" . 2>/dev/null || {
                go install . 2>/dev/null || true
            }
            # Copier dans ~/.local/bin si possible
            if [ -f "$(basename "$tool_dir")" ]; then
                mkdir -p "$HOME/.local/bin"
                cp "$(basename "$tool_dir")" "$HOME/.local/bin/" 2>/dev/null || true
            fi
        fi
    fi
    
    # Installation spéciale pour Ollama
    if [ "$tool" = "ollama" ]; then
        echo -e "${CYAN}📦 Installation d'Ollama...${NC}"
        curl -fsSL https://ollama.com/install.sh | sh 2>/dev/null || {
            echo -e "${YELLOW}⚠️  Installation Ollama échouée, installez manuellement${NC}"
        }
    fi
    
    echo -e "${GREEN}✅ $tool installé avec succès dans $tool_dir${NC}"
    return 0
}

# DESC: Fonction principale pour vérifier et installer un outil OSINT
# USAGE: ensure_osint_tool <tool_name> [github_repo] [install_dir]
# EXAMPLE: ensure_osint_tool sherlock
ensure_osint_tool() {
    local tool="$1"
    local github_repo="$2"
    local install_dir="${3:-$HOME/.local/share}"
    
    if [ -z "$tool" ]; then
        echo -e "${RED}❌ Usage: ensure_osint_tool <tool_name> [github_repo] [install_dir]${NC}"
        return 1
    fi
    
    # Vérifier si déjà installé
    if check_osint_tool_installed "$tool" "$install_dir"; then
        return 0
    fi
    
    # Obtenir le repo GitHub si non fourni
    if [ -z "$github_repo" ]; then
        github_repo=$(get_osint_github_repo "$tool")
        if [ -z "$github_repo" ]; then
            echo -e "${YELLOW}⚠️  Repo GitHub inconnu pour $tool${NC}"
            echo -e "${CYAN}💡 Fournissez le repo GitHub: ensure_osint_tool $tool owner/repo${NC}"
            return 1
        fi
    fi
    
    # Proposer l'installation
    echo ""
    echo -e "${YELLOW}⚠️  L'outil OSINT '${BOLD}$tool${NC}${YELLOW}' n'est pas installé${NC}"
    echo -e "${CYAN}📦 Repo GitHub: ${BOLD}$github_repo${NC}"
    echo ""
    printf "${CYAN}💡 Voulez-vous installer $tool depuis GitHub? (O/n) [défaut: O]: ${NC}"
    read -r install_choice
    install_choice=${install_choice:-O}
    
    if [[ ! "$install_choice" =~ ^[oO]$ ]]; then
        echo -e "${YELLOW}⚠️  Installation annulée${NC}"
        return 1
    fi
    
    # Installer
    if install_osint_tool_from_github "$tool" "$github_repo" "$install_dir"; then
        echo -e "${GREEN}✅ $tool prêt à être utilisé${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Échec de l'installation de $tool${NC}"
        return 1
    fi
}

# Exporter les fonctions
if [ -n "$BASH_VERSION" ]; then
    export -f ensure_osint_tool
    export -f check_osint_tool_installed
    export -f install_osint_tool_from_github
    export -f get_osint_github_repo
fi

