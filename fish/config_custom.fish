# Restaurer le PATH original si nécessaire
if set -q PATH_ORIGINAL
    set -g PATH $PATH_ORIGINAL
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
        fish -c "while true; auto_backup_dotfiles; sleep 900; end" &
        disown
        echo "Sauvegarde automatique démarrée en arrière-plan"
    else
        echo "La sauvegarde automatique est déjà en cours d'exécution"
    end
end


# === Définition des chemins (VARIABLES GLOBALES) ===
set -g DOTFILES_PATH "$HOME/dotfiles"
set -g DOTFILES_FISH_PATH "$DOTFILES_PATH/fish"
set -g ENV_FILE "$DOTFILES_FISH_PATH/env.fish"
set -g ALIASES_FILE "$DOTFILES_FISH_PATH/aliases.fish"
set -g FUNCTIONS_DIR "$DOTFILES_FISH_PATH/functions"


# Charger update_system.fish en premier pour remplacer les alias update/upgrade
if test -f $FUNCTIONS_DIR/update_system.fish
    source $FUNCTIONS_DIR/update_system.fish
    echo "✔ Chargé : update_system.fish"
end

for func_dir in $FUNCTIONS_DIR/*
    if test -d $func_dir
        for func_file in $func_dir/*.fish
            # Ignorer update_system.fish déjà chargé
            if not test "$func_file" = "$FUNCTIONS_DIR/update_system.fish"
                source $func_file
                echo "✔ Chargé : $func_file"
            end
        end
    end
end

# === Auto-backup ===
function auto_backup_dotfiles
    set dotfiles_dir "$HOME/dotfiles"
    set log_file "$dotfiles_dir/logs/auto_backup.log"
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
