function find_alias -d "Recherche un alias par mot-clé"
    # Usage: find_alias <search_term>
    #
    # Description:
    #   Cette fonction recherche des alias correspondant au terme de recherche spécifié.
    #   Elle affiche le nom de l'alias et la commande associée pour chaque correspondance.
    #
    # Arguments:
    #   search_term : Le terme à rechercher dans les alias
    #
    # Exemple:
    #   find_alias git
    #
    # Sortie:
    #   Une liste formatée des alias correspondants avec leur commande associée

    set -l search_term $argv[1]
    if test -z "$search_term"
        echo "Usage: find_alias <search_term>"
        return 1
    end
    echo "Aliases correspondants à '$search_term':"
    echo "======================================="
    set -l found_aliases 0
    grep -iE "alias.*$search_term" "$ALIASES_FILE" | while read -l line
        set -l alias_name (echo $line | sed -E 's/alias ([^ ]+).*/\1/')
        set -l alias_command (echo $line | sed -E "s/alias $alias_name '(.*)'/\1/")
        echo "• $alias_name"
        echo "  Commande: $alias_command"
        echo
        set found_aliases 1
    end
    
    if test $found_aliases -eq 0
        echo "Aucun alias trouvé pour '$search_term'"
    end
end

