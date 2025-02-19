function auto_backup_dotfiles
    set dotfiles_dir "$HOME/dotfiles"
    cd $dotfiles_dir

    # Vérifier s'il y a des changements
    if test (git status --porcelain | wc -l) -gt 0
        # Il y a des changements, on les commit
        git add .
        git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
        git push origin master  # Assurez-vous que 'main' est le nom de votre branche principale
        echo "Dotfiles sauvegardés et poussés vers le dépôt distant."
    else
        echo "Aucun changement détecté dans les dotfiles."
    end
end

