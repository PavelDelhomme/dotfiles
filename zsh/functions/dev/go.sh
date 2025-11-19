#!/bin/zsh
# =============================================================================
# Fonctions utilitaires pour Go (Golang)
# =============================================================================

# DESC: Build un projet Go
# USAGE: go_build [package_path]
go_build() {
    local package="${1:-.}"
    echo "🔨 Build Go: $package"
    go build -v "$package" || { echo "❌ Build échoué"; return 1; }
    echo "✅ Build réussi"
}

# DESC: Test un projet Go
# USAGE: go_test [package_path] [flags]
go_test() {
    local package="${1:-./...}"
    shift
    echo "🧪 Tests Go: $package"
    go test -v "$@" "$package" || { echo "❌ Tests échoués"; return 1; }
    echo "✅ Tests réussis"
}

# DESC: Run un projet Go
# USAGE: go_run [package_path] [args...]
go_run() {
    local package="${1:-.}"
    shift
    echo "▶️  Run Go: $package"
    go run "$package" "$@"
}

# DESC: Format le code Go
# USAGE: go_fmt [package_path]
go_fmt() {
    local package="${1:-./...}"
    echo "✨ Format Go: $package"
    go fmt "$package" && echo "✅ Format appliqué"
}

# DESC: Vérifie le code Go avec go vet
# USAGE: go_vet [package_path]
go_vet() {
    local package="${1:-./...}"
    echo "🔍 Vet Go: $package"
    go vet "$package" && echo "✅ Pas d'erreurs détectées" || { echo "⚠️  Erreurs détectées"; return 1; }
}

# DESC: Nettoie les fichiers build Go
# USAGE: go_clean
go_clean() {
    echo "🧹 Clean Go"
    go clean -cache -modcache -testcache -i -r 2>/dev/null
    rm -rf bin/ 2>/dev/null
    echo "✅ Clean terminé"
}

# DESC: Installe les dépendances Go
# USAGE: go_mod_download
go_mod_download() {
    echo "📦 Download dépendances Go"
    go mod download && echo "✅ Dépendances téléchargées"
}

# DESC: Tidy le go.mod
# USAGE: go_mod_tidy
go_mod_tidy() {
    echo "🧹 Tidy go.mod"
    go mod tidy && echo "✅ go.mod nettoyé"
}

# DESC: Mettre à jour les dépendances Go
# USAGE: go_mod_update [module]
go_mod_update() {
    local module="${1:-all}"
    echo "⬆️  Update dépendances Go: $module"
    go get -u "$module" && go mod tidy && echo "✅ Dépendances mises à jour"
}

# DESC: Voir les dépendances Go
# USAGE: go_mod_graph
go_mod_graph() {
    echo "📊 Graphique des dépendances Go"
    go mod graph | head -30
}

# DESC: Build avec optimisations pour production
# USAGE: go_build_release [package_path] [output_name]
go_build_release() {
    local package="${1:-.}"
    local output="${2:-app}"
    echo "🚀 Build release Go: $package -> $output"
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o "$output" "$package" || { echo "❌ Build release échoué"; return 1; }
    echo "✅ Build release réussi: $output"
}

# DESC: Benchmarks Go
# USAGE: go_bench [package_path]
go_bench() {
    local package="${1:-./...}"
    echo "⚡ Benchmarks Go: $package"
    go test -bench=. -benchmem "$package"
}

