function dnsenum_scan
    if test (count $argv) -eq 0
        echo "Usage: dnsenum_scan <domain>"
        echo "Effectue une énumération DNS avec DNSenum."
        echo "Exemple: dnsenum_scan example.com"
        return 1
    end
    dnsenum $argv[1]
end

