function search_history
    set -l search_term $argv[1]
    if test -z "$search_term"
        echo "Usage: search_history <search_term>"
        return 1
    end
    history search --contains "$search_term" | while read -l cmd
        set -l output (eval "$cmd" 2>&1)
        echo "Command: $cmd"
        echo "Output: $output"
        echo "---"
    end
end

