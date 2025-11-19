# DESC: Tente de cracker un mot de passe hashé avec John the Ripper
# USAGE: password_crack <hash_file>
password_crack() {
	local hash_file="$1"
	if [[ -f "$hash_file" ]]; then
		john "$hash_file"
	else
		echo "❌ Fichier '$hash_file' introuvable."
	fi
}
