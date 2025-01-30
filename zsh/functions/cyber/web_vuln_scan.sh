# DESC: Exécute un scan de vulnérabilités web avancé sur une URL cible
# USAGE: web_vuln_scan <url> [options]
web_vuln_scan() {
    local url="$1"
    shift
    if [[ -z "$url" ]]; then
        echo "❌ Usage: web_vuln_scan <url> [options]"
        echo "Options:"
        echo "  -f, --full       Effectue un scan complet (peut prendre du temps)"
        echo "  -q, --quick      Effectue un scan rapide"
        echo "  -w, --wordpress  Scan spécifique pour WordPress"
        return 1
    fi

    case "$1" in
        -f|--full)
            echo "🔍 Exécution d'un scan complet sur $url"
            nikto -h "$url" -C all
            ;;
        -q|--quick)
            echo "🚀 Exécution d'un scan rapide sur $url"
            nikto -h "$url" -Tuning 123
            ;;
        -w|--wordpress)
            echo "🔍 Exécution d'un scan WordPress sur $url"
            wpscan --url "$url" --enumerate vp,vt,tt,cb,dbe,u,m
            ;;
        *)
            echo "🔍 Exécution d'un scan standard sur $url"
            nikto -h "$url"
            ;;
    esac
}

