#!/bin/bash

################################################################################
# Script de migration entre Fish et Zsh
# Permet de migrer la configuration d'un shell vers l'autre
# Usage: bash ~/dotfiles/scripts/migrate_shell.sh [fish|zsh]
################################################################################

set +e  # Ne pas arrêter sur erreurs

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

DOTFILES_DIR="$HOME/dotfiles"
FISH_DIR="$DOTFILES_DIR/fish"
ZSH_DIR="$DOTFILES_DIR/zsh"

################################################################################
# DÉTECTION DU SHELL ACTUEL
################################################################################
detect_current_shell() {
    local current_shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    if [[ "$current_shell" == *"fish"* ]]; then
        echo "fish"
    elif [[ "$current_shell" == *"zsh"* ]]; then
        echo "zsh"
    else
        echo "unknown"
    fi
}

################################################################################
# MIGRATION FISH -> ZSH
################################################################################
migrate_fish_to_zsh() {
    log_section "Migration Fish -> Zsh"
    
    # 1. Migrer les alias
    log_info "Migration des alias..."
    if [ -f "$FISH_DIR/aliases.fish" ]; then
        # Conversion basique fish -> zsh (format différent)
        if [ ! -f "$ZSH_DIR/aliases.zsh" ]; then
            touch "$ZSH_DIR/aliases.zsh"
        fi
        # Ajouter un commentaire dans zsh/aliases.zsh
        if ! grep -q "# Migré depuis Fish" "$ZSH_DIR/aliases.zsh"; then
            cat >> "$ZSH_DIR/aliases.zsh" << 'EOF'

# Migré depuis Fish
# Les alias Fish utilisent 'alias name=command'
# Les alias Zsh utilisent 'alias name="command"'
# Vérifiez et adaptez manuellement si nécessaire
EOF
            # Convertir les alias fish en zsh (approximation)
            grep "^alias " "$FISH_DIR/aliases.fish" | sed 's/alias /alias /' | sed 's/=/="/' | sed 's/$/"/' >> "$ZSH_DIR/aliases.zsh" 2>/dev/null || true
            log_info "✓ Alias migrés (vérifiez manuellement)"
        fi
    fi
    
    # 2. Migrer les variables d'environnement
    log_info "Migration des variables d'environnement..."
    if [ -f "$FISH_DIR/env.fish" ]; then
        if [ ! -f "$ZSH_DIR/env.sh" ]; then
            touch "$ZSH_DIR/env.sh"
        fi
        # Convertir set -gx VAR value -> export VAR=value
        if ! grep -q "# Migré depuis Fish" "$ZSH_DIR/env.sh"; then
            cat >> "$ZSH_DIR/env.sh" << 'EOF'

# Migré depuis Fish
# Les variables Fish utilisent 'set -gx VAR value'
# Les variables Zsh utilisent 'export VAR=value'
EOF
            grep "set -gx " "$FISH_DIR/env.fish" | sed 's/set -gx /export /' | sed 's/ /=/1' >> "$ZSH_DIR/env.sh" 2>/dev/null || true
            log_info "✓ Variables d'environnement migrées"
        fi
    fi
    
    # 3. Migrer PATH_SAVE si existe
    log_info "Migration des sauvegardes PATH..."
    if [ -f "$FISH_DIR/PATH_SAVE" ]; then
        cp "$FISH_DIR/PATH_SAVE" "$ZSH_DIR/PATH_SAVE" 2>/dev/null && log_info "✓ PATH_SAVE copié" || log_warn "⚠ PATH_SAVE non copié"
    fi
    if [ -f "$FISH_DIR/path_log.txt" ]; then
        cp "$FISH_DIR/path_log.txt" "$ZSH_DIR/path_log.txt" 2>/dev/null && log_info "✓ path_log.txt copié" || log_warn "⚠ path_log.txt non copié"
    fi
    
    # 4. Créer/activer le symlink .zshrc
    log_info "Configuration du symlink .zshrc..."
    if [ ! -L "$HOME/.zshrc" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
            log_info "✓ Backup .zshrc créé: $BACKUP_DIR/.zshrc"
            rm "$HOME/.zshrc"
        fi
        # Créer .zshrc si nécessaire
        if [ ! -f "$DOTFILES_DIR/.zshrc" ]; then
            if [ -f "$ZSH_DIR/zshrc_custom" ]; then
                cat > "$DOTFILES_DIR/.zshrc" << 'EOF'
# Dotfiles - Configuration ZSH
# Source: zshrc_custom
if [ -f "$HOME/dotfiles/zsh/zshrc_custom" ]; then
    source "$HOME/dotfiles/zsh/zshrc_custom"
fi
EOF
            fi
        fi
        ln -s "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" 2>/dev/null || ln -s "$ZSH_DIR/zshrc_custom" "$HOME/.zshrc"
        log_info "✓ Symlink .zshrc créé"
    fi
    
    # 5. Changer le shell par défaut
    log_info "Pour changer le shell par défaut, exécutez :"
    echo -e "${CYAN}  chsh -s $(which zsh)${NC}"
    
    log_info "✅ Migration Fish -> Zsh terminée"
    log_warn "⚠️  Rechargez votre shell avec: exec zsh"
}

################################################################################
# MIGRATION ZSH -> FISH
################################################################################
migrate_zsh_to_fish() {
    log_section "Migration Zsh -> Fish"
    
    # 1. Migrer les alias
    log_info "Migration des alias..."
    if [ -f "$ZSH_DIR/aliases.zsh" ]; then
        if [ ! -f "$FISH_DIR/aliases.fish" ]; then
            touch "$FISH_DIR/aliases.fish"
        fi
        # Ajouter un commentaire dans fish/aliases.fish
        if ! grep -q "# Migré depuis Zsh" "$FISH_DIR/aliases.fish"; then
            cat >> "$FISH_DIR/aliases.fish" << 'EOF'

# Migré depuis Zsh
# Les alias Zsh utilisent 'alias name="command"'
# Les alias Fish utilisent 'alias name=command'
# Vérifiez et adaptez manuellement si nécessaire
EOF
            # Convertir les alias zsh en fish (approximation)
            grep "^alias " "$ZSH_DIR/aliases.zsh" | sed 's/alias /alias /' | sed 's/="\(.*\)"/= \1/' | sed 's/"//g' >> "$FISH_DIR/aliases.fish" 2>/dev/null || true
            log_info "✓ Alias migrés (vérifiez manuellement)"
        fi
    fi
    
    # 2. Migrer les variables d'environnement
    log_info "Migration des variables d'environnement..."
    if [ -f "$ZSH_DIR/env.sh" ]; then
        if [ ! -f "$FISH_DIR/env.fish" ]; then
            touch "$FISH_DIR/env.fish"
        fi
        # Convertir export VAR=value -> set -gx VAR value
        if ! grep -q "# Migré depuis Zsh" "$FISH_DIR/env.fish"; then
            cat >> "$FISH_DIR/env.fish" << 'EOF'

# Migré depuis Zsh
# Les variables Zsh utilisent 'export VAR=value'
# Les variables Fish utilisent 'set -gx VAR value'
EOF
            grep "^export " "$ZSH_DIR/env.sh" | sed 's/export /set -gx /' | sed 's/=/ /' >> "$FISH_DIR/env.fish" 2>/dev/null || true
            log_info "✓ Variables d'environnement migrées"
        fi
    fi
    
    # 3. Migrer PATH_SAVE si existe
    log_info "Migration des sauvegardes PATH..."
    if [ -f "$ZSH_DIR/PATH_SAVE" ]; then
        cp "$ZSH_DIR/PATH_SAVE" "$FISH_DIR/PATH_SAVE" 2>/dev/null && log_info "✓ PATH_SAVE copié" || log_warn "⚠ PATH_SAVE non copié"
    fi
    if [ -f "$ZSH_DIR/path_log.txt" ]; then
        cp "$ZSH_DIR/path_log.txt" "$FISH_DIR/path_log.txt" 2>/dev/null && log_info "✓ path_log.txt copié" || log_warn "⚠ path_log.txt non copié"
    fi
    
    # 4. Créer/activer le symlink config.fish
    log_info "Configuration du symlink config.fish..."
    FISH_CONFIG_DIR="$HOME/.config/fish"
    mkdir -p "$FISH_CONFIG_DIR"
    
    if [ ! -L "$FISH_CONFIG_DIR/config.fish" ]; then
        if [ -f "$FISH_CONFIG_DIR/config.fish" ]; then
            BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            cp "$FISH_CONFIG_DIR/config.fish" "$BACKUP_DIR/config.fish"
            log_info "✓ Backup config.fish créé: $BACKUP_DIR/config.fish"
            rm "$FISH_CONFIG_DIR/config.fish"
        fi
        # Créer config.fish dans dotfiles si nécessaire
        if [ ! -f "$DOTFILES_DIR/fish/config.fish" ]; then
            if [ -f "$FISH_DIR/config_custom.fish" ]; then
                cat > "$DOTFILES_DIR/fish/config.fish" << 'EOF'
# Dotfiles - Configuration Fish
# Source: config_custom.fish
if test -f "$HOME/dotfiles/fish/config_custom.fish"
    source "$HOME/dotfiles/fish/config_custom.fish"
end
EOF
            fi
        fi
        if [ -f "$DOTFILES_DIR/fish/config.fish" ]; then
            ln -s "$DOTFILES_DIR/fish/config.fish" "$FISH_CONFIG_DIR/config.fish"
            log_info "✓ Symlink config.fish créé"
        elif [ -f "$FISH_DIR/config_custom.fish" ]; then
            ln -s "$FISH_DIR/config_custom.fish" "$FISH_CONFIG_DIR/config.fish"
            log_info "✓ Symlink config_custom.fish créé"
        fi
    fi
    
    # 5. Changer le shell par défaut
    log_info "Pour changer le shell par défaut, exécutez :"
    echo -e "${CYAN}  chsh -s $(which fish)${NC}"
    
    log_info "✅ Migration Zsh -> Fish terminée"
    log_warn "⚠️  Rechargez votre shell avec: exec fish"
}

################################################################################
# MENU PRINCIPAL
################################################################################
show_menu() {
    echo ""
    log_section "Migration entre Fish et Zsh"
    echo ""
    echo "1. Migrer Fish -> Zsh"
    echo "2. Migrer Zsh -> Fish"
    echo "3. Détecter le shell actuel"
    echo "0. Quitter"
    echo ""
}

################################################################################
# EXECUTION
################################################################################
TARGET_SHELL="$1"

if [ -n "$TARGET_SHELL" ]; then
    # Mode non-interactif avec argument
    case "$TARGET_SHELL" in
        fish|zsh)
            CURRENT=$(detect_current_shell)
            if [ "$CURRENT" = "$TARGET_SHELL" ]; then
                log_warn "Vous êtes déjà sur $TARGET_SHELL"
                exit 0
            fi
            if [ "$TARGET_SHELL" = "zsh" ]; then
                migrate_fish_to_zsh
            else
                migrate_zsh_to_fish
            fi
            ;;
        *)
            log_error "Usage: $0 [fish|zsh]"
            exit 1
            ;;
    esac
else
    # Mode interactif
    while true; do
        show_menu
        printf "Choix: "
        read -r choice
        
        case "$choice" in
            1)
                migrate_fish_to_zsh
                printf "\nAppuyez sur Entrée pour continuer... "
                read -r dummy
                ;;
            2)
                migrate_zsh_to_fish
                printf "\nAppuyez sur Entrée pour continuer... "
                read -r dummy
                ;;
            3)
                CURRENT=$(detect_current_shell)
                log_info "Shell actuel: $CURRENT"
                printf "\nAppuyez sur Entrée pour continuer... "
                read -r dummy
                ;;
            0)
                log_info "Au revoir!"
                exit 0
                ;;
            *)
                log_error "Choix invalide"
                sleep 1
                ;;
        esac
    done
fi

