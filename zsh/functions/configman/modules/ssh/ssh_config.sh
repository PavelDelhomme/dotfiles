#!/bin/bash

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'configman ssh'
# Il ne doit JAMAIS être sourcé ou exécuté automatiquement au chargement de zshrc

# Vérifier si on est dans un terminal interactif
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

if [ ! -t 0 ]; then
    echo "❌ Ce script nécessite un terminal interactif"
    return 1 2>/dev/null || exit 1
fi

################################################################################
# Configuration SSH automatique
# Génère une clé SSH si nécessaire, configure ~/.ssh/config et copie la clé
################################################################################

DOTFILES_DIR="$HOME/dotfiles"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY_ED25519="$SSH_DIR/id_ed25519"
SSH_KEY_RSA="$SSH_DIR/id_rsa"

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

# Créer le répertoire .ssh s'il n'existe pas
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Fonction pour générer une clé SSH
generate_ssh_key() {
    local key_type="$1"
    local key_path="$2"
    local email="$3"
    
    if [ -f "$key_path" ]; then
        log_warn "Clé SSH $key_type existe déjà: $key_path"
        read -p "Voulez-vous la régénérer ? (o/N): " regenerate
        if [[ ! "$regenerate" =~ ^[oO]$ ]]; then
            return 0
        fi
        mv "$key_path" "${key_path}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        if [ -f "${key_path}.pub" ]; then
            mv "${key_path}.pub" "${key_path}.pub.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        fi
    fi
    
    log_info "Génération de la clé SSH $key_type..."
    if [ "$key_type" = "ED25519" ]; then
        ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N "" -q
    else
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N "" -q
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Clé SSH $key_type générée: $key_path"
        return 0
    else
        log_error "Échec de la génération de la clé SSH"
        return 1
    fi
}

# Fonction pour obtenir ou générer une clé SSH
get_ssh_key() {
    # Préférer ED25519 (plus moderne et sécurisé)
    if [ -f "$SSH_KEY_ED25519" ]; then
        echo "$SSH_KEY_ED25519"
        return 0
    elif [ -f "$SSH_KEY_RSA" ]; then
        echo "$SSH_KEY_RSA"
        return 0
    else
        # Générer une nouvelle clé ED25519
        local email
        if [ -f "$DOTFILES_DIR/.env" ]; then
            source "$DOTFILES_DIR/.env" 2>/dev/null || true
        fi
        
        if [ -z "$GIT_USER_EMAIL" ]; then
            printf "Email pour la clé SSH (optionnel, appuyez sur Entrée pour ignorer): "
            read -r email
        else
            email="$GIT_USER_EMAIL"
            log_info "Utilisation de l'email Git: $email"
        fi
        
        if [ -z "$email" ]; then
            email="$(whoami)@$(hostname)"
        fi
        
        if generate_ssh_key "ED25519" "$SSH_KEY_ED25519" "$email"; then
            echo "$SSH_KEY_ED25519"
            return 0
        else
            log_error "Impossible de générer une clé SSH"
            return 1
        fi
    fi
}

# Fonction pour ajouter une entrée dans ~/.ssh/config
add_ssh_config_entry() {
    local host_name="$1"
    local host_ip="$2"
    local user="$3"
    local port="${4:-22}"
    local key_path="$5"
    
    # Vérifier si l'entrée existe déjà
    if grep -q "^Host $host_name" "$SSH_CONFIG" 2>/dev/null; then
        log_warn "L'entrée SSH pour '$host_name' existe déjà dans $SSH_CONFIG"
        read -p "Voulez-vous la remplacer ? (o/N): " replace
        if [[ ! "$replace" =~ ^[oO]$ ]]; then
            log_info "Configuration SSH conservée"
            return 0
        fi
        # Supprimer l'ancienne entrée
        sed -i "/^Host $host_name/,/^$/d" "$SSH_CONFIG" 2>/dev/null || true
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

# Fonction pour copier la clé publique sur le serveur
copy_ssh_key() {
    local host_name="$1"
    local user="$2"
    local host_ip="$3"
    local port="${4:-22}"
    local key_path="$5"
    
    if [ ! -f "${key_path}.pub" ]; then
        log_error "Clé publique introuvable: ${key_path}.pub"
        return 1
    fi
    
    log_info "Copie de la clé publique sur le serveur..."
    log_info "Vous devrez entrer le mot de passe du serveur (une seule fois)"
    echo ""
    
    # Vérifier si ssh-copy-id est disponible
    if ! command -v ssh-copy-id >/dev/null 2>&1; then
        log_warn "ssh-copy-id n'est pas disponible, utilisation de la méthode manuelle"
        log_info "Exécution de la commande manuelle..."
        
        # Méthode manuelle: copier la clé via ssh
        local pub_key_content
        pub_key_content=$(cat "${key_path}.pub")
        
        if ssh -p "$port" "$user@$host_ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pub_key_content' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2>&1; then
            log_success "Clé publique copiée sur le serveur avec succès!"
            return 0
        else
            log_error "Échec de la copie de la clé publique"
            log_info "Vous pouvez essayer manuellement:"
            log_info "  cat ${key_path}.pub | ssh -p $port $user@$host_ip 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
            return 1
        fi
    else
        # Utiliser ssh-copy-id avec le port spécifié
        if ssh-copy-id -i "${key_path}.pub" -p "$port" "$user@$host_ip" 2>&1; then
            log_success "Clé publique copiée sur le serveur avec succès!"
            return 0
        else
            log_error "Échec de la copie de la clé publique"
            log_info "Vous pouvez essayer manuellement:"
            log_info "  ssh-copy-id -i ${key_path}.pub -p $port $user@$host_ip"
            return 1
        fi
    fi
}

# Fonction pour tester la connexion SSH
test_ssh_connection() {
    local host_name="$1"
    
    log_info "Test de la connexion SSH vers '$host_name'..."
    
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$host_name" "echo 'Connexion SSH réussie!'" 2>/dev/null; then
        log_success "Connexion SSH réussie! Vous pouvez maintenant vous connecter avec: ssh $host_name"
        return 0
    else
        log_warn "La connexion automatique a échoué, mais la configuration est en place"
        log_info "Essayez de vous connecter manuellement: ssh $host_name"
        return 1
    fi
}

# Menu principal
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              CONFIGURATION SSH AUTOMATIQUE                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Fonction principale de configuration
configure_ssh() {
    show_menu
    
    log_info "Configuration d'une nouvelle connexion SSH"
    echo ""
    
    # Demander les informations du serveur
    printf "Nom du serveur (alias SSH, ex: myserver): "
    read -r host_name
    if [ -z "$host_name" ]; then
        log_error "Le nom du serveur est obligatoire"
        return 1
    fi
    
    printf "Adresse IP ou hostname du serveur (ex: 95.111.227.204): "
    read -r host_ip
    if [ -z "$host_ip" ]; then
        log_error "L'adresse IP/hostname est obligatoire"
        return 1
    fi
    
    printf "Nom d'utilisateur sur le serveur (ex: pavel) [défaut: $(whoami)]: "
    read -r user
    if [ -z "$user" ]; then
        user="$(whoami)"
    fi
    
    printf "Port SSH [défaut: 22]: "
    read -r port
    if [ -z "$port" ]; then
        port="22"
    fi
    
    echo ""
    log_info "Récupération ou génération de la clé SSH..."
    
    # Obtenir ou générer une clé SSH
    local key_path
    key_path=$(get_ssh_key)
    if [ $? -ne 0 ] || [ -z "$key_path" ]; then
        log_error "Impossible d'obtenir une clé SSH"
        return 1
    fi
    
    log_success "Clé SSH: $key_path"
    echo ""
    
    # Ajouter l'entrée dans ~/.ssh/config
    log_info "Configuration de ~/.ssh/config..."
    add_ssh_config_entry "$host_name" "$host_ip" "$user" "$port" "$key_path"
    echo ""
    
    # Copier la clé publique sur le serveur
    log_info "Copie de la clé publique sur le serveur..."
    copy_ssh_key "$host_name" "$user" "$host_ip" "$port" "$key_path"
    echo ""
    
    # Tester la connexion
    test_ssh_connection "$host_name"
    echo ""
    
    log_success "Configuration SSH terminée!"
    log_info "Vous pouvez maintenant vous connecter avec: ${GREEN}ssh $host_name${NC}"
}

# Exécuter la configuration
configure_ssh

