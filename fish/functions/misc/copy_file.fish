function copy_file
    if test -f $argv[1]
        cat $argv[1] | xclip -selection clipboard
        echo "📋 Contenu de '$argv[1]' copié dans le presse-papier."
    else
        echo "❌ Fichier '$argv[1]' introuvable ou vide."
    end
end

