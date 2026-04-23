#!/bin/sh
# =============================================================================
# MODULEMAN - Module Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire pour activer/désactiver les modules et fonctions
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif pour activer/désactiver les modules
# USAGE: moduleman [enable|disable|list|status] [module-name]
# EXAMPLE: moduleman
# EXAMPLE: moduleman enable cyberman
# EXAMPLE: moduleman disable miscman
moduleman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # zsh sans SH_WORD_SPLIT : « for x in $liste_avec_espaces » ne boucle pas comme en sh.
    if [ -n "$ZSH_VERSION" ]; then
        setopt LOCAL_OPTIONS SH_WORD_SPLIT 2>/dev/null || true
    fi
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    MODULEMAN_DIR="$DOTFILES_DIR/zsh/functions/moduleman"
    MODULEMAN_CONFIG_DIR="$DOTFILES_DIR/.config/moduleman"
    MODULEMAN_CONFIG_FILE="$MODULEMAN_CONFIG_DIR/modules.conf"
    FUNCTIONS_DIR="$DOTFILES_DIR/zsh/functions"
    
    # Créer le répertoire de configuration si nécessaire
    mkdir -p "$MODULEMAN_CONFIG_DIR"
    
    # Charger la configuration
    load_config() {
        if [ ! -f "$MODULEMAN_CONFIG_FILE" ]; then
            create_default_config
        fi
        # Charger la configuration (support Zsh et Fish)
        while IFS= read -r line || [ -n "$line" ]; do
            # Ignorer les commentaires et lignes vides
            case "$line" in
                \#*|"") continue ;;
            esac
            
            # Parser le format Zsh (MODULE_name=enabled)
            case "$line" in
                MODULE_*=enabled|MODULE_*=disabled)
                    module_name=$(echo "$line" | cut -d= -f1 | sed 's/^MODULE_//')
                    _mod_state=$(echo "$line" | cut -d= -f2)
                    eval "MODULE_${module_name}=${_mod_state}"
                    ;;
                set\ -g\ MODULE_*\ enabled|set\ -g\ MODULE_*\ disabled)
                    # Format Fish
                    module_name=$(echo "$line" | awk '{print $3}' | sed 's/^MODULE_//')
                    _mod_state=$(echo "$line" | awk '{print $4}')
                    eval "MODULE_${module_name}=${_mod_state}"
                    ;;
            esac
        done < "$MODULEMAN_CONFIG_FILE"
    }
    
    # Créer la configuration par défaut
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
MODULE_testzshman=enabled
MODULE_testman=enabled
MODULE_doctorman=enabled
EOF
    }
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  MODULEMAN - MODULE MANAGER                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour obtenir le statut d'un module
    get_module_status() {
        module_name="$1"
        var_name="MODULE_${module_name}"
        _mod_state=
        # zsh + nounset : lire une variable MODULE_* absente du config fait échouer eval seul.
        eval "_mod_state=\$$var_name" 2>/dev/null || _mod_state=
        echo "${_mod_state:-enabled}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}📦 GESTION DES MODULES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        load_config
        
        # Liste des managers (format: name:description)
        # Heredoc: zsh -n rejette une chaîne "…" multiligne ici (lexer différent de bash/sh).
        managers=$(cat <<'MODULEMAN_LIST_EOF'
pathman:PATHMAN - Gestionnaire PATH
netman:NETMAN - Gestionnaire réseau
aliaman:ALIAMAN - Gestionnaire alias
miscman:MISCMAN - Gestionnaire divers
searchman:SEARCHMAN - Gestionnaire recherche
cyberman:CYBERMAN - Gestionnaire cybersécurité
devman:DEVMAN - Gestionnaire développement
gitman:GITMAN - Gestionnaire Git
helpman:HELPMAN - Gestionnaire aide/documentation
manman:MANMAN - Manager of Managers
configman:CONFIGMAN - Gestionnaire configurations
installman:INSTALLMAN - Gestionnaire installations
moduleman:MODULEMAN - Gestionnaire modules (ce menu)
fileman:FILEMAN - Gestionnaire fichiers
virtman:VIRTMAN - Gestionnaire virtualisation
sshman:SSHMAN - Gestionnaire SSH
testzshman:TESTZSHMAN - Gestionnaire tests ZSH/dotfiles
testman:TESTMAN - Gestionnaire tests applications
doctorman:DOCTORMAN - Diagnostic dotfiles / dev
MODULEMAN_LIST_EOF
)
        
        index=1
        echo "$managers" | while IFS=: read -r manager_name manager_desc; do
            _mod_state=$(get_module_status "$manager_name")
            if [ "$_mod_state" = "enabled" ]; then
                printf "${GREEN}%d.${RESET} %s ${GREEN}[ACTIVÉ]${RESET}\n" "$index" "$manager_desc"
            else
                printf "${RED}%d.${RESET} %s ${RED}[DÉSACTIVÉ]${RESET}\n" "$index" "$manager_desc"
            fi
            index=$((index + 1))
        done
        
        echo ""
        printf "${YELLOW}0.${RESET} Quitter\n"
        echo ""
        printf "Choix: "
        read choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            0) return 0 ;;
            [1-9]|1[0-9])
                selected_index=$choice
                manager_index=1
                echo "$managers" | while IFS=: read -r manager_name manager_desc; do
                    if [ "$manager_index" -eq "$selected_index" ]; then
                        toggle_module "$manager_name"
                        break
                    fi
                    manager_index=$((manager_index + 1))
                done
                ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
        
        # Retourner au menu après action
        echo ""
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Fonction pour activer/désactiver un module
    toggle_module() {
        module_name="$1"
        load_config
        _mod_state=$(get_module_status "$module_name")
        
        if [ "$_mod_state" = "enabled" ]; then
            disable_module "$module_name"
        else
            enable_module "$module_name"
        fi
    }
    
    # Fonction pour activer un module
    enable_module() {
        module_name="$1"
        
        # Mettre à jour le fichier de configuration (format Zsh)
        if grep -q "^MODULE_${module_name}=" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            if [ "$(uname)" = "Darwin" ]; then
                sed -i '' "s/^MODULE_${module_name}=.*/MODULE_${module_name}=enabled/" "$MODULEMAN_CONFIG_FILE"
            else
                sed -i "s/^MODULE_${module_name}=.*/MODULE_${module_name}=enabled/" "$MODULEMAN_CONFIG_FILE"
            fi
        # Ou format Fish
        elif grep -q "^set -g MODULE_${module_name}" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            if [ "$(uname)" = "Darwin" ]; then
                sed -i '' "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} enabled/" "$MODULEMAN_CONFIG_FILE"
            else
                sed -i "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} enabled/" "$MODULEMAN_CONFIG_FILE"
            fi
        else
            # Ajouter en format Zsh (par défaut)
            echo "MODULE_${module_name}=enabled" >> "$MODULEMAN_CONFIG_FILE"
        fi
        
        printf "${GREEN}✓ Module %s activé${RESET}\n" "$module_name"
        printf "${YELLOW}⚠️  Rechargez votre shell (source ~/.zshrc ou source ~/.config/fish/config.fish) pour appliquer les changements${RESET}\n"
    }
    
    # Fonction pour désactiver un module
    disable_module() {
        module_name="$1"
        
        # Mettre à jour le fichier de configuration (format Zsh)
        if grep -q "^MODULE_${module_name}=" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            if [ "$(uname)" = "Darwin" ]; then
                sed -i '' "s/^MODULE_${module_name}=.*/MODULE_${module_name}=disabled/" "$MODULEMAN_CONFIG_FILE"
            else
                sed -i "s/^MODULE_${module_name}=.*/MODULE_${module_name}=disabled/" "$MODULEMAN_CONFIG_FILE"
            fi
        # Ou format Fish
        elif grep -q "^set -g MODULE_${module_name}" "$MODULEMAN_CONFIG_FILE" 2>/dev/null; then
            if [ "$(uname)" = "Darwin" ]; then
                sed -i '' "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} disabled/" "$MODULEMAN_CONFIG_FILE"
            else
                sed -i "s/^set -g MODULE_${module_name}.*/set -g MODULE_${module_name} disabled/" "$MODULEMAN_CONFIG_FILE"
            fi
        else
            # Ajouter en format Zsh (par défaut)
            echo "MODULE_${module_name}=disabled" >> "$MODULEMAN_CONFIG_FILE"
        fi
        
        printf "${RED}✓ Module %s désactivé${RESET}\n" "$module_name"
        printf "${YELLOW}⚠️  Rechargez votre shell (source ~/.zshrc ou source ~/.config/fish/config.fish) pour appliquer les changements${RESET}\n"
    }
    
    # Si un argument est fourni, exécuter la commande directement
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log moduleman "$@"
        case "$1" in
            enable|activer)
                if [ -n "$2" ]; then
                    enable_module "$2"
                else
                    printf "${RED}Usage: moduleman enable <module-name>${RESET}\n"
                    return 1
                fi
                ;;
            disable|désactiver)
                if [ -n "$2" ]; then
                    disable_module "$2"
                else
                    printf "${RED}Usage: moduleman disable <module-name>${RESET}\n"
                    return 1
                fi
                ;;
            list|liste)
                load_config
                printf "${CYAN}Modules disponibles:${RESET}\n"
                managers_list="pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman fileman virtman sshman testzshman testman doctorman"
                for manager in $managers_list; do
                    _mod_state=$(get_module_status "$manager")
                    if [ "$_mod_state" = "enabled" ]; then
                        printf "  ${GREEN}✓${RESET} %s [ACTIVÉ]\n" "$manager"
                    else
                        printf "  ${RED}✗${RESET} %s [DÉSACTIVÉ]\n" "$manager"
                    fi
                done
                ;;
            status|statut)
                load_config
                printf "${CYAN}Statut des modules:${RESET}\n"
                managers_list="pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman fileman virtman sshman testzshman testman doctorman"
                for manager in $managers_list; do
                    _mod_state=$(get_module_status "$manager")
                    if [ "$_mod_state" = "enabled" ]; then
                        printf "  ${GREEN}✓${RESET} %s\n" "$manager"
                    else
                        printf "  ${RED}✗${RESET} %s\n" "$manager"
                    fi
                done
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
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
