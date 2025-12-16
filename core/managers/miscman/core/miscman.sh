#!/bin/sh
# =============================================================================
# MISCMAN - Miscellaneous Tools Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils divers et utilitaires
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# DESC: Gestionnaire interactif complet pour les outils divers et utilitaires système
# USAGE: miscman [command]
# EXAMPLE: miscman
# EXAMPLE: miscman genpass 20
# EXAMPLE: miscman sysinfo
miscman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    MISCMAN - Tools Manager                     ║"
        echo "║               Gestionnaire d'Outils Divers                     ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
        echo
    }
    
    # Génération de mots de passe
    # DESC: Génère un mot de passe sécurisé de longueur spécifiée
    # USAGE: gen_password [length]
    gen_password() {
        length="${1:-16}"
        if ! echo "$length" | grep -qE '^[0-9]+$' || [ "$length" -lt 4 ]; then
            printf "${RED}❌ Longueur invalide. Minimum 4 caractères.${RESET}\n"
            return 1
        fi
        
        printf "${CYAN}🔐 Génération de mot de passe (longueur: $length)${RESET}\n"
        
        # Mot de passe sécurisé
        if command -v openssl >/dev/null 2>&1; then
            password=$(openssl rand -base64 $((length * 3 / 4)) 2>/dev/null | tr -d '\n' | head -c "$length")
            printf "${GREEN}Mot de passe généré: ${BOLD}%s${RESET}\n" "$password"
            
            # Copier dans le presse-papier si xclip disponible
            if command -v xclip >/dev/null 2>&1; then
                echo -n "$password" | xclip -selection clipboard 2>/dev/null
                printf "${BLUE}✅ Copié dans le presse-papier${RESET}\n"
            fi
            
            # Afficher la force du mot de passe
            strength="Faible"
            if [ ${#password} -ge 12 ]; then
                if echo "$password" | grep -qE '[A-Z]' && \
                   echo "$password" | grep -qE '[a-z]' && \
                   echo "$password" | grep -qE '[0-9]'; then
                    strength="${GREEN}Fort${RESET}"
                else
                    strength="${YELLOW}Moyen${RESET}"
                fi
            else
                strength="${RED}Faible${RESET}"
            fi
            printf "Force estimée: %s\n" "$strength"
        else
            printf "${RED}❌ openssl non disponible${RESET}\n"
            return 1
        fi
    }
    
    # Informations système
    # DESC: Affiche des informations détaillées sur le système
    # USAGE: show_system_info
    show_system_info() {
        printf "${CYAN}💻 Informations système détaillées${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        printf "\n${YELLOW}Système:${RESET}\n"
        echo "  OS: $(uname -o 2>/dev/null || uname -s)"
        echo "  Kernel: $(uname -r)"
        echo "  Architecture: $(uname -m)"
        echo "  Hostname: $(hostname 2>/dev/null || uname -n)"
        if command -v uptime >/dev/null 2>&1; then
            uptime_output=$(uptime -p 2>/dev/null || uptime)
            echo "  Uptime: $uptime_output"
        fi
        
        printf "\n${YELLOW}Processeur:${RESET}\n"
        if [ -f /proc/cpuinfo ]; then
            cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | sed 's/^[[:space:]]*//')
            cpu_cores=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo "N/A")
            echo "  CPU: $cpu_model"
            echo "  Cœurs: $cpu_cores"
        fi
        
        printf "\n${YELLOW}Mémoire:${RESET}\n"
        if command -v free >/dev/null 2>&1; then
            free -h 2>/dev/null | grep -E "Mem|Swap" | while IFS= read -r line; do
                echo "  $line"
            done
        fi
        
        printf "\n${YELLOW}Stockage:${RESET}\n"
        df -h 2>/dev/null | grep -E "^/dev" | awk '{printf "  %-20s %5s / %5s (%s utilisé)\n", $1, $3, $2, $5}'
        
        printf "\n${YELLOW}Réseau:${RESET}\n"
        if command -v ip >/dev/null 2>&1; then
            ip -o addr show 2>/dev/null | grep inet | awk '{print "  " $2 ": " $4}' | head -5
        elif command -v ifconfig >/dev/null 2>&1; then
            ifconfig 2>/dev/null | grep "inet " | awk '{print "  " $2}' | head -5
        fi
        
        printf "\n${YELLOW}Processus actifs:${RESET}\n"
        if command -v ps >/dev/null 2>&1; then
            total_processes=$(ps aux 2>/dev/null | wc -l | tr -d ' ')
            echo "  Total: $total_processes processus"
            echo "  Top CPU:"
            ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "    %-15s %5s%%\n", $11, $3}'
        fi
        
        echo
        printf "Appuyez sur Entrée pour continuer... "
        read dummy
    }
    
    # Copie de fichiers avec barre de progression
    copy_file_advanced() {
        printf "Fichier source: "
        read source
        printf "Destination: "
        read dest
        
        if [ ! -f "$source" ]; then
            printf "${RED}❌ Fichier source inexistant${RESET}\n"
            return 1
        fi
        
        printf "${CYAN}📁 Copie en cours...${RESET}\n"
        
        if command -v rsync >/dev/null 2>&1; then
            rsync -ah --progress "$source" "$dest" 2>/dev/null
        elif command -v pv >/dev/null 2>&1; then
            pv "$source" > "$dest" 2>/dev/null
        else
            cp "$source" "$dest" 2>/dev/null
            printf "${GREEN}✅ Copie terminée${RESET}\n"
        fi
        
        if [ $? -eq 0 ]; then
            size=$(du -h "$dest" 2>/dev/null | cut -f1)
            printf "${GREEN}✅ Fichier copié avec succès ($size)${RESET}\n"
        else
            printf "${RED}❌ Erreur lors de la copie${RESET}\n"
        fi
    }
    
    # Sauvegarde intelligente
    # DESC: Crée une sauvegarde intelligente d'un répertoire avec horodatage
    # USAGE: create_smart_backup
    create_smart_backup() {
        printf "Répertoire à sauvegarder: "
        read source_dir
        
        if [ ! -d "$source_dir" ]; then
            printf "${RED}❌ Répertoire inexistant${RESET}\n"
            return 1
        fi
        
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_name="backup_$(basename "$source_dir")_$timestamp"
        backup_dir="$HOME/Backups"
        
        mkdir -p "$backup_dir"
        
        printf "${CYAN}💾 Création de la sauvegarde...${RESET}\n"
        echo "Source: $source_dir"
        echo "Destination: $backup_dir/$backup_name.tar.gz"
        
        # Création de l'archive avec compression
        if tar -czf "$backup_dir/$backup_name.tar.gz" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>/dev/null; then
            size=$(du -h "$backup_dir/$backup_name.tar.gz" 2>/dev/null | cut -f1)
            printf "${GREEN}✅ Sauvegarde créée avec succès ($size)${RESET}\n"
            echo "Fichier: $backup_dir/$backup_name.tar.gz"
        else
            printf "${RED}❌ Erreur lors de la sauvegarde${RESET}\n"
        fi
    }
    
    # Extraction intelligente d'archives
    # DESC: Extrait une archive de manière interactive
    # USAGE: extract_archive
    extract_archive() {
        printf "Fichier d'archive à extraire: "
        read archive
        
        if [ ! -f "$archive" ]; then
            printf "${RED}❌ Fichier inexistant${RESET}\n"
            return 1
        fi
        
        printf "${CYAN}📦 Extraction de l'archive...${RESET}\n"
        
        case "$archive" in
            *.tar.bz2) tar xjf "$archive" 2>/dev/null ;;
            *.tar.gz)  tar xzf "$archive" 2>/dev/null ;;
            *.tar.xz)  tar xJf "$archive" 2>/dev/null ;;
            *.tar)     tar xf "$archive" 2>/dev/null ;;
            *.bz2)     bunzip2 "$archive" 2>/dev/null ;;
            *.gz)      gunzip "$archive" 2>/dev/null ;;
            *.zip)     unzip "$archive" 2>/dev/null ;;
            *.Z)       uncompress "$archive" 2>/dev/null ;;
            *.7z)      if command -v 7z >/dev/null 2>&1; then 7z x "$archive" 2>/dev/null; fi ;;
            *.rar)     if command -v unrar >/dev/null 2>&1; then unrar x "$archive" 2>/dev/null; fi ;;
            *)
                printf "${RED}❌ Format d'archive non supporté${RESET}\n"
                return 1
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            printf "${GREEN}✅ Archive extraite avec succès${RESET}\n"
        else
            printf "${RED}❌ Erreur lors de l'extraction${RESET}\n"
        fi
    }
    
    # Gestion des arguments rapides
    case "$1" in
        genpass|password)
            gen_password "$2"
            return 0
            ;;
        sysinfo|info)
            show_system_info
            return 0
            ;;
        copy)
            copy_file_advanced
            return 0
            ;;
        backup)
            create_smart_backup
            return 0
            ;;
        extract)
            extract_archive
            return 0
            ;;
    esac
    
    # Menu principal
    while true; do
        show_header
        printf "${GREEN}Menu Principal${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo
        echo "  ${BOLD}1${RESET}  🔐 Générer un mot de passe"
        echo "  ${BOLD}2${RESET}  💻 Informations système"
        echo "  ${BOLD}3${RESET}  📁 Copie de fichier avancée"
        echo "  ${BOLD}4${RESET}  💾 Sauvegarde intelligente"
        echo "  ${BOLD}5${RESET}  📦 Extraction d'archive"
        echo
        echo "  ${BOLD}h${RESET}  📚 Aide"
        echo "  ${BOLD}q${RESET}  🚪 Quitter"
        echo
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        printf "Votre choix: "
        read choice
        
        case "$choice" in
            1)
                printf "Longueur du mot de passe [16]: "
                read length
                gen_password "${length:-16}"
                echo
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            2) show_system_info ;;
            3) copy_file_advanced ;;
            4) create_smart_backup ;;
            5) extract_archive ;;
            h|H)
                show_header
                printf "${CYAN}📚 Aide - MISCMAN${RESET}\n"
                printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
                echo
                echo "MISCMAN est un gestionnaire d'outils divers et utilitaires."
                echo
                echo "Fonctionnalités:"
                echo "  • Génération de mots de passe sécurisés"
                echo "  • Informations système détaillées"
                echo "  • Copie de fichiers avec progression"
                echo "  • Sauvegarde intelligente"
                echo "  • Extraction d'archives"
                echo
                echo "Raccourcis:"
                echo "  miscman genpass [length]  - Générer un mot de passe"
                echo "  miscman sysinfo          - Informations système"
                echo "  miscman backup           - Créer une sauvegarde"
                echo "  miscman extract          - Extraire une archive"
                echo
                printf "Appuyez sur Entrée pour continuer... "
                read dummy
                ;;
            q|Q)
                printf "${GREEN}Au revoir!${RESET}\n"
                break
                ;;
            *)
                printf "${RED}Option invalide${RESET}\n"
                sleep 1
                ;;
        esac
    done
}
