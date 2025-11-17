#!/bin/bash

################################################################################
# Bootstrap Script - Installation dotfiles sans configuration Git préalable
# Usage: curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
################################################################################

set +e  # Ne pas arrêter sur erreurs pour permettre la continuation

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
# CONFIGURATION PAR DÉFAUT
################################################################################
DEFAULT_GIT_NAME="PavelDelhomme"
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

# Vérifier si Git est déjà configuré
CURRENT_GIT_NAME=$(git config --global user.name 2>/dev/null)
CURRENT_GIT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -n "$CURRENT_GIT_NAME" ] && [ -n "$CURRENT_GIT_EMAIL" ]; then
    # Git est déjà configuré - utiliser la configuration existante
    git_name="$CURRENT_GIT_NAME"
    git_email="$CURRENT_GIT_EMAIL"
    log_info "✓ Git déjà configuré: $CURRENT_GIT_NAME <$CURRENT_GIT_EMAIL>"
    log_info "Configuration Git conservée, passage à la suite..."
else
    # Git n'est pas configuré, demander la configuration
    log_info "Configuration Git nécessaire"
    printf "Nom Git (défaut: %s): " "$DEFAULT_GIT_NAME"
    IFS= read -r git_name </dev/tty 2>/dev/null || read -r git_name
    if [ -z "$git_name" ]; then
        git_name="$DEFAULT_GIT_NAME"
    fi
    
    printf "Email Git (défaut: %s): " "$DEFAULT_GIT_EMAIL"
    IFS= read -r git_email </dev/tty 2>/dev/null || read -r git_email
    if [ -z "$git_email" ]; then
        git_email="$DEFAULT_GIT_EMAIL"
    fi
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

# Configurer Git (même si déjà configuré, pour s'assurer que tout est à jour)
GIT_WAS_CONFIGURED=false
if [ -n "$CURRENT_GIT_NAME" ] && [ -n "$CURRENT_GIT_EMAIL" ]; then
    GIT_WAS_CONFIGURED=true
fi

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor vim
git config --global color.ui auto

if [ "$GIT_WAS_CONFIGURED" = false ]; then
    log_info "✓ Git configuré: $git_name <$git_email>"
fi

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

# IMPORTANT: Le script continue ici vers le clonage
# Ne pas s'arrêter après la vérification SSH
# Forcer la continuation même si quelque chose a échoué
set +e  # S'assurer qu'on ne s'arrête pas sur erreurs

# FORCER la continuation - test explicite IMMÉDIATEMENT après le fi
# Dans un pipe curl | bash, il faut s'assurer que le script continue
# Utiliser une sous-shell pour forcer l'exécution
( true ) || exit 1

# Debug: vérifier qu'on arrive bien ici - FORCER l'affichage IMMÉDIATEMENT
# Utiliser à la fois stdout et stderr pour être sûr que ça s'affiche
exec >&2  # Rediriger stdout vers stderr temporairement pour forcer l'affichage
echo ""
echo "═══════════════════════════════════"
echo "DEBUG: Script continue après SSH..."
echo "═══════════════════════════════════"
exec >&1  # Restaurer stdout
log_info "Continuation vers le clonage du repository..."

################################################################################
# 3. CLONER LE REPO DOTFILES
################################################################################
log_section "Clonage du repo dotfiles"

# Si le dossier existe déjà et est un repo git, on l'utilise directement
if [ -d "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "✓ Dossier dotfiles existe déjà: $DOTFILES_DIR"
    log_info "Mise à jour du repository..."
    cd "$DOTFILES_DIR" 2>/dev/null || {
        log_error "Impossible d'accéder au dossier $DOTFILES_DIR"
        exit 1
    }
    git pull origin main || git pull origin master || true
    cd ~
    log_info "✓ Repository à jour"
    # IMPORTANT: Continuer vers la section suivante (symlinks puis Makefile)
elif [ -d "$DOTFILES_DIR" ]; then
    # Dossier existe mais n'est pas un repo git
    log_warn "Dossier $DOTFILES_DIR existe mais n'est pas un repository Git"
    printf "Supprimer et re-cloner? (o/n) [défaut: n]: "
    IFS= read -r delete_choice </dev/tty 2>/dev/null || read -r delete_choice
    delete_choice=${delete_choice:-n}
    if [[ "$delete_choice" =~ ^[oO]$ ]]; then
        rm -rf "$DOTFILES_DIR"
        log_info "Dossier supprimé"
    else
        log_warn "Dossier non-Git conservé, impossible de continuer"
        exit 1
    fi
fi

# Cloner si le dossier n'existe pas
if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Dossier dotfiles n'existe pas, clonage nécessaire..."
    log_info "Clonage de $DOTFILES_REPO dans $DOTFILES_DIR..."
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>&1; then
        log_info "✓ Dotfiles clonés avec succès"
    else
        log_error "Erreur lors du clonage des dotfiles"
        log_warn "Vérifiez votre connexion internet et réessayez"
        exit 1
    fi
else
    log_info "Dossier dotfiles existe déjà, pas besoin de cloner"
fi

# Vérifier que le dossier existe et contient le Makefile
log_info "Vérification du dossier dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Le dossier dotfiles n'existe pas après le clonage"
    exit 1
fi
log_info "✓ Dossier dotfiles existe: $DOTFILES_DIR"

if [ ! -f "$DOTFILES_DIR/Makefile" ]; then
    log_warn "Makefile non trouvé dans $DOTFILES_DIR"
    log_warn "Le repository semble incomplet, mais on continue..."
else
    log_info "✓ Makefile trouvé"
fi

log_info "Continuation vers la création des symlinks..."

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

# IMPORTANT: Le script continue ici vers la proposition Makefile
# Cette section est TOUJOURS exécutée si dotfiles existe
log_info "Continuation vers le lancement du menu interactif..."

################################################################################
# 5. LANCER AUTOMATIQUEMENT LE MENU INTERACTIF
################################################################################
log_section "Installation des dotfiles"

# Cette section doit TOUJOURS être atteinte si dotfiles existe
# Lancer automatiquement le menu interactif setup.sh

if [ -d "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/setup.sh" ]; then
    log_info "✅ Dotfiles clonés avec succès dans: $DOTFILES_DIR"
    echo ""
    log_info "Lancement du menu interactif d'installation..."
    echo ""
    
    # Changer dans le répertoire dotfiles
    cd "$DOTFILES_DIR" || {
        log_error "Impossible de se déplacer dans $DOTFILES_DIR"
        exit 1
    }
    
    # Lancer directement setup.sh
    bash "$DOTFILES_DIR/setup.sh"
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        log_info "Installation terminée, au revoir!"
        exit 0
    else
        exit $EXIT_CODE
    fi
else
    log_error "Répertoire dotfiles ou setup.sh non trouvé"
    log_warn "Le repository semble incomplet"
    exit 1
fi

# Le script se termine ici si setup.sh a été lancé avec succès
# setup.sh gère sa propre sortie et affichage
