#!/bin/bash

################################################################################
# Installation NVM (Node Version Manager) pour Manjaro Linux avec Zsh
################################################################################

set -e

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Installation NVM (Node Version Manager)"

################################################################################
# VÉRIFICATION INSTALLATION EXISTANTE
################################################################################
if [ -d "$HOME/.nvm" ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
    log_info "✅ NVM déjà installé dans $HOME/.nvm"
    log_info "Version NVM: $(cat "$HOME/.nvm/.nvmrc" 2>/dev/null || echo "v0.39.7")"
    
    # Vérifier si NVM est correctement configuré dans .zshrc
    if grep -q "NVM_DIR" "$HOME/dotfiles/zsh/zshrc_custom" 2>/dev/null; then
        log_info "✅ NVM déjà configuré dans zshrc_custom"
        exit 0
    else
        log_warn "⚠️  NVM installé mais non configuré dans zshrc_custom"
        log_info "Ajout de la configuration NVM..."
    fi
else
    log_info "Installation de NVM..."
fi

################################################################################
# INSTALLATION DE NVM
################################################################################
log_section "Installation depuis le script officiel"

NVM_VERSION="v0.39.7"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

log_info "Téléchargement et installation de NVM ${NVM_VERSION}..."
if ! curl -o- "$NVM_INSTALL_URL" | bash; then
    log_error "Erreur lors de l'installation de NVM"
    log_warn "Vérifiez votre connexion internet et réessayez"
    exit 1
fi

log_info "✓ NVM installé dans $HOME/.nvm"

################################################################################
# CONFIGURATION DANS ZSHRC_CUSTOM
################################################################################
log_section "Configuration dans zshrc_custom"

ZSHRC_CUSTOM="$HOME/dotfiles/zsh/zshrc_custom"

if [ ! -f "$ZSHRC_CUSTOM" ]; then
    log_error "Fichier $ZSHRC_CUSTOM introuvable"
    exit 1
fi

# Vérifier si la configuration NVM existe déjà
if grep -q "NVM_DIR" "$ZSHRC_CUSTOM"; then
    log_info "✅ Configuration NVM déjà présente dans zshrc_custom"
else
    log_info "Ajout de la configuration NVM avec lazy-loading..."
    
    # Trouver la ligne où insérer la configuration NVM (avant Oh-My-Zsh si présent, sinon au début après les commentaires)
    # On va l'insérer juste après la déclaration des variables DOTFILES
    INSERT_LINE=$(grep -n "^DOTFILES_PATH=" "$ZSHRC_CUSTOM" | head -1 | cut -d: -f1)
    
    if [ -z "$INSERT_LINE" ]; then
        # Si on ne trouve pas DOTFILES_PATH, on insère après les commentaires du début
        INSERT_LINE=$(grep -n "^#.*DOTFILES" "$ZSHRC_CUSTOM" | head -1 | cut -d: -f1)
        if [ -z "$INSERT_LINE" ]; then
            INSERT_LINE=1
        fi
    fi
    
    # Configuration NVM avec lazy-loading
    NVM_CONFIG="# =============================================================================
# CONFIGURATION NVM (Node Version Manager)
# IMPORTANT: Cette configuration doit être placée AVANT l'activation d'Oh-My-Zsh
# pour éviter les bugs d'accès. Utilise le lazy-loading pour accélérer le démarrage.
# =============================================================================
export NVM_DIR=\"\$HOME/.nvm\"

# Lazy-loading NVM (ne charge NVM que quand on utilise node/npm/nvm/npx)
lazynvm() {
  unset -f nvm node npm npx
  export NVM_DIR=\"\$HOME/.nvm\"
  [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
}

# Wrappers pour lazy-loading
nvm() { lazynvm; nvm \"\$@\"; }
node() { lazynvm; node \"\$@\"; }
npm()  { lazynvm; npm  \"\$@\"; }
npx()  { lazynvm; npx  \"\$@\"; }
"
    
    # Créer un fichier temporaire avec la nouvelle configuration
    TEMP_FILE=$(mktemp)
    
    # Copier les lignes avant l'insertion
    if [ "$INSERT_LINE" -gt 1 ]; then
        head -n $((INSERT_LINE - 1)) "$ZSHRC_CUSTOM" > "$TEMP_FILE"
    fi
    
    # Ajouter la configuration NVM
    echo "$NVM_CONFIG" >> "$TEMP_FILE"
    
    # Copier les lignes après l'insertion
    tail -n +$INSERT_LINE "$ZSHRC_CUSTOM" >> "$TEMP_FILE"
    
    # Remplacer le fichier original
    mv "$TEMP_FILE" "$ZSHRC_CUSTOM"
    
    log_info "✓ Configuration NVM ajoutée dans zshrc_custom"
fi

################################################################################
# VÉRIFICATION
################################################################################
log_section "Vérification"

if [ -d "$HOME/.nvm" ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
    log_info "✅ NVM installé: $HOME/.nvm"
    
    # Charger NVM temporairement pour vérifier
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    
    if command -v nvm &> /dev/null; then
        NVM_VER=$(nvm --version 2>/dev/null || echo "installé")
        log_info "✅ NVM fonctionnel: version $NVM_VER"
    else
        log_warn "⚠️  NVM installé mais commande non disponible (normal, nécessite rechargement du shell)"
    fi
else
    log_error "✗ NVM non trouvé après installation"
    exit 1
fi

################################################################################
# INSTRUCTIONS
################################################################################
log_section "Installation terminée!"

echo ""
log_info "✅ NVM installé et configuré avec lazy-loading"
echo ""
log_info "📝 PROCHAINES ÉTAPES:"
echo ""
echo "1. Rechargez votre shell:"
echo "   source ~/.zshrc"
echo ""
echo "2. Vérifiez que NVM fonctionne:"
echo "   nvm --version"
echo ""
echo "3. Installez une version de Node.js:"
echo "   nvm install 22"
echo "   nvm use 22"
echo ""
echo "4. Vérifiez l'installation:"
echo "   node -v"
echo "   npm -v"
echo ""
log_info "💡 Le lazy-loading signifie que NVM ne se charge que lorsque vous utilisez"
log_info "   les commandes node, npm, nvm ou npx, ce qui accélère le démarrage de Zsh."
echo ""

