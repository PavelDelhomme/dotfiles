# =============================================================================
# PATHMAN - Path Manager pour Fish
# =============================================================================
# Description: Gestionnaire complet et interactif du PATH
# Author: Paul Delhomme
# Version: 1.0
# Converted from ZSH to Fish
# =============================================================================

# DESC: Gestionnaire interactif complet pour gérer le PATH système. Permet d'ajouter, retirer, nettoyer et sauvegarder les répertoires du PATH avec une interface utilisateur conviviale.
# USAGE: pathman [command] [args]
# EXAMPLE: pathman
# EXAMPLE: pathman add /usr/local/bin
# EXAMPLE: pathman clean
function pathman
    set -l RED (set_color red)
    set -l GREEN (set_color green)
    set -l YELLOW (set_color yellow)
    set -l BLUE (set_color blue)
    set -l MAGENTA (set_color magenta)
    set -l CYAN (set_color cyan)
    set -l BOLD (set_color -o)
    set -l RESET (set_color normal)
    
    set -g PATH_BACKUP_FILE "$HOME/dotfiles/zsh/PATH_SAVE"
    set -g PATH_LOG_FILE "$HOME/dotfiles/zsh/path_log.txt"
    set -g DEFAULT_PATH "$HOME/.local/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/local/games:/snap/bin:/home/pactivisme/.dotnet/tools"

    # DESC: S'assure que le fichier de log du PATH existe
    # USAGE: ensure_path_log
    function ensure_path_log
        if not test -f "$PATH_LOG_FILE"
            mkdir -p (dirname "$PATH_LOG_FILE")
            touch "$PATH_LOG_FILE"
        end
    end

    # DESC: Ajoute une entrée dans le log du PATH
    # USAGE: add_logs <log_type> <message>
    function add_logs
        set -l log_type "$argv[1]"
        set -l message "$argv[2]"
        ensure_path_log
        echo "[$(date)] [$log_type] $message : $PATH" >> "$PATH_LOG_FILE"
    end

    # DESC: Affiche le contenu complet du PATH de manière formatée
    # USAGE: show_path
    function show_path
        echo -e "$CYANContenu du PATH :$RESET"
        set -l index 1
        for dir in (string split ":" "$PATH")
            printf "%-3s %s\n" "$index." "$dir"
            set index (math $index + 1)
        end
        add_logs "SHOW" "Affichage du PATH"
        echo
        read -n 1 -P "Appuyez sur une touche pour continuer... " > /dev/null
        echo
    end

    # DESC: Ajoute un répertoire au PATH de manière interactive
    # USAGE: add_to_path
    function add_to_path
        read -P "Répertoire à ajouter au PATH: " dir
        set dir (string trim -r -c / "$dir")
        if test -z "$dir"
            echo "❌ Usage: add_to_path <directory>"
            return
        end
        if not test -d "$dir"
            echo -e "$REDRépertoire '$dir' inexistant.$RESET"
            add_logs "ERROR" "Tentative d'ajout: $dir"
            sleep 2
            return
        end
        if not contains "$dir" (string split ":" "$PATH")
            set -gx PATH "$dir:$PATH"
            echo -e "$GREENAjouté: $dir$RESET"
            add_logs "ADD" "Ajout: $dir"
        else
            echo -e "$YELLOWDéjà présent: $dir$RESET"
        end
        sleep 2
    end

    # DESC: Retire un répertoire du PATH de manière interactive
    # USAGE: remove_from_path
    function remove_from_path
        read -P "Répertoire à retirer du PATH: " dir
        set -l path_list (string split ":" "$PATH")
        if contains "$dir" $path_list
            set -l new_path_list
            for p in $path_list
                if test "$p" != "$dir"
                    set -a new_path_list "$p"
                end
            end
            set -gx PATH (string join ":" $new_path_list)
            echo -e "$GREENSupprimé: $dir$RESET"
            add_logs "REMOVE" "Suppression: $dir"
        else
            echo -e "$YELLOWNon présent: $dir$RESET"
        end
        sleep 2
    end

    # DESC: Nettoie le PATH en supprimant les doublons et en réorganisant
    # USAGE: clean_path
    function clean_path
        set -l path_list (string split ":" "$PATH")
        set -l new_path_list
        set -l seen_list
        
        for dir in $path_list
            if test -n "$dir" && test -d "$dir"
                if not contains "$dir" $seen_list
                    set -a new_path_list "$dir"
                    set -a seen_list "$dir"
                end
            end
        end
        
        set -gx PATH (string join ":" $new_path_list)
        add_logs "CLEAN" "Doublons/invalid nettoyés"
        echo -e "$GREENPATH nettoyé: $PATH$RESET"
        sleep 2
    end

    # DESC: Supprime les répertoires invalides (inexistants) du PATH
    # USAGE: clean_invalid_paths
    function clean_invalid_paths
        set -l path_list (string split ":" "$PATH")
        set -l new_path_list
        
        for dir in $path_list
            if test -d "$dir"
                set -a new_path_list "$dir"
            else
                echo -e "$REDInexistant retiré: $dir$RESET"
                add_logs "REMOVE" "Inexistant: $dir"
            end
        end
        
        set -gx PATH (string join ":" $new_path_list)
        add_logs "CLEAN" "Invalid retirés"
        sleep 2
    end

    # DESC: Sauvegarde le PATH actuel dans un fichier de sauvegarde
    # USAGE: save_path
    function save_path
        ensure_path_log
        echo "set -gx PATH \"$PATH\"" > "$PATH_BACKUP_FILE"
        add_logs "SAVE" "PATH sauvegardé"
        echo -e "$GREENPATH sauvegardé$RESET"
        sleep 2
    end

    # DESC: Restaure le PATH depuis la sauvegarde précédente
    # USAGE: restore_path
    function restore_path
        ensure_path_log
        if test -f "$PATH_BACKUP_FILE"
            source "$PATH_BACKUP_FILE"
            add_logs "RESTORE" "PATH restauré depuis sauvegarde"
            echo -e "$GREENRestauré: $PATH$RESET"
        else
            set -gx PATH "$DEFAULT_PATH"
            add_logs "RESTORE" "Aucune sauvegarde, valeur par défaut"
            echo -e "$YELLOWRestauré valeur par défaut: $PATH$RESET"
        end
        sleep 2
    end

    # DESC: Affiche les logs des modifications du PATH
    # USAGE: show_logs
    function show_logs
        ensure_path_log
        echo -e "$CYANLogs PATH :$RESET"
        tail -20 "$PATH_LOG_FILE"
        echo
        read -n 1 -P "Appuyez sur une touche pour continuer... " > /dev/null
        echo
    end

    # DESC: Affiche les statistiques d'utilisation du PATH
    # USAGE: show_stats
    function show_stats
        set -l path_list (string split ":" "$PATH")
        set -l cnt (count $path_list)
        set -l invalid 0
        
        for d in $path_list
            if not test -d "$d"
                set invalid (math $invalid + 1)
            end
        end
        
        echo -e "$CYANStats PATH:$RESET"
        echo "$cnt au total, $invalid non résolus"
        echo "Taille totale: "(string length "$PATH")" caractères"
        echo
        read -n 1 -P "Appuyez sur une touche pour continuer... " > /dev/null
        echo
    end

    # DESC: Exporte le PATH dans un fichier texte
    # USAGE: export_path
    function export_path
        set -l ts (date +%Y%m%d_%H%M%S)
        set -l ef "$HOME/PATH_EXPORT_$ts.txt"
        echo "$PATH" > "$ef"
        echo -e "$GREENExporté: $ef$RESET"
        sleep 2
    end

    # DESC: Affiche l'aide complète du gestionnaire PATH
    # USAGE: show_help
    function show_help
        clear
        echo -e "$CYAN$BOLD"
        echo "╔══════════════════════════════════╗"
        echo "║            PATHMAN               ║"
        echo "╚══════════════════════════════════╝"
        echo -e "$RESET"
        echo ""
        echo "1) Voir le PATH complet"
        echo "2) Ajouter un répertoire au PATH"
        echo "3) Retirer un répertoire du PATH"
        echo "4) Nettoyer le PATH (doublons, ordonner)"
        echo "5) Nettoyer les invalids"
        echo "6) Sauvegarder le PATH courant"
        echo "7) Restaurer le PATH précédent"
        echo "8) Afficher logs de modification"
        echo "9) Statistiques"
        echo "0) Exporter le PATH (txt)"
        echo "h) Aide détaillée"
        echo "q) Quitter"
        echo ""
        echo "Commandes rapides : pathman add /mon/chemin"
        echo ""
        read -n 1 -P "Appuyez sur une touche pour revenir au menu... " > /dev/null
        echo
    end

    # Gestion des arguments rapides
    if test (count $argv) -gt 0
        set -l cmd "$argv[1]"
        switch "$cmd"
            case "add"
                if test (count $argv) -gt 1
                    set -gx PATH "$argv[2]:$PATH"
                    add_logs "ADD" "Ajout rapide: $argv[2]"
                    echo "Ajouté $argv[2]"
                end
                return
            case "remove"
                if test (count $argv) -gt 1
                    remove_from_path "$argv[2]"
                end
                return
            case "show"
                show_path
                return
            case "clean"
                clean_path
                return
            case "invalid"
                clean_invalid_paths
                return
            case "stats"
                show_stats
                return
            case "logs"
                show_logs
                return
            case "save"
                save_path
                return
            case "restore"
                restore_path
                return
            case "export"
                export_path
                return
            case "help"
                show_help
                return
        end
    end

    while true
        clear
        echo -e "$CYAN$BOLD"
        echo "╔════════════════════════════════════════╗"
        echo "║      PATHMAN - Gestionnaire du PATH     ║"
        echo "╚════════════════════════════════════════╝"
        echo -e "$RESET"
        echo ""
        echo "1) Voir le PATH"
        echo "2) Ajouter un répertoire"
        echo "3) Retirer un répertoire"
        echo "4) Nettoyer le PATH"
        echo "5) Nettoyer invalid"
        echo "6) Sauvegarder"
        echo "7) Restaurer"
        echo "8) Logs"
        echo "9) Statistiques"
        echo "0) Export"
        echo "h) Aide"
        echo "q) Quitter"
        echo ""
        read -l -P "Votre choix : " choice
        echo
        
        switch "$choice"
            case "1"
                show_path
            case "2"
                add_to_path
            case "3"
                remove_from_path
            case "4"
                clean_path
            case "5"
                clean_invalid_paths
            case "6"
                save_path
            case "7"
                restore_path
            case "8"
                show_logs
            case "9"
                show_stats
            case "0"
                export_path
            case "h" "H"
                show_help
            case "q" "Q"
                break
        end
    end
    echo -e "$GREENBye bye !$RESET"
end

# Exporter les fonctions pour qu'elles soient disponibles globalement
# (utilisées par env.sh via bash)
# DESC: Ajoute un répertoire au PATH de manière globale. Fonction exportée pour utilisation dans env.sh et autres scripts.
# USAGE: add_to_path <directory>
# EXAMPLE: add_to_path /usr/local/bin
function add_to_path -d "Ajoute un répertoire au PATH"
    set -l dir (string trim -r -c / "$argv[1]")
    if test -z "$dir"
        echo "❌ Usage: add_to_path <directory>"
        return 1
    end
    if not test -d "$dir"
        echo "❌ Répertoire '$dir' inexistant."
        return 1
    end
    if not contains "$dir" (string split ":" "$PATH")
        set -gx PATH "$dir:$PATH"
        echo "✅ Ajouté au PATH: $dir"
    else
        echo "⚠️  Déjà présent dans PATH: $dir"
    end
end

# DESC: Nettoie le PATH en supprimant les doublons et répertoires invalides. Fonction exportée pour utilisation globale.
# USAGE: clean_path
# EXAMPLE: clean_path
function clean_path -d "Nettoie le PATH des doublons et répertoires invalides"
    set -l path_list (string split ":" "$PATH")
    set -l new_path_list
    set -l seen_list
    
    for dir in $path_list
        if test -n "$dir" && test -d "$dir"
            if not contains "$dir" $seen_list
                set -a new_path_list "$dir"
                set -a seen_list "$dir"
            end
        end
    end
    
    set -gx PATH (string join ":" $new_path_list)
    echo "✅ PATH nettoyé"
end

# Alias (Fish)
function pm
    pathman $argv
end

function path-manager
    pathman $argv
end

