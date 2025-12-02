# =============================================================================
# MODULEMAN - Module Manager pour Fish
# =============================================================================
# Description: Gestionnaire pour activer/désactiver les modules et fonctions
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -g MODULEMAN_CONFIG_DIR "$HOME/dotfiles/.config/moduleman"
set -g MODULEMAN_CONFIG_FILE "$MODULEMAN_CONFIG_DIR/modules.conf"
set -g DOTFILES_DIR "$HOME/dotfiles"
set -g FUNCTIONS_DIR "$DOTFILES_DIR/fish/functions"

# Créer le répertoire de configuration si nécessaire
mkdir -p $MODULEMAN_CONFIG_DIR

# DESC: Gestionnaire interactif pour activer/désactiver les modules
# USAGE: moduleman [enable|disable|list|status] [module-name]
# EXAMPLE: moduleman
# EXAMPLE: moduleman enable cyberman
# EXAMPLE: moduleman disable miscman
function moduleman
    set -l cmd $argv[1]
    set -l module_name $argv[2]
    
    # Charger la configuration
    if not test -f $MODULEMAN_CONFIG_FILE
        create_default_config
    end
    
    # Charger les variables depuis le fichier de config
    source $MODULEMAN_CONFIG_FILE 2>/dev/null || true
    
    if test -z "$cmd"
        # Mode interactif
        show_main_menu
    else
        switch $cmd
            case enable activer
                if test -z "$module_name"
                    echo "❌ Usage: moduleman enable <module-name>"
                    return 1
                end
                enable_module $module_name
            case disable désactiver
                if test -z "$module_name"
                    echo "❌ Usage: moduleman disable <module-name>"
                    return 1
                end
                disable_module $module_name
            case list liste
                list_modules
            case status statut
                show_status
            case '*'
                echo "❌ Commande inconnue: $cmd"
                echo ""
                echo "Commandes disponibles:"
                echo "  moduleman                    # Menu interactif"
                echo "  moduleman enable <module>    # Activer un module"
                echo "  moduleman disable <module>   # Désactiver un module"
                echo "  moduleman list                # Lister tous les modules"
                echo "  moduleman status              # Afficher le statut"
                return 1
        end
    end
end

# Créer la configuration par défaut
function create_default_config
    cat > $MODULEMAN_CONFIG_FILE <<'EOF'
# Configuration des modules - Moduleman
# Format: set -g MODULE_<nom> enabled|disabled
# Tous les modules sont activés par défaut

set -g MODULE_pathman enabled
set -g MODULE_netman enabled
set -g MODULE_aliaman enabled
set -g MODULE_miscman enabled
set -g MODULE_searchman enabled
set -g MODULE_cyberman enabled
set -g MODULE_devman enabled
set -g MODULE_gitman enabled
set -g MODULE_helpman enabled
set -g MODULE_manman enabled
set -g MODULE_configman enabled
set -g MODULE_installman enabled
set -g MODULE_moduleman enabled
EOF
end

# Fonction pour afficher le header
function show_header
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  MODULEMAN - MODULE MANAGER                   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
end

# Fonction pour afficher le menu principal
function show_main_menu
    show_header
    echo "📦 GESTION DES MODULES"
    echo "══════════════════════════════════════════════════════════════════"
    echo ""
    
    source $MODULEMAN_CONFIG_FILE 2>/dev/null || true
    
    set -l managers pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman
    set -l descriptions "PATHMAN - Gestionnaire PATH" "NETMAN - Gestionnaire réseau" "ALIAMAN - Gestionnaire alias" "MISCMAN - Gestionnaire divers" "SEARCHMAN - Gestionnaire recherche" "CYBERMAN - Gestionnaire cybersécurité" "DEVMAN - Gestionnaire développement" "GITMAN - Gestionnaire Git" "HELPMAN - Gestionnaire aide/documentation" "MANMAN - Manager of Managers" "CONFIGMAN - Gestionnaire configurations" "INSTALLMAN - Gestionnaire installations" "MODULEMAN - Gestionnaire modules (ce menu)"
    
    set -l index 1
    for i in (seq (count $managers))
        set -l manager $managers[$i]
        set -l desc $descriptions[$i]
        set -l var_name "MODULE_$manager"
        set -l status (eval "echo \$$var_name")
        
        if test -z "$status"
            set status "enabled"
        end
        
        if test "$status" = "enabled"
            echo "$index. $desc [ACTIVÉ]"
        else
            echo "$index. $desc [DÉSACTIVÉ]"
        end
        set index (math $index + 1)
    end
    
    echo ""
    echo "0. Quitter"
    echo ""
    printf "Choix: "
    read choice
    
    if test "$choice" = "0"
        return 0
    end
    
    if test $choice -ge 1 -a $choice -le (count $managers)
        set -l selected_manager $managers[$choice]
        toggle_module $selected_manager
    else
        echo "❌ Choix invalide"
        sleep 1
    end
    
    echo ""
    read -P "Appuyez sur Entrée pour continuer... " dummy
    moduleman
end

# Fonction pour activer/désactiver un module
function toggle_module
    set -l module_name $argv[1]
    source $MODULEMAN_CONFIG_FILE 2>/dev/null || true
    set -l var_name "MODULE_$module_name"
    set -l current_status (eval "echo \$$var_name")
    
    if test -z "$current_status"
        set current_status "enabled"
    end
    
    if test "$current_status" = "enabled"
        disable_module $module_name
    else
        enable_module $module_name
    end
end

# Fonction pour activer un module
function enable_module
    set -l module_name $argv[1]
    
    # Mettre à jour le fichier de configuration
    if grep -q "^set -g MODULE_$module_name=" $MODULEMAN_CONFIG_FILE 2>/dev/null
        sed -i "s/^set -g MODULE_$module_name=.*/set -g MODULE_$module_name enabled/" $MODULEMAN_CONFIG_FILE
    else
        echo "set -g MODULE_$module_name enabled" >> $MODULEMAN_CONFIG_FILE
    end
    
    echo "✅ Module $module_name activé"
    echo "⚠️  Rechargez votre shell (source ~/.config/fish/config.fish) pour appliquer les changements"
end

# Fonction pour désactiver un module
function disable_module
    set -l module_name $argv[1]
    
    # Mettre à jour le fichier de configuration
    if grep -q "^set -g MODULE_$module_name=" $MODULEMAN_CONFIG_FILE 2>/dev/null
        sed -i "s/^set -g MODULE_$module_name=.*/set -g MODULE_$module_name disabled/" $MODULEMAN_CONFIG_FILE
    else
        echo "set -g MODULE_$module_name disabled" >> $MODULEMAN_CONFIG_FILE
    end
    
    echo "✅ Module $module_name désactivé"
    echo "⚠️  Rechargez votre shell (source ~/.config/fish/config.fish) pour appliquer les changements"
end

# Fonction pour lister les modules
function list_modules
    source $MODULEMAN_CONFIG_FILE 2>/dev/null || true
    echo "📋 Modules disponibles:"
    set -l managers pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman
    for manager in $managers
        set -l var_name "MODULE_$manager"
        set -l status (eval "echo \$$var_name")
        if test -z "$status"
            set status "enabled"
        end
        if test "$status" = "enabled"
            echo "  ✓ $manager [ACTIVÉ]"
        else
            echo "  ✗ $manager [DÉSACTIVÉ]"
        end
    end
end

# Fonction pour afficher le statut
function show_status
    source $MODULEMAN_CONFIG_FILE 2>/dev/null || true
    echo "📊 Statut des modules:"
    set -l managers pathman netman aliaman miscman searchman cyberman devman gitman helpman manman configman installman moduleman
    for manager in $managers
        set -l var_name "MODULE_$manager"
        set -l status (eval "echo \$$var_name")
        if test -z "$status"
            set status "enabled"
        end
        if test "$status" = "enabled"
            echo "  ✓ $manager"
        else
            echo "  ✗ $manager"
        end
    end
end

# Alias
alias mm='moduleman'
alias modman='moduleman'

