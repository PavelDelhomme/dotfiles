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

    # Charger .env si disponible
    if [ -f "$HOME/dotfiles/.env" ]; then
        source "$HOME/dotfiles/.env"
    fi

    if [[ "$arg" == "perso" ]]; then
        if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
            git config --global user.name "$GIT_USER_NAME"
            git config --global user.email "$GIT_USER_EMAIL"
            echo "Profil global Git: perso ($GIT_USER_NAME)"
            whoami-git
        else
            echo "Erreur: GIT_USER_NAME et GIT_USER_EMAIL doivent être définis dans ~/dotfiles/.env"
            echo "Ou configurez Git manuellement avec:"
            echo "  git config --global user.name 'Votre Nom'"
            echo "  git config --global user.email 'votre@email.com'"
        fi
    else
        echo "Usage: switch-git-identity [perso]"
        echo "Pour le moment, seul le compte perso est configuré."
        echo "Les valeurs sont chargées depuis ~/dotfiles/.env"
    fi
}

