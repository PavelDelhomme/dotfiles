#!/bin/sh
# =============================================================================
# SSHMAN - SSH Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des connexions SSH, clés, et configurations
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

# DESC: Gestionnaire interactif complet pour la gestion SSH
# USAGE: sshman [command]
# EXAMPLE: sshman
# EXAMPLE: sshman auto-setup
# EXAMPLE: sshman list
# EXAMPLE: sshman test
sshman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    SSHMAN_DIR="$DOTFILES_DIR/zsh/functions/sshman"
    SSHMAN_MODULES_DIR="$SSHMAN_DIR/modules"
    SSHMAN_UTILS_DIR="$SSHMAN_DIR/utils"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    
    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }

    # Aide courte (stdout) — identique pour sshman help, sshman -h, option « h » du menu
    sshman_print_quick_help() {
        printf "${CYAN}SSHMAN — raccourcis${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        echo "Sous-commandes :"
        echo "  sshman list           Connexions (~/.ssh/config)"
        echo "  sshman test           Tester une connexion"
        echo "  sshman keys           Gérer les clés SSH"
        echo "  sshman stats          Statistiques + permissions ~/.ssh"
        echo "  sshman auto-setup     Config auto (mot de passe .env si dispo)"
        echo ""
        echo "Interface :"
        echo "  sshman                Menu principal"
        echo "  sshman --help         Cette aide puis Entrée → menu"
        echo "  sshman -h, sshman help  Cette aide uniquement (stdout)"
        echo ""
    }
    
    # Charger les utilitaires si disponibles (find : évite glob zsh « no matches » si dossier vide)
    if [ -d "$SSHMAN_UTILS_DIR" ] && command -v find >/dev/null 2>&1; then
        find "$SSHMAN_UTILS_DIR" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | sort | while IFS= read -r util_file; do
            [ -f "$util_file" ] || continue
            . "$util_file" 2>/dev/null || true
        done
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                      SSHMAN - SSH Manager                        ║"
        echo "║              Gestionnaire de Connexions SSH                    ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # Fonction pour lister les connexions SSH configurées
    list_ssh_connections() {
        show_header
        printf "${YELLOW}🔗 Connexions SSH configurées${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        SSH_CONFIG="$HOME/.ssh/config"
        
        if [ ! -f "$SSH_CONFIG" ]; then
            printf "${YELLOW}⚠️  Aucun fichier ~/.ssh/config trouvé${RESET}\n"
            echo "  Utilisez 'sshman auto-setup' pour configurer une connexion"
            echo ""
            pause_if_tty
            return
        fi
        
        hosts=$(grep -E "^Host " "$SSH_CONFIG" | awk '{print $2}' | grep -v "^\*$")
        
        if [ -z "$hosts" ]; then
            printf "${YELLOW}⚠️  Aucune connexion SSH configurée${RESET}\n"
            echo "  Utilisez 'sshman auto-setup' pour configurer une connexion"
        else
            printf "${CYAN}Hosts configurés:${RESET}\n"
            i=1
            for host in $hosts; do
                hostname=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "HostName" | awk '{print $2}')
                user=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "User" | awk '{print $2}')
                port=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "Port" | awk '{print $2}')
                key=$(grep -A 5 "^Host $host$" "$SSH_CONFIG" | grep "IdentityFile" | awk '{print $2}')
                
                user_display="${user:-$(whoami)}"
                hostname_display="${hostname:-N/A}"
                printf "  ${BOLD}%d.${RESET} %-20s %s@%s" "$i" "$host" "$user_display" "$hostname_display"
                [ -n "$port" ] && printf ":%s" "$port"
                echo ""
                [ -n "$key" ] && echo "     Clé: $key"
                echo ""
                i=$((i + 1))
            done
        fi
        
        echo ""
        pause_if_tty
    }
    
    # Fonction pour tester une connexion SSH
    test_ssh_connection() {
        show_header
        printf "${YELLOW}🧪 Test de connexion SSH${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        SSH_CONFIG="$HOME/.ssh/config"
        hosts=$(grep -E "^Host " "$SSH_CONFIG" 2>/dev/null | awk '{print $2}' | grep -v "^\*$")
        
        if [ -z "$hosts" ]; then
            printf "${YELLOW}⚠️  Aucune connexion SSH configurée${RESET}\n"
            echo ""
            pause_if_tty
            return
        fi
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️  test_ssh_connection nécessite un terminal interactif${RESET}\n"
            return 1
        fi
        
        echo "Sélectionnez un host à tester:"
        i=1
        host_list=""
        for host in $hosts; do
            echo "  $i. $host"
            if [ -z "$host_list" ]; then
                host_list="$host"
            else
                host_list="$host_list $host"
            fi
            i=$((i + 1))
        done
        echo "  0. Annuler"
        echo ""
        printf "Votre choix: "
        read choice
        
        if [ "$choice" = "0" ] || [ -z "$choice" ]; then
            return
        fi
        
        # Extraire le host sélectionné
        selected_index=1
        selected_host=""
        for host in $host_list; do
            if [ "$selected_index" -eq "$choice" ]; then
                selected_host="$host"
                break
            fi
            selected_index=$((selected_index + 1))
        done
        
        if [ -z "$selected_host" ]; then
            printf "${RED}❌ Choix invalide${RESET}\n"
            sleep 2
            return
        fi
        
        echo ""
        printf "${CYAN}Test de connexion à %s...${RESET}\n" "$selected_host"
        echo ""
        
        if ssh -o ConnectTimeout=5 -o BatchMode=yes "$selected_host" "echo 'Connexion SSH réussie!'" 2>/dev/null; then
            printf "${GREEN}✓ Connexion SSH réussie!${RESET}\n"
        else
            printf "${RED}✗ Échec de la connexion SSH${RESET}\n"
            echo ""
            echo "Vérifications possibles:"
            echo "  • Le serveur est-il accessible ?"
            echo "  • La clé SSH est-elle correctement configurée ?"
            echo "  • Le mot de passe est-il correct (si nécessaire) ?"
        fi
        
        echo ""
        pause_if_tty
    }
    
    # Fonction pour gérer les clés SSH
    manage_ssh_keys() {
        show_header
        printf "${YELLOW}🔑 Gestion des clés SSH${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        if ! [ -t 0 ] || ! [ -t 1 ]; then
            printf "${YELLOW}⚠️  manage_ssh_keys nécessite un terminal interactif${RESET}\n"
            return 1
        fi
        
        SSH_DIR="$HOME/.ssh"
        keys=$(find "$SSH_DIR" -name "id_*" -type f ! -name "*.pub" 2>/dev/null)
        
        if [ -z "$keys" ]; then
            printf "${YELLOW}⚠️  Aucune clé SSH privée trouvée${RESET}\n"
            echo ""
            printf "Voulez-vous générer une nouvelle clé ? [y/N]: "
            read generate
            echo ""
            case "$generate" in
                [Yy]*)
                    email=""
                    if [ -f "$HOME/dotfiles/.env" ]; then
                        . "$HOME/dotfiles/.env" 2>/dev/null || true
                        email="${GIT_USER_EMAIL:-$(whoami)@$(hostname)}"
                    else
                        email="$(whoami)@$(hostname)"
                    fi
                    
                    printf "${CYAN}Génération d'une nouvelle clé SSH ED25519...${RESET}\n"
                    ssh-keygen -t ed25519 -C "$email" -f "$SSH_DIR/id_ed25519" -N ""
                    if [ $? -eq 0 ]; then
                        printf "${GREEN}✓ Clé SSH générée: %s/id_ed25519${RESET}\n" "$SSH_DIR"
                    else
                        printf "${RED}✗ Échec de la génération${RESET}\n"
                    fi
                    ;;
            esac
        else
            printf "${CYAN}Clés SSH trouvées:${RESET}\n"
            i=1
            key_list=""
            for key in $keys; do
                key_name=$(basename "$key")
                key_size=$(stat -c%s "$key" 2>/dev/null || stat -f%z "$key" 2>/dev/null || echo "0")
                printf "  %d. %s (%s)\n" "$i" "$key_name" "$key_size"
                if [ -z "$key_list" ]; then
                    key_list="$key"
                else
                    key_list="$key_list $key"
                fi
                i=$((i + 1))
            done
            echo "  0. Générer une nouvelle clé"
            echo ""
            printf "Votre choix: "
            read choice
            
            if [ "$choice" = "0" ]; then
                email=""
                if [ -f "$HOME/dotfiles/.env" ]; then
                    . "$HOME/dotfiles/.env" 2>/dev/null || true
                    email="${GIT_USER_EMAIL:-$(whoami)@$(hostname)}"
                else
                    email="$(whoami)@$(hostname)"
                fi
                
                printf "${CYAN}Génération d'une nouvelle clé SSH ED25519...${RESET}\n"
                ssh-keygen -t ed25519 -C "$email" -f "$SSH_DIR/id_ed25519" -N ""
                if [ $? -eq 0 ]; then
                    printf "${GREEN}✓ Clé SSH générée: %s/id_ed25519${RESET}\n" "$SSH_DIR"
                fi
            elif [ -n "$choice" ] && [ "$choice" -ge 1 ]; then
                # Extraire la clé sélectionnée
                selected_index=1
                selected_key=""
                for key in $key_list; do
                    if [ "$selected_index" -eq "$choice" ]; then
                        selected_key="$key"
                        break
                    fi
                    selected_index=$((selected_index + 1))
                done
                
                if [ -n "$selected_key" ]; then
                    pub_key="${selected_key}.pub"
                    
                    echo ""
                    printf "${CYAN}Clé sélectionnée: %s${RESET}\n" "$selected_key"
                    echo ""
                    echo "Actions disponibles:"
                    echo "  1. Afficher la clé publique"
                    echo "  2. Copier la clé publique dans le presse-papiers"
                    echo "  3. Supprimer la clé"
                    echo "  0. Retour"
                    echo ""
                    printf "Votre choix: "
                    read action
                    
                    case "$action" in
                        1)
                            if [ -f "$pub_key" ]; then
                                echo ""
                                printf "${CYAN}Clé publique:${RESET}\n"
                                cat "$pub_key"
                            else
                                printf "${RED}✗ Clé publique introuvable${RESET}\n"
                            fi
                            ;;
                        2)
                            if [ -f "$pub_key" ]; then
                                if command -v xclip >/dev/null 2>&1; then
                                    cat "$pub_key" | xclip -selection clipboard
                                    printf "${GREEN}✓ Clé publique copiée dans le presse-papiers${RESET}\n"
                                elif command -v pbcopy >/dev/null 2>&1; then
                                    cat "$pub_key" | pbcopy
                                    printf "${GREEN}✓ Clé publique copiée dans le presse-papiers${RESET}\n"
                                else
                                    printf "${YELLOW}⚠️  Aucun outil de presse-papiers disponible${RESET}\n"
                                    echo "Contenu de la clé publique:"
                                    cat "$pub_key"
                                fi
                            else
                                printf "${RED}✗ Clé publique introuvable${RESET}\n"
                            fi
                            ;;
                        3)
                            echo ""
                            printf "⚠️  Confirmer la suppression ? [y/N]: "
                            read confirm
                            echo ""
                            case "$confirm" in
                                [Yy]*)
                                    rm -f "$selected_key" "${selected_key}.pub"
                                    printf "${GREEN}✓ Clé supprimée${RESET}\n"
                                    ;;
                            esac
                            ;;
                    esac
                fi
            fi
        fi
        
        echo ""
        pause_if_tty
    }
    
    # Fonction pour afficher les statistiques SSH
    show_ssh_stats() {
        show_header
        printf "${YELLOW}📊 Statistiques SSH${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo ""
        
        SSH_DIR="$HOME/.ssh"
        SSH_CONFIG="$SSH_DIR/config"
        
        printf "${CYAN}Configuration:${RESET}\n"
        echo "  Répertoire SSH: $SSH_DIR"
        echo "  Fichier config: $SSH_CONFIG"
        echo ""
        
        if [ -f "$SSH_CONFIG" ]; then
            host_count=$(grep -E "^Host " "$SSH_CONFIG" | grep -v "^\*$" | wc -l | tr -d ' ')
            echo "  Hosts configurés: $host_count"
        else
            echo "  Hosts configurés: 0"
        fi
        
        key_count=$(find "$SSH_DIR" -name "id_*" -type f ! -name "*.pub" 2>/dev/null | wc -l | tr -d ' ')
        echo "  Clés privées: $key_count"
        
        pub_key_count=$(find "$SSH_DIR" -name "*.pub" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "  Clés publiques: $pub_key_count"
        
        echo ""
        printf "${CYAN}Permissions:${RESET}\n"
        if [ -d "$SSH_DIR" ]; then
            dir_perm=$(stat -c "%a" "$SSH_DIR" 2>/dev/null || stat -f "%A" "$SSH_DIR" 2>/dev/null || echo "N/A")
            echo "  ~/.ssh: $dir_perm"
            if [ "$dir_perm" != "700" ]; then
                printf "  ${YELLOW}⚠️  Recommandé: 700${RESET}\n"
            fi
        fi
        
        if [ -f "$SSH_CONFIG" ]; then
            config_perm=$(stat -c "%a" "$SSH_CONFIG" 2>/dev/null || stat -f "%A" "$SSH_CONFIG" 2>/dev/null || echo "N/A")
            echo "  ~/.ssh/config: $config_perm"
            if [ "$config_perm" != "600" ]; then
                printf "  ${YELLOW}⚠️  Recommandé: 600${RESET}\n"
            fi
        fi
        
        if [ -t 0 ] && [ -t 1 ]; then
            echo ""
            printf "Appuyez sur Entrée pour continuer... "
            read dummy || true
        fi
    }
    
    # Gestion des arguments en ligne de commande
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        :
    elif [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log sshman "$@"
        case "$1" in
            auto-setup)
                if [ -f "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh" ]; then
                    bash "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh" "$2" "$3" "$4" "$5"
                else
                    printf "${RED}❌ Module ssh_auto_setup non disponible${RESET}\n"
                fi
                ;;
            list)
                list_ssh_connections
                ;;
            test)
                test_ssh_connection
                ;;
            keys)
                manage_ssh_keys
                ;;
            stats)
                show_ssh_stats
                ;;
            help|-h)
                sshman_print_quick_help
                ;;
            *)
                printf "${RED}Commande inconnue: %s${RESET}\n" "$1"
                echo "Utilisez 'sshman help' pour voir les commandes disponibles"
                return 1
                ;;
        esac
    fi
    if [ -z "$1" ] || [ "$1" = "--help" ]; then
        if [ "$1" = "--help" ]; then
            sshman_print_quick_help
            if ! { [ -t 0 ] && [ -t 1 ]; }; then
                return 0
            fi
            pause_if_tty
        fi
        # Menu principal interactif
        while true; do
            show_header
            printf "${GREEN}Menu Principal${RESET}\n"
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            echo ""
            echo "  ${BOLD}1${RESET}  🔗 Lister les connexions SSH configurées"
            echo "  ${BOLD}2${RESET}  ⚙️  Configuration automatique SSH (avec mot de passe .env)"
            echo "  ${BOLD}3${RESET}  🧪 Tester une connexion SSH"
            echo "  ${BOLD}4${RESET}  🔑 Gérer les clés SSH"
            echo "  ${BOLD}5${RESET}  📊 Statistiques SSH"
            echo ""
            echo "  ${BOLD}h${RESET}  📚 Aide"
            echo "  ${BOLD}q${RESET}  🚪 Quitter"
            echo ""
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            choice=""
            if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
                menu_input_file=$(mktemp)
                cat > "$menu_input_file" <<'EOF'
Lister les connexions SSH configurees|1
Configuration automatique SSH (.env)|2
Tester une connexion SSH|3
Gerer les cles SSH|4
Statistiques SSH|5
Aide|h
Quitter|q
EOF
                choice=$(dotfiles_ncmenu_select "SSHMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
                rm -f "$menu_input_file"
            fi
            if [ -z "$choice" ]; then
                printf "Votre choix: "
                read choice
            fi
            echo ""
            
            case "$choice" in
                1) list_ssh_connections ;;
                2)
                    if [ -f "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh" ]; then
                        bash "$SSHMAN_MODULES_DIR/ssh_auto_setup.sh"
                    else
                        printf "${RED}❌ Module ssh_auto_setup non disponible${RESET}\n"
                        sleep 2
                    fi
                    ;;
                3) test_ssh_connection ;;
                4) manage_ssh_keys ;;
                5) show_ssh_stats ;;
                h|H)
                    show_header
                    sshman_print_quick_help
                    pause_if_tty
                    ;;
                q|Q)
                    printf "${GREEN}Au revoir!${RESET}\n"
                    break
                    ;;
                *)
                    printf "${RED}Option invalide${RESET}\n"
                    sleep 1
                    ;;
            esac
        done
    fi
}
