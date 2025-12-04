#!/bin/zsh
# =============================================================================
# MODULEMAN - Module Manager pour ZSH
# =============================================================================
# Description: Gestionnaire pour activer/désactiver les modules et fonctions
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
MODULEMAN_DIR="${MODULEMAN_DIR:-$HOME/dotfiles/zsh/functions/moduleman}"
MODULEMAN_CONFIG_DIR="$HOME/dotfiles/.config/moduleman"
MODULEMAN_CONFIG_FILE="$MODULEMAN_CONFIG_DIR/modules.conf"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"

# Créer le répertoire de configuration si nécessaire
mkdir -p "$MODULEMAN_CONFIG_DIR"

# DESC: Gestionnaire interactif pour activer/désactiver les modules
# USAGE: moduleman [enable|disable|list|status] [module-name]
# EXAMPLE: moduleman
# EXAMPLE: moduleman enable cyberman
# EXAMPLE: moduleman disable miscman
moduleman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Charger la configuration
    load_config() {
        if [ ! -f "$MODULEMAN_CONFIG_FILE" ]; then
            # Créer un fichier de configuration par défaut (tous activés)
            create_default_config
        fi
        # Charger la configuration (support Zsh et Fish)
        # Format Zsh: MODULE_name=enabled
        # Format Fish: set -g MODULE_name enabled
        while IFS= read -r line || [ -n "$line" ]; do
            # Ignorer les commentaires et lignes vides
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$line" ]] && continue
            
            # Parser le format Zsh (MODULE_name=enabled)
            if [[ "$line" =~ ^MODULE_([^=]+)=(enabled|disabled)$ ]]; then
                local module_name="${match[1]}"
                local status="${match[2]}"
                eval "MODULE_${module_name}=${status}"
            # Parser le format Fish (set -g MODULE_name enabled)
            elif [[ "$line" =~ ^set[[:space:]]+-g[[:space:]]+MODULE_([^[:space:]]+)[[:space:]]+(enabled|disabled)$ ]]; then
                local module_name="${match[1]}"
                local status="${match[2]}"
                eval "MODULE_${module_name}=${status}"
            fi
        done < "$MODULEMAN_CONFIG_FILE"
    }
    
    # Créer la configuration par défaut (format compatible Zsh et Fish)
    create_default_config() {
        cat > "$MODULEMAN_CONFIG_FILE" <<'EOF'
# Configuration des modules - Moduleman
# Format compatible Zsh et Fish
# Zsh: MODULE_<nom>=enabled|disabled
# Fish: set -g MODULE_<nom> enabled|disabled
# Tous les modules sont activés par défaut

MODULE_pathman=enabled
MODULE_netman=enabled
MODULE_aliaman=enabled
MODULE_miscman=enabled
MODULE_searchman=enabled
MODULE_cyberman=enabled
MODULE_devman=enabled
MODULE_gitman=enabled
MODULE_helpman=enabled
MODULE_manman=enabled
MODULE_configman=enabled
MODULE_installman=enabled
MODULE_moduleman=enabled
MODULE_fileman=enabled
MODULE_virtman=enabled
MODULE_sshman=enabled
EOF
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  MODULEMAN - MODULE MANAGER                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}📦 GESTION DES MODULES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        load_config
        
        # Lister tous les managers disponibles
        local managers=(
            "pathman:PATHMAN - Gestionnaire PATH"
            "netman:NETMAN - Gestionnaire réseau"
            "aliaman:ALIAMAN - Gestionnaire alias"
            "miscman:MISCMAN - Gestionnaire divers"
            "searchman:SEARCHMAN - Gestionnaire recherche"
            "cyberman:CYBERMAN - Gestionnaire cybersécurité"
            "devman:DEVMAN - Gestionnaire développement"
            "gitman:GITMAN - Gestionnaire Git"
            "helpman:HELPMAN - Gestionnaire aide/documentation"
            "manman:MANMAN - Manager of Managers"
            "configman:CONFIGMAN - Gestionnaire configurations"
            "installman:INSTALLMAN - Gestionnaire installations"
            "moduleman:MODULEMAN - Gestionnaire modules (ce menu)"
        )
        
        local index=1
        for manager_info in "${managers[@]}"; do
            local manager_name="${manager_info%%:*}"
            local manager_desc="${manager_info#*:}"
            local var_name="MODULE_${manager_name}"
            local status="${(P)var_name:-enabled}"
            
            if [ "$status" = "enabled" ]; then
                echo -e "${GREEN}$index.${RESET} $manager_desc ${GREEN}[ACTIVÉ]${RESET}"
            else
                echo -e "${RED}$index.${RESET} $manager_desc ${RED}[DÉSACTIVÉ]${RESET}"
            fi
            ((index++))
        done
        
        echo ""
        echo -e "${YELLOW}0.${RESET} Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            0)
                return 0
                ;;
            [1-9]|1[0-6])
                local selected_index=$choice
                local manager_index=1
                for manager_info in "${managers[@]}"; do
                    if [ $manager_index -eq $selected_index ]; then
                        local manager_name="${manager_info%%:*}"
                        toggle_module "$manager_name"
                        break
                    fi
                    ((manager_index++))
                done
                ;;
            *)
                echo -e "${RED}Choix invalide${RESET}"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        echo ""
        read -k 1 "?Appuyez sur une touche pour continuer... "
        moduleman
    }
    
    # Fonction pour activer/désactiver un module
    toggle_module() {
        local module_name="$1"
        local var_name="MODULE_${module_name}"
        load_config
        local current_status="${(P)var_name:-enabled}"
        
        if [ "$current_status" = "enabled" ]; then
            disable_module "$module_name"
        else
            enable_module "$module_name"
        fi
    }
    
    # Fonction pour activer un module
    enable_module() {
        local module_name="$1"
        local var_name="MODULE_${module_name}"
        
        # Mettre à jour le fichier de configuration (format Zsh)
        if grep -q "^MODULE_${module_name}=" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            sed -i "s/^MODULE_${module_name}=.*/MODULE_${module_name}=enabled/" "$MODULEMAN_CONFIG_FILE"
        # Ou format Fish
        elif grep -q "^set -g MODULE_${module_name}" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            sed -i "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} enabled/" "$MODULEMAN_CONFIG_FILE"
        else
            # Ajouter en format Zsh (par défaut)
            echo "MODULE_${module_name}=enabled" >> "$MODULEMAN_CONFIG_FILE"
        fi
        
        echo -e "${GREEN}✓ Module $module_name activé${RESET}"
        echo -e "${YELLOW}⚠️  Rechargez votre shell (source ~/.zshrc ou source ~/.config/fish/config.fish) pour appliquer les changements${RESET}"
    }
    
    # Fonction pour désactiver un module
    disable_module() {
        local module_name="$1"
        local var_name="MODULE_${module_name}"
        
        # Mettre à jour le fichier de configuration (format Zsh)
        if grep -q "^MODULE_${module_name}=" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            sed -i "s/^MODULE_${module_name}=.*/MODULE_${module_name}=disabled/" "$MODULEMAN_CONFIG_FILE"
        # Ou format Fish
        elif grep -q "^set -g MODULE_${module_name}" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            sed -i "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} disabled/" "$MODULEMAN_CONFIG_FILE"
        else
            # Ajouter en format Zsh (par défaut)
            echo "MODULE_${module_name}=disabled" >> "$MODULEMAN_CONFIG_FILE"
        fi
        
        echo -e "${RED}✓ Module $module_name désactivé${RESET}"
        echo -e "${YELLOW}⚠️  Rechargez votre shell (source ~/.zshrc ou source ~/.config/fish/config.fish) pour appliquer les changements${RESET}"
    }
    
    # Si un argument est fourni, exécuter la commande directement
    if [ -n "$1" ]; then
        case "$1" in
            enable|activer)
                if [ -n "$2" ]; then
                    enable_module "$2"
                else
                    echo -e "${RED}Usage: moduleman enable <module-name>${RESET}"
                    return 1
                fi
                ;;
            disable|désactiver)
                if [ -n "$2" ]; then
                    disable_module "$2"
                else
                    echo -e "${RED}Usage: moduleman disable <module-name>${RESET}"
                    return 1
                fi
                ;;
            list|liste)
                load_config
                echo -e "${CYAN}Modules disponibles:${RESET}"
                local managers=("pathman" "netman" "aliaman" "miscman" "searchman" "cyberman" "devman" "gitman" "helpman" "manman" "configman" "installman" "moduleman" "fileman" "virtman" "sshman")
                for manager in "${managers[@]}"; do
                    local var_name="MODULE_${manager}"
                    local status="${(P)var_name:-enabled}"
                    if [ "$status" = "enabled" ]; then
                        echo -e "  ${GREEN}✓${RESET} $manager [ACTIVÉ]"
                    else
                        echo -e "  ${RED}✗${RESET} $manager [DÉSACTIVÉ]"
                    fi
                done
                ;;
            status|statut)
                load_config
                echo -e "${CYAN}Statut des modules:${RESET}"
                local managers=("pathman" "netman" "aliaman" "miscman" "searchman" "cyberman" "devman" "gitman" "helpman" "manman" "configman" "installman" "moduleman" "fileman" "virtman" "sshman")
                for manager in "${managers[@]}"; do
                    local var_name="MODULE_${manager}"
                    local status="${(P)var_name:-enabled}"
                    if [ "$status" = "enabled" ]; then
                        echo -e "  ${GREEN}✓${RESET} $manager"
                    else
                        echo -e "  ${RED}✗${RESET} $manager"
                    fi
                done
                ;;
            *)
                echo -e "${RED}Commande inconnue: $1${RESET}"
                echo ""
                echo "Commandes disponibles:"
                echo "  moduleman                    # Menu interactif"
                echo "  moduleman enable <module>    # Activer un module"
                echo "  moduleman disable <module>   # Désactiver un module"
                echo "  moduleman list                # Lister tous les modules"
                echo "  moduleman status              # Afficher le statut"
                return 1
                ;;
        esac
    else
        # Mode interactif
        while true; do
            show_main_menu
        done
    fi
}

# Alias
alias mm='moduleman'
alias modman='moduleman'

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "⚙️  MODULEMAN chargé - Tapez 'moduleman' ou 'mm' pour démarrer"

