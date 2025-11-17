#!/bin/bash

################################################################################
# Installation de Go (Golang)
# Détecte la version actuelle et propose mise à jour si nécessaire
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

GO_VERSION="1.23.3"  # Dernière version stable
GO_INSTALL_DIR="/usr/local"
GO_ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

log_section "Installation Go ${GO_VERSION}"

################################################################################
# DÉTECTION VERSION ACTUELLE
################################################################################
CURRENT_VERSION=""
if command -v go &> /dev/null; then
    CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Go ${CURRENT_VERSION} est déjà installé"
    
    if [ "$CURRENT_VERSION" != "$GO_VERSION" ]; then
        log_warn "Version différente détectée: ${CURRENT_VERSION} vs ${GO_VERSION}"
        read -p "Voulez-vous mettre à jour vers ${GO_VERSION}? (o/N): " update_choice
        if [[ ! "$update_choice" =~ ^[oO]$ ]]; then
            log_info "Installation annulée"
            exit 0
        fi
        log_info "Suppression de l'ancienne version..."
        sudo rm -rf /usr/local/go
    else
        log_info "Version déjà à jour: ${GO_VERSION}"
        read -p "Réinstaller quand même? (o/N): " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
            log_info "Installation ignorée"
            exit 0
        fi
        sudo rm -rf /usr/local/go
    fi
fi

################################################################################
# TÉLÉCHARGEMENT
################################################################################
log_section "Téléchargement Go ${GO_VERSION}"

cd /tmp
log_info "Téléchargement depuis: $GO_URL"
wget -q --show-progress "$GO_URL" || {
    log_error "Échec du téléchargement"
    exit 1
}

################################################################################
# INSTALLATION
################################################################################
log_section "Installation Go"

log_info "Extraction de l'archive..."
sudo tar -C "$GO_INSTALL_DIR" -xzf "$GO_ARCHIVE"

log_info "Nettoyage..."
rm "$GO_ARCHIVE"

################################################################################
# CONFIGURATION PATH
################################################################################
log_section "Configuration PATH"

# Créer GOPATH si manquant
mkdir -p "$HOME/go"

# Ajouter Go au PATH via add_to_path si disponible
if type add_to_path &> /dev/null; then
    log_info "Utilisation de add_to_path..."
    add_to_path "/usr/local/go/bin"
    add_to_path "$HOME/go/bin"
    log_info "✓ PATH configuré via add_to_path"
else
    log_warn "add_to_path non disponible, ajout manuel au PATH..."
    ENV_FILE="$HOME/dotfiles/zsh/env.sh"
    if [ -f "$ENV_FILE" ]; then
        if ! grep -q "/usr/local/go/bin" "$ENV_FILE"; then
            echo "" >> "$ENV_FILE"
            echo "# Go paths" >> "$ENV_FILE"
            echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$ENV_FILE"
            log_info "✓ PATH ajouté dans $ENV_FILE"
        else
            log_info "✓ PATH déjà présent dans $ENV_FILE"
        fi
    else
        log_warn "Fichier env.sh non trouvé, ajout manuel requis"
    fi
fi

# Recharger le shell
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

################################################################################
# VÉRIFICATION
################################################################################
log_section "Vérification de l'installation"

if command -v go &> /dev/null; then
    INSTALLED_VERSION=$(go version | awk '{print $3}')
    log_info "✅ Go installé avec succès: $INSTALLED_VERSION"
    go version
    echo ""
    log_info "Configuration:"
    echo "  📁 GOPATH: $HOME/go"
    echo "  📁 GOROOT: /usr/local/go"
else
    log_error "❌ Erreur lors de l'installation de Go"
    log_warn "Rechargez votre shell: exec zsh"
    exit 1
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
log_info "Commandes utiles:"
echo "  go version        - Afficher la version"
echo "  go mod init       - Initialiser un module"
echo "  go run main.go    - Exécuter un fichier"
echo "  go build          - Compiler le projet"
echo ""
log_warn "💡 Rechargez votre shell pour que le PATH soit actif: exec zsh"
echo ""

