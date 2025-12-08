#!/bin/zsh
# =============================================================================
# EXTRACT MANAGER - Module multimediaman
# =============================================================================
# Description: Gestionnaire d'extraction d'archives avec barre de progression CLI
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Affiche une barre de progression simple
# USAGE: show_progress <current> <total> <width>
show_progress() {
    local current=$1
    local total=$2
    local width=${3:-50}
    
    if [ "$total" -eq 0 ]; then
        return
    fi
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Construire la barre
    local bar=""
    local i=0
    while [ $i -lt $filled ]; do
        bar="${bar}█"
        i=$((i + 1))
    done
    i=0
    while [ $i -lt $empty ]; do
        bar="${bar}░"
        i=$((i + 1))
    done
    
    printf "\r[%s] %3d%%" "$bar" "$percent"
}

# DESC: Extrait une archive avec barre de progression
# USAGE: extract_with_progress <archive_file> [destination]
# EXAMPLE: extract_with_progress archive.zip
# EXAMPLE: extract_with_progress archive.tar.gz /tmp/extract
extract_with_progress() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local archive_file="$1"
    local destination="${2:-.}"
    
    # Vérifier que le fichier existe
    if [ ! -f "$archive_file" ]; then
        echo -e "${RED}❌ Erreur: Fichier '$archive_file' introuvable${RESET}"
        return 1
    fi
    
    # Créer le répertoire de destination si nécessaire
    mkdir -p "$destination"
    
    local filename=$(basename "$archive_file")
    local file_size=$(stat -f%z "$archive_file" 2>/dev/null || stat -c%s "$archive_file" 2>/dev/null || echo "0")
    local file_size_mb=$((file_size / 1024 / 1024))
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║              EXTRACTION D'ARCHIVE AVEC PROGRESSION              ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    echo -e "${BLUE}📦 Archive:${RESET} ${CYAN}$filename${RESET}"
    echo -e "${BLUE}📁 Destination:${RESET} ${CYAN}$destination${RESET}"
    echo -e "${BLUE}📊 Taille:${RESET} ${CYAN}${file_size_mb} MB${RESET}\n"
    
    # Détecter le format et extraire
    local success=false
    local start_time=$(date +%s)
    
    case "$archive_file" in
        *.tar.bz2|*.tbz2)
            echo -e "${YELLOW}🔧 Format: tar.bz2${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | tar xjf - -C "$destination" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                tar xjf "$archive_file" -C "$destination" && success=true
            fi
            ;;
        *.tar.gz|*.tgz)
            echo -e "${YELLOW}🔧 Format: tar.gz${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | tar xzf - -C "$destination" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                tar xzf "$archive_file" -C "$destination" && success=true
            fi
            ;;
        *.tar.xz|*.txz)
            echo -e "${YELLOW}🔧 Format: tar.xz${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | tar xJf - -C "$destination" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                tar xJf "$archive_file" -C "$destination" && success=true
            fi
            ;;
        *.tar)
            echo -e "${YELLOW}🔧 Format: tar${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | tar xf - -C "$destination" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                tar xf "$archive_file" -C "$destination" && success=true
            fi
            ;;
        *.zip)
            echo -e "${YELLOW}🔧 Format: zip${RESET}"
            if ! command -v unzip &>/dev/null; then
                echo -e "${RED}❌ Erreur: 'unzip' n'est pas installé${RESET}"
                echo -e "${YELLOW}💡 Installez-le avec: sudo pacman -S unzip${RESET}"
                return 1
            fi
            
            # Compter le nombre de fichiers dans le zip
            local total_files=$(unzip -l "$archive_file" 2>/dev/null | tail -1 | awk '{print $2}')
            if [ -z "$total_files" ] || [ "$total_files" = "0" ]; then
                total_files=1
            fi
            
            echo -e "${YELLOW}📊 Fichiers à extraire: $total_files${RESET}\n"
            
            # Extraire avec progression
            local extracted=0
            unzip -o "$archive_file" -d "$destination" 2>&1 | while IFS= read -r line; do
                if [[ "$line" =~ extracting:\ (.+) ]]; then
                    ((extracted++))
                    show_progress "$extracted" "$total_files" 50
                fi
            done
            echo ""  # Nouvelle ligne après la barre
            success=true
            ;;
        *.rar)
            echo -e "${YELLOW}🔧 Format: rar${RESET}"
            if command -v unrar &>/dev/null; then
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                unrar x -o+ "$archive_file" "$destination" && success=true
            elif command -v rar &>/dev/null; then
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                rar x -o+ "$archive_file" "$destination" && success=true
            else
                echo -e "${RED}❌ Erreur: 'unrar' ou 'rar' n'est pas installé${RESET}"
                echo -e "${YELLOW}💡 Installez-le avec: sudo pacman -S unrar${RESET}"
                return 1
            fi
            ;;
        *.7z)
            echo -e "${YELLOW}🔧 Format: 7z${RESET}"
            if ! command -v 7z &>/dev/null; then
                echo -e "${RED}❌ Erreur: '7z' n'est pas installé${RESET}"
                echo -e "${YELLOW}💡 Installez-le avec: sudo pacman -S p7zip${RESET}"
                return 1
            fi
            echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
            7z x -o"$destination" "$archive_file" && success=true
            ;;
        *.gz)
            echo -e "${YELLOW}🔧 Format: gzip${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | gunzip -c > "${archive_file%.gz}" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                gunzip "$archive_file" && success=true
            fi
            ;;
        *.bz2)
            echo -e "${YELLOW}🔧 Format: bzip2${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | bunzip2 -c > "${archive_file%.bz2}" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                bunzip2 "$archive_file" && success=true
            fi
            ;;
        *.xz)
            echo -e "${YELLOW}🔧 Format: xz${RESET}"
            if command -v pv &>/dev/null; then
                pv "$archive_file" | unxz -c > "${archive_file%.xz}" && success=true
            else
                echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
                unxz "$archive_file" && success=true
            fi
            ;;
        *.Z)
            echo -e "${YELLOW}🔧 Format: compress${RESET}"
            echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
            uncompress "$archive_file" && success=true
            ;;
        *.deb)
            echo -e "${YELLOW}🔧 Format: Debian package${RESET}"
            if ! command -v ar &>/dev/null; then
                echo -e "${RED}❌ Erreur: 'ar' n'est pas installé${RESET}"
                return 1
            fi
            local deb_dir="$destination/$(basename "$archive_file" .deb)"
            mkdir -p "$deb_dir"
            cd "$deb_dir" && ar x "../$archive_file" && success=true
            cd - >/dev/null
            ;;
        *.rpm)
            echo -e "${YELLOW}🔧 Format: RPM package${RESET}"
            if ! command -v rpm2cpio &>/dev/null; then
                echo -e "${RED}❌ Erreur: 'rpm2cpio' n'est pas installé${RESET}"
                return 1
            fi
            echo -e "${YELLOW}⏳ Extraction en cours...${RESET}"
            cd "$destination" && rpm2cpio "$archive_file" | cpio -idmv && success=true
            cd - >/dev/null
            ;;
        *)
            echo -e "${RED}❌ Format non supporté: $archive_file${RESET}"
            echo -e "${YELLOW}💡 Formats supportés: tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm${RESET}"
            return 1
            ;;
    esac
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ "$success" = true ]; then
        echo ""
        echo -e "${GREEN}${BOLD}✅ EXTRACTION TERMINÉE AVEC SUCCÈS !${RESET}\n"
        echo -e "${CYAN}⏱️  Durée: ${duration}s${RESET}"
        echo -e "${CYAN}📁 Contenu extrait dans: ${GREEN}$destination${RESET}\n"
        return 0
    else
        echo ""
        echo -e "${RED}${BOLD}❌ ERREUR LORS DE L'EXTRACTION${RESET}\n"
        return 1
    fi
}

# DESC: Liste le contenu d'une archive sans l'extraire
# USAGE: list_archive <archive_file>
list_archive() {
    local archive_file="$1"
    
    if [ ! -f "$archive_file" ]; then
        echo -e "${RED}❌ Erreur: Fichier '$archive_file' introuvable${RESET}"
        return 1
    fi
    
    echo -e "${CYAN}${BOLD}📋 CONTENU DE L'ARCHIVE: $(basename "$archive_file")${RESET}\n"
    
    case "$archive_file" in
        *.tar.bz2|*.tbz2|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar)
            tar -tf "$archive_file" | head -50
            ;;
        *.zip)
            if command -v unzip &>/dev/null; then
                unzip -l "$archive_file" | head -50
            else
                echo -e "${RED}❌ Erreur: 'unzip' n'est pas installé${RESET}"
                return 1
            fi
            ;;
        *.rar)
            if command -v unrar &>/dev/null; then
                unrar l "$archive_file" | head -50
            elif command -v rar &>/dev/null; then
                rar l "$archive_file" | head -50
            else
                echo -e "${RED}❌ Erreur: 'unrar' ou 'rar' n'est pas installé${RESET}"
                return 1
            fi
            ;;
        *.7z)
            if command -v 7z &>/dev/null; then
                7z l "$archive_file" | head -50
            else
                echo -e "${RED}❌ Erreur: '7z' n'est pas installé${RESET}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Format non supporté${RESET}"
            return 1
            ;;
    esac
}

