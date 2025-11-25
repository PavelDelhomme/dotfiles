#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour C/C++
# =============================================================================

# DESC: Compile un fichier C simple
# USAGE: c_compile <file.c> [output_name]
# EXAMPLE: c_compile ~/example.txt
c_compile() {
    local file="$1"
    local output="${2:-${file%.c}}"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    echo "🔨 Compilation C: $file -> $output"
    gcc -Wall -Wextra -std=c11 "$file" -o "$output" || { echo "❌ Compilation échouée"; return 1; }
    echo "✅ Compilation réussie: $output"
}

# DESC: Compile un fichier C++ simple
# USAGE: cpp_compile <file.cpp> [output_name]
# EXAMPLE: cpp_compile ~/example.txt
cpp_compile() {
    local file="$1"
    local output="${2:-${file%.cpp}}"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    echo "🔨 Compilation C++: $file -> $output"
    g++ -Wall -Wextra -std=c++17 "$file" -o "$output" || { echo "❌ Compilation échouée"; return 1; }
    echo "✅ Compilation réussie: $output"
}

# DESC: Compile C/C++ en mode debug
# USAGE: c_debug_compile <file.c/cpp> [output_name]
# EXAMPLE: c_debug_compile ~/example.txt
c_debug_compile() {
    local file="$1"
    local output="${2:-${file%.*}}"
    local ext="${file##*.}"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    echo "🐛 Compilation debug: $file -> $output"
    if [[ "$ext" == "cpp" || "$ext" == "cc" || "$ext" == "cxx" ]]; then
        g++ -Wall -Wextra -g -std=c++17 "$file" -o "$output" || { echo "❌ Compilation échouée"; return 1; }
    else
        gcc -Wall -Wextra -g -std=c11 "$file" -o "$output" || { echo "❌ Compilation échouée"; return 1; }
    fi
    echo "✅ Compilation debug réussie: $output"
}

# DESC: Lance gdb sur un exécutable
# USAGE: c_debug <executable>
# EXAMPLE: c_debug
c_debug() {
    local exe="$1"
    
    if [[ ! -f "$exe" ]]; then
        echo "❌ Exécutable non trouvé: $exe"
        return 1
    fi
    
    echo "🐛 Démarrage GDB: $exe"
    gdb "$exe"
}

# DESC: Compile et exécute un fichier C/C++
# USAGE: c_run <file.c/cpp>
# EXAMPLE: c_run ~/example.txt
c_run() {
    local file="$1"
    local output="${file%.*}"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    # Compiler
    if [[ "$file" == *.cpp ]] || [[ "$file" == *.cc ]] || [[ "$file" == *.cxx ]]; then
        cpp_compile "$file" "$output" || return 1
    else
        c_compile "$file" "$output" || return 1
    fi
    
    # Exécuter
    echo "▶️  Exécution: $output"
    ./"$output"
}

# DESC: Nettoie les fichiers compilés
# USAGE: c_clean [directory]
# EXAMPLE: c_clean
c_clean() {
    local dir="${1:-.}"
    echo "🧹 Clean C/C++: $dir"
    
    find "$dir" -type f \( -name "*.o" -o -name "*.a" -o -name "*.so" -o -name "*.out" -o -name "a.out" \) -delete 2>/dev/null
    find "$dir" -type d -name "build" -exec rm -rf {} + 2>/dev/null
    find "$dir" -type d -name "cmake-build-*" -exec rm -rf {} + 2>/dev/null
    
    echo "✅ Clean terminé"
}

# DESC: Vérifie le code avec cppcheck (si installé)
# USAGE: c_check <file.c/cpp>
# EXAMPLE: c_check ~/example.txt
c_check() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "❌ Fichier non trouvé: $file"
        return 1
    fi
    
    if ! command -v cppcheck &> /dev/null; then
        echo "⚠️  cppcheck non installé (optionnel)"
        return 1
    fi
    
    echo "🔍 Vérification C/C++: $file"
    cppcheck --enable=all --std=c++17 "$file" 2>/dev/null || cppcheck --enable=all --std=c11 "$file"
}

