# DESC: Recherche une commande dans l'historique de ZSH
# USAGE: search_history <mot_cle>
search_history() {
	local keyword="$1"
	if [[ -z "$keyword" ]]; then
		echo "❌ Usage: search_history <mot_cle>"
		return 1
	fi
	
    	echo "🔍 Recherche de '$keyword' dans l'historique des commandes"
    	echo "---------------------------------------------"
    	history | grep -iE "$keyword"
    	echo "---------------------------------------------"
    	echo "✅ Fin de la recherche dans l'historique"
}
