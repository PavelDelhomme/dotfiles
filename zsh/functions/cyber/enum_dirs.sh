# Fonction pour énumérer les répertoires avec Gobuster
function enum_dirs() {
    if [ $# -eq 0 ]; then
        echo "Usage: enum_dirs <url> [wordlist]"
        echo "Énumère les répertoires d'un site web."
        echo "Exemple: enum_dirs http://example.com ~/SecLists/Discovery/Web-Content/common.txt"
        return 1
    fi

    local url=$1
    local wordlist=${2:-~/SecLists/Discovery/Web-Content/common.txt}

    gobuster dir -u "$url" -w "$wordlist"
}
