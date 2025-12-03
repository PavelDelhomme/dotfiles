#!/bin/bash
# =============================================================================
# SSH AUTO SETUP - Configuration automatique SSH avec mot de passe depuis .env
# =============================================================================
# Description: Configure automatiquement une connexion SSH en utilisant le mot de passe depuis .env
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Ne pas exécuter automatiquement si sourcé
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

if [ ! -t 0 ]; then
    echo "❌ Ce script nécessite un terminal interactif"
    return 1 2>/dev/null || exit 1
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY_ED25519="$SSH_DIR/id_ed25519"
ENV_FILE="$DOTFILES_DIR/.env"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Fonctions de logging
log_info() {
    echo -e "${BLUE}[→]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Charger .env si disponible
load_env() {
    if [ -f "$ENV_FILE" ]; then
        # Charger les variables depuis .env (sans exporter pour éviter les conflits)
        set -a
        source "$ENV_FILE" 2>/dev/null || true
        set +a
    fi
}

# Sauvegarder une variable dans .env
save_to_env() {
    local key="$1"
    local value="$2"
    
    # Créer .env s'il n'existe pas
    if [ ! -f "$ENV_FILE" ]; then
        touch "$ENV_FILE"
        chmod 600 "$ENV_FILE"
        echo "# Dotfiles Environment Variables" > "$ENV_FILE"
        echo "# Ce fichier contient des informations sensibles, ne pas commiter dans Git" >> "$ENV_FILE"
        echo "" >> "$ENV_FILE"
    fi
    
    # Vérifier si la variable existe déjà
    if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
        # Remplacer la valeur existante
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|^${key}=.*|${key}=\"${value}\"|" "$ENV_FILE"
        else
            # Linux
            sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$ENV_FILE"
        fi
    else
        # Ajouter la nouvelle variable
        echo "${key}=\"${value}\"" >> "$ENV_FILE"
    fi
    
    # S'assurer que .env est dans .gitignore
    if [ -f "$DOTFILES_DIR/.gitignore" ]; then
        if ! grep -q "^\.env$" "$DOTFILES_DIR/.gitignore" 2>/dev/null; then
            echo ".env" >> "$DOTFILES_DIR/.gitignore"
        fi
    fi
}

# Obtenir ou générer une clé SSH
get_ssh_key() {
    if [ -f "$SSH_KEY_ED25519" ]; then
        echo "$SSH_KEY_ED25519"
        return 0
    else
        log_info "Génération d'une nouvelle clé SSH ED25519..."
        local email
        load_env
        if [ -n "$GIT_USER_EMAIL" ]; then
            email="$GIT_USER_EMAIL"
        else
            email="$(whoami)@$(hostname)"
        fi
        
        ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY_ED25519" -N "" -q
        if [ $? -eq 0 ]; then
            log_success "Clé SSH générée: $SSH_KEY_ED25519"
            echo "$SSH_KEY_ED25519"
            return 0
        else
            log_error "Échec de la génération de la clé SSH"
            return 1
        fi
    fi
}

# Vérifier et installer sshpass si nécessaire
check_sshpass() {
    if ! command -v sshpass >/dev/null 2>&1; then
        log_info "Installation de sshpass (nécessaire pour l'automatisation)..."
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm sshpass 2>/dev/null || {
                log_error "Impossible d'installer sshpass"
                return 1
            }
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update -qq && sudo apt install -y sshpass 2>/dev/null || {
                log_error "Impossible d'installer sshpass"
                return 1
            }
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y sshpass 2>/dev/null || {
                log_error "Impossible d'installer sshpass"
                return 1
            }
        else
            log_error "Gestionnaire de paquets non supporté pour installer sshpass"
            return 1
        fi
        log_success "sshpass installé"
    fi
}

# Copier la clé publique avec le mot de passe
copy_ssh_key_with_password() {
    local user="$1"
    local host_ip="$2"
    local port="${3:-22}"
    local key_path="$4"
    local password="$5"
    
    if [ ! -f "${key_path}.pub" ]; then
        log_error "Clé publique introuvable: ${key_path}.pub"
        return 1
    fi
    
    log_info "Copie de la clé publique sur le serveur avec le mot de passe..."
    
    # Utiliser sshpass pour automatiser la copie
    if command -v sshpass >/dev/null 2>&1; then
        # Méthode 1: Utiliser sshpass avec ssh-copy-id
        if sshpass -p "$password" ssh-copy-id -i "${key_path}.pub" -p "$port" -o StrictHostKeyChecking=no "$user@$host_ip" 2>/dev/null; then
            log_success "Clé publique copiée avec succès!"
            return 0
        fi
        
        # Méthode 2: Copie manuelle avec sshpass
        local pub_key_content
        pub_key_content=$(cat "${key_path}.pub")
        
        if sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no "$user@$host_ip" \
            "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pub_key_content' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>/dev/null; then
            log_success "Clé publique copiée avec succès!"
            return 0
        else
            log_error "Échec de la copie de la clé publique"
            return 1
        fi
    else
        log_error "sshpass n'est pas disponible"
        log_info "Installation de sshpass..."
        if check_sshpass; then
            # Réessayer après installation
            return copy_ssh_key_with_password "$user" "$host_ip" "$port" "$key_path" "$password"
        else
            return 1
        fi
    fi
}

# Ajouter l'entrée dans ~/.ssh/config
add_ssh_config_entry() {
    local host_name="$1"
    local host_ip="$2"
    local user="$3"
    local port="${4:-22}"
    local key_path="$5"
    
    # Créer le répertoire .ssh s'il n'existe pas
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    # Vérifier si l'entrée existe déjà
    if grep -q "^Host $host_name" "$SSH_CONFIG" 2>/dev/null; then
        log_warn "L'entrée SSH pour '$host_name' existe déjà"
        read -p "Voulez-vous la remplacer ? (o/N): " replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            log_info "Configuration SSH conservée"
            return 0
        fi
        # Supprimer l'ancienne entrée
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^Host $host_name/,/^$/d" "$SSH_CONFIG" 2>/dev/null || true
        else
            sed -i "/^Host $host_name/,/^$/d" "$SSH_CONFIG" 2>/dev/null || true
        fi
    fi
    
    # Créer le fichier config s'il n'existe pas
    if [ ! -f "$SSH_CONFIG" ]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi
    
    # Ajouter la nouvelle entrée
    {
        echo ""
        echo "Host $host_name"
        echo "    HostName $host_ip"
        echo "    User $user"
        echo "    Port $port"
        echo "    IdentityFile $key_path"
        echo "    IdentitiesOnly yes"
        echo "    ServerAliveInterval 60"
        echo "    ServerAliveCountMax 3"
    } >> "$SSH_CONFIG"
    
    log_success "Configuration SSH ajoutée pour '$host_name' dans $SSH_CONFIG"
}

# Fonction principale de configuration automatique
auto_setup_ssh() {
    local host_name="${1:-pavel-server}"
    local host_ip="${2:-95.111.227.204}"
    local user="${3:-pavel}"
    local port="${4:-22}"
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         CONFIGURATION SSH AUTOMATIQUE AVEC MOT DE PASSE        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    log_info "Configuration automatique SSH pour: $user@$host_ip"
    echo ""
    
    # Charger .env
    load_env
    
    # Obtenir le mot de passe depuis .env ou demander
    local password
    local env_key="SSH_PASSWORD_${host_name//[^a-zA-Z0-9]/_}"
    
    if [ -n "${!env_key}" ]; then
        log_info "Mot de passe trouvé dans .env"
        password="${!env_key}"
    else
        # Demander le mot de passe
        printf "Mot de passe SSH pour $user@$host_ip: "
        read -s password
        echo ""
        
        if [ -z "$password" ]; then
            log_error "Le mot de passe est obligatoire"
            return 1
        fi
        
        # Sauvegarder dans .env
        log_info "Sauvegarde du mot de passe dans .env..."
        save_to_env "$env_key" "$password"
        log_success "Mot de passe sauvegardé dans .env (ne sera pas commité)"
    fi
    
    echo ""
    
    # Obtenir ou générer la clé SSH
    log_info "Récupération ou génération de la clé SSH..."
    local key_path
    key_path=$(get_ssh_key)
    if [ $? -ne 0 ] || [ -z "$key_path" ]; then
        log_error "Impossible d'obtenir une clé SSH"
        return 1
    fi
    
    log_success "Clé SSH: $key_path"
    echo ""
    
    # Vérifier sshpass
    log_info "Vérification de sshpass..."
    if ! check_sshpass; then
        log_error "Impossible d'installer sshpass, configuration manuelle requise"
        return 1
    fi
    echo ""
    
    # Ajouter l'entrée dans ~/.ssh/config
    log_info "Configuration de ~/.ssh/config..."
    add_ssh_config_entry "$host_name" "$host_ip" "$user" "$port" "$key_path"
    echo ""
    
    # Copier la clé publique avec le mot de passe
    log_info "Copie de la clé publique sur le serveur..."
    if copy_ssh_key_with_password "$user" "$host_ip" "$port" "$key_path" "$password"; then
        echo ""
        # Tester la connexion
        log_info "Test de la connexion SSH..."
        if ssh -o ConnectTimeout=5 -o BatchMode=yes "$host_name" "echo 'Connexion SSH réussie!'" 2>/dev/null; then
            log_success "Connexion SSH réussie! Vous pouvez maintenant vous connecter avec: ssh $host_name"
            return 0
        else
            log_warn "La connexion automatique a échoué, mais la configuration est en place"
            log_info "Essayez de vous connecter manuellement: ssh $host_name"
            return 1
        fi
    else
        log_error "Échec de la configuration SSH"
        return 1
    fi
}

# Si le script est exécuté directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Utiliser les arguments ou valeurs par défaut
    auto_setup_ssh "$@"
fi

