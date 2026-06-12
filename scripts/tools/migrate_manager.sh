#!/bin/bash
# =============================================================================
# MIGRATE MANAGER - Script de migration d'un manager vers structure hybride
# =============================================================================
# Description: Migre un manager de l'ancienne structure vers core/ + shells/
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MANAGER_NAME="$1"

if [ -z "$MANAGER_NAME" ]; then
    echo "❌ Usage: $0 <manager_name>"
    echo "💡 Exemple: $0 pathman"
    exit 1
fi

echo "🔄 Migration de $MANAGER_NAME vers structure hybride..."
echo ""

# Chemins
ZSH_MANAGER="$DOTFILES_DIR/zsh/functions/$MANAGER_NAME"
BASH_MANAGER="$DOTFILES_DIR/bash/functions/$MANAGER_NAME"
FISH_MANAGER="$DOTFILES_DIR/fish/functions/$MANAGER_NAME"
CORE_MANAGER="$DOTFILES_DIR/core/managers/$MANAGER_NAME"

# Vérifier que le manager existe en ZSH (source principale)
if [ ! -d "$ZSH_MANAGER" ]; then
    echo "❌ Manager $MANAGER_NAME non trouvé dans zsh/functions/"
    exit 1
fi

# Créer la structure core
echo "📁 Création de la structure core/managers/$MANAGER_NAME..."
mkdir -p "$CORE_MANAGER"/{core,modules,config,utils,install}

# Copier le code principal (ZSH comme base, à convertir en POSIX)
if [ -f "$ZSH_MANAGER/core/${MANAGER_NAME}.zsh" ]; then
    echo "📋 Copie du code principal..."
    cp "$ZSH_MANAGER/core/${MANAGER_NAME}.zsh" "$CORE_MANAGER/core/${MANAGER_NAME}.sh"
    # Convertir en POSIX (basique, nécessitera ajustements manuels)
    sed -i 's/#!/bin\/zsh/#!/bin\/sh/g' "$CORE_MANAGER/core/${MANAGER_NAME}.sh"
    sed -i 's/\[\[/\[/g' "$CORE_MANAGER/core/${MANAGER_NAME}.sh"
    sed -i 's/\]\]/\]/g' "$CORE_MANAGER/core/${MANAGER_NAME}.sh"
fi

# Copier modules, config, utils, install
if [ -d "$ZSH_MANAGER/modules" ] && [ "$(ls -A $ZSH_MANAGER/modules 2>/dev/null)" ]; then
    echo "📦 Copie des modules..."
    cp -r "$ZSH_MANAGER/modules"/* "$CORE_MANAGER/modules/" 2>/dev/null || true
fi

if [ -d "$ZSH_MANAGER/config" ] && [ "$(ls -A $ZSH_MANAGER/config 2>/dev/null)" ]; then
    echo "⚙️  Copie de la configuration..."
    cp -r "$ZSH_MANAGER/config"/* "$CORE_MANAGER/config/" 2>/dev/null || true
fi

if [ -d "$ZSH_MANAGER/utils" ] && [ "$(ls -A $ZSH_MANAGER/utils 2>/dev/null)" ]; then
    echo "🔧 Copie des utilitaires..."
    cp -r "$ZSH_MANAGER/utils"/* "$CORE_MANAGER/utils/" 2>/dev/null || true
fi

if [ -d "$ZSH_MANAGER/install" ] && [ "$(ls -A $ZSH_MANAGER/install 2>/dev/null)" ]; then
    echo "📥 Copie des scripts d'installation..."
    cp -r "$ZSH_MANAGER/install"/* "$CORE_MANAGER/install/" 2>/dev/null || true
fi

echo "✅ Structure core créée"
echo ""

# Créer les adapters shell
echo "🔌 Création des adapters shell..."

# Adapter ZSH
ZSH_ADAPTER="$DOTFILES_DIR/shells/zsh/adapters/${MANAGER_NAME}.zsh"
cat > "$ZSH_ADAPTER" <<EOF
#!/bin/zsh
# =============================================================================
# ${MANAGER_NAME^^} ADAPTER - Wrapper ZSH pour ${MANAGER_NAME}
# =============================================================================
# Description: Adapter ZSH pour charger ${MANAGER_NAME} depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
_dotfiles_manager_core="\$HOME/dotfiles/core/managers/${MANAGER_NAME}/core/${MANAGER_NAME}.sh"

if [ -f "\$_dotfiles_manager_core" ]; then
    # Source le code commun
    source "\$_dotfiles_manager_core"
else
    echo "❌ Erreur: ${MANAGER_NAME} core non trouvé: \$_dotfiles_manager_core"
    unset _dotfiles_manager_core
    return 1
fi
unset _dotfiles_manager_core
EOF
chmod +x "$ZSH_ADAPTER"
echo "✅ Adapter ZSH créé: $ZSH_ADAPTER"

# Adapter Bash
BASH_ADAPTER="$DOTFILES_DIR/shells/bash/adapters/${MANAGER_NAME}.sh"
cat > "$BASH_ADAPTER" <<EOF
#!/bin/bash
# =============================================================================
# ${MANAGER_NAME^^} ADAPTER - Wrapper Bash pour ${MANAGER_NAME}
# =============================================================================
# Description: Adapter Bash pour charger ${MANAGER_NAME} depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
_dotfiles_manager_core="\$HOME/dotfiles/core/managers/${MANAGER_NAME}/core/${MANAGER_NAME}.sh"

if [ -f "\$_dotfiles_manager_core" ]; then
    # Source le code commun
    source "\$_dotfiles_manager_core"
else
    echo "❌ Erreur: ${MANAGER_NAME} core non trouvé: \$_dotfiles_manager_core"
    unset _dotfiles_manager_core
    return 1
fi
unset _dotfiles_manager_core
EOF
chmod +x "$BASH_ADAPTER"
echo "✅ Adapter Bash créé: $BASH_ADAPTER"

# Adapter Fish
FISH_ADAPTER="$DOTFILES_DIR/shells/fish/adapters/${MANAGER_NAME}.fish"
cat > "$FISH_ADAPTER" <<EOF
# =============================================================================
# ${MANAGER_NAME^^} ADAPTER - Wrapper Fish pour ${MANAGER_NAME}
# =============================================================================
# Description: Adapter Fish pour charger ${MANAGER_NAME} depuis core/
# Author: Auto-generated
# Version: 1.0
# =============================================================================

# Charger le code commun depuis core/
# Note: Fish ne peut pas sourcer directement .sh, nécessite conversion ou wrapper
set -l CORE_MANAGER "\$HOME/dotfiles/core/managers/${MANAGER_NAME}/core/${MANAGER_NAME}.sh"

if test -f "\$CORE_MANAGER"
    # Pour Fish, on devra créer une version Fish ou utiliser un wrapper
    # Pour l'instant, on garde l'ancienne version
    source "\$HOME/dotfiles/fish/functions/${MANAGER_NAME}/core/${MANAGER_NAME}.fish"
else
    echo "❌ Erreur: ${MANAGER_NAME} core non trouvé: \$CORE_MANAGER"
    return 1
end
EOF
chmod +x "$FISH_ADAPTER"
echo "✅ Adapter Fish créé: $FISH_ADAPTER"

echo ""
echo "✅ Migration de $MANAGER_NAME terminée!"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Vérifier et ajuster le code dans core/managers/$MANAGER_NAME/core/${MANAGER_NAME}.sh"
echo "   2. Tester dans chaque shell"
echo "   3. Mettre à jour les fichiers de configuration (zshrc_custom, bashrc_custom, config_custom.fish)"
echo "   4. Si tout fonctionne, supprimer les anciennes structures"

