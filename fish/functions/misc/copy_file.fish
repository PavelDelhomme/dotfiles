function copy_file
    set file_path $argv[1]
    if test -f "$file_path"
        cat "$file_path" | fish_clipboard_copy
        echo "📋 Contenu de '$file_path' copié dans le presse-papier."
    else
        echo "❌ Fichier '$file_path' introuvable ou vide."
        return 1
    end
end

