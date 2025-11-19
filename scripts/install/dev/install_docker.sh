#!/bin/bash

################################################################################
# Installation Docker & Docker Compose
# Support: Arch Linux, Debian/Ubuntu, Fedora
################################################################################

set +e  # Ne pas arrêter sur erreurs pour mieux gérer les interruptions

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

# Gestion des interruptions (Ctrl+C)
trap 'log_warn "Installation interrompue par l'\''utilisateur"; exit 130' INT TERM

DESKTOP_ONLY=false

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --desktop-only) DESKTOP_ONLY=true; shift ;;
        *) echo "Option inconnue: $1"; exit 1 ;;
    esac
done

################################################################################
# DÉTECTION DE LA DISTRIBUTION
################################################################################
detect_distro() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

################################################################################
# ÉTAPE 1: Vérification installation existante
################################################################################
if [ "$DESKTOP_ONLY" = false ]; then
    log_section "Installation Docker & Docker Compose"

    if command -v docker &> /dev/null; then
        CURRENT_VERSION=$(docker --version)
        log_warn "Docker déjà installé: $CURRENT_VERSION"
        read -p "Réinstaller/mettre à jour? (o/n): " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[oO]$ ]]; then
            log_info "Installation annulée"
            exit 0
        fi
    fi

    ################################################################################
    # ÉTAPE 2: Installation Docker selon la distro
    ################################################################################
    log_section "Installation Docker"

    case "$DISTRO" in
        arch)
            log_info "Installation via pacman (Arch Linux)..."
            sudo pacman -S --noconfirm docker docker-compose
            ;;
        debian)
            log_info "Installation via script officiel Docker (Debian/Ubuntu)..."
            # Installation des dépendances
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg lsb-release
            # Ajouter la clé GPG Docker
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            # Ajouter le repo Docker
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            # Installer Docker
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        fedora)
            log_info "Installation via dnf (Fedora)..."
            sudo dnf install -y dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        *)
            log_error "Distribution non supportée. Installation manuelle requise."
            log_info "Visitez: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    log_info "✓ Docker installé"

    ################################################################################
    # ÉTAPE 3: Activation et démarrage du service
    ################################################################################
    log_section "Configuration du service Docker"

    log_info "Activation du service Docker..."
    sudo systemctl enable docker
    
    # Démarrer le service et vérifier qu'il fonctionne
    if sudo systemctl start docker; then
        # Attendre un peu pour que le service démarre
        sleep 2
        
        # Vérifier que le service est actif
        if sudo systemctl is-active --quiet docker; then
            log_info "✓ Service Docker activé et démarré"
        else
            log_warn "⚠️ Service Docker activé mais ne démarre pas"
            log_warn "Vérifiez avec: sudo systemctl status docker"
            log_warn "Ou redémarrez le système"
        fi
    else
        log_error "✗ Échec démarrage du service Docker"
        log_warn "Vérifiez avec: sudo systemctl status docker"
        log_warn "Ou redémarrez le système"
    fi

    ################################################################################
    # ÉTAPE 4: Ajout de l'utilisateur au groupe docker
    ################################################################################
    log_info "Ajout de l'utilisateur au groupe docker..."
    sudo usermod -aG docker "$USER"
    log_info "✓ Utilisateur ajouté au groupe docker"
    
    # Proposer de redémarrer la session
    echo ""
    log_warn "⚠️  IMPORTANT : Le groupe docker nécessite une nouvelle session"
    printf "Voulez-vous redémarrer votre session maintenant? (o/n) [défaut: n]: "
    read -r restart_session
    restart_session=${restart_session:-n}
    
    if [[ "$restart_session" =~ ^[oO]$ ]]; then
        log_info "Redémarrage de la session..."
        # Essayer différentes méthodes selon l'environnement
        if [ -n "$DISPLAY" ] && command -v gnome-session-quit &> /dev/null; then
            # GNOME
            gnome-session-quit --logout --no-prompt 2>/dev/null &
        elif [ -n "$DISPLAY" ] && command -v xfce4-session-logout &> /dev/null; then
            # XFCE
            xfce4-session-logout --logout 2>/dev/null &
        elif [ -n "$DISPLAY" ] && command -v mate-session-save &> /dev/null; then
            # MATE
            mate-session-save --logout 2>/dev/null &
        else
            # Fallback : utiliser newgrp pour recharger les groupes
            log_info "Utilisation de newgrp pour recharger les groupes..."
            log_warn "Si cela ne fonctionne pas, déconnectez-vous manuellement"
            exec newgrp docker
        fi
    else
        log_warn "⚠️  Déconnectez-vous et reconnectez-vous manuellement pour que le groupe docker soit actif"
        log_warn "   Ou utilisez 'newgrp docker' pour recharger les groupes dans cette session"
    fi

    ################################################################################
    # ÉTAPE 5: Test de l'installation
    ################################################################################
    log_section "Test de l'installation"

    # Utiliser sudo pour le test si l'utilisateur n'est pas encore dans le groupe
    if sudo docker --version &> /dev/null; then
        log_info "✓ Docker fonctionne"
        sudo docker --version
    else
        log_error "✗ Erreur lors du test Docker"
        exit 1
    fi

    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        log_info "✓ Docker Compose fonctionne"
        docker-compose --version 2>/dev/null || docker compose version
    else
        log_error "✗ Docker Compose non trouvé"
    fi
fi

################################################################################
# ÉTAPE 6: Installation Docker Desktop (OPTIONNEL)
################################################################################
if [ "$DESKTOP_ONLY" = true ] || [ "$DESKTOP_ONLY" = false ]; then
    log_section "Installation Docker Desktop (optionnel)"

    read -p "Installer Docker Desktop? (o/n): " install_desktop
    if [[ "$install_desktop" =~ ^[oO]$ ]]; then
        case "$DISTRO" in
            arch)
                if command -v yay &> /dev/null; then
                    log_info "Installation via yay (Arch Linux)..."
                    if yay -S docker-desktop --noconfirm; then
                        log_info "✓ Docker Desktop installé"
                    else
                        log_error "Échec installation Docker Desktop"
                        log_warn "Installez manuellement: yay -S docker-desktop"
                    fi
                else
                    log_warn "yay non installé. Installez-le d'abord (option 18 du menu)"
                    log_info "Lien: https://aur.archlinux.org/packages/docker-desktop"
                    log_info "Ou installez yay d'abord puis réessayez"
                    exit 1
                fi
                ;;
            debian)
                log_info "Téléchargement du paquet .deb..."
                wget -O /tmp/docker-desktop.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-*.deb" || {
                    log_error "Échec du téléchargement"
                    log_info "Téléchargez manuellement depuis: https://www.docker.com/products/docker-desktop/"
                    exit 1
                }
                sudo apt install -y /tmp/docker-desktop.deb
                rm /tmp/docker-desktop.deb
                ;;
            fedora)
                log_info "Téléchargement du paquet .rpm..."
                wget -O /tmp/docker-desktop.rpm "https://desktop.docker.com/linux/main/amd64/docker-desktop-*.rpm" || {
                    log_error "Échec du téléchargement"
                    log_info "Téléchargez manuellement depuis: https://www.docker.com/products/docker-desktop/"
                    exit 1
                }
                sudo dnf install -y /tmp/docker-desktop.rpm
                rm /tmp/docker-desktop.rpm
                ;;
            *)
                log_warn "Installation manuelle requise pour cette distribution"
                log_info "Visitez: https://www.docker.com/products/docker-desktop/"
                ;;
        esac

        log_info "✓ Docker Desktop installé"
        log_info "Lancement de Docker Desktop..."
        docker-desktop &> /dev/null &
        log_info "Attente du démarrage de Docker Desktop..."
        sleep 5
    else
        log_info "Installation Docker Desktop ignorée"
    fi
fi

################################################################################
# ÉTAPE 7: Login Docker Hub avec 2FA
################################################################################
if [ "$DESKTOP_ONLY" = false ]; then
    log_section "Connexion Docker Hub (optionnel)"

    read -p "Se connecter à Docker Hub? (o/n): " login_choice
    if [[ "$login_choice" =~ ^[oO]$ ]]; then
        log_warn "Si 2FA est activé, utilisez un Personal Access Token"
        log_info "Générez un token: https://hub.docker.com/settings/security"
        printf "Appuyez sur Entrée pour lancer docker login... "
        read -r dummy
        
        # Utiliser sudo si nécessaire
        # Gérer l'interruption (Ctrl+C) pendant docker login
        if sudo docker login 2>&1; then
            log_info "✓ Connexion réussie"
            
            # Test avec hello-world (seulement si le daemon Docker fonctionne)
            if sudo docker ps &>/dev/null; then
                log_info "Test avec hello-world..."
                if sudo docker run hello-world; then
                    log_info "✅ Docker configuré et connecté"
                else
                    log_warn "⚠️ Test hello-world échoué (peut-être normal si pas de connexion)"
                fi
            else
                log_warn "⚠️ Docker daemon non accessible"
                log_warn "Le service Docker doit être redémarré ou vous devez vous reconnecter"
            fi
        else
            log_warn "⚠️ Connexion échouée ou annulée"
        fi
    else
        log_info "Connexion Docker Hub ignorée"
    fi
fi

################################################################################
# ÉTAPE 8: Configuration BuildKit
################################################################################
if [ "$DESKTOP_ONLY" = false ]; then
    log_section "Configuration BuildKit"

    DOCKER_DAEMON_JSON="$HOME/.docker/daemon.json"
    mkdir -p "$HOME/.docker"

    log_info "Création/modification de ~/.docker/daemon.json..."
    
    if [ -f "$DOCKER_DAEMON_JSON" ]; then
        log_warn "Fichier daemon.json existe déjà, sauvegarde..."
        cp "$DOCKER_DAEMON_JSON" "$DOCKER_DAEMON_JSON.bak"
    fi

    cat > "$DOCKER_DAEMON_JSON" <<EOF
{
  "features": {
    "buildkit": true
  }
}
EOF

    log_info "✓ BuildKit activé dans daemon.json"

    # Redémarrer Docker si le service est actif
    if sudo systemctl is-active --quiet docker 2>/dev/null; then
        log_info "Redémarrage du service Docker..."
        if sudo systemctl restart docker 2>/dev/null; then
            sleep 1
            if sudo systemctl is-active --quiet docker 2>/dev/null; then
                log_info "✓ Docker redémarré"
            else
                log_warn "⚠️ Docker redémarré mais service non actif"
                log_warn "Vérifiez avec: sudo systemctl status docker"
            fi
        else
            log_warn "⚠️ Échec redémarrage Docker"
            log_warn "Vérifiez avec: sudo systemctl status docker"
        fi
    else
        log_warn "⚠️ Service Docker non actif, pas de redémarrage nécessaire"
    fi
fi

################################################################################
# RÉSUMÉ
################################################################################
log_section "Installation terminée!"

echo ""
log_info "Docker installé et configuré"
echo ""
log_warn "⚠️ IMPORTANT: Déconnectez-vous et reconnectez-vous pour que le groupe docker soit actif"
echo ""
log_info "Commandes utiles:"
echo "  docker --version              # Vérifier la version"
echo "  docker ps                      # Lister les conteneurs"
echo "  docker run hello-world         # Tester Docker"
echo "  docker-compose up              # Lancer avec docker-compose"
echo "  docker compose up              # Lancer avec docker compose (plugin)"
echo ""
