# Restaurer le PATH original si nécessaire
if set -q PATH_ORIGINAL
    set PATH $PATH_ORIGINAL
end

set -g AUTO_BACKUP_PID_FILE "/tmp/auto_backup_dotfiles.pid"

function start_auto_backup
    set -l iterations 0
    set -l max_iterations 96 # 24 heures à raison d'une sauvegarde toutes les 15 minutes
    while test $iterations -lt $max_iterations
        auto_backup_dotfiles
        sleep 900 # 15 minutes
        set iterations (math $iterations + 1)
    end
    rm /tmp/auto_backup_dotfiles.lock
end



function start_auto_backup_if_not_running
    set -l lock_file /tmp/auto_backup_dotfiles.lock
    if not test -f $lock_file
        touch $lock_file
        start_auto_backup &
        disown
    else
        echo "La sauvegarde automatique est déjà en cours d'exécution"
    end
end


set DOTFILES_PATH "$HOME/dotfiles/"
set DOTFILES_FISH_PATH "$DOTFILES_PATH/fish/"
set ENV_FILE "$DOTFILES_FISH_PATH/env.fish"
set ALIASES_FILE "$DOTFILES_FISH_PATH/aliases.fish"
set FUNCTIONS_DIR "$DOTFILES_FISH_PATH/functions/"

# === Chargement des fonctions ===
if test -d $FUNCTIONS_DIR
    for func_file in $FUNCTIONS_DIR/*.fish
        if test -f $func_file
            source $func_file
            echo "✔️ Chargé : $func_file"
        else
            echo "❌ Erreur de chargement : $func_file"
        end
    end
else
    echo "⚠️ Répertoire de fonctions introuvable : $FUNCTIONS_DIR"
end

function backup_dotfiles
    echo "📁 Sauvegarde manuelle des dotfiles..."
    ~/auto_backup_dotfiles.sh
    echo "✅ Sauvegarde terminée."
end

# === Environments ===
if test -f $ENV_FILE
    source $ENV_FILE
else
    echo "⚠️ Fichier $ENV_FILE introuvable."
end

# === Chargement des alias ===
if test -f $ALIASES_FILE
    source $ALIASES_FILE
else
    echo "⚠️ Fichier $ALIASES_FILE introuvable."
end

#neofetch
start_auto_backup_if_not_running
