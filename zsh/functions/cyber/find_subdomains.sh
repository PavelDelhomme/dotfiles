# DESC: Recherche les sous-domaines d'un domaine
# USAGE: find_subdomains <domain>
find_subdomains() {
	local domain="$1"
	subfinder -d "$domain"
}
