set ALIASES_FILE "$HOME/dotfiles/fish/aliases.fish"

function add_alias
    set name $argv[1]
    set command $argv[2]
    set description $argv[3]

    if not test -f "$ALIASES_FILE"
        echo "❌ Le fichier $ALIASES_FILE n'existe pas."
        return 1
    end

    if grep -q "^alias $name " "$ALIASES_FILE"
        echo " !  L'alias '$name' existe déjà."
        return 1
    end

    if test -n "$description"
        echo "# DESC: $description" >> "$ALIASES_FILE"
    end

    echo "alias $name '$command'" >> "$ALIASES_FILE"
    source "$ALIASES_FILE"
    echo "Alias '$name' ajouté et chargé."
end

