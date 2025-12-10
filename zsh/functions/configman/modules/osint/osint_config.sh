#!/bin/bash
# =============================================================================
# OSINT CONFIG - Configuration des outils OSINT
# =============================================================================
# Description: Configuration des clés API et paramètres pour outils OSINT
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Répertoires
CONFIG_DIR="$HOME/.cyberman/config"
CONFIG_FILE="$CONFIG_DIR/osint.conf"
ENV_FILE="$HOME/.env"

# Créer le répertoire de configuration
mkdir -p "$CONFIG_DIR"

# DESC: Menu principal de configuration OSINT
# USAGE: show_osint_config_menu
# EXAMPLE: show_osint_config_menu
show_osint_config_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║          CONFIGURATION OUTILS OSINT                          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}\n"
        
        echo -e "${YELLOW}${BOLD}🔑 CLÉS API (optionnelles)${NC}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}\n"
        
        echo "1.  OpenAI API Key          (pour DarkGPT, Robin, OSINT-LLM)"
        echo "2.  DeHashed API Key        (pour DarkGPT)"
        echo "3.  Shodan API Key          (pour SpiderFoot)"
        echo "4.  VirusTotal API Key      (pour SpiderFoot)"
        echo "5.  GitHub Token            (pour certains outils)"
        echo ""
        echo -e "${YELLOW}${BOLD}⚙️  CONFIGURATION OUTILS${NC}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}\n"
        echo "6.  Configurer Ollama       (modèle LLM local)"
        echo "7.  Configurer Taranis AI   (paramètres NLP)"
        echo "8.  Configurer SpiderFoot   (modules et sources)"
        echo ""
        echo -e "${YELLOW}${BOLD}📋 AFFICHAGE & VÉRIFICATION${NC}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}\n"
        echo "9.  Afficher configuration actuelle"
        echo "10. Vérifier clés API configurées"
        echo "11. Tester connexions API"
        echo ""
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1) config_openai_key ;;
            2) config_dehashed_key ;;
            3) config_shodan_key ;;
            4) config_virustotal_key ;;
            5) config_github_token ;;
            6) config_ollama ;;
            7) config_taranis_ai ;;
            8) config_spiderfoot ;;
            9) show_current_config ;;
            10) check_api_keys ;;
            11) test_api_connections ;;
            0) return 0 ;;
            *) echo -e "${RED}Choix invalide${NC}"; sleep 1 ;;
        esac
    done
}

# DESC: Configure la clé API OpenAI
# USAGE: config_openai_key
config_openai_key() {
    echo ""
    echo -e "${CYAN}Configuration OpenAI API Key${NC}"
    echo -e "${YELLOW}Utilisée par: DarkGPT, Robin, OSINT-LLM${NC}\n"
    
    # Vérifier si déjà configurée
    if [ -f "$CONFIG_FILE" ] && grep -q "OPENAI_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        local current_key=$(grep "OPENAI_API_KEY" "$CONFIG_FILE" | cut -d'"' -f2 | head -c 10)
        echo -e "${GREEN}Clé actuelle: ${current_key}...${NC}"
        printf "Remplacer? (o/N): "
        read -r replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    printf "Entrez votre OpenAI API Key (sk-...): "
    read -r api_key
    
    if [ -z "$api_key" ]; then
        echo -e "${YELLOW}Configuration annulée${NC}"
        return 1
    fi
    
    # Ajouter ou remplacer dans le fichier de config
    if [ -f "$CONFIG_FILE" ] && grep -q "OPENAI_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s|export OPENAI_API_KEY=.*|export OPENAI_API_KEY=\"$api_key\"|" "$CONFIG_FILE"
    else
        echo "export OPENAI_API_KEY=\"$api_key\"" >> "$CONFIG_FILE"
    fi
    
    # Ajouter aussi dans .env si existe
    if [ -f "$ENV_FILE" ]; then
        if grep -q "OPENAI_API_KEY" "$ENV_FILE" 2>/dev/null; then
            sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$api_key|" "$ENV_FILE"
        else
            echo "OPENAI_API_KEY=$api_key" >> "$ENV_FILE"
        fi
    fi
    
    echo -e "${GREEN}✓ OpenAI API Key configurée${NC}"
    echo -e "${YELLOW}💡 Rechargez votre shell ou sourcez $CONFIG_FILE${NC}"
    sleep 2
}

# DESC: Configure la clé API DeHashed
# USAGE: config_dehashed_key
config_dehashed_key() {
    echo ""
    echo -e "${CYAN}Configuration DeHashed API Key${NC}"
    echo -e "${YELLOW}Utilisée par: DarkGPT${NC}\n"
    
    if [ -f "$CONFIG_FILE" ] && grep -q "DEHASHED_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        local current_key=$(grep "DEHASHED_API_KEY" "$CONFIG_FILE" | cut -d'"' -f2 | head -c 10)
        echo -e "${GREEN}Clé actuelle: ${current_key}...${NC}"
        printf "Remplacer? (o/N): "
        read -r replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    printf "Entrez votre DeHashed API Key: "
    read -r api_key
    
    if [ -z "$api_key" ]; then
        echo -e "${YELLOW}Configuration annulée${NC}"
        return 1
    fi
    
    if [ -f "$CONFIG_FILE" ] && grep -q "DEHASHED_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s|export DEHASHED_API_KEY=.*|export DEHASHED_API_KEY=\"$api_key\"|" "$CONFIG_FILE"
    else
        echo "export DEHASHED_API_KEY=\"$api_key\"" >> "$CONFIG_FILE"
    fi
    
    echo -e "${GREEN}✓ DeHashed API Key configurée${NC}"
    sleep 2
}

# DESC: Configure la clé API Shodan
# USAGE: config_shodan_key
config_shodan_key() {
    echo ""
    echo -e "${CYAN}Configuration Shodan API Key${NC}"
    echo -e "${YELLOW}Utilisée par: SpiderFoot${NC}\n"
    
    if [ -f "$CONFIG_FILE" ] && grep -q "SHODAN_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        local current_key=$(grep "SHODAN_API_KEY" "$CONFIG_FILE" | cut -d'"' -f2 | head -c 10)
        echo -e "${GREEN}Clé actuelle: ${current_key}...${NC}"
        printf "Remplacer? (o/N): "
        read -r replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    printf "Entrez votre Shodan API Key: "
    read -r api_key
    
    if [ -z "$api_key" ]; then
        echo -e "${YELLOW}Configuration annulée${NC}"
        return 1
    fi
    
    if [ -f "$CONFIG_FILE" ] && grep -q "SHODAN_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s|export SHODAN_API_KEY=.*|export SHODAN_API_KEY=\"$api_key\"|" "$CONFIG_FILE"
    else
        echo "export SHODAN_API_KEY=\"$api_key\"" >> "$CONFIG_FILE"
    fi
    
    echo -e "${GREEN}✓ Shodan API Key configurée${NC}"
    sleep 2
}

# DESC: Configure la clé API VirusTotal
# USAGE: config_virustotal_key
config_virustotal_key() {
    echo ""
    echo -e "${CYAN}Configuration VirusTotal API Key${NC}"
    echo -e "${YELLOW}Utilisée par: SpiderFoot${NC}\n"
    
    if [ -f "$CONFIG_FILE" ] && grep -q "VT_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        local current_key=$(grep "VT_API_KEY" "$CONFIG_FILE" | cut -d'"' -f2 | head -c 10)
        echo -e "${GREEN}Clé actuelle: ${current_key}...${NC}"
        printf "Remplacer? (o/N): "
        read -r replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    printf "Entrez votre VirusTotal API Key: "
    read -r api_key
    
    if [ -z "$api_key" ]; then
        echo -e "${YELLOW}Configuration annulée${NC}"
        return 1
    fi
    
    if [ -f "$CONFIG_FILE" ] && grep -q "VT_API_KEY" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s|export VT_API_KEY=.*|export VT_API_KEY=\"$api_key\"|" "$CONFIG_FILE"
    else
        echo "export VT_API_KEY=\"$api_key\"" >> "$CONFIG_FILE"
    fi
    
    echo -e "${GREEN}✓ VirusTotal API Key configurée${NC}"
    sleep 2
}

# DESC: Configure le token GitHub
# USAGE: config_github_token
config_github_token() {
    echo ""
    echo -e "${CYAN}Configuration GitHub Token${NC}"
    echo -e "${YELLOW}Utilisé pour: Accès API GitHub (rate limits)${NC}\n"
    
    if [ -f "$CONFIG_FILE" ] && grep -q "GITHUB_TOKEN" "$CONFIG_FILE" 2>/dev/null; then
        local current_token=$(grep "GITHUB_TOKEN" "$CONFIG_FILE" | cut -d'"' -f2 | head -c 10)
        echo -e "${GREEN}Token actuel: ${current_token}...${NC}"
        printf "Remplacer? (o/N): "
        read -r replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            return 0
        fi
    fi
    
    printf "Entrez votre GitHub Token (ghp_...): "
    read -r token
    
    if [ -z "$token" ]; then
        echo -e "${YELLOW}Configuration annulée${NC}"
        return 1
    fi
    
    if [ -f "$CONFIG_FILE" ] && grep -q "GITHUB_TOKEN" "$CONFIG_FILE" 2>/dev/null; then
        sed -i "s|export GITHUB_TOKEN=.*|export GITHUB_TOKEN=\"$token\"|" "$CONFIG_FILE"
    else
        echo "export GITHUB_TOKEN=\"$token\"" >> "$CONFIG_FILE"
    fi
    
    echo -e "${GREEN}✓ GitHub Token configuré${NC}"
    sleep 2
}

# DESC: Configure Ollama
# USAGE: config_ollama
config_ollama() {
    echo ""
    echo -e "${CYAN}Configuration Ollama${NC}"
    echo -e "${YELLOW}Modèles LLM locaux pour OSINT${NC}\n"
    
    if ! command -v ollama &>/dev/null; then
        echo -e "${YELLOW}Ollama n'est pas installé${NC}"
        printf "Installer Ollama maintenant? (O/n): "
        read -r install
        install=${install:-O}
        
        if [[ "$install" =~ ^[oO]$ ]]; then
            curl -fsSL https://ollama.com/install.sh | sh
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Ollama installé${NC}"
            else
                echo -e "${RED}❌ Échec installation Ollama${NC}"
                return 1
            fi
        else
            return 1
        fi
    fi
    
    echo -e "${CYAN}Modèles recommandés pour OSINT:${NC}"
    echo "  - llama3 (8B, 70B)"
    echo "  - mistral (7B)"
    echo "  - deepseek-r1 (7B)"
    echo "  - qwen (7B, 14B)"
    echo ""
    printf "Télécharger un modèle? (O/n): "
    read -r download
    download=${download:-O}
    
    if [[ "$download" =~ ^[oO]$ ]]; then
        echo ""
        echo "Modèles disponibles:"
        echo "1. llama3:8b"
        echo "2. mistral:7b"
        echo "3. deepseek-r1:7b"
        echo "4. qwen:7b"
        echo "5. Autre (entrer manuellement)"
        echo ""
        printf "Choix: "
        read -r model_choice
        
        case "$model_choice" in
            1) ollama pull llama3:8b ;;
            2) ollama pull mistral:7b ;;
            3) ollama pull deepseek-r1:7b ;;
            4) ollama pull qwen:7b ;;
            5)
                printf "Nom du modèle (ex: llama3:70b): "
                read -r custom_model
                if [ -n "$custom_model" ]; then
                    ollama pull "$custom_model"
                fi
                ;;
        esac
    fi
    
    echo -e "${GREEN}✓ Configuration Ollama terminée${NC}"
    sleep 2
}

# DESC: Configure Taranis AI
# USAGE: config_taranis_ai
config_taranis_ai() {
    echo ""
    echo -e "${CYAN}Configuration Taranis AI${NC}"
    echo -e "${YELLOW}Paramètres NLP et IA${NC}\n"
    
    local TARANIS_DIR="$HOME/.local/share/taranis-ai"
    
    if [ ! -d "$TARANIS_DIR" ]; then
        echo -e "${YELLOW}Taranis AI n'est pas installé${NC}"
        echo -e "${CYAN}Installez-le via: ensure_tool taranis-ai${NC}"
        sleep 2
        return 1
    fi
    
    echo -e "${CYAN}Configuration Taranis AI:${NC}"
    echo "  - Modèles ML personnalisables"
    echo "  - Paramètres de clustering"
    echo "  - Détection de termes cybersécurité"
    echo ""
    echo -e "${YELLOW}Consultez la documentation:${NC}"
    echo "  https://github.com/taranis-ai/taranis-ai"
    echo ""
    echo -e "${GREEN}✓ Configuration Taranis AI${NC}"
    sleep 2
}

# DESC: Configure SpiderFoot
# USAGE: config_spiderfoot
config_spiderfoot() {
    echo ""
    echo -e "${CYAN}Configuration SpiderFoot${NC}"
    echo -e "${YELLOW}Modules et sources de données${NC}\n"
    
    local SPIDERFOOT_DIR="$HOME/.local/share/spiderfoot"
    
    if [ ! -d "$SPIDERFOOT_DIR" ]; then
        echo -e "${YELLOW}SpiderFoot n'est pas installé${NC}"
        echo -e "${CYAN}Installez-le via: ensure_tool spiderfoot${NC}"
        sleep 2
        return 1
    fi
    
    echo -e "${CYAN}SpiderFoot dispose de 200+ modules${NC}"
    echo -e "${YELLOW}Accédez à l'interface web pour configurer:${NC}"
    echo "  http://127.0.0.1:5001"
    echo ""
    echo -e "${CYAN}Clés API à configurer dans l'interface:${NC}"
    echo "  - Shodan (si configurée)"
    echo "  - VirusTotal (si configurée)"
    echo ""
    echo -e "${GREEN}✓ Configuration SpiderFoot${NC}"
    sleep 2
}

# DESC: Affiche la configuration actuelle
# USAGE: show_current_config
show_current_config() {
    echo ""
    echo -e "${CYAN}${BOLD}Configuration OSINT actuelle${NC}\n"
    
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}Fichier: $CONFIG_FILE${NC}\n"
        # Afficher les clés (masquées)
        while IFS= read -r line; do
            if [[ "$line" =~ ^export.*API.*KEY ]] || [[ "$line" =~ ^export.*TOKEN ]]; then
                local key_name=$(echo "$line" | cut -d'=' -f1 | sed 's/export //')
                local key_value=$(echo "$line" | cut -d'"' -f2)
                if [ -n "$key_value" ]; then
                    local masked=$(echo "$key_value" | head -c 10)
                    echo -e "${GREEN}✓${NC} $key_name: ${masked}...${NC}"
                else
                    echo -e "${RED}✗${NC} $key_name: ${YELLOW}Non configuré${NC}"
                fi
            fi
        done < "$CONFIG_FILE"
    else
        echo -e "${YELLOW}Aucune configuration trouvée${NC}"
    fi
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# DESC: Vérifie les clés API configurées
# USAGE: check_api_keys
check_api_keys() {
    echo ""
    echo -e "${CYAN}${BOLD}Vérification des clés API${NC}\n"
    
    local keys=(
        "OPENAI_API_KEY:OpenAI"
        "DEHASHED_API_KEY:DeHashed"
        "SHODAN_API_KEY:Shodan"
        "VT_API_KEY:VirusTotal"
        "GITHUB_TOKEN:GitHub"
    )
    
    local configured=0
    local missing=0
    
    for key_info in "${keys[@]}"; do
        local key_name=$(echo "$key_info" | cut -d':' -f1)
        local key_display=$(echo "$key_info" | cut -d':' -f2)
        
        if [ -f "$CONFIG_FILE" ] && grep -q "$key_name" "$CONFIG_FILE" 2>/dev/null; then
            local key_value=$(grep "$key_name" "$CONFIG_FILE" | cut -d'"' -f2)
            if [ -n "$key_value" ]; then
                echo -e "${GREEN}✓${NC} $key_display: ${GREEN}Configuré${NC}"
                ((configured++))
            else
                echo -e "${RED}✗${NC} $key_display: ${YELLOW}Non configuré${NC}"
                ((missing++))
            fi
        else
            echo -e "${RED}✗${NC} $key_display: ${YELLOW}Non configuré${NC}"
            ((missing++))
        fi
    done
    
    echo ""
    echo -e "${CYAN}Résumé:${NC}"
    echo -e "  ${GREEN}Configurées: $configured${NC}"
    echo -e "  ${YELLOW}Manquantes: $missing${NC}"
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# DESC: Teste les connexions API
# USAGE: test_api_connections
test_api_connections() {
    echo ""
    echo -e "${CYAN}${BOLD}Test des connexions API${NC}\n"
    
    # Charger la config
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE" 2>/dev/null
    fi
    
    # Test OpenAI
    if [ -n "$OPENAI_API_KEY" ]; then
        echo -e "${CYAN}Test OpenAI API...${NC}"
        local response=$(curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models 2>/dev/null | head -c 100)
        if [ -n "$response" ] && [[ "$response" =~ "data" ]]; then
            echo -e "${GREEN}✓ OpenAI API: OK${NC}"
        else
            echo -e "${RED}✗ OpenAI API: Erreur${NC}"
        fi
    else
        echo -e "${YELLOW}⊘ OpenAI API: Non configuré${NC}"
    fi
    
    # Test Shodan
    if [ -n "$SHODAN_API_KEY" ]; then
        echo -e "${CYAN}Test Shodan API...${NC}"
        local response=$(curl -s "https://api.shodan.io/api-info?key=$SHODAN_API_KEY" 2>/dev/null | head -c 100)
        if [ -n "$response" ] && [[ "$response" =~ "plan" ]]; then
            echo -e "${GREEN}✓ Shodan API: OK${NC}"
        else
            echo -e "${RED}✗ Shodan API: Erreur${NC}"
        fi
    else
        echo -e "${YELLOW}⊘ Shodan API: Non configuré${NC}"
    fi
    
    # Test VirusTotal
    if [ -n "$VT_API_KEY" ]; then
        echo -e "${CYAN}Test VirusTotal API...${NC}"
        local response=$(curl -s -H "x-apikey: $VT_API_KEY" https://www.virustotal.com/api/v3/user 2>/dev/null | head -c 100)
        if [ -n "$response" ] && [[ "$response" =~ "data" ]]; then
            echo -e "${GREEN}✓ VirusTotal API: OK${NC}"
        else
            echo -e "${RED}✗ VirusTotal API: Erreur${NC}"
        fi
    else
        echo -e "${YELLOW}⊘ VirusTotal API: Non configuré${NC}"
    fi
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Lancer le menu si exécuté directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    show_osint_config_menu
fi

