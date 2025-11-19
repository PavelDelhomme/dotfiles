# DESC: Exécute un scan de ports avancé sur une URL cible
# USAGE: web_port_scan <url> [options]
web_port_scan() {
    local target="$1"
    shift
    if [[ -z "$target" ]]; then
        echo "❌ Usage: web_port_scan <url> [options]"
        echo "Options:"
        echo "  -f, --full       Scan complet de tous les ports"
        echo "  -q, --quick      Scan rapide des ports les plus courants"
        echo "  -s, --service    Détection des services"
        return 1
    fi

    case "$1" in
        -f|--full)
            echo "🔍 Exécution d'un scan complet des ports sur $target"
            nmap -p- -Pn "$target"
            ;;
        -q|--quick)
            echo "🚀 Exécution d'un scan rapide des ports courants sur $target"
            nmap -F -Pn "$target"
            ;;
        -s|--service)
            echo "🔍 Exécution d'un scan avec détection de services sur $target"
            nmap -sV -Pn "$target"
            ;;
        *)
            echo "🔍 Exécution d'un scan de ports standard sur $target"
            nmap -Pn "$target"
            ;;
    esac
}

