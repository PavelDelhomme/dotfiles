# ~/zsh/aliases.zsh
alias msfconsole="sudo msfconsole"
alias cls="clear"
alias ports="list_ports"
alias killport="kill_port"
alias networkmanager="network_manager"
alias copytree="copy_tree"
alias tree_clean="tree -I 'venv|__pycache__|staticfiles|objects|hooks|*.pyc|*.pyo|*.log|*.sqlite3' -a -L 5"
alias copyfile="copy_file"
alias cgoban="java -jar /opt/cgoban.jar"
alias make_and_rebuild="rm -rf build && mkdir build && cd build && cmake .. && make"
alias rmr="cd .. && rm -R"
alias rmr_build="cd .. && rm -rf build && mkdir -p build && cd build && cmake .. && make -j20"
alias rebuild_cpp="cd .. && rm -rf build && mkdir build && cd build && cmake .. && make -j$(nproc) && cd .."
alias noita="cd /opt/Noita && ./start.sh"
alias fr="flutter run"
alias fpg="flutter pub get"
alias fpc="flutter clean"
alias fba="flutter build apk"
alias gs="git status"
alias cambalache="flatpak run ar.xjuan.Cambalache"
alias dcub="docker compose up --build"
alias ls="ls -lah --color=auto"
alias l="ls"
alias pacmans="sudo pacman -S --noconfirm"
alias pacmanr="sudo pacman -Rns --noconfirm"
alias run_simplebrowser="weedlyweb_run"
alias debug_build_simplebrowser="weedlyweb_debug_build"
alias debug_simplebrowser="weedlyweb_debug"
alias lscopy="ls | xclip -selection clipboard"
alias sdkmanager="/home/pactivisme/Android/Sdk/cmdline-tools/latest/cmdline-tools/bin/sdkmanager"
# update et upgrade sont maintenant des fonctions intelligentes
# Voir: zsh/functions/misc/system/update_system.sh
# Elles détectent automatiquement la distribution et utilisent le bon gestionnaire
# (pacman pour Arch, apt pour Debian/Ubuntu, dnf pour Fedora, etc.)
alias zshrc="zsh"
alias dc="docker-compose"
alias pacmann="sudo pacman --noconfirm "
alias cmear="clear"
alias gf="git fetch"
alias watch_weedly="watch -n 1 'ps -p  -o pid,%cpu,%mem,etime,cmd'"
alias run_weedlyweb="weedlyweb_run"
alias debug_build_weedlyweb="weedlyweb_debug_build"
alias debug_weedlyweb="weedlyweb_debug"
alias cd_promanage="cd /home/pactivisme/Documents/Projets/Perso/Promanage/"
alias logs_cyna_backend="docker logs cyna_backend -f"
alias cyna_restart="docker compose down && docker compose up --build"
alias yays="yay -S"
alias run_cyna="cd ~/Documents/Dev/Travail/SupDeVinci/CYNA/cyna_backend/cyna_backend && docker compose up -d 2342f041cbc6 sleep 3 && docker compose logs -f 2342f041cbc6"
alias cd_cyna="cd /home/pactivisme/Documents/Dev/Travail/SupDeVinci/CYNA"
alias cd_cyna_frontend="cd /home/pactivisme/Documents/Dev/Travail/SupDeVinci/CYNA/cyna_front"
alias cd_cyna_backend="cd /home/pactivisme/Documents/Dev/Travail/SupDeVinci/CYNA/cyna_backend"
alias run_jobbingtrack="docker builder prune -af && docker system prune -af --volumes && docker compose build --no-cache && docker compose up"
alias makec="make -C"
alias srn="sudo reboot now"
alias cd_cloudity="cd /home/pactivisme/Documents/Dev/Perso/Cloudity/Cloudity"
alias ipc="ip -c add"
alias gst="git status"
alias git_account="ssh -T git@github.com"
alias gpo="git push origin"
alias playwright_test="npx playwright test"
alias playwright_test_web_interface="npx playwright test --ui-port=4020"
alias gca="git commit -a -m"

# Alias ghs pour ghostscript (la commande système gs)
# L'alias gs="git status" ci-dessus a la priorité sur la commande système
alias ghs="command gs"
alias cd_flutter_cooking_recipe="cd /home/pactivisme/Documents/Dev/Perso/cookingRecipes/flutter_cooking_recipe"
alias cd_cms_crm_solutions="cd /home/pactivisme/Documents/Dev/Perso/CMS_CRM_Solutions"
alias cd_auto_apply="cd /home/pactivisme/Documents/Dev/Perso/auto_apply/auto_apply/"
alias cd_streammake="cd /home/pactivisme/Documents/Dev/Perso/StreamMake"
alias cd_vtcbuilder="/home/pactivisme/Documents/Dev/Perso/VTCBuilder"
# DESC: Looking for firle in directory
alias lsgrep="ls | grep $1"
alias cd_weedlyweb="cd /home/pactivisme/Documents/Dev/Perso/weedlyweb/weedlyweb && export LIBVA_DRIVER_NAME=nvidia"

# PortProton (version native)
alias portproton='bash $HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh'
alias pp='bash $HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh'

# PortProton helper functions (version native)
portproton-install-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-install-game <installer.exe>"
        return 1
    fi
    bash "$HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh" "$1"
}

portproton-run() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-run <game.exe>"
        return 1
    fi
    bash "$HOME/.local/share/PortProton/data_from_portwine/scripts/start.sh" --run "$1"
}

portproton-uninstall-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-uninstall-game <nom_du_jeu>"
        echo ""
        echo "Jeux installés dans PortProton:"
        if [ -d "$HOME/Games/PortProton/games" ]; then
            ls -1 "$HOME/Games/PortProton/games" 2>/dev/null | sed 's/^/  - /' || echo "  (aucun jeu trouvé)"
        else
            echo "  (dossier games non trouvé)"
        fi
        return 1
    fi
    
    local game_name="$1"
    local game_dir="$HOME/Games/PortProton/games/$game_name"
    local prefix_dir="$HOME/Games/PortProton/prefix/$game_name"
    
    echo "🔍 Recherche du jeu: $game_name"
    
    # Vérifier si le jeu existe
    if [ ! -d "$game_dir" ] && [ ! -d "$prefix_dir" ]; then
        echo "❌ Jeu '$game_name' non trouvé dans PortProton"
        echo ""
        echo "Jeux disponibles:"
        if [ -d "$HOME/Games/PortProton/games" ]; then
            ls -1 "$HOME/Games/PortProton/games" 2>/dev/null | sed 's/^/  - /' || echo "  (aucun jeu)"
        fi
        return 1
    fi
    
    # Confirmation
    echo "⚠️  Vous allez supprimer:"
    [ -d "$game_dir" ] && echo "  - Dossier du jeu: $game_dir"
    [ -d "$prefix_dir" ] && echo "  - Préfixe Wine: $prefix_dir"
    echo ""
    printf "Continuer? (o/N): "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[oO]$ ]]; then
        echo "❌ Désinstallation annulée"
        return 1
    fi
    
    # Supprimer le dossier du jeu
    if [ -d "$game_dir" ]; then
        echo "🗑️  Suppression du dossier du jeu..."
        rm -rf "$game_dir" && echo "✓ Dossier du jeu supprimé" || echo "⚠️  Erreur lors de la suppression du dossier du jeu"
    fi
    
    # Supprimer le préfixe Wine
    if [ -d "$prefix_dir" ]; then
        echo "🗑️  Suppression du préfixe Wine..."
        rm -rf "$prefix_dir" && echo "✓ Préfixe Wine supprimé" || echo "⚠️  Erreur lors de la suppression du préfixe"
    fi
    
    echo "✅ Jeu '$game_name' désinstallé avec succès"
}

# Fonction pour désinstaller un jeu installé depuis un fichier .run
uninstall-run() {
    if [ $# -lt 1 ]; then
        echo "Usage: uninstall-run <nom_du_jeu> [chemin_installation]"
        echo ""
        echo "Exemples:"
        echo "  uninstall-run ultrakill"
        echo "  uninstall-run ultrakill /opt/ULTRAKILL"
        echo ""
        echo "Cette fonction cherche le jeu dans les emplacements courants:"
        echo "  - /opt/<nom_jeu>"
        echo "  - ~/Games/<nom_jeu>"
        echo "  - ~/.local/share/<nom_jeu>"
        return 1
    fi
    
    local game_name="$1"
    local install_path="$2"
    
    # Si le chemin est fourni, l'utiliser directement
    if [ -n "$install_path" ]; then
        if [ ! -d "$install_path" ]; then
            echo "❌ Dossier non trouvé: $install_path"
            return 1
        fi
        
        echo "⚠️  Vous allez supprimer: $install_path"
        printf "Continuer? (o/N): "
        read -r confirm
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            echo "❌ Désinstallation annulée"
            return 1
        fi
        
        # Vérifier s'il y a un script uninstall.sh dans le dossier
        if [ -f "$install_path/uninstall.sh" ] && [ -x "$install_path/uninstall.sh" ]; then
            echo "📜 Script de désinstallation trouvé: $install_path/uninstall.sh"
            printf "Utiliser le script de désinstallation? (O/n): "
            read -r use_script
            if [[ ! "$use_script" =~ ^[nN]$ ]]; then
                echo "🔄 Exécution du script de désinstallation..."
                cd "$install_path" && bash "./uninstall.sh" && echo "✅ Jeu désinstallé avec succès (via script)" || {
                    echo "⚠️  Le script a échoué, suppression manuelle..."
                    sudo rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                        echo "⚠️  Erreur lors de la suppression, tentative sans sudo..."
                        rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                            echo "❌ Impossible de supprimer le dossier"
                            return 1
                        }
                    }
                }
                return 0
            fi
        fi
        
        echo "🗑️  Suppression de $install_path..."
        sudo rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
            echo "⚠️  Erreur lors de la suppression, tentative sans sudo..."
            rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                echo "❌ Impossible de supprimer le dossier"
                return 1
            }
        }
        return 0
    fi
    
    # Chercher le jeu dans les emplacements courants
    echo "🔍 Recherche du jeu: $game_name"
    
    # Convertir en majuscules et minuscules (syntaxe zsh)
    local game_name_upper=$(echo "$game_name" | tr '[:lower:]' '[:upper:]')
    local game_name_lower=$(echo "$game_name" | tr '[:upper:]' '[:lower:]')
    
    typeset -a search_paths=(
        "$HOME/$game_name"  # Home directory (ex: ~/ULTRAKILL)
        "$HOME/$game_name_upper"  # Home directory majuscules
        "$HOME/$game_name_lower"  # Home directory minuscules
        "/opt/$game_name"
        "/opt/$game_name_upper"  # Majuscules
        "/opt/$game_name_lower"  # Minuscules
        "$HOME/Games/$game_name"
        "$HOME/Games/$game_name_upper"
        "$HOME/Games/$game_name_lower"
        "$HOME/.local/share/$game_name"
        "$HOME/.local/share/$game_name_upper"
        "$HOME/.local/share/$game_name_lower"
    )
    
    typeset -a found_paths=()
    
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            found_paths+=("$path")
        fi
    done
    
    # Si aucun chemin trouvé, chercher avec find
    if [ ${#found_paths[@]} -eq 0 ]; then
        echo "🔍 Recherche approfondie..."
        local found=$(find "$HOME" /opt "$HOME/Games" "$HOME/.local/share" -maxdepth 2 -type d -iname "*$game_name*" 2>/dev/null | head -5)
        if [ -n "$found" ]; then
            while IFS= read -r line; do
                found_paths+=("$line")
            done <<< "$found"
        fi
    fi
    
    # Afficher les résultats
    if [ ${#found_paths[@]} -eq 0 ]; then
        echo "❌ Jeu '$game_name' non trouvé"
        echo ""
        echo "Emplacements vérifiés:"
        for path in "${search_paths[@]}"; do
            echo "  - $path"
        done
        echo ""
        echo "💡 Vous pouvez spécifier le chemin manuellement:"
        echo "   uninstall-run $game_name /chemin/vers/le/jeu"
        return 1
    elif [ ${#found_paths[@]} -eq 1 ]; then
        # Un seul résultat trouvé
        install_path="${found_paths[0]}"
        echo "✓ Jeu trouvé: $install_path"
        echo ""
        echo "⚠️  Vous allez supprimer: $install_path"
        printf "Continuer? (o/N): "
        read -r confirm
        
        if [[ ! "$confirm" =~ ^[oO]$ ]]; then
            echo "❌ Désinstallation annulée"
            return 1
        fi
        
        echo "🗑️  Suppression de $install_path..."
        sudo rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
            echo "⚠️  Erreur lors de la suppression, tentative sans sudo..."
            rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                echo "❌ Impossible de supprimer le dossier"
                return 1
            }
        }
    else
        # Plusieurs résultats trouvés
        echo "⚠️  Plusieurs emplacements trouvés:"
        for i in "${!found_paths[@]}"; do
            echo "  [$((i+1))] ${found_paths[$i]}"
        done
        echo ""
        printf "Quel emplacement voulez-vous supprimer? (1-${#found_paths[@]}, ou 'a' pour tous, 'q' pour annuler): "
        read -r choice
        
        if [[ "$choice" =~ ^[qQ]$ ]]; then
            echo "❌ Désinstallation annulée"
            return 1
        elif [[ "$choice" =~ ^[aA]$ ]]; then
            echo "⚠️  Vous allez supprimer TOUS les emplacements trouvés"
            printf "Continuer? (o/N): "
            read -r confirm
            
            if [[ ! "$confirm" =~ ^[oO]$ ]]; then
                echo "❌ Désinstallation annulée"
                return 1
            fi
            
            for path in "${found_paths[@]}"; do
                # Vérifier s'il y a un script uninstall.sh
                if [ -f "$path/uninstall.sh" ] && [ -x "$path/uninstall.sh" ]; then
                    echo "📜 Script de désinstallation trouvé pour $path"
                    cd "$path" && bash "./uninstall.sh" && echo "✓ $path supprimé (via script)" || {
                        echo "🗑️  Suppression manuelle de $path..."
                        sudo rm -rf "$path" && echo "✓ $path supprimé" || {
                            rm -rf "$path" && echo "✓ $path supprimé" || echo "⚠️  Erreur: $path"
                        }
                    }
                else
                    echo "🗑️  Suppression de $path..."
                    sudo rm -rf "$path" && echo "✓ $path supprimé" || {
                        rm -rf "$path" && echo "✓ $path supprimé" || echo "⚠️  Erreur: $path"
                    }
                fi
            done
            echo "✅ Tous les emplacements supprimés"
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_paths[@]} ]; then
            install_path="${found_paths[$((choice-1))]}"
            echo "⚠️  Vous allez supprimer: $install_path"
            printf "Continuer? (o/N): "
            read -r confirm
            
            if [[ ! "$confirm" =~ ^[oO]$ ]]; then
                echo "❌ Désinstallation annulée"
                return 1
            fi
            
            # Vérifier s'il y a un script uninstall.sh dans le dossier
            if [ -f "$install_path/uninstall.sh" ] && [ -x "$install_path/uninstall.sh" ]; then
                echo "📜 Script de désinstallation trouvé: $install_path/uninstall.sh"
                printf "Utiliser le script de désinstallation? (O/n): "
                read -r use_script
                if [[ ! "$use_script" =~ ^[nN]$ ]]; then
                    echo "🔄 Exécution du script de désinstallation..."
                    cd "$install_path" && bash "./uninstall.sh" && echo "✅ Jeu désinstallé avec succès (via script)" || {
                        echo "⚠️  Le script a échoué, suppression manuelle..."
                        sudo rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                            echo "⚠️  Erreur lors de la suppression, tentative sans sudo..."
                            rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                                echo "❌ Impossible de supprimer le dossier"
                                return 1
                            }
                        }
                    }
                    return 0
                fi
            fi
            
            echo "🗑️  Suppression de $install_path..."
            sudo rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                echo "⚠️  Erreur lors de la suppression, tentative sans sudo..."
                rm -rf "$install_path" && echo "✅ Jeu désinstallé avec succès" || {
                    echo "❌ Impossible de supprimer le dossier"
                    return 1
                }
            }
        else
            echo "❌ Choix invalide"
            return 1
        fi
    fi
}
alias cd_resa_youyou="cd /home/pactivisme/Documents/Dev/Perso/resa_youyou"
alias cd_dotfiles="cd /home/pactivisme/dotfiles"
alias cd_jobbingtrack="cd /home/pactivisme/Documents/Dev/Perso/JobbingTrack"
alias start_thm_machine="sudo openvpn /home/pactivisme/Téléchargements/eu-west-1-Pachavel-regular.ovpn"
alias cd_budget_youyou="cd /home/pactivisme/Documents/Dev/Perso/budget-web-youyou"
alias cd_taskflow="cd /home/pactivisme/Documents/Dev/Perso/taskflow/taskflow"
