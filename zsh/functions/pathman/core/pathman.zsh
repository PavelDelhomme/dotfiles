#!/bin/zsh
# =============================================================================
# PATHMAN - Path Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet et interactif du PATH
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Gestionnaire interactif complet pour gérer le PATH système. Permet d'ajouter, retirer, nettoyer et sauvegarder les répertoires du PATH avec une interface utilisateur conviviale.
# USAGE: pathman [command] [args]
# EXAMPLE: pathman
# EXAMPLE: pathman add /usr/local/bin
# EXAMPLE: pathman clean
pathman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    local PATH_BACKUP_FILE="$HOME/dotfiles/zsh/PATH_SAVE"
    local PATH_LOG_FILE="$HOME/dotfiles/zsh/path_log.txt"
    local DEFAULT_PATH="$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"
    local MENU="1) Voir le PATH\n2) Ajouter un répertoire\n3) Retirer un répertoire\n4) Nettoyer le PATH\n5) Nettoyer invalid\n6) Sauvegarder\n7) Restaurer\n8) Logs\n9) Statistiques\n0) Export\nh) Aide\nq) Quitter\n"

    # DESC: S'assure que le fichier de log du PATH existe
    # USAGE: ensure_path_log
    ensure_path_log() {
        if [[ ! -f "$PATH_LOG_FILE" ]]; then
            mkdir -p "$(dirname "$PATH_LOG_FILE")"
            touch "$PATH_LOG_FILE"
        fi
    }

    # DESC: Ajoute une entrée dans le log du PATH
    # USAGE: add_logs <log_type> <message>
    add_logs() {
        local log_type="$1"; local message="$2"
        ensure_path_log
        echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
    }

    # DESC: Affiche le contenu complet du PATH de manière formatée
    # USAGE: show_path
    show_path() {
        echo -e "${CYAN}Contenu du PATH :${RESET}"
        echo "$PATH" | tr ':' '\n' | nl -w2 -s". "
        add_logs "SHOW" "Affichage du PATH"
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }

    # DESC: Ajoute un répertoire au PATH de manière interactive
    # USAGE: add_to_path
    add_to_path() {
        read "dir?Répertoire à ajouter au PATH: "
        dir="${dir%/}"
        if [[ -z "$dir" ]]; then echo "❌ Usage: add_to_path <directory>"; return; fi
        if [[ ! -d "$dir" ]]; then
            echo -e "${RED}Répertoire '$dir' inexistant.${RESET}"
            add_logs "ERROR" "Tentative d'ajout: $dir"
            sleep 2; return
        fi
        if [[ ":$PATH:" != *":$dir:"* ]]; then
            export PATH="$dir:$PATH"
            echo -e "${GREEN}Ajouté: $dir${RESET}"
            add_logs "ADD" "Ajout: $dir"
        else
            echo -e "${YELLOW}Déjà présent: $dir${RESET}"
        fi
        sleep 2
    }

    # DESC: Retire un répertoire du PATH de manière interactive
    # USAGE: remove_from_path
    remove_from_path() {
        read "dir?Répertoire à retirer du PATH: "
        if [[ ":$PATH:" == *":$dir:"* ]]; then
            export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
            echo -e "${GREEN}Supprimé: $dir${RESET}"
            add_logs "REMOVE" "Suppression: $dir"
        else
            echo -e "${YELLOW}Non présent: $dir${RESET}"
        fi
        sleep 2
    }

    # DESC: Nettoie le PATH en supprimant les doublons et en réorganisant
    # USAGE: clean_path
    clean_path() {
        local old_IFS="$IFS"; IFS=':'; local arr=($PATH); IFS="$old_IFS"
        local new_path=""
        local seen=()
        for dir in "${arr[@]}"; do
            [[ -n "$dir" && -d "$dir" && -z "${seen[$dir]}" ]] && { new_path="$new_path:$dir"; seen[$dir]=1; }
        done
        export PATH="${new_path#:}"
        add_logs "CLEAN" "Doublons/invalid nettoyés"
        echo -e "${GREEN}PATH nettoyé: $PATH${RESET}"
        sleep 2
    }

    # DESC: Supprime les répertoires invalides (inexistants) du PATH
    # USAGE: clean_invalid_paths
    clean_invalid_paths() {
        local new_path=""
        for dir in $(echo "$PATH" | tr ':' '\n'); do
            if [[ -d "$dir" ]]; then
                new_path="$new_path:$dir"
            else
                echo -e "${RED}Inexistant retiré: $dir${RESET}"
                add_logs "REMOVE" "Inexistant: $dir"
            fi
        done
        export PATH="${new_path#:}"
        add_logs "CLEAN" "Invalid retirés"
        sleep 2
    }

    # DESC: Sauvegarde le PATH actuel dans un fichier de sauvegarde
    # USAGE: save_path
    save_path() {
        ensure_path_log
        echo "export PATH=\"$PATH\"" > "$PATH_BACKUP_FILE"
        add_logs "SAVE" "PATH sauvegardé"
        echo -e "${GREEN}PATH sauvegardé${RESET}"
        sleep 2
    }

    # DESC: Restaure le PATH depuis la sauvegarde précédente
    # USAGE: restore_path
    restore_path() {
        ensure_path_log
        if [[ -f "$PATH_BACKUP_FILE" ]]; then
            source "$PATH_BACKUP_FILE"
            add_logs "RESTORE" "PATH restauré depuis sauvegarde"
            echo -e "${GREEN}Restauré: $PATH${RESET}"
        else
            export PATH="$DEFAULT_PATH"
            add_logs "RESTORE" "Aucune sauvegarde, valeur par défaut"
            echo -e "${YELLOW}Restauré valeur par défaut: $PATH${RESET}"
        fi
        sleep 2
    }

    # DESC: Affiche les logs des modifications du PATH
    # USAGE: show_logs
    show_logs() {
        ensure_path_log
        echo -e "${CYAN}Logs PATH :${RESET}"
        tail -20 "$PATH_LOG_FILE"
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }

    # DESC: Affiche les statistiques d'utilisation du PATH
    # USAGE: show_stats
    show_stats() {
        local cnt=$(echo "$PATH" | tr ':' '\n' | wc -l)
        local invalid=$(echo "$PATH" | tr ':' '\n' | while read d; do [[ ! -d "$d" ]] && echo "$d"; done | wc -l)
        echo -e "${CYAN}Stats PATH:${RESET}"
        echo "$cnt au total, $invalid non résolus"
        echo "Taille totale: $(( ${#PATH} )) caractères"
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }

    # DESC: Exporte le PATH dans un fichier texte
    # USAGE: export_path
    export_path() {
        local ts=$(date +%Y%m%d_%H%M%S)
        local ef="$HOME/PATH_EXPORT_$ts.txt"
        echo "$PATH" > "$ef"
        echo -e "${GREEN}Exporté: $ef${RESET}"
        sleep 2
    }

    # DESC: Affiche l'aide complète du gestionnaire PATH
    # USAGE: show_help
    show_help() {
        clear
        cat <<EOF
${CYAN}${BOLD}
╔══════════════════════════════════╗
║            PATHMAN               ║
╚══════════════════════════════════╝${RESET}

1) Voir le PATH complet
2) Ajouter un répertoire au PATH
3) Retirer un répertoire du PATH
4) Nettoyer le PATH (doublons, ordonner)
5) Nettoyer les invalids
6) Sauvegarder le PATH courant
7) Restaurer le PATH précédent
8) Afficher logs de modification
9) Statistiques
0) Exporter le PATH (txt)
h) Aide détaillée
q) Quitter

Commandes rapides : pathman add /mon/chemin
EOF
        read -k 1 "?Appuyez sur une touche pour revenir au menu..."
    }

    # Gestion des arguments rapides
    if [[ "$1" == "add" && -n "$2" ]]; then export PATH="$2:$PATH"; add_logs "ADD" "Ajout rapide: $2"; echo "Ajouté $2"; return; fi
    if [[ "$1" == "remove" && -n "$2" ]]; then remove_from_path "$2"; return; fi
    if [[ "$1" == "show" ]]; then show_path; return; fi
    if [[ "$1" == "clean" ]]; then clean_path; return; fi
    if [[ "$1" == "invalid" ]]; then clean_invalid_paths; return; fi
    if [[ "$1" == "stats" ]]; then show_stats; return; fi
    if [[ "$1" == "logs" ]]; then show_logs; return; fi
    if [[ "$1" == "save" ]]; then save_path; return; fi
    if [[ "$1" == "restore" ]]; then restore_path; return; fi
    if [[ "$1" == "export" ]]; then export_path; return; fi
    if [[ "$1" == "help" ]]; then show_help; return; fi

    while true; do
        clear
        echo -e "${CYAN}${BOLD}\n╔════════════════════════════════════════╗"
        echo "║      PATHMAN - Gestionnaire du PATH     ║"
        echo "╚════════════════════════════════════════╝${RESET}\n"
        echo -e "$MENU"
        read -k 1 "choice?Votre choix : "
        echo
        case "$choice" in
            1) show_path ;;
            2) add_to_path ;;
            3) remove_from_path ;;
            4) clean_path ;;
            5) clean_invalid_paths ;;
            6) save_path ;;
            7) restore_path ;;
            8) show_logs ;;
            9) show_stats ;;
            0) export_path ;;
            h|H) show_help ;;
            q|Q) break ;;
        esac
    done
    echo -e "${GREEN}Bye bye !${RESET}"
}

# Exporter les fonctions pour qu'elles soient disponibles globalement
# (utilisées par env.sh)
# DESC: Ajoute un répertoire au PATH de manière globale. Fonction exportée pour utilisation dans env.sh et autres scripts.
# USAGE: add_to_path <directory>
# EXAMPLE: add_to_path /usr/local/bin
add_to_path() {
    local dir="${1%/}"
    if [[ -z "$dir" ]]; then 
        echo "❌ Usage: add_to_path <directory>"
        return 1
    fi
    if [[ ! -d "$dir" ]]; then
        echo "❌ Répertoire '$dir' inexistant."
        return 1
    fi
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$dir:$PATH"
        echo "✅ Ajouté au PATH: $dir"
    else
        echo "⚠️  Déjà présent dans PATH: $dir"
    fi
}

# DESC: Nettoie le PATH en supprimant les doublons et répertoires invalides. Fonction exportée pour utilisation globale.
# USAGE: clean_path
# EXAMPLE: clean_path
clean_path() {
    local old_IFS="$IFS"
    IFS=':'
    local arr=($PATH)
    IFS="$old_IFS"
    local new_path=""
    local seen=()
    for dir in "${arr[@]}"; do
        [[ -n "$dir" && -d "$dir" && -z "${seen[$dir]}" ]] && { 
            new_path="$new_path:$dir"
            seen[$dir]=1
        }
    done
    export PATH="${new_path#:}"
    echo "✅ PATH nettoyé"
}

# Message d'initialisation
echo "📁 PATHMAN chargé - Tapez 'pathman' ou 'pm' pour démarrer"

# Alias
alias pm='pathman'
alias path-manager='pathman'

