#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour Make
# =============================================================================

# DESC: Affiche tous les targets disponibles dans un Makefile
# USAGE: make_targets [makefile_path]
make_targets() {
    local makefile="${1:-Makefile}"
    
    if [[ ! -f "$makefile" ]]; then
        echo "❌ Makefile non trouvé: $makefile"
        return 1
    fi
    
    echo "📋 Targets disponibles dans $makefile:"
    echo "─────────────────────────────────────"
    grep -E '^[a-zA-Z_-]+:.*?## .*$$' "$makefile" | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' || \
    grep -E '^[a-zA-Z_-]+:' "$makefile" | awk -F: '{printf "  \033[36m%s\033[0m\n", $$1}' | head -20
}

# DESC: Nettoie les fichiers générés par make
# USAGE: make_clean [makefile_path]
make_clean() {
    local makefile="${1:-Makefile}"
    
    echo "🧹 Clean Make: $makefile"
    
    if [[ -f "$makefile" ]]; then
        make -f "$makefile" clean 2>/dev/null || echo "⚠️  Pas de target 'clean' dans $makefile"
    fi
    
    # Nettoyage générique
    find . -type f \( -name "*.o" -o -name "*.a" -o -name "*.so" -o -name "*~" -o -name ".DS_Store" \) -delete 2>/dev/null
    rm -rf build/ obj/ bin/ dist/ *.dSYM/ 2>/dev/null
    
    echo "✅ Clean terminé"
}

# DESC: Aide Make (si target help existe)
# USAGE: make_help [makefile_path]
make_help() {
    local makefile="${1:-Makefile}"
    
    if [[ ! -f "$makefile" ]]; then
        echo "❌ Makefile non trouvé: $makefile"
        return 1
    fi
    
    echo "📖 Aide Make: $makefile"
    make -f "$makefile" help 2>/dev/null || make_targets "$makefile"
}

# DESC: Build avec make
# USAGE: make_build [target] [makefile_path]
make_build() {
    local target="${1:-all}"
    local makefile="${2:-Makefile}"
    
    echo "🔨 Build Make: $target"
    make -f "$makefile" "$target" || { echo "❌ Build échoué"; return 1; }
    echo "✅ Build réussi: $target"
}

# DESC: Test avec make
# USAGE: make_test [makefile_path]
make_test() {
    local makefile="${1:-Makefile}"
    
    echo "🧪 Test Make: $makefile"
    make -f "$makefile" test 2>/dev/null || { echo "⚠️  Pas de target 'test' dans $makefile"; return 1; }
    echo "✅ Tests terminés"
}

# DESC: Install avec make
# USAGE: make_install [prefix] [makefile_path]
make_install() {
    local prefix="${1:-/usr/local}"
    local makefile="${2:-Makefile}"
    
    echo "📦 Install Make: prefix=$prefix"
    make -f "$makefile" PREFIX="$prefix" install || { echo "❌ Install échoué"; return 1; }
    echo "✅ Install réussi"
}

