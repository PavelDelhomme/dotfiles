# =============================================================================
# INSTALLMAN - Installation Manager pour Fish
# =============================================================================
# Description: Gestionnaire complet des installations d'outils de développement
# Author: Paul Delhomme
# Version: 2.0
# Converted from ZSH to Fish
# =============================================================================

# Répertoires de base
if not set -q INSTALLMAN_DIR
    set -g INSTALLMAN_DIR "$HOME/dotfiles/fish/functions/installman"
end

if not set -q DOTFILES_DIR
    set -g DOTFILES_DIR "$HOME/dotfiles"
end

# Utiliser les modules ZSH (partagés)
set -g ZSH_INSTALLMAN_DIR "$DOTFILES_DIR/zsh/functions/installman"
set -g INSTALLMAN_MODULES_DIR "$ZSH_INSTALLMAN_DIR/modules"
set -g INSTALLMAN_UTILS_DIR "$ZSH_INSTALLMAN_DIR/utils"

set -g SCRIPTS_DIR "$DOTFILES_DIR/scripts"
set -g INSTALL_DIR "$SCRIPTS_DIR/install/dev"
set -g ENV_FILE "$DOTFILES_DIR/zsh/env.sh"

# Charger les utilitaires (via bash pour compatibilité)
if test -d "$INSTALLMAN_UTILS_DIR"
    for util_file in $INSTALLMAN_UTILS_DIR/*.sh
        if test -f "$util_file"
            bash -c "source '$util_file'" 2>/dev/null || true
        end
    end
end

# Charger les fonctions de vérification (via bash)
if test -f "$INSTALLMAN_UTILS_DIR/check_installed.sh"
    bash -c "source '$INSTALLMAN_UTILS_DIR/check_installed.sh'" 2>/dev/null || true
end

# =============================================================================
# DÉFINITION DES OUTILS DISPONIBLES
# =============================================================================
# Format: "nom:alias1,alias2:emoji:description:check_function:module_file:install_function"
set -g TOOLS \
    "flutter:flut:🎯:Flutter SDK:check_flutter_installed:flutter/install_flutter.sh:install_flutter" \
    "dotnet:dot-net,.net,net:🔷:.NET SDK:check_dotnet_installed:dotnet/install_dotnet.sh:install_dotnet" \
    "emacs:emac:📝:Emacs + Doom Emacs:check_emacs_installed:emacs/install_emacs.sh:install_emacs" \
    "java8:java8,jdk8:☕:Java 8 OpenJDK:check_java8_installed:java/install_java.sh:install_java8" \
    "java11:java11,jdk11:☕:Java 11 OpenJDK:check_java11_installed:java/install_java.sh:install_java11" \
    "java17:java17,java-17,jdk17:☕:Java 17 OpenJDK:check_java17_installed:java/install_java.sh:install_java17" \
    "java21:java21,jdk21:☕:Java 21 OpenJDK:check_java21_installed:java/install_java.sh:install_java21" \
    "java25:java25,jdk25,java,jdk:☕:Java 25 OpenJDK:check_java25_installed:java/install_java.sh:install_java25" \
    "android-studio:androidstudio,android,studio,as:🤖:Android Studio:check_android_studio_installed:android/install_android_studio.sh:install_android_studio" \
    "android-tools:androidtools,adb,sdk,android-sdk:🔧:Outils Android (ADB, SDK):check_android_tools_installed:android/install_android_tools.sh:install_android_tools" \
    "android-licenses:android-license,licenses:📝:Accepter licences Android SDK:check_android_licenses_accepted:android/accept_android_licenses.sh:accept_android_licenses" \
    "docker::🐳:Docker & Docker Compose:check_docker_installed:docker/install_docker.sh:install_docker" \
    "brave:brave-browser:🌐:Brave Browser:check_brave_installed:brave/install_brave.sh:install_brave" \
    "cursor::💻:Cursor IDE:check_cursor_installed:cursor/install_cursor.sh:install_cursor" \
    "qemu:qemu-kvm,kvm:🖥️:QEMU/KVM (Virtualisation):check_qemu_installed:qemu/install_qemu.sh:install_qemu" \
    "ssh-config:ssh,ssh-setup:🔐:Configuration SSH automatique:check_ssh_configured:ssh/install_ssh_config.sh:install_ssh_config"

# DESC: Gestionnaire interactif complet pour installer des outils de développement
# USAGE: installman [tool-name]
# EXAMPLE: installman
# EXAMPLE: installman flutter
# EXAMPLE: installman docker
function installman
    set -l RED (set_color red)
    set -l GREEN (set_color green)
    set -l YELLOW (set_color yellow)
    set -l BLUE (set_color blue)
    set -l CYAN (set_color cyan)
    set -l BOLD (set_color -o)
    set -l RESET (set_color normal)
    
    # Fonction pour afficher le header
    function show_header
        clear
        echo -e "$CYAN$BOLD"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  INSTALLMAN - INSTALLATION MANAGER            ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "$RESET"
    end
    
    # Fonction pour obtenir le statut d'installation
    function get_install_status
        set -l tool_check "$argv[1]"
        set -l status (bash -c "$tool_check 2>/dev/null" | tr -d '\n')
        if test "$status" = "installed"
            echo -e "$GREEN[✓ Installé]$RESET"
        else
            echo -e "$YELLOW[✗ Non installé]$RESET"
        end
    end
    
    # Fonction pour trouver un outil par nom/alias
    function find_tool
        set -l search_term (string lower (string trim "$argv[1]"))
        
        for tool_def in $TOOLS
            # Split par ':'
            set -l tool_parts (string split ":" "$tool_def")
            
            # Vérifier que nous avons assez de parties (7)
            if test (count $tool_parts) -lt 7
                continue
            end
            
            set -l tool_name "$tool_parts[1]"
            set -l tool_aliases_str "$tool_parts[2]"
            
            # Vérifier si le terme correspond au nom principal
            if test "$tool_name" = "$search_term"
                echo "$tool_def"
                return 0
            end
            
            # Vérifier les alias (séparés par des virgules)
            if test -n "$tool_aliases_str"
                set -l aliases (string split "," "$tool_aliases_str")
                for alias in $aliases
                    set alias (string trim "$alias")
                    if test "$alias" = "$search_term"
                        echo "$tool_def"
                        return 0
                    end
                end
            end
        end
        
        return 1
    end
    
    # Fonction pour afficher le menu principal
    function show_main_menu
        show_header
        echo -e "$YELLOW📦 INSTALLATION D'OUTILS ET APPLICATIONS$RESET"
        echo -e "$BLUE══════════════════════════════════════════════════════════════════$RESET\n"
        
        # Organiser par catégories
        echo -e "$BOLD💻 DÉVELOPPEMENT:$RESET"
        set -l index 1
        set -l dev_tools flutter dotnet emacs java8 java11 java17 java21 java25 android-studio android-tools docker
        for tool_name in $dev_tools
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                if test "$tool_parts[1]" = "$tool_name"
                    set -l tool_emoji "$tool_parts[3]"
                    set -l tool_desc "$tool_parts[4]"
                    set -l tool_check "$tool_parts[5]"
                    set -l status (get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    set index (math $index + 1)
                    break
                end
            end
        end
        
        echo ""
        echo -e "$BOLD🌐 APPLICATIONS:$RESET"
        set -l app_tools brave cursor
        for tool_name in $app_tools
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                if test "$tool_parts[1]" = "$tool_name"
                    set -l tool_emoji "$tool_parts[3]"
                    set -l tool_desc "$tool_parts[4]"
                    set -l tool_check "$tool_parts[5]"
                    set -l status (get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    set index (math $index + 1)
                    break
                end
            end
        end
        
        echo ""
        echo -e "$BOLD⚙️  CONFIGURATION ANDROID:$RESET"
        set -l android_config_tools android-licenses
        for tool_name in $android_config_tools
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                if test "$tool_parts[1]" = "$tool_name"
                    set -l tool_emoji "$tool_parts[3]"
                    set -l tool_desc "$tool_parts[4]"
                    set -l tool_check "$tool_parts[5]"
                    set -l status (get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    set index (math $index + 1)
                    break
                end
            end
        end
        
        echo ""
        echo -e "$BOLD🖥️  SYSTÈME & VIRTUALISATION:$RESET"
        set -l sys_tools qemu
        for tool_name in $sys_tools
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                if test "$tool_parts[1]" = "$tool_name"
                    set -l tool_emoji "$tool_parts[3]"
                    set -l tool_desc "$tool_parts[4]"
                    set -l tool_check "$tool_parts[5]"
                    set -l status (get_install_status "$tool_check")
                    printf "  %-3s %s %-30s %s\n" "$index." "$tool_emoji" "$tool_desc" "$status"
                    set index (math $index + 1)
                    break
                end
            end
        end
        
        echo ""
        echo "0.  Quitter"
        echo ""
        echo -e "$CYAN💡 Tapez le nom de l'outil (ex: 'flutter', 'docker', 'brave') puis appuyez sur Entrée$RESET"
        echo -e "$CYAN   Ou tapez un numéro pour sélectionner par position$RESET"
        echo ""
        printf "Choix: "
        read -l choice
        set choice (string lower (string trim "$choice"))
        
        # Fonction pour installer un outil
        function install_tool_from_def
            set -l tool_def "$argv[1]"
            set -l tool_parts (string split ":" "$tool_def")
            set -l tool_name "$tool_parts[1]"
            set -l tool_desc "$tool_parts[4]"
            set -l module_file "$tool_parts[6]"
            set -l install_func "$tool_parts[7]"
            
            set -l full_module_path "$INSTALLMAN_MODULES_DIR/$module_file"
            
            if test -f "$full_module_path"
                bash -c "source '$full_module_path' && $install_func"
            else
                echo -e "$RED❌ Module $tool_desc non disponible: $full_module_path$RESET"
                sleep 2
            end
        end
        
        # Traitement du choix
        if test -z "$choice" || test "$choice" = "0" || test "$choice" = "quit" || test "$choice" = "exit" || test "$choice" = "q"
            return 0
        end
        
        # Vérifier si c'est un numéro
        if string match -qr '^[0-9]+$' "$choice"
            set -l tool_index (math "$choice")
            set -l tools_count (count $TOOLS)
            if test $tool_index -ge 1 && test $tool_index -le $tools_count
                set -l array_index (math $tool_index - 1)
                set -l tool_def $TOOLS[(math $array_index + 1)]
                install_tool_from_def "$tool_def"
            else
                echo -e "$RED❌ Numéro invalide: $choice$RESET"
                sleep 2
                show_main_menu
            end
        else
            # Rechercher par nom/alias
            set -l found_tool (find_tool "$choice")
            if test -n "$found_tool"
                install_tool_from_def "$found_tool"
            else
                echo -e "$RED❌ Outil non trouvé: '$choice'$RESET"
                echo ""
                echo -e "$YELLOWOutils disponibles:$RESET"
                for tool_def in $TOOLS
                    set -l tool_parts (string split ":" "$tool_def")
                    echo "  - $tool_parts[1]"
                end
                echo ""
                sleep 2
                show_main_menu
            end
        end
    end
    
    # Fonction pour installer un outil (utilisée par les arguments en ligne de commande)
    function install_tool
        set -l tool_name "$argv[1]"
        set -l module_file "$argv[2]"
        set -l install_func "$argv[3]"
        
        if test -f "$module_file"
            bash -c "source '$module_file' && $install_func"
        else
            echo -e "$RED❌ Module $tool_name non disponible$RESET"
            return 1
        end
    end
    
    # Si un argument est fourni, lancer directement le module
    if test (count $argv) -gt 0
        set -l tool_arg (string lower (string trim "$argv[1]"))
        
        # Rechercher l'outil
        set -l found_tool (find_tool "$tool_arg")
        if test -n "$found_tool"
            set -l tool_parts (string split ":" "$found_tool")
            set -l tool_desc "$tool_parts[4]"
            set -l module_file "$tool_parts[6]"
            set -l install_func "$tool_parts[7]"
            set -l full_module_path "$INSTALLMAN_MODULES_DIR/$module_file"
            install_tool "$tool_desc" "$full_module_path" "$install_func"
        else if test "$tool_arg" = "list"
            echo -e "$CYAN$BOLDINSTALLMAN - Outils disponibles:$RESET"
            echo ""
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                set -l tool_name "$tool_parts[1]"
                set -l tool_emoji "$tool_parts[3]"
                set -l tool_desc "$tool_parts[4]"
                echo "  $GREEN$tool_name$RESET $tool_emoji - $tool_desc"
            end
            echo ""
            echo -e "$YELLOW Astuce:$RESET installman help pour l'usage complet."
        else if test "$tool_arg" = "help" || test "$tool_arg" = "--help" || test "$tool_arg" = "-h"
            echo -e "$CYAN$BOLDINSTALLMAN - Outils disponibles:$RESET"
            echo ""
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                set -l tool_name "$tool_parts[1]"
                set -l tool_emoji "$tool_parts[3]"
                set -l tool_desc "$tool_parts[4]"
                echo "  $GREEN$tool_name$RESET $tool_emoji - $tool_desc"
            end
            echo ""
            echo -e "$YELLOWUsage:$RESET"
            echo "  installman [tool-name]     - Installer directement un outil"
            echo "  installman                 - Menu interactif"
            echo "  installman list            - Liste des outils (sans menu)"
            echo ""
            echo -e "$CYANExemples:$RESET"
            echo "  installman flutter"
            echo "  installman docker"
            echo "  installman cursor"
        else
            echo -e "$RED❌ Outil inconnu: '$argv[1]'$RESET"
            echo ""
            echo -e "$YELLOWOutils disponibles:$RESET"
            for tool_def in $TOOLS
                set -l tool_parts (string split ":" "$tool_def")
                echo "  - $tool_parts[1]"
            end
            echo ""
            echo "Usage: installman [tool-name]"
            echo "   ou: install-tool [tool-name] (alias)"
            echo "   ou: installman (menu interactif)"
            echo "   ou: installman list (outils installman)"
            return 1
        end
    else
        # Mode interactif
        show_main_menu
    end
end

# Créer l'alias install-tool pour compatibilité
function install-tool
    installman $argv
end

# Alias
function im
    installman $argv
end

