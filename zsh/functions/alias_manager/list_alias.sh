# DESC: Liste tous les alias existants
# USAGE: list_aliases
list_aliases() {
    grep -E '^alias ' ~/dotfiles/.zsh/aliases.zsh | sed 's/^alias/👉 Alias:/'
}
