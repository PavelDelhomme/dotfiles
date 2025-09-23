#!/bin/zsh
# =============================================================================
# MISCMAN - Miscellaneous Tools Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des outils divers et utilitaires
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

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
    
    # Nettoyage du système
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
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}"
        read -k 1 "choice?Votre choix: "
        echo
        
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
                echo
                echo "Raccourcis:"
                echo "  miscman                    - Lance le gestionnaire"
                echo "  miscman genpass [length]   - Génère un mot de passe"
                echo "  miscman sysinfo           - Infos système"
                echo "  miscman cleanup           - Nettoyage"
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

# Message d'initialisation
echo "🔧 MISCMAN chargé - Tapez 'miscman' ou 'mm' pour démarrer"
