# DESC: Recherche un alias ou une fonction dans la configuration ZSH
# USAGE: search_zsh <mot_cle>
search_zsh() {
    local keyword="$1"
    if [[ -z "$keyword" ]]; then
        echo "❌ Usage: search_zsh <mot_cle>"
    fi

    echo "🔍 Recherche de '$keyword' dans les alias et fonctions"
    echo "---------------------------------------------"

    echo "📝 Alias définis dans ~/dotfiles/.zsh/aliases.zsh"
    grep -iE "$keyword" ~/dotfiles/.zsh/aliases.zsh | sed 's/^# DESC:/👉 /'

    # Rechercher dans les fonctions
    echo "📝 Fonctions définies dans ~/dotfiles/.zsh/functions/"
    find ~/dotfiles/.zsh/functions/ -type f -name '*.sh' -exec grep -H -iE "$keyword" {} + | sed 's/^# DESC:/👉 /'
    echo "---------------------------------------------"
}
