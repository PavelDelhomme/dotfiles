# ~/.zsh/functions/misc.sh

# === Fonction copy_file ===
# DESC: Copie le contenu d'un fichier dans le presse-papier
# USAGE: copy_file <file_path>
copy_file() {
	if [[ -f "$1" ]]; then
		cat "$1" | xclip -selection clipboard
		echo "📋 Contenu de '$1' copié dans le presse-papier."
	else
		echo "❌ Fichier '$1' introuvable ou vide."
	fi
}

# === Fonction copy_tree ===
# DESC: Copie l'arborescence d'un répertoire
# USAGE: copy_tree <directory_path>
copy_tree() {
	local dir="${1:-.}"  # Par défaut, le répertoire actuel
	if [[ ! -d "$dir" ]]; then
		echo "❌ Le répertoire '$dir' n'existe pas."
		return 1
	fi
	local tree_output
	# Exclure les fichiers cachés (.git, .DS_Store, etc.) et mettre le résultat dans une variable
	tree_output=$(tree -a -I '.*' "$dir" 2>/dev/null)
	if [ -n "$tree_output" ]; then
		echo "$tree_output" | xclip -selection clipboard
		echo "📋 Sortie de 'tree' du répertoire '$dir' copiée dans le presse-papier."
	else
		echo "❌ Impossible de générer le 'tree' du répertoire '$dir'."
	fi
}


# === Fonction create_backup ===
# DESC: Crée une sauvegarde d'un fichier avec un horodatage
# USAGE: create_backup <file_path>
create_backup() {
	local file="$1"
	if [[ -f "$file" ]]; then
		local backup_file="${file}_backup_$(date +%Y%m%d%H%M%S)"
		cp "$file" "$backup_file"
		echo "✅ Sauvegarde créée : $backup_file"
	else
		echo "❌ Fichier '$file' introuvable."
	fi
}


# === Fonction extract ===
# DESC: Extrait automatiquement des fichiers d'archive (tar, zip, rar, etc.)
# USAGE: extract <file_path>
extract() {
	if [[ -f "$1" ]]; then
		case "$1" in
			*.tar.bz2) tar xvjf "$1" ;;
			*.tar.gz) tar xvzf "$1" ;;
			*.tar.xz) tar xvJf "$1" ;;
			*.tar) tar xvf "$1" ;;
			*.gz) gunzip "$1" ;;
			*.bz2) bunzip2 "$1" ;;
			*.xz) unxz "$1" ;;
			*.zip) unzip "$1" ;;
			*.rar) unrar x "$1" ;;
			*.7z) 7z x "$1" ;;
			*) echo "❌ Format de fichier non pris en charge: '$1'" ;;
		esac
	else
		echo "❌ Fichier '$1' introuvable."
	fi
}




# === Fonction open_ports ===
# DESC: Affiche la liste des ports ouverts
# USAGE: open_ports
open_ports() {
	sudo netstat -tuln | grep LISTEN
}

# === Fonction show_ip ===
# DESC: Affiche l'adresse IP publique
# USAGE: show_ip
show_ip() {
	curl -s https://ipinfo.io/ip
}

# === Fonction gen_password ===
# DESC: Génère un mot de passe aléatoire
# USAGE: gen_password <length>
gen_password() {
	local length="${1:-16}"
	LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*()_+{}|:<>?' </dev/urandom | head -c "$length" ; echo
}

# === Fonction reload_shell ===
# DESC: Recharge la configuration du shell
# USAGE: reload_shell
reload_shell() {
	exec "$SHELL" -l
}

# === Fonction system_info ===
# DESC: Affiche des informations sur le système
# USAGE: system_info
system_info() {
	echo "📊 Informations sur le système :"
	echo "-------------------------------"
	echo "Système d'exploitation : $(uname -a)"
	echo "Utilisateur : $USER"
	echo "Uptime : $(uptime -p)"
	echo "Espace disque :"
	df -h /
	echo "Utilisation de la RAM :"
	free -h
}

# === Fonction encrypt_file ===
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

# === Fonction decrypt_file ===
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



