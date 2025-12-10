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
set -g DOTFILES_ZSH_PATH "$DOTFILES_PATH/zsh"  # Pour partager env.sh et aliases.zsh
set -g ENV_FILE "$DOTFILES_FISH_PATH/env.fish"
set -g ALIASES_FILE "$DOTFILES_FISH_PATH/aliases.fish"
set -g FUNCTIONS_DIR "$DOTFILES_FISH_PATH/functions"

# =============================================================================
# ÉTAPE 1 : CHARGEMENT DU GESTIONNAIRE DE MODULES (MODULEMAN) EN PREMIER
# =============================================================================
# Chercher le fichier de configuration dans plusieurs emplacements
set -g MODULEMAN_CONFIG_FILE "$HOME/dotfiles/.config/moduleman/modules.conf"
if not test -f "$MODULEMAN_CONFIG_FILE"
    set -g MODULEMAN_CONFIG_FILE "$HOME/.config/moduleman/modules.conf"
end

if test -f "$MODULEMAN_CONFIG_FILE"
    source "$MODULEMAN_CONFIG_FILE" 2>/dev/null || true
end

# Charger moduleman pour gérer les modules
if test -f "$DOTFILES_FISH_PATH/functions/moduleman.fish"
    source "$DOTFILES_FISH_PATH/functions/moduleman.fish" 2>/dev/null || true
end

# =============================================================================
# ÉTAPE 2 : CHARGEMENT DES GESTIONNAIRES (*MAN) SELON LA CONFIGURATION
# =============================================================================
# Fonction pour charger un manager si activé (version Fish)
function load_manager -d "Charger un manager si activé"
    set -l manager_name "$argv[1]"
    set -l manager_file "$argv[2]"
    set -l display_name "$argv[3]"
    set -l var_name "MODULE_"(string upper $manager_name)
    set -l module_status (eval "echo \$$var_name" 2>/dev/null || echo "enabled")
    
    if test "$module_status" = "enabled"
        if test -f "$manager_file"
            source "$manager_file" >/dev/null 2>&1 || true
            # Messages désactivés pour éviter le bruit
        end
    end
end

# =============================================================================
# CONFIGURATION HISTORIQUE (AVANT CHARGEMENT MANAGERS)
# =============================================================================
# Charger la configuration d'historique partagé
if test -f "$DOTFILES_FISH_PATH/history.fish"
    source "$DOTFILES_FISH_PATH/history.fish" 2>/dev/null || true
end

# Charger les managers (même ordre que ZSH)
# Charger pathman depuis la nouvelle structure hybride
load_manager "pathman" "$DOTFILES_DIR/shells/fish/adapters/pathman.fish" "PATHMAN"
load_manager "netman" "$DOTFILES_FISH_PATH/functions/netman.fish" "NETMAN"
load_manager "aliaman" "$DOTFILES_FISH_PATH/functions/aliaman.fish" "ALIAMAN"
load_manager "miscman" "$DOTFILES_FISH_PATH/functions/miscman.fish" "MISCMAN"
load_manager "searchman" "$DOTFILES_FISH_PATH/functions/searchman.fish" "SEARCHMAN"
load_manager "cyberman" "$DOTFILES_FISH_PATH/functions/cyberman.fish" "CYBERMAN"
load_manager "devman" "$DOTFILES_FISH_PATH/functions/devman.fish" "DEVMAN"
load_manager "gitman" "$DOTFILES_FISH_PATH/functions/gitman.fish" "GITMAN"
load_manager "helpman" "$DOTFILES_FISH_PATH/functions/helpman.fish" "HELPMAN"
load_manager "manman" "$DOTFILES_FISH_PATH/functions/manman.fish" "MANMAN"
load_manager "configman" "$DOTFILES_FISH_PATH/functions/configman.fish" "CONFIGMAN"
load_manager "installman" "$DOTFILES_FISH_PATH/functions/installman.fish" "INSTALLMAN"
load_manager "moduleman" "$DOTFILES_FISH_PATH/functions/moduleman.fish" "MODULEMAN"
load_manager "fileman" "$DOTFILES_FISH_PATH/functions/fileman.fish" "FILEMAN"
load_manager "virtman" "$DOTFILES_FISH_PATH/functions/virtman.fish" "VIRTMAN"
load_manager "sshman" "$DOTFILES_FISH_PATH/functions/sshman.fish" "SSHMAN"
load_manager "testzshman" "$DOTFILES_FISH_PATH/functions/testzshman.fish" "TESTZSHMAN"
load_manager "testman" "$DOTFILES_FISH_PATH/functions/testman.fish" "TESTMAN"


# =============================================================================
# CHARGEMENT DES COMMANDES STANDALONE (NON-MANAGERS)
# =============================================================================
# Charger toutes les commandes standalone (ipinfo, whatismyip, network_scanner, etc.)
if test -f "$DOTFILES_FISH_PATH/functions/commands/load_commands.fish"
    source "$DOTFILES_FISH_PATH/functions/commands/load_commands.fish" 2>/dev/null || true
end

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
