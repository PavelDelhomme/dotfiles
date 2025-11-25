#!/bin/zsh

WEEDLYWEB_DIR="/home/pactivisme/Documents/Projets/Perso/CPP/WeedlyWeb"

# DESC: Lance le projet WeedlyWeb en mode développement.
# USAGE: weedlyweb_run
# EXAMPLE: weedlyweb_run
weedlyweb_run() {
    cd "$WEEDLYWEB_DIR" && \
    mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    ./bin/weedlyweb
}

# DESC: Compile le projet WeedlyWeb en mode debug avec les symboles de débogage.
# USAGE: weedlyweb_debug_build
# EXAMPLE: weedlyweb_debug_build
weedlyweb_debug_build() {
    cd "$WEEDLYWEB_DIR" && \
    mkdir -p build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make -j$(nproc)
}

# DESC: Lance le projet WeedlyWeb en mode debug avec un débogueur attaché.
# USAGE: weedlyweb_debug
# EXAMPLE: weedlyweb_debug
weedlyweb_debug() {
    cd "$WEEDLYWEB_DIR/build" && \
    gdb ./bin/weedlyweb
}

# DESC: Nettoie les fichiers de build et les artefacts de compilation du projet WeedlyWeb.
# USAGE: weedlyweb_clean
# EXAMPLE: weedlyweb_clean
weedlyweb_clean() {
    cd "$WEEDLYWEB_DIR"
    local current_dir=$(pwd)
    if [[ $current_dir == $WEEDLYWEB_DIR/build* ]]; then
        cd ..
    fi
    rm -rf build
    echo "Build directory cleaned."
}

# DESC: Nettoie et recompile complètement le projet WeedlyWeb depuis zéro.
# USAGE: weedlyweb_rebuild
# EXAMPLE: weedlyweb_rebuild
weedlyweb_rebuild() {
    weedlyweb_clean && weedlyweb_run
}
