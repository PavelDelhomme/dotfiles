#!/bin/bash
# =============================================================================
# Script de diagnostic pour la commande help()
# =============================================================================

echo "🔍 Diagnostic de la commande help()"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier les variables d'environnement
echo "📋 Variables d'environnement:"
echo "  DOTFILES_DIR: ${DOTFILES_DIR:-❌ NON DÉFINI}"
echo "  COLUMNS: ${COLUMNS:-❌ NON DÉFINI}"
echo ""

# Vérifier Python
echo "🐍 Python:"
if command -v python3 >/dev/null 2>&1; then
    echo "  ✅ Python3 installé: $(python3 --version)"
else
    echo "  ❌ Python3 non installé"
fi
echo ""

# Vérifier le script Python
SCRIPT_PATH="$HOME/dotfiles/zsh/functions/utils/list_functions.py"
echo "📄 Script Python:"
if [ -f "$SCRIPT_PATH" ]; then
    echo "  ✅ Fichier trouvé: $SCRIPT_PATH"
    if [ -x "$SCRIPT_PATH" ]; then
        echo "  ✅ Fichier exécutable"
    else
        echo "  ⚠️  Fichier non exécutable (chmod +x requis)"
    fi
else
    echo "  ❌ Fichier introuvable: $SCRIPT_PATH"
fi
echo ""

# Tester le script directement
echo "🧪 Test du script Python:"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export COLUMNS="${COLUMNS:-$(tput cols 2>/dev/null || echo "80")}"

if [ -f "$SCRIPT_PATH" ] && command -v python3 >/dev/null 2>&1; then
    echo "  Exécution du script..."
    python3 "$SCRIPT_PATH" 2>&1 | head -30
    echo ""
    echo "  ✅ Script exécuté avec succès"
else
    echo "  ❌ Impossible d'exécuter le script"
fi
echo ""

# Vérifier la fonction help
echo "🔧 Fonction help:"
if type help >/dev/null 2>&1; then
    echo "  ✅ Fonction help disponible"
    echo "  Test de 'help' (premiers 50 lignes):"
    help 2>&1 | head -50
else
    echo "  ❌ Fonction help non disponible"
    echo "  💡 Essayez: source ~/dotfiles/zsh/zshrc_custom"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Si le problème persiste, vérifiez:"
echo "   1. Que Python3 est installé: python3 --version"
echo "   2. Que le script est exécutable: chmod +x $SCRIPT_PATH"
echo "   3. Que DOTFILES_DIR est défini: echo \$DOTFILES_DIR"
echo "   4. Rechargez le shell: source ~/dotfiles/zsh/zshrc_custom"
echo ""

