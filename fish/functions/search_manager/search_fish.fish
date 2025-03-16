function search_fish -d "Recherche des alias et des fonctions"
    set -l search_term $argv[1]
    if test -z "$search_term"
        echo "Usage: search_fish <search_term>"
        return 1
    end
    
    echo "Matching aliases:"
    set -l found_aliases 0
    grep -i "$search_term" "$ALIASES_FILE" | while read -l line
        if string match -q "# DESC:*" $line
            set desc (string replace "# DESC: " "" $line)
            echo "📝 Description: $desc"
        else
            set alias_name (string replace -r "alias ([^ ]+).*" '$1' $line)
            set alias_command (string replace -r "alias [^ ]+ '(.*)'" '$1' $line)
            echo "👉 Alias: $alias_name"
            echo "🔧 Command: $alias_command"
        end
        echo ""
        set found_aliases 1
    end
    
    if test $found_aliases -eq 0
        echo "Aucun alias trouvé pour '$search_term'"
    end
    
    echo "Matching functions:"
    set -l found_functions 0
    for func_file in $FUNCTIONS_DIR/**/*.fish
        set -l func_name (string replace -r '.*/([^/]+)\.fish$' '$1' $func_file)
        if string match -iq "*$search_term*" "$func_name"
            set -l func_content (cat $func_file)
            set -l desc (string match -r '^\s*#\s*Description:.*' $func_content | string replace -r '^\s*#\s*Description:\s*' '')
            set -l usage (string match -r '^\s*#\s*Usage:.*' $func_content | string replace -r '^\s*#\s*Usage:\s*' '')
            
            echo "🐠 Function: $func_name"
            if test -n "$desc"
                echo "📝 Description: $desc"
            end
            echo "📂 Defined in: $func_file"
            if test -n "$usage"
                echo "🔧 Usage: $usage"
            end
            echo ""
            set found_functions 1
        end
    end
    
    if test $found_functions -eq 0
        echo "Aucune fonction trouvée pour '$search_term'"
    end
end

