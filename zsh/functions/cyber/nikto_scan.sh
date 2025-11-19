# Nouvelle fonction pour effectuer un scan de vulnérabilités avec Nikto
function nikto_scan() {
    # Vérifier et installer nikto si nécessaire
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool nikto || return 1
    fi
    
    if [ $# -eq 0 ]; then
        echo "Usage: nikto_scan <target>"
        echo "Effectue un scan de vulnérabilités avec Nikto."
        echo "Exemple: nikto_scan https://example.com"
        return 1
    fi
    nikto -h $1
}
