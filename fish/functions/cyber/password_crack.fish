function password_crack
    set hash_file $argv[1]
    if test -f $hash_file
        john $hash_file
    else
        echo "❌ Fichier '$hash_file' introuvable."
    end
end

