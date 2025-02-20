function enum_dirs
    if test (count $argv) -eq 0
        echo "Usage: enum_dirs <url> [wordlist]"
        echo "Énumère les répertoires d'un site web."
        echo "Exemple: enum_dirs http://example.com ~/SecLists/Discovery/Web-Content/common.txt"
        return 1
    end

    set url $argv[1]
    set wordlist $argv[2]
    set -q wordlist[1]; or set wordlist ~/SecLists/Discovery/Web-Content/common.txt

    gobuster dir -u $url -w $wordlist
end

