function web_vuln_scan
    set url $argv[1]
    set option $argv[2]
    if test -z "$url"
        echo "❌ Usage: web_vuln_scan <url> [options]"
        echo "Options:"
        echo "  -f, --full       Effectue un scan complet (peut prendre du temps)"
        echo "  -q, --quick      Effectue un scan rapide"
        echo "  -w, --wordpress  Scan spécifique pour WordPress"
        return 1
    end

    switch $option
        case -f --full
            echo "🔍 Exécution d'un scan complet sur $url"
            nikto -h $url -C all
        case -q --quick
            echo "🚀 Exécution d'un scan rapide sur $url"
            nikto -h $url -Tuning 123
        case -w --wordpress
            echo "🔍 Exécution d'un scan WordPress sur $url"
            wpscan --url $url --enumerate vp,vt,tt,cb,dbe,u,m
        case '*'
            echo "🔍 Exécution d'un scan standard sur $url"
            nikto -h $url
    end
end

