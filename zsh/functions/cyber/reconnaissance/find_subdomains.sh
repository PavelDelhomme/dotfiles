# DESC: Recherche les sous-domaines d'un domaine
# USAGE: find_subdomains <domain>
# EXAMPLE: find_subdomains example.com
find_subdomains() {
	local domain="$1"
	subfinder -d "$domain"
}
