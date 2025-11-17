#!/bin/bash

################################################################################
# Bootstrap Script - Installation dotfiles sans configuration Git préalable
# Usage: curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_section() { echo -e "\n${BLUE}═══════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}═══════════════════════════════════${NC}"; }

################################################################################
# CONFIGURATION PAR DÉFAUT (Pactivisme)
################################################################################
DEFAULT_GIT_NAME="Pactivisme"
DEFAULT_GIT_EMAIL="dev@delhomme.ovh"
DOTFILES_REPO="https://github.com/PavelDelhomme/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

log_section "Bootstrap Installation - Dotfiles Pactivisme"

################################################################################
# 1. VÉRIFIER ET INSTALLER GIT
################################################################################
if ! command -v git >/dev/null 2>&1; then
    log_info "Git non trouvé, installation..."
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm git
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y git
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git
    else
        log_error "Gestionnaire de paquets non supporté"
        exit 1
    fi
    log_info "✓ Git installé"
else
    log_info "✓ Git déjà présent"
fi

################################################################################
# 2. CONFIGURATION GIT GLOBALE
################################################################################
log_section "Configuration Git globale"

# Configuration par défaut (compte perso)
DEFAULT_GIT_NAME="PavelDelhomme"
DEFAULT_GIT_EMAIL="dev@delhomme.ovh"

# Demander confirmation ou utiliser les valeurs par défaut
printf "Nom Git (défaut: %s): " "$DEFAULT_GIT_NAME"
IFS= read -r git_name </dev/tty 2>/dev/null || read -r git_name

# Utiliser la valeur par défaut si vide
if [ -z "$git_name" ]; then
    git_name="$DEFAULT_GIT_NAME"
fi

printf "Email Git (défaut: %s): " "$DEFAULT_GIT_EMAIL"
IFS= read -r git_email </dev/tty 2>/dev/null || read -r git_email

# Utiliser la valeur par défaut si vide
if [ -z "$git_email" ]; then
    git_email="$DEFAULT_GIT_EMAIL"
fi

# Vérifier que git_email est bien défini (sécurité)
if [ -z "$git_email" ] || [[ "$git_email" == *"\$"* ]] || [[ "$git_email" == *"DEFAULT"* ]] || [[ "$git_email" == *"git_email"* ]]; then
    git_email="$DEFAULT_GIT_EMAIL"
    log_warn "Email invalide détecté, utilisation de la valeur par défaut"
fi

# Vérifier que git_name est bien défini
if [ -z "$git_name" ] || [[ "$git_name" == *"\$"* ]] || [[ "$git_name" == *"DEFAULT"* ]] || [[ "$git_name" == *"git_name"* ]]; then
    git_name="$DEFAULT_GIT_NAME"
    log_warn "Nom invalide détecté, utilisation de la valeur par défaut"
fi

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global color.ui auto

log_info "✓ Git configuré: $git_name <$git_email>"

################################################################################
# 2.1. CONFIGURATION CREDENTIAL HELPER
################################################################################
log_section "Configuration credential helper"

if [ -z "$(git config --global credential.helper)" ]; then
    log_info "Configuration du credential helper (cache)..."
    git config --global credential.helper cache
    log_info "✓ Credentials stockés en cache (15min)"
else
    log_info "✓ Credential helper déjà configuré: $(git config --global credential.helper)"
fi

################################################################################
# 2.2. GÉNÉRATION CLÉ SSH (si absente)
################################################################################
log_section "Configuration SSH pour GitHub"

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$SSH_KEY.pub"

if [ ! -f "$SSH_KEY" ]; then
    log_info "Génération de la clé SSH ED25519..."
    
    # S'assurer que git_email contient bien la valeur réelle
    # Si git_email contient encore des variables non résolues, utiliser la valeur par défaut
    if [ -z "$git_email" ] || [[ "$git_email" == *"\$"* ]] || [[ "$git_email" == *"DEFAULT"* ]] || [[ "$git_email" == *"git_email"* ]]; then
        git_email="dev@delhomme.ovh"
        log_warn "Email invalide détecté, utilisation de la valeur par défaut pour la clé SSH"
    fi
    
    # Générer la clé avec l'email correct (vérifier une dernière fois)
    SSH_EMAIL="$git_email"
    if [ -z "$SSH_EMAIL" ]; then
        SSH_EMAIL="dev@delhomme.ovh"
    fi
    
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY" -N "" 2>/dev/null
    log_info "✓ Clé SSH générée: $SSH_KEY (email: $SSH_EMAIL)"
    
    # Démarrer ssh-agent
    log_info "Démarrage de ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
    
    # Ajouter la clé
    ssh-add "$SSH_KEY" 2>/dev/null || log_warn "Impossible d'ajouter la clé au ssh-agent"
    log_info "✓ Clé ajoutée au ssh-agent"
    
    # Copier la clé publique dans le presse-papier
    if [ -f "$SSH_PUB_KEY" ]; then
        # Lire uniquement la première ligne (la clé SSH complète)
        SSH_KEY_CONTENT=$(head -n1 "$SSH_PUB_KEY" 2>/dev/null)
        
        if [ -n "$SSH_KEY_CONTENT" ]; then
            if command -v xclip &> /dev/null; then
                echo -n "$SSH_KEY_CONTENT" | xclip -selection clipboard 2>/dev/null
                log_info "✓ Clé publique copiée dans le presse-papier (xclip)"
            elif command -v wl-copy &> /dev/null; then
                echo -n "$SSH_KEY_CONTENT" | wl-copy 2>/dev/null
                log_info "✓ Clé publique copiée dans le presse-papier (wl-copy)"
            else
                log_warn "xclip/wl-copy non disponible, affichage de la clé:"
                echo "$SSH_KEY_CONTENT"
            fi
        else
            log_error "Impossible de lire la clé publique"
        fi
    else
        log_error "Fichier clé publique non trouvé: $SSH_PUB_KEY"
    fi
    
    log_warn "⚠️ Ajoutez cette clé SSH sur GitHub:"
    log_info "URL: https://github.com/settings/keys"
    
    # Ouvrir automatiquement GitHub
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://github.com/settings/keys" 2>/dev/null || true
    fi
    
    printf "\nAppuyez sur Entrée après avoir ajouté la clé sur GitHub... "
    read -r dummy
    
    # Tester la connexion
    log_info "Test de la connexion GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "✅ Connexion GitHub OK"
    else
        log_warn "⚠️ Connexion GitHub non vérifiée (peut être normal si clé non encore ajoutée)"
        log_info "Testez manuellement avec: ssh -T git@github.com"
    fi
else
    log_info "✓ Clé SSH déjà présente: $SSH_KEY"
    
    # Tester la connexion existante
    log_info "Test de la connexion GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "✅ Connexion GitHub OK"
    else
        log_warn "⚠️ Connexion GitHub échouée, vérifiez la clé SSH"
    fi
fi

################################################################################
# 3. CLONER LE REPO DOTFILES
################################################################################
log_section "Clonage du repo dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    log_warn "Dossier $DOTFILES_DIR existe déjà"
    printf "Supprimer et re-cloner? (o/n) [défaut: n]: "
    IFS= read -r delete_choice </dev/tty 2>/dev/null || read -r delete_choice
    delete_choice=${delete_choice:-n}
    if [[ "$delete_choice" =~ ^[oO]$ ]]; then
        rm -rf "$DOTFILES_DIR"
        log_info "Dossier supprimé"
    else
        log_info "Utilisation du dossier existant"
        cd "$DOTFILES_DIR" 2>/dev/null || {
            log_warn "Impossible d'accéder au dossier, clonage dans un nouveau..."
            rm -rf "$DOTFILES_DIR"
        }
        if [ -d "$DOTFILES_DIR" ]; then
            cd "$DOTFILES_DIR"
            git pull origin main || git pull origin master || true
            cd ~
        fi
    fi
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Clonage de $DOTFILES_REPO..."
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>&1; then
        log_info "✓ Dotfiles clonés"
    else
        log_error "Erreur lors du clonage des dotfiles"
        log_warn "Vérifiez votre connexion internet et réessayez"
        exit 1
    fi
else
    log_info "✓ Dossier dotfiles existe déjà"
fi

################################################################################
# 4. CRÉER LES SYMLINKS (CENTRALISATION CONFIGURATION)
################################################################################
log_section "Création des symlinks pour centraliser la configuration"

if [ -f "$DOTFILES_DIR/scripts/config/create_symlinks.sh" ]; then
    printf "Créer les symlinks pour centraliser la configuration? (o/n) [défaut: o]: "
    IFS= read -r create_symlinks </dev/tty 2>/dev/null || read -r create_symlinks
    create_symlinks=${create_symlinks:-o}
    if [[ "$create_symlinks" =~ ^[oO]$ ]]; then
        log_info "Création des symlinks..."
        bash "$DOTFILES_DIR/scripts/config/create_symlinks.sh"
    else
        log_warn "Création des symlinks ignorée"
    fi
else
    log_warn "Script create_symlinks.sh non trouvé"
fi

################################################################################
# 5. PROPOSER UTILISATION MAKEFILE (recommandé)
################################################################################
log_section "Installation des dotfiles"

if [ -d "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/Makefile" ]; then
    log_info "✅ Dotfiles clonés avec succès dans: $DOTFILES_DIR"
    echo ""
    log_info "Pour continuer l'installation, utilisez le Makefile (recommandé):"
    echo ""
    echo "  cd ~/dotfiles"
    echo "  make install          # Installation complète"
    echo "  make setup            # Menu interactif"
    echo "  make help             # Voir toutes les commandes"
    echo ""
    printf "Voulez-vous lancer l'installation maintenant? (o/n) [défaut: o]: "
    IFS= read -r launch_install </dev/tty 2>/dev/null || read -r launch_install
    launch_install=${launch_install:-o}
    
    if [[ "$launch_install" =~ ^[oO]$ ]]; then
        cd "$DOTFILES_DIR" || {
            log_error "Impossible de se déplacer dans $DOTFILES_DIR"
            exit 1
        }
        
        echo ""
        log_info "Méthodes disponibles:"
        echo "  1. make install    - Installation complète (bootstrap complet)"
        echo "  2. make setup      - Menu interactif (recommandé)"
        echo "  3. bash setup.sh   - Menu interactif (alternative)"
        echo ""
        printf "Choisir une méthode (1/2/3) [défaut: 2]: "
        IFS= read -r method_choice </dev/tty 2>/dev/null || read -r method_choice
        method_choice=${method_choice:-2}
        
        case "$method_choice" in
            1)
                log_info "Lancement: make install"
                if command -v make &> /dev/null; then
                    make install
                else
                    log_warn "make non disponible, utilisation de bootstrap.sh directement"
                    bash "$DOTFILES_DIR/bootstrap.sh"
                fi
                ;;
            2)
                log_info "Lancement: make setup"
                if command -v make &> /dev/null; then
                    make setup
                else
                    log_warn "make non disponible, utilisation de setup.sh directement"
                    bash "$DOTFILES_DIR/setup.sh"
                fi
                ;;
            3)
                log_info "Lancement: bash setup.sh"
                bash "$DOTFILES_DIR/setup.sh"
                ;;
            *)
                log_warn "Choix invalide, utilisation de make setup par défaut"
                if command -v make &> /dev/null; then
                    make setup
                else
                    bash "$DOTFILES_DIR/setup.sh"
                fi
                ;;
        esac
        
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
            log_info "Installation terminée, au revoir!"
            exit 0
        fi
    else
        log_info "Installation ignorée"
        echo ""
        log_info "Pour installer plus tard:"
        echo "  cd ~/dotfiles"
        echo "  make install    # ou make setup"
        exit 0
    fi
else
    log_warn "Répertoire dotfiles ou Makefile non trouvé"
    if [ -f "$DOTFILES_DIR/setup.sh" ]; then
        log_info "Utilisation de setup.sh en fallback..."
        bash "$DOTFILES_DIR/setup.sh"
        if [ $? -eq 0 ]; then
            exit 0
        fi
    fi
fi

################################################################################
# TERMINÉ
################################################################################
log_section "Bootstrap terminé!"
log_info "Dotfiles installés et configurés"
echo ""
log_warn "Prochaines étapes:"
echo "  1. Rechargez votre shell: exec zsh"
echo "  2. Si QEMU installé: déconnectez-vous et reconnectez-vous"
echo "  3. Vérifiez les installations avec les commandes appropriées"
echo ""
