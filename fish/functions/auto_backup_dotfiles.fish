function auto_backup_dotfiles
    set dotfiles_dir "$HOME/dotfiles"
    set log_file "$dotfiles_dir/auto_backup.log"
    cd $dotfiles_dir

    if test (git status --porcelain | wc -l) -gt 0
        git add .
        git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" >> $log_file 2>&1
        git push origin master >> $log_file 2>&1
        echo "Dotfiles sauvegardés et poussés vers le dépôt distant. Consultez $log_file pour plus de détails." >> $log_file
    else
        echo "Aucun changement détecté dans les dotfiles." >> $log_file
    end
end

