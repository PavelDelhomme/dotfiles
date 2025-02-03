#!/bin/zsh

WEEDLYWEB_DIR="/home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb_SimpleBrowser"

weedlyweb_run() {
    cd "$WEEDLYWEB_DIR" && \
    rm -rf build && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    ./simplebrowser
}

weedlyweb_debug_build() {
    cd "$WEEDLYWEB_DIR" && \
    rm -rf build && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make -j$(nproc) && \
    ./simplebrowser
}

weedlyweb_debug() {
    cd "$WEEDLYWEB_DIR" && \
    rm -rf build && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make -j$(nproc) && \
    gdb -ex "set debuginfod enabled on" -ex run --args ./simplebrowser
}

