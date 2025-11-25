# DESC: Exécute une commande via Proxychains pour anonymiser le trafic
# USAGE: proxycmd <commande>
# EXAMPLE: proxycmd
proxycmd() {
    local cmd="$*"
    proxychains4 $cmd
}
