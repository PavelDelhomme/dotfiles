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
alias watch_weedly="watch -n 1 'ps -p $(pgrep WeedlyWeb) -o pid,%cpu,%mem,etime,cmd'"
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
alias cd_weedlyweb="cd /home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb_SimpleBrowser && export LIBVA_DRIVER_NAME=nvidia"
alias run_simplebrowser="weedlyweb_run"
alias debug_build_simplebrowser="weedlyweb_debug_build"
alias debug_simplebrowser="weedlyweb_debug"
alias lscopy="ls | xclip -selection clipboard"
alias sdkmanager="/home/pactivisme/Android/Sdk/cmdline-tools/latest/bin/sdkmanager"
alias update="sudo pacman -Sy --noconfirm"
alias upgrade="sudo pacman -Syu --noconfirm"
alias zshrc="zsh"
alias dc="docker-compose"
alias pacmann="sudo pacman --noconfirm "
alias run_weedlyweb="run_simplebrowser"
alias cmear="clear"
