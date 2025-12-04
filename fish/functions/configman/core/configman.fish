# =============================================================================
# CONFIGMAN - Configuration Manager pour Fish
# =============================================================================
# Description: Gestionnaire complet des configurations système
# Author: Paul Delhomme
# Version: 1.0
# Converted from ZSH to Fish
# =============================================================================

# Répertoires de base
if not set -q CONFIGMAN_DIR
    set -g CONFIGMAN_DIR "$HOME/dotfiles/fish/functions/configman"
end

if not set -q DOTFILES_DIR
    set -g DOTFILES_DIR "$HOME/dotfiles"
end

# Utiliser les modules ZSH (partagés)
set -g ZSH_CONFIGMAN_DIR "$DOTFILES_DIR/zsh/functions/configman"
set -g CONFIGMAN_MODULES_DIR "$ZSH_CONFIGMAN_DIR/modules"

# Charger les utilitaires (via bash pour compatibilité)
if test -d "$CONFIGMAN_DIR/utils"
    for util_file in $CONFIGMAN_DIR/utils/*.sh
        if test -f "$util_file"
            bash -c "source '$util_file'" 2>/dev/null || true
        end
    end
end

# DESC: Gestionnaire interactif complet pour les configurations système
# USAGE: configman [category]
# EXAMPLE: configman
# EXAMPLE: configman git
# EXAMPLE: configman qemu
function configman
    set -l RED (set_color red)
    set -l GREEN (set_color green)
    set -l YELLOW (set_color yellow)
    set -l BLUE (set_color blue)
    set -l MAGENTA (set_color magenta)
    set -l CYAN (set_color cyan)
    set -l BOLD (set_color -o)
    set -l RESET (set_color normal)
    
    # Fonction pour afficher le header
    function show_header
        clear
        echo -e "$CYAN$BOLD"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  CONFIGMAN - CONFIGURATION MANAGER             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "$RESET"
    end
    
    # Fonction pour afficher le menu principal
    function show_main_menu
        show_header
        echo -e "$YELLOW⚙️  CONFIGURATIONS SYSTÈME$RESET"
        echo -e "$BLUE══════════════════════════════════════════════════════════════════$RESET\n"
        
        echo "1.  📦 Git (configuration Git globale)"
        echo "2.  🔗 Git Remote (configuration remote GitHub)"
        echo "3.  🔗 Symlinks (création des symlinks dotfiles)"
        echo "4.  🐚 Shell (gestion des shells)"
        echo "5.  🎨 Powerlevel10k (configuration prompt avec Git)"
        echo "6.  🔐 SSH (configuration connexion SSH interactive)"
        echo "6a. 🔐 SSH Auto (configuration automatique avec mot de passe .env)"
        echo "7.  🖥️  QEMU Libvirt (permissions libvirt)"
        echo "8.  🌐 QEMU Network (configuration réseau NAT)"
        echo "9.  📦 QEMU Packages (installation paquets QEMU)"
        echo ""
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -l choice
        set choice (string trim "$choice" | string sub -s 1 -l 2)
        
        switch "$choice"
            case "1"
                if test -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                else
                    echo -e "$RED❌ Module Git non disponible$RESET"
                    sleep 2
                end
            case "2"
                if test -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                else
                    echo -e "$RED❌ Module Git Remote non disponible$RESET"
                    sleep 2
                end
            case "3"
                if test -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                else
                    echo -e "$RED❌ Module Symlinks non disponible$RESET"
                    sleep 2
                end
            case "4"
                if test -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh"
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                else
                    echo -e "$RED❌ Module Shell non disponible$RESET"
                    sleep 2
                end
            case "5"
                if test -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                else
                    echo -e "$RED❌ Module Powerlevel10k non disponible$RESET"
                    sleep 2
                end
            case "6"
                if test -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                else
                    echo -e "$RED❌ Module SSH non disponible$RESET"
                    sleep 2
                end
            case "6a"
                if test -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh"
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh"
                else
                    echo -e "$RED❌ Module SSH Auto non disponible$RESET"
                    sleep 2
                end
            case "7"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                else
                    echo -e "$RED❌ Module QEMU Libvirt non disponible$RESET"
                    sleep 2
                end
            case "8"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                else
                    echo -e "$RED❌ Module QEMU Network non disponible$RESET"
                    sleep 2
                end
            case "9"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                else
                    echo -e "$RED❌ Module QEMU Packages non disponible$RESET"
                    sleep 2
                end
            case "0"
                return 0
            case "*"
                echo -e "$REDChoix invalide$RESET"
                sleep 1
        end
        
        # Retourner au menu après action (sauf si choix 0)
        if test "$choice" != "0"
            echo ""
            read -n 1 -P "Appuyez sur une touche pour continuer... " > /dev/null
            echo ""
            configman
        end
    end
    
    # Si un argument est fourni, lancer directement le module
    if test (count $argv) -gt 0
        set -l module_arg (string lower "$argv[1]")
        
        switch "$module_arg"
            case "git"
                if test -f "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/git/git_config.sh"
                end
            case "git-remote" "gitremote"
                if test -f "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                    bash "$CONFIGMAN_MODULES_DIR/git/git_remote.sh"
                end
            case "symlinks" "symlink"
                if test -f "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                    bash "$CONFIGMAN_MODULES_DIR/symlinks/create_symlinks.sh"
                end
            case "shell"
                if test -f "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh"
                    bash "$CONFIGMAN_MODULES_DIR/shell/shell_manager.sh" menu
                end
            case "p10k" "powerlevel10k" "prompt"
                if test -f "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/prompt/p10k_config.sh"
                end
            case "ssh"
                if test -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_config.sh"
                end
            case "ssh-auto" "sshauto"
                if test -f "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh"
                    bash "$CONFIGMAN_MODULES_DIR/ssh/ssh_auto_setup.sh" $argv[2..-1]
                end
            case "qemu-libvirt" "qemulibvirt"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_libvirt.sh"
                end
            case "qemu-network" "qemunetwork"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_network.sh"
                end
            case "qemu-packages" "qemupackages"
                if test -f "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                    bash "$CONFIGMAN_MODULES_DIR/qemu/qemu_packages.sh"
                end
            case "*"
                echo -e "$REDModule inconnu: $argv[1]$RESET"
                echo ""
                echo "Modules disponibles:"
                echo "  - git"
                echo "  - git-remote"
                echo "  - symlinks"
                echo "  - shell"
                echo "  - p10k (Powerlevel10k)"
                echo "  - ssh (configuration SSH interactive)"
                echo "  - ssh-auto (configuration SSH automatique avec .env)"
                echo "  - qemu-libvirt"
                echo "  - qemu-network"
                echo "  - qemu-packages"
                return 1
        end
    else
        # Mode interactif
        while true
            show_main_menu
        end
    end
end

# Créer les alias pour compatibilité (Fish)
function cm
    configman $argv
end

function config
    configman $argv
end

function dotfilesman
    configman $argv
end

function dfm
    configman $argv
end

