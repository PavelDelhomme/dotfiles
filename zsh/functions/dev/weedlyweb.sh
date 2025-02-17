#!/bin/zsh

WEEDLYWEB_DIR="/home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb"

weedlyweb_run() {
    cd "$WEEDLYWEB_DIR" && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    ./bin/weedlyweb
}

weedlyweb_debug_build() {
    cd "$WEEDLYWEB_DIR" && \
    mkdir -p build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make -j$(nproc)
}

weedlyweb_debug() {
    cd "$WEEDLYWEB_DIR/build" && \
    gdb ./bin/weedlyweb
}

weedlyweb_clean() {
    cd "$WEEDLYWEB_DIR"
    local current_dir=$(pwd)
    if [[ $current_dir == $WEEDLYWEB_DIR/build* ]]; then
        cd ..
    fi
    rm -rf build
    echo "Build directory cleaned."
}

weedlyweb_rebuild() {
    weedlyweb_clean && weedlyweb_run
}
