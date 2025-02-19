# Restaurer le PATH original si nécessaire
if set -q PATH_ORIGINAL
    set PATH $PATH_ORIGINAL
end

set -g AUTO_BACKUP_PID_FILE "/tmp/auto_backup_dotfiles.pid"

function start_auto_backup
	while true
		auto_backup_dotfiles
		sleep 900
	end
end


function start_auto_backup_if_not_running
	if not test -f $AUTO_BACKUP_PID_FILE
		start_auto_backup &
		echo $fish_pid > $AUTO_BACKUP_PID_FILE
		echo "Sauvegarde automatique démarré"
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
