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
alias zshrc="source ~/.zshrc"
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
alias cd_weedlyweb="cd /home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb_SimpleBrowser"
alias run_simplebrowser="cmake -DCMAKE_BUILD_TYPE=Release -B build && cmake --build build && ./build/simplebrowser"
alias build_run_simplebrowser='cd /home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb_SimpleBrowser && rm -rf build && mkdir build && cd build && cmake .. && make -j$(nproc) && ./simplebrowser'
alias debug_build_simplebrowser="cmake -DCMAKE_BUILD_TYPE=Debug -B build && cmake --build build && ./build/simplebrowser"
alias debug_simplebrowser="cmake -DCMAKE_BUILD_TYPE=Debug -B build && cmake --build build && gdb -ex "set debuginfod enabled on" -ex run --args ./build/simplebrowser"
alias lscopy="ls | xclip -selection clipboard"
alias sdkmanager="/home/pactivisme/Android/Sdk/cmdline-tools/latest/bin/sdkmanager"
