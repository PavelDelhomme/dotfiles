#!/bin/zsh
# =============================================================================
# INSTALL-TOOL - Installateur universel d'outils avec configuration automatique
# =============================================================================
# Description: Installe et configure automatiquement des outils de développement
#              avec ajout automatique au PATH dans env.sh
# Usage: install-tool [tool-name] ou install-tool (menu interactif)
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Chemins
DOTFILES_DIR="$HOME/dotfiles"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
INSTALL_DIR="$SCRIPTS_DIR/install/dev"
ENV_FILE="$DOTFILES_DIR/zsh/env.sh"

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================
log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }

# =============================================================================
# AJOUTER AU PATH DANS env.sh
# =============================================================================
add_path_to_env() {
    local path_to_add="$1"
    local comment="$2"
    
    if [ -z "$path_to_add" ]; then
        log_error "Chemin vide, impossible d'ajouter au PATH"
        return 1
    fi
    
    log_step "Ajout de $path_to_add au PATH dans env.sh..."
    
    # Vérifier si le chemin existe déjà dans env.sh (chercher la ligne exacte)
    if grep -q "add_to_path.*\"$path_to_add\"" "$ENV_FILE" 2>/dev/null || \
       grep -q "add_to_path.*'$path_to_add'" "$ENV_FILE" 2>/dev/null || \
       grep -q "$path_to_add" "$ENV_FILE" 2>/dev/null; then
        log_info "Le chemin $path_to_add est déjà présent dans env.sh"
        return 0
    fi
    
    # Trouver la dernière ligne avec add_to_path pour insérer après
    local insert_line
    insert_line=$(grep -n "add_to_path" "$ENV_FILE" 2>/dev/null | tail -1 | cut -d: -f1)
    
    if [ -z "$insert_line" ]; then
        # Si pas de add_to_path, trouver la section PATH
        insert_line=$(grep -n "^# === Ajout des chemins au PATH ===" "$ENV_FILE" 2>/dev/null | cut -d: -f1)
        if [ -n "$insert_line" ]; then
            # Chercher la première ligne add_to_path après cette section
            local section_start=$insert_line
            insert_line=$(sed -n "${section_start},\$p" "$ENV_FILE" | grep -n "add_to_path" | head -1 | cut -d: -f1)
            if [ -n "$insert_line" ]; then
                insert_line=$((section_start + insert_line - 1))
            else
                # Aucune ligne add_to_path trouvée, ajouter après la section
                insert_line=$(grep -n "^# ===" "$ENV_FILE" | grep -A1 "Ajout des chemins" | tail -1 | cut -d: -f1)
                insert_line=$((insert_line + 1))
            fi
        else
            # Pas de section trouvée, ajouter à la fin
            insert_line=$(wc -l < "$ENV_FILE" 2>/dev/null || echo "0")
            if [ "$insert_line" = "0" ]; then
                log_error "Fichier env.sh vide ou inaccessible"
                return 1
            fi
        fi
    else
        # Insérer après la dernière ligne add_to_path
        insert_line=$((insert_line + 1))
    fi
    
    # Préparer les lignes à ajouter
    local indent="    "
    local new_lines=""
    if [ -n "$comment" ]; then
        new_lines="${indent}# $comment\n${indent}add_to_path \"$path_to_add\" 2>/dev/null || true"
    else
        new_lines="${indent}add_to_path \"$path_to_add\" 2>/dev/null || true"
    fi
    
    # Créer un fichier temporaire avec la modification
    local temp_file=$(mktemp)
    
    # Ajouter les lignes avant et après l'insertion
    if [ -n "$insert_line" ] && [ "$insert_line" -gt 0 ]; then
        head -n $((insert_line - 1)) "$ENV_FILE" 2>/dev/null > "$temp_file"
        echo -e "$new_lines" >> "$temp_file"
        tail -n +$insert_line "$ENV_FILE" 2>/dev/null >> "$temp_file"
    else
        # Ajouter à la fin
        cat "$ENV_FILE" 2>/dev/null > "$temp_file"
        echo "" >> "$temp_file"
        echo -e "$new_lines" >> "$temp_file"
    fi
    
    # Remplacer le fichier original
    mv "$temp_file" "$ENV_FILE" 2>/dev/null || {
        log_error "Impossible de modifier env.sh (permissions?)"
        log_warn "Vous pouvez ajouter manuellement: add_to_path \"$path_to_add\" dans $ENV_FILE"
        return 1
    }
    
    log_info "✓ Chemin $path_to_add ajouté à env.sh"
    
    # Ajouter aussi au PATH actuel de la session
    if [ -d "$path_to_add" ] && [[ ":$PATH:" != *":$path_to_add:"* ]]; then
        export PATH="$path_to_add:$PATH"
        log_info "✓ Chemin ajouté au PATH de la session actuelle"
    fi
    
    return 0
}

# =============================================================================
# INSTALLATION FLUTTER
# =============================================================================
install_flutter() {
    log_step "Installation de Flutter dans /opt/flutter/bin..."
    
    local flutter_bin="/opt/flutter/bin"
    local flutter_dir="/opt/flutter"
    
    # Vérifier si déjà installé
    if [ -d "$flutter_bin" ] && [ -f "$flutter_bin/flutter" ]; then
        log_info "Flutter est déjà installé dans $flutter_dir"
        log_step "Vérification de la version..."
        "$flutter_bin/flutter" --version | head -n1 || true
        read -p "Réinstaller/mettre à jour? (o/N): " reinstall
        if [[ ! "$reinstall" =~ ^[oO]$ ]]; then
            # Vérifier si déjà dans env.sh
            if ! grep -q "$flutter_bin" "$ENV_FILE" 2>/dev/null; then
                log_step "Ajout au PATH dans env.sh..."
                add_path_to_env "$flutter_bin" "Flutter SDK"
            fi
            log_info "Installation ignorée"
            return 0
        else
            log_step "Suppression de l'installation existante..."
            sudo rm -rf "$flutter_dir"
        fi
    fi
    
    # Détection de la distribution
    local distro="unknown"
    if [ -f /etc/arch-release ]; then
        distro="arch"
    elif [ -f /etc/debian_version ]; then
        distro="debian"
    elif [ -f /etc/fedora-release ]; then
        distro="fedora"
    fi
    
    log_step "Distribution détectée: $distro"
    
    # Installation selon la distribution
    case "$distro" in
        arch)
            log_step "Installation Flutter (Arch Linux) dans /opt/flutter..."
            
            # Vérifier les dépendances
            if ! command -v wget &>/dev/null; then
                log_warn "wget non trouvé, installation..."
                sudo pacman -S --noconfirm wget || {
                    log_error "Impossible d'installer wget"
                    return 1
                }
            fi
            
            # Télécharger et installer Flutter directement dans /opt/flutter
            log_step "Téléchargement de Flutter SDK..."
            cd /tmp
            local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"
            wget -q --show-progress "$flutter_url" -O flutter.tar.xz || {
                log_error "Échec du téléchargement de Flutter"
                return 1
            }
            
            log_step "Extraction dans /opt/flutter..."
            sudo mkdir -p /opt
            sudo tar -xf flutter.tar.xz -C /opt/ || {
                log_error "Échec de l'extraction"
                rm -f flutter.tar.xz
                return 1
            }
            
            # Configurer les permissions
            sudo chown -R "$USER:$USER" "$flutter_dir" || {
                log_warn "Impossible de changer le propriétaire, utilisation de sudo pour les permissions..."
            }
            
            rm -f flutter.tar.xz
            ;;
        debian|fedora)
            # Utiliser le script d'installation existant pour Debian/Fedora
            local flutter_script="$INSTALL_DIR/install_flutter.sh"
            if [ -f "$flutter_script" ]; then
                bash "$flutter_script" || {
                    log_error "Échec de l'installation de Flutter"
                    return 1
                }
            else
                log_error "Script d'installation non trouvé: $flutter_script"
                return 1
            fi
            ;;
        *)
            log_error "Distribution non supportée: $distro"
            log_info "Voir: https://docs.flutter.dev/get-started/install/linux"
            return 1
            ;;
    esac
    
    # Vérifier l'installation
    if [ -d "$flutter_bin" ] && [ -f "$flutter_bin/flutter" ]; then
        log_info "✓ Flutter installé dans $flutter_dir"
        
        # Ajouter au PATH dans env.sh
        add_path_to_env "$flutter_bin" "Flutter SDK"
        
        # Ajouter au PATH de la session actuelle
        if [[ ":$PATH:" != *":$flutter_bin:"* ]]; then
            export PATH="$flutter_bin:$PATH"
        fi
        
        # Exécuter flutter doctor
        log_step "Exécution de 'flutter doctor'..."
        "$flutter_bin/flutter" doctor || true
        
        log_info "✓ Flutter installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Flutter partout"
        return 0
    else
        log_error "Flutter n'a pas pu être installé correctement"
        log_info "Vérifiez les permissions sur /opt/flutter"
        return 1
    fi
}

# =============================================================================
# INSTALLATION DOTNET
# =============================================================================
install_dotnet() {
    log_step "Installation de .NET SDK..."
    
    local dotnet_script="$INSTALL_DIR/install_dotnet.sh"
    
    if [ ! -f "$dotnet_script" ]; then
        log_error "Script d'installation .NET introuvable: $dotnet_script"
        return 1
    fi
    
    bash "$dotnet_script" || {
        log_error "Échec de l'installation de .NET"
        return 1
    }
    
    # Ajouter .NET tools au PATH
    local dotnet_tools="$HOME/.dotnet/tools"
    if [ -d "$dotnet_tools" ]; then
        add_path_to_env "$dotnet_tools" ".NET Tools"
        log_info "✓ .NET installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser .NET"
        return 0
    fi
    
    return 1
}

# =============================================================================
# INSTALLATION EMCAS
# =============================================================================
install_emacs() {
    log_step "Installation d'Emacs et Doom Emacs..."
    
    local emacs_script="$INSTALL_DIR/install_emacs.sh"
    
    if [ ! -f "$emacs_script" ]; then
        log_error "Script d'installation Emacs introuvable: $emacs_script"
        return 1
    fi
    
    bash "$emacs_script" || {
        log_error "Échec de l'installation d'Emacs"
        return 1
    }
    
    # Ajouter Doom Emacs au PATH
    local doom_bin="$HOME/.emacs.d/bin"
    if [ -d "$doom_bin" ]; then
        add_path_to_env "$doom_bin" "Doom Emacs"
        log_info "✓ Emacs installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Doom Emacs"
        return 0
    fi
    
    return 1
}

# =============================================================================
# INSTALLATION JAVA 17
# =============================================================================
install_java17() {
    log_step "Installation de Java 17 OpenJDK..."
    
    local java_script="$INSTALL_DIR/install_java17.sh"
    
    if [ ! -f "$java_script" ]; then
        log_error "Script d'installation Java 17 introuvable: $java_script"
        return 1
    fi
    
    bash "$java_script" || {
        log_error "Échec de l'installation de Java 17"
        return 1
    }
    
    # Java est généralement installé dans /usr/lib/jvm/
    local java_path="/usr/lib/jvm/java-17-openjdk/bin"
    if [ -d "$java_path" ]; then
        add_path_to_env "$java_path" "Java 17 OpenJDK"
        log_info "✓ Java 17 installé et configuré avec succès!"
        log_info "💡 Rechargez votre shell (zshrc) pour utiliser Java 17"
        return 0
    fi
    
    return 1
}

# =============================================================================
# MENU INTERACTIF
# =============================================================================
show_menu() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Installation d'outils de développement     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}1.${NC} Flutter SDK"
    echo -e "${CYAN}2.${NC} .NET SDK"
    echo -e "${CYAN}3.${NC} Emacs + Doom Emacs"
    echo -e "${CYAN}4.${NC} Java 17 OpenJDK"
    echo ""
    echo -e "${YELLOW}0.${NC} Quitter"
    echo ""
    echo -n "Choisissez une option [0-4]: "
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================
install_tool() {
    local tool="$1"
    
    # Si aucun argument, afficher le menu
    if [ -z "$tool" ]; then
        while true; do
            show_menu
            read -r choice
            
            case "$choice" in
                1)
                    install_flutter
                    echo ""
                    echo -n "Appuyez sur Entrée pour continuer..."
                    read -r dummy
                    ;;
                2)
                    install_dotnet
                    echo ""
                    echo -n "Appuyez sur Entrée pour continuer..."
                    read -r dummy
                    ;;
                3)
                    install_emacs
                    echo ""
                    echo -n "Appuyez sur Entrée pour continuer..."
                    read -r dummy
                    ;;
                4)
                    install_java17
                    echo ""
                    echo -n "Appuyez sur Entrée pour continuer..."
                    read -r dummy
                    ;;
                0)
                    log_info "Au revoir!"
                    return 0
                    ;;
                *)
                    log_error "Option invalide: $choice"
                    sleep 1
                    ;;
            esac
        done
    else
        # Installation directe via argument
        case "$tool" in
            flutter|Flutter)
                install_flutter
                ;;
            dotnet|dot-net|.NET|net)
                install_dotnet
                ;;
            emacs|Emacs)
                install_emacs
                ;;
            java|java17|Java|Java17)
                install_java17
                ;;
            *)
                log_error "Outil inconnu: $tool"
                echo ""
                echo "Outils disponibles:"
                echo "  - flutter"
                echo "  - dotnet"
                echo "  - emacs"
                echo "  - java17"
                echo ""
                echo "Usage: install-tool [tool-name]"
                echo "   ou: install-tool (menu interactif)"
                return 1
                ;;
        esac
    fi
}

# Exporter la fonction
export -f install_tool 2>/dev/null || true

# Si appelé directement (pas source), exécuter la fonction
if [ "${(%):-%x}" = "${0}" ]; then
    install_tool "$@"
fi

