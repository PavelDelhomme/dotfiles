#!/bin/bash
# ~/dotfiles/install_go.sh - Installation de Go (Golang)

set -e

GO_VERSION="1.23.3"  # Dernière version stable au 17 nov 2025
GO_INSTALL_DIR="/usr/local"
GO_ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "🚀 Installation de Go ${GO_VERSION}..."

# Vérifier si Go est déjà installé
if command -v go &> /dev/null; then
    CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    echo "ℹ️  Go ${CURRENT_VERSION} est déjà installé."
    read -p "Voulez-vous réinstaller/mettre à jour vers ${GO_VERSION}? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "❌ Installation annulée."
        exit 0
    fi
    echo "🗑️  Suppression de l'ancienne version..."
    sudo rm -rf /usr/local/go
fi

# Télécharger Go
echo "📥 Téléchargement de Go ${GO_VERSION}..."
cd /tmp
wget -q --show-progress "$GO_URL"

# Extraire et installer
echo "📦 Installation de Go..."
sudo tar -C "$GO_INSTALL_DIR" -xzf "$GO_ARCHIVE"

# Nettoyer
rm "$GO_ARCHIVE"

# Ajouter Go au PATH via pathman (si disponible)
if type add_to_path &> /dev/null; then
    add_to_path "/usr/local/go/bin"
    add_to_path "$HOME/go/bin"
else
    # Fallback manuel
    echo "⚠️  pathman non disponible, ajout manuel au PATH..."
    if ! grep -q "/usr/local/go/bin" "$HOME/dotfiles/zsh/env.sh"; then
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$HOME/dotfiles/zsh/env.sh"
    fi
fi

# Recharger le shell
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Vérifier l'installation
if command -v go &> /dev/null; then
    echo "✅ Go installé avec succès!"
    go version
    echo ""
    echo "📁 GOPATH: $HOME/go"
    echo "📁 GOROOT: /usr/local/go"
else
    echo "❌ Erreur lors de l'installation de Go"
    exit 1
fi

echo ""
echo "💡 Commandes utiles:"
echo "  go version        - Afficher la version"
echo "  go mod init       - Initialiser un module"
echo "  go run main.go    - Exécuter un fichier"
echo "  go build          - Compiler le projet"
