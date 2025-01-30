backup_dotfiles() {
    echo "📁 Sauvegarde des dotfiles..."
    cd ~/dotfiles
    git add .
    git commit -m "Sauvegarde manuelle - $(date)"
    git push origin master
    echo "✅ Sauvegarde terminée."
}

