# DESC: Effectue une reconnaissance sur un domaine cible
# USAGE: recon_domain <domaine>
recon_domain() {
    local domaine="$1"
    whois "$domaine"
    dig "$domaine" any +multiline +noall +answer
    theHarvester -d "$domaine" -l 500 -b all
}
