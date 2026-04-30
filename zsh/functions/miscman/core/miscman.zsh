#!/bin/zsh
# =============================================================================
# MISCMAN - Miscellaneous Tools Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des outils divers et utilitaires
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Gestionnaire interactif complet pour les outils divers et utilitaires système. Inclut génération de mots de passe, informations système, sauvegardes, extraction d'archives, chiffrement et nettoyage.
# USAGE: miscman [command]
# EXAMPLE: miscman
# EXAMPLE: miscman genpass 20
# EXAMPLE: miscman sysinfo
miscman() {
    # Configuration des couleurs
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    local DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        source "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" 2>/dev/null || true
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    MISCMAN - Tools Manager                     ║"
        echo "║               Gestionnaire d'Outils Divers ZSH                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo
    }
    
    # Fonctions intégrées depuis misc/
    
    # Génération de mots de passe
    # DESC: Génère un mot de passe sécurisé de longueur spécifiée
    # USAGE: gen_password [length]
    # EXAMPLE: gen_password 20
    gen_password() {
        local length="${1:-16}"
        if [[ ! "$length" =~ ^[0-9]+$ ]] || [[ "$length" -lt 4 ]]; then
            echo -e "${RED}❌ Longueur invalide. Minimum 4 caractères.${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}🔐 Génération de mot de passe (longueur: $length)${RESET}"
        
        # Mot de passe sécurisé
        local password=$(openssl rand -base64 $((length * 3 / 4)) | tr -d '\n' | head -c $length)
        echo -e "${GREEN}Mot de passe généré: ${BOLD}$password${RESET}"
        
        # Copier dans le presse-papier si xclip disponible
        if command -v xclip &> /dev/null; then
            echo -n "$password" | xclip -selection clipboard
            echo -e "${BLUE}✅ Copié dans le presse-papier${RESET}"
        fi
        
        # Afficher la force du mot de passe
        local strength="Faible"
        if [[ ${#password} -ge 12 ]]; then
            if [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] ]]; then
                strength="${GREEN}Fort${RESET}"
            else
                strength="${YELLOW}Moyen${RESET}"
            fi
        else
            strength="${RED}Faible${RESET}"
        fi
        echo -e "Force estimée: $strength"
    }
    
    # Informations système
    # DESC: Affiche des informations détaillées sur le système
    # USAGE: show_system_info
    # EXAMPLE: show_system_info
    show_system_info() {
        echo -e "${CYAN}💻 Informations système détaillées${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${YELLOW}Système:${RESET}"
        echo "  OS: $(uname -o)"
        echo "  Kernel: $(uname -r)"
        echo "  Architecture: $(uname -m)"
        echo "  Hostname: $(hostname)"
        echo "  Uptime: $(uptime -p 2>/dev/null || uptime)"
        
        echo -e "\n${YELLOW}Processeur:${RESET}"
        if [[ -f /proc/cpuinfo ]]; then
            local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
            local cpu_cores=$(nproc)
            echo "  CPU: $cpu_model"
            echo "  Cœurs: $cpu_cores"
        fi
        
        echo -e "\n${YELLOW}Mémoire:${RESET}"
        if command -v free &> /dev/null; then
            free -h | grep -E "Mem|Swap" | while read line; do
                echo "  $line"
            done
        fi
        
        echo -e "\n${YELLOW}Stockage:${RESET}"
        df -h | grep -E "^/dev" | awk '{printf "  %-20s %5s / %5s (%s utilisé)\n", $1, $3, $2, $5}'
        
        echo -e "\n${YELLOW}Réseau:${RESET}"
        ip -o addr show | grep inet | awk '{print "  " $2 ": " $4}' | head -5
        
        echo -e "\n${YELLOW}Processus actifs:${RESET}"
        echo "  Total: $(ps aux | wc -l) processus"
        echo "  Top CPU:"
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "    %-15s %5s%%\n", $11, $3}'
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Copie de fichiers avec barre de progression
    copy_file_advanced() {
        read "source?Fichier source: "
        read "dest?Destination: "
        
        if [[ ! -f "$source" ]]; then
            echo -e "${RED}❌ Fichier source inexistant${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}📁 Copie en cours...${RESET}"
        
        if command -v rsync &> /dev/null; then
            rsync -ah --progress "$source" "$dest"
        elif command -v pv &> /dev/null; then
            pv "$source" > "$dest"
        else
            cp "$source" "$dest"
            echo -e "${GREEN}✅ Copie terminée${RESET}"
        fi
        
        if [[ $? -eq 0 ]]; then
            local size=$(du -h "$dest" | cut -f1)
            echo -e "${GREEN}✅ Fichier copié avec succès ($size)${RESET}"
        else
            echo -e "${RED}❌ Erreur lors de la copie${RESET}"
        fi
    }
    
    # Sauvegarde intelligente
    # DESC: Crée une sauvegarde intelligente d'un répertoire avec horodatage
    # USAGE: create_smart_backup
    # EXAMPLE: create_smart_backup
    create_smart_backup() {
        read "source_dir?Répertoire à sauvegarder: "
        
        if [[ ! -d "$source_dir" ]]; then
            echo -e "${RED}❌ Répertoire inexistant${RESET}"
            return 1
        fi
        
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_name="backup_$(basename "$source_dir")_$timestamp"
        local backup_dir="$HOME/Backups"
        
        mkdir -p "$backup_dir"
        
        echo -e "${CYAN}💾 Création de la sauvegarde...${RESET}"
        echo "Source: $source_dir"
        echo "Destination: $backup_dir/$backup_name.tar.gz"
        
        # Création de l'archive avec compression
        if tar -czf "$backup_dir/$backup_name.tar.gz" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>/dev/null; then
            local size=$(du -h "$backup_dir/$backup_name.tar.gz" | cut -f1)
            echo -e "${GREEN}✅ Sauvegarde créée avec succès ($size)${RESET}"
            echo "Fichier: $backup_dir/$backup_name.tar.gz"
        else
            echo -e "${RED}❌ Erreur lors de la sauvegarde${RESET}"
        fi
    }
    
    # Extraction intelligente d'archives
    # DESC: Extrait une archive de manière interactive
    # USAGE: extract_archive
    # EXAMPLE: extract_archive
    extract_archive() {
        read "archive?Fichier d'archive à extraire: "
        
        if [[ ! -f "$archive" ]]; then
            echo -e "${RED}❌ Fichier inexistant${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}📦 Extraction de l'archive...${RESET}"
        
        case "$archive" in
            *.tar.bz2) tar xjf "$archive" ;;
            *.tar.gz)  tar xzf "$archive" ;;
            *.tar.xz)  tar xJf "$archive" ;;
            *.bz2)     bunzip2 "$archive" ;;
            *.rar)     unrar x "$archive" ;;
            *.gz)      gunzip "$archive" ;;
            *.tar)     tar xf "$archive" ;;
            *.tbz2)    tar xjf "$archive" ;;
            *.tgz)     tar xzf "$archive" ;;
            *.zip)     unzip "$archive" ;;
            *.Z)       uncompress "$archive" ;;
            *.7z)      7z x "$archive" ;;
            *)         echo -e "${RED}❌ Format d'archive non supporté${RESET}"; return 1 ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Extraction terminée${RESET}"
        else
            echo -e "${RED}❌ Erreur lors de l'extraction${RESET}"
        fi
    }
    
    # Chiffrement/déchiffrement de fichiers
    # DESC: Chiffre un fichier avec GPG
    # USAGE: encrypt_file
    # EXAMPLE: encrypt_file
    encrypt_file() {
        read "file?Fichier à chiffrer: "
        
        if [[ ! -f "$file" ]]; then
            echo -e "${RED}❌ Fichier inexistant${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}🔒 Chiffrement du fichier...${RESET}"
        
        if command -v gpg &> /dev/null; then
            gpg --symmetric --cipher-algo AES256 "$file"
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}✅ Fichier chiffré: $file.gpg${RESET}"
                read -k 1 "remove?Supprimer le fichier original? [y/N]: "
                echo
                if [[ "$remove" =~ ^[Yy]$ ]]; then
                    rm "$file"
                    echo -e "${GREEN}✅ Fichier original supprimé${RESET}"
                fi
            fi
        else
            echo -e "${RED}❌ GPG non installé${RESET}"
        fi
    }
    
    # DESC: Déchiffre un fichier GPG
    # USAGE: decrypt_file
    # EXAMPLE: decrypt_file
    decrypt_file() {
        read "file?Fichier à déchiffrer: "
        
        if [[ ! -f "$file" ]]; then
            echo -e "${RED}❌ Fichier inexistant${RESET}"
            return 1
        fi
        
        echo -e "${CYAN}🔓 Déchiffrement du fichier...${RESET}"
        
        if command -v gpg &> /dev/null; then
            gpg --decrypt "$file" > "${file%.gpg}"
            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}✅ Fichier déchiffré: ${file%.gpg}${RESET}"
            fi
        else
            echo -e "${RED}❌ GPG non installé${RESET}"
        fi
    }
    
    # Copie de la dernière sortie de commande
    # DESC: Copie la dernière sortie de commande dans le presse-papier
    # USAGE: copy_last_output
    # EXAMPLE: copy_last_output
    copy_last_output() {
        echo -e "${CYAN}📋 Copie de la dernière sortie de commande${RESET}"
        
        # Récupérer la dernière commande de l'historique
        local last_cmd=$(fc -ln -1)
        echo "Dernière commande: $last_cmd"
        
        read -k 1 "confirm?Exécuter et copier la sortie? [y/N]: "
        echo
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            local output=$(eval "$last_cmd" 2>&1)
            echo "$output"
            
            if command -v xclip &> /dev/null; then
                echo "$output" | xclip -selection clipboard
                echo -e "${GREEN}✅ Sortie copiée dans le presse-papier${RESET}"
            else
                echo -e "${YELLOW}⚠️ xclip non disponible pour la copie${RESET}"
            fi
        fi
    }
    
    # Charger les fonctions système depuis les modules
    local MISC_DIR="${MISC_DIR:-$HOME/dotfiles/zsh/functions/miscman/modules/legacy}"
    
    # Charger les fonctions de gestion de processus
    if [ -f "$MISC_DIR/system/process.sh" ]; then
        source "$MISC_DIR/system/process.sh"
    fi
    
    # Charger les fonctions système (system_info, etc.)
    if [ -f "$MISC_DIR/system/system_info.sh" ]; then
        source "$MISC_DIR/system/system_info.sh"
    fi
    
    # Nettoyage du système
    # DESC: Nettoie le système (caches, fichiers temporaires)
    # USAGE: system_cleanup
    # EXAMPLE: system_cleanup
    system_cleanup() {
        echo -e "${CYAN}🧹 Nettoyage du système${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        
        echo -e "\n${YELLOW}Nettoyage proposé:${RESET}"
        echo "  1. Cache des paquets"
        echo "  2. Fichiers temporaires"
        echo "  3. Logs anciens"
        echo "  4. Cache utilisateur"
        echo "  5. Corbeille"
        
        read -k 1 "confirm?Procéder au nettoyage? [y/N]: "
        echo
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Cache des paquets (Manjaro/Arch)
            if command -v pacman &> /dev/null; then
                echo -e "${CYAN}Nettoyage du cache pacman...${RESET}"
                sudo pacman -Sc --noconfirm
            fi
            
            # Fichiers temporaires
            echo -e "${CYAN}Nettoyage des fichiers temporaires...${RESET}"
            sudo rm -rf /tmp/* 2>/dev/null
            
            # Logs anciens
            echo -e "${CYAN}Nettoyage des logs anciens...${RESET}"
            sudo journalctl --vacuum-time=7d 2>/dev/null
            
            # Cache utilisateur
            echo -e "${CYAN}Nettoyage du cache utilisateur...${RESET}"
            rm -rf ~/.cache/* 2>/dev/null
            
            # Corbeille
            if [[ -d ~/.local/share/Trash ]]; then
                echo -e "${CYAN}Vidage de la corbeille...${RESET}"
                rm -rf ~/.local/share/Trash/* 2>/dev/null
            fi
            
            echo -e "${GREEN}✅ Nettoyage terminé${RESET}"
        else
            echo -e "${BLUE}ℹ️ Nettoyage annulé${RESET}"
        fi
        
        echo
        read -k 1 "?Appuyez sur une touche pour continuer..."
    }
    
    # Menu principal
    while true; do
        show_header
        echo -e "${GREEN}Menu Principal${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        echo
        echo "  ${BOLD}1${RESET}  🔐 Générer un mot de passe"
        echo "  ${BOLD}2${RESET}  💻 Informations système détaillées"
        echo "  ${BOLD}3${RESET}  📁 Copie de fichier avancée"
        echo "  ${BOLD}4${RESET}  💾 Créer une sauvegarde"
        echo "  ${BOLD}5${RESET}  📦 Extraire une archive"
        echo "  ${BOLD}6${RESET}  🔒 Chiffrer un fichier"
        echo "  ${BOLD}7${RESET}  🔓 Déchiffrer un fichier"
        echo "  ${BOLD}8${RESET}  📋 Copier la dernière sortie de commande"
        echo "  ${BOLD}9${RESET}  🧹 Nettoyage du système"
        echo
        echo -e "${YELLOW}🔄 GESTION DES PROCESSUS:${RESET}"
        echo "  ${BOLD}10${RESET} 👁️  Surveiller un processus (watch)"
        echo "  ${BOLD}11${RESET} 🛑 Arrêter un processus par nom"
        echo "  ${BOLD}12${RESET} 🛑 Arrêter un processus sur un port"
        echo "  ${BOLD}13${RESET} 🔍 Lister les processus utilisant des ports"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        local choice=""
        if [[ -t 0 && -t 1 ]] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            local menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Generer un mot de passe|1
Informations systeme detaillees|2
Copie de fichier avancee|3
Creer une sauvegarde|4
Extraire une archive|5
Chiffrer un fichier|6
Dechiffrer un fichier|7
Copier la derniere sortie de commande|8
Nettoyage du systeme|9
Surveiller un processus (watch)|10
Arreter un processus par nom|11
Arreter un processus sur un port|12
Lister les processus utilisant des ports|13
Aide|h
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "MISCMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
            echo
        fi
        if [[ -z "$choice" ]]; then
            read "choice?Votre choix (validez avec Entrée): "
            echo
        fi
        
        case "$choice" in
            1) 
                read "length?Longueur du mot de passe (défaut: 16): "
                gen_password "${length:-16}"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2) show_system_info ;;
            3) 
                copy_file_advanced
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4) 
                create_smart_backup
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5) 
                extract_archive
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6) 
                encrypt_file
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7) 
                decrypt_file
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8) 
                copy_last_output
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9) system_cleanup ;;
            10)
                read "process?Nom du processus à surveiller: "
                read "interval?Intervalle en secondes (défaut: 1): "
                if command -v watch_process >/dev/null 2>&1; then
                    watch_process "$process" "${interval:-1}"
                else
                    echo -e "${RED}❌ Fonction watch_process non disponible${RESET}"
                    echo "💡 Chargement du module process..."
                    if [ -f "$MISC_DIR/system/process.sh" ]; then
                        source "$MISC_DIR/system/process.sh"
                        watch_process "$process" "${interval:-1}"
                    fi
                fi
                ;;
            11)
                read "process?Nom du processus à arrêter: "
                if command -v kill_process >/dev/null 2>&1; then
                    kill_process "$process"
                else
                    echo -e "${RED}❌ Fonction kill_process non disponible${RESET}"
                    echo "💡 Chargement du module process..."
                    if [ -f "$MISC_DIR/system/process.sh" ]; then
                        source "$MISC_DIR/system/process.sh"
                        kill_process "$process"
                    fi
                fi
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            12)
                read "port?Port à libérer: "
                if command -v kill_port >/dev/null 2>&1; then
                    kill_port "$port"
                else
                    echo -e "${RED}❌ Fonction kill_port non disponible${RESET}"
                    echo "💡 Chargement du module process..."
                    if [ -f "$MISC_DIR/system/process.sh" ]; then
                        source "$MISC_DIR/system/process.sh"
                        kill_port "$port"
                    fi
                fi
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            13)
                read "port?Port spécifique (laissez vide pour tous): "
                if command -v port_process >/dev/null 2>&1; then
                    port_process "$port"
                else
                    echo -e "${RED}❌ Fonction port_process non disponible${RESET}"
                    echo "💡 Chargement du module process..."
                    if [ -f "$MISC_DIR/system/process.sh" ]; then
                        source "$MISC_DIR/system/process.sh"
                        port_process "$port"
                    fi
                fi
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            h|H)
                show_header
                echo -e "${CYAN}📚 Aide - MISCMAN${RESET}"
                echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
                echo
                echo "MISCMAN est un gestionnaire d'outils divers pour ZSH."
                echo
                echo "Fonctionnalités:"
                echo "  • Génération de mots de passe sécurisés"
                echo "  • Informations système complètes"
                echo "  • Copie avancée avec barre de progression"
                echo "  • Sauvegardes automatisées"
                echo "  • Extraction d'archives multiformats"
                echo "  • Chiffrement/déchiffrement GPG"
                echo "  • Gestion du presse-papier"
                echo "  • Nettoyage système intelligent"
                echo "  • Surveillance de processus (watch_process)"
                echo "  • Arrêt de processus (kill_process, kill_port)"
                echo "  • Gestion des ports réseau (port_process)"
                echo
                echo "Raccourcis:"
                echo "  miscman                    - Lance le gestionnaire"
                echo "  miscman genpass [length]   - Génère un mot de passe"
                echo "  miscman sysinfo           - Infos système"
                echo "  miscman cleanup           - Nettoyage"
                echo
                echo "Fonctions processus (disponibles directement):"
                echo "  watch_process <name> [interval]  - Surveiller un processus"
                echo "  kill_process <name>              - Arrêter un processus"
                echo "  kill_port <port>                 - Libérer un port"
                echo "  port_process [port]              - Lister processus sur ports"
                echo
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            q|Q)
                echo -e "${GREEN}Au revoir!${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Option invalide${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Alias et raccourcis
alias mm='miscman'
alias misc-manager='miscman'

# Accès direct aux fonctions
if [[ "$1" == "genpass" ]]; then
    gen_password "$2"
elif [[ "$1" == "sysinfo" ]]; then
    miscman; show_system_info
elif [[ "$1" == "cleanup" ]]; then
    miscman; system_cleanup
fi

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🔧 MISCMAN chargé - Tapez 'miscman' ou 'mm' pour démarrer"
