function web_dir_enum
    if test (count $argv) -eq 0
        echo "Usage: web_dir_enum <url> [wordlist]"
        echo "Énumère les répertoires d'un site web."
        echo "Exemple: web_dir_enum https://example.com /usr/share/wordlists/dirb/common.txt"
        return 1
    end

    set url $argv[1]
    set wordlist $argv[2]
    set -q wordlist[1]; or set wordlist /usr/share/wordlists/dirb/common.txt

    if not test -f $wordlist
        echo "❌ Wordlist non trouvée : $wordlist"
        return 1
    end

    echo "🔍 Énumération des répertoires pour $url"
    echo "📚 Utilisation de la wordlist : $wordlist"

    gobuster dir -u $url -w $wordlist -q -n -e
end

