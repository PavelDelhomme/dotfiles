#!/bin/bash

################################################################################
# Désinstallation Cursor IDE
################################################################################

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_section "Désinstallation Cursor IDE"

log_warn "⚠️  Cette opération va supprimer Cursor IDE"
echo ""
printf "Continuer? (tapez 'OUI' en majuscules): "
read -r confirm

if [ "$confirm" != "OUI" ]; then
    log_info "Désinstallation annulée"
    exit 0
fi

CURSOR_DIR="$HOME/.local/share/cursor"
CURSOR_APPIMAGE="$HOME/.local/bin/cursor"
CURSOR_DESKTOP="$HOME/.local/share/applications/cursor.desktop"
CURSOR_ALIAS="cursor"

log_info "Suppression Cursor..."

# Supprimer l'AppImage
if [ -f "$CURSOR_APPIMAGE" ]; then
    rm -f "$CURSOR_APPIMAGE" && log_info "✓ AppImage supprimé" || log_warn "Impossible de supprimer AppImage"
else
    log_skip "AppImage non trouvé"
fi

# Supprimer le dossier Cursor
if [ -d "$CURSOR_DIR" ]; then
    rm -rf "$CURSOR_DIR" && log_info "✓ Dossier Cursor supprimé" || log_warn "Impossible de supprimer dossier"
else
    log_skip "Dossier Cursor non trouvé"
fi

# Supprimer le fichier desktop
if [ -f "$CURSOR_DESKTOP" ]; then
    rm -f "$CURSOR_DESKTOP" && log_info "✓ Fichier desktop supprimé" || log_warn "Impossible de supprimer desktop"
else
    log_skip "Fichier desktop non trouvé"
fi

# Supprimer l'alias (si existe dans zshrc ou aliases.zsh)
if command -v cursor &> /dev/null; then
    log_warn "⚠️  Alias 'cursor' trouvé. Supprimer de aliases.zsh?"
    printf "Supprimer alias? (o/n): "
    read -r remove_alias
    if [[ "$remove_alias" =~ ^[oO]$ ]]; then
        # Supprimer l'alias des fichiers
        sed -i '/alias cursor=/d' "$HOME/dotfiles/zsh/aliases.zsh" 2>/dev/null
        sed -i '/alias cursor=/d' "$HOME/.zshrc" 2>/dev/null
        log_info "✓ Alias supprimé"
    fi
fi

# Supprimer cache/config Cursor (optionnel)
log_warn "⚠️  Supprimer aussi le cache et la configuration Cursor?"
printf "Supprimer cache/config? (o/n): "
read -r remove_cache
if [[ "$remove_cache" =~ ^[oO]$ ]]; then
    rm -rf "$HOME/.config/cursor" 2>/dev/null && log_info "✓ Cache supprimé" || true
    rm -rf "$HOME/.cache/cursor" 2>/dev/null && log_info "✓ Config supprimé" || true
fi

log_info "✅ Désinstallation Cursor terminée"

