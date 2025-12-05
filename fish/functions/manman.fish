# =============================================================================
# MANMAN - Manager of Managers pour Fish
# =============================================================================
# Description: Gestionnaire centralisé pour tous les gestionnaires (*man)
# Author: Paul Delhomme
# Version: 1.0
# Converted from ZSH to Fish
# =============================================================================

# DESC: Gestionnaire centralisé pour accéder à tous les gestionnaires interactifs (*man). Permet de lancer rapidement pathman, netman, aliaman, miscman, searchman et cyberman depuis un menu unique.
# USAGE: manman
# EXAMPLE: manman
function manman
    set -l RED (set_color red)
    set -l GREEN (set_color green)
    set -l YELLOW (set_color yellow)
    set -l BLUE (set_color blue)
    set -l MAGENTA (set_color magenta)
    set -l CYAN (set_color cyan)
    set -l BOLD (set_color -o)
    set -l RESET (set_color normal)
    
    if not set -q DOTFILES_DIR
        set -g DOTFILES_DIR "$HOME/dotfiles"
    end
    
    set -l DOTFILES_FUNCTIONS_DIR "$DOTFILES_DIR/zsh/functions"
    
    # Détecter tous les gestionnaires disponibles
    set -l managers
    
    if test -f "$DOTFILES_FUNCTIONS_DIR/pathman.zsh"
        set -a managers "pathman:📁 Gestionnaire PATH|pathman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/netman.zsh"
        set -a managers "netman:🌐 Gestionnaire réseau|netman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/aliaman.zsh"
        set -a managers "aliaman:📝 Gestionnaire alias|aliaman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/miscman.zsh"
        set -a managers "miscman:🔧 Gestionnaire divers|miscman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/searchman.zsh"
        set -a managers "searchman:🔍 Gestionnaire recherche|searchman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/cyberman.zsh"
        set -a managers "cyberman:🛡️ Gestionnaire cybersécurité|cyberman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/devman.zsh"
        set -a managers "devman:💻 Gestionnaire développement|devman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/gitman.zsh"
        set -a managers "gitman:📦 Gestionnaire Git|gitman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/helpman.zsh"
        set -a managers "helpman:📚 Gestionnaire aide/documentation|helpman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/configman.zsh"
        set -a managers "configman:⚙️ Gestionnaire configuration|configman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/installman.zsh"
        set -a managers "installman:📦 Gestionnaire installation|installman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/moduleman.zsh"
        set -a managers "moduleman:⚙️ Gestionnaire modules|moduleman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/fileman.zsh"
        set -a managers "fileman:📁 Gestionnaire fichiers|fileman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/virtman.zsh"
        set -a managers "virtman:🖥️ Gestionnaire virtualisation|virtman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/sshman.zsh"
        set -a managers "sshman:🔐 Gestionnaire SSH|sshman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/testzshman.zsh"
        set -a managers "testzshman:🧪 Gestionnaire tests ZSH/dotfiles|testzshman"
    end
    if test -f "$DOTFILES_FUNCTIONS_DIR/testman.zsh"
        set -a managers "testman:🧪 Gestionnaire tests applications|testman"
    end

    clear
    echo -e "$CYAN$BOLD"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  MANMAN - Manager of Managers                   ║"
    echo "║           Gestionnaire centralisé des gestionnaires            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "$RESET"
    echo
    
    echo -e "$YELLOWGestionnaires disponibles:$RESET"
    echo -e "$BLUE══════════════════════════════════════════════════════════════════$RESET"
    echo
    
    set -l index 1
    for manager_info in $managers
        set -l parts (string split "|" "$manager_info")
        set -l info "$parts[1]"
        set -l command "$parts[2]"
        set -l info_parts (string split ":" "$info")
        set -l name "$info_parts[1]"
        set -l description "$info_parts[2]"
        
        printf "  $BOLD%d$RESET  %-40s $CYAN%s$RESET\n" "$index" "$description" "$command"
        set index (math $index + 1)
    end
    
    echo
    echo -e "$BLUE══════════════════════════════════════════════════════════════════$RESET"
    echo "  0) Retour"
    echo
    printf "$YELLOWChoisir un gestionnaire [1-%d]: $RESET" (count $managers)
    read -l choice
    echo
    
    if test "$choice" = "0" || test -z "$choice"
        return 0
    end
    
    set -l choice_num (math "$choice")
    if test $choice_num -ge 1 && test $choice_num -le (count $managers)
        set -l array_index (math $choice_num - 1)
        set -l selected_manager $managers[(math $array_index + 1)]
        set -l parts (string split "|" "$selected_manager")
        set -l info "$parts[1]"
        set -l command "$parts[2]"
        set -l info_parts (string split ":" "$info")
        set -l name "$info_parts[1]"
        set -l description "$info_parts[2]"
        
        echo -e "$GREENLancement de $description...$RESET"
        echo
        sleep 1
        
        # S'assurer que le gestionnaire est chargé
        set -l manager_file "$DOTFILES_FUNCTIONS_DIR/${name}.zsh"
        if test -f "$manager_file"
            # Source le fichier via bash pour compatibilité
            bash -c "source '$manager_file'" 2>/dev/null || true
        end
        
        # Appeler directement la fonction du gestionnaire
        if command -v "$command" >/dev/null 2>&1
            "$command"
        else
            echo -e "$RED❌ Erreur: Impossible de lancer $name$RESET"
            echo "💡 Assurez-vous que le gestionnaire est correctement chargé"
            sleep 2
        end
        
        # Retourner au menu manman après avoir quitté le gestionnaire
        echo
        read -n 1 -P "Appuyez sur une touche pour retourner au menu... " > /dev/null
        echo
        manman
    else
        echo -e "$REDChoix invalide$RESET"
        sleep 2
        manman
    end
end

# Alias (Fish)
function mmg
    manman $argv
end

function managers
    manman $argv
end

