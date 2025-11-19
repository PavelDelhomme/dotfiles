# DESC: Exécute une commande via Proxychains pour anonymiser le trafic
# USAGE: proxycmd <commande>
proxycmd() {
    local cmd="$*"
    proxychains4 $cmd
}
