# DESC: Génère un mot de passe aléatoire
# USAGE: gen_password <length>
# EXAMPLE: gen_password
gen_password() {
	local length="${1:-16}"
	LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*()_+{}|:<>?' </dev/urandom | head -c "$length" ; echo
}
