#!/bin/zsh
# =============================================================================
# SSMAN - SSH Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des connexions SSH, clés, et configurations
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
SSHMAN_DIR="${SSHMAN_DIR:-$HOME/dotfiles/zsh/functions/sshman}"
SSHMAN_MODULES_DIR="$SSHMAN_DIR/modules"
SSHMAN_UTILS_DIR="$SSHMAN_DIR/utils"

# Charger les utilitaires
if [ -d "$SSHMAN_UTILS_DIR" ]; then
    # Utiliser null_glob pour éviter l'erreur si le répertoire est vide
    setopt null_glob 2>/dev/null || true
    for util_file in "$SSHMAN_UTILS_DIR"/*.sh; do
        [ -f "$util_file" ] && source "$util_file" 2>/dev/null || true
    done
    unsetopt null_glob 2>/dev/null || true
fi

# DESC: Gestionnaire interactif complet pour la gestion SSH
# USAGE: sshman [command]
# EXAMPLE: sshman
# EXAMPLE: sshman auto-setup
# EXAMPLE: sshman list
# EXAMPLE: sshman test
sshman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                      SSMAN - SSH Manager                        ║"
        echo "║              Gestionnaire de Connexions SSH                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour lister les connexions SSH configurées
    list_ssh_connections() {
        show_header
        echo -e "${YELLOW}🔗 Connexions SSH configurées${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        local SSH_CONFIG="$HOME/.ssh/config"
        
        if [ ! -f "$SSH_CONFIG" ]; then
            echo -e "${YELLOW}⚠️  Aucun fichier ~/.ssh/config trouvé${RESET}"
            echo "  Utilisez 'sshman auto-setup' pour configurer une connexion"
            echo
            read -k 1 "?Appuyez sur une touche pour continuer..."
            return
        fi
        
        local hosts=$(grep -E "^Host " "$SSH_CONFIG" | awk '{print $2}' | grep -v "^\*$")
        
        if [ -z "$hosts" ]; then
            echo -e "${YELLOW}⚠️  Aucune connexion SSH configurée${RESET}"
            echo "  Utilisez 'sshman auto-setup' pour configurer une connexion"
        else
            echo -e "${CYAN}Hosts configurés:${RESET}"
            local i=1
            for host in $(echo "$hosts"); do
                local hostname=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "HostName" | awk '{print $2}')
                local user=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "User" | awk '{print $2}')
                local port=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "Port" | awk '{print $2}')
                local key=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "IdentityFile" | awk '{print $2}')
                
                printf "  ${BOLD}%d.${RESET} %-20s %s@%s" "$i" "$host" "${user:-$(whoami)}" "${hostname:-N/A}"
                [ -n "$port" ] && printf ":%s" "$port"
                echo
                [ -n "$key" ] && echo "     Clé: $key"
                echo
                ((i++))
            done
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour tester une connexion SSH
    test_ssh_connection() {
        show_header
        echo -e "${YELLOW}🧪 Test de connexion SSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        local SSH_CONFIG="$HOME/.ssh/config"
        local hosts=$(grep -E "^Host " "$SSH_CONFIG" 2>/dev/null | awk '{print $2}' | grep -v "^\*$")
        
        if [ -z "$hosts" ]; then
            echo -e "${YELLOW}⚠️  Aucune connexion SSH configurée${RESET}"
            echo
            read -k 1 "?Appuyez sur une touche pour continuer..."
            return
        fi
        
        echo "Sélectionnez un host à tester:"
        local i=1
        local host_array=()
        for host in $(echo "$hosts"); do
            echo "  $i. $host"
            host_array+=("$host")
            ((i++))
        done
        echo "  0. Annuler"
        echo
        read "choice?Votre choix: "
        
        if [ "$choice" = "0" ] || [ -z "$choice" ]; then
            return
        fi
        
        local selected_host="${host_array[$choice]}"
        if [ -z "$selected_host" ]; then
            echo -e "${RED}❌ Choix invalide${RESET}"
            sleep 2
            return
        fi
        
        echo
        echo -e "${CYAN}Test de connexion à $selected_host...${RESET}"
        echo
        
        if ssh -o ConnectTimeout=5 -o BatchMode=yes "$selected_host" "echo 'Connexion SSH réussie!'" 2>/dev/null; then
            echo -e "${GREEN}✓ Connexion SSH réussie!${RESET}"
        else
            echo -e "${RED}✗ Échec de la connexion SSH${RESET}"
            echo
            echo "Vérifications possibles:"
            echo "  • Le serveur est-il accessible ?"
            echo "  • La clé SSH est-elle correctement configurée ?"
            echo "  • Le mot de passe est-il correct (si nécessaire) ?"
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour gérer les clés SSH
    manage_ssh_keys() {
        show_header
        echo -e "${YELLOW}🔑 Gestion des clés SSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        local SSH_DIR="$HOME/.ssh"
        local keys=$(find "$SSH_DIR" -name "id_*" -type f ! -name "*.pub" 2>/dev/null)
        
        if [ -z "$keys" ]; then
            echo -e "${YELLOW}⚠️  Aucune clé SSH privée trouvée${RESET}"
            echo
            read -k 1 "generate?Voulez-vous générer une nouvelle clé ? [y/N]: "
            echo
            if [[ "$generate" =~ ^[Yy]$ ]]; then
                local email
                if [ -f "$HOME/dotfiles/.env" ]; then
                    source "$HOME/dotfiles/.env" 2>/dev/null || true
                    email="${GIT_USER_EMAIL:-$(whoami)@$(hostname)}"
                else
                    email="$(whoami)@$(hostname)"
                fi
                
                echo -e "${CYAN}Génération d'une nouvelle clé SSH ED25519...${RESET}"
                ssh-keygen -t ed25519 -C "$email" -f "$SSH_DIR/id_ed25519" -N ""
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Clé SSH générée: $SSH_DIR/id_ed25519${RESET}"
                else
                    echo -e "${RED}✗ Échec de la génération${RESET}"
                fi
            fi
        else
            echo -e "${CYAN}Clés SSH trouvées:${RESET}"
            local i=1
            local key_array=()
            for key in $(echo "$keys"); do
                local key_name=$(basename "$key")
                local key_size=$(stat -f%z "$key" 2>/dev/null || stat -c%s "$key" 2>/dev/null)
                echo "  $i. $key_name ($(numfmt --to=iec-i $key_size 2>/dev/null || echo $key_size))"
                key_array+=("$key")
                ((i++))
            done
            echo "  0. Générer une nouvelle clé"
            echo
            read "choice?Votre choix: "
            
            if [ "$choice" = "0" ]; then
                local email
                if [ -f "$HOME/dotfiles/.env" ]; then
                    source "$HOME/dotfiles/.env" 2>/dev/null || true
                    email="${GIT_USER_EMAIL:-$(whoami)@$(hostname)}"
                else
                    email="$(whoami)@$(hostname)}"
                fi
                
                echo -e "${CYAN}Génération d'une nouvelle clé SSH ED25519...${RESET}"
                ssh-keygen -t ed25519 -C "$email" -f "$SSH_DIR/id_ed25519" -N ""
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Clé SSH générée: $SSH_DIR/id_ed25519${RESET}"
                fi
            elif [ -n "$choice" ] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#key_array[@]} ]; then
                local selected_key="${key_array[$choice]}"
                local pub_key="${selected_key}.pub"
                
                echo
                echo -e "${CYAN}Clé sélectionnée: $selected_key${RESET}"
                echo
                echo "Actions disponibles:"
                echo "  1. Afficher la clé publique"
                echo "  2. Copier la clé publique dans le presse-papiers"
                echo "  3. Supprimer la clé"
                echo "  0. Retour"
                echo
                read "action?Votre choix: "
                
                case "$action" in
                    1)
                        if [ -f "$pub_key" ]; then
                            echo
                            echo -e "${CYAN}Clé publique:${RESET}"
                            cat "$pub_key"
                        else
                            echo -e "${RED}✗ Clé publique introuvable${RESET}"
                        fi
                        ;;
                    2)
                        if [ -f "$pub_key" ]; then
                            if command -v xclip >/dev/null 2>&1; then
                                cat "$pub_key" | xclip -selection clipboard
                                echo -e "${GREEN}✓ Clé publique copiée dans le presse-papiers${RESET}"
                            elif command -v pbcopy >/dev/null 2>&1; then
                                cat "$pub_key" | pbcopy
                                echo -e "${GREEN}✓ Clé publique copiée dans le presse-papiers${RESET}"
                            else
                                echo -e "${YELLOW}⚠️  Aucun outil de presse-papiers disponible${RESET}"
                                echo "Contenu de la clé publique:"
                                cat "$pub_key"
                            fi
                        else
                            echo -e "${RED}✗ Clé publique introuvable${RESET}"
                        fi
                        ;;
                    3)
                        echo
                        read -k 1 "confirm?⚠️  Confirmer la suppression ? [y/N]: "
                        echo
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            rm -f "$selected_key" "${selected_key}.pub"
                            echo -e "${GREEN}✓ Clé supprimée${RESET}"
                        fi
                        ;;
                esac
            fi
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Fonction pour afficher les statistiques SSH
    show_ssh_stats() {
        show_header
        echo -e "${YELLOW}📊 Statistiques SSH${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        
        local SSH_DIR="$HOME/.ssh"
        local SSH_CONFIG="$SSH_DIR/config"
        
        echo -e "${CYAN}Configuration:${RESET}"
        echo "  Répertoire SSH: $SSH_DIR"
        echo "  Fichier config: $SSH_CONFIG"
        echo
        
        if [ -f "$SSH_CONFIG" ]; then
            local host_count=$(grep -E "^Host " "$SSH_CONFIG" | grep -v "^\*$" | wc -l)
            echo "  Hosts configurés: $host_count"
        else
            echo "  Hosts configurés: 0"
        fi
        
        local key_count=$(find "$SSH_DIR" -name "id_*" -type f ! -name "*.pub" 2>/dev/null | wc -l)
        echo "  Clés privées: $key_count"
        
        local pub_key_count=$(find "$SSH_DIR" -name "*.pub" -type f 2>/dev/null | wc -l)
        echo "  Clés publiques: $pub_key_count"
        
        echo
        echo -e "${CYAN}Permissions:${RESET}"
        if [ -d "$SSH_DIR" ]; then
            local dir_perm=$(stat -c "%a" "$SSH_DIR" 2>/dev/null || stat -f "%A" "$SSH_DIR" 2>/dev/null)
            echo "  ~/.ssh: $dir_perm"
            if [ "$dir_perm" != "700" ]; then
                echo -e "  ${YELLOW}⚠️  Recommandé: 700${RESET}"
            fi
        fi
        
        if [ -f "$SSH_CONFIG" ]; then
            local config_perm=$(stat -c "%a" "$SSH_CONFIG" 2>/dev/null || stat -f "%A" "$SSH_CONFIG" 2>/dev/null)
            echo "  ~/.ssh/config: $config_perm"
            if [ "$config_perm" != "600" ]; then
                echo -e "  ${YELLOW}⚠️  Recommandé: 600${RESET}"
            fi
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Menu principal
    while true; do
        show_header
        echo -e "${GREEN}Menu Principal${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        echo "  ${BOLD}1${RESET}  🔗 Lister les connexions SSH configurées"
        echo "  ${BOLD}2${RESET}  ⚙️  Configuration automatique SSH (avec mot de passe .env)"
        echo "  ${BOLD}3${RESET}  🧪 Tester une connexion SSH"
        echo "  ${BOLD}4${RESET}  🔑 Gérer les clés SSH"
        echo "  ${BOLD}5${RESET}  📊 Statistiques SSH"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        read -k 1 "choice?Votre choix: "
        echo
        
        case "$choice" in
            1) list_ssh_connections ;;
            2)
                if [ -f "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh" ]; then
                    bash "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh"
                else
                    echo -e "${RED}❌ Module ssh_auto_setup non disponible${RESET}"
                    sleep 2
                fi
                ;;
            3) test_ssh_connection ;;
            4) manage_ssh_keys ;;
            5) show_ssh_stats ;;
            h|H)
                show_header
                echo -e "${CYAN}📚 Aide - SSMAN${RESET}"
                echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
                echo
                echo "SSMAN est un gestionnaire SSH complet pour ZSH."
                echo
                echo "Fonctionnalités principales:"
                echo "  • Configuration automatique SSH avec mot de passe depuis .env"
                echo "  • Liste des connexions SSH configurées"
                echo "  • Test de connexions SSH"
                echo "  • Gestion des clés SSH (génération, affichage, copie)"
                echo "  • Statistiques et vérification des permissions"
                echo
                echo "Raccourcis:"
                echo "  sshman              - Lance le gestionnaire"
                echo "  sshman auto-setup    - Configuration automatique directe"
                echo "  sshman list          - Liste des connexions"
                echo "  sshman test          - Test de connexion"
                echo "  sshman keys          - Gestion des clés"
                echo "  sshman stats         - Statistiques"
                echo
                echo "Utilisation manuelle:"
                echo "  ssh_auto_setup [host_name] [host_ip] [user] [port]"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            q|Q)
                echo -e "${GREEN}Au revoir!${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Option invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Alias et raccourcis
alias sm='sshman'

# Fonction pour accès direct aux sous-commandes
if [[ "$1" == "auto-setup" ]]; then
    if [ -f "$SSHMAN_DIR/modules/ssh_auto_setup.sh" ]; then
        bash "$SSHMAN_DIR/modules/ssh_auto_setup.sh" "${@:2}"
    fi
elif [[ "$1" == "list" ]]; then
    sshman
    list_ssh_connections
elif [[ "$1" == "test" ]]; then
    sshman
    test_ssh_connection
elif [[ "$1" == "keys" ]]; then
    sshman
    manage_ssh_keys
elif [[ "$1" == "stats" ]]; then
    sshman
    show_ssh_stats
fi

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🚀 SSMAN chargé - Tapez 'sshman' ou 'sm' pour démarrer"

