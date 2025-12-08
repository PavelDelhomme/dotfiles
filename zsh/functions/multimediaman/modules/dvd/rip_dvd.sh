#!/bin/zsh
# =============================================================================
# RIP DVD - Module multimediaman
# =============================================================================
# Description: Pipeline automatique pour ripper un DVD (copie + encodage MP4)
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================
# Pipeline automatique en CLI avec deux briques:
# 1) Copie du DVD brut avec dvdbackup
# 2) Encodage propre en MP4 avec HandBrakeCLI (VF+VO, bonne qualité)
# =============================================================================

# DESC: Rippe un DVD avec copie brute puis encodage MP4
# USAGE: rip_dvd [title_name] [dvd_device] [quality]
# EXAMPLE: rip_dvd "Mon_Film"
# EXAMPLE: rip_dvd "Mon_Film" "/dev/sr0" "18"
rip_dvd() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    set -e  # Arrêter sur erreur
    
    # 1) Paramètres personnalisables
    local TITLE_NAME="${1:-dvd_title}"
    local DVD_DEVICE="${2:-/dev/sr0}"
    local PRESET_QUALITY="${3:-20}"  # RF 18-20 = très bonne qualité
    
    local OUT_DIR="$HOME/DVD_RIPS"
    
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║                    RIP DVD - PIPELINE AUTOMATIQUE              ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${RESET}\n"
    
    # Vérifier les pré-requis
    echo -e "${BLUE}[1/4]${RESET} Vérification des pré-requis..."
    
    if ! command -v HandBrakeCLI &>/dev/null; then
        echo -e "${RED}❌ HandBrakeCLI non trouvé${RESET}"
        echo -e "${YELLOW}Installez-le avec: installman handbrake${RESET}"
        return 1
    fi
    
    if ! command -v dvdbackup &>/dev/null; then
        echo -e "${RED}❌ dvdbackup non trouvé${RESET}"
        echo -e "${YELLOW}Installez-le avec: sudo pacman -S dvdbackup${RESET}"
        return 1
    fi
    
    if [ ! -b "$DVD_DEVICE" ]; then
        echo -e "${YELLOW}⚠️  Périphérique DVD non trouvé: $DVD_DEVICE${RESET}"
        echo -e "${CYAN}Vérifiez que le DVD est inséré et que le périphérique est correct${RESET}"
        read "?Continuer quand même? (o/N): " continue_choice
        if [[ ! "$continue_choice" =~ ^[oO]$ ]]; then
            return 1
        fi
    fi
    
    echo -e "${GREEN}✓ Pré-requis OK${RESET}\n"
    
    # Créer le dossier de sortie
    mkdir -p "$OUT_DIR"
    echo -e "${BLUE}[2/4]${RESET} Dossier de sortie: ${CYAN}$OUT_DIR${RESET}\n"
    
    # 2) Backup du DVD (copie brute)
    echo -e "${BLUE}[3/4]${RESET} Copie du DVD depuis ${CYAN}$DVD_DEVICE${RESET}..."
    
    local TMP_DVD_DIR=$(mktemp -d)
    echo -e "${CYAN}Dossier temporaire: $TMP_DVD_DIR${RESET}"
    
    if ! dvdbackup -i "$DVD_DEVICE" -o "$TMP_DVD_DIR" -F -p; then
        echo -e "${RED}❌ Erreur lors de la copie du DVD${RESET}"
        rm -rf "$TMP_DVD_DIR"
        return 1
    fi
    
    echo -e "${GREEN}✓ Copie du DVD terminée${RESET}\n"
    
    # Normalement dvdbackup crée un sous-dossier avec le nom du disque
    local SRC_DIR=$(find "$TMP_DVD_DIR" -maxdepth 2 -type d -name 'VIDEO_TS' -print -quit)
    
    if [ -z "$SRC_DIR" ]; then
        echo -e "${RED}❌ Impossible de trouver VIDEO_TS dans $TMP_DVD_DIR${RESET}"
        echo -e "${YELLOW}Structure trouvée:${RESET}"
        find "$TMP_DVD_DIR" -type d | head -10
        rm -rf "$TMP_DVD_DIR"
        return 1
    fi
    
    echo -e "${CYAN}Dossier source trouvé: $SRC_DIR${RESET}\n"
    
    # 3) Encodage avec HandBrakeCLI
    echo -e "${BLUE}[4/4]${RESET} Encodage vers MP4..."
    echo -e "${CYAN}Qualité: RF $PRESET_QUALITY (18-20 = très bonne qualité)${RESET}"
    echo -e "${CYAN}Format: MP4 H.264 + AAC (toutes pistes audio)${RESET}\n"
    
    local OUT_FILE="$OUT_DIR/${TITLE_NAME}.mp4"
    
    echo -e "${YELLOW}⏳ Encodage en cours... (cela peut prendre du temps)${RESET}\n"
    
    # Options HandBrakeCLI:
    # -f av_mp4 → MP4 (compat web)
    # -e x264 -q 18-20 → très bonne qualité
    # --all-audio → garde toutes les pistes audio (VF, VO, etc.)
    # --all-subtitles → garde tous les sous-titres
    # --optimize → rend le MP4 "fast start" pour le streaming web
    # --markers → garde les chapitres
    
    if HandBrakeCLI \
        -i "$SRC_DIR" \
        -o "$OUT_FILE" \
        -f av_mp4 \
        -e x264 -q "$PRESET_QUALITY" -E av_aac \
        --all-audio \
        --all-subtitles \
        --subtitle-burned=none \
        --optimize \
        --markers; then
        
        echo -e "\n${GREEN}✓ Encodage terminé !${RESET}\n"
        echo -e "${CYAN}${BOLD}Fichier créé:${RESET}"
        echo -e "${GREEN}$OUT_FILE${RESET}\n"
        
        # Afficher les informations du fichier
        if command -v ffprobe &>/dev/null; then
            echo -e "${CYAN}Informations du fichier:${RESET}"
            ffprobe -v quiet -print_format json -show_format -show_streams "$OUT_FILE" 2>/dev/null | \
                grep -E '"duration"|"codec_name"|"codec_type"|"language"' | head -10 || true
        fi
        
        # Taille du fichier
        local file_size=$(du -h "$OUT_FILE" | cut -f1)
        echo -e "${CYAN}Taille: $file_size${RESET}\n"
        
        echo -e "${YELLOW}💡 Note:${RESET} Vérifiez le fichier et les pistes audio (FR/EN)"
        echo -e "${YELLOW}   Si vous voulez forcer seulement FR+EN, ajustez le script${RESET}\n"
    else
        echo -e "\n${RED}❌ Erreur lors de l'encodage${RESET}"
        rm -rf "$TMP_DVD_DIR"
        return 1
    fi
    
    # Nettoyer le dossier temporaire
    echo -e "${CYAN}Nettoyage du dossier temporaire...${RESET}"
    rm -rf "$TMP_DVD_DIR"
    echo -e "${GREEN}✓ Nettoyage terminé${RESET}\n"
    
    echo -e "${GREEN}${BOLD}✅ RIP DVD TERMINÉ AVEC SUCCÈS !${RESET}\n"
    echo -e "${CYAN}Fichier final: ${GREEN}$OUT_FILE${RESET}\n"
    
    return 0
}

# Fonction pour ripper avec seulement FR+EN (optionnel)
# DESC: Rippe un DVD en forçant seulement les pistes audio FR et EN
# USAGE: rip_dvd_fr_en [title_name] [dvd_device] [quality]
rip_dvd_fr_en() {
    local TITLE_NAME="${1:-dvd_title}"
    local DVD_DEVICE="${2:-/dev/sr0}"
    local PRESET_QUALITY="${3:-20}"
    local OUT_DIR="$HOME/DVD_RIPS"
    
    # Même logique que rip_dvd mais avec --audio-lang-list fr,eng
    # (à implémenter si nécessaire)
    echo "Fonction rip_dvd_fr_en - À implémenter si nécessaire"
}

