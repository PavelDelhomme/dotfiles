# DESC: Chiffre un fichier avec OpenSSL
# USAGE: encrypt_file <file_path> <password>
encrypt_file() {
	local file="$1"
	local password="$2"
	if [[ -f "$file" ]]; then
		openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.enc" -k "$password"
		echo "✅ Fichier chiffré : ${file}.enc"
	else
		echo "❌ Fichier '$file' introuvable."
	fi
}
