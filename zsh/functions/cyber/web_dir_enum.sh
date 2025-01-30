web_dir_enum() {
    if [ $# -eq 0 ]; then
        echo "Usage: web_dir_enum <url> [wordlist]"
        echo "Énumère les répertoires d'un site web."
        echo "Exemple: web_dir_enum https://example.com /usr/share/wordlists/dirb/common.txt"
        return 1
    fi

    local url=$1
    local wordlist=${2:-/usr/share/wordlists/dirb/common.txt}

    if [ ! -f "$wordlist" ]; then
        echo "❌ Wordlist non trouvée : $wordlist"
        return 1
    fi

    echo "🔍 Énumération des répertoires pour $url"
    echo "📚 Utilisation de la wordlist : $wordlist"
    
    gobuster dir -u $url -w $wordlist -q -n -e
}

