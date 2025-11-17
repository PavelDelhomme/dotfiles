# ~/dotfiles/zsh/functions/git/git_functions.sh
# Fonctions utilitaires pour Git

################################################################################
# DESC: Affiche l'identité Git configurée
# USAGE: whoami-git
################################################################################
whoami-git() {
    echo "user.name = $(git config --global user.name)"
    echo "user.email = $(git config --global user.email)"
    echo "Répertoire courant : $PWD"
}

################################################################################
# DESC: Configure l'identité Git (compte perso)
# USAGE: switch-git-identity [perso]
#       Par défaut, configure le compte perso
################################################################################
switch-git-identity() {
    local arg="${1:-perso}"

    if [[ "$arg" == "perso" ]]; then
        git config --global user.name "Paul Delhomme"
        git config --global user.email "36136537+PavelDelhomme@users.noreply.github.com"
        echo "Profil global Git: perso (Paul Delhomme)"
        whoami-git
    else
        echo "Usage: switch-git-identity [perso]"
        echo "Pour le moment, seul le compte perso est configuré."
    fi
}

