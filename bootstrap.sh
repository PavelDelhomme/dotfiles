#!/bin/bash

################################################################################
# Bootstrap Script - Installation dotfiles sans configuration Git préalable
# Usage: curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash
# Alternative: bash <(curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh)
################################################################################

# Ne pas arrêter sur erreurs pour permettre la continuation
set +e
set -o pipefail 2>/dev/null || true  # Ignorer si pipefail n'est pas supporté

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
# GESTION DE L'INTERRUPTION (Ctrl+C)
################################################################################
cleanup_on_interrupt() {
    echo ""
    echo ""
    log_warn "⚠️  Installation interrompue par l'utilisateur (Ctrl+C)"
    echo ""
    log_info "État actuel :"
    echo "  - Git : $(git config --global user.name 2>/dev/null || echo 'Non configuré')"
    echo "  - Dossier dotfiles : $([ -d "$HOME/dotfiles" ] && echo 'Présent' || echo 'Absent')"
    echo ""
    log_info "Vous pouvez relancer l'installation plus tard avec :"
    echo "  curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"
    echo ""
    log_info "Ou si dotfiles est déjà cloné :"
    echo "  cd ~/dotfiles && bash scripts/setup.sh"
    echo ""
    exit 130  # Code de sortie standard pour SIGINT
}

# Capturer Ctrl+C (SIGINT) et SIGTERM
trap cleanup_on_interrupt SIGINT SIGTERM

################################################################################
# CONFIGURATION PAR DÉFAUT
################################################################################
DOTFILES_DIR="$HOME/dotfiles"

# Charger le fichier .env s'il existe, sinon utiliser les valeurs par défaut
if [ -f "$DOTFILES_DIR/.env" ]; then
    source "$DOTFILES_DIR/.env"
elif [ -f "$HOME/.env_dotfiles" ]; then
    # Fallback: chercher dans le home directory
    source "$HOME/.env_dotfiles"
fi

# Charger les variables depuis .env si disponibles
# PAS de valeurs par défaut hardcodées pour protéger la vie privée
DEFAULT_GIT_NAME="${GIT_USER_NAME:-}"
DEFAULT_GIT_EMAIL="${GIT_USER_EMAIL:-}"
DOTFILES_REPO="${GITHUB_REPO_URL:-https://github.com/PavelDelhomme/dotfiles.git}"

log_section "Bootstrap Installation - Dotfiles"

# Créer le fichier .env depuis .env.example si nécessaire (après le clonage)
# Cette partie sera exécutée plus tard dans le script

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

# Vérifier si Git est déjà configuré
CURRENT_GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$CURRENT_GIT_NAME" ] && [ -n "$CURRENT_GIT_EMAIL" ] && [ "$CURRENT_GIT_NAME" != "" ] && [ "$CURRENT_GIT_EMAIL" != "" ]; then
    # Git est déjà configuré - utiliser la configuration existante
    git_name="$CURRENT_GIT_NAME"
    git_email="$CURRENT_GIT_EMAIL"
    log_info "✓ Git déjà configuré: $CURRENT_GIT_NAME <$CURRENT_GIT_EMAIL>"
    log_info "Configuration Git conservée, passage à la suite..."
    
    # Stocker les valeurs pour éviter de redemander
    GIT_WAS_CONFIGURED=true
    SKIP_GIT_CONFIG=true
else
    # Git n'est pas configuré
    GIT_WAS_CONFIGURED=false
    SKIP_GIT_CONFIG=false
    # Git n'est pas configuré, demander la configuration
    log_info "Configuration Git nécessaire"
    log_warn "Aucune information personnelle ne sera utilisée par défaut"
    echo ""
    log_info "Le nom Git est le nom qui apparaîtra dans vos commits Git (visible dans git log, GitHub, etc.)"
    log_info "Exemples : PavelDelhomme, Jean Dupont, John Doe"
    echo ""
    
    # Demander le nom Git (obligatoire)
    while [ -z "$git_name" ]; do
        if [ -n "$DEFAULT_GIT_NAME" ]; then
            printf "Nom Git [défaut depuis .env: %s]: " "$DEFAULT_GIT_NAME"
        else
            printf "Nom Git (obligatoire): "
        fi
        IFS= read -r git_name </dev/tty 2>/dev/null || read -r git_name
        if [ -z "$git_name" ] && [ -n "$DEFAULT_GIT_NAME" ]; then
            git_name="$DEFAULT_GIT_NAME"
        fi
        if [ -z "$git_name" ]; then
            log_error "Le nom Git est obligatoire. Veuillez entrer un nom."
        fi
    done
    
    echo ""
    log_info "L'email Git doit correspondre à l'email de votre compte GitHub/GitLab"
    log_info "Pour GitHub, vous pouvez utiliser username@users.noreply.github.com pour garder votre email privé"
    log_info "Exemples : dev@delhomme.ovh, votre.email@example.com"
    echo ""
    
    # Demander l'email Git (obligatoire)
    while [ -z "$git_email" ]; do
        if [ -n "$DEFAULT_GIT_EMAIL" ]; then
            printf "Email Git [défaut depuis .env: %s]: " "$DEFAULT_GIT_EMAIL"
        else
            printf "Email Git (obligatoire): "
        fi
        IFS= read -r git_email </dev/tty 2>/dev/null || read -r git_email
        if [ -z "$git_email" ] && [ -n "$DEFAULT_GIT_EMAIL" ]; then
            git_email="$DEFAULT_GIT_EMAIL"
        fi
        if [ -z "$git_email" ]; then
            log_error "L'email Git est obligatoire. Veuillez entrer un email valide."
        elif [[ ! "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            log_warn "Format d'email invalide. Veuillez entrer un email valide."
            git_email=""
        fi
    done
fi

# Vérifier que les valeurs sont bien définies (sécurité finale)
if [ -z "$git_email" ] || [[ "$git_email" == *"\$"* ]] || [[ "$git_email" == *"DEFAULT"* ]]; then
    log_error "Erreur: L'email Git n'est pas valide. Configuration annulée."
    exit 1
fi

if [ -z "$git_name" ] || [[ "$git_name" == *"\$"* ]] || [[ "$git_name" == *"DEFAULT"* ]]; then
    log_error "Erreur: Le nom Git n'est pas valide. Configuration annulée."
    exit 1
fi

# Configurer Git uniquement si nécessaire
if [ "$SKIP_GIT_CONFIG" != "true" ]; then
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    log_info "✓ Git configuré: $git_name <$git_email>"
fi

# Configurations globales (toujours appliquées si nécessaire)
if [ -z "$(git config --global init.defaultBranch 2>/dev/null)" ]; then
    git config --global init.defaultBranch main
fi
if [ -z "$(git config --global core.editor 2>/dev/null)" ]; then
    git config --global core.editor vim
fi
if [ -z "$(git config --global color.ui 2>/dev/null)" ]; then
    git config --global color.ui auto
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
# 2.2. GÉNÉRATION CLÉ SSH (si absente) - OPTIONNEL
################################################################################
log_section "Configuration SSH pour GitHub (optionnel)"

# Demander si l'utilisateur veut configurer SSH pour GitHub
echo ""
log_info "Souhaitez-vous configurer SSH pour GitHub ?"
log_info "Cela permet de cloner/pusher sans saisir vos identifiants."
echo ""
echo "  1. Oui, configurer SSH (recommandé)"
echo "  2. Non, passer cette étape (vous pourrez cloner via HTTPS)"
echo "  0. Vérifier si SSH est déjà configuré et fonctionne"
echo ""
while true; do
    printf "Votre choix [défaut: 1]: "
    IFS= read -r ssh_choice </dev/tty 2>/dev/null || read -r ssh_choice
    ssh_choice=${ssh_choice:-1}
    
    case "$ssh_choice" in
        1)
            CONFIGURE_SSH=true
            break
            ;;
        2)
            CONFIGURE_SSH=false
            log_warn "Configuration SSH ignorée. Vous pouvez continuer sans SSH."
            log_info "Note: Vous devrez utiliser HTTPS pour cloner (avec authentification GitHub)."
            break
            ;;
        0)
            # Vérifier si SSH fonctionne déjà
            log_info "Vérification de la configuration SSH existante..."
            if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
                SSH_KEY="$HOME/.ssh/id_ed25519"
                [ ! -f "$SSH_KEY" ] && SSH_KEY="$HOME/.ssh/id_rsa"
                log_info "✓ Clé SSH trouvée: $SSH_KEY"
                
                # Tester la connexion
                log_info "Test de la connexion GitHub..."
                if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
                    log_info "✅ Connexion GitHub SSH fonctionne déjà !"
                    CONFIGURE_SSH=false
                    break
                else
                    log_warn "⚠️ Clé SSH présente mais connexion GitHub échouée"
                    log_info "Vous pouvez choisir de reconfigurer ou continuer sans SSH."
                    echo ""
                    continue
                fi
            else
                log_warn "Aucune clé SSH trouvée."
                echo ""
                continue
            fi
            ;;
        *)
            log_error "Choix invalide. Entrez 1, 2 ou 0."
            ;;
    esac
done

if [ "$CONFIGURE_SSH" = "false" ]; then
    log_info "Passage à l'étape suivante (clonage du repository)..."
else
    # Continuer avec la configuration SSH
    SSH_KEY="$HOME/.ssh/id_ed25519"
    SSH_PUB_KEY="$SSH_KEY.pub"

    if [ ! -f "$SSH_KEY" ]; then
        log_info "Génération de la clé SSH ED25519..."
    
    # S'assurer que git_email contient bien la valeur réelle
    # Si git_email contient encore des variables non résolues, erreur
    if [ -z "$git_email" ] || [[ "$git_email" == *"\$"* ]] || [[ "$git_email" == *"DEFAULT"* ]] || [[ "$git_email" == *"git_email"* ]]; then
        log_error "Erreur: L'email Git n'est pas valide pour la génération de la clé SSH."
        log_warn "Veuillez configurer Git correctement avant de continuer."
        exit 1
    fi
    
    # Générer la clé avec l'email correct (vérifier une dernière fois)
    SSH_EMAIL="$git_email"
    if [ -z "$SSH_EMAIL" ] || [[ ! "$SSH_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_error "Erreur: Impossible de déterminer un email valide pour la clé SSH."
        log_warn "Veuillez configurer Git correctement avant de continuer."
        exit 1
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
    
    echo ""
    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_warn "⚠️  IMPORTANT: Ajoutez la clé SSH sur GitHub avant de continuer"
    log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "1. Copiez la clé SSH ci-dessus (déjà dans le presse-papier si xclip/wl-copy disponible)"
    log_info "2. Allez sur: https://github.com/settings/keys"
    log_info "3. Cliquez sur 'New SSH key'"
    log_info "4. Collez la clé et donnez-lui un titre (ex: 'Dotfiles SSH Key')"
    log_info "5. Cliquez sur 'Add SSH key'"
    echo ""
    log_warn "Une fois la clé ajoutée sur GitHub, appuyez sur Entrée pour continuer..."
    echo ""
    
    # Attendre explicitement que l'utilisateur appuie sur Entrée
    # Utiliser /dev/tty pour forcer la lecture depuis le terminal même dans un pipe
    while true; do
        printf "${YELLOW}Appuyez sur Entrée après avoir ajouté la clé sur GitHub... ${NC}"
        if IFS= read -r dummy </dev/tty 2>/dev/null || IFS= read -r dummy; then
            break
        fi
        sleep 0.5
    done
    
    echo ""
    log_info "Vérification de la connexion GitHub..."
    
    # Attendre un peu pour que GitHub propage la clé
    log_info "Attente de 5 secondes pour la propagation de la clé sur GitHub..."
    sleep 5
    
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
        
        # Démarrer ssh-agent si nécessaire et ajouter la clé
        if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
            log_info "Démarrage de ssh-agent..."
            eval "$(ssh-agent -s)" > /dev/null 2>&1 || true
            ssh-add "$SSH_KEY" 2>/dev/null || log_warn "Impossible d'ajouter la clé au ssh-agent"
            log_info "✓ Clé ajoutée au ssh-agent"
            # Attendre un peu pour que ssh-agent soit prêt
            sleep 1
        else
            log_info "✓ Clé SSH déjà dans ssh-agent"
        fi
        
        # Tester la connexion existante
        log_info "Test de la connexion GitHub..."
        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            log_info "✅ Connexion GitHub OK"
        else
            log_warn "⚠️ Connexion GitHub échouée"
            
            # Vérifier si on a un environnement graphique
            HAS_DISPLAY=false
            if [ -n "$DISPLAY" ] || command -v xdg-open >/dev/null 2>&1 || command -v firefox >/dev/null 2>&1 || command -v chromium >/dev/null 2>&1; then
                HAS_DISPLAY=true
            fi
            
            if [ "$HAS_DISPLAY" = true ]; then
                # Environnement graphique disponible - ouvrir GitHub
                log_info "Ouverture de GitHub dans le navigateur..."
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "https://github.com/settings/ssh/new" 2>/dev/null || true
                elif command -v firefox >/dev/null 2>&1; then
                    firefox "https://github.com/settings/ssh/new" 2>/dev/null || true
                elif command -v chromium >/dev/null 2>&1; then
                    chromium "https://github.com/settings/ssh/new" 2>/dev/null || true
                fi
                log_info "Veuillez ajouter la clé SSH dans GitHub"
                echo ""
                log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                log_warn "⚠️  IMPORTANT: Ajoutez la clé SSH sur GitHub avant de continuer"
                log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                log_info "1. Copiez la clé SSH publique ci-dessous :"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                cat "$SSH_KEY.pub"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                log_info "2. Allez sur: https://github.com/settings/keys"
                log_info "3. Cliquez sur 'New SSH key'"
                log_info "4. Collez la clé et donnez-lui un titre (ex: 'Dotfiles SSH Key')"
                log_info "5. Cliquez sur 'Add SSH key'"
                echo ""
                log_warn "Une fois la clé ajoutée sur GitHub, appuyez sur Entrée pour continuer..."
                echo ""
                
                # Attendre explicitement que l'utilisateur appuie sur Entrée
                while true; do
                    printf "${YELLOW}Appuyez sur Entrée après avoir ajouté la clé sur GitHub... ${NC}"
                    if IFS= read -r dummy </dev/tty 2>/dev/null || IFS= read -r dummy; then
                        break
                    fi
                    sleep 0.5
                done
            else
                # Pas d'environnement graphique - afficher les instructions manuelles
                echo ""
                log_section "Instructions pour ajouter la clé SSH manuellement"
                log_info "Vous êtes en ligne de commande uniquement (pas d'interface graphique)"
                echo ""
                log_info "1. Copiez la clé SSH publique ci-dessous :"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                cat "$SSH_KEY.pub"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                log_info "2. Connectez-vous à GitHub sur une autre machine avec un navigateur :"
                echo "   https://github.com/settings/ssh/new"
                echo ""
                log_info "3. Ou utilisez GitHub CLI si installé :"
                echo "   gh auth login"
                echo "   gh ssh-key add $SSH_KEY.pub --title 'Dotfiles SSH Key'"
                echo ""
                log_info "4. Une fois la clé ajoutée, testez la connexion avec :"
                echo "   ssh -T git@github.com"
                echo ""
                log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                log_warn "⚠️  IMPORTANT: Ajoutez la clé SSH sur GitHub avant de continuer"
                log_warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                log_warn "Une fois la clé ajoutée sur GitHub, appuyez sur Entrée pour continuer..."
                echo ""
                
                # Attendre explicitement que l'utilisateur appuie sur Entrée
                while true; do
                    printf "${YELLOW}Appuyez sur Entrée après avoir ajouté la clé sur GitHub... ${NC}"
                    if IFS= read -r dummy </dev/tty 2>/dev/null || IFS= read -r dummy; then
                        break
                    fi
                    sleep 0.5
                done
            fi
            
            echo ""
            log_info "Vérification de la connexion GitHub..."
            
            # Attendre un peu pour que GitHub propage la clé
            log_info "Attente de 5 secondes pour la propagation de la clé sur GitHub..."
            sleep 5
            
            # Tester à nouveau après l'ajout manuel
            log_info "Test de la connexion GitHub..."
            if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
                log_info "✅ Connexion GitHub OK"
            else
                log_warn "⚠️ Connexion GitHub toujours échouée"
                log_warn "Vous pourrez configurer la clé SSH plus tard"
            fi
        fi
    fi
    # Fin du if [ ! -f "$SSH_KEY" ]
fi
# Fin du bloc CONFIGURE_SSH=true

################################################################################
# VÉRIFICATION FINALE GIT AVANT CLONAGE
################################################################################
# S'assurer que Git est installé avant de cloner
if ! command -v git >/dev/null 2>&1; then
    log_error "Git n'est pas installé. Impossible de continuer."
    log_info "Veuillez installer Git manuellement, puis relancez le script."
    exit 1
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
# Utiliser stderr directement pour être sûr que ça s'affiche même dans un pipe
echo "" >&2
echo "═══════════════════════════════════" >&2
echo "DEBUG: Script continue après SSH..." >&2
echo "═══════════════════════════════════" >&2
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
    # Passer directement au menu interactif si dotfiles existe déjà
    log_info "Passage direct au menu interactif..."
    log_info "✅ Dotfiles présents, lancement du menu interactif..."
    echo ""
    
    if [ -f "$DOTFILES_DIR/scripts/setup.sh" ]; then
        cd "$DOTFILES_DIR" || {
            log_error "Impossible de se déplacer dans $DOTFILES_DIR"
            exit 1
        }
        bash "$DOTFILES_DIR/scripts/setup.sh"
        exit $?
    fi
    # IMPORTANT: Continuer vers la section suivante si setup.sh n'existe pas
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
        
        # Créer le fichier .env automatiquement avec les valeurs fournies
        if [ -n "$SAVED_GIT_NAME" ] && [ -n "$SAVED_GIT_EMAIL" ]; then
            log_info "Création automatique du fichier .env..."
            ENV_FILE="$DOTFILES_DIR/.env"
            
            # Créer .env depuis .env.example si disponible, sinon créer un nouveau fichier
            if [ -f "$DOTFILES_DIR/.env.example" ]; then
                cp "$DOTFILES_DIR/.env.example" "$ENV_FILE"
            else
                # Créer un fichier .env basique
                cat > "$ENV_FILE" << EOF
# =============================================================================
# FICHIER DE CONFIGURATION D'ENVIRONNEMENT
# =============================================================================
# Ce fichier contient vos variables d'environnement personnelles.
# 
# IMPORTANT: Ce fichier est dans .gitignore et ne sera JAMAIS commité.
# Il contient des informations personnelles sensibles.
# =============================================================================

# =============================================================================
# CONFIGURATION GIT
# =============================================================================
# Nom d'utilisateur Git (pour les commits)
GIT_USER_NAME=""

# Email Git (pour les commits)
GIT_USER_EMAIL=""

# =============================================================================
# CONFIGURATION GITHUB
# =============================================================================
# URL du repository GitHub (par défaut, peut être changé)
GITHUB_REPO_URL=""
EOF
            fi
            
            # Remplacer les valeurs dans .env
            if [ -f "$ENV_FILE" ]; then
                # Utiliser sed pour remplacer les valeurs (compatible avec tous les systèmes)
                if command -v sed >/dev/null 2>&1; then
                    # Échapper les caractères spéciaux pour sed
                    ESCAPED_NAME=$(echo "$SAVED_GIT_NAME" | sed 's/[\/&]/\\&/g')
                    ESCAPED_EMAIL=$(echo "$SAVED_GIT_EMAIL" | sed 's/[\/&]/\\&/g')
                    ESCAPED_REPO=$(echo "$DOTFILES_REPO" | sed 's/[\/&]/\\&/g')
                    
                    # Remplacer les valeurs
                    sed -i "s/^GIT_USER_NAME=.*/GIT_USER_NAME=\"$ESCAPED_NAME\"/" "$ENV_FILE" 2>/dev/null || \
                    sed -i '' "s/^GIT_USER_NAME=.*/GIT_USER_NAME=\"$ESCAPED_NAME\"/" "$ENV_FILE" 2>/dev/null || true
                    
                    sed -i "s/^GIT_USER_EMAIL=.*/GIT_USER_EMAIL=\"$ESCAPED_EMAIL\"/" "$ENV_FILE" 2>/dev/null || \
                    sed -i '' "s/^GIT_USER_EMAIL=.*/GIT_USER_EMAIL=\"$ESCAPED_EMAIL\"/" "$ENV_FILE" 2>/dev/null || true
                    
                    sed -i "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=\"$ESCAPED_REPO\"|" "$ENV_FILE" 2>/dev/null || \
                    sed -i '' "s|^GITHUB_REPO_URL=.*|GITHUB_REPO_URL=\"$ESCAPED_REPO\"|" "$ENV_FILE" 2>/dev/null || true
                fi
                
                log_info "✓ Fichier .env créé avec vos informations"
                log_info "  GIT_USER_NAME=\"$SAVED_GIT_NAME\""
                log_info "  GIT_USER_EMAIL=\"$SAVED_GIT_EMAIL\""
                log_info "  GITHUB_REPO_URL=\"$DOTFILES_REPO\""
            fi
        fi
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
# 4. CHOIX DU SHELL (FISH OU ZSH)
################################################################################
log_section "Choix du shell"

CURRENT_SHELL=$(basename "$SHELL" 2>/dev/null || echo "unknown")
DEFAULT_SHELL="zsh"

echo ""
log_info "Shell actuel détecté: $CURRENT_SHELL"
echo ""
echo "Quel shell souhaitez-vous configurer?"
echo "  1. Zsh (recommandé)"
echo "  2. Fish"
echo "  3. Les deux (Fish et Zsh)"
echo "  0. Passer cette étape"
echo ""

SELECTED_SHELL=""
while [ -z "$SELECTED_SHELL" ]; do
    printf "Votre choix [défaut: 1]: "
    # Lire le choix de manière robuste
    shell_choice=""
    if [ -t 0 ]; then
        IFS= read -r shell_choice </dev/tty 2>/dev/null || IFS= read -r shell_choice
    else
        IFS= read -r shell_choice 2>/dev/null || read -r shell_choice
    fi
    # Nettoyer et utiliser la valeur par défaut si vide
    shell_choice=$(echo "$shell_choice" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    shell_choice=${shell_choice:-1}
    
    case "$shell_choice" in
        1)
            SELECTED_SHELL="zsh"
            log_info "Zsh sélectionné"
            ;;
        2)
            SELECTED_SHELL="fish"
            log_info "Fish sélectionné"
            ;;
        3)
            SELECTED_SHELL="both"
            log_info "Les deux shells sélectionnés"
            ;;
        0)
            SELECTED_SHELL="skip"
            log_warn "Configuration shell ignorée"
            ;;
        *)
            log_error "Choix invalide, veuillez entrer 1, 2, 3 ou 0"
            shell_choice=""  # Réinitialiser pour reboucler
            ;;
    esac
done

# Stocker le choix dans une variable pour setup.sh
export SELECTED_SHELL_FOR_SETUP="$SELECTED_SHELL"

################################################################################
# 4.1. INSTALLATION COMPLÈTE ZSH (OPTIONNEL)
################################################################################
if [ "$SELECTED_SHELL" = "zsh" ] || [ "$SELECTED_SHELL" = "both" ]; then
    log_section "Installation complète Zsh + Oh My Zsh + Powerlevel10k"
    
    echo ""
    log_info "Souhaitez-vous installer automatiquement Zsh complet avec:"
    echo "  - Oh My Zsh"
    echo "  - Powerlevel10k (thème avec support Git)"
    echo "  - Plugins Zsh (autosuggestions, syntax-highlighting, completions)"
    echo "  - Nerd Fonts (support emojis/icônes)"
    echo ""
    echo "  1. Oui, installer tout automatiquement (recommandé)"
    echo "  2. Non, passer cette étape"
    echo ""
    
    zsh_install_choice=""
    while [ -z "$zsh_install_choice" ]; do
        printf "Votre choix [défaut: 1]: "
        if [ -t 0 ]; then
            IFS= read -r zsh_install_choice </dev/tty 2>/dev/null || IFS= read -r zsh_install_choice
        else
            IFS= read -r zsh_install_choice 2>/dev/null || read -r zsh_install_choice
        fi
        zsh_install_choice=$(echo "$zsh_install_choice" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        zsh_install_choice=${zsh_install_choice:-1}
        
        case "$zsh_install_choice" in
            1)
                if [ -f "$DOTFILES_DIR/install_zsh_complete.sh" ]; then
                    log_info "Installation complète de Zsh..."
                    bash "$DOTFILES_DIR/install_zsh_complete.sh" || {
                        log_warn "⚠️  Installation Zsh complète échouée, continuons..."
                    }
                else
                    log_warn "⚠️  Script install_zsh_complete.sh non trouvé"
                fi
                break
                ;;
            2)
                log_info "Installation Zsh complète ignorée"
                break
                ;;
            *)
                log_error "Choix invalide, veuillez entrer 1 ou 2"
                zsh_install_choice=""
                ;;
        esac
    done
fi

################################################################################
# 5. CRÉER LES SYMLINKS (CENTRALISATION CONFIGURATION)
################################################################################
log_section "Création des symlinks pour centraliser la configuration"

if [ -f "$DOTFILES_DIR/scripts/config/create_symlinks.sh" ]; then
    printf "Créer les symlinks pour centraliser la configuration? (o/n) [défaut: o]: "
    # Lire le choix de manière robuste
    create_symlinks=""
    if [ -t 0 ]; then
        IFS= read -r create_symlinks </dev/tty 2>/dev/null || IFS= read -r create_symlinks
    else
        IFS= read -r create_symlinks 2>/dev/null || read -r create_symlinks
    fi
    # Nettoyer et utiliser la valeur par défaut si vide
    create_symlinks=$(echo "$create_symlinks" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    create_symlinks=${create_symlinks:-o}
    if [[ "$create_symlinks" =~ ^[oO]$ ]]; then
        log_info "Création des symlinks..."
        # Créer les symlinks selon le shell choisi
        if [ "$SELECTED_SHELL" = "zsh" ] || [ "$SELECTED_SHELL" = "both" ]; then
            bash "$DOTFILES_DIR/scripts/config/create_symlinks.sh"
        fi
        if [ "$SELECTED_SHELL" = "fish" ] || [ "$SELECTED_SHELL" = "both" ]; then
            # Créer le symlink pour fish
            FISH_CONFIG_DIR="$HOME/.config/fish"
            mkdir -p "$FISH_CONFIG_DIR"
            if [ ! -L "$FISH_CONFIG_DIR/config.fish" ]; then
                if [ -f "$DOTFILES_DIR/fish/config.fish" ]; then
                    [ -f "$FISH_CONFIG_DIR/config.fish" ] && mv "$FISH_CONFIG_DIR/config.fish" "$FISH_CONFIG_DIR/config.fish.backup"
                    ln -s "$DOTFILES_DIR/fish/config.fish" "$FISH_CONFIG_DIR/config.fish" 2>/dev/null || ln -s "$DOTFILES_DIR/fish/config_custom.fish" "$FISH_CONFIG_DIR/config.fish"
                    log_info "✓ Symlink config.fish créé pour Fish"
                fi
            fi
        fi
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
# 6. LANCER AUTOMATIQUEMENT LE MENU INTERACTIF
################################################################################
log_section "Installation des dotfiles"

# Cette section doit TOUJOURS être atteinte si dotfiles existe
# Lancer automatiquement le menu interactif setup.sh

    if [ -d "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/scripts/setup.sh" ]; then
        log_info "✅ Dotfiles clonés avec succès dans: $DOTFILES_DIR"
        echo ""
        log_info "Lancement du menu interactif d'installation..."
        echo ""
        
        # Changer dans le répertoire dotfiles
        cd "$DOTFILES_DIR" || {
            log_error "Impossible de se déplacer dans $DOTFILES_DIR"
            exit 1
        }
        
        # Passer le shell sélectionné à setup.sh via variable d'environnement
        export SELECTED_SHELL_FOR_SETUP
        
        # Lancer directement setup.sh
        bash "$DOTFILES_DIR/scripts/setup.sh"
    
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
