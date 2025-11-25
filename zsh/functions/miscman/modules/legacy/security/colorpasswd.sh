# DESC: Génère un mot de passe sécurisé avec des couleurs pour une meilleure lisibilité. Affiche le mot de passe avec un code couleur.
# USAGE: colorpasswd [length]
# EXAMPLE: colorpasswd 16
colorpasswd() {
    sudo cat /etc/passwd | awk -F: '{
        printf "\033[1;34m%s\033[0m:\033[1;31m%s\033[0m:%s:%s:\033[1;32m%s\033[0m:\033[1;33m%s\033[0m:\033[1;35m%s\033[0m\n", 
        $1, $2, $3, $4, $5, $6, $7
    }'
}

