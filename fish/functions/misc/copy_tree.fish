function copy_tree
    set -l dir $argv[1]
    if test -z "$dir"
        set dir "."
    end

    if not test -d "$dir"
        echo "❌ Le répertoire '$dir' n'existe pas."
        return 1
    end

    set -l tree_output (tree -a -I '.*' "$dir" 2>/dev/null)
    if test -n "$tree_output"
        echo "$tree_output" | fish_clipboard_copy
        echo "📋 Sortie de 'tree' du répertoire '$dir' copiée dans le presse-papier."
    else
        echo "❌ Impossible de générer le 'tree' du répertoire '$dir'."
    end
end

