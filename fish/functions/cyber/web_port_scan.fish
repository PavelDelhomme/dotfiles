function web_port_scan
    set target $argv[1]
    set option $argv[2]
    if test -z "$target"
        echo "❌ Usage: web_port_scan <url> [options]"
        echo "Options:"
        echo "  -f, --full       Scan complet de tous les ports"
        echo "  -q, --quick      Scan rapide des ports les plus courants"
        echo "  -s, --service    Détection des services"
        return 1
    end

    switch $option
        case -f --full
            echo "🔍 Exécution d'un scan complet des ports sur $target"
            nmap -p- -Pn $target
        case -q --quick
            echo "🚀 Exécution d'un scan rapide des ports courants sur $target"
            nmap -F -Pn $target
        case -s --service
            echo "🔍 Exécution d'un scan avec détection de services sur $target"
            nmap -sV -Pn $target
        case '*'
            echo "🔍 Exécution d'un scan de ports standard sur $target"
            nmap -Pn $target
    end
end

