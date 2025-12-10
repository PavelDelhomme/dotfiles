#!/bin/sh
# =============================================================================
# PATHMAN - Path Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet et interactif du PATH (code commun)
# Author: Paul Delhomme
# Version: 2.0 - Structure Hybride
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

# DESC: Gestionnaire interactif complet pour gérer le PATH système
# USAGE: pathman [command] [args]
# EXAMPLE: pathman
# EXAMPLE: pathman add /usr/local/bin
# EXAMPLE: pathman clean
pathman() {
    # Couleurs (compatibles tous shells)
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Fichiers de configuration (utiliser shared pour logs)
    PATH_BACKUP_FILE="${PATH_BACKUP_FILE:-$HOME/dotfiles/shells/$SHELL_TYPE/config/PATH_SAVE}"
    PATH_LOG_FILE="${PATH_LOG_FILE:-$HOME/dotfiles/shells/$SHELL_TYPE/config/path_log.txt}"
    DEFAULT_PATH="${DEFAULT_PATH:-$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin}"
    MENU="1) Voir le PATH\n2) Ajouter un répertoire\n3) Retirer un répertoire\n4) Nettoyer le PATH\n5) Nettoyer invalid\n6) Sauvegarder\n7) Restaurer\n8) Logs\n9) Statistiques\n0) Export\nh) Aide\nq) Quitter\n"

    # DESC: S'assure que le fichier de log du PATH existe
    # USAGE: ensure_path_log
    ensure_path_log() {
        if [ ! -f "$PATH_LOG_FILE" ]; then
            mkdir -p "$(dirname "$PATH_LOG_FILE")"
            touch "$PATH_LOG_FILE"
        fi
    }

    # DESC: Ajoute une entrée dans le log du PATH
    # USAGE: add_logs <log_type> <message>
    add_logs() {
        local log_type="$1"
        local message="$2"
        ensure_path_log
        echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
    }

    # DESC: Affiche le contenu complet du PATH de manière formatée
    # USAGE: show_path
    show_path() {
        printf "${CYAN}Contenu du PATH :${RESET}\n"
        echo "$PATH" | tr ':' '\n' | awk '{printf "%2d. %s\n", NR, $0}'
        add_logs "SHOW" "Affichage du PATH"
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }

    # DESC: Ajoute un répertoire au PATH (version interactive)
    # USAGE: add_to_path_interactive
    add_to_path_interactive() {
        printf "Répertoire à ajouter au PATH: "
        read dir
        dir="${dir%/}"
        if [ -z "$dir" ]; then
            echo "❌ Usage: add_to_path <directory>"
            return 1
        fi
        add_to_path "$dir"
    }

    # DESC: Ajoute un répertoire au PATH de manière globale (exportée)
    # USAGE: add_to_path <directory>
    # EXAMPLE: add_to_path /usr/local/bin
    add_to_path() {
        local dir="${1%/}"
        if [ -z "$dir" ]; then
            echo "❌ Usage: add_to_path <directory>"
            return 1
        fi
        if [ ! -d "$dir" ]; then
            printf "${RED}Répertoire '$dir' inexistant.${RESET}\n"
            add_logs "ERROR" "Tentative d'ajout: $dir"
            sleep 2
            return 1
        fi
        case ":$PATH:" in
            *":$dir:"*)
                printf "${YELLOW}Déjà présent: $dir${RESET}\n"
                ;;
            *)
                export PATH="$dir:$PATH"
                printf "${GREEN}Ajouté: $dir${RESET}\n"
                add_logs "ADD" "Ajout: $dir"
                ;;
        esac
        sleep 2
    }

    # DESC: Retire un répertoire du PATH de manière interactive
    # USAGE: remove_from_path
    remove_from_path() {
        printf "Répertoire à retirer du PATH: "
        read dir
        case ":$PATH:" in
            *":$dir:"*)
                export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
                printf "${GREEN}Supprimé: $dir${RESET}\n"
                add_logs "REMOVE" "Suppression: $dir"
                ;;
            *)
                printf "${YELLOW}Non présent: $dir${RESET}\n"
                ;;
        esac
        sleep 2
    }

    # DESC: Nettoie le PATH en supprimant les doublons et répertoires invalides
    # USAGE: pathman_clean_path
    # EXAMPLE: pathman_clean_path
    pathman_clean_path() {
        local old_IFS="$IFS"
        IFS=':'
        set -- $PATH
        IFS="$old_IFS"
        local new_path=""
        local seen=""
        
        for dir in "$@"; do
            if [ -n "$dir" ] && [ -d "$dir" ]; then
                case ":$seen:" in
                    *":$dir:"*) ;;
                    *)
                        new_path="$new_path:$dir"
                        seen="$seen:$dir"
                        ;;
                esac
            fi
        done
        export PATH="${new_path#:}"
        add_logs "CLEAN" "Doublons/invalid nettoyés"
        printf "${GREEN}PATH nettoyé: $PATH${RESET}\n"
    }

    # Alias pour compatibilité avec env.sh
    clean_path() {
        pathman_clean_path
    }

    # DESC: Supprime les répertoires invalides (inexistants) du PATH
    # USAGE: clean_invalid_paths
    clean_invalid_paths() {
        local new_path=""
        local old_IFS="$IFS"
        IFS=':'
        set -- $PATH
        IFS="$old_IFS"
        
        for dir in "$@"; do
            if [ -d "$dir" ]; then
                new_path="$new_path:$dir"
            else
                printf "${RED}Inexistant retiré: $dir${RESET}\n"
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
        printf "${GREEN}PATH sauvegardé${RESET}\n"
        sleep 2
    }

    # DESC: Restaure le PATH depuis la sauvegarde précédente
    # USAGE: restore_path
    restore_path() {
        ensure_path_log
        if [ -f "$PATH_BACKUP_FILE" ]; then
            . "$PATH_BACKUP_FILE"
            add_logs "RESTORE" "PATH restauré depuis sauvegarde"
            printf "${GREEN}Restauré: $PATH${RESET}\n"
        else
            export PATH="$DEFAULT_PATH"
            add_logs "RESTORE" "Aucune sauvegarde, valeur par défaut"
            printf "${YELLOW}Restauré valeur par défaut: $PATH${RESET}\n"
        fi
        sleep 2
    }

    # DESC: Affiche les logs des modifications du PATH
    # USAGE: show_logs
    show_logs() {
        ensure_path_log
        printf "${CYAN}Logs PATH :${RESET}\n"
        tail -20 "$PATH_LOG_FILE"
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }

    # DESC: Affiche les statistiques d'utilisation du PATH
    # USAGE: show_stats
    show_stats() {
        local cnt=0
        local invalid=0
        local path_length=0
        local old_IFS="$IFS"
        IFS=':'
        set -- $PATH
        IFS="$old_IFS"
        
        for dir in "$@"; do
            cnt=$((cnt + 1))
            if [ ! -d "$dir" ]; then
                invalid=$((invalid + 1))
            fi
            path_length=$((path_length + ${#dir} + 1))  # +1 pour le séparateur
        done
        
        printf "${CYAN}Stats PATH:${RESET}\n"
        echo "$cnt au total, $invalid non résolus"
        echo "Taille totale: $path_length caractères"
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }

    # DESC: Exporte le PATH dans un fichier texte
    # USAGE: export_path
    export_path() {
        local ts=$(date +%Y%m%d_%H%M%S)
        local ef="$HOME/PATH_EXPORT_$ts.txt"
        echo "$PATH" > "$ef"
        printf "${GREEN}Exporté: $ef${RESET}\n"
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
        printf "Appuyez sur Entrée pour revenir au menu... "
        read dummy
    }

    # Gestion des arguments rapides
    case "$1" in
        add)
            if [ -n "$2" ]; then
                pathman_add_to_path "$2"
            else
                add_to_path_interactive
            fi
            return 0
            ;;
        remove)
            if [ -n "$2" ]; then
                remove_from_path "$2"
            else
                remove_from_path
            fi
            return 0
            ;;
        show)
            show_path
            return 0
            ;;
        clean)
            pathman_clean_path
            return 0
            ;;
        invalid)
            clean_invalid_paths
            return 0
            ;;
        stats)
            show_stats
            return 0
            ;;
        logs)
            show_logs
            return 0
            ;;
        save)
            save_path
            return 0
            ;;
        restore)
            restore_path
            return 0
            ;;
        export)
            export_path
            return 0
            ;;
        help)
            show_help
            return 0
            ;;
    esac

    # Menu interactif
    while true; do
        clear
        printf "${CYAN}${BOLD}\n╔════════════════════════════════════════╗\n"
        printf "║      PATHMAN - Gestionnaire du PATH     ║\n"
        printf "╚════════════════════════════════════════╝${RESET}\n\n"
        printf "$MENU"
        printf "Votre choix : "
        read choice
        case "$choice" in
            1) show_path ;;
            2) add_to_path_interactive ;;
            3) remove_from_path ;;
            4) pathman_clean_path ;;
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
    printf "${GREEN}Bye bye !${RESET}\n"
}

# Exporter les fonctions pour utilisation globale (via adapters)
# Ces fonctions seront disponibles après le chargement de pathman()
add_to_path() {
    pathman_add_to_path "$@"
}

clean_path() {
    pathman_clean_path
}

# Note: Les fonctions add_to_path et clean_path sont définies dans pathman()
# Elles seront disponibles globalement via les adapters shell qui les exportent

