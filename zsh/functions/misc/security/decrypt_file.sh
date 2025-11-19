# DESC: Déchiffre un fichier chiffré avec OpenSSL
# USAGE: decrypt_file <file_path> <password>
decrypt_file() {
	local file="$1"
	local password="$2"
	if [[ -f "$file" ]]; then
		openssl enc -d -aes-256-cbc -in "$file" -out "${file%.enc}" -k "$password"
		echo "✅ Fichier déchiffré : ${file%.enc}"
	else
		echo "❌ Fichier '$file' introuvable."
	fi
}

