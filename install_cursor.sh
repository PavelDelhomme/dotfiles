#!/bin/bash
# ~/dotfiles/install_cursor.sh - Installation/Mise à jour de Cursor IDE

set -e

CURSOR_DIR="$HOME/.cursor"
CURSOR_BIN="/usr/local/bin/cursor"
CURSOR_APPIMAGE="$HOME/.local/share/applications/cursor.AppImage"

echo "🚀 Installation/Mise à jour de Cursor IDE..."

# Vérifier si Cursor est déjà installé
if command -v cursor &> /dev/null; then
    echo "ℹ️  Cursor est déjà installé."
    read -p "Voulez-vous réinstaller/mettre à jour? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "❌ Installation annulée."
        exit 0
    fi
    echo "🗑️  Suppression de l'ancienne version..."
    sudo rm -f "$CURSOR_BIN"
    rm -rf "$CURSOR_DIR"
fi

# Télécharger la dernière version
echo "📥 Téléchargement de Cursor..."
mkdir -p "$(dirname "$CURSOR_APPIMAGE")"
wget -O "$CURSOR_APPIMAGE" "https://downloader.cursor.sh/linux/appImage/x64"

# Rendre exécutable
chmod +x "$CURSOR_APPIMAGE"

# Créer un lien symbolique
echo "🔗 Création du lien symbolique..."
sudo ln -sf "$CURSOR_APPIMAGE" "$CURSOR_BIN"

# Créer l'entrée de menu
echo "📝 Création de l'entrée de menu..."
cat > "$HOME/.local/share/applications/cursor.desktop" <<EOF
[Desktop Entry]
Name=Cursor
Exec=$CURSOR_APPIMAGE
Icon=cursor
Type=Application
Categories=Development;IDE;
EOF

# Vérifier l'installation
if command -v cursor &> /dev/null; then
    echo "✅ Cursor installé avec succès!"
    echo "📁 AppImage: $CURSOR_APPIMAGE"
    echo "🔗 Lien: $CURSOR_BIN"
    echo ""
    echo "💡 Lancer avec: cursor"
else
    echo "❌ Erreur lors de l'installation"
    exit 1
fi

