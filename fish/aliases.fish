# Système et utilitaires
# DESC: Lance msfconsole avec les privilèges sudo
alias msfconsole 'sudo msfconsole'

# DESC: Efface l'écran du terminal
alias cls 'clear'

# DESC: Liste les ports ouverts
alias ports 'list_ports'

# DESC: Tue un processus sur un port spécifique
alias killport 'kill_port'

# DESC: Lance le gestionnaire de réseau
alias networkmanager 'network_manager'

# DESC: Copie récursivement une arborescence de répertoires
alias copytree 'copy_tree'

# DESC: Affiche l'arborescence des fichiers en excluant certains dossiers et type de fichiers
alias tree_clean "tree -I 'venv|__pycache__|staticfiles|objects|hooks|*.pyc|*.pyo|*.log|*.sqlite3' -a -L 5"

# DESC: Copie le contenu d'un fichier
alias copyfile 'copy_file'

# DESC: 
alias clear_file_content 'echo > '' '

# DESC: Recompile un projet CMake
alias make_and_rebuild 'rm -rf build && mkdir build && cd build && cmake .. && make'

# DESC: Remonte d'un niveau et supprime le répertoire
alias rmr 'cd .. && rm -R'

# DESC: Recompile un projet CMake avec 20 threads
alias rmr_build 'cd .. && rm -rf build && mkdir -p build && cd build && cmake .. && make -j20'

# DESC: Recompile un projet C++ avec le nombre de processeurs disponibles
alias rebuild_cpp 'cd .. && rm -rf build && mkdir build && cd build && cmake .. && make -j(nproc) && cd ..'

# Jeux aliases 
# DESC: Lance le jeu de Go CGoban
alias cgoban 'java -jar /opt/cgoban.jar'

# DESC: Lance le jeu Noita
alias noita 'cd /opt/Noita && ./start.sh'

# Flutter aliases
# DESC: Lance l'application Flutter
alias fr 'flutter run'

# DESC: Récupère les dépendances Flutter
alias fpg 'flutter pub get'

# DESC: Nettoie le projet Flutter
alias fpc 'flutter clean'

# DESC: Construit l'API Flutter
alias fba 'flutter build apk'

# Git aliases
# DESC: Affiche le status Git
alias gs 'git status'

# DESC: Récupère les dernières modifications du dépôt distant
alias gf 'git fetch'

# DESC: Lance Calambache via Flatpak 
alias cambalache 'flatpak run ar.xjuan.Cambalache'

# Docker aliases
# DESC: Lance Docker Compose avec reconstruction
alias dcub 'docker compose up --build'

# DESC: Alias pour Docker Compose
alias dc 'docker-compose'

# DESC: 
alias restart_docker 'sudo systemctl restart docker'

# DESC: 
alias status_docker 'sudo systemctl status docker'

# Pacman aliases
# DESC: Installation de paquets sans confirmation
alias pacmans 'sudo pacman -S --noconfirm'

# DESC: Suppression de paquets sans confirmation
alias pacmanr 'sudo pacman -Rns --noconfirm'

# DESC: Lance la mise à jour des paquets
alias update 'sudo pacman -Sy --noconfirm'

# DESC: Lance la mise à jour du système
alias upgrade 'sudo pacman -Syu --noconfirm'

# DESC: Commande pacman sans confirmation
alias pacmann 'sudo pacman --noconfirm'

# Listing directory aliases
# DESC: Liste les fichiers avec des détails et des couleurs
alias ls 'ls -lah --color=auto'

# DESC: Alias court pour ls
alias l 'ls'

# DESC: Copie la sortie de ls dans le presse-papiers
alias lscopy 'ls | xclip -selection clipboard'

# Projet WeedlyWeb
# DESC: Change de répertoire vers WeedlyWeb et configure le pilote NVIDIA
alias cd_weedlyweb 'cd /home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb_SimpleBrowser && export LIBVA_DRIVER_NAME=nvidia'

# DESC: Lance WeedlyWeb
alias run_simplebrowser 'weedlyweb_run'

# DESC: Compile WeedlyWeb en mode debug
alias debug_build_simplebrowser 'weedlyweb_debug_build'

# DESC: Lance WeedlyWeb en mode debug
alias debug_simplebrowser 'weedlyweb_debug'

# DESC: Surveille les processus WeedlyWeb
alias watch_weedly "watch -n 1 'ps -p  -o pid,%cpu,%mem,etime,cmd'"

# DESC: Lance WeedlyWeb
alias run_weedlyweb 'weedlyweb_run'

# DESC: Compile WeedlyWeb en mode debug
alias debug_build_weedlyweb 'weedlyweb_debug_build'

# DESC: Lance WeedlyWeb en mode debug
alias debug_weedlyweb 'weedlyweb_debug'

# MISC
# DESC: Lance Zsh
alias zshrc 'zsh'

# DESC: Nettoie la sortie du terminal
alias cmear 'clear'


# Gestion d'alias
# DESC: Alias pour supprimer un alias 
alias remove_alias 'delete_alias'

# Gestion des dotfiles
# DESC: Change le répertoire vers les dotfiles
alias cd_dotfiles 'cd ~/dotfiles'

# DESC: Edite le fichier d'environement Fish
alias vim_env 'vim ~/dotfiles/fish/env.fish'

# Projet Promanage
# DESC: Change le répertoire vers Promanage
alias cd_promanage 'cd /home/pactivisme/Documents/Dev/Projets/Perso/promanage/Promanage'

# DESC: Afficher les logs du backend Promanage 
alias docker-logs-promanage 'docker-compose logs -f promanage-backend'

# DESC: Lance le backend Django Promanage

# DESC: Affiche les logs du backend Django Promanage
alias logs_promanage_backend 'sh /home/pactivisme/Documents/Dev/Projets/Perso/promanage/Promanage/promanage-backend/scripts/logs_backend.sh'

# DESC: Arrête le backend Django Promanage et supprime les volumes
alias stop_promanage_backend 'docker-compose down -v'

alias stop_promanage_backend_and_rebuild 'docker-compose down && docker-compose build --no-cache && docker-compose up -d'
alias launch_pro_backend 'docker-compose down && docker-compose build --no-cache && docker-compose up -d'
alias cd_jobbingtrack 'cd /home/pactivisme/Documents/Dev/Projets/Perso/JobbingTrack'
alias sunzip 'sudo unzip'
alias yays 'yay -S --noconfirm'
alias start_promanage_backend 'docker-compose down && docker-compose build --no-cache && docker-compose up -d'
