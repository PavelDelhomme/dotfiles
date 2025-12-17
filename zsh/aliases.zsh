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
alias cd_jobbingtrack="cd /home/pactivisme/Documents/Dev/Perso/JobbingTrackProject/JobbingTrack"
alias cd_flutter_cooking_recipe="cd /home/pactivisme/Documents/Dev/Perso/cookingRecipes/flutter_cooking_recipe"
alias cd_cms_crm_solutions="cd /home/pactivisme/Documents/Dev/Perso/CMS_CRM_Solutions"
alias cd_auto_apply="cd /home/pactivisme/Documents/Dev/Perso/auto_apply/auto_apply/"
alias cd_streammake="cd /home/pactivisme/Documents/Dev/Perso/StreamMake"
alias cd_budget_youyou="cd /home/pactivisme/Documents/Dev/Perso/BudgetYouyou/budget-web-youyou-merdique"
alias cd_vtcbuilder="/home/pactivisme/Documents/Dev/Perso/VTCBuilder"
# DESC: Looking for firle in directory
alias lsgrep="ls | grep $1"
alias cd_weedlyweb="cd /home/pactivisme/Documents/Dev/Perso/weedlyweb/weedlyweb && export LIBVA_DRIVER_NAME=nvidia"

# PortProton helpers
alias portproton='flatpak run ru.linux_gaming.PortProton'
alias pp='flatpak run ru.linux_gaming.PortProton'

# PortProton helper functions
portproton-install-game() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-install-game <installer.exe>"
        return 1
    fi
    flatpak run ru.linux_gaming.PortProton "$1"
}

portproton-run() {
    if [ $# -lt 1 ]; then
        echo "Usage: portproton-run <game.exe>"
        return 1
    fi
    flatpak run ru.linux_gaming.PortProton "$1"
}
