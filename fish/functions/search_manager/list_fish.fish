function list_fish
    echo "Aliases:"
    alias | sed 's/^/👉 /'
    echo "\nFunctions:"
    for func in (functions)
        set -l desc (functions -Dv $func | string match -r 'Description: .*' | string replace 'Description: ' '')
        if test -n "$desc"
            echo "🐠 $func - $desc"
        else
            echo "🐠 $func"
        end
    end
end

